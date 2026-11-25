-- =============================================================================
-- ReCan v2.0 migration
--
--   1. Drop station capacity 300
--   2. Daily check-in that never resets on a missed day (Asia/Jakarta calendar)
--   3. Catalog payment with points, cash or both
--   4. Admin / produser portal support and QR hardening
--
-- Run schema.sql (and the 20261124 migration) first, then paste this whole file
-- into Supabase Dashboard > SQL Editor and run it. It is safe to run again.
--
-- Re-running schema.sql restores the v1 functions, grants and policies, so run
-- this file again right after it.
--
-- BREAKING: app builds older than 2.0.0 can no longer deposit cans, because
-- record_can_deposit now requires the scanned QR value.
--
-- NEW ERROR CODES
--   invalid_qr_code, station_empty, assignment_required, assignment_exists,
--   assignment_not_found, assignment_not_active, invalid_produser,
--   invalid_payment_method, invalid_points, invalid_payment_channel,
--   payment_method_not_allowed
-- =============================================================================

begin;

do $$
begin
  if to_regclass('public.drop_stations') is null then
    raise exception 'Run supabase/schema.sql before this migration';
  end if;
end $$;


-- =============================================================================
-- 1. STATION CAPACITY
-- =============================================================================

alter table public.drop_stations alter column max_capacity set default 300;

-- The status trigger recomputes available/full for every row touched here.
update public.drop_stations
   set max_capacity = 300,
       current_cans = least(current_cans, 300)
 where max_capacity <> 300 or current_cans > 300;


-- =============================================================================
-- 2. DAILY CHECK-IN AND QUEST CALENDAR
-- =============================================================================

create or replace function public.app_today()
returns date
language sql stable set search_path = ''
as $$ select (now() at time zone 'Asia/Jakarta')::date $$;

create or replace function public.period_start_for(p_period text, p_day date default public.app_today())
returns date
language sql stable set search_path = ''
as $$
  select case p_period
    when 'daily'   then p_day
    when 'weekly'  then date_trunc('week', p_day::timestamp)::date
    when 'monthly' then date_trunc('month', p_day::timestamp)::date
  end
$$;

-- day_index used to be the weekday, which started a Wednesday sign-up on day 3.
-- It is now the position in the reward cycle, so old rows are renumbered in
-- claim order.
with ordered as (
  select c.user_id, c.checkin_date,
         ((row_number() over (partition by c.user_id order by c.checkin_date) - 1)
           % jsonb_array_length(public.app_setting('checkin_rewards')))::smallint as idx
  from public.user_checkins c
)
update public.user_checkins c
   set day_index = o.idx
  from ordered o
 where c.user_id = o.user_id
   and c.checkin_date = o.checkin_date
   and c.day_index is distinct from o.idx;

update public.app_settings
   set description = 'Daily check-in reward per cycle day (day 1 first). A missed calendar day does not reset the cycle'
 where key = 'checkin_rewards';

comment on table public.user_checkins is
  'Daily check-in claims, one per Asia/Jakarta calendar day. day_index is the position in the reward cycle (0 = day 1).';

drop function if exists public.my_checkin_state();
create function public.my_checkin_state()
returns table (
  claimed_count integer,
  claimed_today boolean,
  next_claim_at timestamptz,
  rewards       jsonb
)
language sql stable set search_path = ''
as $$
  with cfg as (
    select public.app_today() as today,
           public.app_setting('checkin_rewards') as rewards
  ),
  latest as (
    -- RLS lets an admin see every row, so the caller filter is explicit.
    select c.checkin_date, c.day_index
    from public.user_checkins c
    where c.user_id = auth.uid()
    order by c.checkin_date desc
    limit 1
  )
  select case
           when l.checkin_date is null then 0
           when l.checkin_date >= cfg.today then l.day_index + 1
           else (l.day_index + 1) % jsonb_array_length(cfg.rewards)
         end,
         coalesce(l.checkin_date >= cfg.today, false),
         case when l.checkin_date >= cfg.today
              then (cfg.today + 1)::timestamp at time zone 'Asia/Jakarta'
         end,
         cfg.rewards
  from cfg
  left join latest l on true
$$;

create or replace function public.claim_daily_checkin()
returns table (
  day_index     integer,
  points_earned integer,
  new_points    integer,
  streak_days   integer
)
language plpgsql security definer set search_path = ''
as $$
#variable_conflict use_column
declare
  v_uid     uuid := auth.uid();
  v_today   date := public.app_today();
  v_rewards jsonb := public.app_setting('checkin_rewards');
  v_last    integer;
  v_idx     integer;
  v_reward  integer;
  v_profile public.profiles%rowtype;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  -- Serialises two claims of one user, so both cannot read the same last day.
  perform 1 from public.profiles p where p.id = v_uid for update;
  if not found then
    raise exception 'profile_not_found' using errcode = 'P0002';
  end if;

  select c.day_index into v_last
  from public.user_checkins c
  where c.user_id = v_uid and c.checkin_date < v_today
  order by c.checkin_date desc
  limit 1;

  v_idx := coalesce((v_last + 1) % jsonb_array_length(v_rewards), 0);
  v_reward := (v_rewards ->> v_idx)::integer;

  insert into public.user_checkins (user_id, checkin_date, day_index, reward_points)
  values (v_uid, v_today, v_idx, v_reward)
  on conflict (user_id, checkin_date) do nothing;
  if not found then
    raise exception 'already_claimed' using errcode = 'P0001';
  end if;

  update public.profiles p set points = p.points + v_reward where p.id = v_uid
  returning * into v_profile;

  insert into public.transactions
    (reference, user_id, type, points_delta, title, title_en, metadata)
  values
    (public.new_reference(), v_uid, 'checkin', v_reward,
     'Hadiah Harian', 'Daily Reward', jsonb_build_object('day_index', v_idx));

  perform public.advance_quests(v_uid, 'checkIn', 1);

  return query select v_idx, v_reward, v_profile.points, public.checkin_streak(v_uid);
end;
$$;


-- =============================================================================
-- 3. CATALOG PAYMENT: POINTS, CASH OR HYBRID
-- Cash is simulated: no gateway confirms it, so those rows are stored with
-- payment_status 'simulated' and must not be fulfilled as paid orders.
-- =============================================================================

alter table public.transactions
  add column if not exists payment_method  text,
  add column if not exists points_used     integer not null default 0,
  add column if not exists cash_paid       integer not null default 0,
  add column if not exists gross_idr       integer,
  add column if not exists payment_channel text,
  add column if not exists payment_status  text;

update public.transactions
   set payment_method = 'points',
       points_used = -points_delta,
       payment_status = 'paid'
 where type = 'redeem' and payment_method is null;

alter table public.transactions
  drop constraint if exists transactions_redeem_check,
  drop constraint if exists transactions_payment_check,
  drop constraint if exists transactions_payment_values_check;

alter table public.transactions
  add constraint transactions_redeem_check check (
    type <> 'redeem' or (
      payment_method is not null
      and points_delta <= 0
      and (points_delta < 0 or cash_paid > 0)
    )
  ),
  add constraint transactions_payment_check check (
    payment_method is null or (
      points_delta = -points_used and (
        (payment_method = 'points' and points_used > 0 and cash_paid = 0 and payment_channel is null) or
        (payment_method = 'cash'   and points_used = 0 and cash_paid > 0 and payment_channel is not null) or
        (payment_method = 'hybrid' and points_used > 0 and cash_paid > 0 and payment_channel is not null)
      )
    )
  ),
  add constraint transactions_payment_values_check check (
    points_used >= 0
    and cash_paid >= 0
    and (gross_idr is null or gross_idr >= 0)
    and (payment_channel is null or payment_channel in ('qris', 'bank_transfer', 'ewallet'))
    and (payment_status is null or payment_status in ('paid', 'simulated'))
  );

comment on column public.transactions.gross_idr is
  'Rupiah price of the order before the points discount. NULL for items without a rupiah price.';
comment on column public.transactions.payment_status is
  'paid = settled with points only; simulated = contains a cash part that no payment gateway confirmed.';

-- The old four-argument version would otherwise remain as an ambiguous overload.
drop function if exists public.redeem_reward(bigint, integer, text, text);
drop function if exists public.redeem_reward(bigint, integer, text, text, text, integer, text);
create function public.redeem_reward(
  p_item_id          bigint,
  p_quantity         integer default 1,
  p_shipping_address text default null,
  p_notes            text default null,
  p_payment_method   text default 'points',
  p_points_used      integer default null,
  p_payment_channel  text default null
)
returns table (
  transaction_id  uuid,
  reference       text,
  points_spent    integer,
  new_points      integer,
  tier            text,
  payment_method  text,
  cash_paid       integer,
  payment_channel text,
  gross_idr       integer,
  payment_status  text
)
language plpgsql security definer set search_path = ''
as $$
#variable_conflict use_column
declare
  v_uid     uuid := auth.uid();
  v_qty     integer := coalesce(p_quantity, 1);
  v_method  text := coalesce(p_payment_method, 'points');
  v_channel text := p_payment_channel;
  v_item    public.catalog_items%rowtype;
  v_profile public.profiles%rowtype;
  v_full    integer;
  v_points  integer;
  v_gross   integer;
  v_cash    integer := 0;
  v_status  text := 'paid';
  v_ref     text;
  v_tx      uuid;
  v_suffix  text;
  v_address text := nullif(btrim(coalesce(p_shipping_address, '')), '');
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if v_qty < 1 or v_qty > 100 then
    raise exception 'invalid_quantity' using errcode = '22023';
  end if;
  if v_method not in ('points', 'cash', 'hybrid') then
    raise exception 'invalid_payment_method' using errcode = '22023';
  end if;

  select * into v_item from public.catalog_items i where i.id = p_item_id for update;
  if not found or not v_item.is_active then
    raise exception 'item_not_found' using errcode = 'P0002';
  end if;
  if v_item.item_type <> 'product' and v_qty <> 1 then
    raise exception 'invalid_quantity' using errcode = '22023';
  end if;
  -- Vouchers have no rupiah price and e-wallet balance cannot be bought with money.
  if v_method <> 'points'
     and (v_item.item_type <> 'product' or coalesce(v_item.price_idr, 0) <= 0) then
    raise exception 'payment_method_not_allowed' using errcode = '22023';
  end if;
  if v_item.item_type = 'product' then
    if v_address is null then
      raise exception 'shipping_address_required' using errcode = '22023';
    end if;
    if v_item.stock < v_qty then
      raise exception 'out_of_stock' using errcode = 'P0001';
    end if;
  end if;

  v_full  := v_item.price_points * v_qty;
  v_gross := v_item.price_idr * v_qty;
  v_points := case v_method
                when 'points' then coalesce(p_points_used, v_full)
                when 'cash'   then coalesce(p_points_used, 0)
                else p_points_used
              end;

  if v_points is null or v_points < 0 or v_points > v_full
     or (v_method = 'points' and v_points <> v_full)
     or (v_method = 'cash'   and v_points <> 0)
     or (v_method = 'hybrid' and (v_points = 0 or v_points = v_full)) then
    raise exception 'invalid_points' using errcode = '22023';
  end if;

  if v_method = 'points' then
    v_channel := null;
  else
    -- Discount rounds down, so rounding never favours spending fewer points.
    v_cash := v_gross - ((v_gross::bigint * v_points) / v_full)::integer;
    if v_method = 'hybrid' and v_cash >= v_gross then
      raise exception 'invalid_points' using errcode = '22023';
    end if;
    if v_channel is null or v_channel not in ('qris', 'bank_transfer', 'ewallet') then
      raise exception 'invalid_payment_channel' using errcode = '22023';
    end if;
    v_status := 'simulated';
  end if;

  select * into v_profile from public.profiles p where p.id = v_uid for update;
  if not found then
    raise exception 'profile_not_found' using errcode = 'P0002';
  end if;
  if v_profile.points < v_points then
    raise exception 'insufficient_points' using errcode = 'P0001';
  end if;

  update public.profiles p set points = p.points - v_points where p.id = v_uid
  returning * into v_profile;

  if v_item.item_type = 'product' then
    update public.catalog_items i set stock = i.stock - v_qty where i.id = v_item.id;
  end if;

  v_ref := public.new_reference();
  v_suffix := case when v_qty > 1 then ' x' || v_qty else '' end;

  insert into public.transactions
    (reference, user_id, item_id, type, points_delta, title, title_en, metadata,
     payment_method, points_used, cash_paid, gross_idr, payment_channel, payment_status)
  values
    (v_ref, v_uid, v_item.id, 'redeem', -v_points,
     case when v_method = 'points' then 'Tukar ' else 'Beli ' end || v_item.name || v_suffix,
     case when v_method = 'points' then 'Redeemed ' else 'Bought ' end || v_item.name_en || v_suffix,
     jsonb_strip_nulls(jsonb_build_object(
       'item_type', v_item.item_type,
       'quantity', v_qty,
       'shipping_address', v_address,
       'notes', nullif(btrim(coalesce(p_notes, '')), ''),
       'ewallet_provider', v_item.ewallet_provider,
       'ewallet_nominal', v_item.ewallet_nominal
     )),
     v_method, v_points, v_cash, v_gross, v_channel, v_status)
  returning id into v_tx;

  if v_item.item_type = 'voucher' then
    insert into public.owned_vouchers (user_id, item_id, transaction_id, reference)
    values (v_uid, v_item.id, v_tx, v_ref);
    perform public.advance_quests(v_uid, 'voucher', 1);
  elsif v_item.item_type = 'product' and v_points > 0 then
    -- An unconfirmed cash order must not be able to earn quest points.
    perform public.advance_quests(v_uid, 'product', 1);
  end if;

  return query select v_tx, v_ref, v_points, v_profile.points, v_profile.tier,
    v_method, v_cash, v_channel, v_gross, v_status;
end;
$$;


-- =============================================================================
-- 4. PORTAL SUPPORT AND SECURITY
-- =============================================================================

-- ---- pickup_assignments -----------------------------------------------------
create table if not exists public.pickup_assignments (
  id            uuid primary key default gen_random_uuid(),
  station_id    bigint not null references public.drop_stations (id) on delete restrict,
  produser_id   uuid not null references public.profiles (id) on delete cascade,
  assigned_by   uuid references public.profiles (id) on delete set null,
  status        text not null default 'assigned',
  scheduled_for timestamptz,
  notes         text,
  created_at    timestamptz not null default now(),
  started_at    timestamptz,
  completed_at  timestamptz,
  cancelled_at  timestamptz,
  updated_at    timestamptz not null default now(),
  constraint pickup_assignments_status_check
    check (status in ('assigned', 'in_progress', 'completed', 'cancelled'))
);
create unique index if not exists pickup_assignments_active_station_key
  on public.pickup_assignments (station_id)
  where status in ('assigned', 'in_progress');
create index if not exists pickup_assignments_produser_idx
  on public.pickup_assignments (produser_id, created_at desc);
comment on table public.pickup_assignments is
  'Pickup tasks given to produsers. At most one active task per station. Written only through RPC functions.';

drop trigger if exists pickup_assignments_updated_at on public.pickup_assignments;
create trigger pickup_assignments_updated_at before update on public.pickup_assignments
  for each row execute function public.set_updated_at();

alter table public.pickup_logs
  add column if not exists assignment_id uuid
    references public.pickup_assignments (id) on delete set null;

-- ---- RLS and grants ---------------------------------------------------------
alter table public.pickup_assignments enable row level security;
revoke all on public.pickup_assignments from anon, authenticated;
grant select on public.pickup_assignments to authenticated;

drop policy if exists pickup_assignments_read on public.pickup_assignments;
create policy pickup_assignments_read on public.pickup_assignments
  for select to authenticated
  using (public.is_admin() or (produser_id = (select auth.uid()) and public.is_staff()));

drop policy if exists pickup_logs_staff_read on public.pickup_logs;
drop policy if exists pickup_logs_read on public.pickup_logs;
create policy pickup_logs_read on public.pickup_logs
  for select to authenticated
  using (public.is_admin() or (produser_id = (select auth.uid()) and public.is_staff()));

-- Column grants: qr_code is unreadable and current_cans unwritable for clients.
-- A column added to drop_stations later has to be listed here to be visible.
revoke all on public.drop_stations from anon, authenticated;
grant select (id, name, name_en, location, location_en, address, lat, lng,
              current_cans, max_capacity, capacity_percentage, status,
              opens_at, closes_at, open_24h, image_url, created_at, updated_at)
  on public.drop_stations to anon, authenticated;
grant insert (name, name_en, location, location_en, address, lat, lng,
              max_capacity, status, opens_at, closes_at, open_24h, image_url)
  on public.drop_stations to authenticated;
grant update (name, name_en, location, location_en, address, lat, lng,
              max_capacity, status, opens_at, closes_at, open_24h, image_url)
  on public.drop_stations to authenticated;
grant delete on public.drop_stations to authenticated;

-- ---- station RPCs -----------------------------------------------------------
drop function if exists public.station_by_qr(text);
create function public.station_by_qr(p_qr_code text)
returns table (
  id                  bigint,
  name                text,
  name_en             text,
  lat                 double precision,
  lng                 double precision,
  status              text,
  current_cans        integer,
  max_capacity        integer,
  capacity_percentage integer
)
language plpgsql stable security definer set search_path = ''
as $$
#variable_conflict use_column
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  return query
    select s.id, s.name, s.name_en, s.lat, s.lng, s.status,
           s.current_cans, s.max_capacity, s.capacity_percentage
    from public.drop_stations s
    where s.qr_code = btrim(p_qr_code);
end;
$$;

drop function if exists public.admin_list_stations();
create function public.admin_list_stations()
returns setof public.drop_stations
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not public.is_admin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  return query select * from public.drop_stations s order by s.id;
end;
$$;

drop function if exists public.admin_regenerate_station_qr(bigint);
create function public.admin_regenerate_station_qr(p_station_id bigint)
returns text
language plpgsql security definer set search_path = ''
as $$
declare
  v_code text;
begin
  if not public.is_admin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  v_code := 'RECAN-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10));
  update public.drop_stations s set qr_code = v_code where s.id = p_station_id;
  if not found then
    raise exception 'station_not_found' using errcode = 'P0002';
  end if;
  return v_code;
end;
$$;

-- ---- record_can_deposit -----------------------------------------------------
-- The scanned QR value is now required, so a station id alone no longer earns
-- points. The printed code is static: regenerate it if it leaks.
drop function if exists public.record_can_deposit(bigint, integer, boolean, jsonb);
drop function if exists public.record_can_deposit(bigint, integer, text, jsonb);
create function public.record_can_deposit(
  p_station_id bigint,
  p_cans_count integer,
  p_qr_code    text default null,
  p_metadata   jsonb default '{}'::jsonb
)
returns table (
  transaction_id uuid,
  reference      text,
  points_earned  integer,
  weight_kg      numeric,
  carbon_kg      numeric,
  new_points     integer,
  new_total_cans integer,
  tier           text
)
language plpgsql security definer set search_path = ''
as $$
#variable_conflict use_column
declare
  v_uid     uuid := auth.uid();
  v_station public.drop_stations%rowtype;
  v_profile public.profiles%rowtype;
  v_points  integer;
  v_weight  numeric;
  v_ref     text;
  v_tx      uuid;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if p_cans_count is null or p_cans_count < 1
     or p_cans_count > public.setting_int('max_cans_per_deposit') then
    raise exception 'invalid_cans_count' using errcode = '22023';
  end if;

  select * into v_station from public.drop_stations s where s.id = p_station_id for update;
  if not found then
    raise exception 'station_not_found' using errcode = 'P0002';
  end if;
  if p_qr_code is null or btrim(p_qr_code) <> v_station.qr_code then
    raise exception 'invalid_qr_code' using errcode = '22023';
  end if;
  if v_station.status in ('maintenance', 'offline') then
    raise exception 'station_unavailable' using errcode = 'P0001';
  end if;
  if v_station.status = 'full'
     or v_station.current_cans + p_cans_count > v_station.max_capacity then
    raise exception 'station_full' using errcode = 'P0001';
  end if;

  v_points := p_cans_count * public.setting_int('points_per_can');
  v_weight := p_cans_count * public.setting_num('grams_per_can') / 1000.0;
  v_ref    := public.new_reference();

  update public.profiles p
     set points = p.points + v_points,
         total_cans = p.total_cans + p_cans_count
   where p.id = v_uid
  returning * into v_profile;
  if not found then
    raise exception 'profile_not_found' using errcode = 'P0002';
  end if;

  update public.drop_stations s
     set current_cans = s.current_cans + p_cans_count
   where s.id = p_station_id;

  insert into public.transactions
    (reference, user_id, station_id, type, points_delta, cans_delta, weight_kg, title, title_en, metadata)
  values
    (v_ref, v_uid, p_station_id, 'deposit', v_points, p_cans_count, v_weight,
     'Setor ' || p_cans_count || ' Kaleng',
     'Dropped ' || p_cans_count || ' Cans',
     coalesce(p_metadata, '{}'::jsonb))
  returning id into v_tx;

  perform public.advance_quests(v_uid, 'cans', p_cans_count);

  return query select
    v_tx, v_ref, v_points, v_weight,
    round(p_cans_count * public.setting_num('carbon_kg_per_can'), 2),
    v_profile.points, v_profile.total_cans, v_profile.tier;
end;
$$;

-- ---- pickup RPCs ------------------------------------------------------------
drop function if exists public.admin_assign_pickup(bigint, uuid, timestamptz, text);
create function public.admin_assign_pickup(
  p_station_id    bigint,
  p_produser_id   uuid,
  p_scheduled_for timestamptz default null,
  p_notes         text default null
)
returns uuid
language plpgsql security definer set search_path = ''
as $$
declare
  v_id uuid;
begin
  if not public.is_admin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  perform 1 from public.drop_stations s where s.id = p_station_id for update;
  if not found then
    raise exception 'station_not_found' using errcode = 'P0002';
  end if;
  if not exists (
    select 1 from public.profiles p where p.id = p_produser_id and p.role = 'produser'
  ) then
    raise exception 'invalid_produser' using errcode = '22023';
  end if;
  if exists (
    select 1 from public.pickup_assignments a
    where a.station_id = p_station_id and a.status in ('assigned', 'in_progress')
  ) then
    raise exception 'assignment_exists' using errcode = 'P0001';
  end if;

  insert into public.pickup_assignments
    (station_id, produser_id, assigned_by, scheduled_for, notes)
  values
    (p_station_id, p_produser_id, auth.uid(), p_scheduled_for,
     nullif(btrim(coalesce(p_notes, '')), ''))
  returning id into v_id;
  return v_id;
end;
$$;

drop function if exists public.admin_cancel_pickup(uuid);
create function public.admin_cancel_pickup(p_assignment_id uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_status text;
begin
  if not public.is_admin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select a.status into v_status
  from public.pickup_assignments a where a.id = p_assignment_id for update;
  if not found then
    raise exception 'assignment_not_found' using errcode = 'P0002';
  end if;
  if v_status not in ('assigned', 'in_progress') then
    raise exception 'assignment_not_active' using errcode = 'P0001';
  end if;
  update public.pickup_assignments a
     set status = 'cancelled', cancelled_at = now()
   where a.id = p_assignment_id;
end;
$$;

drop function if exists public.start_pickup(uuid);
create function public.start_pickup(p_assignment_id uuid)
returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_task public.pickup_assignments%rowtype;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if not public.is_staff() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  select * into v_task
  from public.pickup_assignments a where a.id = p_assignment_id for update;
  if not found then
    raise exception 'assignment_not_found' using errcode = 'P0002';
  end if;
  if v_task.produser_id <> auth.uid() and not public.is_admin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if v_task.status <> 'assigned' then
    raise exception 'assignment_not_active' using errcode = 'P0001';
  end if;
  update public.pickup_assignments a
     set status = 'in_progress', started_at = now()
   where a.id = p_assignment_id;
end;
$$;

-- A produser needs the active task of that station; an admin may override, and
-- either way the active task is closed with the pickup.
create or replace function public.confirm_station_pickup(
  p_station_id bigint,
  p_notes      text default null
)
returns table (
  pickup_id      uuid,
  cans_collected integer,
  picked_up_at   timestamptz
)
language plpgsql security definer set search_path = ''
as $$
#variable_conflict use_column
declare
  v_uid     uuid := auth.uid();
  v_station public.drop_stations%rowtype;
  v_task    public.pickup_assignments%rowtype;
  v_id      uuid;
  v_at      timestamptz;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if not public.is_staff() then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  select * into v_station from public.drop_stations s where s.id = p_station_id for update;
  if not found then
    raise exception 'station_not_found' using errcode = 'P0002';
  end if;

  select * into v_task
  from public.pickup_assignments a
  where a.station_id = p_station_id and a.status in ('assigned', 'in_progress')
  for update;

  if not public.is_admin() and v_task.produser_id is distinct from v_uid then
    raise exception 'assignment_required' using errcode = '42501';
  end if;
  if v_station.current_cans = 0 then
    raise exception 'station_empty' using errcode = 'P0001';
  end if;

  insert into public.pickup_logs
    (station_id, produser_id, cans_collected, notes, assignment_id)
  values
    (p_station_id, v_uid, v_station.current_cans,
     nullif(btrim(coalesce(p_notes, '')), ''), v_task.id)
  returning id, picked_up_at into v_id, v_at;

  update public.drop_stations s set current_cans = 0 where s.id = p_station_id;

  update public.pickup_assignments a
     set status = 'completed', completed_at = v_at
   where a.id = v_task.id;

  return query select v_id, v_station.current_cans, v_at;
end;
$$;

-- ---- function grants --------------------------------------------------------
-- Supabase grants new functions to anon by default, so every RPC is reset here.
do $$
declare
  f text;
begin
  foreach f in array array[
    'public.my_checkin_state()',
    'public.claim_daily_checkin()',
    'public.redeem_reward(bigint, integer, text, text, text, integer, text)',
    'public.record_can_deposit(bigint, integer, text, jsonb)',
    'public.station_by_qr(text)',
    'public.admin_list_stations()',
    'public.admin_regenerate_station_qr(bigint)',
    'public.admin_assign_pickup(bigint, uuid, timestamptz, text)',
    'public.admin_cancel_pickup(uuid)',
    'public.start_pickup(uuid)',
    'public.confirm_station_pickup(bigint, text)'
  ] loop
    execute format('revoke all on function %s from public, anon', f);
    execute format('grant execute on function %s to authenticated', f);
  end loop;
end $$;

-- ---- realtime ---------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array['pickup_assignments', 'pickup_logs'] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;

commit;

notify pgrst, 'reload schema';

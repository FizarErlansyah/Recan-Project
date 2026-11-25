-- =============================================================================
--  ReCan - Supabase schema (Stage 1: SQL only)
--  Recycle your can: circular economy platform for can collection,
--  drop-station management and real-time community impact tracking.
--
--  Clients served by this schema
--    * Mobile app (Flutter)  -> role 'user'
--    * Web portal Produser   -> role 'produser' (collects cans from stations)
--    * Web portal Admin      -> role 'admin'    (manages stations, catalog, content)
--
--  HOW TO RUN
--    Paste the whole file into Supabase Dashboard > SQL Editor > New query > Run.
--    The script is re-runnable: tables use IF NOT EXISTS, functions/views are
--    replaced, policies are dropped and recreated, seed rows use
--    ON CONFLICT DO NOTHING. Requires PostgreSQL 15+ (every current Supabase
--    project). Changing an existing column type needs a manual ALTER TABLE.
--    This file is the v1 base. After running it, run every file in
--    supabase/migrations/ in order. Re-running it restores v1 functions, grants
--    and policies, so the migrations must be run again afterwards.
--
--  CONTENTS
--    1. Tables (ERD)                       7. Row Level Security policies
--    2. Helper functions                   8. Storage buckets and policies
--    3. Triggers                           9. Realtime publication
--    4. RPC functions (business rules)    10. Seed data
--    5. Views
--    6. Grants
--
--  ERD (arrows point to the referenced table)
--
--    auth.users 1---1 profiles <---------------------------------------.
--                      ^  ^  ^  ^  ^                                    |
--                      |  |  |  |  '-- user_quest_progress --> quest_definitions
--                      |  |  |  '----- user_checkins                    |
--                      |  |  '-------- article_bookmarks --> education_articles
--                      |  |            article_bonus_claims --> education_articles
--                      |  '----------- transactions --> drop_stations, catalog_items
--                      |                    ^
--                      |                    '-- owned_vouchers --> catalog_items
--                      '-------------- pickup_logs (produser_id) --> drop_stations
--
--    app_settings and community_impact_baseline stand alone (tuning constants
--    and the historical impact curve).
--
--  ERROR CODES raised by the RPC functions (exception message = stable code,
--  the app maps each one to a localized string):
--    not_authenticated, forbidden, invalid_cans_count, invalid_quantity,
--    invalid_role, station_not_found, station_unavailable, station_full,
--    item_not_found, out_of_stock, shipping_address_required,
--    insufficient_points, quest_not_found, quest_not_completed,
--    article_not_found, already_claimed, user_not_found, cannot_demote_self,
--    profile_not_found
--
--  NAMING: English identifiers that mirror lib/models (deposit/redeem,
--  checkIn, price_points ...). The Indonesian labels of the brief map as
--  setor = deposit, tukar = redeem, misi = quest, checkin = checkin.
-- =============================================================================


-- =============================================================================
-- 1. TABLES
-- =============================================================================

-- ---- app_settings -----------------------------------------------------------
-- Server-side tuning constants. They replace the constants hard-coded in
-- Flutter (DropSessionSummary.pointsPerCan, MemberTier thresholds,
-- MockStore.checkInRewards ...) so rules change without an app release.
create table if not exists public.app_settings (
  key         text primary key,
  value       jsonb not null,
  description text,
  updated_at  timestamptz not null default now()
);
comment on table public.app_settings is
  'Key/value tuning constants (points per can, tier thresholds, check-in rewards ...). Readable by everyone, writable by admin.';

-- ---- profiles ---------------------------------------------------------------
-- One row per auth user. Flutter: ProfileData, UserProfile, LeaderboardEntry.
-- Email lives in auth.users and is never copied here. points, total_cans,
-- tier and role are protected: clients cannot update them (see section 6/7).
create table if not exists public.profiles (
  id              uuid primary key references auth.users (id) on delete cascade,
  username        text not null,
  full_name       text not null,
  phone           text,
  avatar_url      text,
  role            text not null default 'user',
  points          integer not null default 0,
  total_cans      integer not null default 0,
  tier            text not null default 'Bronze',
  gopay_connected boolean not null default false,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint profiles_role_check      check (role in ('user', 'admin', 'produser')),
  constraint profiles_points_check    check (points >= 0),
  constraint profiles_total_cans_check check (total_cans >= 0),
  constraint profiles_tier_check      check (tier in ('Bronze', 'Silver', 'Gold')),
  constraint profiles_username_format check (username ~ '^[A-Za-z0-9_.-]{3,30}$')
);
create unique index if not exists profiles_username_lower_key
  on public.profiles (lower(username));
create index if not exists profiles_leaderboard_idx
  on public.profiles (total_cans desc, points desc) where role = 'user';
comment on table public.profiles is
  'App users, produsers and admins. Tier is derived from points by a trigger.';
comment on column public.profiles.points is
  'Spendable balance (MockStore.points). Only changes through RPC functions.';
comment on column public.profiles.total_cans is
  'Lifetime cans deposited. Drives the leaderboard.';

-- ---- drop_stations ----------------------------------------------------------
-- Flutter: DropStation (Beranda list) and MapStation (map pins).
-- capacity_percentage is generated; status flips available <-> full by trigger.
create table if not exists public.drop_stations (
  id                  bigint generated by default as identity primary key,
  name                text not null,
  name_en             text not null,
  location            text not null,
  location_en         text not null,
  address             text,
  lat                 double precision not null,
  lng                 double precision not null,
  current_cans        integer not null default 0,
  max_capacity        integer not null default 200,
  capacity_percentage integer generated always as
                        (least(100, (current_cans * 100) / greatest(max_capacity, 1))) stored,
  status              text not null default 'available',
  opens_at            time,
  closes_at           time,
  open_24h            boolean not null default false,
  image_url           text,
  qr_code             text not null unique
                        default ('RECAN-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10))),
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  constraint drop_stations_lat_check      check (lat between -90 and 90),
  constraint drop_stations_lng_check      check (lng between -180 and 180),
  constraint drop_stations_cans_check     check (current_cans >= 0),
  constraint drop_stations_capacity_check check (max_capacity > 0),
  constraint drop_stations_status_check   check (status in ('available', 'full', 'maintenance', 'offline'))
);
create index if not exists drop_stations_status_idx on public.drop_stations (status);
comment on table public.drop_stations is
  'Public drop stations. location = short place label shown on cards, address = full street address, qr_code = value printed on the station QR.';
comment on column public.drop_stations.status is
  'available | full | maintenance | offline. available/full are maintained automatically from capacity; maintenance/offline are set by admin.';

-- ---- catalog_items ----------------------------------------------------------
-- One catalog for everything that costs points.
--   product : upcycled craft (Flutter UpcycleProduct), has stock
--   voucher : partner discount (Flutter Voucher), unlimited, ends in owned_vouchers
--   ewallet : e-wallet top-up (Flutter EWalletOption), unlimited, paid out manually
-- Mock ids collide across the three Flutter lists, so seed ids are products
-- 1-99, vouchers 101-199, e-wallets 201-299.
create table if not exists public.catalog_items (
  id               bigint generated by default as identity primary key,
  item_type        text not null,
  name             text not null,
  name_en          text not null,
  description      text not null default '',
  description_en   text not null default '',
  category         text,
  price_points     integer not null,
  price_idr        integer,
  stock            integer,
  image_url        text,
  icon_key         text,
  gradient_hex     text[],
  ewallet_provider text,
  ewallet_nominal  integer,
  is_active        boolean not null default true,
  sort_order       integer not null default 0,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  constraint catalog_items_type_check   check (item_type in ('product', 'voucher', 'ewallet')),
  constraint catalog_items_category_check check (category is null or category in ('toy', 'decor')),
  constraint catalog_items_price_check  check (price_points > 0),
  constraint catalog_items_stock_check  check (stock is null or stock >= 0),
  constraint catalog_items_product_check
    check (item_type <> 'product' or (category is not null and price_idr is not null and stock is not null)),
  constraint catalog_items_ewallet_check
    check (item_type <> 'ewallet' or (ewallet_provider is not null and ewallet_nominal is not null))
);
create index if not exists catalog_items_type_idx
  on public.catalog_items (item_type, is_active, sort_order);
comment on table public.catalog_items is
  'Redeemable items. stock NULL means unlimited (vouchers, e-wallet). category is toy|decor for products. icon_key and gradient_hex describe the voucher card style.';

-- ---- pickup_logs ------------------------------------------------------------
-- History of can collection by produsers. Written only by confirm_station_pickup().
create table if not exists public.pickup_logs (
  id             uuid primary key default gen_random_uuid(),
  station_id     bigint not null references public.drop_stations (id) on delete restrict,
  produser_id    uuid references public.profiles (id) on delete set null,
  cans_collected integer not null,
  picked_up_at   timestamptz not null default now(),
  notes          text,
  constraint pickup_logs_cans_check check (cans_collected >= 0)
);
create index if not exists pickup_logs_station_idx
  on public.pickup_logs (station_id, picked_up_at desc);
create index if not exists pickup_logs_produser_idx
  on public.pickup_logs (produser_id, picked_up_at desc);
comment on table public.pickup_logs is
  'Audit trail of station pickups. cans_collected is the station counter at confirmation time.';

-- ---- transactions -----------------------------------------------------------
-- Ledger of every points movement. Flutter: ActivityTransaction
--   transactionId -> reference, title -> title/title_en, points -> points_delta,
--   weightKg -> weight_kg, timestamp -> created_at.
-- The Aktivitas tab currently lists only deposit and redeem; quest, checkin
-- and bonus rows are new and can be filtered or shown by the client.
create table if not exists public.transactions (
  id           uuid primary key default gen_random_uuid(),
  reference    text not null unique,
  user_id      uuid not null references public.profiles (id) on delete cascade,
  station_id   bigint references public.drop_stations (id) on delete set null,
  item_id      bigint references public.catalog_items (id) on delete set null,
  type         text not null,
  points_delta integer not null,
  cans_delta   integer not null default 0,
  weight_kg    numeric(10, 3) not null default 0,
  title        text not null,
  title_en     text not null,
  metadata     jsonb not null default '{}'::jsonb,
  created_at   timestamptz not null default now(),
  constraint transactions_type_check check (type in ('deposit', 'redeem', 'quest', 'checkin', 'bonus')),
  constraint transactions_deposit_check check (type <> 'deposit' or (cans_delta > 0 and points_delta > 0)),
  constraint transactions_redeem_check  check (type <> 'redeem' or points_delta < 0)
);
create index if not exists transactions_user_idx on public.transactions (user_id, created_at desc);
create index if not exists transactions_station_idx on public.transactions (station_id) where station_id is not null;
create index if not exists transactions_deposit_day_idx on public.transactions (created_at) where type = 'deposit';
comment on table public.transactions is
  'Immutable points ledger. reference is the REC-XXXXX code shown to the user. metadata holds shipping address, quantity, e-wallet target, article id ...';

-- ---- owned_vouchers ---------------------------------------------------------
-- Flutter: OwnedVoucher (voucher, reference, redeemedAt).
create table if not exists public.owned_vouchers (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references public.profiles (id) on delete cascade,
  item_id        bigint not null references public.catalog_items (id) on delete restrict,
  transaction_id uuid not null unique references public.transactions (id) on delete cascade,
  reference      text not null unique,
  status         text not null default 'active',
  redeemed_at    timestamptz not null default now(),
  used_at        timestamptz,
  expires_at     timestamptz,
  constraint owned_vouchers_status_check check (status in ('active', 'used', 'expired'))
);
create index if not exists owned_vouchers_user_idx on public.owned_vouchers (user_id, redeemed_at desc);
comment on table public.owned_vouchers is
  'Vouchers a user has redeemed. reference equals the redeem transaction reference.';

-- ---- user_checkins ----------------------------------------------------------
-- Flutter: DailyCheckIn. One claim per user per day; day_index 0 = Monday.
create table if not exists public.user_checkins (
  user_id       uuid not null references public.profiles (id) on delete cascade,
  checkin_date  date not null,
  day_index     smallint not null,
  reward_points integer not null,
  created_at    timestamptz not null default now(),
  primary key (user_id, checkin_date),
  constraint user_checkins_day_check check (day_index between 0 and 6)
);
comment on table public.user_checkins is
  'Daily check-in claims (Asia/Jakarta calendar day). Reward comes from app_settings.checkin_rewards.';

-- ---- quest_definitions ------------------------------------------------------
-- Flutter: DailyQuest. metric uses the Flutter enum names (cans, checkIn, product, voucher).
create table if not exists public.quest_definitions (
  id            bigint generated by default as identity primary key,
  period        text not null,
  metric        text not null,
  title         text not null,
  title_en      text not null,
  unit          text not null default 'Kaleng',
  unit_en       text not null default 'Cans',
  target        integer not null,
  reward_points integer not null,
  is_active     boolean not null default true,
  sort_order    integer not null default 0,
  created_at    timestamptz not null default now(),
  constraint quest_definitions_period_check check (period in ('daily', 'weekly', 'monthly')),
  constraint quest_definitions_metric_check check (metric in ('cans', 'checkIn', 'product', 'voucher')),
  constraint quest_definitions_target_check check (target > 0),
  constraint quest_definitions_reward_check check (reward_points >= 0)
);
comment on table public.quest_definitions is
  'Mission templates. Progress is tracked per user and per period in user_quest_progress.';

-- ---- user_quest_progress ----------------------------------------------------
-- One row per user, quest and period window (day / ISO week / month start).
create table if not exists public.user_quest_progress (
  user_id      uuid not null references public.profiles (id) on delete cascade,
  quest_id     bigint not null references public.quest_definitions (id) on delete cascade,
  period_start date not null,
  progress     integer not null default 0,
  claimed_at   timestamptz,
  updated_at   timestamptz not null default now(),
  primary key (user_id, quest_id, period_start),
  constraint user_quest_progress_progress_check check (progress >= 0)
);
comment on table public.user_quest_progress is
  'Quest progress per period. A new period starts a new row, so daily/weekly/monthly quests reset on their own.';

-- ---- education_articles -----------------------------------------------------
-- Flutter: EducationArticle + ArticleStat. Paragraph arrays keep order.
-- stats is [{"value": "25", "label": "...", "label_en": "..."}].
-- source_name/source_url hold the citation for data-driven pieces (SIPSN ...).
create table if not exists public.education_articles (
  id             bigint generated by default as identity primary key,
  category       text not null,
  title          text not null,
  title_en       text not null,
  summary        text not null,
  summary_en     text not null,
  paragraphs     text[] not null default '{}',
  paragraphs_en  text[] not null default '{}',
  insight        text not null default '',
  insight_en     text not null default '',
  stats          jsonb not null default '[]'::jsonb,
  read_minutes   integer not null default 3,
  source_name    text,
  source_url     text,
  is_published   boolean not null default true,
  published_at   timestamptz not null default now(),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  constraint education_articles_category_check check (category in ('about', 'importance', 'impact')),
  constraint education_articles_read_check check (read_minutes > 0)
);
create index if not exists education_articles_list_idx
  on public.education_articles (is_published, published_at desc);
comment on table public.education_articles is
  'Education content. Written and published by admin; read by everyone.';

-- ---- article_bookmarks / article_bonus_claims -------------------------------
create table if not exists public.article_bookmarks (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  article_id bigint not null references public.education_articles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, article_id)
);
comment on table public.article_bookmarks is 'Saved articles (EducationService.toggleBookmark).';

create table if not exists public.article_bonus_claims (
  user_id    uuid not null references public.profiles (id) on delete cascade,
  article_id bigint not null references public.education_articles (id) on delete cascade,
  points     integer not null,
  claimed_at timestamptz not null default now(),
  primary key (user_id, article_id)
);
comment on table public.article_bonus_claims is
  'One helpful-article bonus per user and article (EducationService.claimHelpfulBonus).';

-- ---- community_impact_baseline ----------------------------------------------
-- Historical cans per day since 2025-01-01. The community_carbon_summary view
-- adds real deposits from transactions on top of this baseline.
create table if not exists public.community_impact_baseline (
  day  date primary key,
  cans integer not null,
  note text,
  constraint community_impact_baseline_cans_check check (cans >= 0)
);
comment on table public.community_impact_baseline is
  'Baseline cans per day (estimate before the app went live). Real deposits are added by community_carbon_summary.';


-- =============================================================================
-- 2. HELPER FUNCTIONS
-- All functions pin search_path and use fully qualified names.
-- =============================================================================

-- Business calendar day. Everything day-based (check-ins, quests, charts) uses
-- Jakarta time so a deposit at 23:30 WIB counts for that day, not for the UTC one.
create or replace function public.app_today()
returns date
language sql stable set search_path = ''
as $$ select (now() at time zone 'Asia/Jakarta')::date $$;

create or replace function public.app_setting(p_key text)
returns jsonb
language sql stable set search_path = ''
as $$ select s.value from public.app_settings s where s.key = p_key $$;

create or replace function public.setting_int(p_key text)
returns integer
language sql stable set search_path = ''
as $$ select (public.app_setting(p_key) #>> '{}')::integer $$;

create or replace function public.setting_num(p_key text)
returns numeric
language sql stable set search_path = ''
as $$ select (public.app_setting(p_key) #>> '{}')::numeric $$;

-- First day of the quest window a date belongs to (weeks start on Monday).
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

-- Mirrors MemberTier.of(points): Bronze < silver, Silver < gold, else Gold.
create or replace function public.tier_for_points(p_points integer)
returns text
language sql stable set search_path = ''
as $$
  select case
    when p_points < (public.app_setting('tier_thresholds') ->> 'silver')::integer then 'Bronze'
    when p_points < (public.app_setting('tier_thresholds') ->> 'gold')::integer   then 'Silver'
    else 'Gold'
  end
$$;

-- Great-circle distance in metres, used for the "nearest station" list.
create or replace function public.haversine_m(
  p_lat1 double precision, p_lng1 double precision,
  p_lat2 double precision, p_lng2 double precision
)
returns double precision
language sql immutable set search_path = ''
as $$
  select 2 * 6371000 * asin(sqrt(
    power(sin(radians(p_lat2 - p_lat1) / 2), 2)
    + cos(radians(p_lat1)) * cos(radians(p_lat2)) * power(sin(radians(p_lng2 - p_lng1) / 2), 2)
  ))
$$;

-- Transaction code shown to the user, same alphabet as MockStore.newTransactionId.
create or replace function public.new_reference()
returns text
language plpgsql volatile set search_path = ''
as $$
declare
  alphabet constant text := '0123456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  v_ref text;
begin
  loop
    v_ref := 'REC-';
    for i in 1..5 loop
      v_ref := v_ref || substr(alphabet, 1 + floor(random() * length(alphabet))::integer, 1);
    end loop;
    exit when not exists (select 1 from public.transactions t where t.reference = v_ref);
  end loop;
  return v_ref;
end;
$$;

-- Role lookups. SECURITY DEFINER so policies on profiles can call them without
-- recursing into profiles' own RLS.
create or replace function public.user_role()
returns text
language sql stable security definer set search_path = ''
as $$ select p.role from public.profiles p where p.id = auth.uid() $$;

create or replace function public.is_admin()
returns boolean
language sql stable security definer set search_path = ''
as $$ select coalesce(public.user_role() = 'admin', false) $$;

-- admin or produser
create or replace function public.is_staff()
returns boolean
language sql stable security definer set search_path = ''
as $$ select coalesce(public.user_role() in ('admin', 'produser'), false) $$;

-- Consecutive check-in days ending today or yesterday (RLS limits it to the caller's own rows).
create or replace function public.checkin_streak(p_user uuid)
returns integer
language sql stable set search_path = ''
as $$
  select coalesce((
    select count(*)::integer
    from (
      select x.d, x.d - (row_number() over (order by x.d))::integer as grp
      from (select c.checkin_date as d from public.user_checkins c where c.user_id = p_user) x
    ) y
    group by y.grp
    having max(y.d) >= public.app_today() - 1
    order by max(y.d) desc
    limit 1
  ), 0)
$$;

-- Adds progress to every active quest of a metric for the current period.
-- Claimed quests are left untouched, like MockStore._advanceQuests.
create or replace function public.advance_quests(p_user uuid, p_metric text, p_amount integer)
returns void
language sql security definer set search_path = ''
as $$
  insert into public.user_quest_progress as up (user_id, quest_id, period_start, progress)
  select p_user, q.id, public.period_start_for(q.period), p_amount
  from public.quest_definitions q
  where q.metric = p_metric and q.is_active
  on conflict (user_id, quest_id, period_start) do update
    set progress = up.progress + excluded.progress,
        updated_at = now()
    where up.claimed_at is null
$$;


-- =============================================================================
-- 3. TRIGGERS
-- =============================================================================

create or replace function public.set_updated_at()
returns trigger
language plpgsql set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists app_settings_updated_at on public.app_settings;
create trigger app_settings_updated_at before update on public.app_settings
  for each row execute function public.set_updated_at();

drop trigger if exists drop_stations_updated_at on public.drop_stations;
create trigger drop_stations_updated_at before update on public.drop_stations
  for each row execute function public.set_updated_at();

drop trigger if exists catalog_items_updated_at on public.catalog_items;
create trigger catalog_items_updated_at before update on public.catalog_items
  for each row execute function public.set_updated_at();

drop trigger if exists education_articles_updated_at on public.education_articles;
create trigger education_articles_updated_at before update on public.education_articles
  for each row execute function public.set_updated_at();

-- ---- profiles: guard, tier, updated_at --------------------------------------
-- Second line of defence behind the column-level grants in section 6: a direct
-- client update of a protected column fails with a readable error. SECURITY
-- DEFINER RPCs run as the function owner, so they pass.
create or replace function public.guard_profile_update()
returns trigger
language plpgsql set search_path = ''
as $$
begin
  if current_user in ('anon', 'authenticated') and (
       new.id         is distinct from old.id
    or new.role       is distinct from old.role
    or new.points     is distinct from old.points
    or new.total_cans is distinct from old.total_cans
    or new.tier       is distinct from old.tier
  ) then
    raise exception 'forbidden' using errcode = '42501',
      detail = 'role, points, total_cans and tier can only change through RPC functions';
  end if;
  return new;
end;
$$;

create or replace function public.sync_profile_tier()
returns trigger
language plpgsql set search_path = ''
as $$
begin
  new.tier := public.tier_for_points(new.points);
  return new;
end;
$$;

-- Trigger order is alphabetical: guard first, then tier, then updated_at.
drop trigger if exists profiles_a_guard on public.profiles;
create trigger profiles_a_guard before update on public.profiles
  for each row execute function public.guard_profile_update();

drop trigger if exists profiles_b_tier on public.profiles;
create trigger profiles_b_tier before insert or update of points on public.profiles
  for each row execute function public.sync_profile_tier();

drop trigger if exists profiles_c_updated_at on public.profiles;
create trigger profiles_c_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();

-- ---- drop_stations: keep status in step with capacity -----------------------
-- Mirrors DropStation.isFull (full from 90 %). maintenance and offline are
-- manual states and are never overwritten.
create or replace function public.sync_station_status()
returns trigger
language plpgsql set search_path = ''
as $$
begin
  if new.status in ('available', 'full') then
    new.status := case
      when (new.current_cans * 100) / greatest(new.max_capacity, 1)
           >= public.setting_int('station_full_threshold_percent') then 'full'
      else 'available'
    end;
  end if;
  return new;
end;
$$;

drop trigger if exists drop_stations_status on public.drop_stations;
create trigger drop_stations_status before insert or update on public.drop_stations
  for each row execute function public.sync_station_status();

-- ---- auth.users -> profiles --------------------------------------------------
-- Runs when a user signs up through Supabase Auth. Reads username, full_name,
-- phone (and avatar_url from OAuth providers) from raw_user_meta_data. The role
-- is NEVER read from metadata: that field is writable by the user.
create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  v_meta      jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  v_base      text;
  v_username  text;
  v_full_name text;
  v_attempt   integer := 0;
begin
  v_base := coalesce(
    nullif(btrim(v_meta ->> 'username'), ''),
    nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
    'user'
  );
  v_base := regexp_replace(v_base, '[^A-Za-z0-9_.-]', '', 'g');
  if length(v_base) < 3 then
    v_base := 'user' || substr(replace(new.id::text, '-', ''), 1, 6);
  end if;
  v_base := left(v_base, 24);

  v_username := v_base;
  while exists (select 1 from public.profiles p where lower(p.username) = lower(v_username)) loop
    v_attempt := v_attempt + 1;
    v_username := v_base || '_' || substr(md5(random()::text || v_attempt::text), 1, 5);
    exit when v_attempt >= 10;
  end loop;

  v_full_name := coalesce(
    nullif(btrim(v_meta ->> 'full_name'), ''),
    nullif(btrim(v_meta ->> 'username'), ''),
    v_username
  );

  insert into public.profiles (id, username, full_name, phone, avatar_url)
  values (
    new.id,
    v_username,
    v_full_name,
    nullif(btrim(v_meta ->> 'phone'), ''),
    nullif(btrim(v_meta ->> 'avatar_url'), '')
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill for users that signed up before this trigger existed (no-op on a fresh project).
insert into public.profiles (id, username, full_name)
select u.id,
       'user_' || substr(replace(u.id::text, '-', ''), 1, 10),
       coalesce(nullif(btrim(u.raw_user_meta_data ->> 'full_name'), ''),
                nullif(split_part(coalesce(u.email, ''), '@', 1), ''),
                'ReCan User')
from auth.users u
where not exists (select 1 from public.profiles p where p.id = u.id);


-- =============================================================================
-- 4. RPC FUNCTIONS (server-side integrity)
-- Points, stock, counters and ledger rows change ONLY here. All are SECURITY
-- DEFINER with a pinned search_path; each checks auth.uid() itself. Rows are
-- locked in a fixed order (station/item first, then profile) to avoid deadlocks.
-- =============================================================================

-- ---- record_can_deposit -----------------------------------------------------
-- A user drops cans at a station (Flutter TransactionService.submitDrop).
-- Points = cans * points_per_can. p_is_collective covers the "+1000 community
-- collective / event" preset: it may exceed the bin size, the bin counter is
-- clamped at max_capacity and the cans still count for the user.
-- Anti-abuse note: a client can call this directly. Verifying a signed station
-- QR / hardware confirmation belongs to a later stage; until then the per-call
-- cap in app_settings.max_cans_per_deposit is the guard rail.
drop function if exists public.record_can_deposit(bigint, integer, boolean, jsonb);
create function public.record_can_deposit(
  p_station_id    bigint,
  p_cans_count    integer,
  p_is_collective boolean default false,
  p_metadata      jsonb default '{}'::jsonb
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
  v_uid        uuid := auth.uid();
  v_collective boolean := coalesce(p_is_collective, false);
  v_station    public.drop_stations%rowtype;
  v_profile    public.profiles%rowtype;
  v_points     integer;
  v_weight     numeric;
  v_ref        text;
  v_tx         uuid;
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
  if v_station.status in ('maintenance', 'offline') then
    raise exception 'station_unavailable' using errcode = 'P0001';
  end if;
  if not v_collective and v_station.current_cans + p_cans_count > v_station.max_capacity then
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
     set current_cans = least(s.max_capacity, s.current_cans + p_cans_count)
   where s.id = p_station_id;

  insert into public.transactions
    (reference, user_id, station_id, type, points_delta, cans_delta, weight_kg, title, title_en, metadata)
  values
    (v_ref, v_uid, p_station_id, 'deposit', v_points, p_cans_count, v_weight,
     'Setor ' || p_cans_count || ' Kaleng',
     'Dropped ' || p_cans_count || ' Cans',
     coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object('collective', v_collective))
  returning id into v_tx;

  perform public.advance_quests(v_uid, 'cans', p_cans_count);

  return query select
    v_tx, v_ref, v_points, v_weight,
    round(p_cans_count * public.setting_num('carbon_kg_per_can'), 2),
    v_profile.points, v_profile.total_cans, v_profile.tier;
end;
$$;

-- ---- redeem_reward ----------------------------------------------------------
-- Spends points on a catalog item (Flutter TransactionService.redeem,
-- redeemVoucher, redeemEWallet). Validates the balance on the server.
--   product : needs a shipping address, decrements stock
--   voucher : adds a row to owned_vouchers
--   ewallet : recorded in the ledger, paid out manually by admin
drop function if exists public.redeem_reward(bigint, integer, text, text);
create function public.redeem_reward(
  p_item_id          bigint,
  p_quantity         integer default 1,
  p_shipping_address text default null,
  p_notes            text default null
)
returns table (
  transaction_id uuid,
  reference      text,
  points_spent   integer,
  new_points     integer,
  tier           text
)
language plpgsql security definer set search_path = ''
as $$
#variable_conflict use_column
declare
  v_uid      uuid := auth.uid();
  v_qty      integer := coalesce(p_quantity, 1);
  v_item     public.catalog_items%rowtype;
  v_profile  public.profiles%rowtype;
  v_cost     integer;
  v_ref      text;
  v_tx       uuid;
  v_suffix   text;
  v_address  text := nullif(btrim(coalesce(p_shipping_address, '')), '');
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if v_qty < 1 or v_qty > 100 then
    raise exception 'invalid_quantity' using errcode = '22023';
  end if;

  select * into v_item from public.catalog_items i where i.id = p_item_id for update;
  if not found or not v_item.is_active then
    raise exception 'item_not_found' using errcode = 'P0002';
  end if;
  if v_item.item_type <> 'product' and v_qty <> 1 then
    raise exception 'invalid_quantity' using errcode = '22023';
  end if;
  if v_item.item_type = 'product' then
    if v_address is null then
      raise exception 'shipping_address_required' using errcode = '22023';
    end if;
    if v_item.stock < v_qty then
      raise exception 'out_of_stock' using errcode = 'P0001';
    end if;
  end if;

  v_cost := v_item.price_points * v_qty;

  select * into v_profile from public.profiles p where p.id = v_uid for update;
  if not found then
    raise exception 'profile_not_found' using errcode = 'P0002';
  end if;
  if v_profile.points < v_cost then
    raise exception 'insufficient_points' using errcode = 'P0001';
  end if;

  update public.profiles p set points = p.points - v_cost where p.id = v_uid
  returning * into v_profile;

  if v_item.item_type = 'product' then
    update public.catalog_items i set stock = i.stock - v_qty where i.id = v_item.id;
  end if;

  v_ref := public.new_reference();
  v_suffix := case when v_qty > 1 then ' x' || v_qty else '' end;

  insert into public.transactions
    (reference, user_id, item_id, type, points_delta, title, title_en, metadata)
  values
    (v_ref, v_uid, v_item.id, 'redeem', -v_cost,
     'Tukar ' || v_item.name || v_suffix,
     'Redeemed ' || v_item.name_en || v_suffix,
     jsonb_strip_nulls(jsonb_build_object(
       'item_type', v_item.item_type,
       'quantity', v_qty,
       'shipping_address', v_address,
       'notes', nullif(btrim(coalesce(p_notes, '')), ''),
       'ewallet_provider', v_item.ewallet_provider,
       'ewallet_nominal', v_item.ewallet_nominal
     )))
  returning id into v_tx;

  if v_item.item_type = 'voucher' then
    insert into public.owned_vouchers (user_id, item_id, transaction_id, reference)
    values (v_uid, v_item.id, v_tx, v_ref);
    perform public.advance_quests(v_uid, 'voucher', 1);
  elsif v_item.item_type = 'product' then
    perform public.advance_quests(v_uid, 'product', 1);
  end if;

  return query select v_tx, v_ref, v_cost, v_profile.points, v_profile.tier;
end;
$$;

-- ---- confirm_station_pickup -------------------------------------------------
-- Produser (or admin) empties a station: logs the pickup and resets the counter.
drop function if exists public.confirm_station_pickup(bigint, text);
create function public.confirm_station_pickup(
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

  insert into public.pickup_logs (station_id, produser_id, cans_collected, notes)
  values (p_station_id, v_uid, v_station.current_cans, nullif(btrim(coalesce(p_notes, '')), ''))
  returning id, picked_up_at into v_id, v_at;

  update public.drop_stations s set current_cans = 0 where s.id = p_station_id;

  return query select v_id, v_station.current_cans, v_at;
end;
$$;

-- ---- claim_daily_checkin ----------------------------------------------------
-- One reward per day; the amount depends on the weekday (Monday = index 0).
drop function if exists public.claim_daily_checkin();
create function public.claim_daily_checkin()
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
  v_idx     integer := extract(isodow from public.app_today())::integer - 1;
  v_reward  integer;
  v_profile public.profiles%rowtype;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  v_reward := (public.app_setting('checkin_rewards') ->> v_idx)::integer;

  insert into public.user_checkins (user_id, checkin_date, day_index, reward_points)
  values (v_uid, v_today, v_idx, v_reward)
  on conflict (user_id, checkin_date) do nothing;
  if not found then
    raise exception 'already_claimed' using errcode = 'P0001';
  end if;

  update public.profiles p set points = p.points + v_reward where p.id = v_uid
  returning * into v_profile;
  if not found then
    raise exception 'profile_not_found' using errcode = 'P0002';
  end if;

  insert into public.transactions
    (reference, user_id, type, points_delta, title, title_en, metadata)
  values
    (public.new_reference(), v_uid, 'checkin', v_reward,
     'Hadiah Harian', 'Daily Reward', jsonb_build_object('day_index', v_idx));

  perform public.advance_quests(v_uid, 'checkIn', 1);

  return query select v_idx, v_reward, v_profile.points, public.checkin_streak(v_uid);
end;
$$;

-- ---- claim_quest ------------------------------------------------------------
-- Pays the reward of a completed quest for its current period, once.
drop function if exists public.claim_quest(bigint);
create function public.claim_quest(p_quest_id bigint)
returns table (
  points_earned integer,
  new_points    integer,
  tier          text
)
language plpgsql security definer set search_path = ''
as $$
#variable_conflict use_column
declare
  v_uid      uuid := auth.uid();
  v_quest    public.quest_definitions%rowtype;
  v_progress public.user_quest_progress%rowtype;
  v_start    date;
  v_profile  public.profiles%rowtype;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  select * into v_quest from public.quest_definitions q where q.id = p_quest_id and q.is_active;
  if not found then
    raise exception 'quest_not_found' using errcode = 'P0002';
  end if;

  v_start := public.period_start_for(v_quest.period);
  select * into v_progress from public.user_quest_progress up
   where up.user_id = v_uid and up.quest_id = p_quest_id and up.period_start = v_start
   for update;
  if not found or v_progress.progress < v_quest.target then
    raise exception 'quest_not_completed' using errcode = 'P0001';
  end if;
  if v_progress.claimed_at is not null then
    raise exception 'already_claimed' using errcode = 'P0001';
  end if;

  update public.user_quest_progress up
     set claimed_at = now(), updated_at = now()
   where up.user_id = v_uid and up.quest_id = p_quest_id and up.period_start = v_start;

  update public.profiles p set points = p.points + v_quest.reward_points where p.id = v_uid
  returning * into v_profile;
  if not found then
    raise exception 'profile_not_found' using errcode = 'P0002';
  end if;

  insert into public.transactions
    (reference, user_id, type, points_delta, title, title_en, metadata)
  values
    (public.new_reference(), v_uid, 'quest', v_quest.reward_points,
     'Hadiah Misi: ' || v_quest.title, 'Quest Reward: ' || v_quest.title_en,
     jsonb_build_object('quest_id', v_quest.id, 'period_start', v_start));

  return query select v_quest.reward_points, v_profile.points, v_profile.tier;
end;
$$;

-- ---- claim_article_bonus ----------------------------------------------------
-- "Was this helpful?" bonus, once per user and article.
drop function if exists public.claim_article_bonus(bigint);
create function public.claim_article_bonus(p_article_id bigint)
returns table (
  points_earned integer,
  new_points    integer,
  tier          text
)
language plpgsql security definer set search_path = ''
as $$
#variable_conflict use_column
declare
  v_uid     uuid := auth.uid();
  v_bonus   integer := public.setting_int('helpful_bonus_points');
  v_profile public.profiles%rowtype;
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if not exists (
    select 1 from public.education_articles a where a.id = p_article_id and a.is_published
  ) then
    raise exception 'article_not_found' using errcode = 'P0002';
  end if;

  insert into public.article_bonus_claims (user_id, article_id, points)
  values (v_uid, p_article_id, v_bonus)
  on conflict (user_id, article_id) do nothing;
  if not found then
    raise exception 'already_claimed' using errcode = 'P0001';
  end if;

  update public.profiles p set points = p.points + v_bonus where p.id = v_uid
  returning * into v_profile;
  if not found then
    raise exception 'profile_not_found' using errcode = 'P0002';
  end if;

  insert into public.transactions
    (reference, user_id, type, points_delta, title, title_en, metadata)
  values
    (public.new_reference(), v_uid, 'bonus', v_bonus,
     'Bonus Artikel Bermanfaat', 'Helpful Article Bonus',
     jsonb_build_object('article_id', p_article_id));

  return query select v_bonus, v_profile.points, v_profile.tier;
end;
$$;

-- ---- admin_set_user_role ----------------------------------------------------
-- The only way to change a role from a client (admin portal).
drop function if exists public.admin_set_user_role(uuid, text);
create function public.admin_set_user_role(p_user_id uuid, p_role text)
returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not public.is_admin() then
    raise exception 'forbidden' using errcode = '42501';
  end if;
  if p_role is null or p_role not in ('user', 'admin', 'produser') then
    raise exception 'invalid_role' using errcode = '22023';
  end if;
  if p_user_id = auth.uid() and p_role <> 'admin' then
    raise exception 'cannot_demote_self' using errcode = 'P0001';
  end if;

  update public.profiles p set role = p_role where p.id = p_user_id;
  if not found then
    raise exception 'user_not_found' using errcode = 'P0002';
  end if;
end;
$$;

-- ---- stations_with_distance -------------------------------------------------
-- Station list for Beranda and the map, nearest first. distance_m matches
-- DropStation.fromJson ('distance_m'). SECURITY INVOKER: it only reads
-- drop_stations, which everyone may read.
drop function if exists public.stations_with_distance(double precision, double precision);
create function public.stations_with_distance(p_lat double precision, p_lng double precision)
returns table (
  id                  bigint,
  name                text,
  name_en             text,
  location            text,
  location_en         text,
  address             text,
  lat                 double precision,
  lng                 double precision,
  current_cans        integer,
  max_capacity        integer,
  capacity_percentage integer,
  status              text,
  opens_at            time,
  closes_at           time,
  open_24h            boolean,
  image_url           text,
  distance_m          integer
)
language sql stable set search_path = ''
as $$
  select s.id, s.name, s.name_en, s.location, s.location_en, s.address,
         s.lat, s.lng, s.current_cans, s.max_capacity, s.capacity_percentage,
         s.status, s.opens_at, s.closes_at, s.open_24h, s.image_url,
         round(public.haversine_m(p_lat, p_lng, s.lat, s.lng))::integer
  from public.drop_stations s
  order by public.haversine_m(p_lat, p_lng, s.lat, s.lng)
$$;


-- =============================================================================
-- 5. VIEWS
-- =============================================================================

-- ---- community_carbon_summary -----------------------------------------------
-- Baseline (historical estimate) + live deposits, in the three shapes of
-- Flutter CarbonRange. One row per chart bar.
--   week         : the last 7 days, one bar per day (bucket_index 1 = oldest)
--   month        : the current month in 4 week buckets (days 1-7, 8-14, 15-21, 22+)
--   sinceJan2025 : one bar per month since 2025-01
-- carbon_kg = cans * app_settings.carbon_kg_per_can; goal_cans comes from
-- app_settings.carbon_goal_cans. Aggregates only, so anon may read it.
drop view if exists public.community_carbon_summary;
create view public.community_carbon_summary as
with cfg as (
  select public.app_today() as today,
         public.setting_num('carbon_kg_per_can') as kg_per_can
),
real_daily as (
  select (t.created_at at time zone 'Asia/Jakarta')::date as day,
         sum(t.cans_delta)::integer as cans
  from public.transactions t
  where t.type = 'deposit'
  group by 1
),
daily as (
  select g.day::date as day,
         coalesce(b.cans, 0) as baseline_cans,
         coalesce(r.cans, 0) as real_cans
  from cfg
  cross join lateral generate_series(date '2025-01-01', cfg.today, interval '1 day') as g(day)
  left join public.community_impact_baseline b on b.day = g.day::date
  left join real_daily r on r.day = g.day::date
),
buckets as (
  select 'week'::text as range_key,
         (row_number() over (order by d.day))::integer as bucket_index,
         d.day as bucket_start,
         d.baseline_cans,
         d.real_cans
  from daily d, cfg
  where d.day > cfg.today - 7

  union all

  select 'month'::text,
         least(4, (extract(day from d.day)::integer - 1) / 7 + 1),
         min(d.day),
         sum(d.baseline_cans)::integer,
         sum(d.real_cans)::integer
  from daily d, cfg
  where date_trunc('month', d.day::timestamp) = date_trunc('month', cfg.today::timestamp)
  group by 2

  union all

  select 'sinceJan2025'::text,
         (row_number() over (order by m.month_start))::integer,
         m.month_start,
         m.baseline_cans,
         m.real_cans
  from (
    select date_trunc('month', d.day::timestamp)::date as month_start,
           sum(d.baseline_cans)::integer as baseline_cans,
           sum(d.real_cans)::integer as real_cans
    from daily d
    group by 1
  ) m
)
select b.range_key,
       b.bucket_index,
       b.bucket_start,
       b.baseline_cans,
       b.real_cans,
       b.baseline_cans + b.real_cans as cans,
       round((b.baseline_cans + b.real_cans) * cfg.kg_per_can, 2) as carbon_kg,
       (public.app_setting('carbon_goal_cans') ->> b.range_key)::integer as goal_cans
from buckets b
cross join cfg
order by b.range_key, b.bucket_index;
comment on view public.community_carbon_summary is
  'Chart data for the community carbon impact card: baseline since 2025 plus real deposits.';

-- ---- public_leaderboard -----------------------------------------------------
-- Top contributors without email, phone or user id. Runs with the view owner's
-- rights (so it can see every profile) and exposes only the columns below.
-- Ranked by lifetime cans, then points. Regular users only; a user with no
-- deposits yet shows up only for themselves (is_current_user).
-- The client applies .limit(n); ask for the caller's own row separately when
-- they rank outside the top n.
drop view if exists public.public_leaderboard;
create view public.public_leaderboard with (security_barrier = true) as
select (row_number() over (order by p.total_cans desc, p.points desc, p.created_at))::integer as rank,
       p.username,
       p.full_name,
       p.avatar_url,
       p.points,
       p.total_cans,
       p.tier,
       round(p.total_cans * public.setting_num('grams_per_can') / 1000.0, 1) as total_kg,
       (p.id = auth.uid()) as is_current_user
from public.profiles p
where p.role = 'user'
  and (p.total_cans > 0 or p.id = auth.uid())
order by 1;
comment on view public.public_leaderboard is
  'Community leaderboard. No email, phone or id is exposed.';

-- ---- my_quest_status --------------------------------------------------------
-- The caller's quests for the current period; columns line up with
-- DailyQuest.fromJson (id, title, unit, period, metric, progress, target,
-- reward_points, is_claimed). SECURITY INVOKER keeps RLS in force.
drop view if exists public.my_quest_status;
create view public.my_quest_status with (security_invoker = true) as
select q.id,
       q.title,
       q.title_en,
       q.unit,
       q.unit_en,
       q.period,
       q.metric,
       q.target,
       q.reward_points,
       coalesce(up.progress, 0) as progress,
       (up.claimed_at is not null) as is_claimed
from public.quest_definitions q
left join public.user_quest_progress up
  on up.quest_id = q.id
 and up.user_id = auth.uid()
 and up.period_start = public.period_start_for(q.period)
where q.is_active
order by q.sort_order, q.id;
comment on view public.my_quest_status is 'Quest list with the caller''s progress for the current day/week/month.';

-- ---- my_checkin_week --------------------------------------------------------
-- Check-ins of the caller this week; day_index values feed DailyCheckIn.claimedDays.
drop view if exists public.my_checkin_week;
create view public.my_checkin_week with (security_invoker = true) as
select c.day_index, c.checkin_date, c.reward_points
from public.user_checkins c
where c.user_id = auth.uid()
  and c.checkin_date >= date_trunc('week', public.app_today()::timestamp)::date;
comment on view public.my_checkin_week is 'Check-in days claimed this week by the caller.';


-- =============================================================================
-- 6. GRANTS
-- Defence in depth: RLS (section 7) decides which rows, grants decide which
-- columns and verbs. Everything is revoked first, then granted back.
-- =============================================================================

do $$
declare
  t text;
begin
  foreach t in array array[
    'app_settings', 'profiles', 'drop_stations', 'catalog_items', 'pickup_logs',
    'transactions', 'owned_vouchers', 'user_checkins', 'quest_definitions',
    'user_quest_progress', 'education_articles', 'article_bookmarks',
    'article_bonus_claims', 'community_impact_baseline'
  ] loop
    execute format('revoke all on public.%I from anon, authenticated', t);
  end loop;
end $$;

-- Views get the same default grants as tables, so strip them before granting.
revoke all on public.community_carbon_summary, public.public_leaderboard,
  public.my_quest_status, public.my_checkin_week from anon, authenticated;

-- Public reference data (map, catalog, education, tuning constants).
grant select on public.app_settings, public.drop_stations, public.catalog_items,
  public.education_articles to anon, authenticated;

-- Signed-in users read their own rows and the shared reference tables.
grant select on public.profiles, public.pickup_logs, public.transactions,
  public.owned_vouchers, public.user_checkins, public.quest_definitions,
  public.user_quest_progress, public.article_bookmarks,
  public.article_bonus_claims, public.community_impact_baseline to authenticated;

-- Profile self-service: only these columns. points, total_cans, tier and role
-- are deliberately absent.
grant update (username, full_name, phone, avatar_url, gopay_connected)
  on public.profiles to authenticated;

-- Bookmarks are plain user data.
grant insert, delete on public.article_bookmarks to authenticated;

-- Admin portal writes (RLS restricts them to role 'admin').
grant insert, update, delete on public.app_settings, public.drop_stations,
  public.catalog_items, public.education_articles, public.quest_definitions,
  public.community_impact_baseline to authenticated;
grant update on public.owned_vouchers to authenticated;

-- Views.
grant select on public.community_carbon_summary to anon, authenticated;
grant select on public.public_leaderboard, public.my_quest_status,
  public.my_checkin_week to authenticated;

-- Functions: helpers are callable by policies and views; RPCs only by signed-in users;
-- internals only by the database itself.
do $$
declare
  f text;
begin
  foreach f in array array[
    'public.app_today()', 'public.app_setting(text)', 'public.setting_int(text)',
    'public.setting_num(text)', 'public.period_start_for(text, date)',
    'public.tier_for_points(integer)', 'public.haversine_m(double precision, double precision, double precision, double precision)',
    'public.user_role()', 'public.is_admin()', 'public.is_staff()'
  ] loop
    execute format('revoke all on function %s from public', f);
    execute format('grant execute on function %s to anon, authenticated', f);
  end loop;

  foreach f in array array[
    'public.record_can_deposit(bigint, integer, boolean, jsonb)',
    'public.redeem_reward(bigint, integer, text, text)',
    'public.confirm_station_pickup(bigint, text)',
    'public.claim_daily_checkin()',
    'public.claim_quest(bigint)',
    'public.claim_article_bonus(bigint)',
    'public.admin_set_user_role(uuid, text)',
    'public.stations_with_distance(double precision, double precision)',
    'public.checkin_streak(uuid)'
  ] loop
    execute format('revoke all on function %s from public, anon', f);
    execute format('grant execute on function %s to authenticated', f);
  end loop;

  foreach f in array array[
    'public.advance_quests(uuid, text, integer)', 'public.new_reference()',
    'public.handle_new_user()', 'public.set_updated_at()',
    'public.guard_profile_update()', 'public.sync_profile_tier()',
    'public.sync_station_status()'
  ] loop
    execute format('revoke all on function %s from public, anon, authenticated', f);
  end loop;
end $$;


-- =============================================================================
-- 7. ROW LEVEL SECURITY
-- RLS is on for every table. Roles:
--   user     own profile, own ledger/vouchers/check-ins/progress; public reference data
--   produser everything a user has + read all pickup_logs; empties stations through
--            confirm_station_pickup()
--   admin    CRUD on drop_stations, catalog_items, education_articles (plus
--            quest_definitions, app_settings, baseline); reads all profiles,
--            transactions, pickup_logs; changes roles through admin_set_user_role()
-- Nobody writes points, ledger rows, stock or station counters directly.
-- =============================================================================

alter table public.app_settings             enable row level security;
alter table public.profiles                 enable row level security;
alter table public.drop_stations            enable row level security;
alter table public.catalog_items            enable row level security;
alter table public.pickup_logs              enable row level security;
alter table public.transactions             enable row level security;
alter table public.owned_vouchers           enable row level security;
alter table public.user_checkins            enable row level security;
alter table public.quest_definitions        enable row level security;
alter table public.user_quest_progress      enable row level security;
alter table public.education_articles       enable row level security;
alter table public.article_bookmarks        enable row level security;
alter table public.article_bonus_claims     enable row level security;
alter table public.community_impact_baseline enable row level security;

-- ---- app_settings -----------------------------------------------------------
drop policy if exists app_settings_read on public.app_settings;
create policy app_settings_read on public.app_settings
  for select to anon, authenticated using (true);
drop policy if exists app_settings_admin_write on public.app_settings;
create policy app_settings_admin_write on public.app_settings
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- ---- profiles ---------------------------------------------------------------
-- Own row, or any row for admin. Updates are limited to the granted columns.
drop policy if exists profiles_select on public.profiles;
create policy profiles_select on public.profiles
  for select to authenticated
  using (id = (select auth.uid()) or public.is_admin());
drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- ---- drop_stations ----------------------------------------------------------
drop policy if exists drop_stations_read on public.drop_stations;
create policy drop_stations_read on public.drop_stations
  for select to anon, authenticated using (true);
drop policy if exists drop_stations_admin_write on public.drop_stations;
create policy drop_stations_admin_write on public.drop_stations
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- ---- pickup_logs ------------------------------------------------------------
drop policy if exists pickup_logs_staff_read on public.pickup_logs;
create policy pickup_logs_staff_read on public.pickup_logs
  for select to authenticated using (public.is_staff());

-- ---- catalog_items ----------------------------------------------------------
drop policy if exists catalog_items_read on public.catalog_items;
create policy catalog_items_read on public.catalog_items
  for select to anon, authenticated using (is_active or public.is_admin());
drop policy if exists catalog_items_admin_write on public.catalog_items;
create policy catalog_items_admin_write on public.catalog_items
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- ---- transactions -----------------------------------------------------------
drop policy if exists transactions_select on public.transactions;
create policy transactions_select on public.transactions
  for select to authenticated
  using (user_id = (select auth.uid()) or public.is_admin());

-- ---- owned_vouchers ---------------------------------------------------------
drop policy if exists owned_vouchers_select on public.owned_vouchers;
create policy owned_vouchers_select on public.owned_vouchers
  for select to authenticated
  using (user_id = (select auth.uid()) or public.is_admin());
drop policy if exists owned_vouchers_admin_update on public.owned_vouchers;
create policy owned_vouchers_admin_update on public.owned_vouchers
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

-- ---- user_checkins ----------------------------------------------------------
drop policy if exists user_checkins_select on public.user_checkins;
create policy user_checkins_select on public.user_checkins
  for select to authenticated
  using (user_id = (select auth.uid()) or public.is_admin());

-- ---- quest_definitions / user_quest_progress --------------------------------
drop policy if exists quest_definitions_read on public.quest_definitions;
create policy quest_definitions_read on public.quest_definitions
  for select to authenticated using (is_active or public.is_admin());
drop policy if exists quest_definitions_admin_write on public.quest_definitions;
create policy quest_definitions_admin_write on public.quest_definitions
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists user_quest_progress_select on public.user_quest_progress;
create policy user_quest_progress_select on public.user_quest_progress
  for select to authenticated using (user_id = (select auth.uid()));

-- ---- education_articles -----------------------------------------------------
drop policy if exists education_articles_read on public.education_articles;
create policy education_articles_read on public.education_articles
  for select to anon, authenticated using (is_published or public.is_admin());
drop policy if exists education_articles_admin_write on public.education_articles;
create policy education_articles_admin_write on public.education_articles
  for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- ---- article_bookmarks / article_bonus_claims -------------------------------
drop policy if exists article_bookmarks_own on public.article_bookmarks;
create policy article_bookmarks_own on public.article_bookmarks
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists article_bonus_claims_select on public.article_bonus_claims;
create policy article_bonus_claims_select on public.article_bonus_claims
  for select to authenticated using (user_id = (select auth.uid()));

-- ---- community_impact_baseline ----------------------------------------------
drop policy if exists community_impact_baseline_read on public.community_impact_baseline;
create policy community_impact_baseline_read on public.community_impact_baseline
  for select to authenticated using (true);
drop policy if exists community_impact_baseline_admin_write on public.community_impact_baseline;
create policy community_impact_baseline_admin_write on public.community_impact_baseline
  for all to authenticated using (public.is_admin()) with check (public.is_admin());


-- =============================================================================
-- 8. STORAGE
--   avatars : public read. A signed-in user may write only inside the folder
--             named after their own id, e.g. avatars/<uid>/avatar.jpg
--   catalog : public read. Only admin may upload, replace or delete.
-- =============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars', 'avatars', true, 5242880,  array['image/jpeg', 'image/png', 'image/webp']),
  ('catalog', 'catalog', true, 10485760, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- ---- avatars ----------------------------------------------------------------
drop policy if exists avatars_public_read on storage.objects;
create policy avatars_public_read on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'avatars');

drop policy if exists avatars_owner_insert on storage.objects;
create policy avatars_owner_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists avatars_owner_update on storage.objects;
create policy avatars_owner_update on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists avatars_owner_delete on storage.objects;
create policy avatars_owner_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- ---- catalog ----------------------------------------------------------------
drop policy if exists catalog_public_read on storage.objects;
create policy catalog_public_read on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'catalog');

drop policy if exists catalog_admin_insert on storage.objects;
create policy catalog_admin_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'catalog' and public.is_admin());

drop policy if exists catalog_admin_update on storage.objects;
create policy catalog_admin_update on storage.objects
  for update to authenticated
  using (bucket_id = 'catalog' and public.is_admin())
  with check (bucket_id = 'catalog' and public.is_admin());

drop policy if exists catalog_admin_delete on storage.objects;
create policy catalog_admin_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'catalog' and public.is_admin());


-- =============================================================================
-- 9. REALTIME
-- profiles (points/tier), transactions (new activity) and drop_stations
-- (capacity) stream to clients. Realtime applies RLS, so a user only receives
-- their own profile and transaction rows.
-- =============================================================================

do $$
declare
  t text;
begin
  foreach t in array array['profiles', 'transactions', 'drop_stations'] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;


-- =============================================================================
-- 10. SEED DATA (idempotent: ON CONFLICT DO NOTHING, safe to run again)
-- Copied from the data currently inside the Flutter app (MockStore,
-- MockStations, EducationCatalog, EWalletOption) so the first real sync keeps
-- the same names, prices and texts. Edit rows later from the admin portal; a
-- re-run never overwrites them.
-- =============================================================================

-- ---- app_settings -----------------------------------------------------------
insert into public.app_settings (key, value, description) values
  ('points_per_can',                '25'::jsonb,   'Points earned per can (DropSessionSummary.pointsPerCan)'),
  ('grams_per_can',                 '14'::jsonb,   'Weight of one can in grams (DropSessionSummary.gramsPerCan)'),
  ('carbon_kg_per_can',             '0.13'::jsonb, 'Carbon saved per can in kg CO2e (DropSessionSummary.carbonKgPerCan)'),
  ('max_cans_per_deposit',          '1000'::jsonb, 'Upper bound of cans in a single record_can_deposit call (matches the +1000 collective preset)'),
  ('ewallet_points_per_rupiah',     '1'::jsonb,    'Points per rupiah for e-wallet items (EWalletOption.pointsPerRupiah); catalog prices are seeded with it'),
  ('helpful_bonus_points',          '5'::jsonb,    'Bonus for a helpful article (EducationService.helpfulBonusPoints)'),
  ('checkin_rewards',               '[10, 20, 30, 50, 75, 100, 200]'::jsonb,   'Daily check-in reward by weekday, Monday first (MockStore.checkInRewards)'),
  ('tier_thresholds',               '{"silver": 1000, "gold": 5000}'::jsonb,   'Points needed for Silver and Gold (MemberTier). Tier follows the current balance, like the app'),
  ('station_full_threshold_percent','90'::jsonb,   'Capacity percentage from which a station counts as full (DropStation.isFull)'),
  ('carbon_goal_cans',              '{"week": 700, "month": 3000, "sinceJan2025": 45000}'::jsonb, 'Community goal in cans per chart range (CarbonRange.goalCans)')
on conflict (key) do nothing;


-- ---- quest_definitions (MockStore.quests) -----------------------------------
insert into public.quest_definitions (id, period, metric, title, title_en, unit, unit_en, target, reward_points, sort_order) values
  (1, 'daily', 'cans', 'Setor 5 Kaleng Hari Ini', 'Drop 5 Cans Today', 'Kaleng', 'Cans', 5, 50, 10),
  (2, 'daily', 'cans', 'Setor 10 Kaleng Hari Ini', 'Drop 10 Cans Today', 'Kaleng', 'Cans', 10, 150, 20),
  (3, 'daily', 'checkIn', 'Klaim Hadiah Harian', 'Claim the Daily Reward', 'Klaim', 'Claim', 1, 20, 30),
  (4, 'weekly', 'cans', 'Setor 15 Kaleng Minggu Ini', 'Drop 15 Cans This Week', 'Kaleng', 'Cans', 15, 200, 40),
  (5, 'weekly', 'checkIn', 'Klaim 3 Hadiah Harian', 'Claim 3 Daily Rewards', 'Klaim', 'Claims', 3, 120, 50),
  (6, 'weekly', 'voucher', 'Tukar 1 Voucher Minggu Ini', 'Redeem 1 Voucher This Week', 'Voucher', 'Voucher', 1, 100, 60),
  (7, 'monthly', 'cans', 'Kontributor Eco-Hero 50 Kaleng', 'Eco-Hero Contributor 50 Cans', 'Kaleng', 'Cans', 50, 600, 70),
  (8, 'monthly', 'product', 'Tukar 1 Produk Kriya', 'Redeem 1 Craft Product', 'Produk', 'Product', 1, 300, 80),
  (9, 'monthly', 'cans', 'Setor 100 Kaleng Bulan Ini', 'Drop 100 Cans This Month', 'Kaleng', 'Cans', 100, 1500, 90)
on conflict (id) do nothing;

-- ---- catalog_items ----------------------------------------------------------
-- Crafts (ids 1-99): MockStore.products. Image URLs stay empty until admin
-- uploads pictures to the "catalog" bucket.
insert into public.catalog_items (id, item_type, name, name_en, description, description_en, category, price_points, price_idr, stock, sort_order) values
  (1, 'product', 'Miniatur F1', 'F1 Miniature', 'Replika mobil balap Formula 1 dari aluminium kaleng daur ulang, dirakit dan dipoles tangan.', 'A Formula 1 race car replica made from recycled aluminum cans, hand-assembled and hand-polished.', 'toy', 15000, 150000, 8, 10),
  (2, 'product', 'Miniatur Jet Tempur', 'Fighter Jet Miniature', 'Replika jet tempur dengan detail sayap dan kokpit dari lembaran aluminium kaleng.', 'A fighter jet replica with detailed wings and cockpit made from aluminum can sheets.', 'toy', 20000, 200000, 5, 20),
  (3, 'product', 'Miniatur Mobil Klasik', 'Classic Car Miniature', 'Replika mobil klasik berlapis anti-karat, cocok sebagai hiasan meja kerja.', 'A rust-proof coated classic car replica, perfect as a desk decoration.', 'toy', 12000, 120000, 10, 30),
  (4, 'product', 'Miniatur Kapal Pinisi', 'Pinisi Ship Miniature', 'Replika kapal pinisi khas Nusantara dari potongan kaleng yang dibentuk satu per satu.', 'A replica of the traditional Nusantara pinisi ship, shaped one by one from cut aluminum cans.', 'decor', 18000, 180000, 4, 40),
  (5, 'product', 'Vas Bunga Kaleng', 'Tin Can Flower Vase', 'Vas minimalis dari kaleng aluminium bekas, dicat tangan dan siap mempercantik sudut ruangan.', 'A minimalist vase from used aluminum cans, hand-painted and ready to brighten up any corner of your room.', 'decor', 9000, 90000, 12, 50),
  (6, 'product', 'Lampu Meja Kaleng', 'Tin Can Desk Lamp', 'Lampu meja hangat dengan rangka kaleng daur ulang, cocok untuk kamar tidur dan sudut kerja.', 'A warm desk lamp with a recycled can frame, great for bedrooms and work corners.', 'decor', 14000, 140000, 6, 60)
on conflict (id) do nothing;

-- Vouchers (ids 101-199): MockStore.vouchers. icon_key maps to AppIcons.meal /
-- parking / print; gradient_hex is the card gradient (AppColors.gold/goldDeep,
-- primary/primaryDark, primaryDark/primaryLight).
insert into public.catalog_items (id, item_type, name, name_en, description, description_en, price_points, icon_key, gradient_hex, sort_order) values
  (101, 'voucher', 'Diskon Kuliner 20%', 'Food Discount 20%', 'Berlaku di gerai makanan dan minuman mitra ReCan.', 'Valid at ReCan partner food and beverage outlets.', 500, 'meal', array['#C8A252', '#8A6D28']::text[], 10),
  (102, 'voucher', 'Gratis Parkir', 'Free Parking', 'Gratis parkir motor satu hari di lokasi mitra.', 'One day of free motorbike parking at partner locations.', 800, 'parking', array['#284B63', '#1B3547']::text[], 20),
  (103, 'voucher', 'Diskon Fotokopi 30%', 'Photocopy Discount 30%', 'Potongan biaya fotokopi dan cetak di gerai mitra.', 'Discount on copying and printing at partner shops.', 300, 'print', array['#1B3547', '#386282']::text[], 30)
on conflict (id) do nothing;

-- E-wallet top-ups (ids 201-299): EWalletOption.all, 1 point = Rp 1.
insert into public.catalog_items (id, item_type, name, name_en, price_points, price_idr, icon_key, ewallet_provider, ewallet_nominal, sort_order) values
  (201, 'ewallet', 'Saldo GoPay Rp 20.000', 'GoPay Balance Rp 20.000', 20000, 20000, 'gopay', 'GoPay', 20000, 10),
  (202, 'ewallet', 'Saldo GoPay Rp 50.000', 'GoPay Balance Rp 50.000', 50000, 50000, 'gopay', 'GoPay', 50000, 20),
  (203, 'ewallet', 'Saldo GoPay Rp 100.000', 'GoPay Balance Rp 100.000', 100000, 100000, 'gopay', 'GoPay', 100000, 30),
  (204, 'ewallet', 'Saldo OVO Rp 20.000', 'OVO Balance Rp 20.000', 20000, 20000, 'ovo', 'OVO', 20000, 40),
  (205, 'ewallet', 'Saldo OVO Rp 50.000', 'OVO Balance Rp 50.000', 50000, 50000, 'ovo', 'OVO', 50000, 50),
  (206, 'ewallet', 'Saldo OVO Rp 100.000', 'OVO Balance Rp 100.000', 100000, 100000, 'ovo', 'OVO', 100000, 60),
  (207, 'ewallet', 'Saldo DANA Rp 20.000', 'DANA Balance Rp 20.000', 20000, 20000, 'dana', 'DANA', 20000, 70),
  (208, 'ewallet', 'Saldo DANA Rp 50.000', 'DANA Balance Rp 50.000', 50000, 50000, 'dana', 'DANA', 50000, 80),
  (209, 'ewallet', 'Saldo DANA Rp 100.000', 'DANA Balance Rp 100.000', 100000, 100000, 'dana', 'DANA', 100000, 90)
on conflict (id) do nothing;

-- ---- drop_stations ----------------------------------------------------------
-- Same eight stations as MockStations (ids 201-208, coordinates from
-- OpenStreetMap). max_capacity 200; current_cans reproduces the capacity
-- percentages of the app. Opening hours (06:00-22:00) are placeholders to
-- confirm with each site owner.
insert into public.drop_stations (id, name, name_en, location, location_en, address, lat, lng, current_cans, max_capacity, opens_at, closes_at) values
  (201, 'Drop Station Pasar Modern Bintaro', 'Drop Station at Pasar Modern Bintaro', 'Pasar Modern Bintaro Sektor 7', 'Pasar Modern Bintaro Sector 7', 'Pasar Modern Bintaro, Jl. Tegal Rotan Raya, Sektor 7, Bintaro Jaya, Pondok Aren, Tangerang Selatan', -6.2796, 106.71938, 70, 200, '06:00', '22:00'),
  (202, 'Drop Station Stasiun Pondok Ranji', 'Drop Station at Pondok Ranji Station', 'Stasiun KRL Pondok Ranji', 'Pondok Ranji KRL Station', 'Stasiun Pondok Ranji, Pondok Ranji, Ciputat Timur, Tangerang Selatan', -6.27668, 106.74469, 170, 200, '06:00', '22:00'),
  (203, 'Drop Station Bintaro Plaza', 'Drop Station at Bintaro Plaza', 'Bintaro Plaza Sektor 3A', 'Bintaro Plaza Sector 3A', 'Bintaro Plaza, Jl. Bintaro Utama 3A, Sektor 3A, Bintaro Jaya, Pondok Aren, Tangerang Selatan', -6.27268, 106.74187, 120, 200, '06:00', '22:00'),
  (204, 'Drop Station Stasiun Jurang Mangu', 'Drop Station at Jurang Mangu Station', 'Stasiun KRL Jurang Mangu', 'Jurang Mangu KRL Station', 'Stasiun Jurang Mangu, Jl. Cendrawasih Raya, Sawah, Ciputat, Tangerang Selatan', -6.28858, 106.72915, 96, 200, '06:00', '22:00'),
  (205, 'Drop Station Bintaro Jaya Xchange', 'Drop Station at Bintaro Jaya Xchange', 'Bintaro Jaya Xchange Mall', 'Bintaro Jaya Xchange Mall', 'Bintaro Jaya Xchange Mall, Jl. Akses Bintaro Xchange, CBD Bintaro Jaya, Pondok Aren, Tangerang Selatan', -6.28567, 106.728, 132, 200, '06:00', '22:00'),
  (206, 'Drop Station AEON Mall BSD', 'Drop Station at AEON Mall BSD', 'AEON Mall BSD City', 'AEON Mall BSD City', 'AEON Mall BSD City, Jl. BSD Raya Utama, BSD City, Pagedangan, Kabupaten Tangerang', -6.30441, 106.64416, 44, 200, '06:00', '22:00'),
  (207, 'Drop Station Taman Kota 1 BSD', 'Drop Station at Taman Kota 1 BSD', 'Taman Kota 1, BSD City', 'Taman Kota 1, BSD City', 'Taman Kota 1, BSD City, Serpong, Tangerang Selatan', -6.28822, 106.67599, 148, 200, '06:00', '22:00'),
  (208, 'Drop Station Stasiun Rawa Buntu', 'Drop Station at Rawa Buntu Station', 'Stasiun KRL Rawa Buntu', 'Rawa Buntu KRL Station', 'Stasiun Rawa Buntu, Jl. Stasiun Rawa Buntu, Serpong, Tangerang Selatan', -6.31488, 106.67615, 62, 200, '06:00', '22:00')
on conflict (id) do nothing;

-- ---- education_articles -----------------------------------------------------
-- EducationCatalog.articles (ids 1-6). published_at is midnight Jakarta time.
-- No SIPSN statistics are seeded on purpose: published 2025 national figures
-- differ between sources, so add that article from the admin portal with the
-- official number and fill source_name / source_url.
insert into public.education_articles (id, category, title, title_en, summary, summary_en, paragraphs, paragraphs_en, insight, insight_en, stats, read_minutes, published_at) values
  (1, 'about', 'Apa Itu ReCan dan Bagaimana Cara Kerjanya', 'What ReCan Is and How It Works', 'Kenali ekosistem Drop Station pintar di sekitarmu.', 'Meet the smart Drop Station ecosystem around you.',
   array['ReCan adalah aplikasi daur ulang kaleng untuk semua orang. Ide dasarnya sederhana: kaleng bekas yang biasanya berakhir di tempat sampah kini punya nilai, dan setiap orang bisa ikut menjaganya tetap berputar.', 'Kamu cukup datang ke Drop Station terdekat, memindai kode QR, lalu memasukkan kaleng satu per satu. Sensor di dalam station menghitung jumlah dan berat kaleng, kemudian mengubahnya menjadi poin secara otomatis.', 'Poin yang terkumpul bisa ditukar dengan kriya daur ulang, saldo e-wallet, atau voucher mitra. Semakin rutin kamu menyetor, semakin tinggi tier member yang kamu dapatkan.']::text[],
   array['ReCan is a can recycling app for everyone. The idea is simple: used cans that usually end up in the trash now have value, and everyone can help keep them in circulation.', 'Just go to the nearest Drop Station, scan the QR code, and insert your cans one by one. Sensors inside the station count the cans and weigh them, then convert them into points automatically.', 'The points you collect can be redeemed for recycled crafts, e-wallet balance, or partner vouchers. The more regularly you drop cans, the higher your member tier climbs.']::text[],
   'Satu kaleng yang disetor di ReCan mendapat 25 poin, dan semuanya tercatat otomatis di tab Aktivitas.', 'Every can dropped at ReCan earns 25 points, all recorded automatically in the Activity tab.',
   '[{"value": "25", "label": "Poin per kaleng", "label_en": "Points per can"}, {"value": "8", "label": "Titik Drop Station", "label_en": "Drop Station points"}, {"value": "3", "label": "Tier member", "label_en": "Member tiers"}]'::jsonb, 3, '2026-10-12 00:00:00+07'),
  (2, 'about', 'Dari Kaleng Bekas Menjadi Kriya Bernilai', 'From Used Cans to Valuable Crafts', 'Perjalanan satu kaleng setelah kamu menyetornya.', 'The journey of a single can after you drop it.',
   array['Setelah kamu menyetor, kaleng dikumpulkan oleh petugas dan dibawa ke tempat pemilahan. Di sana kaleng dibersihkan dari sisa minuman dan label, lalu dipisahkan berdasarkan jenis logamnya.', 'Sebagian kaleng dilebur menjadi lembaran aluminium baru, sementara sebagian lainnya dipotong dan dibentuk oleh perajin lokal menjadi miniatur, vas, dan lampu meja yang ada di Katalog.', 'Setiap karya dipoles dengan tangan sehingga tidak ada dua produk yang benar-benar sama. Dengan menukar poinmu, kamu ikut menghidupi perajin lokal dan menjaga aluminium tetap berputar.']::text[],
   array['After you drop your cans, staff collect them and take them to a sorting site. There the cans are cleaned of leftover drink and labels, then separated by metal type.', 'Some cans are melted into new aluminum sheets, while others are cut and shaped by local artisans into the miniatures, vases, and desk lamps you see in the Catalog.', 'Every piece is polished by hand so no two products are exactly the same. By redeeming your points, you support local artisans and keep aluminum in circulation.']::text[],
   'Tidak ada cetakan pabrik. Setiap sambungan pada kriya ReCan dibentuk dan dipoles dengan tangan.', 'There are no factory molds. Every joint on a ReCan craft is shaped and polished by hand.',
   '[{"value": "6", "label": "Produk kriya", "label_en": "Craft products"}, {"value": "100%", "label": "Aluminium daur ulang", "label_en": "Recycled aluminum"}, {"value": "1:18", "label": "Skala miniatur", "label_en": "Miniature scale"}]'::jsonb, 4, '2026-10-08 00:00:00+07'),
  (3, 'importance', 'Mengapa Aluminium Layak Didaur Ulang', 'Why Aluminum Deserves a Second Life', 'Aluminium bisa didaur ulang tanpa kehilangan kualitas.', 'Aluminum can be recycled without losing its quality.',
   array['Aluminium adalah salah satu material paling istimewa di dunia industri. Berbeda dengan banyak bahan lain yang menurun mutunya setiap kali diolah ulang, aluminium dapat didaur ulang berkali-kali tanpa kehilangan kualitas aslinya.', 'Memproduksi aluminium dari bijih bauksit membutuhkan energi yang sangat besar. Sebaliknya, melebur kaleng bekas hanya memerlukan sebagian kecil dari energi tersebut, sehingga emisi karbon yang dihasilkan jauh lebih rendah.', 'Itu sebabnya satu kaleng yang kamu buang hari ini bisa kembali menjadi kaleng baru dalam hitungan minggu, lalu melakukannya lagi dan lagi tanpa batas.']::text[],
   array['Aluminum is one of the most remarkable materials in industry. Unlike many other materials that degrade each time they are reprocessed, aluminum can be recycled again and again without losing its original quality.', 'Producing aluminum from bauxite ore takes a huge amount of energy. Melting used cans, by contrast, needs only a small fraction of that energy, so the carbon emissions are far lower.', 'That is why a can you throw away today can become a new can within weeks, and then do it again and again without limit.']::text[],
   'Mendaur ulang 1 kaleng aluminium menghemat energi hingga 95% dibandingkan memproduksi dari bijih bauksit mentah.', 'Recycling 1 aluminum can saves up to 95% of the energy needed to produce it from raw bauxite ore.',
   '[{"value": "95%", "label": "Energi dihemat", "label_en": "Energy saved"}, {"value": "∞", "label": "Kali bisa didaur ulang", "label_en": "Times recyclable"}, {"value": "60", "label": "Hari kaleng kembali ke rak", "label_en": "Days to return to shelves"}]'::jsonb, 4, '2026-09-28 00:00:00+07'),
  (4, 'importance', 'Tips Memilah Sampah di Rumah dan Tempat Kerja', 'Tips for Sorting Waste at Home and at Work', 'Tiga kebiasaan kecil yang mempermudah proses daur ulang.', 'Three small habits that make recycling easier.',
   array['Memilah sampah tidak perlu rumit. Mulailah dengan menyediakan satu wadah khusus untuk kaleng di rumah atau tasmu, terpisah dari sampah basah dan plastik.', 'Bilas kaleng sebelum disetor agar tidak berbau dan tidak mengotori kaleng lain. Setelah itu, pipihkan kaleng supaya hemat tempat dan lebih banyak yang bisa kamu bawa sekali jalan.', 'Biasakan menyetor saat melewati Drop Station, misalnya sepulang kerja atau berbelanja. Kebiasaan kecil yang rutin lebih berdampak daripada setoran besar yang jarang.']::text[],
   array['Sorting waste does not have to be complicated. Start by keeping a dedicated container for cans in your room or backpack, separate from wet waste and plastic.', 'Rinse cans before dropping them so they do not smell or dirty other cans. Then flatten them to save space and carry more in a single trip.', 'Make it a habit to drop cans when you pass a Drop Station, for example on your way home from work or shopping. Small, regular habits make more impact than large, rare deposits.']::text[],
   'Kaleng yang dibilas dan dipipihkan lebih cepat diproses dan menghemat ruang hingga separuhnya.', 'Rinsed and flattened cans are processed faster and save up to half the space.',
   '[{"value": "3", "label": "Langkah mudah", "label_en": "Easy steps"}, {"value": "50%", "label": "Ruang dihemat", "label_en": "Space saved"}, {"value": "5 mnt", "label": "Waktu per hari", "label_en": "Minutes per day"}]'::jsonb, 3, '2026-10-03 00:00:00+07'),
  (5, 'impact', 'Jejak Karbon yang Kamu Hemat Setiap Hari', 'The Carbon Footprint You Save Every Day', 'Setiap kaleng yang disetor ikut menurunkan emisi.', 'Every can you drop helps cut emissions.',
   array['Setiap produk punya jejak karbon, yaitu jumlah gas rumah kaca yang dihasilkan sepanjang hidupnya. Untuk aluminium, sebagian besar jejak itu muncul saat penambangan dan peleburan bijih mentah.', 'Ketika kaleng bekas didaur ulang, tahap-tahap berat itu dilewati. Karena itu, tiap kaleng yang kamu setor di ReCan secara nyata mengurangi emisi dibandingkan jika kaleng itu dibuang.', 'Di Beranda kamu bisa memantau grafik dampak karbon dan melihat berapa kilogram emisi yang sudah kamu hemat. Angka itu bertambah setiap kali kamu menyelesaikan satu sesi setoran.', 'Berdasarkan data SIPSN 2025, komposisi sampah nasional didominasi oleh Sisa Makanan (40,24%), disusul Plastik (20,21%), Kayu/Ranting (12,96%), Kertas/Karton (10,74%), Lainnya (6,94%), Logam (3,02%), dan Kaca (2,27%). Meskipun logam (termasuk kaleng) hanya 3,02%, kaleng membutuhkan waktu 80 hingga 200 tahun untuk terurai secara alami dan karatnya dapat mencemari tanah.']::text[],
   array['Every product has a carbon footprint, the amount of greenhouse gases produced over its life. For aluminum, most of that footprint comes from mining and smelting raw ore.', 'When used cans are recycled, those heavy stages are skipped. That is why every can you drop at ReCan genuinely reduces emissions compared with throwing it away.', 'On the Home page you can follow the carbon impact chart and see how many kilograms of emissions you have saved. The number grows every time you finish a deposit session.', 'According to 2025 SIPSN data, national waste composition is dominated by food waste (40.24%), followed by plastic (20.21%), wood/twigs (12.96%), paper/cardboard (10.74%), other (6.94%), metal (3.02%), and glass (2.27%). Even though metal (including cans) is only 3.02%, a can still takes 80 to 200 years to decompose naturally, and its rust can contaminate the soil.']::text[],
   'Setiap kaleng yang disetor di ReCan dihitung menghemat sekitar 0,13 kg emisi karbon.', 'Every can dropped at ReCan is counted as saving about 0.13 kg of carbon emissions.',
   '[{"value": "0,13", "label": "kg CO2 per kaleng", "label_en": "kg CO2 per can"}, {"value": "7", "label": "Hari grafik mingguan", "label_en": "Days in weekly chart"}, {"value": "95%", "label": "Energi lebih hemat", "label_en": "Less energy used"}]'::jsonb, 4, '2026-10-10 00:00:00+07'),
  (6, 'impact', 'Lingkungan Bersih, Bumi Lestari', 'A Clean Neighborhood for a Greener Planet', 'Dampak kolektif ribuan kaleng yang tidak lagi terbuang.', 'The collective impact of thousands of cans kept from waste.',
   array['Dampak terbesar daur ulang lahir dari kebiasaan bersama. Ketika seluruh warga ikut menyetor, ribuan kaleng tidak lagi berakhir di tempat pembuangan atau tercecer di taman dan selokan.', 'Lingkungan yang bersih bukan hanya enak dipandang. Lingkungan yang terjaga mengurangi risiko banjir akibat saluran tersumbat dan membuat ruang publik jadi lebih nyaman bagi semua orang.', 'Program ini sejalan dengan tujuan pembangunan berkelanjutan (SDG 11 dan 12) tentang kota yang berkelanjutan serta konsumsi dan produksi yang bertanggung jawab. Langkahmu hari ini adalah bagian dari gerakan itu.']::text[],
   array['The biggest impact of recycling comes from shared habits. When the whole community joins in, thousands of cans no longer end up in landfills or scattered across gardens and drains.', 'A clean neighborhood is not only pleasant to look at. A well-kept environment reduces the risk of floods from clogged drains and makes public spaces more comfortable for everyone.', 'This program is aligned with the sustainable development goals (SDG 11 and 12) on sustainable cities and responsible consumption and production. Your step today is part of that movement.']::text[],
   'Kampanye SDG 11 & 12 mengajak seluruh masyarakat menjadikan daur ulang kaleng sebagai kebiasaan harian.', 'The SDG 11 & 12 campaign invites the whole community to make can recycling a daily habit.',
   '[{"value": "1.240", "label": "kg kaleng terkumpul", "label_en": "kg of cans collected"}, {"value": "2", "label": "Target SDG didukung", "label_en": "SDG goals supported"}, {"value": "1.860", "label": "kg emisi dihemat", "label_en": "kg of emissions saved"}]'::jsonb, 5, '2026-10-01 00:00:00+07')
on conflict (id) do nothing;

-- ---- community_impact_baseline ----------------------------------------------
-- Daily baseline from 2025-01-01 to 2026-12-31, the same curve the app shows
-- today (MockStore._communityMonthCans and the weekday factors):
--   cans in month m = 900 + 60 * m + (m mod 3) * 70   (m = months since Jan 2025)
--   cans on a day   = month cans / 30 * factor of that weekday (Mon..Sun)
-- It is a placeholder estimate until real campaign data replaces it. Real
-- deposits are added on top by community_carbon_summary. Rows only exist up to
-- the end date; extend the range (or edit rows) when 2027 approaches.
insert into public.community_impact_baseline (day, cans, note)
select g.day::date,
       round(
         (900 + 60 * m.idx + (m.idx % 3) * 70) / 30.0
         * (array[0.9, 1.1, 0.8, 1.2, 1.0, 0.7, 1.3])[extract(isodow from g.day)::integer]
       )::integer,
       'placeholder estimate (app demo curve)'
from generate_series(date '2025-01-01', date '2026-12-31', interval '1 day') as g(day)
cross join lateral (
  select ((extract(year from g.day)::integer - 2025) * 12 + extract(month from g.day)::integer - 1) as idx
) m
on conflict (day) do nothing;

-- ---- identity sequences -----------------------------------------------------
-- Seed rows carry explicit ids, so move each sequence past the highest id.
select setval(pg_get_serial_sequence('public.drop_stations', 'id'),
              greatest((select coalesce(max(id), 1) from public.drop_stations), 1));
select setval(pg_get_serial_sequence('public.catalog_items', 'id'),
              greatest((select coalesce(max(id), 1) from public.catalog_items), 1));
select setval(pg_get_serial_sequence('public.quest_definitions', 'id'),
              greatest((select coalesce(max(id), 1) from public.quest_definitions), 1));
select setval(pg_get_serial_sequence('public.education_articles', 'id'),
              greatest((select coalesce(max(id), 1) from public.education_articles), 1));


-- =============================================================================
-- AFTER RUNNING
--   1. Create your first admin: sign up in the app (or Auth > Users), then run
--        update public.profiles set role = 'admin' where username = '<your username>';
--      Run it in the SQL Editor (postgres role); clients cannot do this.
--      Later roles go through: select public.admin_set_user_role('<uid>', 'produser');
--   2. Sanity checks
--        select count(*) from public.drop_stations;          -- 8
--        select count(*) from public.catalog_items;          -- 18 (6 + 3 + 9)
--        select * from public.community_carbon_summary where range_key = 'week';
--        select * from public.stations_with_distance(-6.288, 106.729);
--   3. Auth settings: set Site URL / redirect URLs and decide whether email
--      confirmation is required. Pass username, full_name and phone as the
--      "data" option of signUp so handle_new_user() can fill the profile.
-- =============================================================================

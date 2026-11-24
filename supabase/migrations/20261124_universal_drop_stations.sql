-- =============================================================================
-- Migration: universal public drop stations (replaces the three UPJ campus rows)
--
-- schema.sql seeds stations with ON CONFLICT DO NOTHING, so a database that was
-- created from the earlier seed keeps the old UPJ names. Run this once in the
-- Supabase SQL Editor to bring ids 201-203 in line with the current seed.
-- It is safe to run again. Counters, QR codes and ids are left untouched.
-- =============================================================================

update public.drop_stations as s
set name = v.name,
    name_en = v.name_en,
    location = v.location,
    location_en = v.location_en,
    address = v.address,
    lat = v.lat,
    lng = v.lng
from (values
  (201, 'Drop Station Pasar Modern Bintaro', 'Drop Station at Pasar Modern Bintaro',
        'Pasar Modern Bintaro Sektor 7', 'Pasar Modern Bintaro Sector 7',
        'Pasar Modern Bintaro, Jl. Tegal Rotan Raya, Sektor 7, Bintaro Jaya, Pondok Aren, Tangerang Selatan',
        -6.2796::double precision, 106.71938::double precision),
  (202, 'Drop Station Stasiun Pondok Ranji', 'Drop Station at Pondok Ranji Station',
        'Stasiun KRL Pondok Ranji', 'Pondok Ranji KRL Station',
        'Stasiun Pondok Ranji, Pondok Ranji, Ciputat Timur, Tangerang Selatan',
        -6.27668::double precision, 106.74469::double precision),
  (203, 'Drop Station Bintaro Plaza', 'Drop Station at Bintaro Plaza',
        'Bintaro Plaza Sektor 3A', 'Bintaro Plaza Sector 3A',
        'Bintaro Plaza, Jl. Bintaro Utama 3A, Sektor 3A, Bintaro Jaya, Pondok Aren, Tangerang Selatan',
        -6.27268::double precision, 106.74187::double precision)
) as v (id, name, name_en, location, location_en, address, lat, lng)
where s.id = v.id;

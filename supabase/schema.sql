-- GreenLeaf Supabase Database Schema & Seed Data
-- Run this entire script in: Supabase Dashboard -> SQL Editor -> New query -> Run

-- 1. Create plants table
create table if not exists public.plants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  emoji text not null default '🌿',
  room text not null,
  water_every_days integer not null check (water_every_days > 0),
  last_watered timestamptz not null default now(),
  sunlight text not null default 'Bright Indirect',
  care_tip text not null default 'Check the top inch of soil before watering.',
  watered_count integer not null default 0,
  created_at timestamptz not null default now()
);

-- 2. Create watering_log table
create table if not exists public.watering_log (
  id uuid primary key default gen_random_uuid(),
  plant_id uuid not null references public.plants(id) on delete cascade,
  plant_name text not null,
  watered_at timestamptz not null default now(),
  note text
);

-- Index for fast lookup of watering logs per plant
create index if not exists idx_watering_log_plant_id
  on public.watering_log (plant_id, watered_at desc);

-- 3. Enable Row Level Security (RLS) with open policies for this personal app
alter table public.plants enable row level security;
alter table public.watering_log enable row level security;

drop policy if exists "Allow public read plants" on public.plants;
drop policy if exists "Allow public insert plants" on public.plants;
drop policy if exists "Allow public update plants" on public.plants;
drop policy if exists "Allow public delete plants" on public.plants;

create policy "Allow public read plants"
  on public.plants for select
  to anon, authenticated
  using (true);

create policy "Allow public insert plants"
  on public.plants for insert
  to anon, authenticated
  with check (true);

create policy "Allow public update plants"
  on public.plants for update
  to anon, authenticated
  using (true)
  with check (true);

create policy "Allow public delete plants"
  on public.plants for delete
  to anon, authenticated
  using (true);

drop policy if exists "Allow public read watering_log" on public.watering_log;
drop policy if exists "Allow public insert watering_log" on public.watering_log;
drop policy if exists "Allow public delete watering_log" on public.watering_log;

create policy "Allow public read watering_log"
  on public.watering_log for select
  to anon, authenticated
  using (true);

create policy "Allow public insert watering_log"
  on public.watering_log for insert
  to anon, authenticated
  with check (true);

create policy "Allow public delete watering_log"
  on public.watering_log for delete
  to anon, authenticated
  using (true);

-- 4. Seed the 8 sample plants (only if plants table is empty so re-running is safe)
insert into public.plants (name, emoji, room, water_every_days, last_watered, sunlight, care_tip, watered_count)
select * from (
  values
    ('Money Plant', '🌿', 'Living Room', 4,  now() - interval '4 days', 'Bright Indirect',     'Loves indirect light and slightly dry topsoil between waterings. Wipe leaves gently for a healthy shine.', 6),
    ('Aloe Vera',   '🪴', 'Bedroom',     10, now() - interval '4 days', 'Bright Sun',          'Soak deeply, then allow the soil to dry completely before watering again. Avoid soggy roots.', 4),
    ('Snake Plant', '🌱', 'Study',       14, now() - interval '6 days', 'Low to Bright Light', 'Super resilient and purifies indoor air. Water sparingly around the rim rather than the leaf center.', 3),
    ('Tulsi',       '☘️', 'Balcony',     2,  now() - interval '2 days', 'Direct Sun',          'Thrives in warm morning sunlight. Keep soil evenly moist and pinch flower buds for bushier leaves.', 12),
    ('Rose',        '🌹', 'Terrace',     3,  now() - interval '3 days', 'Direct Sun',          'Water at the base early in the morning to keep petals dry and prevent leaf spots.', 8),
    ('Mint',        '🍃', 'Kitchen',     2,  now() - interval '1 day',  'Partial Sun',         'Prefers consistently cool, lightly damp soil. Snip top sprigs regularly to encourage fresh growth.', 9),
    ('Peace Lily',  '🌸', 'Living Room', 5,  now() - interval '5 days', 'Low to Medium Light', 'Drooping leaves are a polite reminder for water. Loves occasional misting for tropical humidity.', 5),
    ('Cactus',      '🌵', 'Work Desk',   14, now() - interval '5 days', 'Direct Sun',          'Needs plenty of sunshine and fast-draining soil. Less water is always safer than too much.', 2)
) as seed(name, emoji, room, water_every_days, last_watered, sunlight, care_tip, watered_count)
where not exists (select 1 from public.plants);

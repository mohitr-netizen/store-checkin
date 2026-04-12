-- ============================================================
-- CaratLane Store Check-in — Supabase Setup
-- Run this in: https://supabase.com/dashboard/project/sazlkppprwoctfwjhfqj/sql
-- ============================================================

-- Stores
create table if not exists stores (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  slug text not null unique,
  address text
);

insert into stores (name, slug, address) values
  ('CaratLane Dallas',     'dallas',      'Dallas, Texas'),
  ('CaratLane Edison',     'edison',      'Edison, New Jersey'),
  ('CaratLane Trunk Show', 'trunk-show',  'Trunk Show')
on conflict (slug) do nothing;

-- Check-ins
create table if not exists checkins (
  id         uuid default gen_random_uuid() primary key,
  store_slug text not null,
  first_name text not null,
  last_name  text not null,
  phone      text not null,
  status     text not null default 'waiting'
               check (status in ('waiting', 'in_progress', 'completed')),
  consultant_id text default 'DallasTexas@caratlane.us',
  token      text default gen_random_uuid()::text unique not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Row Level Security (open for prototype)
alter table stores   enable row level security;
alter table checkins enable row level security;

create policy "public_stores_read"    on stores   for select using (true);
create policy "public_checkins_read"  on checkins for select using (true);
create policy "public_checkins_write" on checkins for insert with check (true);
create policy "public_checkins_update" on checkins for update using (true);

-- Enable Realtime
alter publication supabase_realtime add table checkins;

-- Token number (daily, per-location) — run once
alter table checkins add column if not exists token_number int;

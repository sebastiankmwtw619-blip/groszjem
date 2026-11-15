-- Schemat wspólnej bazy dla Grosz.jem (Supabase → SQL Editor → wklej i uruchom).
-- Lokale z places.json są wbudowane w aplikację; w bazie trzymamy tylko to, co dodają użytkownicy.

create table if not exists prices (
  id uuid primary key default gen_random_uuid(),
  place_id text not null check (char_length(place_id) <= 120),
  price numeric(6,2) not null check (price >= 1 and price <= 200),
  date date not null check (date <= current_date + 1),
  kind text not null check (char_length(kind) <= 40),
  dish text not null default '' check (char_length(dish) <= 80),
  created_at timestamptz not null default now()
);

create table if not exists submissions (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 1 and 80),
  city text not null check (char_length(city) between 1 and 40),
  address text not null default '' check (char_length(address) <= 60),
  voiv int not null check (voiv between 0 and 15),
  type text not null check (char_length(type) <= 40),
  price numeric(6,2) check (price is null or (price >= 1 and price <= 200)),
  created_at timestamptz not null default now()
);

-- Każdy może czytać i dodawać; nikt anonimowy nie może zmieniać ani usuwać.
alter table prices enable row level security;
alter table submissions enable row level security;

create policy "prices read"   on prices      for select using (true);
create policy "prices insert" on prices      for insert with check (true);
create policy "subs read"     on submissions for select using (true);
create policy "subs insert"   on submissions for insert with check (true);

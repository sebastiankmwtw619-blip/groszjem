-- Moderacja Grosz.jem: statusy zgłoszeń i cen, uprawnienia moderatorów.
-- Uruchamiać po supabase.sql. Można uruchomić wielokrotnie.

alter table submissions add column if not exists status text not null default 'pending';
alter table submissions drop constraint if exists submissions_status_check;
alter table submissions add constraint submissions_status_check check (status in ('pending', 'approved', 'rejected'));
alter table submissions add column if not exists moderated_at timestamptz;

alter table prices add column if not exists status text not null default 'visible';
alter table prices drop constraint if exists prices_status_check;
alter table prices add constraint prices_status_check check (status in ('visible', 'hidden'));

-- Lista moderatorów (po adresie e-mail potwierdzonym przez logowanie linkiem).
create table if not exists moderators (
  email text primary key check (email = lower(email)),
  added_at timestamptz not null default now()
);
alter table moderators enable row level security;
revoke all on moderators from anon, authenticated;

create or replace function public.is_moderator() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from moderators where email = lower(coalesce(auth.jwt() ->> 'email', '')));
$$;
revoke all on function public.is_moderator() from public;
grant execute on function public.is_moderator() to anon, authenticated;

-- Odczyt: wszyscy widzą widoczne ceny i nieodrzucone zgłoszenia; moderator widzi wszystko.
drop policy if exists "prices read" on prices;
create policy "prices read" on prices for select using (status = 'visible' or public.is_moderator());
drop policy if exists "subs read" on submissions;
create policy "subs read" on submissions for select using (status <> 'rejected' or public.is_moderator());

-- Dodawanie: każdy, ale tylko ze statusem początkowym.
drop policy if exists "prices insert" on prices;
create policy "prices insert" on prices for insert with check (status = 'visible');
drop policy if exists "subs insert" on submissions;
create policy "subs insert" on submissions for insert with check (status = 'pending' and moderated_at is null);

-- Zmiana i usuwanie: tylko moderator.
drop policy if exists "prices moderate" on prices;
create policy "prices moderate" on prices for update using (public.is_moderator()) with check (public.is_moderator());
drop policy if exists "prices delete" on prices;
create policy "prices delete" on prices for delete using (public.is_moderator());
drop policy if exists "subs moderate" on submissions;
create policy "subs moderate" on submissions for update using (public.is_moderator()) with check (public.is_moderator());
drop policy if exists "subs delete" on submissions;
create policy "subs delete" on submissions for delete using (public.is_moderator());

grant update, delete on prices, submissions to authenticated;

-- Dodaj moderatora (adres zapisz małymi literami):
-- insert into moderators (email) values ('adres@przyklad.pl') on conflict do nothing;

notify pgrst, 'reload schema';

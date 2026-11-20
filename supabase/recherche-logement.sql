-- Immo+ — demandes de recherche de logement et messagerie privée
-- À exécuter une seule fois dans Supabase > SQL Editor.
-- L'administration se base sur profiles.type_compte = 'admin' (profil existant dans Immo+).

create table if not exists public.housing_search_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  city text not null,
  area text not null,
  property_type text not null,
  rooms text,
  budget_min numeric check (budget_min is null or budget_min >= 0),
  budget_max numeric not null check (budget_max > 0),
  move_period text,
  phone text not null,
  details text,
  status text not null default 'pending' check (status in ('pending','accepted','rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.housing_search_messages (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.housing_search_requests(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 2000),
  created_at timestamptz not null default now()
);

create index if not exists housing_search_requests_user_created_idx on public.housing_search_requests(user_id, created_at desc);
create index if not exists housing_search_requests_status_created_idx on public.housing_search_requests(status, created_at desc);
create index if not exists housing_search_messages_request_created_idx on public.housing_search_messages(request_id, created_at);

alter table public.housing_search_requests enable row level security;
alter table public.housing_search_messages enable row level security;

grant select, insert, update on public.housing_search_requests to authenticated;
grant select, insert on public.housing_search_messages to authenticated;

drop policy if exists "Users create own housing searches" on public.housing_search_requests;
create policy "Users create own housing searches" on public.housing_search_requests
  for insert to authenticated with check (user_id = (select auth.uid()) and status = 'pending');
drop policy if exists "Users and admins read housing searches" on public.housing_search_requests;
create policy "Users and admins read housing searches" on public.housing_search_requests
  for select to authenticated using (
    user_id = (select auth.uid()) or exists (
      select 1 from public.profiles p where p.id = (select auth.uid()) and p.type_compte = 'admin'
    )
  );
drop policy if exists "Admins update housing searches" on public.housing_search_requests;
create policy "Admins update housing searches" on public.housing_search_requests
  for update to authenticated using (
    exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.type_compte = 'admin')
  ) with check (
    exists (select 1 from public.profiles p where p.id = (select auth.uid()) and p.type_compte = 'admin')
  );

drop policy if exists "Participants read accepted search messages" on public.housing_search_messages;
create policy "Participants read accepted search messages" on public.housing_search_messages
  for select to authenticated using (
    exists (
      select 1 from public.housing_search_requests r
      where r.id = request_id and r.status = 'accepted'
      and (r.user_id = (select auth.uid()) or exists (
        select 1 from public.profiles p where p.id = (select auth.uid()) and p.type_compte = 'admin'
      ))
    )
  );
drop policy if exists "Participants send messages to accepted searches" on public.housing_search_messages;
create policy "Participants send messages to accepted searches" on public.housing_search_messages
  for insert to authenticated with check (
    user_id = (select auth.uid()) and exists (
      select 1 from public.housing_search_requests r
      where r.id = request_id and r.status = 'accepted'
      and (r.user_id = (select auth.uid()) or exists (
        select 1 from public.profiles p where p.id = (select auth.uid()) and p.type_compte = 'admin'
      ))
    )
  );

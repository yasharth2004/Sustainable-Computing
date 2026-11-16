create extension if not exists pgcrypto;

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  department text not null,
  academic_year smallint not null check (academic_year between 1 and 8),
  eco_points integer not null default 0 check (eco_points >= 0),
  badges jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists resources (
  id uuid primary key default gen_random_uuid(), owner_id uuid not null references profiles(id) on delete cascade,
  title text not null, description text not null, category text not null,
  resource_type text not null check (resource_type in ('Borrow','Share','Donate')),
  condition text not null check (condition in ('Brand New','Like New','Good','Usable')),
  campus_location text not null, availability_status text not null default 'Available'
    check (availability_status in ('Available','Requested','Borrowed','Unavailable')),
  borrowing_duration integer check (borrowing_duration is null or borrowing_duration > 0),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists borrowings (
  id uuid primary key default gen_random_uuid(), resource_id uuid not null references resources(id) on delete cascade,
  owner_id uuid not null references profiles(id), borrower_id uuid not null references profiles(id),
  request_date timestamptz not null default now(), approval_date timestamptz, borrow_date timestamptz,
  expected_return_date timestamptz, actual_return_date timestamptz,
  status text not null check (status in ('Pending','Approved','Rejected','Borrowed','Return Requested','Returned','Overdue')),
  check (owner_id <> borrower_id)
);
create unique index if not exists one_active_borrowing_per_resource on borrowings(resource_id)
  where status in ('Pending','Approved','Borrowed','Return Requested','Overdue');
create table if not exists campaigns (
  id uuid primary key default gen_random_uuid(), organizer_id uuid not null references profiles(id) on delete cascade,
  title text not null, description text not null, category text not null, start_date timestamptz not null,
  end_date timestamptz not null, collection_location text not null, target_quantity integer not null check (target_quantity > 0),
  status text not null check (status in ('Upcoming','Active','Completed')), created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(), check (end_date > start_date)
);
create table if not exists campaign_contributions (
  id uuid primary key default gen_random_uuid(), campaign_id uuid not null references campaigns(id) on delete cascade,
  resource_id uuid references resources(id) on delete set null, contributor_id uuid not null references profiles(id) on delete cascade,
  contribution_date timestamptz not null default now(), status text not null default 'Pledged'
    check (status in ('Pledged','Completed','Withdrawn'))
);
create table if not exists lifecycle_events (
  id uuid primary key default gen_random_uuid(), resource_id uuid not null references resources(id) on delete cascade,
  actor_id uuid not null references profiles(id), event_type text not null, description text not null,
  timestamp timestamptz not null default now()
);
create table if not exists points_transactions (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references profiles(id) on delete cascade,
  activity_type text not null, reference_id text not null, points integer not null check (points > 0),
  created_at timestamptz not null default now(), unique(user_id, activity_type, reference_id)
);
create table if not exists saved_resources (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references profiles(id) on delete cascade,
  resource_id uuid not null references resources(id) on delete cascade, created_at timestamptz not null default now(),
  unique(user_id, resource_id)
);

create or replace function set_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;
drop trigger if exists profiles_updated_at on profiles;
create trigger profiles_updated_at before update on profiles for each row execute function set_updated_at();
drop trigger if exists resources_updated_at on resources;
create trigger resources_updated_at before update on resources for each row execute function set_updated_at();
drop trigger if exists campaigns_updated_at on campaigns;
create trigger campaigns_updated_at before update on campaigns for each row execute function set_updated_at();

create or replace function handle_new_user() returns trigger language plpgsql security definer set search_path = public as $$
begin insert into public.profiles(id,display_name,department,academic_year)
values(new.id,coalesce(new.raw_user_meta_data->>'display_name','Campus member'),
coalesce(new.raw_user_meta_data->>'department','Undeclared'),
coalesce((new.raw_user_meta_data->>'academic_year')::smallint,1)); return new; end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure handle_new_user();

create index if not exists resources_category_idx on resources(category);
create index if not exists resources_owner_idx on resources(owner_id);
create index if not exists borrowings_participants_idx on borrowings(owner_id,borrower_id,status);
create index if not exists lifecycle_resource_idx on lifecycle_events(resource_id,timestamp);
create index if not exists points_user_idx on points_transactions(user_id,created_at desc);

alter table profiles enable row level security;
alter table resources enable row level security;
alter table borrowings enable row level security;
alter table campaigns enable row level security;
alter table campaign_contributions enable row level security;
alter table lifecycle_events enable row level security;
alter table points_transactions enable row level security;
alter table saved_resources enable row level security;

create policy "public can view available resources" on resources for select using (availability_status = 'Available' or auth.uid() = owner_id);
create policy "users create own resources" on resources for insert with check (auth.uid() = owner_id);
create policy "owners update resources" on resources for update using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
create policy "owners delete resources" on resources for delete using (auth.uid() = owner_id);
create policy "public can view campaigns" on campaigns for select using (true);
create policy "organizers manage campaigns" on campaigns for all using (auth.uid() = organizer_id) with check (auth.uid() = organizer_id);
create policy "participants view borrowings" on borrowings for select using (auth.uid() in (owner_id,borrower_id));
create policy "borrowers create requests" on borrowings for insert with check (auth.uid() = borrower_id and borrower_id <> owner_id);
create policy "participants update borrowings" on borrowings for update using (auth.uid() in (owner_id,borrower_id));
create policy "participants view contributions" on campaign_contributions for select using (true);
create policy "users create contributions" on campaign_contributions for insert with check (auth.uid() = contributor_id);
create policy "users manage own contributions" on campaign_contributions for update using (auth.uid() = contributor_id);
create policy "participants view lifecycle" on lifecycle_events for select using (true);
create policy "users view own points" on points_transactions for select using (auth.uid() = user_id);
create policy "users view leaderboard profiles" on profiles for select using (true);
create policy "users manage own profile" on profiles for update using (auth.uid() = id) with check (auth.uid() = id);
create policy "users manage own saved resources" on saved_resources for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

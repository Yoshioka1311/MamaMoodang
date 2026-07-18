create extension if not exists "pgcrypto";
create extension if not exists "pg_trgm";

create table if not exists public.knowledge_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.knowledge_topics (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category_id uuid references public.knowledge_categories(id) on delete set null,
  keywords text[] not null default '{}',
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid not null references public.knowledge_topics(id) on delete cascade,
  role text not null check (role in ('user', 'assistant', 'system')),
  message text not null,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.admin_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'admin' check (role in ('admin', 'reviewer')),
  created_at timestamptz not null default now()
);

insert into public.knowledge_categories (id, name, description)
values
  ('00000000-0000-0000-0000-000000000101', 'Gestational Diabetes', 'Core GDM guidance and safety boundaries.'),
  ('00000000-0000-0000-0000-000000000102', 'Nutrition', 'Food, meal planning, GI, and daily nutrition support.'),
  ('00000000-0000-0000-0000-000000000103', 'Mental Health', 'Emotional support and non-diagnostic coping guidance.'),
  ('00000000-0000-0000-0000-000000000104', 'Environmental Health', 'PM2.5, heat index, hydration, and safety messaging.'),
  ('00000000-0000-0000-0000-000000000105', 'Buddy Personality', 'Tone, companion behavior, and chatbot style rules.'),
  ('00000000-0000-0000-0000-000000000106', 'System Prompts', 'Internal prompts, safety policies, and response constraints.')
on conflict (id) do nothing;

drop index if exists public.knowledge_topics_search_idx;
drop index if exists public.chat_messages_search_idx;

create index if not exists knowledge_topics_title_search_idx
  on public.knowledge_topics
  using gin (title gin_trgm_ops);

create index if not exists chat_messages_search_idx
  on public.chat_messages
  using gin (message gin_trgm_ops);

create index if not exists chat_messages_topic_created_idx
  on public.chat_messages (topic_id, created_at);

create or replace function public.touch_knowledge_topic()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.knowledge_topics
  set updated_at = now()
  where id = new.topic_id;
  return new;
end;
$$;

drop trigger if exists chat_messages_touch_topic on public.chat_messages;
create trigger chat_messages_touch_topic
after insert on public.chat_messages
for each row execute function public.touch_knowledge_topic();

alter table public.knowledge_categories enable row level security;
alter table public.knowledge_topics enable row level security;
alter table public.chat_messages enable row level security;
alter table public.admin_profiles enable row level security;

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.admin_profiles
    where user_id = auth.uid() and role in ('admin', 'reviewer')
  );
$$;

grant usage on schema public to anon, authenticated;
grant select on public.knowledge_categories to anon, authenticated;
grant select, insert, update on public.knowledge_topics to anon, authenticated;
grant select, insert on public.chat_messages to anon, authenticated;
grant select, insert, update, delete on public.admin_profiles to authenticated;

drop policy if exists "admin read categories" on public.knowledge_categories;
drop policy if exists "admin write categories" on public.knowledge_categories;
drop policy if exists "admin read topics" on public.knowledge_topics;
drop policy if exists "admin write topics" on public.knowledge_topics;
drop policy if exists "admin read messages" on public.chat_messages;
drop policy if exists "admin write messages" on public.chat_messages;
drop policy if exists "public read categories" on public.knowledge_categories;
drop policy if exists "public read topics" on public.knowledge_topics;
drop policy if exists "public create topics" on public.knowledge_topics;
drop policy if exists "public update topics" on public.knowledge_topics;
drop policy if exists "public read messages" on public.chat_messages;
drop policy if exists "public create messages" on public.chat_messages;
drop policy if exists "admin read own profile" on public.admin_profiles;
drop policy if exists "admin manage profiles" on public.admin_profiles;

create policy "public read categories" on public.knowledge_categories
  for select using (true);

create policy "public read topics" on public.knowledge_topics
  for select using (true);

create policy "public create topics" on public.knowledge_topics
  for insert with check (true);

create policy "public update topics" on public.knowledge_topics
  for update using (true) with check (true);

create policy "public read messages" on public.chat_messages
  for select using (true);

create policy "public create messages" on public.chat_messages
  for insert with check (true);

create policy "admin read own profile" on public.admin_profiles
  for select using (user_id = auth.uid() or public.is_admin());

create policy "admin manage profiles" on public.admin_profiles
  for all using (public.is_admin()) with check (public.is_admin());

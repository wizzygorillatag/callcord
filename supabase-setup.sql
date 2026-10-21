-- Run this entire script in Supabase Dashboard > SQL Editor.
create table if not exists public.messages (
  id bigint generated always as identity primary key,
  room text not null check (length(room) between 1 and 40),
  channel text not null check (channel in ('general','memes','gaming')),
  username text not null check (length(username) between 1 and 24),
  content text not null check (length(content) between 1 and 1500),
  created_at timestamptz not null default now()
);

alter table public.messages enable row level security;

-- DEMO MODE: anyone who has your public site can read and post in chat.
-- For a private community, add Supabase Auth and restrict these policies to authenticated users.
create policy "Anyone can read chat messages"
on public.messages for select to anon, authenticated using (true);

create policy "Anyone can post chat messages"
on public.messages for insert to anon, authenticated with check (
  length(trim(username)) between 1 and 24
  and length(trim(content)) between 1 and 1500
  and room ~ '^[a-z0-9_-]{1,40}$'
  and channel in ('general','memes','gaming')
);

-- Enable Realtime for new message broadcasts.
alter publication supabase_realtime add table public.messages;

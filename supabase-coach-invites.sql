-- Deckside: let a head coach invite assistant coaches to share their team.
-- Run once in Supabase: SQL Editor > New query > paste all of this > Run.
-- Safe to run again; it skips anything already there.

create table if not exists public.deckside_members (
  owner_id     uuid not null references auth.users(id) on delete cascade,
  member_email text not null,
  owner_name   text,
  created_at   timestamptz not null default now(),
  primary key (owner_id, member_email)
);
alter table public.deckside_members enable row level security;
grant select, insert, delete on public.deckside_members to authenticated;

-- true when the signed-in user was invited by this head coach
create or replace function public.deckside_is_coach(owner uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.deckside_members m
    where m.owner_id = owner
      and m.member_email = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

do $$ begin
  -- the head coach manages their own invite list
  if not exists (select 1 from pg_policies where tablename = 'deckside_members' and policyname = 'owner manages coaches') then
    create policy "owner manages coaches" on public.deckside_members
      for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
  end if;
  -- an invited coach can see their invite and leave the team
  if not exists (select 1 from pg_policies where tablename = 'deckside_members' and policyname = 'coach sees invite') then
    create policy "coach sees invite" on public.deckside_members
      for select using (member_email = lower(coalesce(auth.jwt() ->> 'email', '')));
  end if;
  if not exists (select 1 from pg_policies where tablename = 'deckside_members' and policyname = 'coach can leave') then
    create policy "coach can leave" on public.deckside_members
      for delete using (member_email = lower(coalesce(auth.jwt() ->> 'email', '')));
  end if;

  -- invited coaches can read and edit the head coach's Deckside data
  if not exists (select 1 from pg_policies where tablename = 'deckside_docs' and policyname = 'coaches read team') then
    create policy "coaches read team" on public.deckside_docs
      for select using (public.deckside_is_coach(user_id));
  end if;
  if not exists (select 1 from pg_policies where tablename = 'deckside_docs' and policyname = 'coaches add team') then
    create policy "coaches add team" on public.deckside_docs
      for insert with check (public.deckside_is_coach(user_id));
  end if;
  if not exists (select 1 from pg_policies where tablename = 'deckside_docs' and policyname = 'coaches edit team') then
    create policy "coaches edit team" on public.deckside_docs
      for update using (public.deckside_is_coach(user_id)) with check (public.deckside_is_coach(user_id));
  end if;
  if not exists (select 1 from pg_policies where tablename = 'deckside_docs' and policyname = 'coaches delete team') then
    create policy "coaches delete team" on public.deckside_docs
      for delete using (public.deckside_is_coach(user_id));
  end if;
end $$;

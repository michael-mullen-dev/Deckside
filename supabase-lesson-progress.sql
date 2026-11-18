-- Deckside: private family pages for the Private Lessons team.
-- Each lesson swimmer can get a private link. The family's page can read only that one swimmer's
-- summary (first name, lesson times, lesson notes), and only with the exact link.
-- Run once in Supabase: SQL Editor > New query > paste all of this > Run.
-- Safe to run again; it skips anything already there.

create table if not exists public.lesson_progress (
  token       text primary key check (length(token) >= 24),
  owner_id    uuid not null references auth.users(id) on delete cascade,
  swimmer_id  text not null,
  data        jsonb not null default '{}'::jsonb,
  updated_at  timestamptz not null default now()
);
create index if not exists lesson_progress_owner on public.lesson_progress (owner_id);

alter table public.lesson_progress enable row level security;
revoke all on public.lesson_progress from anon;
grant select, insert, update, delete on public.lesson_progress to authenticated;

do $$ begin
  -- only the coach who made a family page can see, change or remove it
  if not exists (select 1 from pg_policies where tablename = 'lesson_progress' and policyname = 'coach manages family pages') then
    create policy "coach manages family pages" on public.lesson_progress
      for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
  end if;
end $$;

-- the family page calls this with the token from its link and gets back that one swimmer's summary
create or replace function public.get_lesson_progress(t text)
returns jsonb language sql stable security definer set search_path = public as $$
  select p.data || jsonb_build_object('updated', p.updated_at)
  from public.lesson_progress p
  where p.token = t;
$$;
revoke all on function public.get_lesson_progress(text) from public;
grant execute on function public.get_lesson_progress(text) to anon, authenticated;

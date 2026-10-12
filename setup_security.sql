-- マリポケ共有版：areasテーブルを許可ユーザーだけに限定する設定
-- SQL Editorでプロジェクト管理者として一度だけ実行してください。
-- 実行後、area_accessに許可する2人のauth.users.idを追加します（README参照）。

create table if not exists public.area_access (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.area_access enable row level security;
revoke all on table public.area_access from anon, authenticated;
grant select on table public.area_access to authenticated;

drop policy if exists "Users can read own area access" on public.area_access;
create policy "Users can read own area access"
on public.area_access for select to authenticated
using (user_id = auth.uid());

alter table public.areas enable row level security;

drop policy if exists "Authenticated users can read areas" on public.areas;
drop policy if exists "Authenticated users can insert areas" on public.areas;
drop policy if exists "Authenticated users can update areas" on public.areas;
drop policy if exists "Authenticated users can delete areas" on public.areas;

create policy "Allowed members can read areas"
on public.areas for select to authenticated
using (exists (select 1 from public.area_access aa where aa.user_id = auth.uid()));

create policy "Allowed members can insert areas"
on public.areas for insert to authenticated
with check (exists (select 1 from public.area_access aa where aa.user_id = auth.uid()));

create policy "Allowed members can update areas"
on public.areas for update to authenticated
using (exists (select 1 from public.area_access aa where aa.user_id = auth.uid()))
with check (exists (select 1 from public.area_access aa where aa.user_id = auth.uid()));

create policy "Allowed members can delete areas"
on public.areas for delete to authenticated
using (exists (select 1 from public.area_access aa where aa.user_id = auth.uid()));

grant select, insert, update, delete on public.areas to authenticated;
grant usage, select on sequence public.areas_id_seq to authenticated;

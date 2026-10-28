-- Run in a NEW, DEDICATED Supabase project (not the existing prints/orders project).
-- Create the two users manually in Authentication > Users first, then add their user UUIDs to gallery_admins.
create table if not exists public.gallery_admins (user_id uuid primary key references auth.users(id) on delete cascade);
alter table public.gallery_admins enable row level security;
create policy "Read own admin membership" on public.gallery_admins for select to authenticated using (user_id=auth.uid());
create table if not exists public.photos (id uuid primary key default gen_random_uuid(),owner_id uuid not null references public.gallery_admins(user_id),title text not null check(length(title) between 1 and 120),category text not null check(length(category) between 1 and 60),description text not null default '' check(length(description)<=1500),price integer not null default 0 check(price>=0),preview_path text not null,published boolean not null default false,created_at timestamptz not null default now());
alter table public.photos enable row level security;
create policy "Public sees published" on public.photos for select to anon,authenticated using (published or owner_id=auth.uid());
create policy "Admins insert own" on public.photos for insert to authenticated with check(owner_id=auth.uid() and exists(select 1 from public.gallery_admins a where a.user_id=auth.uid()));
create policy "Admins update own" on public.photos for update to authenticated using(owner_id=auth.uid()) with check(owner_id=auth.uid());
create policy "Admins delete own" on public.photos for delete to authenticated using(owner_id=auth.uid());
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('previews','previews',true,8388608,array['image/jpeg','image/png','image/webp']) on conflict(id) do nothing;
create policy "Public reads preview images" on storage.objects for select to anon,authenticated using(bucket_id='previews');
create policy "Admins upload into own folder" on storage.objects for insert to authenticated with check(bucket_id='previews' and (storage.foldername(name))[1]=auth.uid()::text and exists(select 1 from public.gallery_admins a where a.user_id=auth.uid()));
create policy "Admins remove own previews" on storage.objects for delete to authenticated using(bucket_id='previews' and (storage.foldername(name))[1]=auth.uid()::text);
-- After creating users, run for each UUID (replace placeholder):
-- insert into public.gallery_admins(user_id) values ('USER_UUID_HERE');
-- Keep Auth > Providers > Email enabled; disable public sign-ups in Auth settings.

-- Jalankan di Supabase: SQL Editor > New query > paste > Run

create table profiles (
  id uuid primary key references auth.users on delete cascade,
  nama text,
  email text,
  role text not null default 'pending'  -- pending | guru | osis | bk | admin
);

create table violations (
  id bigint generated always as identity primary key,
  nis text,
  nama_siswa text not null,
  kelas text not null,
  jenis text not null,
  poin int not null default 0,
  catatan text,
  tanggal date not null default current_date,
  pelapor_id uuid default auth.uid(),
  pelapor_nama text,
  created_at timestamptz default now()
);

alter table profiles enable row level security;
alter table violations enable row level security;

create function my_role() returns text
language sql security definer stable set search_path = public
as $$ select role from profiles where id = auth.uid() $$;

-- akun baru otomatis dibuat dengan role 'pending' sampai disetujui admin
create function handle_new_user() returns trigger
language plpgsql security definer set search_path = public
as $$
begin
  insert into profiles (id, nama, email)
  values (new.id, coalesce(new.raw_user_meta_data->>'nama', new.email), new.email);
  return new;
end $$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function handle_new_user();

-- profiles
create policy "baca profil sendiri atau admin" on profiles
  for select using (id = auth.uid() or my_role() = 'admin');
create policy "admin ubah role" on profiles
  for update using (my_role() = 'admin');

-- violations
create policy "guru osis admin boleh input" on violations
  for insert with check (my_role() in ('guru','osis','admin') and pelapor_id = auth.uid());
create policy "admin bk lihat semua, pelapor lihat miliknya" on violations
  for select using (my_role() in ('admin','bk') or pelapor_id = auth.uid());
create policy "admin hapus" on violations
  for delete using (my_role() = 'admin');

-- hanya admin yang boleh mengubah (revisi) catatan
create policy "admin ubah catatan" on violations
  for update using (my_role() = 'admin') with check (my_role() = 'admin');

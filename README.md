# Catatan Pelanggaran Siswa

Hosting gratis di **GitHub Pages**, login dan database gratis di **Supabase**.

## Isi folder
- `index.html` : seluruh website
- `supabase.sql` : tabel database dan aturan keamanan
- `README.md` : panduan ini

## Peran
| Peran | Bisa apa |
|---|---|
| guru, osis | Login, input pelanggaran, lihat riwayat input sendiri |
| bk | Lihat rekap, pengecekan mingguan, unduh CSV |
| admin | Semua fitur BK, input, **ubah dan hapus catatan (hanya admin)**, atur peran akun |
| pending | Akun baru, belum bisa apa-apa sampai admin menyetujui |

## Aturan pengecekan mingguan (tab "Pengecekan mingguan")
Minggu dihitung Senin sampai Minggu.
1. Lebih dari 2 pelanggaran dalam seminggu: **Peringatan 1**.
2. Minggu berikutnya tanpa pelanggaran: dianggap berubah, tidak dipanggil. Jika melanggar lagi: **Peringatan 2**.
3. Minggu berikutnya masih melanggar: **SP**.

Batas 2 bisa diubah lewat `const BATAS` di `index.html`.

## Alur upload (urut)

### A. Database (Supabase)
1. Daftar di https://supabase.com, **New project** (simpan password database).
2. Buka **SQL Editor > New query**, paste seluruh isi `supabase.sql`, klik **Run**.
3. Buka **Project Settings > API**, salin **Project URL** dan **anon public key**.
4. Opsional saat uji coba: **Authentication > Providers > Email**, matikan "Confirm email".

### B. Isi konfigurasi
Di `index.html`, ganti dua baris ini dengan milik Anda:
```js
const SUPABASE_URL = "https://xxxx.supabase.co";
const SUPABASE_ANON_KEY = "kunci-anon-anda";
```
Kunci anon memang boleh publik. Keamanan data dijaga aturan RLS di `supabase.sql`. Jangan pernah memasang kunci `service_role` di sini.

### C. Upload ke GitHub
**Cara 1, lewat browser:** buat repository baru (public) di github.com, klik **Add file > Upload files**, tarik `index.html`, `supabase.sql`, `README.md`, lalu **Commit changes**.

**Cara 2, lewat Git:**
```bash
cd pelanggaran-siswa
git init
git add .
git commit -m "Website pelanggaran siswa"
git branch -M main
git remote add origin https://github.com/USERNAME/NAMA-REPO.git
git push -u origin main
```

### D. Aktifkan GitHub Pages
**Settings > Pages > Source: Deploy from a branch > Branch: main, folder / (root) > Save.** Tunggu 1-2 menit, alamat website muncul di halaman itu (`https://USERNAME.github.io/NAMA-REPO/`).

### E. Sambungkan Supabase ke alamat website
**Authentication > URL Configuration**: isi **Site URL** dengan alamat GitHub Pages tadi.

### F. Jadikan diri sendiri admin
1. Buka website, daftar dengan email Anda.
2. Di Supabase **SQL Editor**, jalankan:
```sql
update profiles set role = 'admin' where email = 'EMAIL_ANDA@contoh.com';
```
3. Muat ulang website. Tab **Kelola akun** muncul; setujui guru, OSIS, dan BK dari sana.

### G. Uji sebelum dipakai
1. Daftar akun guru, setujui lewat admin, input 3 pelanggaran untuk satu siswa pada minggu yang sama.
2. Masuk sebagai admin: cek tab **Rekap data** dan **Pengecekan mingguan** (siswa itu harus berstatus Peringatan 1).
3. Coba tombol **Ubah** dan **Hapus** (hanya muncul untuk admin).

## Memperbarui website
Ubah `index.html`, lalu `git add . && git commit -m "update" && git push`. GitHub Pages memperbarui sendiri dalam 1-2 menit.

## Jika SQL versi lama sudah dijalankan
Jalankan hanya ini untuk menambah izin ubah khusus admin:
```sql
create policy "admin ubah catatan" on violations
  for update using (my_role() = 'admin') with check (my_role() = 'admin');
```

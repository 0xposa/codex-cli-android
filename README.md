# Codex CLI Android (Termux)

Installer otomatis **OpenAI Codex CLI** (`@openai/codex`) untuk Android melalui **Termux** tanpa memerlukan akses root.

Repository: [0xposa/codex-cli-android](https://github.com/0xposa/codex-cli-android)

---

## ⚡ Instalasi Cepat via `curl`

Buka Termux di ponsel Android Anda, lalu jalankan satu baris perintah berikut:

```bash
curl -fsSL https://raw.githubusercontent.com/0xposa/codex-cli-android/main/install.sh | bash
```

Atau jika ingin mengunduh skrip terlebih dahulu:

```bash
curl -fsSL https://raw.githubusercontent.com/0xposa/codex-cli-android/main/install.sh -o install.sh && bash install.sh
```

---

## 🎯 Fitur & Keunggulan

* **Tanpa Root:** Menggunakan `proot-distro` Debian (`codex-debian`) terisolasi agar paket Node.js, Python, git, dan npm resmi `@openai/codex` berjalan stabil di Android.
* **Integrasi Workspace Penuh:** Home directory Termux (`$HOME`) di-bind langsung ke dalam container (`/termux-home`), sehingga proyek dan berkas lokal tersimpan di penyimpanan internal Anda.
* **Perintah Native `codex`:** Menambahkan wrapper di `$PREFIX/bin/codex` sehingga Anda bisa mengetik `codex` dari direktori proyek mana saja di Termux.
* **Variasi Suara "Hidup Jokowi":** Setelah instalasi berhasil 100%, sistem akan otomatis memutar efek suara kemenangan *"Hidup Jokowi"* yang ada di folder Download ponsel.
  - Diputar tepat **1 kali (single play)**.
  - Dijamin **tanpa looping** menggunakan flag `--loop=no`.

---

## 🚀 Panduan Penggunaan

### 1. Login Akun OpenAI / Codex
Setelah instalasi selesai, jalankan autentikasi perangkat:

```bash
codex login --device-auth
```

Buka URL yang ditampilkan di browser ponsel dan masukkan kode autentikasi.

### 2. Menjalankan Codex CLI di Proyek
Masuk ke direktori proyek Anda:

```bash
cd ~/proyek-anda
codex
```

Atau jalankan instruksi langsung:
```bash
codex "Buatkan REST API sederhana dengan Express.js"
```

---

## 🔊 Catatan Efek Suara

Skrip installer otomatis mendeteksi berkas audio di direktori:
- `/sdcard/Download/` atau `~/storage/shared/Download/`
- Jika berkas lokal belum ada, skrip akan mengambil cadangan dari direktori `assets/hidup-jokowi.mp3` di repositori ini.
- Menggunakan `mpv` (atau `termux-media-player`) dengan konfigurasi non-loop sehingga hanya bersuara satu kali saat instalasi selesai.

---

## 📄 Lisensi

[MIT License](LICENSE)

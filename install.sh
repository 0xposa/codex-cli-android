#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Project: Codex CLI Android (Termux)
# Repository: https://github.com/0xposa/codex-cli-android
# Deskripsi: Installer otomatis OpenAI Codex CLI untuk Termux di Android.
# ==============================================================================

set -Eeuo pipefail
trap 'printf "\n❌ Instalasi gagal pada baris %s. Periksa log di atas, lalu jalankan ulang.\n" "$LINENO" >&2' ERR

die() { printf '❌ Error: %s\n' "$*" >&2; exit 1; }

# Validasi environment Termux
command -v pkg >/dev/null 2>&1 || die 'Jalankan script ini di dalam aplikasi Termux Android.'
[[ ${PREFIX:-} == /data/data/com.termux/files/usr ]] || die 'Installer harus dijalankan di Termux utama (com.termux).'
[[ $(id -u) != 0 ]] || die 'Jalankan sebagai user Termux standar, jangan gunakan root/su.'

case $(uname -m) in
  aarch64|x86_64) ;;
  *) die 'Arsitektur CPU tidak didukung. Hanya mendukung Android 64-bit (ARM64 / x86_64).' ;;
esac

target="$PREFIX/bin/codex"
if [[ -e "$target" || -L "$target" ]]; then
  if [[ -L "$target" ]] || ! grep -q '^# codex-termux-managed-launcher$' "$target" 2>/dev/null; then
    die 'Perintah "codex" sudah ada dan bukan dikelola installer ini. Hapus atau pindahkan instalasi lama terlebih dahulu.'
  fi
fi

printf '\n===================================================\n'
printf '🚀 Memulai Instalasi Codex CLI Android\n'
printf '===================================================\n'

printf '\n[1/4] Memperbarui paket Termux & memasang dependensi (proot-distro, mpv, curl)...\n'
pkg update -y
pkg install -y proot-distro mpv curl

distro="codex-debian"
rootfs="$PREFIX/var/lib/proot-distro/installed-rootfs/$distro"

printf '\n[2/4] Menyiapkan lingkungan Debian untuk Codex CLI...\n'
if [[ ! -d "$rootfs" ]]; then
  proot-distro install --override-alias "$distro" debian
else
  printf 'Lingkungan container "%s" sudah ada, memperbarui isi...\n' "$distro"
fi

printf '\n[3/4] Memasang Node.js, Git, ripgrep, dan @openai/codex di dalam container...\n'
proot-distro login "$distro" -- bash -lc '
  set -euo pipefail
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y ca-certificates curl nodejs npm git ripgrep
  node -e '\''if (Number(process.versions.node.split(".")[0]) < 18) { console.error("Node.js 18+ diperlukan; perbarui Debian terlebih dahulu."); process.exit(1); }'\''
  npm install -g @openai/codex@latest
  printf "Versi Codex terpasang: "
  codex --version
'

printf '\n[4/4] Membuat launcher perintah "codex" di Termux...\n'
launcher=$(mktemp "$PREFIX/bin/.codex-launcher.XXXXXX")
{
  printf '#!%s/bin/bash\n' "$PREFIX"
  cat <<'LAUNCHER'
# codex-termux-managed-launcher
set -euo pipefail
case "$PWD/" in
  "$HOME/"*) workdir="/termux-home${PWD#"$HOME"}" ;;
  *) printf 'Jalankan codex dari direktori di dalam home Termux ($HOME): %s\n' "$HOME" >&2; exit 1 ;;
esac
exec proot-distro login --bind "$HOME:/termux-home" --work-dir "$workdir" codex-debian -- /usr/local/bin/codex "$@"
LAUNCHER
} > "$launcher"
chmod 755 "$launcher"
mv -- "$launcher" "$target"

# Fungsi memainkan sound kemenangan "Hidup Jokowi" (1 kali putar, tanpa loop)
play_sound_once() {
  local sound_file=""
  local candidates=(
    "/sdcard/Download/assets_sounds_antek-asing.mp3"
    "/sdcard/Download/hidup-jokowi.mp3"
    "$HOME/storage/shared/Download/assets_sounds_antek-asing.mp3"
    "$HOME/storage/shared/Download/hidup-jokowi.mp3"
  )

  for candidate in "${candidates[@]}"; do
    if [[ -f "$candidate" ]]; then
      sound_file="$candidate"
      break
    fi
  done

  # Jika belum ditemukan, cari file dengan kata 'jokowi' atau 'antek-asing' di Download
  if [[ -z "$sound_file" ]]; then
    sound_file=$(find /sdcard/Download "$HOME/storage/shared/Download" -maxdepth 2 -type f \( -iname "*jokowi*.mp3" -o -iname "*antek-asing*.mp3" \) 2>/dev/null | head -n 1 || true)
  fi

  # Fallback: unduh asset jika file lokal tidak ditemukan
  if [[ -z "$sound_file" || ! -f "$sound_file" ]]; then
    local tmp_sound="/tmp/hidup-jokowi.mp3"
    if curl -fsSL "https://raw.githubusercontent.com/0xposa/codex-cli-android/main/assets/hidup-jokowi.mp3" -o "$tmp_sound" 2>/dev/null; then
      sound_file="$tmp_sound"
    fi
  fi

  if [[ -n "$sound_file" && -f "$sound_file" ]]; then
    printf '\n🔊 Memutar efek suara keberhasilan: Hidup Jokowi! (1x putar, no loop)...\n'
    if command -v mpv >/dev/null 2>&1; then
      # --loop=no memastikan hanya berputar sekali dan berhenti
      mpv --no-terminal --really-quiet --loop=no "$sound_file" >/dev/null 2>&1 || true
    elif command -v termux-media-player >/dev/null 2>&1; then
      termux-media-player stop >/dev/null 2>&1 || true
      termux-media-player play "$sound_file" >/dev/null 2>&1 || true
    elif command -v paplay >/dev/null 2>&1; then
      paplay "$sound_file" >/dev/null 2>&1 || true
    fi
  fi
}

play_sound_once

printf '\n===================================================\n'
printf '🎉 Codex CLI Android BERHASIL DIINSTALL!\n'
printf '===================================================\n'
printf 'Cara memulai:\n'
printf '  1. cd ~\n'
printf '  2. codex login --device-auth\n'
printf '  3. Buka tautan login yang muncul di browser HP Anda.\n'
printf '  4. Buat / masuk ke folder proyek, lalu jalankan:\n'
printf '     codex\n'
printf '===================================================\n'

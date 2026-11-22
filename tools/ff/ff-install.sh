#!/usr/bin/env bash
set -euo pipefail

# Renkler
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
error() { echo -e "${RED}[HATA]${NC} $1" >&2; exit 1; }

# 1. Dağıtım Tespiti ve Paket Kurulumu
install_dependencies() {
    if [[ ! -f /etc/os-release ]]; then
        error "/etc/os-release bulunamadı. Desteklenmeyen sistem."
    fi
    
    # shellcheck disable=SC1091
    source /etc/os-release
    local distro="${ID:-}"
    local like="${ID_LIKE:-}"
    
    info "Sistem tespit edildi: ${PRETTY_NAME:-$distro}"
    
    if [[ "$distro" == "fedora" || "$like" == *"fedora"* ]]; then
        info "Fedora paketleri kuruluyor..."
        sudo dnf install -y plocate fzf bat file wl-clipboard xclip
        elif [[ "$distro" == "ubuntu" || "$distro" == "debian" || "$like" == *"debian"* || "$like" == *"ubuntu"* ]]; then
        info "Ubuntu/Debian paketleri kuruluyor..."
        sudo apt-get update -qq
        sudo apt-get install -y plocate fzf bat file wl-clipboard xclip
    else
        error "Bu script yalnızca Fedora ve Ubuntu/Debian sistemlerini destekler (Tespit edilen: $distro)."
    fi
}

# 2. plocate Veritabanını Güncelle
init_plocate() {
    info "plocate dosya indeksi güncelleniyor (ilk seferde birkaç saniye sürebilir)..."
    sudo updatedb
    ok "plocate indeksi hazır."
}

# 3. /usr/local/bin/ff Komutunu Oluştur
install_ff_binary() {
    info "/usr/local/bin/ff kuruluyor..."
    
    sudo tee /usr/local/bin/ff > /dev/null << 'EOF'
#!/usr/bin/env bash
set -uo pipefail

# Ubuntu'da 'batcat', Fedora'da 'bat' uyumluluğu
if command -v bat >/dev/null 2>&1; then
    BAT_CMD="bat"
elif command -v batcat >/dev/null 2>&1; then
    BAT_CMD="batcat"
else
    BAT_CMD="cat"
fi

# Wayland / X11 pano uyumluluğu
if [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy >/dev/null 2>&1; then
    CLIP_CMD="wl-copy"
elif command -v xclip >/dev/null 2>&1; then
    CLIP_CMD="xclip -selection clipboard"
else
    CLIP_CMD="cat >/dev/null"
fi

QUERY="${1:-*}"

target=$(plocate -i "$QUERY" | fzf \
    --height=60% \
    --layout=reverse \
    --border=rounded \
    --border-label=" 🔍 Dosya & Klasör Arama " \
    --border-label-pos=3 \
    --margin=1 \
    --padding=0,1 \
    --info=inline-right \
    --prompt="❯ " \
    --pointer="▶" \
    --marker="✓" \
    --header="ENTER: Klasörde Aç  │  CTRL-O: Uygulamada Aç  │  CTRL-Y: Yolu Kopyala  │  CTRL-/: Önizleme" \
    --header-first \
    --preview-window="down,35%,rounded,border-top" \
    --preview-label=" Önizleme " \
    --preview "[[ -d {} ]] && ls -lhF --color=always {} || (file -b --mime-encoding {} | grep -q binary && echo -e '\033[1;36mDosya Bilgisi:\033[0m\n'\$(file -b {})'\n\n\033[1;36mBoyut & Tarih:\033[0m\n'\$(ls -lh {}) || $BAT_CMD -n --color=always --line-range :40 {})" \
    --color="bg+:#1e293b,fg+:#f8fafc,hl:#2dd4bf,hl+:#2dd4bf,border:#475569,label:#2dd4bf,header:#94a3b8,prompt:#2dd4bf,pointer:#2dd4bf,info:#64748b" \
    --bind "ctrl-/:toggle-preview" \
    --bind "ctrl-o:execute-silent(xdg-open {} >/dev/null 2>&1 &)+abort" \
    --bind "ctrl-y:execute-silent(echo -n {} | $CLIP_CMD)+abort")

if [[ -n "$target" ]]; then
    if command -v nautilus >/dev/null 2>&1; then
        nautilus --select "$target" >/dev/null 2>&1 & disown
    else
        # Nautilus yoksa (ör. KDE/XFCE) üst klasörü varsayılan dosya yöneticisiyle aç
        xdg-open "$(dirname "$target")" >/dev/null 2>&1 & disown
    fi
fi
EOF
    
    sudo chmod +x /usr/local/bin/ff
    ok "ff komutu /usr/local/bin/ff konumuna kuruldu."
}

main() {
    install_dependencies
    init_plocate
    install_ff_binary
    echo ""
    ok "Kurulum tamamlandı! Kullanım: ff <aranacak_kelime>"
}

main "$@"
#!/usr/bin/env bash
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
error() { echo -e "${RED}[HATA]${NC} $1" >&2; exit 1; }

BIN_PATH="/usr/local/bin/ff"

has_gui() {
    [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]] || command -v nautilus >/dev/null 2>&1
}

uninstall_ff() {
    if [[ -f "$BIN_PATH" ]]; then
        info "$BIN_PATH kaldırılıyor..."
        sudo rm -f "$BIN_PATH"
        ok "ff başarıyla kaldırıldı. (Sistem paketleri olan plocate, fzf ve bat korunmuştur.)"
    else
        info "ff zaten kurulu değil ($BIN_PATH bulunamadı)."
    fi
}

install_dependencies() {
    [[ -f /etc/os-release ]] || error "/etc/os-release bulunamadı."
    # shellcheck disable=SC1091
    source /etc/os-release
    local distro="${ID:-}"
    local like="${ID_LIKE:-}"
    
    local pkgs=(plocate fzf bat file)
    if has_gui; then
        info "Masaüstü ortamı tespit edildi; pano araçları dahil ediliyor."
        pkgs+=(wl-clipboard xclip)
    else
        info "Sunucu (headless) ortamı tespit edildi; sadece CLI paketleri kurulacak."
    fi
    
    if [[ "$distro" == "fedora" || "$like" == *"fedora"* ]]; then
        sudo dnf install -y "${pkgs[@]}"
        elif [[ "$distro" == "ubuntu" || "$distro" == "debian" || "$like" == *"debian"* || "$like" == *"ubuntu"* ]]; then
        sudo apt-get update -qq
        sudo apt-get install -y "${pkgs[@]}"
    else
        error "Desteklenmeyen dağıtım: $distro"
    fi
}

init_plocate() {
    info "plocate dosya indeksi güncelleniyor..."
    sudo updatedb
    ok "plocate indeksi hazır."
}

install_ff_binary() {
    info "$BIN_PATH kuruluyor..."
    
    sudo tee "$BIN_PATH" > /dev/null << 'EOF'
#!/usr/bin/env bash
set -uo pipefail

if command -v bat >/dev/null 2>&1; then
    BAT_CMD="bat"
elif command -v batcat >/dev/null 2>&1; then
    BAT_CMD="batcat"
else
    BAT_CMD="cat"
fi

EDITOR_CMD="${EDITOR:-vim}"
QUERY="${1:-*}"

if [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
    if [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy >/dev/null 2>&1; then
        CLIP_CMD="wl-copy"
    elif command -v xclip >/dev/null 2>&1; then
        CLIP_CMD="xclip -selection clipboard"
    else
        CLIP_CMD="cat >/dev/null"
    fi

    HEADER="ENTER: Klasörde Aç  │  CTRL-O: Uygulamada Aç  │  CTRL-E: Editör  │  CTRL-Y: Kopyala  │  CTRL-/: Önizleme"
    EXTRA_BINDS=(
        --bind "ctrl-o:execute-silent(xdg-open {} >/dev/null 2>&1 &)+abort"
        --bind "ctrl-y:execute-silent(echo -n {} | $CLIP_CMD)+abort"
    )
    IS_GUI=1
else
    HEADER="ENTER: Yolu Yazdır  │  CTRL-E: ${EDITOR_CMD} ile Aç  │  CTRL-/: Önizleme"
    EXTRA_BINDS=()
    IS_GUI=0
fi

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
    --header="$HEADER" \
    --header-first \
    --preview-window="down,35%,rounded,border-top" \
    --preview-label=" Önizleme " \
    --preview "[[ -d {} ]] && ls -lhF --color=always {} || (file -b --mime-encoding {} | grep -q binary && echo -e '\033[1;36mDosya Bilgisi:\033[0m\n'\$(file -b {})'\n\n\033[1;36mBoyut & Tarih:\033[0m\n'\$(ls -lh {}) || $BAT_CMD -n --color=always --line-range :40 {})" \
    --color="bg+:#1e293b,fg+:#f8fafc,hl:#2dd4bf,hl+:#2dd4bf,border:#475569,label:#2dd4bf,header:#94a3b8,prompt:#2dd4bf,pointer:#2dd4bf,info:#64748b" \
    --bind "ctrl-/:toggle-preview" \
    --bind "ctrl-e:execute($EDITOR_CMD {} </dev/tty >/dev/tty)+abort" \
    "${EXTRA_BINDS[@]}")

if [[ -n "$target" ]]; then
    if [[ "$IS_GUI" -eq 1 ]]; then
        if command -v nautilus >/dev/null 2>&1; then
            nautilus --select "$target" >/dev/null 2>&1 & disown
        else
            xdg-open "$(dirname "$target")" >/dev/null 2>&1 & disown
        fi
    else
        echo "$target"
    fi
fi
EOF
    
    sudo chmod +x "$BIN_PATH"
    ok "ff komutu $BIN_PATH konumuna kuruldu."
}

main() {
    case "${1:-}" in
        -u|--uninstall)
            uninstall_ff
            exit 0
        ;;
        -h|--help)
            echo "Kullanım: $0 [--uninstall | -u]"
            exit 0
        ;;
        "")
            install_dependencies
            init_plocate
            install_ff_binary
            echo ""
            ok "Kurulum tamamlandı! Kullanım: ff <aranacak_kelime>"
        ;;
        *)
            error "Bilinmeyen parametre: $1 (Kullanım: $0 [--uninstall])"
        ;;
    esac
}

main "$@"
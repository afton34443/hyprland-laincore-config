#!/usr/bin/env bash
# ==============================================================================
#  CAELESTIA PURGE — СКРИПТ ОЧИСТКИ ОТ СТАРОГО МУСОРА
#  Удаляет остатки старых райсов (Rofi, Thunar, Zsh, старые бэкапы и обои).
# ==============================================================================

set -e

# --- ЦВЕТА ---
C_PURP='\033[1;35m'
C_CYAN='\033[1;36m'
C_GREEN='\033[1;32m'
C_RED='\033[1;31m'
C_YEL='\033[1;33m'
C_DIM='\033[2m'
C_RST='\033[0m'

clear
echo -e "${C_PURP}"
cat << "EOF"
   ____urge         _       
  |  _ \ _   _ _ __| |__  __ 
  | |_) | | | | '__| '_ \/ _ \
  |  __/| |_| | |  | | | |  __/
  |_|    \__,_|_|  |_| |_|\___|[ DEEP CLEANING UTILITY ]
EOF
echo -e "${C_RST}\n"

if[ "$EUID" -eq 0 ]; then
    echo -e "${C_RED}✗ Ошибка: Не запускай от root!${C_RST}"
    exit 1
fi

echo -e "${C_YEL}ВНИМАНИЕ: Этот скрипт удалит:${C_RST}"
echo -e "  ${C_DIM}- Пакеты: rofi, rofi-wayland, thunar, wlogout, zsh, polkit-kde-agent${C_RST}"
echo -e "  ${C_DIM}- Конфиги: ~/.config/rofi, ~/.config/wlogout, ~/.config/thunar${C_RST}"
echo -e "  ${C_DIM}- Бэкапы: ~/.config-backup-lain-*, ~/.config-backup-old${C_RST}"
echo -e "  ${C_DIM}- Файлы: ~/.zshrc, ~/.zsh_history, старые обои в ~/Pictures${C_RST}"
echo ""
read -rp "$(echo -e ${C_CYAN}Вы уверены, что хотите продолжить? [y/N]: ${C_RST})" CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo -e "${C_RED}Очистка отменена.${C_RST}"; exit 0; }

echo -e "\n${C_CYAN}▸ Шаг 1: Удаление устаревших и ненужных пакетов...${C_RST}"

TRASH_PKGS=(
    rofi
    rofi-wayland
    thunar
    thunar-volman
    thunar-archive-plugin
    wlogout
    zsh
    zsh-syntax-highlighting
    zsh-autosuggestions
    polkit-kde-agent
    grimblast-git
)

for pkg in "${TRASH_PKGS[@]}"; do
    if pacman -Qs "^${pkg}$" > /dev/null; then
        sudo pacman -Rns --noconfirm "$pkg" 2>/dev/null || yay -Rns --noconfirm "$pkg" 2>/dev/null || true
        echo -e "  ${C_GREEN}✓${C_RST} Пакет ${C_PURP}${pkg}${C_RST} удалён."
    else
        echo -e "  ${C_DIM}- Пакет ${pkg} уже отсутствует.${C_RST}"
    fi
done

echo -e "\n${C_CYAN}▸ Шаг 2: Удаление пакетов-сирот (Orphans)...${C_RST}"
ORPHANS=$(pacman -Qdtq || true)
if [ -n "$ORPHANS" ]; then
    sudo pacman -Rns --noconfirm $ORPHANS
    echo -e "  ${C_GREEN}✓${C_RST} Пакеты-сироты удалены."
else
    echo -e "  ${C_DIM}- Сирот не найдено.${C_RST}"
fi

echo -e "\n${C_CYAN}▸ Шаг 3: Очистка старых конфигов и файлов ZSH...${C_RST}"
TRASH_DIRS=(
    "$HOME/.config/rofi"
    "$HOME/.config/wlogout"
    "$HOME/.config/thunar"
    "$HOME/.config/xfce4"
)
TRASH_FILES=(
    "$HOME/.zshrc"
    "$HOME/.zsh_history"
    "$HOME/.zcompdump*"
    "$HOME/.zprofile"
    "$HOME/Pictures/wallpaper.png"
)

for d in "${TRASH_DIRS[@]}"; do
    if [ -d "$d" ]; then
        rm -rf "$d"
        echo -e "  ${C_GREEN}✓${C_RST} Директория ${C_PURP}${d}${C_RST} удалена."
    fi
done

for f in "${TRASH_FILES[@]}"; do
    for match in $f; do
        if [ -f "$match" ]; then
            rm -f "$match"
            echo -e "  ${C_GREEN}✓${C_RST} Файл ${C_PURP}${match}${C_RST} удалён."
        fi
    done
done

echo -e "\n${C_CYAN}▸ Шаг 4: Удаление старых бэкапов от прошлых установщиков...${C_RST}"
BACKUPS=$(find "$HOME" -maxdepth 1 -type d \( -name ".config-backup-lain-*" -o -name ".config-backup-old" \) 2>/dev/null)

if [ -n "$BACKUPS" ]; then
    for b in $BACKUPS; do
        rm -rf "$b"
        echo -e "  ${C_GREEN}✓${C_RST} Бэкап ${C_PURP}${b}${C_RST} стёрт."
    done
else
    echo -e "  ${C_DIM}- Старые бэкапы не найдены.${C_RST}"
fi

echo -e "\n${C_CYAN}▸ Шаг 5: Очистка кэша пакетов...${C_RST}"
sudo pacman -Sc --noconfirm >/dev/null 2>&1
echo -e "  ${C_GREEN}✓${C_RST} Кэш Pacman очищен."

echo -e "\n${C_GREEN}================================================================${C_RST}"
echo -e "${C_PURP}✨ СИСТЕМА ИДЕАЛЬНО ЧИСТА!${C_RST}"
echo -e "${C_DIM}Теперь твой Arch Linux не содержит ничего лишнего.${C_RST}"

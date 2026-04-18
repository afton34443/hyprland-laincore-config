#!/usr/bin/env bash
# ==============================================================================
#  CAELESTIA-TIER HYPRLAND INSTALLER (2026 EDITION)
#  Нереальный уровень: Никакого мусора, только чистая Wayland-эстетика.
# ==============================================================================

set -e

# --- ЦВЕТА И СТИЛИ ---
C_PURP='\033[1;35m'
C_CYAN='\033[1;36m'
C_GREEN='\033[1;32m'
C_RED='\033[1;31m'
C_DIM='\033[2m'
C_RST='\033[0m'

clear
echo -e "${C_PURP}"
cat << "EOF"
   ____           _           _   _         _   _           
  / ___|__ _  ___| | ___  ___| |_(_) __ _  | |_(_) ___ _ __ 
 | |   / _` |/ _ \ |/ _ \/ __| __| |/ _` | | __| |/ _ \ '__|
 | |__| (_| |  __/ |  __/\__ \ |_| | (_| | | |_| |  __/ |   
  \____\__,_|\___|_|\___||___/\__|_|\__,_|  \__|_|\___|_|   
                                                            
      [ ULTIMATE WAYLAND RICE • CAELESTIA EDITION ]
EOF
echo -e "${C_RST}\n"

if [ "$EUID" -eq 0 ]; then
    echo -e "${C_RED}✗ Ошибка: Не запускай от root! Запускай как обычный пользователь.${C_RST}"
    exit 1
fi

# --- ПРОФЕССИОНАЛЬНЫЙ СПИННЕР ---
execute() {
    local msg="$1"
    shift
    "$@" >/tmp/install.log 2>&1 &
    local pid=$!
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r  ${C_PURP}%c${C_RST}  %s" "$spinstr" "$msg"
        local spinstr=$temp${spinstr%"$temp"}
        sleep 0.05
    done
    wait $pid
    local status=$?
    if [ $status -eq 0 ]; then
        printf "\r\033[K  ${C_GREEN}✓${C_RST}  %s\n" "$msg"
    else
        printf "\r\033[K  ${C_RED}✗${C_RST}  %s\n" "$msg"
        echo -e "${C_RED}Последние логи ошибки (/tmp/install.log):${C_RST}"
        tail -n 5 /tmp/install.log
        exit 1
    fi
}

echo -e "${C_CYAN}▸ Подготовка системы...${C_RST}"

# --- ПАКЕТЫ (ТОЛЬКО ЭЛИТА, НОЛЬ МУСОРА) ---
# Thunar, Rofi, Zsh вырезаны. Внедрены Yazi, Fuzzel, Fish.
CORE="hyprland hyprpaper hyprlock hypridle hyprpolkitagent"
UI="waybar fuzzel dunst kitty starship ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts-emoji papirus-icon-theme bibata-cursor-theme"
TERMINAL="fish yazi eza bat fzf fd ripgrep zoxide btop fastfetch"
TOOLS="grim slurp swappy wl-clipboard cliphist brightnessctl pamixer playerctl ffmpegthumbnailer 7zip jq poppler imagemagick"

execute "Обновление баз данных pacman" sudo pacman -Sy --noconfirm
execute "Установка архитектуры ядра (Hyprland)" sudo pacman -S --needed --noconfirm $CORE
execute "Установка интерфейса и шрифтов (Waybar, Fuzzel, Fonts)" sudo pacman -S --needed --noconfirm $UI
execute "Установка терминальной магии (Fish, Yazi, Eza)" sudo pacman -S --needed --noconfirm $TERMINAL
execute "Установка инструментов (Скриншоты, Буфер, Медиа)" sudo pacman -S --needed --noconfirm $TOOLS

# --- БЭКАП И ОЧИСТКА ---
execute "Очистка старых конфигов и создание директорий" bash -c "
    mkdir -p ~/.config-backup-old
    mv ~/.config/{hypr,waybar,rofi,dunst,kitty,starship,wlogout,fish,fuzzel,yazi,fastfetch} ~/.config-backup-old/ 2>/dev/null || true
    mkdir -p ~/.config/{hypr/scripts,waybar,dunst,kitty,fish,fuzzel,yazi,fastfetch} ~/.local/share/caelestia-wallpapers
"

# --- ЗАГРУЗКА ОБОЕВ (CAELESTIA VIBE) ---
execute "Загрузка эстетичных обоев (Catppuccin Space)" wget -qO ~/.local/share/caelestia-wallpapers/space.jpg "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/space/comet.jpg"

echo -e "\n${C_CYAN}▸ Генерация конфигураций Unreal-уровня...${C_RST}"

# --- HYPRLAND (PERFECT BLUR & SHADOWS) ---
execute "Генерация hyprland.conf" cat << 'EOF' > ~/.config/hypr/hyprland.conf
monitor=,preferred,auto,1

exec-once = waybar
exec-once = hyprpaper
exec-once = dunst
exec-once = hypridle
exec-once = systemctl --user start hyprpolkitagent
exec-once = wl-paste --type text --watch cliphist store

env = XCURSOR_THEME,Bibata-Modern-Classic
env = XCURSOR_SIZE,24
env = HYPRCURSOR_THEME,Bibata-Modern-Classic
env = HYPRCURSOR_SIZE,24
env = QT_QPA_PLATFORM,wayland;xcb

input {
    kb_layout = us,ru
    kb_options = grp:alt_shift_toggle
    follow_mouse = 1
    touchpad { natural_scroll = true }
    sensitivity = 0
}

general {
    gaps_in = 8
    gaps_out = 16
    border_size = 2
    col.active_border = rgba(cba6f7ff) rgba(f38ba8ff) 45deg
    col.inactive_border = rgba(11111b99)
    layout = dwindle
    resize_on_border = true
}

decoration {
    rounding = 16
    active_opacity = 0.95
    inactive_opacity = 0.85

    blur {
        enabled = true
        size = 12
        passes = 3
        noise = 0.02
        contrast = 1.1
        brightness = 0.9
        popups = true
    }

    shadow {
        enabled = true
        range = 40
        render_power = 3
        color = rgba(cba6f744)
    }
}

animations {
    enabled = true
    bezier = overshot, 0.05, 0.9, 0.1, 1.05
    bezier = smoothOut, 0.36, 0, 0.66, -0.56
    animation = windows, 1, 4, overshot, slide
    animation = windowsOut, 1, 4, smoothOut, slide
    animation = border, 1, 10, default
    animation = fade, 1, 4, default
    animation = workspaces, 1, 5, overshot, slidefade 20%
}

dwindle {
    pseudotile = true
    preserve_split = true
}

misc {
    disable_hyprland_logo = true
    vfr = true
}

$mod = SUPER

# Терминал и TUI приложения
bind = $mod, Return, exec, kitty
bind = $mod, E, exec, kitty -e yazi
bind = $mod, Space, exec, fuzzel
bind = $mod, V, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy

# Скрипт Power Menu (замена тяжелого wlogout)
bind = $mod, M, exec, ~/.config/hypr/scripts/powermenu.sh
bind = $mod, L, exec, hyprlock

# Управление окнами
bind = $mod, Q, killactive,
bind = $mod, F, fullscreen, 0
bind = $mod, T, togglefloating,

# Фокус и перемещение
bind = $mod, left, movefocus, l
bind = $mod, right, movefocus, r
bind = $mod, up, movefocus, u
bind = $mod, down, movefocus, d

bind = $mod, 1, workspace, 1
bind = $mod, 2, workspace, 2
bind = $mod, 3, workspace, 3
bind = $mod, 4, workspace, 4
bind = $mod, 5, workspace, 5

bind = $mod SHIFT, 1, movetoworkspace, 1
bind = $mod SHIFT, 2, movetoworkspace, 2
bind = $mod SHIFT, 3, movetoworkspace, 3
bind = $mod SHIFT, 4, movetoworkspace, 4
bind = $mod SHIFT, 5, movetoworkspace, 5

# Скриншоты
bind = , Print, exec, grim - | wl-copy
bind = SHIFT, Print, exec, grim -g "$(slurp)" - | swappy -f -

# Медиа клавиши
bindel = , XF86AudioRaiseVolume, exec, pamixer -i 5
bindel = , XF86AudioLowerVolume, exec, pamixer -d 5
bindl  = , XF86AudioMute, exec, pamixer -t
bindel = , XF86MonBrightnessUp, exec, brightnessctl set 5%+
bindel = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# Правила окон и слоев (Идеальный блюр для панелей)
windowrulev2 = float, class:^(pavucontrol)$
windowrulev2 = float, class:^(hyprpolkitagent)$

layerrule = blur, waybar
layerrule = ignorealpha 0.0, waybar
layerrule = blur, fuzzel
layerrule = ignorealpha 0.0, fuzzel
layerrule = blur, dunst
layerrule = ignorealpha 0.0, dunst
EOF

# --- ПОВЕР МЕНЮ (КАСТОМНЫЙ СКРИПТ) ---
execute "Генерация скрипта PowerMenu" cat << 'EOF' > ~/.config/hypr/scripts/powermenu.sh
#!/usr/bin/env bash
entries="⏻ Poweroff\n⟳ Reboot\n⏾ Suspend\n⭘ Logout\n Lock"
selected=$(echo -e $entries | fuzzel --dmenu --lines=5 --width=15 --prompt="⏻  " | awk '{print $2}')
case $selected in
    Poweroff) systemctl poweroff ;;
    Reboot) systemctl reboot ;;
    Suspend) systemctl suspend ;;
    Logout) hyprctl dispatch exit ;;
    Lock) hyprlock ;;
esac
EOF
chmod +x ~/.config/hypr/scripts/powermenu.sh

# --- WAYBAR (QUICKSHELL / ISLANDS VIBE) ---
execute "Генерация Waybar (Islands UI)" cat << 'EOF' > ~/.config/waybar/config.jsonc
{
    "layer": "top",
    "position": "top",
    "margin-top": 12,
    "margin-left": 16,
    "margin-right": 16,
    "height": 40,
    "spacing": 0,
    "modules-left":["custom/launcher", "hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right":["tray", "pulseaudio", "battery"],

    "custom/launcher": {
        "format": "󰣇",
        "on-click": "fuzzel",
        "tooltip": false
    },
    "hyprland/workspaces": {
        "format": "{icon}",
        "format-icons": { "active": "", "default": "" },
        "persistent-workspaces": { "*": 5 }
    },
    "clock": {
        "format": "  {:%H:%M  |  %d %b}",
        "tooltip-format": "<tt><small>{calendar}</small></tt>"
    },
    "pulseaudio": {
        "format": "{icon}  {volume}%",
        "format-muted": "  Mute",
        "format-icons": ["", "", ""]
    },
    "battery": {
        "states": { "warning": 30, "critical": 15 },
        "format": "{icon}  {capacity}%",
        "format-charging": "  {capacity}%",
        "format-icons":["", "", "", "", ""]
    },
    "tray": { "spacing": 10 }
}
EOF

execute "Генерация Waybar CSS" cat << 'EOF' > ~/.config/waybar/style.css
* {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 14px;
    font-weight: bold;
    border: none;
    border-radius: 0;
    min-height: 0;
    margin: 0;
    padding: 0;
}

window#waybar { background: transparent; }

/* Кастомизация каждого модуля как отдельной "таблетки" (Pill) */
#custom-launcher, #workspaces, #clock, #tray, #pulseaudio, #battery {
    background: rgba(17, 17, 27, 0.65);
    border: 1px solid rgba(203, 166, 247, 0.2);
    border-radius: 24px;
    padding: 4px 18px;
    margin: 0 6px;
    color: #cdd6f4;
    box-shadow: 0 4px 15px rgba(0,0,0,0.3);
    transition: all 0.3s ease;
}

#custom-launcher { color: #cba6f7; font-size: 18px; padding-right: 20px; }
#clock { color: #89b4fa; }
#pulseaudio { color: #f38ba8; }
#battery { color: #a6e3a1; }
#battery.warning { color: #f9e2af; }
#battery.critical { color: #f38ba8; animation: blink 1s infinite; }

#workspaces button {
    color: #6c7086;
    padding: 0 4px;
    background: transparent;
    border: none;
    box-shadow: none;
}
#workspaces button.active { color: #cba6f7; text-shadow: 0 0 8px rgba(203,166,247,0.6); }

@keyframes blink { 50% { color: transparent; } }
EOF

# --- FUZZEL (ЛУЧШИЙ LAUNCHER ДЛЯ WAYLAND) ---
execute "Генерация Fuzzel (Сверхбыстрый Launcher)" cat << 'EOF' > ~/.config/fuzzel/fuzzel.ini
[main]
font=JetBrainsMono Nerd Font:size=14
prompt="❯ "
icon-theme=Papirus-Dark
terminal=kitty -e
width=40
lines=8
horizontal-pad=24
vertical-pad=24
inner-pad=12
line-height=24
layer=overlay

[colors]
background=11111bd9
text=cdd6f4ff
match=f38ba8ff
selection=cba6f7ff
selection-text=11111bff
border=cba6f780

[border]
width=2
radius=16
EOF

# --- DUNST (УВЕДОМЛЕНИЯ В СТИЛЕ IOS TOASTS) ---
execute "Генерация Dunst (Toast-стиль)" cat << 'EOF' > ~/.config/dunst/dunstrc
[global]
width = 320
height = 120
origin = top-center
offset = 0x20
corner_radius = 16
frame_width = 1
frame_color = "#cba6f780"
background = "#11111bd9"
foreground = "#cdd6f4"
font = JetBrainsMono Nerd Font 11
padding = 16
horizontal_padding = 16
icon_position = left
min_icon_size = 48
max_icon_size = 64
EOF

# --- KITTY & FISH & STARSHIP ---
execute "Генерация Kitty (Терминал)" cat << 'EOF' > ~/.config/kitty/kitty.conf
font_family      JetBrainsMono Nerd Font
font_size        13.0
cursor_shape     beam
background            #11111b
foreground            #cdd6f4
selection_background  #cba6f7
selection_foreground  #11111b
cursor                #cba6f7
background_opacity    0.85
window_padding_width  20
hide_window_decorations yes
confirm_os_window_close 0
EOF

execute "Генерация Starship (Промпт)" cat << 'EOF' > ~/.config/starship.toml
format = "$directory$git_branch$character"
add_newline = false

[directory]
style = "bold #cba6f7"
format = "[$path]($style) "

[git_branch]
style = "italic #f38ba8"
format = "[$branch]($style) "

[character]
success_symbol = "[❯](bold #a6e3a1)"
error_symbol = "[❯](bold #f38ba8)"
EOF

execute "Генерация Fish (Оболочка)" cat << 'EOF' > ~/.config/fish/config.fish
set fish_greeting ""
starship init fish | source
zoxide init fish | source

alias ls="eza --icons=always --group-directories-first"
alias ll="eza -la --icons=always --group-directories-first"
alias cat="bat --style=plain"
alias top="btop"
alias clear="clear && fastfetch"

# При запуске Fish рисуем fetch
if status is-interactive
    fastfetch
end
EOF

execute "Генерация эстетичного Fastfetch" cat << 'EOF' > ~/.config/fastfetch/config.jsonc
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "color": {"1": "magenta"},
    "padding": {"top": 1, "left": 2, "right": 4}
  },
  "display": { "separator": " ➜  " },
  "modules":[
    "break",
    {"type": "os", "key": "OS", "keyColor": "magenta"},
    {"type": "wm", "key": "WM", "keyColor": "magenta"},
    {"type": "shell", "key": "Shell", "keyColor": "magenta"},
    {"type": "terminal", "key": "Terminal", "keyColor": "magenta"},
    {"type": "packages", "key": "Packages", "keyColor": "magenta"},
    "break", "colors"
  ]
}
EOF

# --- ОБОИ И ЛОКСКРИН ---
execute "Настройка Hyprpaper & Lock" cat << 'EOF' > ~/.config/hypr/hyprpaper.conf
preload = ~/.local/share/caelestia-wallpapers/space.jpg
wallpaper = ,~/.local/share/caelestia-wallpapers/space.jpg
splash = false
EOF

cat > ~/.config/hypr/hyprlock.conf << 'EOF'
background {
    monitor =
    path = ~/.local/share/caelestia-wallpapers/space.jpg
    blur_passes = 3
    blur_size = 10
    brightness = 0.6
}
input-field {
    monitor =
    size = 280, 55
    outline_thickness = 2
    outer_color = rgb(cba6f7)
    inner_color = rgba(17, 17, 27, 0.8)
    font_color = rgb(cdd6f4)
    fade_on_empty = false
    placeholder_text = <i>Password...</i>
    position = 0, -120
    halign = center
    valign = center
}
label {
    monitor =
    text = $TIME
    color = rgb(cba6f7)
    font_size = 90
    font_family = JetBrainsMono Nerd Font Bold
    position = 0, 80
    halign = center
    valign = center
}
EOF

# --- СМЕНА ОБОЛОЧКИ ---
execute "Смена дефолтной оболочки на Fish" sudo chsh -s $(which fish) $USER

echo -e "\n${C_GREEN}================================================================${C_RST}"
echo -e "${C_PURP}✨ МАГИЯ ЗАВЕРШЕНА! Уровень CAELESTIA достигнут.${C_RST}"
echo -e "${C_DIM}• Никаких тяжелых панелей, всё сведено к идеальным TUI / Wayland стандартам.${C_RST}"
echo -e "${C_DIM}• Файловый менеджер: Yazi (Super + E)${C_RST}"
echo -e "${C_DIM}• Меню приложений: Fuzzel (Super + Space)${C_RST}"
echo -e "${C_DIM}• Меню выключения: Кастомный скрипт (Super + M)${C_RST}"
echo -e "\n${C_CYAN}➜ Пожалуйста, перезагрузи систему и наслаждайся.${C_RST}"

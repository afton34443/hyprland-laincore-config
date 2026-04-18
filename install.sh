#!/usr/bin/env bash
# ==============================================================================
#  LAIN-CORE x CAELESTIA TIER (EDITION 2026)
#  Безопасный установщик: логи открыты, пакеты разделены, эстетика идеальна.
# ==============================================================================

set -e

C_PURP='\033[1;35m'
C_CYAN='\033[1;36m'
C_GREEN='\033[1;32m'
C_RED='\033[1;31m'
C_RST='\033[0m'
BOLD='\033[1m'

clear
echo -e "${C_PURP}${BOLD}"
cat << "EOF"
  _          _               ____               
 | |    __ _(_)_ __         / ___|___  _ __ ___ 
 | |   / _` | | '_ \ _____ | |   / _ \| '__/ _ \
 | |__| (_| | | | | |_____|| |__| (_) | | |  __/
 |_____\__,_|_|_| |_|       \____\___/|_|  \___|[ WAYLAND RICE • LAIN-CORE x CAELESTIA ]
EOF
echo -e "${C_RST}\n"

if [ "$EUID" -eq 0 ]; then
    echo -e "${C_RED}✗ Ошибка: Не запускай от root!${C_RST}"
    exit 1
fi

step() { echo -e "\n${C_CYAN}▸ $1${C_RST}"; }
ok() { echo -e "${C_GREEN}✓ $1${C_RST}"; }

# ==============================================================================
# 1. УСТАНОВКА ПАКЕТОВ (ЛОГИ ОТКРЫТЫ ДЛЯ БЕЗОПАСНОСТИ)
# ==============================================================================
step "Обновление системы (введи пароль, если попросит)..."
sudo pacman -Syu --noconfirm

# Только пакеты из ОФИЦИАЛЬНЫХ репозиториев
PACMAN_PKGS=(
    # Ядро Wayland
    hyprland hyprpaper hyprlock hypridle hyprpolkitagent
    # Интерфейс
    waybar fuzzel dunst kitty starship
    # Шрифты и иконки
    ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts-emoji papirus-icon-theme
    # Терминал и утилиты
    fish eza bat fzf fd ripgrep zoxide btop fastfetch yazi
    # Система
    grim slurp swappy wl-clipboard cliphist brightnessctl pamixer playerctl wget unzip
)

step "Установка основных пакетов..."
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

step "Проверка и установка yay (AUR helper)..."
if ! command -v yay &>/dev/null; then
    cd /tmp
    rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
fi

# Пакеты из AUR (курсоры)
AUR_PKGS=(bibata-cursor-theme)
step "Установка пакетов из AUR..."
yay -S --needed --noconfirm "${AUR_PKGS[@]}"

# ==============================================================================
# 2. ПОДГОТОВКА И ОБОИ
# ==============================================================================
step "Создание папок для конфигов..."
mkdir -p ~/.config/{hypr/scripts,waybar,dunst,kitty,fish,fuzzel,yazi,fastfetch}
mkdir -p ~/Pictures/Screenshots

step "Скачиваем эстетичные тёмные обои..."
# Темная абстракция (отлично подходит под неон-розовый)
wget -qO ~/Pictures/wallpaper.png "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/minimalistic/mac-os-monterey-dark.jpg" || true

# ==============================================================================
# 3. ГЕНЕРАЦИЯ КОНФИГОВ (ГИБКИЕ И С КОММЕНТАРИЯМИ)
# ==============================================================================
step "Настройка Hyprland (Ядро системы)..."
cat > ~/.config/hypr/hyprland.conf << 'EOF'
# ==============================================================================
#  HYPRLAND CONFIG — LAIN CORE
# ==============================================================================

monitor=,preferred,auto,1

# --- АВТОЗАПУСК ---
exec-once = waybar
exec-once = hyprpaper
exec-once = dunst
exec-once = hypridle
exec-once = systemctl --user start hyprpolkitagent
exec-once = wl-paste --type text --watch cliphist store

# --- ПЕРЕМЕННЫЕ (Курсор и Wayland) ---
env = XCURSOR_THEME,Bibata-Modern-Classic
env = XCURSOR_SIZE,24
env = HYPRCURSOR_THEME,Bibata-Modern-Classic
env = HYPRCURSOR_SIZE,24
env = QT_QPA_PLATFORM,wayland;xcb

# --- КЛАВИАТУРА И МЫШЬ ---
input {
    kb_layout = us,ru
    kb_options = grp:alt_shift_toggle
    follow_mouse = 1
    touchpad { natural_scroll = true }
    sensitivity = 0
}

# --- ВНЕШНИЙ ВИД (ЦВЕТА И ОТСТУПЫ) ---
general {
    gaps_in = 6                  # Отступы между окнами
    gaps_out = 12                # Отступы по краям экрана
    border_size = 2              # Толщина рамки

    # ЦВЕТА: Градиент от неоново-розового к фиолетовому
    col.active_border = rgba(ff5588ff) rgba(cba6f7ff) 45deg
    col.inactive_border = rgba(1a1a24cc)

    layout = dwindle
    resize_on_border = true
}

decoration {
    rounding = 12                # Скругление углов окон
    active_opacity = 0.95        # Прозрачность активного окна
    inactive_opacity = 0.85      # Прозрачность неактивного окна

    # Размытие фона под полупрозрачными окнами
    blur {
        enabled = true
        size = 8
        passes = 3
        ignore_opacity = true
    }

    # НЕОНОВОЕ СВЕЧЕНИЕ (Глоу-эффект)
    shadow {
        enabled = true
        range = 30
        render_power = 2
        color = rgba(ff558855)   # Розовая полупрозрачная тень
    }
}

# --- АНИМАЦИИ (Плавные и упругие) ---
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

misc { disable_hyprland_logo = true }

# --- ГОРЯЧИЕ КЛАВИШИ ---
$mod = SUPER

# Программы
bind = $mod, Return, exec, kitty
bind = $mod, E, exec, kitty -e yazi    # Файловый менеджер в терминале
bind = $mod, Space, exec, fuzzel       # Меню приложений
bind = $mod, V, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy

# Система
bind = $mod, M, exec, ~/.config/hypr/scripts/powermenu.sh # Выключение
bind = $mod, L, exec, hyprlock                            # Блокировка

# Окна
bind = $mod, Q, killactive,
bind = $mod, F, fullscreen, 0
bind = $mod, T, togglefloating,

# Фокус
bind = $mod, left, movefocus, l
bind = $mod, right, movefocus, r
bind = $mod, up, movefocus, u
bind = $mod, down, movefocus, d

# Рабочие столы
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

# Мультимедиа (Звук и яркость)
bindel = , XF86AudioRaiseVolume, exec, pamixer -i 5
bindel = , XF86AudioLowerVolume, exec, pamixer -d 5
bindl  = , XF86AudioMute, exec, pamixer -t
bindel = , XF86MonBrightnessUp, exec, brightnessctl set 5%+
bindel = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# --- ПРАВИЛА ОКОН (Исключения) ---
windowrulev2 = float, class:^(pavucontrol)$
windowrulev2 = float, class:^(hyprpolkitagent)$

# Блюр интерфейса
layerrule = blur, waybar
layerrule = ignorealpha 0.0, waybar
layerrule = blur, fuzzel
layerrule = ignorealpha 0.0, fuzzel
EOF

step "Создание меню выключения (Power Menu)..."
cat > ~/.config/hypr/scripts/powermenu.sh << 'EOF'
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

step "Настройка панелей Waybar (Стиль Островов/Pills)..."
cat > ~/.config/waybar/config.jsonc << 'EOF'
{
    "layer": "top",
    "position": "top",
    "margin-top": 10,
    "margin-left": 14,
    "margin-right": 14,
    "height": 38,
    "spacing": 0,
    "modules-left": ["custom/launcher", "hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["tray", "pulseaudio", "battery"],

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
        "format": "  {:%H:%M}",
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

cat > ~/.config/waybar/style.css << 'EOF'
* {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 14px;
    font-weight: bold;
    border: none;
    border-radius: 0;
    margin: 0;
    padding: 0;
}

window#waybar { background: transparent; }

/* Кастомизация капсул (островов) */
#custom-launcher, #workspaces, #clock, #tray, #pulseaudio, #battery {
    background: rgba(10, 10, 15, 0.7);    /* Темный полупрозрачный фон */
    border: 1px solid rgba(255, 85, 136, 0.4); /* Розовая обводка */
    border-radius: 20px;
    padding: 2px 16px;
    margin: 0 6px;
    color: #f8f8f2;
    transition: all 0.3s ease;
}

/* Цвета иконок */
#custom-launcher { color: #ff5588; font-size: 18px; padding-right: 20px;}
#clock { color: #cba6f7; }
#pulseaudio { color: #8be9fd; }
#battery { color: #50fa7b; }
#battery.warning { color: #ffb86c; }
#battery.critical { color: #ff5555; animation: blink 1s infinite; }

#workspaces button {
    color: rgba(255, 255, 255, 0.3);
    padding: 0 4px;
    background: transparent;
    box-shadow: none;
}
#workspaces button.active { 
    color: #ff5588; 
    text-shadow: 0 0 8px rgba(255, 85, 136, 0.6); 
}

@keyframes blink { 50% { color: transparent; } }
EOF

step "Настройка Fuzzel (Сверхбыстрый Launcher)..."
cat > ~/.config/fuzzel/fuzzel.ini << 'EOF'
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
layer=overlay[colors]
background=0a0a0fed
text=f8f8f2ff
match=cba6f7ff
selection=ff5588ff
selection-text=0a0a0fff
border=ff558880

[border]
width=2
radius=16
EOF

step "Настройка Kitty (Терминал)..."
cat > ~/.config/kitty/kitty.conf << 'EOF'
font_family      JetBrainsMono Nerd Font
font_size        12.0
cursor_shape     beam

background            #0a0a0f
foreground            #f8f8f2
selection_background  #ff5588
selection_foreground  #0a0a0f
cursor                #ff5588
background_opacity    0.85
window_padding_width  20
hide_window_decorations yes
confirm_os_window_close 0
EOF

step "Настройка Fish и Starship (Оболочка)..."
cat > ~/.config/starship.toml << 'EOF'
format = "$directory$git_branch$character"
add_newline = false

[directory]
style = "bold #ff5588"
format = "[$path]($style) "[git_branch]
style = "italic #cba6f7"
format = "[$branch]($style) "

[character]
success_symbol = "[❯](bold #ff5588)"
error_symbol = "[❯](bold #ff5555)"
EOF

cat > ~/.config/fish/config.fish << 'EOF'
set fish_greeting ""
starship init fish | source
zoxide init fish | source

alias ls="eza --icons=always --group-directories-first"
alias ll="eza -la --icons=always --group-directories-first"
alias cat="bat --style=plain"
alias top="btop"

if status is-interactive
    fastfetch
end
EOF

step "Настройка Обоев и Экрана блокировки..."
cat > ~/.config/hypr/hyprpaper.conf << 'EOF'
preload = ~/Pictures/wallpaper.png
wallpaper = ,~/Pictures/wallpaper.png
splash = false
EOF

cat > ~/.config/hypr/hyprlock.conf << 'EOF'
background {
    monitor =
    path = ~/Pictures/wallpaper.png
    blur_passes = 3
    blur_size = 10
    brightness = 0.5
}
input-field {
    monitor =
    size = 280, 55
    outline_thickness = 2
    outer_color = rgb(ff5588)
    inner_color = rgba(10, 10, 15, 0.8)
    font_color = rgb(f8f8f2)
    fade_on_empty = false
    placeholder_text = <i>Password...</i>
    position = 0, -120
    halign = center
    valign = center
}
label {
    monitor =
    text = $TIME
    color = rgb(ff5588)
    font_size = 90
    font_family = JetBrainsMono Nerd Font Bold
    position = 0, 80
    halign = center
    valign = center
}
EOF

cat > ~/.config/hypr/hypridle.conf << 'EOF'
general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}
listener { timeout = 300; on-timeout = loginctl lock-session }
listener { timeout = 600; on-timeout = systemctl suspend }
EOF

step "Смена стандартной оболочки на Fish..."
CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
if[ "$CURRENT_SHELL" != "/usr/bin/fish" ]; then
    sudo chsh -s $(which fish) $USER
fi

echo -e "\n${C_GREEN}${BOLD}УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО!${C_RST}"
echo -e "${C_PURP}Теперь система идеально стабильна и прозрачна в настройке.${C_RST}"
echo -e "Файлы конфигурации лежат в ${C_CYAN}~/.config/${C_RST} и снабжены комментариями."
echo -e "\nТвой арсенал:"
echo -e " • ${C_CYAN}Super + Enter${C_RST} : Терминал (Kitty + Fish)"
echo -e " • ${C_CYAN}Super + Space${C_RST} : Меню приложений (Fuzzel)"
echo -e " • ${C_CYAN}Super + E${C_RST}     : Файлы (Yazi)"
echo -e " • ${C_CYAN}Super + M${C_RST}     : Выключение / Перезагрузка"
echo -e "\nПожалуйста, ${C_RED}перезагрузи компьютер${C_RST} и наслаждайся!"

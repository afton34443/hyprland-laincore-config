#!/usr/bin/env bash
# ============================================================
#   LAIN-CORE HYPRLAND — АВТОУСТАНОВКА
#   Чёрный + Розовый неон глоу
#   Запуск: bash install.sh
# ============================================================

set -e  # остановиться при любой ошибке

# ── Цвета для вывода ────────────────────────────────────────
RED='\033[0;31m'
PINK='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${PINK}▸${NC} $1"; }
ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${RED}⚠${NC}  $1"; }
sec()  { echo -e "\n${BOLD}${PINK}══ $1 ══${NC}\n"; }

# ── Проверки ────────────────────────────────────────────────
sec "Проверка окружения"

if [ "$EUID" -eq 0 ]; then
    warn "Не запускай от root! Запусти от обычного пользователя."
    exit 1
fi

if ! command -v pacman &>/dev/null; then
    warn "Этот скрипт только для Arch Linux (pacman не найден)."
    exit 1
fi

log "Пользователь: $(whoami)"
log "Домашняя директория: $HOME"
echo ""
warn "Скрипт установит пакеты, создаст конфиги и сменит оболочку на zsh."
warn "Существующие конфиги будут сохранены в ~/.config-backup-lain/"
echo ""
read -rp "$(echo -e "${PINK}Продолжить? [y/N]:${NC} ")" CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "Отменено."; exit 0; }

# ── Бэкап существующих конфигов ─────────────────────────────
sec "Бэкап конфигов"

BACKUP_DIR="$HOME/.config-backup-lain-$(date +%Y%m%d_%H%M%S)"
CONFIGS_TO_BACKUP=(hypr waybar rofi dunst kitty starship)

for cfg in "${CONFIGS_TO_BACKUP[@]}"; do
    if [ -d "$HOME/.config/$cfg" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -r "$HOME/.config/$cfg" "$BACKUP_DIR/"
        log "Сохранён бэкап: ~/.config/$cfg → $BACKUP_DIR/$cfg"
    fi
done

if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.bak"
    log "Сохранён бэкап: ~/.zshrc"
fi

ok "Бэкапы готовы: $BACKUP_DIR"

# ── Обновление системы ───────────────────────────────────────
sec "Обновление системы"

log "Обновляем базы пакетов и ключи..."
sudo pacman -Sy --noconfirm archlinux-keyring
sudo pacman -Su --noconfirm
ok "Система обновлена"

# ── Установка основных пакетов ───────────────────────────────
sec "Установка пакетов (pacman)"

PACKAGES=(
    # Hyprland и Wayland
    hyprland
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    qt5-wayland
    qt6-wayland

    # Бар, уведомления, лаунчер
    waybar
    dunst
    libnotify
    rofi-wayland

    # Терминал
    kitty

    # Обои и экран блокировки
    hyprpaper
    hyprlock
    hypridle

    # Скриншоты
    grim
    slurp
    swappy

    # Буфер обмена
    wl-clipboard
    cliphist

    # Управление устройствами
    brightnessctl
    pamixer
    playerctl
    polkit-kde-agent

    # Сеть и звук
    network-manager-applet
    pavucontrol
    bluez
    bluez-utils
    blueman

    # Файловый менеджер
    thunar
    gvfs

    # Оболочка
    zsh
    zsh-syntax-highlighting
    zsh-autosuggestions

    # Инструменты
    git
    base-devel
    curl
    wget
    bat
    btop
    fastfetch
    cava
    xdg-user-dirs

    # Шрифты
    ttf-jetbrains-mono-nerd
    ttf-font-awesome
    noto-fonts
    noto-fonts-emoji

    # Иконки
    papirus-icon-theme
)

log "Устанавливаем ${#PACKAGES[@]} пакетов..."
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
ok "Пакеты установлены"

# ── Установка yay ────────────────────────────────────────────
sec "Установка yay (AUR)"

if command -v yay &>/dev/null; then
    ok "yay уже установлен, пропускаем"
else
    log "Клонируем и собираем yay..."
    cd /tmp
    rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd "$HOME"
    ok "yay установлен"
fi

# ── Установка AUR пакетов ────────────────────────────────────
sec "Установка пакетов из AUR"

AUR_PACKAGES=(
    bibata-cursor-theme
    grimblast-git
    wlogout
)

for pkg in "${AUR_PACKAGES[@]}"; do
    log "Устанавливаем $pkg..."
    yay -S --needed --noconfirm "$pkg"
done
ok "AUR пакеты установлены"

# ── Установка Starship ───────────────────────────────────────
sec "Установка Starship (промпт)"

if command -v starship &>/dev/null; then
    ok "Starship уже установлен, пропускаем"
else
    log "Устанавливаем starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    ok "Starship установлен"
fi

# ── Создание директорий ──────────────────────────────────────
sec "Создание структуры директорий"

DIRS=(
    "$HOME/.config/hypr"
    "$HOME/.config/waybar"
    "$HOME/.config/rofi"
    "$HOME/.config/dunst"
    "$HOME/.config/kitty"
    "$HOME/.config/starship"
    "$HOME/.config/wlogout"
    "$HOME/Pictures/Screenshots"
    "$HOME/Pictures"
)

for d in "${DIRS[@]}"; do
    mkdir -p "$d"
done

xdg-user-dirs-update
ok "Директории созданы"

# ════════════════════════════════════════════════════════════
#   КОНФИГИ
# ════════════════════════════════════════════════════════════

sec "Запись конфигов"

# ── hyprland.conf ────────────────────────────────────────────
log "Пишем hyprland.conf..."
cat > "$HOME/.config/hypr/hyprland.conf" << 'HYPR_EOF'
########################################
#   HYPRLAND — LAIN-CORE ЭСТЕТИКА      #
########################################

# ── АВТОЗАПУСК ─────────────────────────
exec-once = waybar
exec-once = hyprpaper
exec-once = dunst
exec-once = hypridle
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = nm-applet --indicator
exec-once = wl-paste --type text --watch cliphist store

# ── ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ ────────────────
env = LIBVA_DRIVER_NAME,radeonsi
env = GBM_BACKEND,radeon
env = WLR_NO_HARDWARE_CURSORS,1

env = QT_QPA_PLATFORM,wayland;xcb
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = GDK_BACKEND,wayland,x11
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = ELECTRON_OZONE_PLATFORM_HINT,auto

env = XCURSOR_THEME,Bibata-Modern-Classic
env = XCURSOR_SIZE,20
env = HYPRCURSOR_THEME,Bibata-Modern-Classic
env = HYPRCURSOR_SIZE,20

# ── МОНИТОР ─────────────────────────────
monitor = , preferred, auto, 1

# ── ВВОД ────────────────────────────────
input {
    kb_layout = us,ru
    kb_options = grp:alt_shift_toggle
    follow_mouse = 1
    sensitivity = 0

    touchpad {
        natural_scroll = true
        disable_while_typing = true
        tap-to-click = true
    }
}

# ── ВНЕШНИЙ ВИД ─────────────────────────
general {
    gaps_in = 6
    gaps_out = 14
    border_size = 1
    col.active_border   = rgba(c96070ff)
    col.inactive_border = rgba(1a000800)
    layout = dwindle
    resize_on_border = true
}

decoration {
    rounding = 6
    active_opacity   = 1.0
    inactive_opacity = 0.88

    blur {
        enabled = false
    }

    shadow {
        enabled = true
        range = 50
        render_power = 1
        offset = 0, 0
        color          = rgba(c96070aa)
        color_inactive = rgba(00000000)
    }
}

animations {
    enabled = true

    bezier = snap,   0.19, 1,   0.22, 1
    bezier = lain,   0.0,  0.9, 0.1,  1.0

    animation = windows,     1, 4, lain, slide
    animation = windowsOut,  1, 3, snap, slide
    animation = windowsMove, 1, 4, lain
    animation = fade,        1, 6, default
    animation = workspaces,  1, 4, lain, slidevert
}

dwindle {
    pseudotile = true
    preserve_split = true
    force_split = 0
}

misc {
    force_default_wallpaper = 0
    disable_hyprland_logo = true
    animate_manual_resizes = true
    mouse_move_enables_dpms = true
    key_press_enables_dpms = true
    focus_on_activate = true
}

# ── ГОРЯЧИЕ КЛАВИШИ ─────────────────────
$mod = SUPER

bind = $mod, Return,      exec, kitty
bind = $mod, E,           exec, thunar
bind = $mod, B,           exec, firefox
bind = $mod, Space,       exec, rofi -show drun
bind = $mod SHIFT, Space, exec, rofi -show run
bind = $mod, V,           exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy

bind = $mod, Q,           killactive
bind = $mod, F,           fullscreen, 0
bind = $mod SHIFT, F,     fullscreen, 1
bind = $mod, T,           togglesplit
bind = $mod, P,           pseudo
bind = $mod, M,           exec, wlogout
bind = $mod, L,           exec, hyprlock

bind = $mod, H,           movefocus, l
bind = $mod, J,           movefocus, d
bind = $mod, K,           movefocus, u
bind = $mod, L,           movefocus, r
bind = $mod, left,        movefocus, l
bind = $mod, down,        movefocus, d
bind = $mod, up,          movefocus, u
bind = $mod, right,       movefocus, r

bind = $mod SHIFT, H,     movewindow, l
bind = $mod SHIFT, J,     movewindow, d
bind = $mod SHIFT, K,     movewindow, u
bind = $mod SHIFT, L,     movewindow, r

binde = $mod CTRL, H,     resizeactive, -30 0
binde = $mod CTRL, L,     resizeactive,  30 0
binde = $mod CTRL, K,     resizeactive, 0 -30
binde = $mod CTRL, J,     resizeactive, 0  30

bind = $mod SHIFT, T,     togglefloating
bind = $mod, C,           centerwindow
bindm = $mod, mouse:272,  movewindow
bindm = $mod, mouse:273,  resizewindow

bind = $mod, 1,           workspace, 1
bind = $mod, 2,           workspace, 2
bind = $mod, 3,           workspace, 3
bind = $mod, 4,           workspace, 4
bind = $mod, 5,           workspace, 5
bind = $mod SHIFT, 1,     movetoworkspace, 1
bind = $mod SHIFT, 2,     movetoworkspace, 2
bind = $mod SHIFT, 3,     movetoworkspace, 3
bind = $mod SHIFT, 4,     movetoworkspace, 4
bind = $mod SHIFT, 5,     movetoworkspace, 5
bind = $mod, Tab,         workspace, e+1
bind = $mod SHIFT, Tab,   workspace, e-1
bind = $mod, mouse_down,  workspace, e+1
bind = $mod, mouse_up,    workspace, e-1

bind = $mod, S,           togglespecialworkspace, magic
bind = $mod SHIFT, S,     movetoworkspace, special:magic

bind = , Print,           exec, grimblast copy screen
bind = SHIFT, Print,      exec, grimblast save screen ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png
bind = $mod, Print,       exec, grimblast copy area
bind = $mod SHIFT, Print, exec, grimblast save area - | swappy -f -

binde = , XF86AudioRaiseVolume,   exec, pamixer -i 5
binde = , XF86AudioLowerVolume,   exec, pamixer -d 5
bind  = , XF86AudioMute,          exec, pamixer -t
binde = , XF86MonBrightnessUp,    exec, brightnessctl set +5%
binde = , XF86MonBrightnessDown,  exec, brightnessctl set 5%-
bind  = , XF86AudioPlay,          exec, playerctl play-pause
bind  = , XF86AudioPrev,          exec, playerctl previous
bind  = , XF86AudioNext,          exec, playerctl next

windowrule = float,  class:^(pavucontrol)$
windowrule = float,  class:^(blueman-manager)$
windowrule = float,  class:^(nm-connection-editor)$
windowrule = float,  class:^(org.kde.polkit-kde-authentication-agent-1)$
windowrule = float,  title:^(Picture-in-Picture)$
windowrule = center, class:^(pavucontrol)$

layerrule = blur,       waybar
layerrule = blur,       rofi
layerrule = ignorezero, rofi
HYPR_EOF
ok "hyprland.conf готов"

# ── hyprpaper.conf ───────────────────────────────────────────
log "Пишем hyprpaper.conf..."
cat > "$HOME/.config/hypr/hyprpaper.conf" << 'PAPER_EOF'
preload = ~/Pictures/wallpaper.png
wallpaper = , ~/Pictures/wallpaper.png
splash = false
PAPER_EOF
ok "hyprpaper.conf готов"

# ── hyprlock.conf ────────────────────────────────────────────
log "Пишем hyprlock.conf..."
cat > "$HOME/.config/hypr/hyprlock.conf" << 'LOCK_EOF'
background {
    monitor =
    path = ~/Pictures/wallpaper.png
    blur_passes = 2
    blur_size = 6
    brightness = 0.3
    noise = 0.0117
    contrast = 1.3
}

input-field {
    monitor =
    size = 250, 40
    outline_thickness = 1
    outer_color = rgb(c96070)
    inner_color = rgb(000000)
    font_color  = rgb(c96070)
    fade_on_empty = true
    placeholder_text = <i>········</i>
    rounding = 4
    position = 0, -60
    halign = center
    valign = center
    check_color = rgb(c96070)
    fail_color  = rgb(eb5050)
    fail_text   = <i>$FAIL</i>
}

label {
    monitor =
    text = cmd[update:1000] echo "$(date +"%H:%M")"
    color = rgba(c96070cc)
    font_size = 64
    font_family = JetBrainsMono Nerd Font
    position = 0, 60
    halign = center
    valign = center
}
LOCK_EOF
ok "hyprlock.conf готов"

# ── hypridle.conf ────────────────────────────────────────────
log "Пишем hypridle.conf..."
cat > "$HOME/.config/hypr/hypridle.conf" << 'IDLE_EOF'
general {
    lock_cmd         = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd  = hyprctl dispatch dpms on
}

listener {
    timeout    = 300
    on-timeout = brightnessctl -s set 0
    on-resume  = brightnessctl -r
}

listener {
    timeout    = 360
    on-timeout = loginctl lock-session
}

listener {
    timeout    = 600
    on-timeout = systemctl suspend
}
IDLE_EOF
ok "hypridle.conf готов"

# ── waybar/config.jsonc ──────────────────────────────────────
log "Пишем waybar/config.jsonc..."
cat > "$HOME/.config/waybar/config.jsonc" << 'WB_EOF'
{
    "layer": "top",
    "position": "top",
    "height": 22,
    "margin-top": 0,
    "margin-left": 0,
    "margin-right": 0,
    "spacing": 0,
    "exclusive": true,

    "modules-left":   [ "custom/logo", "hyprland/workspaces" ],
    "modules-center": [ "hyprland/window" ],
    "modules-right":  [ "network", "battery", "clock", "backlight", "custom/eye" ],

    "custom/logo": {
        "format": ">_ ",
        "tooltip": false
    },

    "hyprland/workspaces": {
        "format": "{id}",
        "on-click": "activate",
        "sort-by-number": true,
        "persistent-workspaces": { "*": 5 }
    },

    "hyprland/window": {
        "max-length": 60,
        "separate-outputs": true,
        "format": "{}"
    },

    "clock": {
        "format": "{:%H:%M}",
        "format-alt": "{:%d.%m.%Y}",
        "tooltip": false
    },

    "battery": {
        "format": "{icon}{capacity}%",
        "format-charging": "↑{capacity}%",
        "format-icons": ["▂","▃","▅","▆","█"],
        "states": { "warning": 30, "critical": 15 },
        "tooltip": false
    },

    "network": {
        "format-wifi": "3ψ{signalStrength}%",
        "format-ethernet": "eth",
        "format-disconnected": "---",
        "tooltip": false,
        "on-click": "nm-connection-editor"
    },

    "backlight": {
        "format": "{percent}%",
        "tooltip": false
    },

    "custom/eye": {
        "format": "◎",
        "tooltip": false
    }
}
WB_EOF
ok "waybar config.jsonc готов"

# ── waybar/style.css ─────────────────────────────────────────
log "Пишем waybar/style.css..."
cat > "$HOME/.config/waybar/style.css" << 'CSS_EOF'
* {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 11px;
    border: none;
    border-radius: 0;
    min-height: 0;
    padding: 0;
    margin: 0;
}

window#waybar {
    background: rgba(0, 0, 0, 0.92);
    color: #c96070;
    border-bottom: 1px solid rgba(201, 96, 112, 0.3);
}

#custom-logo {
    color: #c96070;
    padding: 0 8px 0 10px;
    font-weight: bold;
}

#workspaces {
    padding: 0 6px;
}

#workspaces button {
    color: rgba(201, 96, 112, 0.3);
    background: transparent;
    padding: 0 4px;
    min-width: 0;
    transition: color 0.2s ease;
    box-shadow: none;
}

#workspaces button.active {
    color: #c96070;
}

#workspaces button:hover {
    color: rgba(201, 96, 112, 0.7);
    background: transparent;
    box-shadow: none;
}

#window {
    color: rgba(201, 96, 112, 0.55);
    font-size: 10px;
    letter-spacing: 1px;
    font-style: italic;
}

#clock,
#battery,
#network,
#backlight,
#custom-eye {
    color: rgba(201, 96, 112, 0.7);
    padding: 0 8px;
}

#clock,
#battery,
#network,
#backlight {
    border-right: 1px solid rgba(201, 96, 112, 0.15);
}

#clock {
    color: #c96070;
    padding-right: 10px;
}

#battery.warning  { color: #e88a5a; }
#battery.critical { color: #eb5050; animation: blink 1s step-end infinite; }
#battery.charging { color: #7ec88e; }

@keyframes blink { 50% { opacity: 0.3; } }

#network.disconnected { color: rgba(201, 96, 112, 0.2); }

#custom-eye {
    color: rgba(201, 96, 112, 0.35);
    padding-right: 12px;
    font-size: 13px;
}

tooltip {
    background: #0a0005;
    border: 1px solid rgba(201, 96, 112, 0.4);
    color: #c96070;
    border-radius: 4px;
    padding: 4px 8px;
}
CSS_EOF
ok "waybar style.css готов"

# ── rofi конфиг ──────────────────────────────────────────────
log "Пишем rofi конфиги..."
cat > "$HOME/.config/rofi/config.rasi" << 'ROFI_EOF'
configuration {
    modi:           "drun,run,filebrowser,window";
    show-icons:     true;
    icon-theme:     "Papirus-Dark";
    font:           "JetBrainsMono Nerd Font 12";
    drun-display-format: "{name}";
    display-drun:   "  apps";
    display-run:    "  run";
    display-window: "  windows";
    kb-cancel:      "Escape";
}

@theme "~/.config/rofi/lain.rasi"
ROFI_EOF

cat > "$HOME/.config/rofi/lain.rasi" << 'RASI_EOF'
* {
    bg:       #000000;
    bg-alt:   #0a0005;
    fg:       #c96070;
    fg-dim:   rgba(201, 96, 112, 0.35);
    border-c: rgba(201, 96, 112, 0.6);
    selected: rgba(201, 96, 112, 0.1);

    background-color: transparent;
    text-color:       @fg;
}

window {
    background-color: @bg;
    border:           1px solid;
    border-color:     @border-c;
    border-radius:    6px;
    width:            480px;
    padding:          14px;
}

mainbox {
    background-color: transparent;
    children:         [ inputbar, listview ];
    spacing:          8px;
}

inputbar {
    background-color: @bg-alt;
    border-radius:    4px;
    padding:          7px 10px;
    children:         [ prompt, entry ];
}

prompt {
    background-color: transparent;
    text-color:       @fg;
    padding:          0 6px 0 0;
}

entry {
    background-color: transparent;
    placeholder:      "type to search...";
    placeholder-color: @fg-dim;
}

listview {
    background-color: transparent;
    lines:            8;
    columns:          1;
    spacing:          2px;
}

element {
    background-color: transparent;
    border-radius:    4px;
    padding:          7px 10px;
    spacing:          8px;
    children:         [ element-icon, element-text ];
}

element.selected {
    background-color: @selected;
}

element-icon {
    size:             22px;
    background-color: transparent;
}

element-text {
    background-color: transparent;
    text-color:       @fg;
    vertical-align:   0.5;
}

element-text.selected {
    text-color: #e0a0aa;
}
RASI_EOF
ok "rofi конфиги готовы"

# ── dunst ────────────────────────────────────────────────────
log "Пишем dunstrc..."
cat > "$HOME/.config/dunst/dunstrc" << 'DUNST_EOF'
[global]
    monitor = 0
    follow = mouse
    width = (0, 380)
    height = (0, 200)
    origin = top-right
    offset = 12x28
    scale = 0
    notification_limit = 4

    progress_bar = true
    progress_bar_height = 4
    progress_bar_corner_radius = 2

    transparency = 8
    separator_height = 1
    padding = 10
    horizontal_padding = 12
    frame_width = 1
    frame_color = "#c96070"
    gap_size = 4
    separator_color = "#1a0008"
    corner_radius = 6

    font = JetBrainsMono Nerd Font 10
    line_height = 2
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    ellipsize = end
    stack_duplicates = true

    icon_position = left
    min_icon_size = 28
    max_icon_size = 42
    icon_corner_radius = 3

    mouse_left_click  = close_current
    mouse_right_click = close_all

[urgency_low]
    background = "#050002"
    foreground = "#c96070"
    frame_color = "#3a1020"
    timeout = 3

[urgency_normal]
    background = "#080004"
    foreground = "#c96070"
    frame_color = "#c96070"
    timeout = 5

[urgency_critical]
    background = "#0a0006"
    foreground = "#eb5050"
    frame_color = "#eb5050"
    timeout = 0
DUNST_EOF
ok "dunstrc готов"

# ── kitty.conf ───────────────────────────────────────────────
log "Пишем kitty.conf..."
cat > "$HOME/.config/kitty/kitty.conf" << 'KITTY_EOF'
font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
font_size        12.0

cursor_shape          beam
cursor_blink_interval 0.5
cursor_stop_blinking_after 0

background            #000000
foreground            #c96070
selection_background  #1a0008
selection_foreground  #e8a0aa
cursor                #c96070
cursor_text_color     #000000

color0   #0a0005
color1   #c96070
color2   #5a8a6a
color3   #c8a06a
color4   #506890
color5   #9a6090
color6   #6a9090
color7   #a0909a
color8   #3a1020
color9   #e07080
color10  #6aaa7a
color11  #e0b070
color12  #6080b0
color13  #b070a8
color14  #70a8a8
color15  #c096a0

background_opacity    0.95
window_padding_width  12
confirm_os_window_close 0
tab_bar_style         hidden
hide_window_decorations yes
enable_audio_bell     no
url_color             #c96070
url_style             curly
copy_on_select        yes
KITTY_EOF
ok "kitty.conf готов"

# ── starship.toml ────────────────────────────────────────────
log "Пишем starship.toml..."
cat > "$HOME/.config/starship.toml" << 'STAR_EOF'
format = """
$directory$git_branch$git_status$line_break$character"""

scan_timeout = 30
command_timeout = 500

[directory]
style = "fg:#c96070"
format = "[$path]($style) "
truncation_length = 3
truncate_to_repo = false

[character]
success_symbol = "[>](fg:#c96070)"
error_symbol   = "[>](fg:#eb5050)"
vimcmd_symbol  = "[<](fg:#9a6090)"

[git_branch]
style = "fg:#9a6090"
format = "[$branch]($style) "
symbol = ""

[git_status]
style = "fg:#3a1020"
format = "[$all_status$ahead_behind]($style) "

[cmd_duration]
disabled = false
style = "fg:#3a1020"
format = "[$duration]($style) "
min_time = 2000

[nodejs]
disabled = true
[python]
disabled = true
[rust]
disabled = true
[package]
disabled = true
STAR_EOF
ok "starship.toml готов"

# ── .zshrc ───────────────────────────────────────────────────
log "Пишем .zshrc..."
cat > "$HOME/.zshrc" << 'ZSH_EOF'
# ── История ─────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# ── Автодополнение ───────────────────────────────────────────
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ── Плагины ─────────────────────────────────────────────────
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Цвет подсказок
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#3a1020"

# Подсветка синтаксиса
ZSH_HIGHLIGHT_STYLES[command]='fg=#c96070'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#c96070,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#9a6090'
ZSH_HIGHLIGHT_STYLES[path]='fg=#a0909a'
ZSH_HIGHLIGHT_STYLES[string]='fg=#6aaa7a'

# ── Алиасы ──────────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='ls -la --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
alias cat='bat --theme=base16 --style=plain'
alias top='btop'
alias fetch='fastfetch'
alias reload='source ~/.zshrc'
alias cfg='cd ~/.config'
alias hypr='cd ~/.config/hypr && $EDITOR hyprland.conf'

# ── Starship промпт ──────────────────────────────────────────
eval "$(starship init zsh)"
ZSH_EOF
ok ".zshrc готов"

# ── wlogout layout ───────────────────────────────────────────
log "Пишем wlogout layout..."
cat > "$HOME/.config/wlogout/layout" << 'WLO_EOF'
{
    "label" : "lock",
    "action" : "hyprlock",
    "text" : "Lock",
    "keybind" : "l"
}
{
    "label" : "logout",
    "action" : "hyprctl dispatch exit 0",
    "text" : "Logout",
    "keybind" : "e"
}
{
    "label" : "suspend",
    "action" : "systemctl suspend",
    "text" : "Suspend",
    "keybind" : "u"
}
{
    "label" : "reboot",
    "action" : "systemctl reboot",
    "text" : "Reboot",
    "keybind" : "r"
}
{
    "label" : "shutdown",
    "action" : "systemctl poweroff",
    "text" : "Shutdown",
    "keybind" : "s"
}
WLO_EOF

cat > "$HOME/.config/wlogout/style.css" << 'WLOC_EOF'
* {
    background-color: transparent;
    font-family: "JetBrainsMono Nerd Font";
}

window {
    background-color: rgba(0, 0, 0, 0.88);
}

button {
    color: rgba(201, 96, 112, 0.5);
    background-color: transparent;
    border: 1px solid rgba(201, 96, 112, 0.15);
    border-radius: 6px;
    margin: 8px;
    font-size: 12px;
    transition: all 0.2s ease;
}

button:hover {
    color: #c96070;
    background-color: rgba(201, 96, 112, 0.08);
    border-color: rgba(201, 96, 112, 0.5);
    box-shadow: 0 0 20px rgba(201, 96, 112, 0.3);
}

button:focus {
    color: #c96070;
    border-color: #c96070;
}
WLOC_EOF
ok "wlogout готов"

# ── Placeholder обои ─────────────────────────────────────────
sec "Создание placeholder обоев"

if [ ! -f "$HOME/Pictures/wallpaper.png" ]; then
    log "Создаём тёмные обои-заглушку (замени на свои)..."
    # Создаём чисто чёрный PNG через Python
    python3 -c "
import struct, zlib, sys

def make_black_png(w, h, out):
    def u32(v): return struct.pack('>I', v)
    sig = b'\x89PNG\r\n\x1a\n'
    def chunk(t, d):
        c = zlib.crc32(t+d) & 0xffffffff
        return u32(len(d)) + t + d + u32(c)
    ihdr = chunk(b'IHDR', u32(w)+u32(h)+b'\x08\x02\x00\x00\x00')
    raw = b''.join(b'\x00'+b'\x00\x00\x00'*w for _ in range(h))
    idat = chunk(b'IDAT', zlib.compress(raw))
    iend = chunk(b'IEND', b'')
    with open(out, 'wb') as f:
        f.write(sig+ihdr+idat+iend)

make_black_png(1920, 1080, '$HOME/Pictures/wallpaper.png')
print('done')
" && ok "Создан чёрный wallpaper.png" || warn "Не удалось создать PNG — положи wallpaper.png в ~/Pictures/ вручную"
else
    ok "wallpaper.png уже существует, пропускаем"
fi

# ── Сервисы ──────────────────────────────────────────────────
sec "Активация сервисов"

log "Включаем bluetooth..."
sudo systemctl enable --now bluetooth 2>/dev/null && ok "bluetooth включён" || warn "bluetooth не запустился"

# ── Смена оболочки на zsh ────────────────────────────────────
sec "Смена оболочки"

CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
ZSH_PATH=$(which zsh)

if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
    ok "Оболочка уже zsh, пропускаем"
else
    log "Меняем оболочку на zsh ($ZSH_PATH)..."
    chsh -s "$ZSH_PATH"
    ok "Оболочка изменена на zsh (применится после перезахода)"
fi

# ── Финальный вывод ──────────────────────────────────────────
sec "Установка завершена"

echo -e "${BOLD}${PINK}"
cat << 'BANNER'
  _       _            _
 | | __ _(_)_ __   ___| | ___  _ __ ___
 | |/ _` | | '_ \ / __| |/ _ \| '__/ _ \
 | | (_| | | | | | (__| | (_) | | |  __/
 |_|\__,_|_|_| |_|\___|_|\___/|_|  \___|

BANNER
echo -e "${NC}"

echo -e "${GREEN}Всё установлено и настроено!${NC}\n"

echo -e "${PINK}Что сделать дальше:${NC}"
echo -e "  ${DIM}1.${NC} Положи обои в ${CYAN}~/Pictures/wallpaper.png${NC}"
echo -e "  ${DIM}2.${NC} Перезайди в систему или перезагрузись"
echo -e "  ${DIM}3.${NC} На экране входа выбери сессию ${CYAN}Hyprland${NC}"
echo ""
echo -e "${PINK}Горячие клавиши:${NC}"
echo -e "  ${CYAN}Super + Enter${NC}   → терминал"
echo -e "  ${CYAN}Super + Space${NC}   → лаунчер"
echo -e "  ${CYAN}Super + Q${NC}       → закрыть окно"
echo -e "  ${CYAN}Super + M${NC}       → меню выхода"
echo -e "  ${CYAN}Super + L${NC}       → заблокировать"
echo -e "  ${CYAN}Alt  + Shift${NC}    → смена раскладки"
echo ""
echo -e "${DIM}Бэкап старых конфигов: $BACKUP_DIR${NC}"
echo ""
echo -e "${PINK}Хочешь изменить цвет акцента?${NC}"
echo -e "  ${DIM}find ~/.config/hypr ~/.config/waybar ~/.config/kitty ~/.config/dunst -type f \\${NC}"
echo -e "  ${DIM}  -exec sed -i 's/c96070/НОВЫЙ_HEX/g' {} +${NC}"
echo ""

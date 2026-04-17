# Hyprland — Lain-core / Dark Anime эстетика
### Полный гайд: чёрный фон + розовый неон глоу + минимальный бар

---

## Разбор референса

Что видно на скриншотах:

| Элемент | Описание |
|---|---|
| Фон | Чистый чёрный `#000000` |
| Обои | Тёмный аниме арт в центре экрана, всё остальное — чёрное |
| Бордер окна | Тонкая розовая линия + большой размытый розовый глоу снаружи |
| Бар (сверху) | Очень тонкий, минимальный. Слева: иконка+`>_`, центр: имя окна, справа: сеть/батарея/время |
| Терминал | Чёрный фон, розовый промпт `> ~`, beam-курсор мигающий |
| Цвет акцента | Приглушённый розово-малиновый, примерно `#c96070` |

---

## ШАГ 1 — Установка пакетов

```bash
sudo pacman -S \
  waybar \
  kitty \
  rofi-wayland \
  dunst \
  libnotify \
  hyprpaper \
  hyprlock \
  hypridle \
  grim slurp swappy \
  grimblast \
  wl-clipboard \
  cliphist \
  brightnessctl \
  pamixer \
  playerctl \
  polkit-kde-agent \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  qt5-wayland qt6-wayland \
  zsh \
  ttf-jetbrains-mono-nerd \
  ttf-font-awesome \
  noto-fonts noto-fonts-emoji \
  btop \
  fastfetch \
  network-manager-applet \
  papirus-icon-theme

# starship — красивый промпт
curl -sS https://starship.rs/install.sh | sh

# yay (если нет)
cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd ~

# из AUR
yay -S \
  zsh-syntax-highlighting \
  zsh-autosuggestions \
  bibata-cursor-theme \
  wlogout
```

---

## ШАГ 2 — Структура конфигов

```bash
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/rofi
mkdir -p ~/.config/dunst
mkdir -p ~/.config/kitty
mkdir -p ~/.config/starship
mkdir -p ~/Pictures/Screenshots
xdg-user-dirs-update
```

---

## ШАГ 3 — Главный конфиг Hyprland

```bash
nano ~/.config/hypr/hyprland.conf
```

```ini
########################################
#   HYPRLAND — LAIN-CORE ЭСТЕТИКА      #
#   Чёрный + Розовый неон глоу         #
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

# Курсор
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

# ── ВНЕШНИЙ ВИД — ГЛАВНАЯ ЧАСТЬ ─────────
#
#   Вся магия эстетики — здесь.
#   Объяснение каждого параметра под секцией.

general {
    gaps_in = 6          # зазор МЕЖДУ окнами (пикселей)
    gaps_out = 14        # зазор от КРАЯ экрана
    border_size = 1      # толщина самой линии бордера

    # Активное окно: тонкая розовая линия
    col.active_border = rgba(c96070ff)

    # Неактивное: почти невидимое
    col.inactive_border = rgba(1a000800)

    layout = dwindle
    resize_on_border = true
}

decoration {
    rounding = 6         # скругление углов окна

    # Прозрачность
    active_opacity = 1.0
    inactive_opacity = 0.88    # неактивные окна чуть прозрачнее

    # Размытие внутри окна
    blur {
        enabled = false    # выключено — лаин-эстетика = чистый чёрный, без blur
    }

    # ── ГЛОУ-ЭФФЕКТ (главный элемент эстетики) ──────────────────────
    #
    #   Именно shadow создаёт светящийся ореол вокруг окна.
    #   Это НЕ настоящая тень — это имитация неонового свечения.
    #
    #   range        = радиус размытия глоу в пикселях
    #                  больше = мягче и дальше распространяется
    #                  на референсе примерно 40-60px
    #
    #   render_power = резкость краёв (1 = мягко, 4 = резко)
    #                  для неонового глоу нужно 1-2
    #
    #   color        = цвет + прозрачность (RGBA hex)
    #                  c96070 = приглушённый розово-малиновый
    #                  aa = ~67% прозрачности (можно менять)
    #
    #   offset       = смещение тени, 0 0 = равномерно со всех сторон
    # ─────────────────────────────────────────────────────────────────
    shadow {
        enabled = true
        range = 50
        render_power = 1
        offset = 0, 0
        color = rgba(c96070aa)
        color_inactive = rgba(00000000)   # у неактивных — нет глоу
    }
}

# ── АНИМАЦИИ ────────────────────────────
#
#   Hyprland использует кривые Безье для анимаций.
#   bezier = имя, x1, y1, x2, y2
#   Значения — контрольные точки кубической кривой Безье.
#
#   Полезный инструмент для подбора: https://cubic-bezier.com
#
#   animation = тип, вкл(1)/выкл(0), скорость, кривая, стиль
#   скорость: меньше = быстрее (1 = ~100мс, 6 = ~600мс)

animations {
    enabled = true

    # Кривые
    bezier = snap,    0.19, 1, 0.22, 1      # быстрый старт, плавное торможение
    bezier = linear,  1, 1, 1, 1
    bezier = lain,    0.0, 0.9, 0.1, 1.0    # плавный, чуть пружинистый

    # Появление/исчезновение окон
    animation = windows,     1, 4,  lain,   slide   # слайд при открытии
    animation = windowsOut,  1, 3,  snap,   slide
    animation = windowsMove, 1, 4,  lain

    # Прозрачность
    animation = fade,        1, 6,  default
    animation = fadeIn,      1, 4,  default
    animation = fadeOut,     1, 3,  default

    # Рабочие пространства
    animation = workspaces,  1, 4,  lain,   slidevert   # вертикальный слайд между WS
}

# ── ТАЙЛИНГ ─────────────────────────────

dwindle {
    pseudotile = true
    preserve_split = true
    force_split = 0          # 0 = авто-направление split
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

# Приложения
bind = $mod, Return,      exec, kitty
bind = $mod, E,           exec, thunar
bind = $mod, B,           exec, firefox
bind = $mod, Space,       exec, rofi -show drun
bind = $mod SHIFT, Space, exec, rofi -show run
bind = $mod, V,           exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy

# Управление окнами
bind = $mod, Q,           killactive
bind = $mod, F,           fullscreen, 0
bind = $mod SHIFT, F,     fullscreen, 1
bind = $mod, T,           togglesplit
bind = $mod, P,           pseudo
bind = $mod, M,           exec, wlogout
bind = $mod, L,           exec, hyprlock

# Фокус (HJKL + стрелки)
bind = $mod, H,           movefocus, l
bind = $mod, J,           movefocus, d
bind = $mod, K,           movefocus, u
bind = $mod, L,           movefocus, r
bind = $mod, left,        movefocus, l
bind = $mod, down,        movefocus, d
bind = $mod, up,          movefocus, u
bind = $mod, right,       movefocus, r

# Перемещение окон
bind = $mod SHIFT, H,     movewindow, l
bind = $mod SHIFT, J,     movewindow, d
bind = $mod SHIFT, K,     movewindow, u
bind = $mod SHIFT, L,     movewindow, r

# Ресайз
binde = $mod CTRL, H,     resizeactive, -30 0
binde = $mod CTRL, L,     resizeactive, 30 0
binde = $mod CTRL, K,     resizeactive, 0 -30
binde = $mod CTRL, J,     resizeactive, 0 30

# Плавающий
bind = $mod SHIFT, T,     togglefloating
bind = $mod, C,           centerwindow
bindm = $mod, mouse:272,  movewindow
bindm = $mod, mouse:273,  resizewindow

# Рабочие пространства
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

# Scratchpad
bind = $mod, S,           togglespecialworkspace, magic
bind = $mod SHIFT, S,     movetoworkspace, special:magic

# Скриншоты
bind = , Print,           exec, grimblast copy screen
bind = SHIFT, Print,      exec, grimblast save screen ~/Pictures/Screenshots/$(date +%Y%m%d_%H%M%S).png
bind = $mod, Print,       exec, grimblast copy area
bind = $mod SHIFT, Print, exec, grimblast save area - | swappy -f -

# Fn-клавиши
binde = , XF86AudioRaiseVolume,   exec, pamixer -i 5
binde = , XF86AudioLowerVolume,   exec, pamixer -d 5
bind  = , XF86AudioMute,          exec, pamixer -t
binde = , XF86MonBrightnessUp,    exec, brightnessctl set +5%
binde = , XF86MonBrightnessDown,  exec, brightnessctl set 5%-
bind  = , XF86AudioPlay,          exec, playerctl play-pause
bind  = , XF86AudioPrev,          exec, playerctl previous
bind  = , XF86AudioNext,          exec, playerctl next

# ── ПРАВИЛА ОКОН ─────────────────────────

windowrule = float, class:^(pavucontrol)$
windowrule = float, class:^(blueman-manager)$
windowrule = float, class:^(nm-connection-editor)$
windowrule = float, class:^(org.kde.polkit-kde-authentication-agent-1)$
windowrule = float, title:^(Picture-in-Picture)$
windowrule = center, class:^(pavucontrol)$

# Размытие waybar и rofi (слои, не окна)
layerrule = blur, waybar
layerrule = blur, rofi
layerrule = ignorezero, rofi
```

---

## ШАГ 4 — Waybar (минималистичный бар как на референсе)

### 4.1 Конфиг

На референсе бар очень минимальный:
- Слева: иконка терминала
- Центр: название активного окна
- Справа: сеть / батарея / время / яркость

```bash
nano ~/.config/waybar/config.jsonc
```

```jsonc
{
    "layer": "top",
    "position": "top",
    "height": 22,
    "margin-top": 0,
    "margin-left": 0,
    "margin-right": 0,
    "spacing": 0,
    "exclusive": true,

    "modules-left": [
        "custom/logo",
        "hyprland/workspaces"
    ],

    "modules-center": [
        "hyprland/window"
    ],

    "modules-right": [
        "network",
        "battery",
        "clock",
        "backlight",
        "custom/eye"
    ],

    "custom/logo": {
        "format": ">_ ",
        "tooltip": false
    },

    "hyprland/workspaces": {
        "format": "{id}",
        "on-click": "activate",
        "sort-by-number": true,
        "persistent-workspaces": {
            "*": 5
        }
    },

    "hyprland/window": {
        "max-length": 60,
        "separate-outputs": true,
        "format": "{}",
        "rewrite": {
            "(.*)": "$1"
        }
    },

    "clock": {
        "format": "{:%H:%M}",
        "format-alt": "{:%d.%m.%Y}",
        "tooltip": false
    },

    "battery": {
        "format": "{icon}{capacity}%",
        "format-charging": "↑{capacity}%",
        "format-icons": ["▂", "▃", "▅", "▆", "█"],
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
```

### 4.2 Стиль (CSS)

```bash
nano ~/.config/waybar/style.css
```

```css
/*
    WAYBAR — LAIN-CORE СТИЛЬ
    Минималистичный, тонкий, тёмный
    
    Как читать CSS-переменные:
    --bg       = цвет фона бара
    --fg       = цвет текста
    --accent   = розовый акцент
    --dim      = приглушённый текст (неактивные элементы)
*/

* {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 11px;
    border: none;
    border-radius: 0;
    min-height: 0;
    padding: 0;
    margin: 0;
}

/* ── Основной бар ───────────────────────────────────────────────────
   background: rgba(0,0,0, X) — X = прозрачность от 0.0 до 1.0
   border-bottom: тонкая линия снизу — как на референсе
   Можно поставить rgba(0,0,0,0) = полностью прозрачный бар
*/
window#waybar {
    background: rgba(0, 0, 0, 0.92);
    color: #c96070;
    border-bottom: 1px solid rgba(201, 96, 112, 0.3);
}

/* ── Рабочие пространства ─────────────────────────────────────────── */
#workspaces {
    padding: 0 6px;
}

#workspaces button {
    color: rgba(201, 96, 112, 0.35);
    background: transparent;
    padding: 0 4px;
    min-width: 0;
    transition: color 0.2s ease;
}

#workspaces button.active {
    color: #c96070;
}

#workspaces button:hover {
    color: rgba(201, 96, 112, 0.75);
    background: transparent;
    box-shadow: none;
}

/* ── Логотип слева ────────────────────────────────────────────────── */
#custom-logo {
    color: #c96070;
    padding: 0 8px 0 10px;
    font-weight: bold;
    letter-spacing: -1px;
}

/* ── Название окна (центр) ────────────────────────────────────────── */
#window {
    color: rgba(201, 96, 112, 0.6);
    font-size: 10px;
    letter-spacing: 1px;
    font-style: italic;
}

/* ── Правая часть — все модули ────────────────────────────────────── */
#clock,
#battery,
#network,
#backlight,
#custom-eye {
    color: rgba(201, 96, 112, 0.7);
    padding: 0 8px;
}

/* Разделитель между модулями */
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

/* Низкий заряд батареи */
#battery.warning {
    color: #e88a5a;
}

#battery.critical {
    color: #eb5050;
    animation: blink 1s step-end infinite;
}

@keyframes blink {
    50% { opacity: 0.3; }
}

#battery.charging {
    color: #7ec88e;
}

/* Глаз — декоративный элемент как на референсе */
#custom-eye {
    color: rgba(201, 96, 112, 0.4);
    padding-right: 12px;
    font-size: 12px;
}

/* Без сети */
#network.disconnected {
    color: rgba(201, 96, 112, 0.2);
}

/* ── Tooltip (всплывающая подсказка) ──────────────────────────────── */
tooltip {
    background: #0a0005;
    border: 1px solid rgba(201, 96, 112, 0.4);
    color: #c96070;
    border-radius: 4px;
    padding: 4px 8px;
}
```

---

## ШАГ 5 — Kitty (терминал как на референсе)

На референсе: чёрный фон, розовый промпт, beam-курсор мигающий, никаких табов.

```bash
nano ~/.config/kitty/kitty.conf
```

```ini
# ─────────────────────────────────────────
#   KITTY — LAIN-CORE
#   Чёрный + розовый, beam курсор
# ─────────────────────────────────────────

# Шрифт
font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
font_size        12.0

# Курсор
# beam  = вертикальная черта | (как на референсе)
# block = блок █
# underline = подчёркивание _
cursor_shape          beam
cursor_blink_interval 0.5          # скорость мигания (сек)
cursor_stop_blinking_after 0       # 0 = мигает всегда

# Цвета — чистый чёрный + розовые акценты
background            #000000
foreground            #c96070

# Выделение
selection_background  #1a0008
selection_foreground  #e8a0aa

# Курсор
cursor                #c96070
cursor_text_color     #000000

# 16 цветов терминала
# Нормальные
color0   #0a0005       # black
color1   #c96070       # red → наш основной акцент
color2   #5a8a6a       # green
color3   #c8a06a       # yellow
color4   #506890       # blue
color5   #9a6090       # magenta
color6   #6a9090       # cyan
color7   #a0909a       # white

# Яркие
color8   #3a1020       # bright black
color9   #e07080       # bright red
color10  #6aaa7a       # bright green
color11  #e0b070       # bright yellow
color12  #6080b0       # bright blue
color13  #b070a8       # bright magenta
color14  #70a8a8       # bright cyan
color15  #c096a0       # bright white

# Прозрачность фона
# 0.0 = полностью прозрачный, 1.0 = непрозрачный
background_opacity    0.95

# Окно
window_padding_width  12     # отступы внутри терминала (пиксели)
confirm_os_window_close 0    # не спрашивать при закрытии

# Убираем бар вкладок (как на референсе — нет табов)
tab_bar_style         hidden

# Убираем декорации окна (рамку рисует Hyprland)
hide_window_decorations yes

# Звук
enable_audio_bell no

# Внешний вид URL
url_color             #c96070
url_style             curly

# Копирование при выделении
copy_on_select        yes
```

---

## ШАГ 6 — Zsh + Starship промпт (как `> ~` на референсе)

### 6.1 Смена оболочки на zsh

```bash
chsh -s /bin/zsh
```

Перезайди в систему или выполни `zsh` для немедленного переключения.

### 6.2 Конфиг zsh

```bash
nano ~/.zshrc
```

```bash
# ─────────────────────────────────────────
#   ZSH CONFIG — LAIN-CORE
# ─────────────────────────────────────────

# История
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# Автодополнение
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Плагины
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Цвет подсказок автодополнения (серо-розовый)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#3a1020"

# Подсветка синтаксиса — розовая схема
ZSH_HIGHLIGHT_STYLES[command]='fg=#c96070'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#c96070,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#9a6090'
ZSH_HIGHLIGHT_STYLES[path]='fg=#a0909a'
ZSH_HIGHLIGHT_STYLES[string]='fg=#6aaa7a'

# Алиасы
alias ls='ls --color=auto'
alias ll='ls -la --color=auto'
alias grep='grep --color=auto'
alias cat='bat --theme=base16'      # замена cat (нужен: sudo pacman -S bat)
alias top='btop'

# Starship промпт
eval "$(starship init zsh)"

# Fastfetch при открытии терминала (опционально, закомментируй если не нужно)
# fastfetch
```

### 6.3 Starship — промпт как на референсе (`> ~`)

```bash
nano ~/.config/starship.toml
```

```toml
# ─────────────────────────────────────────
#   STARSHIP — LAIN-CORE ПРОМПТ
#   Минималистичный, розовый
#
#   Что такое промпт-модули:
#   Starship собирает промпт из "модулей" — каждый показывает
#   что-то своё: директорию, ветку git, язык и т.д.
#   Здесь всё максимально минимально как на референсе.
# ─────────────────────────────────────────

# Формат промпта (левая строка)
# $directory = текущая директория (~, ~/Documents и т.д.)
# $git_branch = ветка git если внутри репозитория
# $git_status = статус файлов в репозитории
# $line_break = перенос на новую строку
# $character = символ > в конце (сам курсор ввода)
format = """
$directory$git_branch$git_status$line_break$character"""

# Таймаут сканирования директории (мс)
scan_timeout = 30
command_timeout = 500

# Директория
[directory]
style = "fg:#c96070"
format = "[$path]($style) "
truncation_length = 3           # показывать последние N папок
truncate_to_repo = false

# Символ промпта (стрелка >)
[character]
success_symbol = "[>](fg:#c96070)"     # успешная команда
error_symbol   = "[>](fg:#eb5050)"     # ошибка (красный)
vimcmd_symbol  = "[<](fg:#9a6090)"     # vim-режим

# Git ветка
[git_branch]
style = "fg:#9a6090"
format = "[$branch]($style) "
symbol = ""

# Git статус
[git_status]
style = "fg:#3a1020"
format = "[$all_status$ahead_behind]($style) "

# Отключаем лишние модули
[nodejs]
disabled = true

[python]
disabled = true

[rust]
disabled = true

[package]
disabled = true

[cmd_duration]
disabled = false
style = "fg:#3a1020"
format = "[$duration]($style) "
min_time = 2000     # показывать только если дольше 2 секунд
```

---

## ШАГ 7 — Dunst (тёмные уведомления)

```bash
nano ~/.config/dunst/dunstrc
```

```ini
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

    mouse_left_click = close_current
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
```

---

## ШАГ 8 — Обои (как на референсе)

На референсе: тёмный аниме арт по центру, вокруг чёрный фон.

```bash
nano ~/.config/hypr/hyprpaper.conf
```

```ini
preload = ~/Pictures/wallpaper.png
wallpaper = , ~/Pictures/wallpaper.png
splash = false
```

**Как найти похожие обои:**

Ключевые слова для поиска: `lain serial experiments`, `dark anime wallpaper`, `glitch anime 4k black`.

Хорошие источники: [wallhaven.cc](https://wallhaven.cc) (тег: lain, dark-anime), [reddit.com/r/unixporn](https://reddit.com/r/unixporn).

---

## ШАГ 9 — Hyprlock (экран блокировки в том же стиле)

```bash
nano ~/.config/hypr/hyprlock.conf
```

```ini
background {
    monitor =
    path = ~/Pictures/wallpaper.png
    blur_passes = 2
    blur_size = 6
    brightness = 0.3       # затемнить обои на экране блокировки
    noise = 0.0117
    contrast = 1.3
}

input-field {
    monitor =
    size = 250, 40
    outline_thickness = 1
    outer_color = rgb(c96070)
    inner_color = rgb(000000)
    font_color = rgb(c96070)
    fade_on_empty = true
    placeholder_text = <i>········</i>
    rounding = 4
    position = 0, -60
    halign = center
    valign = center
    check_color = rgb(c96070)
    fail_color = rgb(eb5050)
    fail_text = <i>$FAIL</i>
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
```

```bash
nano ~/.config/hypr/hypridle.conf
```

```ini
general {
    lock_cmd = pidof hyprlock || hyprlock
    before_sleep_cmd = loginctl lock-session
    after_sleep_cmd = hyprctl dispatch dpms on
}

listener {
    timeout = 300
    on-timeout = brightnessctl -s set 0
    on-resume = brightnessctl -r
}

listener {
    timeout = 360
    on-timeout = loginctl lock-session
}

listener {
    timeout = 600
    on-timeout = systemctl suspend
}
```

---

## ШАГ 10 — Применение и перезапуск

```bash
# Перечитать конфиг Hyprland
hyprctl reload

# Перезапустить waybar
pkill waybar; waybar &

# Перезапустить dunst
pkill dunst; dunst &
```

Или полностью перелогиниться: `Super + M` → Logout.

---

## Как самостоятельно настраивать и кастомизировать

### Изменить цвет акцента

Текущий цвет `#c96070` — розово-малиновый. Ищи и меняй во всех файлах:

```bash
# Найти все вхождения во всех конфигах
grep -r "c96070" ~/.config/hypr ~/.config/waybar ~/.config/kitty ~/.config/dunst

# Заменить на другой цвет (например cyan #70c9c9) одной командой
find ~/.config/hypr ~/.config/waybar ~/.config/kitty ~/.config/dunst -type f \
  -exec sed -i 's/c96070/70c9c9/g; s/C96070/70C9C9/g' {} +
```

Популярные цвета для подобного стиля:

| Название | Hex | Эффект |
|---|---|---|
| Rose (текущий) | `#c96070` | Тёплый тёмно-розовый |
| Neon Pink | `#ff6090` | Более яркий неон |
| Cyan | `#70c9c9` | Холодный бирюзовый |
| Lime | `#90c970` | Хакерский зелёный |
| Violet | `#9070c9` | Фиолетовый |
| Gold | `#c9a070` | Янтарный |

---

### Настройка глоу-эффекта

В `hyprland.conf` найди секцию `shadow`:

```ini
shadow {
    range = 50          # ← ГЛАВНЫЙ ПАРАМЕТР
                        #   20 = маленький и резкий глоу
                        #   50 = средний (как на референсе)
                        #   80 = большой мягкий ореол

    render_power = 1    # 1 = очень мягкий край (как неон)
                        # 2 = чуть резче
                        # 4 = резкий (обычная тень)

    color = rgba(c96070aa)
    #              ^^^^ это прозрачность в hex
    # ff = полностью непрозрачный (очень яркий глоу)
    # aa = ~67% (как на референсе, умеренный)
    # 55 = ~33% (слабый, едва заметный)
}
```

---

### Настройка промпта starship

Файл: `~/.config/starship.toml`

Хочешь добавить что-то в промпт? Добавь модуль в `format`:

```toml
# Пример — добавить время
format = """$time$directory$git_branch$line_break$character"""

[time]
disabled = false
style = "fg:#3a1020"
format = "[$time]($style) "
time_format = "%H:%M"
```

Все доступные модули: [starship.rs/config](https://starship.rs/config/)

---

### Настройка анимаций Hyprland

```ini
# Пример — сделать анимации быстрее
animation = windows, 1, 2, lain, slide     # 2 вместо 4 = в 2 раза быстрее

# Отключить анимации совсем
animations {
    enabled = false
}

# Тип анимации окон:
# slide      = скользит с края
# slidevert  = скользит вертикально
# popin      = появляется из центра
# fade       = просто fade in/out
```

Подбирать кривые Безье удобно на сайте: https://cubic-bezier.com  
Четыре числа в `bezier = имя, x1, y1, x2, y2` — это контрольные точки.

---

### Как работают рабочие пространства в Hyprland

- `Super + 1-5` — переключиться на пространство
- `Super + Shift + 1-5` — переместить текущее окно туда
- `Super + Tab` — следующее пространство
- `Super + S` — скрытое пространство (scratchpad) — удобно для музыки, калькулятора

---

## Итоговая таблица горячих клавиш

| Клавиши | Действие |
|---|---|
| `Super + Enter` | Терминал |
| `Super + Space` | Лаунчер (rofi) |
| `Super + Q` | Закрыть окно |
| `Super + F` | Полный экран |
| `Super + L` | Заблокировать экран |
| `Super + M` | Меню выхода |
| `Super + T` | Плавающий режим |
| `Super + C` | Центрировать |
| `Super + S` | Scratchpad |
| `Super + HJKL` | Фокус (vim) |
| `Super + Shift + HJKL` | Переместить окно |
| `Super + Ctrl + HJKL` | Ресайз |
| `Super + 1-5` | Рабочее пространство |
| `Print` | Скриншот |
| `Super + Print` | Скриншот области |
| `Alt + Shift` | Смена раскладки |

---

## Что ещё можно добавить для полного образа

```bash
# bat — красивый cat с подсветкой кода
sudo pacman -S bat

# lsd — красивый ls с иконками
sudo pacman -S lsd

# zoxide — умный cd (запоминает часто используемые папки)
sudo pacman -S zoxide
# добавь в .zshrc: eval "$(zoxide init zsh)"

# pipes.sh — анимированные трубки в терминале
yay -S pipes.sh

# cmatrix — матричный дождь
sudo pacman -S cmatrix
```

---

*Вся конфигурация основана на анализе референс-скриншотов. Главные элементы эстетики — глоу через shadow, минимальный waybar, чёрный+розовый китти.*

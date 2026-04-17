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

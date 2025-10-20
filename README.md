<div align="center">

**ArpanSource's Hyprland Arch Rice**

*A beautifully crafted Hyprland desktop environment for Arch Linux*

[![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-00AAFF?style=for-the-badge&logo=hyprland&logoColor=white)](https://hyprland.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Keybindings](#%EF%B8%8F-keybindings) • [Customization](#-customization)

</div>

---

## 📸 Screenshots

> *Add your rice screenshots here*

<details>
<summary>Click to view more screenshots</summary>

<!-- Add more screenshots -->

</details>

## ✨ Features

- 🎨 **Beautiful Aesthetics** - Carefully chosen color schemes and themes
- ⚡ **Performance** - Optimized for speed and efficiency
- 🔧 **Modular Configuration** - Easy to customize and extend
- 🎯 **Productive Workflow** - Intuitive keybindings and workspace management
- 🌈 **Eye Candy** - Smooth animations and modern UI elements

## 🛠️ Components

| Component | Name | Description |
|-----------|------|-------------|
| **WM** | [Hyprland](https://hyprland.org/) | Dynamic tiling Wayland compositor |
| **Bar** | [Waybar](https://github.com/Alexays/Waybar) | Highly customizable status bar |
| **Terminal** | [Kitty](https://sw.kovidgoyal.net/kitty/) | GPU-accelerated terminal emulator |
| **Shell** | [Zsh](https://www.zsh.org/) | Powerful shell with Oh-My-Zsh |
| **Launcher** | [Rofi](https://github.com/lbonn/rofi) (Wayland fork) | Application launcher & window switcher |
| **Notifications** | [Mako](https://github.com/emersion/mako) | Lightweight notification daemon |
| **File Manager** | [Thunar](https://docs.xfce.org/xfce/thunar/start) | Modern file manager |
| **Editor** | [Neovim](https://neovim.io/) / [Zed](https://zed.dev/) | Text editors |
| **Browser** | [Brave](https://brave.com/) | Privacy-focused browser |
| **Lock Screen** | [Swaylock-effects](https://github.com/mortie/swaylock-effects) | Screen locker with effects |

## 📋 Requirements

### Mandatory
- Arch Linux (or Arch-based distro)
- Hyprland
- Waybar
- Kitty
- Rofi (Wayland fork)

### Optional
- Zsh & Oh-My-Zsh
- Mako
- Swaylock-effects
- Thunar
- Neovim/Zed

## 🚀 Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/arpansource/ashar.git
cd ashar

# Make the install script executable
chmod +x install.sh

# Run the installation
./install.sh
```

### Manual Installation

<details>
<summary>Click to expand manual installation steps</summary>

1. **Install Dependencies**
```bash
# Essential packages
sudo pacman -S hyprland waybar kitty rofi-wayland mako dunst \
               thunar polkit-gnome swaylock-effects \
               brightnessctl pamixer playerctl \
               grim slurp wl-clipboard cliphist

# Optional packages
sudo pacman -S zsh neovim btop fastfetch \
               network-manager-applet blueman
```

2. **Install AUR packages**
```bash
# Using yay
yay -S swww hyprpicker-git
```

3. **Backup existing configs**
```bash
# Backup your current configs (if any)
mkdir -p ~/.config/backup
cp -r ~/.config/hypr ~/.config/backup/
cp -r ~/.config/waybar ~/.config/backup/
# ... backup other configs as needed
```

4. **Copy configurations**
```bash
# Copy all configs
cp -r .config/* ~/.config/
cp -r .local/* ~/.local/
cp -r wallpapers ~/Pictures/
```

5. **Set Zsh as default shell**
```bash
chsh -s $(which zsh)
```

6. **Reboot or restart Hyprland**
```bash
# Logout and login to Hyprland
# Or press Super + Shift + E (exit Hyprland)
```

</details>

## ⌨️ Keybindings

### General

| Key Combination | Action |
|----------------|--------|
| `Super + Return` | Open terminal (Kitty) |
| `Super + Q` | Close active window |
| `Super + D` | Open app launcher (Rofi) |
| `Super + E` | Open file manager |
| `Super + F` | Toggle fullscreen |
| `Super + Space` | Toggle floating mode |
| `Super + Shift + E` | Exit Hyprland |
| `Super + L` | Lock screen |

### Window Management

| Key Combination | Action |
|----------------|--------|
| `Super + H/J/K/L` | Move focus (Vim keys) |
| `Super + Shift + H/J/K/L` | Move window |
| `Super + Ctrl + H/J/K/L` | Resize window |
| `Super + 1-9` | Switch to workspace 1-9 |
| `Super + Shift + 1-9` | Move window to workspace 1-9 |
| `Super + Mouse Left` | Move window |
| `Super + Mouse Right` | Resize window |

### Screenshot

| Key Combination | Action |
|----------------|--------|
| `Print` | Screenshot (full screen) |
| `Super + Print` | Screenshot (select area) |
| `Super + Shift + Print` | Screenshot (active window) |

### Media Controls

| Key Combination | Action |
|----------------|--------|
| `XF86AudioPlay` | Play/Pause |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Toggle mute |
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |

## 🎨 Customization

### Changing Theme Colors

Edit `~/.config/hypr/colors.conf`:
```conf
$background = rgb(1e1e2e)
$foreground = rgb(cdd6f4)
$accent = rgb(89b4fa)
# ... modify colors as needed
```

### Changing Wallpaper

```bash
# Using swww
swww img ~/Pictures/wallpapers/your-wallpaper.jpg --transition-type fade
```

### Waybar Customization

Edit `~/.config/waybar/config` and `~/.config/waybar/style.css` to customize your bar.

### Terminal Font & Colors

Edit `~/.config/kitty/kitty.conf` to change terminal appearance.

## 📁 Directory Structure

```
ashar/
├── .config/
│   ├── hypr/              # Hyprland configuration
│   │   ├── hyprland.conf
│   │   ├── colors.conf
│   │   └── keybindings.conf
│   ├── waybar/            # Waybar configuration
│   ├

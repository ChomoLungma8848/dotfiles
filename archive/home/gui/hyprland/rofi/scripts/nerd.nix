{ pkgs }:
let
  nerdFontIcons = pkgs.writeText "nerd-icons.txt" ''
    nf-dev-git  Git
    nf-fa-git  Git
    nf-dev-git_commit  Git commit
    nf-dev-git_branch  Git branch
    nf-dev-git_merge  Git merge
    nf-dev-git_compare  Git compare
    nf-dev-git_pull_request  Git pull request
    nf-dev-github  GitHub
    nf-dev-docker 󰡨 Docker
    nf-dev-c  C
    nf-dev-rust  Rust
    nf-dev-python  Python
    nf-custom-go  Go
    nf-md-language_go 󰟓 Golang
    nf-dev-java  Java
    nf-dev-javascript  JavaScript
    nf-dev-typescript  TypeScript
    nf-dev-react  React
    nf-dev-bun  Bun
    nf-dev-nodejs  Node.js
    nf-md-nodejs 󰎙 Node.js
    nf-dev-npm  npm
    nf-dev-yarn  Yarn
    nf-dev-pnpm  Pnpm
    nf-dev-nextjs  nextjs
    nf-dev-prisma  Prisma
    nf-dev-html5  HTML
    nf-dev-css3  CSS
    nf-md-xml 󰗀 XML
    nf-dev-sass  Sass
    nf-dev-postgresql  PostgreSQL
    nf-dev-mysql  MySQL
    nf-dev-sqlite  SQLite
    nf-dev-markdown  Markdown
    nf-dev-lua  Lua
    nf-md-nix 󱄅 Nix
    nf-dev-vim  Vim
    nf-dev-linux  Linux
    nf-linux-tux  tux
    nf-dev-nixos  NixOS
    nf-fa-ubuntu  Ubuntu
    nf-dev-archlinux  Arch Linux
    nf-dev-debian  Debian
    nf-dev-fedora  Fedora
    nf-fa-redhat  redhat
    nf-fa-suse  SUSE
    nf-dev-apple  Apple
    nf-dev-windows  Windows
    nf-linux-hyprland  Hyprlnad
    nf-dev-aws  AWS
    nf-dev-gnu  GNU
    nf-fa-amazon  amazon
    nf-md-folder 󰉋 Folder
    nf-md-file 󰈔 File
    nf-md-file_code 󰈮 Code File
    nf-md-file_document 󰈙 Document
    nf-md-file_image 󰈟 Image
    nf-md-file_music 󰈣 Music
    nf-md-file_video 󰈫 Video
    nf-md-file_pdf 󰈦 PDF
    nf-md-zip_box  Archive
    nf-md-database 󰆼 Database
    nf-md-server 󰒋 Server
    nf-md-cloud 󰅟 Cloud
    nf-md-wifi 󰖩 WiFi
    nf-md-bluetooth 󰂯 Bluetooth
    nf-md-battery 󰁹 Battery
    nf-md-volume_high 󰕾 Volume
    nf-md-brightness_6 󰃟 Brightness
    nf-md-power 󰐥 Power
    nf-md-lock 󰌾 Lock
    nf-md-cog 󰒓 Settings
    nf-md-magnify 󰍉 Search
    nf-md-home 󰋜 Home
    nf-md-account 󰀄 User
    nf-md-email 󰇮 Email
    nf-md-calendar 󰃭 Calendar
    nf-md-clock 󰥔 Clock
    nf-md-download 󰇚 Download
    nf-md-upload 󰕒 Upload
    nf-md-refresh 󰑓 Refresh
    nf-md-check 󰄬 Check
    nf-md-close 󰅖 Close
    nf-md-plus 󰐕 Plus
    nf-md-minus 󰍴 Minus
    nf-md-arrow_left 󰁍 Arrow Left
    nf-md-arrow_right 󰁔 Arrow Right
    nf-md-arrow_up 󰁝 Arrow Up
    nf-md-arrow_down 󰁅 Arrow Down
    nf-md-star 󰓎 Star
    nf-md-heart 󰋑 Heart
    nf-md-bookmark 󰃀 Bookmark
    nf-md-tag 󰓹 Tag
    nf-md-comment 󰆉 Comment
    nf-md-share 󰒖 Share
    nf-md-link 󰌷 Link
    nf-md-image 󰋩 Image
    nf-md-camera 󰄀 Camera
    nf-md-video 󰕧 Video
    nf-md-microphone 󰍬 Microphone
    nf-md-headphones 󰋋 Headphones
    nf-md-gamepad 󰊗 Gamepad
    nf-md-keyboard 󰌌 Keyboard
    nf-md-mouse 󰍽 Mouse
    nf-md-monitor 󰍹 Monitor
    nf-md-laptop 󰌢 Laptop
    nf-md-cellphone 󰄜 Phone
    nf-md-tablet 󰓶 Tablet
    nf-md-printer 󰐪 Printer
    nf-md-usb 󰕓 USB
    nf-md-sd 󰆔 SD Card
    nf-md-console 󰆍 Terminal
    nf-md-code_braces 󰅪 Code
    nf-md-bug 󰃤 Bug
    nf-md-wrench 󰖷 Wrench
    nf-md-hammer 󰣈 Hammer
    nf-md-palette 󰏘 Palette
    nf-md-brush 󰃢 Brush
    nf-md-pencil 󰏫 Pencil
    nf-md-eraser 󰇾 Eraser
    nf-md-scissors 󰆐 Scissors
    nf-md-ruler 󰟉 Ruler
    nf-md-compass 󰀹 Compass
    nf-md-map 󰆋 Map
    nf-md-navigation 󰆌 Navigation
    nf-md-earth 󰇧 Earth
    nf-md-sun 󰖨 Sun
    nf-md-moon 󰽥 Moon
    nf-md-weather_cloudy 󰖐 Cloud
    nf-md-weather_rainy 󰖗 Rain
    nf-md-weather_snowy 󰖘 Snow
    nf-md-fire 󰈸 Fire
    nf-md-water 󰖌 Water
    nf-md-leaf 󰌪 Leaf
    nf-md-flower 󰌻 Flower
    nf-md-tree 󰐅 Tree
    nf-cod-edit  Edit
    nf-fa-edit  Edit
    nf-cod-triangle_down  Triangle Down
    nf-cod-triangle_left  Triangle Left
    nf-cod-triangle_right  Triangle Right
    nf-cod-triangle_up  Triangle Up
    nf-ple-lower_left_triangle  Lower Left Triangle
    nf-ple-lower_right_triangle  Lower Right Triangle
    nf-ple-upper_left_triangle  Upper Left Triangle
    nf-ple-upper_right_triangle  Upper Right Triangle
    nf-md-square 󰝤 Square
    nf-cod-terminal_bash  Bash
    nf-md-firefox 󰈹 Firefox
    nf-fa-chrome  Chrome
    nf-dev-google  Google
    nf-fa-discord  Discord
    nf-md-steam 󰓓 Steam
    nf-md-spotify 󰓇 Spotify
    nf-md-slack 󰒱 Slack
    nf-dev-notion  Notion
    nf-md-telegram 󰔁 Telegram
    nf-cod-vscode 󰨞 VSCode
    nf-custom-neovim  Neovim
  '';
in
pkgs.writeShellScriptBin "rofi-nerd" ''
  export PATH="${pkgs.wl-clipboard}/bin:${pkgs.gawk}/bin:$PATH"

  selected=$(cat ${nerdFontIcons} | rofi -dmenu -i -p "󰀬 Nerd Icons" -theme-str 'listview { lines: 15; }')

  if [ -n "$selected" ]; then
    # アイコン部分を抽出 (2番目のフィールド)
    icon=$(echo "$selected" | awk '{print $2}')
    echo -n "$icon" | wl-copy
    notify-send "󰀬 Nerd Icons" "Copied: $icon"
  fi
''

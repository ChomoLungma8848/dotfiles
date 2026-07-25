{ ... }:
{
  xdg.configFile."rofi/config.rasi".text = ''
    @theme "catppuccin-mocha"
  '';

  xdg.configFile."rofi/catppuccin-mocha.rasi".text = ''
    * {
      bg: #1e1e2e;
      bg-alt: #313244;
      bg-selected: #45475a;
      fg: #cdd6f4;
      fg-alt: #7f849c;
      accent: #89b4fa;
      urgent: #f38ba8;

      background-color: transparent;
      text-color: @fg;
      border-color: @accent;
    }

    window {
      width: 600px;
      background-color: @bg;
      border: 2px solid;
      border-color: @accent;
      border-radius: 12px;
      padding: 0;
    }

    mainbox {
      padding: 16px;
      spacing: 12px;
    }

    inputbar {
      background-color: @bg-alt;
      padding: 12px 16px;
      border-radius: 8px;
      spacing: 12px;
      children: [ prompt, entry ];
    }

    prompt {
      text-color: @accent;
      font: "JetBrainsMono Nerd Font Bold 12";
    }

    entry {
      placeholder: "Type to search...";
      placeholder-color: @fg-alt;
    }

    message {
      background-color: @bg-alt;
      padding: 12px;
      border-radius: 8px;
    }

    textbox {
      text-color: @fg;
    }

    listview {
      lines: 8;
      columns: 1;
      fixed-height: false;
      scrollbar: false;
      spacing: 4px;
    }

    element {
      padding: 10px 14px;
      border-radius: 8px;
      spacing: 12px;
    }

    element normal.normal {
      background-color: transparent;
    }

    element selected.normal {
      background-color: @bg-selected;
      text-color: @accent;
    }

    element alternate.normal {
      background-color: transparent;
    }

    element-icon {
      size: 24px;
      vertical-align: 0.5;
    }

    element-text {
      vertical-align: 0.5;
      highlight: bold underline;
    }

    /* モード切り替えタブ */
    mode-switcher {
      background-color: @bg-alt;
      padding: 8px;
      border-radius: 8px;
      spacing: 8px;
    }

    button {
      padding: 8px 16px;
      border-radius: 6px;
      text-color: @fg-alt;
    }

    button selected {
      background-color: @accent;
      text-color: @bg;
    }
  '';
}

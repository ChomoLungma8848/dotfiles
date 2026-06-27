{ pkgs, ... }:
{
  programs.vesktop = {
    enable = true;

    # vesktop
    settings = {
      # --- general ---
      discordBranch = "canary";

      # --- tray ---
      tray = false;
      minimizeToTray = false;
      clickTrayToShowHide = false;
      autoStartMinimized = false;

      # --- UI ---
      staticTitle = true;
      customTitleBar = false;
      enableMenu = false;
      openLinksWithElectron = false;
      disableSmoothScroll = false;
      disableMinSize = true;

      # --- performance ---
      hardwareAcceleration = true;
      hardwareVideoAcceleration = false;

      # --- notice ---
      appBadge = false;
      enableTaskbarFlashing = false;

      # --- Rich Presence ---
      arRPC = true;

      # --- spell check ---
      spellCheckLanguages = [
        "en-US"
        "ja"
      ];

      # --- splash ---
      enableSplashScreen = false;
      splashTheming = false;
      splashColor = "#cba6f7";
      splashBackground = "#1e1e2e";
      splashPixelated = false;

      # --- venmic/PipeWire ---
      audio = {
        workaround = false;
        deviceSelect = true;
        granularSelect = true;
        ignoreVirtual = false;
        ignoreDevices = false;
        ignoreInputMedia = false;
        onlySpeakers = true;
        onlyDefaultSpeakers = false;
      };
    };

    # vencode
    vencord = {
      # --- enable vencord from Nixpkgs ---
      useSystem = true;

      # --- themes ---
      themes = {
        catppuccin = pkgs.fetchurl {
          url = "https://catppuccin.github.io/discord/dist/catppuccin-macchiato.theme.css";
          hash = "sha256-dHQhESjRhvlO24uzqgpQU+WYdkd93er2HNx8rJt6YbI=";
        };
      };

      # settings = {
      #   # --- auto update ---
      #   autoUpdate = false;
      #   autoUpdateNotification = false;
      #
      #   # --- theme ---
      #   useQuickCss = true;
      #   enabledThemes = [ "catppucin.css" ];
      #   themeLinks = [];
      #
      #   # --- window ---
      #   frameless = true;
      #   transparent = true;
      #   disableMinSize = true;
      #
      #   # --- other ---
      #   eagerPatches = false;
      #   enableReactDevtools = false;
      #
      #   # --- plugins ---
      #   plugins = {
      #     BetterFolders = {
      #       enabled = true;
      #       sidebar = true;
      #       sidebarAnim = true;
      #       closeAllFolder = false;
      #       closeAllHomeButton = false;
      #       closeOthors = false;
      #       forceOpen = false;
      #       keepIcons = false;
      #       showFolderIcon = "Always";
      #     };
      #
      #     BetterSettings = {
      #       enabled = true;
      #       disableFade = true;
      #       organizeMenu = true;
      #       eagerLoad = true;
      #     };
      #
      #     BiggerStreamPreview = {
      #       enabled = true;
      #     };
      #
      #     ClearURLs = {
      #       enabled = true;
      #     };
      #
      #     CrashHandler = {
      #       enabled = true;
      #     };
      #
      #     CustomRPC = {
      #       enabled = true;
      #     };
      #
      #     Decor = {
      #       enabled = true;
      #     };
      #
      #     FakeNitro = {
      #       enabled = true;
      #       enableEmojiBypass = true;
      #       emojiSize = 48;
      #       transformEmojis = true;
      #       enableStickerBypass =true;
      #       stickerSize = 160;
      #       transformStickers = true;
      #       transformCompoundSentence = false;
      #       enableStreamQualityBypass = true;
      #       useHyperLinks = true;
      #       # hyprLinkText = "";
      #       # disableEmbedPermissonCheck = true;
      #     };
      #
      #     FakeProfileThemes = {
      #       enabled = true;
      #       nitroFirst = "Nitro colors";
      #     };
      #
      #     FavEmojiFirst = {
      #       enabled = true;
      #     };
      #
      #     ReadAllNotificationsButton = {
      #       enabled = true;
      #     };
      #
      #     ShowAllMessageButtons = {
      #       enabled = true;
      #     };
      #
      #     Translate = {
      #       enabled = true;
      #       service = "google";
      #       autoTranslate = false;
      #       showAutoTranslateTooltip = true;
      #       receivedInput = "auto";
      #       receivedOutput = "ja";
      #       sentInput = "auto";
      #       sentOutput = "en";
      #     };
      #
      #     USRBG = {
      #       enabled = true;
      #       nitroFirst = "Nitro Banner";
      #       voiceBackground = true;
      #     };
      #
      #     ViewIcons = {
      #       enabled = true;
      #       format = "png";
      #       imgSize = 1024;
      #     };
      #   };
      #
      #   # --- uiElements ---
      #   uiElements = {
      #     messagePopverButtons = {};
      #     chatBarButtons = {};
      #   };
      #
      #   # --- notice ---
      #   notifications = {
      #     timeout = 5000;
      #     position = "top-right";
      #     useNative = "not-focused";
      #     logLimit = 50;
      #   };
      #
      #   # --- cloud ---
      #   cloud = {
      #     authenticated = false;
      #     url = "https://api.vencord.dev/";
      #     settingsSync = false;
      #     settingsSyncVersion = 0;
      #   };
      # };
    };
  };
}

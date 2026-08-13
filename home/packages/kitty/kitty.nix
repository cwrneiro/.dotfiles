# kitty — native home-manager module.
#
# kitty has no scripting (pure key=value), so the typed `settings` map is
# lossless and preferable to a raw kitty.conf. STARTER values below; fill in
# your real theme/font.
{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      confirm_os_window_close = 0;
      # font_family = "Hack Nerd Font";
      # font_size = 13;
    };

    # If you'd rather keep an existing kitty.conf verbatim, drop it next to this
    # file and use instead:
    #   extraConfig = builtins.readFile ./kitty.conf;
  };
}

# kitty — the real config kept verbatim (it mixes settings, keymaps and an
# include, so a raw kitty.conf is simpler than the typed `settings` map).
#
# The two kittens referenced by kitty.conf (`+kitten search.py`) are placed
# alongside the config in ~/.config/kitty/. The Linux-only quickshell theme
# `include` is appended by home/linux.nix (kitty.conf has none on purpose).
#
# Font: JetBrains Mono Nerd Font — installed via home.packages in common.nix.
{ ... }:

{
  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./kitty.conf;
  };

  # Kittens must sit in the kitty config dir so `+kitten search.py` resolves.
  xdg.configFile."kitty/search.py".source = ./search.py;
  xdg.configFile."kitty/scroll_mark.py".source = ./scroll_mark.py;
}

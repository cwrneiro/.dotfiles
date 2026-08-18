# AeroSpace — i3-style tiling window manager for macOS (macOS-only; imported
# from home/darwin.nix, not common.nix).
#
# Config-file strategy (DECISIONS.md §4): the real aerospace.toml is kept
# VERBATIM rather than re-encoded into a Nix attrset. The home-manager module
# only writes a config file when `settings != {}`, so we leave `settings` empty
# and use the module purely for its correctly-wired launchd agent (it launches
# AeroSpace.app/Contents/MacOS/AeroSpace, which is what macOS grants the
# Accessibility permission to). The verbatim toml goes in via xdg.configFile
# below — no collision, since the module writes nothing.
{ pkgs, ... }:

{
  programs.aerospace = {
    enable = true;
    # launchd owns startup + keep-alive. This also means AeroSpace must NOT
    # manage its own login item, so aerospace.toml has `start-at-login = false`.
    launchd.enable = true;
    # settings intentionally omitted ({}) -> module does not generate the config.
  };

  # Verbatim aerospace.toml (like kitty.conf). The only transformation is
  # swapping the old Homebrew sketchybar path for the Nix-provided binary, so
  # the workspace-change triggers keep firing after we drop brew. Using the
  # absolute store path makes it independent of the launchd/GUI PATH.
  xdg.configFile."aerospace/aerospace.toml".text =
    builtins.replaceStrings
      [ "@sketchybar@" ]
      [ "${pkgs.sketchybar}/bin/sketchybar" ]
      (builtins.readFile ./aerospace.toml);
}

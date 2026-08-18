# SketchyBar — the macOS menu-bar replacement (macOS-only; imported from
# home/darwin.nix, not common.nix).
#
# Config strategy: this is a modified fork of a third-party bash config that
# was deliberately disconnected from upstream, so the runtime tree is vendored
# into ./config and symlinked into ~/.config/sketchybar verbatim. Only the
# files sketchybarrc actually sources are kept (scripts + the two helper
# binaries `menubar`/`ft-haptic`, which are NOT in nixpkgs and are aliased via
# $RELPATH by the plugins); the redundant 596KB `sketchybar` binary that shipped
# in the fork is dropped because Nix provides that one.
#
# There is no home-manager services.sketchybar module (unlike nix-darwin), so
# the daemon is started with a plain launchd agent. sketchybar with no args
# loads ~/.config/sketchybar/sketchybarrc.
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    sketchybar
    sketchybar-app-font # app-name glyphs used by the spaces item
  ];

  # Vendored config tree -> ~/.config/sketchybar (individual symlinks so the
  # dir is real and the executable bit on the scripts + helper binaries is
  # preserved from the Nix store).
  xdg.configFile."sketchybar" = {
    source = ./config;
    recursive = true;
  };

  # macOS does not register Nix-installed fonts; link the app-font where the OS
  # (and thus sketchybar) will find it, mirroring the JetBrains Mono link in
  # home/darwin.nix.
  home.file."Library/Fonts/sketchybar-app-font.ttf".source =
    "${pkgs.sketchybar-app-font}/share/fonts/truetype/sketchybar-app-font.ttf";

  # Run sketchybar as a launchd user agent. The daemon hands this environment
  # to the event/plugin scripts it spawns, so PATH must already contain
  # everything they call (the Nix profile for `sketchybar` itself, Homebrew and
  # the system dirs for the usual CLI tools). sketchybarrc extends PATH further
  # for its own process, but spawned scripts only see what is set here.
  launchd.agents.sketchybar = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.sketchybar}/bin/sketchybar" ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Interactive";
      EnvironmentVariables.PATH =
        "${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      StandardOutPath = "/tmp/sketchybar.out.log";
      StandardErrorPath = "/tmp/sketchybar.err.log";
    };
  };
}

# TEMPLATE — copy this when adding a new program:
#
#   mkdir -p home/packages/<name>
#   cp home/packages/template.nix home/packages/<name>/<name>.nix
#   # then add  ./packages/<name>/<name>.nix  to `imports` in home/common.nix
#
{ config, pkgs, ... }:

{
  # Packages this program needs on PATH.
  home.packages = with pkgs; [
    # <package>
  ];

  # If home-manager has a native module for it, prefer that (typed + lossless
  # for settings-style configs like kitty/git/starship):
  # programs.<name> = {
  #   enable = true;
  # };

  # If the program's real config is easier kept as a native file (scripting,
  # or you want to paste an existing dotfile verbatim), co-locate it here and
  # point at it — this is the reference repo's main pattern:
  # xdg.configFile."<name>/<file>".source = ./<file>;
}

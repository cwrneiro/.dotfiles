# Shared Linux home-manager bits (Arch + NixOS). Imports the shared config and
# adds the pieces common to both Linux targets.
{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    gcc       # C compiler for nvim-treesitter parser builds
    xdg-utils # provides `xdg-open`, used by the Neovim config's image/PDF open
  ];
}

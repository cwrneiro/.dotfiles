# macOS-only home-manager bits. Imports the shared config and adds the pieces
# that differ on Darwin.
{ pkgs, ... }:

{
  imports = [ ./common.nix ];

  home.packages = with pkgs; [
    clang # C compiler for nvim-treesitter parser builds (macOS uses clang)
  ];

  # Notes:
  #   - macOS ships `open`; the Neovim config already branches on jit.os, so no
  #     xdg-open shim is needed here.
  #   - There is no good Nix `zathura`/`feh` on Darwin; if you later add a PDF/
  #     image viewer, pick a mac-friendly one here.
}

# Shared home-manager configuration imported by every host.
#
# Responsibilities:
#   - set the user identity (threaded in from flake.nix via extraSpecialArgs)
#   - aggregate the per-program package modules (one `imports` line each)
#
# OS-specific bits live in home/darwin.nix and home/linux.nix, which import
# THIS file. So the chain is:  hosts/<host>.nix -> {darwin,linux}.nix -> common.nix
{ config, pkgs, username, homeDirectory, ... }:

{
  # ---- Per-program modules (the reference repo's pattern) --------------------
  # Toggle a program on/off by (un)commenting its line here. Each module lives
  # in its own directory under home/packages/<name>/ and owns its settings and
  # (where useful) a co-located native config file.
  imports = [
    ./packages/neovim/neovim.nix
    ./packages/zsh/zsh.nix
    ./packages/kitty/kitty.nix
    ./packages/tmux/tmux.nix
    ./packages/ohmyposh/ohmyposh.nix
    # ./packages/<name>/<name>.nix   <- add new programs here
  ];

  # ---- Identity --------------------------------------------------------------
  home.username = username;
  home.homeDirectory = homeDirectory;

  # See DECISIONS.md ("stateVersion"). Do NOT bump casually.
  home.stateVersion = "25.05";

  # Let home-manager manage itself, so this works on non-NixOS (macOS, Arch).
  programs.home-manager.enable = true;

  # Nerd Font: JetBrains Mono (kitty's font + nvim/render-markdown icons).
  # On Linux, fontconfig picks it up from the profile; on macOS it is also
  # linked into ~/Library/Fonts by home/darwin.nix (Nix fonts aren't auto-
  # registered there).
  fonts.fontconfig.enable = true;
  home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
}

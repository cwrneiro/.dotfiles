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

  # Standard XDG user-bin (pipx, pip --user, the Omnigent installer's binary).
  # Cross-platform: applies to login + non-login shells, no duplicate appends on
  # re-source. Replaces the old per-OS definitions (Arch .zshrc export, macOS
  # zsh envExtra).
  home.sessionPath = [ "$HOME/.local/bin" ];

  # See DECISIONS.md ("stateVersion"). Do NOT bump casually.
  home.stateVersion = "25.05";

  # Let home-manager manage itself, so this works on non-NixOS (macOS, Arch).
  programs.home-manager.enable = true;

  # Nerd Font: JetBrains Mono (kitty's font + nvim/render-markdown icons).
  # fontconfig is a Linux mechanism (the profile font dir is picked up there);
  # macOS uses CoreText and finds the font via the ~/Library/Fonts link in
  # home/darwin.nix instead, so enabling fontconfig on Darwin would only add an
  # unused font cache to the closure — hence Linux-only.
  fonts.fontconfig.enable = pkgs.stdenv.hostPlatform.isLinux;

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    # Shell CLIs (also used by nvim/telescope, but nixCats bakes its own copies
    # into the wrapped nvim — these are for the interactive shell). On macOS they
    # replace the brew-installed ripgrep/fd.
    ripgrep
    fd
  ];
}

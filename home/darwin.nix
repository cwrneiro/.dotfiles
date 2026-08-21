# macOS-only home-manager bits. Imports the shared config and adds the pieces
# that differ on Darwin — most notably the machine-specific zsh setup ported
# from the old ~/.zshrc / ~/.zprofile / ~/.zshenv.
{ pkgs, lib, ... }:

{
  imports = [
    ./common.nix
    # macOS-only programs (aerospace/sketchybar aren't packaged for Linux and
    # the aerospace module asserts a Darwin platform).
    ./packages/aerospace/aerospace.nix
    ./packages/sketchybar/sketchybar.nix
  ];

  home.packages = with pkgs; [
    clang # C compiler for nvim-treesitter parser builds (macOS uses clang)
  ];

  # Spotlight (Cmd+Space) won't index GUI apps that home-manager links as
  # symlinks into /nix/store (e.g. kitty). A Finder *alias* gets indexed but
  # shows up as an "alias" with a badge — ugly. So instead drop a REAL copy of
  # each app bundle under ~/Applications/Nix Apps: it appears as a normal app
  # with the proper icon. The bundle still references /nix/store internally
  # (which persists), so it launches fine. Rebuilt each activation to track
  # store-path bumps. readlink is single-hop (BSD-safe) since HM links point
  # straight at the store.
  home.activation.copyNixApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    nixApps="$HOME/Applications/Nix Apps"
    run rm -rf "$nixApps"
    run mkdir -p "$nixApps"
    for app in "$HOME/Applications/Home Manager Apps/"*.app; do
      [ -e "$app" ] || continue
      dst="$nixApps/$(basename "$app")"
      run cp -R "$(readlink "$app")" "$dst"
      run chmod -R u+w "$dst"   # store copies are read-only; let macOS manage it
    done
  '';

  # macOS doesn't register Nix-installed fonts, so link the Nerd Font (used by
  # kitty + nvim icons) into ~/Library/Fonts where the OS will find it.
  home.file."Library/Fonts/JetBrainsMonoNerdFont" = {
    source = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype";
    recursive = true;
  };

  # ---- macOS-specific zsh -----------------------------------------------------
  # Login shell (.zprofile): Homebrew, framework Python, Obsidian.
  programs.zsh.profileExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Framework Python 3.13
    PATH="/Library/Frameworks/Python.framework/Versions/3.13/bin:''${PATH}"
    export PATH

    # Obsidian
    export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
  '';

  # Work aliases (moved out of initContent so they get Nix-level dedup/collision
  # detection). claudio: macOS binds it to `claude` (Linux uses plain claude).
  programs.zsh.shellAliases = {
    claudio = "claude";
    work = "claude";
  };

  # Interactive (.zshrc). mkBefore runs before compinit (fpath must precede it);
  # mkAfter runs after the shared setup and the oh-my-posh init.
  programs.zsh.initContent = lib.mkMerge [
    (lib.mkBefore ''
      fpath+=/opt/homebrew/share/zsh/site-functions
      autoload -U +X bashcompinit && bashcompinit
    '')
    (lib.mkAfter ''
      ulimit -n 10240

      # Google Cloud SDK
      source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"

      # work env (aliases live in programs.zsh.shellAliases above)
      export ALPHA_OPT_IN=true
      export PRIVACY_SUMMARIZATION=false
    '')
  ];

  # Notes:
  #   - macOS ships `open`; the Neovim config branches on jit.os, so no xdg-open
  #     shim is needed here.
}

# macOS-only home-manager bits. Imports the shared config and adds the pieces
# that differ on Darwin — most notably the machine-specific zsh setup ported
# from the old ~/.zshrc / ~/.zprofile / ~/.zshenv.
{ pkgs, lib, ... }:

{
  imports = [ ./common.nix ];

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

  # Always-sourced (.zshenv): uv.
  programs.zsh.envExtra = ''
    export PATH="$HOME/.local/bin:$PATH"
  '';

  # Interactive (.zshrc). mkBefore runs before compinit (fpath must precede it);
  # mkAfter runs after the shared setup and the oh-my-posh init.
  programs.zsh.initContent = lib.mkMerge [
    (lib.mkBefore ''
      fpath+=/opt/homebrew/share/zsh/site-functions
      autoload -U +X bashcompinit && bashcompinit
    '')
    (lib.mkAfter ''
      ulimit -n 10240

      # bun
      export BUN_INSTALL="$HOME/Library/Application Support/reflex/bun"
      export PATH="$BUN_INSTALL/bin:$PATH"

      # Rancher Desktop
      export PATH="$HOME/.rd/bin:$PATH"

      # Google Cloud SDK
      source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"

      # work aliases / env
      alias claudio='claude'
      alias work="claude"
      export ALPHA_OPT_IN=true
      export PRIVACY_SUMMARIZATION=false

      # claude-tmux (scripts live unmanaged in ~/.config/tmux/scripts/)
      alias ct="~/.config/tmux/scripts/claude-tmux.sh"
      alias ct-cleanup="~/.config/tmux/scripts/claude-tmux-cleanup.sh"

      # token usage YTD
      tokens-ytd() {
        work usage --days 365 2>/dev/null \
          | sed -n '/^Daily Breakdown/,/^Last.*Sessions/{ /^Last/d; p; }' \
          | awk -F'│' '/^│/ && NF>4 {gsub(/^ +| +$/,"",$5); if($5 != "" && $5 != "-") print $5}' \
          | sed 's/M/*1000000/;s/k/*1000/' \
          | bc \
          | LC_ALL=en_US.UTF-8 awk '{s+=$1} END{printf "Tokens used YTD: %\047d\n",s}'
      }
    '')
  ];

  # Notes:
  #   - macOS ships `open`; the Neovim config branches on jit.os, so no xdg-open
  #     shim is needed here.
}

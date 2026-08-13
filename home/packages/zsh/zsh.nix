# zsh — native home-manager module (settings-style config, lossless in Nix).
#
# STARTER: minimal. Migrate your existing ~/.zshrc into here incrementally —
# aliases into `shellAliases`, everything else into `initContent`.
{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -lah";
      dot = "cd ~/.dotfiles";
    };

    # Note: on recent home-manager this option is `initContent` (older versions
    # called it `initExtra`). Paste raw ~/.zshrc lines here as you migrate.
    initContent = ''
      # placeholder — migrate ~/.zshrc here incrementally
    '';
  };
}

# zsh — shared base. Machine-specific config is contributed by the OS layers:
#   macOS  -> home/darwin.nix   (brew, gcloud, rancher, bun, work aliases, …)
#   Arch   -> home/linux.nix    (Arch-specific config — currently a stub)
# `initContent`, `shellAliases`, `profileExtra`, `envExtra` all merge across
# modules, so each layer just adds its own piece. See DECISIONS.md.
{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true; # runs compinit; do not add a manual compinit
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Shared history (was raw HISTFILE/HISTSIZE/setopt appendhistory on Arch).
    # path defaults to $HOME/.zsh_history, so it is not set here.
    history = {
      size = 10000;
      save = 10000;
      append = true; # setopt appendhistory
    };

    # Aliases common to every machine.
    shellAliases = {
      ls = "ls --color=auto"; # --color=auto stays quiet when output is piped
      dot = "cd ~/.dotfiles";
      act = "source .venv/bin/activate";
      grep = "grep --color=auto";
      # nvim config now lives in the dotfiles repo (nixCats), not ~/.config/nvim.
      nvconf = "cd ~/.dotfiles/home/packages/neovim/cfg && nvim . && cd -";
    };
  };
}

# oh-my-posh — prompt. We wire it manually (rather than programs.oh-my-posh) so
# the theme stays a verbatim config.toml instead of being re-encoded as a Nix
# attrset. The zsh init line merges into the shared zsh module's initContent.
{ config, pkgs, lib, ... }:

{
  home.packages = [ pkgs.oh-my-posh ];

  xdg.configFile."oh-my-posh/config.toml".source = ./config.toml;

  # Initialise the prompt in interactive zsh (after the shared/OS zsh setup).
  programs.zsh.initContent = lib.mkAfter ''
    eval "$(oh-my-posh init zsh --config ${config.xdg.configHome}/oh-my-posh/config.toml)"
  '';
}

# tmux — real config kept as a co-located tmux.conf. Plugins come from nixpkgs
# but are loaded LAST (appended after tmux.conf), because:
#   - catppuccin v2 reads its @catppuccin_* options when it loads, and
#   - tmux-cpu substitutes the literal #{ram_percentage}/#{cpu_percentage}
#     tokens found in status-left/right at load time.
# Both require our config (options + status bar) to be in place first. We do NOT
# use `programs.tmux.plugins` because home-manager sources those BEFORE
# extraConfig, which would load the plugins too early (options ignored, RAM
# token left unsubstituted). This mirrors the original TPM ordering.
{ pkgs, ... }:

let
  plugin = p: "run-shell ${p}/share/tmux-plugins";
in
{
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux.conf + ''

      # --- Plugins from nixpkgs (loaded last; see tmux.nix) --------------------
      ${plugin pkgs.tmuxPlugins.catppuccin}/catppuccin/catppuccin.tmux
      ${plugin pkgs.tmuxPlugins.cpu}/cpu/cpu.tmux
      ${plugin pkgs.tmuxPlugins.battery}/battery/battery.tmux
    '';
  };

  # gitmux backs `@catppuccin_status_gitmux` in the status bar.
  home.packages = [ pkgs.gitmux ];
}

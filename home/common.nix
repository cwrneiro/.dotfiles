{ config, pkgs, username, homeDirectory, ... }:

{
	imports = [
		./packages/neovim/neovim.nix
		./packages/zsh/zsh.nix
		./packages/kitty/kitty.nix
		./packages/tmux/tmux.nix
		./packages/ohmyposh/ohmyposh.nix
		# ./packages/<name>/<name>.nix   <- add new programs here
	];

	home.username = username;
	home.homeDirectory = homeDirectory;

	home.sessionPath = [ "$HOME/.local/bin" ];

	home.stateVersion = "25.05";

	programs.home-manager.enable = true;

	fonts.fontconfig.enable = pkgs.stdenv.hostPlatform.isLinux;

	home.packages = with pkgs; [
		nerd-fonts.jetbrains-mono
		ripgrep
		fd
	];
}

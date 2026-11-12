{ pkgs, lib, ... }:

{
	imports = [
		./common.nix
	];

	home.packages = with pkgs; [
		gcc
		xdg-utils
	];

	programs.kitty.extraConfig = lib.mkAfter ''
		include ~/.local/state/quickshell/user/generated/terminal/kitty-theme.conf
	'';

	programs.zsh.shellAliases = {
		nvhypr = "cd ~/.config/hypr && nvim . && cd -";
		claudio = "claude";
	};

	programs.zsh.initContent = lib.mkAfter ''
		# Delete key + Ctrl+Left/Right word navigation (xterm/kitty sequences)
		bindkey "^[[3~" delete-char
		bindkey "^[[1;5C" forward-word
		bindkey "^[[1;5D" backward-word

		# esp-idf: source the SDK env on demand (lazy — no startup cost). First run
		# also registers /opt/esp-idf as a git safe.directory (idempotent).
		esp() {
			git config --global --get-all safe.directory \
				| grep -q '^/opt/esp-idf$' \
				|| git config --global --add safe.directory /opt/esp-idf
			source /opt/esp-idf/export.sh
		}
	'';
}

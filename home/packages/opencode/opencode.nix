{ ... }:

{
	programs.opencode = {
		enable = true;
		settings = {
			model = "zai-coding-plan/glm5.3";
			plugin = [
				"@mohak34/opencode-notifier@latest"
			];
		};
		tui = {
			theme = "gruvbox";
			vim_mode = true;
		};
	};

	# Exa-backed websearch for opencode.
	home.sessionVariables = {
		OPENCODE_ENABLE_EXA = "1";
	};

	# sessionVariables only reach the systemd user session. tmux panes do not
	# inherit it (the tmux server's environment is captured when it starts), so
	# export from .zshenv as well: every zsh invocation sources it, and
	# programs.tmux.shell is zsh, so panes get the var too.
	programs.zsh.envExtra = ''
		export OPENCODE_ENABLE_EXA=1
	'';
}

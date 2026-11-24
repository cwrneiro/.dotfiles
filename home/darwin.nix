{ pkgs, lib, ... }:

{
	imports = [
		./common.nix
		./packages/aerospace/aerospace.nix
		./packages/sketchybar/sketchybar.nix
	]
	home.packages = with pkgs; [
		clang
	];

	# drop a copy of each app bundle to "~/Applications/Nix Apps" so they appear in spotlight
	home.activation.copyNixApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
		nixApps="$HOME/Applications/Nix Apps"
		run rm -rf "$nixApps"
		run mkdir -p "$nixApps"
		for app in "$HOME/Applications/Home Manager Apps/"*.app; do
			[ -e "$app" ] || continue
			dst="$nixApps/$(basename "$app")"
			run cp -R "$(readlink "$app")" "$dst"
			run chmod -R u+w "$dst"	 # store copies are read-only; let macOS manage it
		done
	'';

	# link the nix-installed Nerd Font into ~/Library/Fonts so MACOS can find it
	home.file."Library/Fonts/JetBrainsMonoNerdFont" = {
		source = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype";
		recursive = true;
	};

	# ---- macOS-specific zsh -----------------------------------------------------
	# Non-login shells skip .zprofile, so source the Nix hook here too (it guards
	# against double-sourcing).
	programs.zsh.envExtra = ''
		if [[ ! -o login && -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
			. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
		fi
	'';

	# Login shell (.zprofile): Homebrew, framework Python, Obsidian.
	programs.zsh.profileExtra = ''
		# Nix on PATH. macOS updates reset /etc/zshrc and drop the installer's hook,
		# so source it from $HOME where updates/MDM can't touch it.
		[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && \
			. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

		eval "$(/opt/homebrew/bin/brew shellenv)"

		# Framework Python 3.13
		PATH="/Library/Frameworks/Python.framework/Versions/3.13/bin:''${PATH}"
		export PATH

		# Obsidian
		export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
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

			# Google Cloud SDK
			source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"
		'')
	];
}

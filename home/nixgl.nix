{ inputs, pkgs, ... }:

let
	nixglPkgs = inputs.nixgl.packages.${pkgs.system};
in {
	# Wrap kitty with nixGLIntel (mesa) so it finds the system GL drivers on
	# non-NixOS Linux.
	programs.kitty.package = pkgs.runCommand "kitty-nixgl" {
		nativeBuildInputs = [ pkgs.makeWrapper ];
	} ''
		mkdir -p $out/bin
		makeWrapper ${nixglPkgs.nixGLIntel}/bin/nixGLIntel $out/bin/kitty \
			--add-flags "${pkgs.kitty}/bin/kitty"
	'';
}

# Host: arch (Arch Linux, x86_64-linux, home-manager standalone).
#
# On non-NixOS Linux, Nix-installed OpenGL programs can't find the system GL
# drivers. nixGL wraps them so EGL/GLX initialization succeeds (see kitty's
# "Failed to create GLFWwindow" error without this).
{ inputs, pkgs, ... }:

let
  nixglPkgs = inputs.nixgl.packages.${pkgs.system};
in {
  imports = [ ../linux.nix ];

  # Wrap kitty with nixGLIntel (mesa) so it finds the system GL drivers.
  programs.kitty.package = pkgs.runCommand "kitty-nixgl" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin
    makeWrapper ${nixglPkgs.nixGLIntel}/bin/nixGLIntel $out/bin/kitty \
      --add-flags "${pkgs.kitty}/bin/kitty"
  '';
}

# Host: nixos (NixOS, x86_64-linux).
#
# This is the home-manager (user) layer only. System-level NixOS config
# (configuration.nix + hardware-configuration.nix) lives under system/ and is
# added to the flake as a nixosConfiguration when you actually run NixOS.
{ ... }:

{
  imports = [ ../linux.nix ];
}

# Host: macbook (Apple Silicon, aarch64-darwin).
# Identity (username/homeDirectory) is set in flake.nix; this file only picks
# the OS layer and can hold machine-specific overrides later.
{ ... }:

{
  imports = [ ../darwin.nix ];
}

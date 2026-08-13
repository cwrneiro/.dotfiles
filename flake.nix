{
  description = "Augusto's cross-platform dotfiles (macOS / Arch / NixOS) via home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim 0.12+ is required by the nvim-treesitter `main` branch used in the
    # Neovim config. nixpkgs' neovim usually trails, so we pull it from here.
    # See DECISIONS.md ("Neovim version").
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, neovim-nightly-overlay, ... }@inputs:
    let
      # A single helper builds a home-manager configuration for ANY OS/arch.
      # This is the key generalization over the reference dotfiles repo, which
      # hardcoded one `system` and therefore only worked on x86_64 Linux.
      mkHome = { system, hostModule, username, homeDirectory }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          # Values threaded down to every module (see home/common.nix args).
          extraSpecialArgs = { inherit inputs username homeDirectory system; };
          modules = [ hostModule ];
        };
    in {
      homeConfigurations = {
        # ---- macOS laptop (Apple Silicon) ----
        "macbook" = mkHome {
          system = "aarch64-darwin";
          username = "augusto.carneiro";
          homeDirectory = "/Users/augusto.carneiro";
          hostModule = ./home/hosts/macbook.nix;
        };

        # ---- Arch Linux (home-manager standalone on a non-NixOS distro) ----
        "arch" = mkHome {
          system = "x86_64-linux";
          username = "augusto";            # TODO: confirm real Arch username
          homeDirectory = "/home/augusto"; # TODO: confirm
          hostModule = ./home/hosts/arch.nix;
        };

        # ---- NixOS ----
        "nixos" = mkHome {
          system = "x86_64-linux";
          username = "augusto";            # TODO: confirm real NixOS username
          homeDirectory = "/home/augusto"; # TODO: confirm
          hostModule = ./home/hosts/nixos.nix;
        };
      };
    };
}

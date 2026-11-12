{
	description = "Augusto's cross-platform dotfiles (macOS / Arch) via home-manager";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		neovim-nightly-overlay = {
			url = "github:nix-community/neovim-nightly-overlay";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nixCats.url = "github:BirdeeHub/nixCats-nvim";

		plugins-monokai-nightasty = {
			url = "github:polirritmico/monokai-nightasty.nvim";
			flake = false;
		};

		plugins-d2-vim = {
			url = "github:terrastruct/d2-vim";
			flake = false;
		};

		nixgl.url = "github:nix-community/nixGL";
	};

	outputs = { self, nixpkgs, home-manager, neovim-nightly-overlay, nixCats, ... }@inputs:
		let
			mkHome = { system, hostModule, username, homeDirectory }:
				home-manager.lib.homeManagerConfiguration {
					pkgs = import nixpkgs {
						inherit system;
						config.allowUnfree = true;
					};
					extraSpecialArgs = { inherit inputs username homeDirectory; };
					modules = [ hostModule ];
				};
		in {
			homeConfigurations = {
				"macbook" = mkHome {
					system = "aarch64-darwin";
					username = "augusto.carneiro";
					homeDirectory = "/Users/augusto.carneiro";
					hostModule = ./home/hosts/macbook.nix;
				};

				"zoro" = mkHome {
					system = "x86_64-linux";
					username = "carneiro";
					homeDirectory = "/home/carneiro";
					hostModule = ./home/hosts/zoro.nix;
				};

				"jinbe" = mkHome {
					system = "x86_64-linux";
					username = "carneiro";
					homeDirectory = "/home/carneiro";
					hostModule = ./home/hosts/jinbe.nix;
				};
			};
		};
}

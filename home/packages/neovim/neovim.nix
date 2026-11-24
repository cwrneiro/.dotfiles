{ pkgs, inputs, ... }:

let
	utils = inputs.nixCats.utils;
in
{
	imports = [ inputs.nixCats.homeModule ];

	nixCats = {
		enable = true;
		packageNames = [ "nvim" ];

		luaPath = ./cfg;

		nixpkgs_version = inputs.nixpkgs;

		addOverlays = [ (utils.standardPluginOverlay inputs) ];

		categoryDefinitions.replace = ({ pkgs, ... }: let
			lib = pkgs.lib;

			tsGrammars = [
				"python"
				"rust"
				"c"
				"lua"
				"vim"
				"vimdoc"
				"query"
				"bash"
				"markdown"
				"markdown_inline"
				"typescript"
				"tsx"
				"javascript"
				"json"
				"sql"
				"yaml"
				"hyprlang"
			];
			tsParsers = pkgs.runCommandLocal "nvim-ts-parsers" { } (''
				mkdir -p $out/parser
			'' + lib.concatMapStringsSep "\n"
				(lang: "ln -s ${pkgs.vimPlugins.nvim-treesitter.builtGrammars.${lang}}/parser $out/parser/${lang}.so")
				tsGrammars);
		in {
			lspsAndRuntimeDeps.general = with pkgs; [
				rust-analyzer
				pyright	
				lua-language-server
				ripgrep
				fd
				catimg
				git
			];

			startupPlugins.general = with pkgs.vimPlugins; [
				lazy-nvim
				tsParsers
			];

			optionalPlugins.general = (with pkgs.vimPlugins; [
				# core / shared
				plenary-nvim
				nvim-treesitter
				mini-icons

				# completion
				nvim-cmp
				cmp-nvim-lsp
				cmp-buffer
				cmp-path
				cmp_luasnip
				luasnip
				friendly-snippets

				# lsp
				nvim-lspconfig

				# editing
				nvim-autopairs
				comment-nvim
				auto-save-nvim
				nvim-colorizer-lua

				# navigation / ui
				telescope-nvim
				harpoon
				oil-nvim
				undotree
				lightline-vim
				lensline-nvim
				render-markdown-nvim

				# git
				vim-fugitive
			]) ++ [
				pkgs.neovimPlugins.monokai-nightasty	# colorscheme (from plugins-* input)
				pkgs.neovimPlugins.d2-vim		# d2 syntax highlight
			];
		});

		packageDefinitions.replace = {
			nvim = { pkgs, ... }: {
				settings = {
					wrapRc = true;
					aliases = [ "vim" "vi" ];
					# nvim-treesitter main branch needs Neovim 0.12+; use the nightly.
					neovim-unwrapped =
						inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
				};
				categories = {
					general = true;
					have_nerd_font = true;
				};
			};
		};
	};

	home.sessionVariables.EDITOR = "nvim";
}

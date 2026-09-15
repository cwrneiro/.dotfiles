# Neovim — managed by nixCats.
#
# Nix owns the environment: the neovim binary (nightly, for the nvim-treesitter
# `main` branch), every plugin, the LSP servers, and the treesitter parsers.
# The lua/ config tree stays real Lua under ./cfg and is loaded by lazy.nvim via
# nixCats' lazyCat wrapper (see cfg/init.lua) — plugins are served from the Nix
# store instead of being cloned by lazy. With `wrapRc = true` the config is baked
# into the wrapped `nvim`, so this does NOT symlink ~/.config/nvim.
#
# Add/remove plugins here (categoryDefinitions) AND in the lua spec files; drop
# CLI tools/LSPs in lspsAndRuntimeDeps. See DECISIONS.md ("Neovim: nixCats").
{ pkgs, inputs, ... }:

let
  utils = inputs.nixCats.utils;
in
{
  imports = [ inputs.nixCats.homeModule ];

  nixCats = {
    enable = true;
    packageNames = [ "nvim" ];

    # The real lua config (init.lua, lua/, spell/). Baked in via wrapRc below.
    luaPath = ./cfg;

    # Use the same nixpkgs as the rest of the flake (where plugin/grammar
    # versions were validated), not nixCats' own pinned nixpkgs.
    nixpkgs_version = inputs.nixpkgs;

    # Exposes inputs named `plugins-<name>` as pkgs.neovimPlugins.<name>
    # (here: monokai-nightasty, which is not in nixpkgs).
    addOverlays = [ (utils.standardPluginOverlay inputs) ];

    categoryDefinitions.replace = ({ pkgs, ... }: let
      lib = pkgs.lib;

      # nvim-treesitter `main` branch loads parsers from `parser/<lang>.so` on the
      # runtimepath. nixpkgs' `withPlugins` does NOT bundle parsers on the main
      # branch, so assemble a parser-only plugin from the individual builtGrammars
      # (each ships its shared object at `$out/parser`).
      tsGrammars = [
        "python" "rust" "c" "lua" "vim" "vimdoc" "query" "bash"
        "markdown" "markdown_inline" "typescript" "tsx" "javascript"
        "json" "sql" "yaml" "hyprlang"
      ];
      tsParsers = pkgs.runCommandLocal "nvim-ts-parsers" { } (''
        mkdir -p $out/parser
      '' + lib.concatMapStringsSep "\n"
        (lang: "ln -s ${pkgs.vimPlugins.nvim-treesitter.builtGrammars.${lang}}/parser $out/parser/${lang}.so")
        tsGrammars);
    in {
      # Available on PATH at runtime (LSPs + CLI tools the config expects).
      # These replace Mason, which is removed for reproducibility / NixOS.
      lspsAndRuntimeDeps.general = with pkgs; [
        rust-analyzer          # lua/plugins/lsp.lua: vim.lsp.enable rust_analyzer
        pyright                # ...pyright (bundles its own node)
        lua-language-server    # ...lua_ls
        ripgrep                # telescope live_grep
        fd                     # telescope find_files
        catimg                 # telescope image preview (lua/plugins/telescope.lua)
        git                    # fugitive + telescope git_files
      ];

      # lazy.nvim must be present so lazyCat can find & prepend it; everything
      # else lazy loads from the store. `start` vs `opt` is irrelevant — lazy
      # does the actual loading — except tsParsers, which no lazy spec references
      # and so must live on `start` to always be on the runtimepath.
      startupPlugins.general = with pkgs.vimPlugins; [
        lazy-nvim
        tsParsers
      ];

      optionalPlugins.general = (with pkgs.vimPlugins; [
        # core / shared
        plenary-nvim
        nvim-treesitter        # main branch (parsers provided by tsParsers)
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

  # Replaces the old programs.neovim.defaultEditor.
  home.sessionVariables.EDITOR = "nvim";
}

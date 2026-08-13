# Neovim — PHASE 1 (starter): Nix owns the binary + toolchain; the existing
# Lua config keeps managing plugins via lazy.nvim.
#
# IMPORTANT: the Neovim config is its OWN git repo at ~/.config/nvim
# (github.com/cwrneiro/nvim). We deliberately do NOT symlink or copy it here —
# home-manager only guarantees the ENVIRONMENT (neovim + LSPs + tools) is
# present and identical across machines. The config repo stays independent and
# you keep editing it in place.
#
# PHASE 2 (see DECISIONS.md "Neovim: nixCats migration") moves plugin
# management into Nix via nixCats. Deferred on purpose.
{ config, pkgs, inputs, ... }:

{
  programs.neovim = {
    enable = true;
    # Neovim 0.12+ for the nvim-treesitter `main` branch. See DECISIONS.md.
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Toolchain the current config assumes on PATH. This replaces Mason (which is
  # removed for NixOS compatibility) and the implicit CLI dependencies.
  home.packages = with pkgs; [
    # --- LSP servers (were Mason-managed; see lua/plugins/lsp.lua) ---
    rust-analyzer
    pyright               # bundles its own node
    lua-language-server

    # --- treesitter `main` branch compiles parsers at runtime ---
    tree-sitter           # CLI >= 0.26 (C compiler provided per-OS)

    # --- Telescope ---
    ripgrep               # live_grep
    fd                    # find_files
    catimg                # image preview (lua/plugins/telescope.lua)

    git                   # lazy.nvim bootstrap + fugitive + git_files
  ];
}

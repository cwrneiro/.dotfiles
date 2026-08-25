-- Set leader keys before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Nerd Font availability is decided in Nix (packageDefinitions categories).
vim.g.have_nerd_font = nixCats("have_nerd_font")

-- nixCats: plugins are provided by Nix. lazy.nvim still does the loading, but
-- via the lazyCat wrapper it pulls each plugin from the Nix store instead of
-- cloning from GitHub. First arg is the Nix-provided lazy.nvim path; the rest
-- is the usual require("lazy").setup(spec, opts). (The non-Nix git bootstrap
-- was removed — this config targets Nix.)
require("nixCatsUtils.lazyCat").setup(nixCats.pawsible({ "allPlugins", "start", "lazy.nvim" }), "plugins", {
  -- Plugins come from Nix (lazyCat maps each to the nixCats pack dir). Never let
  -- lazy clone from git — that reintroduces non-reproducible, version-mismatched
  -- copies. Every spec must therefore resolve to a Nix dir (see the `name = ...`
  -- overrides where the upstream repo name differs from the nixpkgs pname).
  install = { missing = false },
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})

require("guscar")

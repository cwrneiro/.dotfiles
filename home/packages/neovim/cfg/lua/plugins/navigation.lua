return {
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>a", function() require("harpoon.mark").add_file() end, desc = "Add file to harpoon" },
      { "<C-e>", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Toggle harpoon menu" },
      { "<C-h>", function() require("harpoon.ui").nav_file(1) end, desc = "Harpoon file 1" },
      { "<C-j>", function() require("harpoon.ui").nav_file(2) end, desc = "Harpoon file 2" },
      { "<C-k>", function() require("harpoon.ui").nav_file(3) end, desc = "Harpoon file 3" },
      { "<C-l>", function() require("harpoon.ui").nav_file(4) end, desc = "Harpoon file 4" },
    },
  },
  {
    "stevearc/oil.nvim",
    dependencies = { "echasnovski/mini.icons" },
    lazy = false,
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    config = function()
      local oil = require('oil')
      require('mini.icons').setup({})

      local detail = false

      oil.setup({
        default_file_explorer = true,
        keymaps = {
          ['gd'] = {
            desc = 'Toggle file detail view',
            callback = function()
              detail = not detail
              if detail then
                oil.set_columns({ 'icon', 'permissions', 'size', 'mtime' })
              else
                oil.set_columns({ 'icon' })
              end
            end,
          },
          ['<leader>.'] = {
            desc = 'Toggle visibility of hidden files',
            callback = oil.toggle_hidden
          }
        },
      })

      -- Disable netrw to let Oil handle directory browsing
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
  },
  {
    "echasnovski/mini.icons",
    lazy = false,
  },
}

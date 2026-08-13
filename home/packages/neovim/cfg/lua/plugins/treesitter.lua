return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- main branch does not support lazy-loading
    -- No build/install step: Nix provides the compiled parsers on the
    -- runtimepath (home/packages/neovim/neovim.nix -> tsParsers). The parser
    -- list lives there now; keep it in sync when adding a language.
    config = function()
      require("nvim-treesitter").setup()

      -- main has no highlight.enable: start treesitter for any
      -- filetype that has a parser available
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })

      vim.filetype.add({
        pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
      })
    end,
  },
}

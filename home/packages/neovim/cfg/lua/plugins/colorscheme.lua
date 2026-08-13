return {
	{
	  "polirritmico/monokai-nightasty.nvim",
	  name = "monokai-nightasty", -- match nixCats pack dir (no .nvim suffix)
	  lazy = false,
	  priority = 1000,
	  config = function()
	    vim.cmd.colorscheme("monokai-nightasty")
	  end,
	}
}
-- return {
--   {
--     "rose-pine/neovim",
--     name = "rose-pine",
--     priority = 1000,
--     config = function()
--       function ColorMyPencils(color)
--         color = color or 'rose-pine'
--         vim.cmd.colorscheme(color)
--
--         vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
--         vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
--       end
--
--       ColorMyPencils()
--     end,
--   },
-- }

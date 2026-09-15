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

			-- nvim-treesitter `main` ships its highlight/indent queries under
			-- `runtime/queries/<lang>/`, but only the plugin ROOT lands on the
			-- runtimepath — so Neovim never finds `queries/<lang>/highlights.scm` and
			-- highlighting silently no-ops for every language Neovim doesn't bundle
			-- itself (python, bash, yaml, …; markdown/lua work because Neovim ships
			-- their queries). Parsers come from Nix and already load — only the query
			-- path is missing. Prepend the plugin's `runtime/` dir so they resolve.
			local ts_queries = vim.api.nvim_get_runtime_file("runtime/queries", false)[1]
			if ts_queries then
				vim.opt.runtimepath:prepend(vim.fn.fnamemodify(ts_queries, ":h"))
			end

			-- main has no highlight.enable: start treesitter for any
			-- filetype that has a parser available
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
				end,
			})

			vim.filetype.add({
				extension = { d2 = "d2"},
				pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
			})
		end,
	},
}

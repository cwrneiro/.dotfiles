return {
	{
		'oribarilan/lensline.nvim',
		tag = 'v2.1.0', -- pre-1.0 had breaking changes; pin the major
		event = 'LspAttach',
		config = function()
			require('lensline').setup({
				-- v2 profiles format (root-level providers/style is deprecated)
				profiles = {
					{
						name = 'default',
						providers = {
							-- references + implementations above functions/classes
							-- (replaces lsp-lens references=true, implements=true)
							{
								name = 'usages',
								enabled = true,
								include = { 'refs', 'impls' },
								breakdown = true,
								show_zero = true,
							},
							-- git authors above symbols (replaces lsp-lens git_authors=true)
							{
								name = 'last_author',
								enabled = true,
							},
						},
						style = {
							placement = 'above',
							use_nerdfont = vim.g.have_nerd_font or false,
						},
					},
				},
			})
		end,
	}
}

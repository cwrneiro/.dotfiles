return {
  {
    "nvim-telescope/telescope.nvim",
    -- No `tag`: the plugin (and its version) comes from Nix via nixCats; a tag
    -- here is ignored and misleading. See home/packages/neovim/neovim.nix.
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    keys = {
      { "<leader>pf", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>ps", "<cmd>Telescope live_grep<cr>",  desc = "Live grep"  },
      { "<leader>pb", "<cmd>Telescope buffers<cr>",    desc = "Buffers"    },
      { "<leader>ph", "<cmd>Telescope help_tags<cr>",  desc = "Help tags"  },
      { "<C-p>",      "<cmd>Telescope git_files<cr>",  desc = "Git Files"  },
    },
    -- MUST be inside config (runs after the plugin loads). Calling
    -- require("telescope").setup at module scope broke once plugins came from
    -- Nix as lazy-loaded `opt` packages — telescope isn't on the rtp yet when
    -- lazy imports this spec file.
    config = function()
      -- Telescope's bundled treesitter previewer relies on the old `master`-
      -- branch nvim-treesitter API (ft_to_lang, get_parser, configs.is_enabled).
      -- Since nvim-treesitter is on the `main` branch, that path errors out. We
      -- disable telescope's highlighter and attach Neovim's native treesitter
      -- highlighter to preview buffers instead.
      local native_ts_maker = function(filepath, bufnr, opts)
        opts = opts or {}
        local orig_callback = opts.callback
        require("telescope.previewers.buffer_previewer").file_maker(filepath, bufnr, vim.tbl_extend("force", opts, {
          callback = function(buf)
            if orig_callback then
              orig_callback(buf)
            end
            local ft = vim.filetype.match { buf = buf, filename = filepath }
            if not ft or ft == "" then
              return
            end
            local lang = vim.treesitter.language.get_lang(ft) or ft
            if pcall(vim.treesitter.start, buf, lang) then
              -- file_maker's regex highlighter sets `syntax` right after this
              -- callback; drop it next tick so only treesitter is active.
              vim.schedule(function()
                if vim.api.nvim_buf_is_valid(buf) then
                  vim.bo[buf].syntax = "off"
                end
              end)
            end
          end,
        }))
      end

      require("telescope").setup {
        defaults = {
          buffer_previewer_maker = native_ts_maker,
          preview = {
            treesitter = false,
            mime_hook = function(filepath, bufnr, opts)
              local is_image = function(filepath)
                local image_extensions = {'png','jpg'}   -- Supported image formats
                local split_path = vim.split(filepath:lower(), '.', {plain=true})
                local extension = split_path[#split_path]
                return vim.tbl_contains(image_extensions, extension)
              end
              if is_image(filepath) then
                local term = vim.api.nvim_open_term(bufnr, {})
                local function send_output(_, data, _ )
                  for _, d in ipairs(data) do
                    vim.api.nvim_chan_send(term, d..'\r\n')
                  end
                end
                vim.fn.jobstart(
                  {
                    'catimg', filepath  -- Terminal image viewer command
                  },
                  {on_stdout=send_output, stdout_buffered=true, pty=true})
              else
                require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
              end
            end
          },
        }
      }
    end,
  },
}

--[[
  This directory is the luaUtils template.
  You can choose what things from it that you would like to use.
  And then delete the rest.
  Everything in this directory is optional.
--]]

local M = {}
-- NOTE: If you don't use lazy.nvim, you don't need this file.

---lazy.nvim wrapper
---@overload fun(nixLazyPath: string|nil, lazySpec: any, opts: table)
---@overload fun(nixLazyPath: string|nil, opts: table)
function M.setup(nixLazyPath, lazySpec, opts)
  local lazySpecs = nil
  local lazyCFG = nil
  if opts == nil and type(lazySpec) == "table" and lazySpec.spec then
    lazyCFG = lazySpec
  else
    lazySpecs = lazySpec
    lazyCFG = opts
  end

  -- nix always provides lazy.nvim (nixLazyPath) and the nixCats global, so we
  -- wrap lazy with a few extra config options. (The non-nix git-clone bootstrap
  -- was removed — this config only loads via nixCats.)
  local nixCats = require('nixCats')
  local lazypath = nixLazyPath

  local oldPath
  local lazypatterns
  local fallback
  if type(lazyCFG) == "table" and type(lazyCFG.dev) == "table" then
    lazypatterns = lazyCFG.dev.patterns
    fallback = lazyCFG.dev.fallback
    oldPath = lazyCFG.dev.path
  end

  local myNeovimPackages = nixCats.vimPackDir .. "/pack/myNeovimPackages"

  local newLazyOpts = {
    performance = {
      rtp = {
        reset = false,
      },
    },
    dev = {
      path = function(plugin)
        local path = nil
        if type(oldPath) == "string" and vim.fn.isdirectory(oldPath .. "/" .. plugin.name) == 1 then
          path = oldPath .. "/" .. plugin.name
        elseif type(oldPath) == "function" then
          path = oldPath(plugin)
          if type(path) ~= "string" then
            path = nil
          end
        end
        if path == nil then
          if vim.fn.isdirectory(myNeovimPackages .. "/start/" .. plugin.name) == 1 then
            path = myNeovimPackages .. "/start/" .. plugin.name
          elseif vim.fn.isdirectory(myNeovimPackages .. "/opt/" .. plugin.name) == 1 then
            path = myNeovimPackages .. "/opt/" .. plugin.name
          else
            path = "~/projects/" .. plugin.name
          end
        end
        return path
      end,
      patterns = lazypatterns or { "" },
      fallback = fallback == nil and true or fallback,
    }
  }
  lazyCFG = vim.tbl_deep_extend("force", lazyCFG or {}, newLazyOpts)
  -- do the reset we disabled without removing important stuff
  local cfgdir = nixCats.configDir
  vim.opt.rtp = {
    cfgdir,
    nixCats.nixCatsPath,
    nixCats.pawsible.allPlugins.ts_grammar_path,
    vim.fn.stdpath("data") .. "/site",
    lazypath,
    vim.env.VIMRUNTIME,
    vim.fn.fnamemodify(vim.v.progpath, ":p:h:h") .. "/lib/nvim",
    cfgdir .. "/after",
  }

  if lazySpecs then
    require('lazy').setup(lazySpecs, lazyCFG)
  else
    require('lazy').setup(lazyCFG)
  end
end

return M

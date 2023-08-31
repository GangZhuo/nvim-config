-- Install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- autocmds and keymaps can wait to load
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("trigger-lazy-done", { clear = true }),
  pattern = "VeryLazy",
  callback = function()
    require("config.lazydone")
  end,
})

require("lazy").setup({
  spec = {
    -- import plugins
    { import = "config.plugins" },
  },
  defaults = {
    -- should plugins be lazy-loaded?
    lazy = false,
    -- It's recommended to leave version=false for now,
    -- since a lot the plugin that support versioning, have outdated releases,
    -- which may break your Neovim install.
    version = "", -- try installing the latest stable versions of plugins
  },
  checker = {
    -- don't automatically check for plugin updates
    enabled = false,
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})


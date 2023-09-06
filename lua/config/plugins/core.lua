return {
  { "folke/lazy.nvim" },
  -- Escape from insert mode by 'jk'
  {
    "nvim-zh/better-escape.vim",
    event = 'InsertEnter',
    config = function()
      vim.g.better_escape_interval = 200
    end
  },
  -- Show marks in signcolumn
  {
    "kshenoy/vim-signature",
    event = "VeryLazy",
  },
}

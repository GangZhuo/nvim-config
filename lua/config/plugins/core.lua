return {
  { "folke/lazy.nvim" },
  -- Resume last cursor position
  { "ethanholz/nvim-lastplace",
    opts = {
      lastplace_ignore_buftype = {"quickfix", "nofile", "help"},
      lastplace_ignore_filetype = {"gitcommit", "gitrebase", "svn", "hgcommit"},
      lastplace_open_folds = true
    }
  },
  -- Escape from insert mode by 'jk'
  { "nvim-zh/better-escape.vim",
    config = function()
      vim.g.better_escape_interval = 200
    end
  },
  -- Show marks in signcolumn
  { "kshenoy/vim-signature" },
}

return {

  { "folke/lazy.nvim" },

  -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },

  -- Escape from insert mode by 'jk'
  {
    "nvim-zh/better-escape.vim",
    event = 'InsertEnter',
    config = function()
      vim.g.better_escape_interval = 200
    end,
  },

  -- measure startuptime
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },

  -- Session management. This saves your session in the background,
  -- keeping track of open buffers, window arrangement, and more.
  -- You can restore sessions when returning through the dashboard.
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      options = {
        "buffers",
        "curdir",
        "tabpages",
        "winsize",
        "help",
        "globals",
        "skiprtp",
      },
    },
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session for Current Directory",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },

  -- automatically update your ctags file
  {
    "ludovicchabant/vim-gutentags",
    event = "VeryLazy",
    config = function()
      -- A list of arguments to pass to `ctags`.
      -- vim.g.gutentags_ctags_extra_args = {}
    end,
  },

}

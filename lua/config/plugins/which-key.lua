return {

  -- which-key helps you remember key bindings by showing a popup
  -- with the active keybindings of the command you started typing.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      defaults = {
        mode = { "n", "v" },
        { "g", group = "+goto" },
        { "gs", group = "+surround" },
        { "]", group = "+next" },
        { "[", group = "+prev" },
        { "<leader>b", group = "+buffer" },
        { "<leader>c", group = "+code" },
        { "<leader>d", group = "+debug" },
        { "<leader>f", group = "+file/find" },
        { "<leader>g", group = "+git" },
        { "<leader>q", group = "+quit/session" },
        { "<leader>s", group = "+search" },
        { "<leader>u", group = "+ui" },
        { "<leader>w", group = "+windows" },
        { "<space>", group = "+diagnostics/quickfix" },
        { "<leader>x", group = "+diagnostics/quickfix" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add(opts.defaults)
    end,
  },

}

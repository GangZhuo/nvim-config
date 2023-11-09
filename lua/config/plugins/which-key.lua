return {

  -- which-key helps you remember key bindings by showing a popup
  -- with the active keybindings of the command you started typing.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      defaults = {
        --["<leader>d"] = { name = "+debug" },
      },
    },
  },

}

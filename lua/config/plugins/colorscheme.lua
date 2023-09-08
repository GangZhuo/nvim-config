return {

  -- Main colorschemes
  {
    "sainnhe/sonokai",
    -- make sure we load this during startup
    lazy = false,
    -- make sure to load this before all the other start plugins
    priority = 1000,
    config = function()
      vim.g.sonokai_enable_italic = 1
      vim.g.sonokai_better_performance = 1
      vim.cmd.colorscheme("sonokai")
    end,
  },

  -- Optional colorschemes
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
  },

}

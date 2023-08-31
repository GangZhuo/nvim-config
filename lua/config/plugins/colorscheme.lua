return {
  { "sainnhe/sonokai", lazy = true,
    config = function()
      vim.g.sonokai_enable_italic = 1
      vim.g.sonokai_better_performance = 1
    end
  },
  { "rebelot/kanagawa.nvim", lazy = true, },
}

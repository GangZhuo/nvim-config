local utils = require("config.utils")
local treesitter

local ts_parsers = {
  "bash",
  "c",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
  "rust",
}

if utils.expect_ver("0.12.0") then
  treesitter = {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function(_, opts)
      local ts = require('nvim-treesitter')
      ts.install(ts_parsers)
      vim.api.nvim_create_autocmd('FileType', {
        pattern = ts_parsers,
        callback = function()
          vim.treesitter.start()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  }
else
  treesitter = {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdateSync" },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup({
        highlight = {
          enable = true, -- false will disable the whole extension
          additional_vim_regex_highlighting = false,
          disable = { "help" }, -- list of language that will be disabled
        },
        indent = { enable = true },
        matchup = { enable = true },
        ensure_installed = ts_parsers,
      })
    end,
  }
end

return {

  -- treesitter
  treesitter,

  -- Modern matchit implementation base on treesitter
  {
    "andymass/vim-matchup",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<leader>k", "<cmd>MatchupWhereAmI?<cr>", desc = "Where am i?" },
    },
    config = function()
      -- Improve performance
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_timeout = 100
      vim.g.matchup_matchparen_insert_timeout = 30

      vim.g.matchup_surround_enabled = 1

      -- Whether to enable matching inside comment or string
      vim.g.matchup_delim_noskips = 0

      -- Show offscreen match pair in popup window
      vim.g.matchup_matchparen_offscreen = { }
    end
  },

}

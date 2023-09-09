return {

  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      diagnostics = {
        virtual_text = false,
        underline = false,
        signs = true,
        severity_sort = true,
        float = {
          focusable = true,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      },
    },
    config = function(_, opts)

      -- Change diagnostic signs.
      for name, icon in pairs(require("config.icons").diagnostics) do
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end

      -- global config for diagnostic
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- Change border of documentation hover window,
      -- See https://github.com/neovim/neovim/pull/13998.
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })

    end
  },

    -- Standalone UI for nvim-lsp progress
  {
    "j-hui/fidget.nvim",
    branch = "legacy",
    event = "VeryLazy",
    opts = {
      debug = {
        logging = false, -- whether to enable logging, for debugging
        strict = false,  -- whether to interpret LSP strictly
      },
    }
  },

  -- lsp icons
  {
    "onsails/lspkind-nvim",
    lazy = true,
    config = function()
      local lspkind = require("lspkind")
      lspkind.init({
        symbol_map = {
          Copilot = "",
        },
      })
    end
  },

}

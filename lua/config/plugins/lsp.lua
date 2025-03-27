return {

  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
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

      local utils = require("config.utils")

      local capabilities

      if utils.has_plugin("nvim-cmp") then
        capabilities = require("cmp_nvim_lsp").default_capabilities()
      else
        capabilities = vim.lsp.protocol.make_client_capabilities()
      end

      -- nvim-ufo using 'foldingRange' capability,
      if utils.has_plugin("nvim-ufo") then
        capabilities.textDocument.foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true
        }
      end

      -- 'j-hui/fidget.nvim' need workDoneProgress capability
      if utils.has_plugin("fidget.nvim") then
        capabilities.window = capabilities.window or {}
        capabilities.window.workDoneProgress = true
      end

      -- lsp attach function
      local on_attach = function (client, bufnr)
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, {
            noremap = true,
            silent = true,
            buffer = bufnr,
            desc = desc,
          })
        end

        map("n", "gD",        vim.lsp.buf.declaration,    "go to declaration")
        map("n", "gd",        vim.lsp.buf.definition,     "go to definition")
        map("n", "gi",        vim.lsp.buf.implementation, "go to implementation")
        map("n", "gr",        vim.lsp.buf.references,     "show references")
        map("n", "K",         vim.lsp.buf.hover,          "show help")
        map("n", "<C-k>",     vim.lsp.buf.signature_help, "show signature help")
        map("n", "<space>rn", vim.lsp.buf.rename,         "varialbe rename")
        map("n", "<space>ca", vim.lsp.buf.code_action,    "LSP code action")
        map("n", "<space>wa", vim.lsp.buf.add_workspace_folder, "add workspace folder")
        map("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, "remove workspace folder")

        -- Set some key bindings conditional on server capabilities
        if client.server_capabilities.documentFormattingProvider then
          map("n", "<space>fc", vim.lsp.buf.format,         "format code")
        end

        local msg = string.format("Language server %s started!", client.name)
        vim.notify(msg, vim.log.levels.INFO, { title = "LSP" })

      end

      local lspconfig = require("lspconfig")

      -- set up clangd
      if vim.fn.executable("clangd") == 1 then
        lspconfig.clangd.setup {
          on_attach = on_attach,
          capabilities = capabilities,
        }
      end

      -- set up vim-language-server
      if vim.fn.executable("vim-language-server") == 1 then
        lspconfig.vimls.setup {
          on_attach = on_attach,
          capabilities = capabilities,
        }
      end

      -- set up bash-language-server
      if vim.fn.executable("bash-language-server") == 1 then
        lspconfig.bashls.setup {
          on_attach = on_attach,
          capabilities = capabilities,
        }
      end

      -- set up lua-language-server
      if vim.fn.executable("lua-language-server") == 1 then
        lspconfig.lua_ls.setup {
          on_attach = on_attach,
          capabilities = capabilities,
          settings = {
            Lua = {
              runtime = {
                -- Tell the language server which version of Lua you're
                -- using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
              },
              diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
              },
              workspace = {
                library = {
                  -- Make the server aware of Neovim runtime files
                  vim.api.nvim_get_runtime_file("", true),
                },
              },
            },
          },
        }
      end

      -- set up python-lsp-server
      -- see https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
      if vim.fn.executable("pylsp") == 1 then
        local venv_path = os.getenv('VIRTUAL_ENV')
        local py_path = nil
        -- decide which python executable to use for mypy
        if venv_path ~= nil then
          py_path = venv_path .. "/bin/python3"
        else
          py_path = vim.g.python3_host_prog
        end
        lspconfig.pylsp.setup {
          on_attach = on_attach,
          capabilities = capabilities,
          flags = {
            debounce_text_changes = 200,
          },
          settings = {
            pylsp = {
              plugins = {
                -- formatter options
                black = { enabled = true },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                -- linter options
                pylint = { enabled = true, executable = "pylint" },
                ruff = { enabled = false },
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },
                -- type checker
                pylsp_mypy = {
                  enabled = true,
                  overrides = { "--python-executable", py_path, true },
                  report_progress = true,
                  live_mode = false
                },
                -- auto-completion options
                jedi_completion = { fuzzy = true },
                -- import sorting
                isort = { enabled = true },
              },
            },
          },
        }
      end

      -- set up rust-analyzer
      if vim.fn.executable("rust-analyzer") == 1 then
        lspconfig.rust_analyzer.setup {
          on_attach = function (client, bufnr)
            on_attach(client, bufnr)
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end,
          capabilities = capabilities,
          settings = {
            --[[
            ['rust-analyzer'] = {
              diagnostics = {
                enable = false;
              },
            },
            --]]
          },
        }
      end

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

return {

  -- Install lsp servers
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = function()
      local pip_args = {}
      local proxy_url = vim.env.https_proxy or vim.env.http_proxy
      if proxy_url ~= nil and proxy_url ~= "" then
        -- Remove trailing slash
        proxy_url = string.gsub(proxy_url, "(.-)/*$", "%1")
        pip_args = { "--proxy", proxy_url }
      end
      return {
        pip = {
          install_args = pip_args,
        },
        ensure_installed = {
          -- LSP
          "clangd",
          "lua-language-server",
          "bash-language-server",
          "vim-language-server",

          -- debugger
          "codelldb",

          -- utils
          --"tree-sitter-cli",
        },
      }
    end,
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

}


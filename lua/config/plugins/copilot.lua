return {

  -- Github Copilot Completion
  {
    "zbirenbaum/copilot.lua",
    enabled = false,
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
    config = function(_, opts)
      local proxy_url = vim.env.https_proxy or vim.env.http_proxy
      if proxy_url ~= nil and proxy_url ~= "" then
        -- Remove trailing slash
        proxy_url = string.gsub(proxy_url, "(.-)/*$", "%1")
        vim.g.copilot_proxy = proxy_url
      end
      require("copilot").setup(opts)
    end
  },

  { "zbirenbaum/copilot-cmp", lazy = true },

}

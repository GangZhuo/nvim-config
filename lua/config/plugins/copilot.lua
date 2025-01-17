return {

  -- Github Copilot Completion
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
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

  -- Turn github copilot into a cmp source
  {
    "zbirenbaum/copilot-cmp",
    config = function ()
      require("copilot_cmp").setup()
    end
  },

}

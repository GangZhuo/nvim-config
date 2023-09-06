return {

  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
      { "gb", function()
          if vim.v.count == 0 then
            vim.cmd("BufferLineCycleNext")
          else
            require("bufferline").go_to_buffer(vim.v.count, true)
          end
        end,
        desc = "Next buffer, or goto buffer by ordinal number"
      },
      { "gB", function()
          if vim.v.count == 0 then
            vim.cmd("BufferLineCyclePrev")
          else
            vim.cmd("buffer"..tostring(vim.v.count))
          end
        end,
        desc = "Prev buffer, or goto buffer by absolute number"
      },
      { "<leader>1", "<cmd>lua require('bufferline').go_to_buffer(1)<cr>",  desc = "go to first buffer" },
      { "<leader>2", "<cmd>lua require('bufferline').go_to_buffer(2)<cr>",  desc = "go to 2nd buffer"   },
      { "<leader>3", "<cmd>lua require('bufferline').go_to_buffer(3)<cr>",  desc = "go to 3rd buffer"   },
      { "<leader>4", "<cmd>lua require('bufferline').go_to_buffer(4)<cr>",  desc = "go to 4th buffer"   },
      { "<leader>5", "<cmd>lua require('bufferline').go_to_buffer(5)<cr>",  desc = "go to 5th buffer"   },
      { "<leader>6", "<cmd>lua require('bufferline').go_to_buffer(6)<cr>",  desc = "go to 6th buffer"   },
      { "<leader>7", "<cmd>lua require('bufferline').go_to_buffer(7)<cr>",  desc = "go to 7th buffer"   },
      { "<leader>8", "<cmd>lua require('bufferline').go_to_buffer(8)<cr>",  desc = "go to 8th buffer"   },
      { "<leader>9", "<cmd>lua require('bufferline').go_to_buffer(9)<cr>",  desc = "go to 9th buffer"   },
      { "<leader>$", "<cmd>lua require('bufferline').go_to_buffer(-1)<cr>", desc = "go to last buffer"  },
    },
    opts = {
      options = {
        numbers = "ordinal",
        always_show_bufferline = false,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
          local icons = require("config.icons").diagnostics
          local ret = (diag.error and icons.Error .. diag.error .. " " or "")
            .. (diag.warning and icons.Warn .. diag.warning or "")
          return vim.trim(ret)
        end,
      },
    },
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local icons = require("config.icons")
      local utils = require("config.utils")

      return {
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
          -- component_separators = { left = "", right = "" },
          -- section_separators = { left = "", right = "" },
          section_separators = "",
          component_separators = "",
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
            {
              function() return require("nvim-navic").get_location() end,
              cond = function() return package.loaded["nvim-navic"] and require("nvim-navic").is_available() end,
            },
          },
          lualine_x = {
            {
              function() return "  " .. require("dap").status() end,
              cond = function () return package.loaded["dap"] and require("dap").status() ~= "" end,
              color = utils.fg("Debug"),
            },
            { require("lazy.status").updates, cond = require("lazy.status").has_updates, color = utils.fg("Special") },
            "filetype",
            "encoding",
            {
              "fileformat",
              symbols = {
                unix = "unix",
                dos = "win",
                mac = "mac",
              },
            },
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            {
              require("config.utils").get_tags_status,
              cond = function () return vim.g.loaded_gutentags == 1 and vim.g.gutentags_enabled == 1 end,
            },
          },
        },
        extensions = { "nvim-tree", "lazy" },
      }
    end,
  },

  -- indent guides for Neovim
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- char = "▏",
      char = '',
      show_end_of_line = false,
      disable_with_nolist = true,
      show_trailing_blankline_indent = false,
      show_current_context = false,
      filetype_exclude = {
        "help",
        "nvim-tree",
        "lazy",
      },
    },
    config = function (_, opts)
      require("indent_blankline").setup(opts)
      local gid = vim.api.nvim_create_augroup("indent_blankline", { clear = true })
      vim.api.nvim_create_autocmd("InsertEnter", {
        pattern = "*",
        group = gid,
        command = "IndentBlanklineDisable",
      })

      vim.api.nvim_create_autocmd("InsertLeave", {
        pattern = "*",
        group = gid,
        command = "IndentBlanklineEnable",
      })
    end,
  },

  -- Dashboard. This runs when neovim starts, and is what displays
  -- the "LAZYVIM" banner.
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.buttons.val = {
        dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>"),
        dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("g", " " .. " Find text", ":Telescope live_grep <CR>"),
        dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
        dashboard.button("s", " " .. " Restore Session", [[:lua require("persistence").load() <cr>]]),
        dashboard.button("l", "󰒲 " .. " Lazy", ":Lazy<CR>"),
        dashboard.button("q", " " .. " Quit", ":qa<CR>"),
      }
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortcut"
      end
      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"
      dashboard.opts.layout[1].val = 8
      return dashboard
    end,
    config = function(_, dashboard)
      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "AlphaReady",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      require("alpha").setup(dashboard.opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  -- lsp symbol navigation for lualine. This shows where
  -- in the code structure you are - within functions, classes,
  -- etc - in the statusline.
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    init = function()
      vim.g.navic_silence = true
      require("config.utils").on_attach(function(client, buffer)
        if client.server_capabilities.documentSymbolProvider then
          require("nvim-navic").attach(client, buffer)
        end
      end)
    end,
    opts = function()
      return {
        separator = " ",
        highlight = true,
        depth_limit = 5,
        icons = require("config.icons").kinds,
      }
    end,
  },

  -- icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

}
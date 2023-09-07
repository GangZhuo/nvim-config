return {

  -- Better `vim.notify()`
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
    config = function(_, opts)
      require("notify").setup(opts)
      vim.notify = require("notify")
    end,
  },

  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = function(_, keys)
      keys = vim.list_extend(keys or {}, {
        {
          "<leader>bp",
          "<Cmd>BufferLineTogglePin<CR>",
          desc = "Toggle pin",
        },
        {
          "<leader>bP",
          "<Cmd>BufferLineGroupClose ungrouped<CR>",
          desc = "Delete non-pinned buffers",
        },
        {
          "gb",
          function()
            if vim.v.count == 0 then
              vim.cmd("BufferLineCycleNext")
            else
              require("bufferline").go_to_buffer(vim.v.count, true)
            end
          end,
          desc = "Next buffer, or goto buffer by ordinal number",
        },
        {
          "gB",
          function()
            if vim.v.count == 0 then
              vim.cmd("BufferLineCyclePrev")
            else
              vim.cmd("buffer"..tostring(vim.v.count))
            end
          end,
          desc = "Prev buffer, or goto buffer by absolute number",
        },
      })
      for i,n in ipairs({
        "first", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th"
      }) do
        table.insert(keys, {
          "<leader>"..i,
          "<cmd>lua require('bufferline').go_to_buffer("..i..")<cr>",
          desc = "go to "..n.." buffer",
        })
      end
      table.insert(keys, {
        "<leader>$",
        "<cmd>lua require('bufferline').go_to_buffer(-1)<cr>",
        desc = "go to last buffer",
      })
      return keys
    end,
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
          disabled_filetypes = {
            statusline = {
              "dashboard",
              "alpha",
            },
          },
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
            {
              "filetype",
              icon_only = true,
              separator = "",
              padding = { left = 1, right = 0 },
            },
            {
              "filename",
              path = 1,
              symbols = {
                modified = "  ",
                readonly = "",
                unnamed = "",
              },
            },
            {
              function()
                return require("nvim-navic").get_location()
              end,
              cond = function()
                return package.loaded["nvim-navic"]
                  and require("nvim-navic").is_available()
              end,
            },
          },
          lualine_x = {
            {
              function()
                return "  " .. require("dap").status()
              end,
              cond = function ()
                return package.loaded["dap"]
                  and require("dap").status() ~= ""
              end,
              color = utils.fg("Debug"),
            },
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = utils.fg("Special"),
            },
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
            {
              "progress",
              separator = " ",
              padding = { left = 1, right = 0 },
            },
            {
              "location",
              padding = { left = 0, right = 1 },
            },
          },
          lualine_z = {
            {
              require("config.utils").get_gutentags_status,
              cond = function ()
                return vim.g.loaded_gutentags == 1
                    and vim.g.gutentags_enabled == 1
              end,
            },
          },
        },
        extensions = { "nvim-tree", "lazy" },
      }
    end,
  },

  -- file explorer
  {
    "kyazdani42/nvim-tree.lua",
    cmd = { "NvimTreeOpen", "NvimTreeToggle" },
    keys = {
      {
        "<leader>e",
        function()
          return require("nvim-tree.api").tree.toggle(true, false)
        end,
        silent = true,
        desc = "toggle nvim-tree",
      },
    },
    opts = function (_, opts)
      local api = require("nvim-tree.api")

      local edit = function (mode, node)
        local path = node.absolute_path
        if node.link_to and not node.nodes then
          path = node.link_to
        end
        require("nvim-tree.actions.node.open-file").fn(mode, path)
      end

      local expand = function()
        local node = api.tree.get_node_under_cursor()
        if node.nodes then
          if not node.open then
            require("nvim-tree.lib").expand_or_collapse(node)
          end
        elseif node.parent then
          edit("edit", node)
        end
      end

      local collapse = function()
        local node = api.tree.get_node_under_cursor()
        if node.nodes and node.open then
          require("nvim-tree.lib").expand_or_collapse(node)
          return
        end
        -- find parent node which is opened
        local p = node
        while p.parent do
            p = p.parent
            if p.open then
                break
            end
        end
        -- if found and not a root node, collapse the node
        if p and p ~= node and p.parent and p.open then
          require("nvim-tree.lib").expand_or_collapse(p)
          require("nvim-tree.utils").focus_file(p.absolute_path)
        end
      end

      local map_opts = function(bufnr, desc)
        return {
          desc = desc,
          buffer = bufnr,
          noremap = true,
          silent = true,
          nowait = true,
        }
      end

      return vim.tbl_extend("force", opts or {}, {
        sync_root_with_cwd = true,
        diagnostics = {
          enable = true,
          debounce_delay = 1000,
          show_on_dirs = true,
        },
        on_attach = function(bufnr)
          api.config.mappings.default_on_attach(bufnr)
          vim.keymap.set("n", "l",
              expand,
              map_opts(bufnr, "Expand folder or open a file"))
          vim.keymap.set("n", "h",
              collapse,
              map_opts(bufnr, "Collapse the folder"))
          vim.keymap.set("n", "?",
              api.tree.toggle_help,
              map_opts(bufnr, "Show help"))
        end,
        view = {
          adaptive_size = false,
          centralize_selection = true,
          width = 40,
          side = "left",
          number = true,
          relativenumber = true,
          signcolumn = "yes",
        },
        renderer = {
          group_empty = true,
        },
      })
    end,
  },

  -- show file tags in vim window
  {
    "liuchengxu/vista.vim",
    cmd = "Vista",
    keys = {
      { "<leader>t", "<Cmd>Vista!!<CR>", desc = "Toggle ctags view window" },
    },
    config = function()
      -- How each level is indented and what to prepend.
      -- This could make the display more compact or more spacious.
      -- e.g., more compact: ["▸ ", ""]
      -- Note: this option only works for the kind renderer,
      -- not the tree renderer.
      vim.g.vista_icon_indent = { "╰─▸ ", "├─▸ " }

      -- Executive used when opening vista sidebar without specifying it.
      -- See all the avaliable executives via `:echo g:vista#executives`.
      -- e.g. 'ale', 'coc', 'ctags', 'lcn', 'nvim_lsp', 'vim_lsc', 'vim_lsp'
      vim.g.vista_default_executive = "ctags"
      vim.g.vista_finder_alternative_executives = "nvim_lsp"

      -- Set this option to `0` to disable echoing when the cursor moves.
      vim.g.vista_echo_cursor = 1
      vim.g.vista_cursor_delay = 150

      -- How to show the detailed formation of current cursor symbol.
      -- Avaliable options:
      --
      -- `echo`         - echo in the cmdline.
      -- `scroll`       - make the source line of current tag at the center
      --                  of the window.
      -- `floating_win` - display in neovim's floating window or vim's popup
      --                  window.
      --                  See if you have neovim's floating window support
      --                  via `:echo exists('*nvim_open_win')` or vim's popup
      --                  feature via `:echo exists('*popup_create')`
      -- `both`         - both `echo` and `floating_win` if it's avaliable
      --                  otherwise `scroll` will be used.
      vim.g.vista_echo_cursor_strategy = "floating_win"
      vim.g.vista_floating_border= "rounded"

      -- Set the executive for some filetypes explicitly. Use the explicit
      -- executive instead of the default one for these filetypes when using
      -- `:Vista` without specifying the executive.
      --vim.g.vista_executive_for = {
      --  ["c"]   = "nvim_lsp",
      --  ["cpp"] = "nvim_lsp",
      --  ["lua"] = "nvim_lsp",
      --  ["php"] = "nvim_lsp",
      --}
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
          dashboard.section.footer.val =
            "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  -- which-key helps you remember key bindings by showing a popup
  -- with the active keybindings of the command you started typing.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
      defaults = {
        mode = { "n", "v" },
        ["g"] = { name = "+goto" },
        ["gz"] = { name = "+surround" },
        ["]"] = { name = "+next" },
        ["["] = { name = "+prev" },
        ["<leader><tab>"] = { name = "+tabs" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>f"] = { name = "+file/find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>gh"] = { name = "+hunks" },
        ["<leader>q"] = { name = "+quit/session" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>u"] = { name = "+ui" },
        ["<leader>w"] = { name = "+windows" },
        ["<leader>x"] = { name = "+diagnostics/quickfix" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(opts.defaults)
    end,
  },

  -- Show match number and index for searching
  {
    "kevinhwang91/nvim-hlslens",
    event = "VeryLazy",
    opts = {
      -- If calm_down is true, clear all lens and highlighting When
      -- the cursor is out of the position range of the matched
      -- instance or any texts are changed
      calm_down = false,
      -- Only add lens for the nearest matched instance and ignore others
      nearest_only = false,
      -- When to open the floating window for the nearest lens.
      --   'auto':   floating window will be opened if room isn't enough
      --             for virtual text;
      --   'always': always use floating window instead of virtual text;
      --   'never':  never use floating window for the nearest lens
      nearest_float_when = 'auto'
    },
    config = function(_, opts)
      require("hlslens").setup(opts)
      local activate_hlslens = function(direction)
        local cmd = string.format("normal! %s%s", vim.v.count1, direction)
        local status, msg = pcall(vim.cmd, cmd)
        if not status then
          -- 13 is the index where real error message starts
          msg = msg:sub(13)
          vim.api.nvim_err_writeln(msg)
          return
        end
        require("hlslens").start()
      end

      vim.keymap.set("n", "n", "", {
        callback = function()
          activate_hlslens("n")
        end,
      })
 
      vim.keymap.set("n", "N", "", {
        callback = function()
          activate_hlslens("N")
        end,
      })

      vim.keymap.set("n", "*", "", {
        callback = function()
          vim.fn.execute("normal! *N")
          require('hlslens').start()
        end,
      })
      vim.keymap.set("n", "#", "", {
        callback = function()
          vim.fn.execute("normal! #N")
          require('hlslens').start()
        end,
      })
      vim.keymap.set("n", "<BackSpace>", function ()
        require('hlslens').stop()
        vim.cmd('nohl')
      end)
    end,
  },

  -- Best quickfix
  -- * Press <Tab> or <S-Tab> to toggle the sign of item
  -- * Press zn or zN will create new quickfix list
  -- * Press zf in quickfix window will enter fzf mode.
  -- * Press p to toggle auto preview when cursor moved
  -- * Press P to toggle preview for an item of quickfix list
  -- * Press ctrl-t/ctrl-x/ctrl-v to open up an item in a new tab,
  --   a new horizontal split, or in a new vertical split.
  -- * Press ctrl-q to toggle sign for the selected items
  -- * Press ctrl-c to close quickfix window and abort fzf
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      auto_resize_height = true,
    },
  },

  -- Show marks in signcolumn
  {
    "kshenoy/vim-signature",
    event = "VeryLazy",
  },

  -- Colorizer
  {
    "norcalli/nvim-colorizer.lua",
    cmd = "ColorizerToggle",
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
      local gid = vim.api.nvim_create_augroup("indent_blankline",
          { clear = true })
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

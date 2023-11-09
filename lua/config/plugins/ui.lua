return {

  -- icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

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
        desc = "Dismiss all notifications",
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
    keys = function()
      local keys = {
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
          desc = "Next buffer/Goto buffer by ordinal number",
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
          desc = "Prev buffer/Goto buffer by absolute number",
        },
      }
      for i,n in ipairs({
        "first", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th"
      }) do
        table.insert(keys, {
          "<leader>"..i,
          "<cmd>lua require('bufferline').go_to_buffer("..i..")<cr>",
          desc = "Goto "..n.." buffer",
        })
      end
      table.insert(keys, {
        "<leader>$",
        "<cmd>lua require('bufferline').go_to_buffer(-1)<cr>",
        desc = "Goto last buffer",
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
        "<leader>fe",
        function()
          return require("nvim-tree.api").tree.toggle(true, false)
        end,
        silent = true,
        desc = "Toggle file explorer",
      },
    },
    opts = function ()

      local edit = function (mode, node)
        local path = node.absolute_path
        if node.link_to and not node.nodes then
          path = node.link_to
        end
        require("nvim-tree.actions.node.open-file").fn(mode, path)
      end

      local expand = function()
        local api = require("nvim-tree.api")
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
        local api = require("nvim-tree.api")
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

      return {
        sync_root_with_cwd = true,
        diagnostics = {
          enable = true,
          debounce_delay = 1000,
          show_on_dirs = true,
        },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          api.config.mappings.default_on_attach(bufnr)
          vim.keymap.set("n", "l",
              expand,
              map_opts(bufnr, "Expand folder/Open file"))
          vim.keymap.set("n", "h",
              collapse,
              map_opts(bufnr, "Collapse folder"))
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
      }
    end,
  },

  -- show file tags in vim window
  {
    "liuchengxu/vista.vim",
    cmd = "Vista",
    keys = {
      { "<leader>te", "<Cmd>Vista!!<CR>", desc = "Toggle ctags explorer" },
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

  -- fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release"..
          " && cmake --build build --config Release"..
          " && cmake --install build --prefix build",
      },
      { "nvim-telescope/telescope-live-grep-args.nvim" },
    },
    keys = function()
      local keys = {}

      local get_visual_selection = function ()
        local mode = vim.fn.mode()
        if mode ~= "v" then
          return ""
        end
        vim.cmd("noau normal! \"vy")
        local text = vim.fn.getreg("v")
        vim.fn.setreg("v", {})
        text = string.gsub(text, "\n", "")
        if #text > 0 then
          return text
        else
          return ""
        end
      end

      local set_keymap = function (key, picker, theme, desc, opts)
        opts = opts or {}
        opts.prompt_title = desc
        local rhs = function()
          if theme ~= nil and theme ~= "" then
            opts = require("telescope.themes")["get_"..theme](opts)
          end
          opts.default_text = get_visual_selection()
          if opts and opts.grep_current_buffer then
            opts.search_dirs = { vim.api.nvim_buf_get_name(0) }
          else
            opts.search_dirs = nil
          end
          picker(opts)
        end
        table.insert(keys, {
          key,
          rhs,
          mode = { "n", "v" },
          noremap = true,
          silent = true,
          desc = desc,
        })
      end

      local symbol_picker = function(opts)
        local lsp = vim.lsp
        local buf_clients = lsp.get_active_clients({ bufnr = opts.bufnr })
        local buf_client_num = #vim.tbl_keys(buf_clients)
        if buf_client_num > 0 then
          opts.prompt_title = "Search LSP Symbols (Current Workspace)"
          require("telescope.builtin").lsp_workspace_symbols(opts)
        else
          opts.prompt_title = "Search Ctags Symbols (Current Workspace)"
          require("telescope.builtin").tags(opts)
        end
      end

      local doc_symbol_picker = function(opts)
        local lsp = vim.lsp
        local buf_clients = lsp.get_active_clients({ bufnr = opts.bufnr })
        local buf_client_num = #vim.tbl_keys(buf_clients)
        if buf_client_num > 0 then
          opts.prompt_title = "Search LSP Symbols (Current Buffer)"
          require("telescope.builtin").lsp_document_symbols(opts)
        else
          opts.prompt_title = "Search Ctags Symbols (Current Buffer)"
          require("telescope.builtin").current_buffer_tags(opts)
        end
      end

      set_keymap(
        "<leader>h",
        function(...)
          require("telescope.builtin").builtin(...)
        end,
        nil,
        "Find Telescope Builtin Pickers"
      )
      set_keymap(
        "<leader>f",
        function (...)
          require("telescope.builtin").find_files(...)
        end,
        nil,
        "Find Files"
      )
      set_keymap(
        "<leader>b",
        function (...)
          require("telescope.builtin").buffers(...)
        end,
        nil,
        "Find Buffers",
        { sort_mru = true, }
      )
      set_keymap(
        "<leader>s",
        function(...)
          require("telescope").extensions.live_grep_args.live_grep_args(...)
        end,
        nil,
        "Search in Workspace"
      )
      set_keymap(
        "<leader>c",
        function(...)
          require("telescope").extensions.live_grep_args.live_grep_args(...)
        end,
        nil,
        "Search in Current Buffer",
        { grep_current_buffer = true }
      )
      set_keymap(
        "<leader>w",
        symbol_picker,
        nil,
        "Search LSP/Ctags Symbols in Workspace"
      )
      set_keymap(
        "<leader>d",
        doc_symbol_picker,
        nil,
        "Search LSP/Ctags Symbols in Current Buffer"
      )
      set_keymap(
        "<leader>m",
        function (...)
          require("telescope.builtin").marks(...)
        end,
        nil,
        "Find Marks"
      )
      set_keymap(
        "<leader>M",
        function (...)
          require("telescope.builtin").keymaps(...)
        end,
        nil,
        "Find Keymaps"
      )
      set_keymap(
        "<leader>r",
        function (...)
          require("telescope.builtin").registers(...)
        end,
        nil,
        "Find Registers"
      )
      set_keymap(
        "<leader>q",
        function (...)
          require("telescope.builtin").quickfix(...)
        end,
        nil,
        "Search Quick Fix"
      )
      set_keymap(
        "<leader>l",
        function (...)
          require("telescope.builtin").loclist(...)
        end,
        nil,
        "Search Location List"
      )
      set_keymap(
        "<leader>n",
        function(...)
          require("telescope").extensions.notify.notify(...)
        end,
        nil,
        "Search Notify History"
      )
      return keys
    end,
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-Down>"] = function(...)
              require("telescope.actions").cycle_history_next(...)
            end,
            ["<C-Up>"] = function(...)
              require("telescope.actions").cycle_history_prev(...)
            end,

            ["<C-u>"] = function(...)
              require("telescope.actions").preview_scrolling_up(...)
            end,
            ["<C-d>"] = function(...)
              require("telescope.actions").preview_scrolling_down(...)
            end,
            ["<C-f>"] = function(...)
              require("telescope.actions").preview_scrolling_left(...)
            end,
            ["<C-b>"] = function(...)
              require("telescope.actions").preview_scrolling_right(...)
            end,
          },
          n = {
            ["l"] = function(...)
              require("telescope.actions").select_default(...)
            end,
            ["o"] = function(...)
              -- Open the file
              require("telescope.actions").select_default(...)
            end,

            ["<C-u>"] = function(...)
              require("telescope.actions").preview_scrolling_up(...)
            end,
            ["<C-d>"] = function(...)
              require("telescope.actions").preview_scrolling_down(...)
            end,
            ["<C-f>"] = function(...)
              require("telescope.actions").preview_scrolling_left(...)
            end,
            ["<C-b>"] = function(...)
              require("telescope.actions").preview_scrolling_right(...)
            end,
          },
        }
      },
      extensions = {
        fzf = {
          fuzzy = true,                    -- false will only do exact matching
          override_generic_sorter = true,  -- override the generic sorter
          override_file_sorter = true,     -- override the file sorter
          case_mode = 'smart_case',        -- options: 'ignore_case', 'respect_case'
        }
      }
    },
    config = function()
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("live_grep_args")
      --[[
      -- previewer options
      vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopePreviewerLoaded",
        callback = function(args)
          if args.data.filetype ~= "help" then
            vim.wo.number = true
          end
          if args.data.bufname:match("*.csv") then
            vim.wo.wrap = false
          else
            vim.wo.wrap = true
          end
        end,
      })
      --]]
    end,
  },

  -- search/replace in multiple files
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    keys = {
      {
        "<leader>S",
        function()
          require("spectre").open()
        end,
        desc = "Replace in files (Spectre)"
      },
    },
  },

  -- Dashboard. This runs when neovim starts, and is what displays
  -- the "LAZYVIM" banner.
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
        dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("g", "  Find text", ":Telescope live_grep <CR>"),
        dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
        dashboard.button("s", "  Restore Session",
            [[:lua require("persistence").load() <CR>]]),
        dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
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
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = {
        char = "",
      },
      scope = {
        enabled = false,
      },
    },
    config = function (_, opts)
      require("ibl").setup(opts)
      local gid = vim.api.nvim_create_augroup("IBL_Augroup",
          { clear = true })
      vim.api.nvim_create_autocmd("InsertEnter", {
        pattern = "*",
        group = gid,
        command = "IBLDisable",
      })

      vim.api.nvim_create_autocmd("InsertLeave", {
        pattern = "*",
        group = gid,
        command = "IBLEnable",
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
      require("config.utils").on_lsp_attach(function(client, buffer)
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

}

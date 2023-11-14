local M = {}

M.kind_filter = {
  default = {
    "Class",
    "Constructor",
    "Enum",
    "Field",
    "Function",
    "Interface",
    "Method",
    "Module",
    "Namespace",
    "Package",
    "Property",
    "Struct",
    "Trait",
  },
  markdown = false,
  help = false,
  -- you can specify a different filter for each filetype
  lua = {
    "Class",
    "Constructor",
    "Enum",
    "Field",
    "Function",
    "Interface",
    "Method",
    "Module",
    "Namespace",
    -- "Package", -- remove package since luals uses it for control flow structures
    "Property",
    "Struct",
    "Trait",
  },
}

M.get_kind_filter = function (buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local ft = vim.bo[buf].filetype
  if M.kind_filter == false then
    return
  end
  if M.kind_filter[ft] == false then
    return
  end
  return type(M.kind_filter) == "table" and
         type(M.kind_filter.default) == "table" and
         M.kind_filter.default or nil
end

M.workspace_symbols = function(opts)
  local lsp = vim.lsp
  local buf_clients = lsp.get_active_clients({ bufnr = opts.bufnr })
  local buf_client_num = #vim.tbl_keys(buf_clients)
  if buf_client_num > 0 then
    require("telescope.builtin").lsp_workspace_symbols(opts)
  else
    require("telescope.builtin").tags(opts)
  end
end

M.document_symbols = function(opts)
  local lsp = vim.lsp
  local buf_clients = lsp.get_active_clients({ bufnr = opts.bufnr })
  local buf_client_num = #vim.tbl_keys(buf_clients)
  if buf_client_num > 0 then
    require("telescope.builtin").lsp_document_symbols(opts)
  else
    require("telescope.builtin").current_buffer_tags(opts)
  end
end

M.get_visual_selection = function ()
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

M.picker = function(func, opts)
  local params = { func = func, opts = opts }
  return function()
    opts = params.opts
    opts = vim.tbl_deep_extend("force", { cwd = vim.loop.cwd() }, opts or {})

    if opts.default_text == nil then
      local mode = vim.fn.mode()
      if mode == "v" then
        opts.default_text = M.get_visual_selection()
      end
    end

    if opts.cwd and opts.cwd ~= vim.loop.cwd() then
      opts.attach_mappings = function(_, map)
        map("i", "<a-c>", function()
          local action_state = require("telescope.actions.state")
          local line = action_state.get_current_line()
          M.picker(
            params.func,
            vim.tbl_deep_extend("force", {}, params.opts or {}, { cwd = false, default_text = line })
          )()
        end)
        return true
      end
    end

    if opts.current_buffer then
      opts.search_dirs = { vim.api.nvim_buf_get_name(0) }
    else
      opts.search_dirs = nil
    end

    func = params.func

    if type(func) == "function" then
      -- do nothing
    elseif func == "files" then
      if vim.loop.fs_stat((opts.cwd or vim.loop.cwd()) .. "/.git") then
        opts.show_untracked = true
        func = "git_files"
      else
        func = "find_files"
      end
      func = require("telescope.builtin")[func]
    elseif func == "notify" then
      func = require("telescope").extensions.notify.notify
    elseif func == "live_grep" then
      func = require("telescope").extensions.live_grep_args.live_grep_args
    elseif func == "document_symbols" then
      func = M.document_symbols
    elseif func == "workspace_symbols" then
      func = M.workspace_symbols
    else
      func = require("telescope.builtin")[func]
    end

    func(opts)
  end
end

M.action = function (func, opts)
  local params = { func = func, opts = opts }
  return function()
    opts = params.opts
    func = params.func
    require("telescope.actions")[func](opts)
  end
end

M.keys = function (keys)
  for _,o in ipairs(keys) do
    if type(o.mode) == "nil" then
      o.mode = { "n", "v" }
    end
  end
  return keys;
end

return {

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
      return M.keys({
        { "<leader>,", M.picker("live_grep"), desc = "Grep in Workspace", },
        -- find
        { "<leader>fb", M.picker("buffers", { sort_mru = true, sort_lastused = true }), desc = "Find Buffers", },
        { "<leader>fc", M.picker("find_files", { cwd = vim.fn.stdpath("config") }), desc = "Find Config Files", },
        { "<leader>ff", M.picker("files"), desc = "Find Files" },
        { "<leader>fr", M.picker("oldfiles"), desc = "Recent Files" },
        -- git
        { "<leader>gc", M.picker("git_commits"), desc = "git commits" },
        { "<leader>gs", M.picker("git_status"), desc = "git status" },
        -- search
        { '<leader>s"', M.picker("registers"), desc = "Registers" },
        { "<leader>sa", M.picker("autocommands"), desc = "Auto Commands" },
        { "<leader>sb", M.picker("current_buffer_fuzzy_find"), desc = "Fuzzy Search in Buffer" },
        { "<leader>sc", M.picker("command_history"), desc = "Command History" },
        { "<leader>sC", M.picker("commands"), desc = "Commands" },
        { "<leader>sd", M.picker("diagnostics", { bufnr = 0, }), desc = "Diagnostics in Buffer" },
        { "<leader>sD", M.picker("diagnostics"), desc = "Diagnostics in Workspace" },
        { "<leader>sg", M.picker("live_grep"), desc = "Grep in Workspace" },
        { "<leader>sG", M.picker("live_grep", { current_buffer = true }), desc = "Grep in Buffer" },
        { "<leader>sh", M.picker("help_tags"), desc = "Help Pages" },
        { "<leader>sH", M.picker("highlights"), desc = "Highlight Groups" },
        { "<leader>sk", M.picker("keymaps"), desc = "Key Maps" },
        { "<leader>sl", M.picker("loclist"), desc = "Loc List" },
        { "<leader>sM", M.picker("man_pages"), desc = "Man Pages" },
        { "<leader>sm", M.picker("marks"), desc = "Jump to Mark" },
        { "<leader>sn", M.picker("notify"), desc = "Notify History" },
        { "<leader>so", M.picker("vim_options"), desc = "Options" },
        { "<leader>sq", M.picker("quickfix"), desc = "Quick Fix" },
        { "<leader>sr", M.picker("resume"), desc = "Resume" },
        { "<leader>sw", M.picker("grep_string", { word_match = "-w" }), desc = "Word in Workspace" },
        { "<leader>sW", M.picker("grep_string", { word_match = "-w", current_buffer = true }), desc = "Word in Buffer" },
        { "<leader>uC", M.picker("colorscheme", { enable_preview = true }), desc = "Colorscheme with preview" },
        { "<leader>ss", M.picker("document_symbols", { symbols = M.get_kind_filter(), }), desc = "Symbol in Buffer", },
        { "<leader>sS", M.picker("workspace_symbols", { symbols = M.get_kind_filter(), }), desc = "Symbol in Workspace", },
      })
    end,
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-Down>"] = M.action("cycle_history_next"),
            ["<C-Up>"]   = M.action("cycle_history_prev"),

            ["<C-u>"] = M.action("preview_scrolling_up"),
            ["<C-d>"] = M.action("preview_scrolling_down"),
            ["<C-f>"] = M.action("preview_scrolling_left"),
            ["<C-b>"] = M.action("preview_scrolling_right"),
          },
          n = {
            ["l"] = M.action("select_default"),
            ["o"] = M.action("select_default"), -- Open the file

            ["<C-u>"] = M.action("preview_scrolling_up"),
            ["<C-d>"] = M.action("preview_scrolling_down"),
            ["<C-f>"] = M.action("preview_scrolling_left"),
            ["<C-b>"] = M.action("preview_scrolling_right"),
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

}

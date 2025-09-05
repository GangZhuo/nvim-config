return {

  -- snippets
  {
    "L3MON4D3/LuaSnip",
    build = (not jit.os:find("Windows"))
        and "echo 'NOTE: jsregexp is optional, so not a big deal "..
                  "if it fails to build'; "..
            "make install_jsregexp"
      or nil,
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    keys = {
      {
        "<tab>",
        function()
          return require("luasnip").jumpable(1)
              and "<Plug>luasnip-jump-next" or "<tab>"
        end,
        expr = true,
        silent = true,
        mode = "i",
      },
      {
        "<tab>",
        function()
          require("luasnip").jump(1)
        end,
        mode = "s",
      },
      {
        "<s-tab>",
        function()
          require("luasnip").jump(-1)
        end,
        mode = { "i", "s" },
      },
    },
  },

  -- auto completion
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    cmd = "CmpStatus",
    dependencies = {
      -- nvim-cmp completion sources
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      "saadparwaiz1/cmp_luasnip",
      "dmitmel/cmp-cmdline-history",
      "delphinus/cmp-ctags",
      "uga-rosa/cmp-dictionary",
      "zbirenbaum/copilot-cmp",
    },
    opts = function()
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and
          vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
            :sub(col, col):match("%s") == nil
      end
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      return {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end,
          ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end,
          ["<CR>"] = cmp.mapping.confirm { select = true },
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
        }),
        sources = cmp.config.sources({
          { name = "copilot" },
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
          { name = "ctags", option = { trigger_characters = {} } },
          { name = "nvim_lua" },
          { name = "dictionary", keyword_length = 2 },
        }),
        formatting = {
          format = function(entry, item)
            local icons = require("config.icons").kinds
            local utils = require("config.utils")
            local name = utils.firstToUpper(entry.source.name or "");
            if icons[name] then
              item.kind = icons[name] .. item.kind
            elseif icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end
            return item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
      }
    end,
    config = function(_, opts)
      local cmp = require("cmp")
      local utils = require("config.utils")

      -- Remove source when 'exclusion' is false
      local function del_source(name, exclusion)
        if exclusion then return end
        for i, v in ipairs(opts.sources) do
          if v.name == name then
            return table.remove(opts.sources, i)
          end
        end
      end

      del_source("copilot", utils.has_plugin("copilot.lua"))
      del_source("nvim_lsp", utils.has_plugin("nvim-lspconfig"))
      del_source("ctags", utils.has_plugin("vim-gutentags"))

      cmp.setup(opts)

      -- `/` cmdline setup.
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "buffer" },
          { name = "path" },
        })
      })

      -- `:` cmdline setup.
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "cmdline", option = { ignore_cmds = { "Man", "!" } } },
          { name = "cmdline_history" },
          { name = "path" },
        })
      })

    end
  },

  -- nvim-cmp dictionary sources
  {
    "uga-rosa/cmp-dictionary",
    lazy = true,
    opts = {},
    config = function()
      local dict_root = string.format("%s/dict/", vim.fn.stdpath("config"))

      -- get fullpath
      local F = function (filename)
        return dict_root..filename
      end

      local opts = {
        paths = {
          F"global.dic",
          F"en.dic",
        },
        exact_length = 2,
        first_case_insensitive = true,
      }

      --[[
      if vim.fn.executable("wn") == 1 then
        opts.document = {
          enable = true,
          command = { "wn", "${label}", "-over" },
        }
      end
      --]]

      require("cmp_dictionary").setup(opts)

    end
  },

}

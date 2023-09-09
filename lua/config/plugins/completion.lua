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
    event = "InsertEnter",
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
      local defaults = require("cmp.config.default")()
      local luasnip = require("luasnip")
      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
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
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path", option = { trailing_slash = true } },
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
        sorting = defaults.sorting,
      }
    end,
    config = function(_, opts)
      local cmp = require("cmp")

      local utils = require("config.utils")
      if utils.has("copilot.lua") and utils.has("copilot-cmp") then
        require("copilot_cmp")
        table.insert(opts.sources, 1, cmp.config.sources({
          { name = "copilot" }
        })[1])
      end

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

  {
    "uga-rosa/cmp-dictionary",
    opts = {},
    config = function(_, opts)
      local cmp_dict = require("cmp_dictionary")
      local dict_root = string.format("%s/dict/", vim.fn.stdpath("config"))

      -- get fullpath
      local F = function (filename)
        return dict_root..filename
      end

      cmp_dict.setup(opts)

      cmp_dict.switcher({
        filepath = {
          ["*"] = {
            F"global.dic",
          },
        },
        spelllang = {
          en = F"en.dic",
        },
      })

    end
  },

}
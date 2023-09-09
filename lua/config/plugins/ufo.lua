return {

  -- Ultra fold in Neovim base on lsp, treesitter and indent
  {
    "kevinhwang91/nvim-ufo",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      -- Using ufo provider need remap `zR` and `zM`.
      { "zR", function(...) require("ufo").openAllFolds(...) end, },
      { "zM", function(...) require("ufo").closeAllFolds(...) end, },
      { "zr", function(...) require("ufo").openFoldsExceptKinds(...) end, },
      { "zm", function(...) require("ufo").closeFoldsWith(...) end, },

    },
    opts = function()
      local ftMap = {
        vim    = "indent",
        python = { "indent" },
        git = ""
      }

      local chainSelector = function(bufnr)
        local handleFallbackException = function(err, providerName)
          if type(err) == "string" and err:match("UfoFallbackException") then
            return require("ufo").getFolds(bufnr, providerName)
          else
            return require("promise").reject(err)
          end
        end

        return require("ufo").getFolds(bufnr, "lsp"):catch(function(err)
            return handleFallbackException(err, "treesitter")
          end):catch(function(err)
            return handleFallbackException(err, "indent")
          end)
      end

      return {
        provider_selector = function(bufnr, filetype, buftype)
          return ftMap[filetype] or chainSelector
        end
      }
    end,
    config = function(_, opts)
      vim.o.foldcolumn = "1" -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      require("ufo").setup(opts)
    end
  },

  { "kevinhwang91/promise-async", lazy = true }
}

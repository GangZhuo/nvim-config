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
        close_command = "bdelete! %d",
        right_mouse_command = nil,
        left_mouse_command = "buffer %d",
        middle_mouse_command = nil,
        indicator = {
          icon = "▎", -- this should be omitted if indicator style is not 'icon'
          style = "icon",
        },
        buffer_close_icon = "󰅙",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 10,
        diagnostics = false,
        custom_filter = function(bufnr)
          -- You can check whatever you would like and return `true`
          -- if you would like it to appear and `false` if not.
          local exclude_ft = { "qf" }
          local cur_ft = vim.bo[bufnr].filetype
          return not vim.tbl_contains(exclude_ft, cur_ft)
        end,
        show_buffer_icons = false,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
        separator_style = "bar",
        enforce_regular_tabs = false,
        always_show_bufferline = true,
      },
    },
  },
}

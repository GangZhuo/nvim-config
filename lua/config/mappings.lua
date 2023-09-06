local keymap = vim.keymap
local api = vim.api
local uv = vim.loop
local diagnostic = vim.diagnostic

-- Turn the word under cursor to upper case
keymap.set("i", "<c-u>", "<Esc>viwUea")

-- Turn the current word into title case
keymap.set("i", "<c-t>", "<Esc>b~lea")

-- insert semicolon in the end
keymap.set("i", "<A-;>", "<Esc>miA;<Esc>`ii")

-- Go to the beginning and end of current line in insert mode quickly
keymap.set("i", "<C-A>", "<HOME>")
keymap.set("i", "<C-E>", "<END>")

-- Delete the character to the right of the cursor
keymap.set("i", "<C-D>", "<DEL>")

-- Go to beginning of command in command-line mode
keymap.set("c", "<C-A>", "<HOME>")

-- Save key strokes (now we do not need to press shift to enter command mode).
keymap.set({ "n", "x" }, ";", ":")

-- Paste non-linewise text above or below current line, see https://stackoverflow.com/a/1346777/6064933
--keymap.set("n", "<leader>p", "m`o<ESC>p``", { desc = "paste below current line" })
--keymap.set("n", "<leader>P", "m`O<ESC>p``", { desc = "paste above current line" })

-- Copy entire buffer.
keymap.set("n", "<leader>y", "<cmd>%yank<cr>", { desc = "yank entire buffer" })

-- Copy to system clipboard
keymap.set("x", "<leader>y", "\"+y", { desc = "yank to system clipboard" })

-- Paste from system clipboard
keymap.set({ "n", "x" }, "<leader>p", "\"+p", { desc = "paste system clipboard after current cursor" })
keymap.set({ "n", "x" }, "<leader>P", "\"+P", { desc = "paste system clipboard before current cursor" })

-- Shortcut for faster save and quit
keymap.set("n", "<leader>w", "<cmd>update<cr>", { silent = true, desc = "save buffer" })

-- Close location list or quickfix list if they are present, see https://superuser.com/q/355325/736190
keymap.set("n", [[\x]], "<cmd>windo lclose <bar> cclose <cr>", {
  silent = true,
  desc = "close qf and location list",
})

-- Delete a buffer, without closing the window, see https://stackoverflow.com/q/4465095/6064933
keymap.set("n", [[\d]], "<cmd>bprevious <bar> bdelete #<cr>", {
  silent = true,
  desc = "delete buffer",
})

-- Insert a blank line below or above current line (do not move the cursor),
-- see https://stackoverflow.com/a/16136133/6064933
keymap.set("n", "<space>o", "printf('m`%so<ESC>``', v:count1)", {
  expr = true,
  desc = "insert line below",
})

keymap.set("n", "<space>O", "printf('m`%sO<ESC>``', v:count1)", {
  expr = true,
  desc = "insert line above",
})

-- Move the cursor based on physical lines, not the actual lines.
keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Go to start or end of line easier
keymap.set({ "n", "x" }, "H", "g^")
keymap.set({ "n", "x" }, "L", "g_")

-- Go to start or end of screen
keymap.set({ "n", "x" }, "zh", "H")
keymap.set({ "n", "x" }, "zl", "L")
keymap.set({ "n", "x" }, "zm", "M")

-- Continuous visual shifting (does not exit Visual mode), `gv` means
-- to reselect previous visual area, see https://superuser.com/q/310417/736190
keymap.set("x", "<", "<gv")
keymap.set("x", ">", ">gv")

-- Edit and reload nvim config file quickly
keymap.set("n", "<leader>ev", "<cmd>tabnew $MYVIMRC <bar> tcd %:h<cr>", {
  silent = true,
  desc = "open init.lua",
})

-- Reselect the text that has just been pasted, see also https://stackoverflow.com/a/4317090/6064933.
keymap.set("n", "<leader>v", "printf('`[%s`]', getregtype()[0])", {
  expr = true,
  desc = "reselect last pasted area",
})

-- Always use very magic mode for searching
keymap.set("n", "/", [[/\v]])

-- Change current working directory locally and print cwd after that,
-- see https://vim.fandom.com/wiki/Set_working_directory_to_the_current_file
keymap.set("n", "<leader>cd", "<cmd>lcd %:p:h<cr><cmd>pwd<cr>", { desc = "change cwd" })

-- Use Esc to quit builtin terminal
keymap.set("t", "<Esc>", [[<c-\><c-n>]])

-- Toggle spell checking
keymap.set("n", "<F11>", "<cmd>set spell!<cr>", { desc = "toggle spell" })
keymap.set("i", "<F11>", "<c-o><cmd>set spell!<cr>", { desc = "toggle spell" })

-- Change text without putting it into the vim register,
-- see https://stackoverflow.com/q/54255/6064933
keymap.set("n", "c", '"_c')
keymap.set("n", "C", '"_C')
keymap.set("n", "cc", '"_cc')
keymap.set("x", "c", '"_c')

-- Toggle cursor column
keymap.set("n", "<leader>cl", function ()
  if vim.o.cursorcolumn then
    vim.o.cursorcolumn = false
  else
    vim.o.cursorcolumn = true
  end
end, { desc = "toggle cursor column" })

-- Replace visual selection with text in register, but not contaminate the register,
-- see also https://stackoverflow.com/q/10723700/6064933.
keymap.set("x", "p", '"_c<Esc>p')

-- Switch windows
keymap.set("n", "<C-H>", "<c-w>h")
keymap.set("n", "<C-L>", "<C-W>l")
keymap.set("n", "<C-K>", "<C-W>k")
keymap.set("n", "<C-J>", "<C-W>j")

-- Increase/decrease horizontal size for window
keymap.set("n", "<A-->", "<cmd>resize +3<cr>")
keymap.set("n", "<A-_>", "<cmd>resize -3<cr>")

-- Increase/decrease horizontal size for window
keymap.set("n", "<A-(>", "<cmd>vertical resize -3<cr>")
keymap.set("n", "<A-)>", "<cmd>vertical resize +3<cr>")

-- Break inserted text into smaller undo units when we insert some punctuation chars.
local undo_ch = { ",", ".", "!", "?", ";", ":" }
for _, ch in ipairs(undo_ch) do
  keymap.set("i", ch, ch .. "<c-g>u")
end

keymap.set("n", "<leader>cb", function()
  local cnt = 0
  local blink_times = 7
  local timer = uv.new_timer()

  timer:start(0, 100, vim.schedule_wrap(function()
    vim.cmd[[
      set cursorcolumn!
      set cursorline!
    ]]

    if cnt == blink_times then
      timer:close()
    end

    cnt = cnt + 1
  end))
end)

-- Print treesitter captures
keymap.set("n", "<leader>st", function()
  if vim.treesitter then
    local captures = vim.treesitter.get_captures_at_cursor(0)
    vim.print(captures)
  else
    api.nvim_err_writeln("treesitter not found!")
  end
end, {
    silent = true,
    desc = "Show treesitter captures"
})

keymap.set("n", "<BackSpace>", "<cmd>nohl<cr>")

keymap.set('n', '<space>e', diagnostic.open_float, { desc = "Show diagnostics in a floating window." })
keymap.set('n', '<space>l', diagnostic.setloclist, { desc = "Add buffer diagnostics to the location list." })
keymap.set('n', '[d',       diagnostic.goto_prev,  { desc = "Move to the previous diagnostic in the current buffer." })
keymap.set('n', ']d',       diagnostic.goto_next,  { desc = "Move to the next diagnostic." })
keymap.set('n', 'gk',       diagnostic.goto_prev,  { desc = "Move to the previous diagnostic in the current buffer." })
keymap.set('n', 'gj',       diagnostic.goto_next,  { desc = "Move to the next diagnostic." })

-- Navigation in the location and quickfix list
keymap.set("n", "[l", "<cmd>lprevious<cr>zv", { silent = true, desc = "previous location item" })
keymap.set("n", "]l", "<cmd>lnext<cr>zv", { silent = true, desc = "next location item" })

keymap.set("n", "[L", "<cmd>lfirst<cr>zv", { silent = true, desc = "first location item" })
keymap.set("n", "]L", "<cmd>llast<cr>zv", { silent = true, desc = "last location item" })

keymap.set("n", "[q", "<cmd>cprevious<cr>zv", { silent = true, desc = "previous qf item" })
keymap.set("n", "]q", "<cmd>cnext<cr>zv", { silent = true, desc = "next qf item" })

keymap.set("n", "[Q", "<cmd>cfirst<cr>zv", { silent = true, desc = "first qf item" })
keymap.set("n", "]Q", "<cmd>clast<cr>zv", { silent = true, desc = "last qf item" })

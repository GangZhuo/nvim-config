local map = vim.keymap.set
local api = vim.api
local uv = vim.loop
local diagnostic = vim.diagnostic

-- Turn the word under cursor to upper case
map("i", "<c-u>", "<Esc>viwUea")

-- Turn the current word into title case
map("i", "<c-t>", "<Esc>b~lea")

-- insert semicolon in the end
map("i", "<A-;>", "<Esc>miA;<Esc>`ii")

-- Go to the beginning and end of current line in insert mode quickly
map("i", "<C-A>", "<HOME>")
map("i", "<C-E>", "<END>")

-- Delete the character to the right of the cursor
map("i", "<C-D>", "<DEL>")

-- Go to beginning of command in command-line mode
map("c", "<C-A>", "<HOME>")

-- Save key strokes (now we do not need to press shift to enter command mode).
map({ "n", "x" }, ";", ":")

-- Copy entire buffer.
map("n", "<leader>y", "<cmd>%yank<cr>", { desc = "yank entire buffer" })

-- Copy to system clipboard
map("x", "<leader>y", "\"+y", { desc = "yank to system clipboard" })

-- Paste from system clipboard
map({ "n", "x" }, "<leader>p", "\"+p", { desc = "paste system clipboard after current cursor" })
map({ "n", "x" }, "<leader>P", "\"+P", { desc = "paste system clipboard before current cursor" })

-- Move the cursor based on physical lines, not the actual lines.
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Go to start or end of line easier
map({ "n", "x" }, "H", "g^")
map({ "n", "x" }, "L", "g_")

-- Go to start or end of screen
map({ "n", "x" }, "zh", "H", { desc = "move cursor to screen top" })
map({ "n", "x" }, "zl", "L", { desc = "move cursor to screen bottom" })

-- Continuous visual shifting (does not exit Visual mode), `gv` means
-- to reselect previous visual area, see https://superuser.com/q/310417/736190
map("x", "<", "<gv")
map("x", ">", ">gv")

-- Change text without putting it into the vim register,
-- see https://stackoverflow.com/q/54255/6064933
map("n", "c", '"_c')
map("n", "C", '"_C')
map("n", "cc", '"_cc')
map("x", "c", '"_c')

-- Replace visual selection with text in register, but not contaminate the register.
map("x", "p", 'P')

-- Reselect the text that has just been pasted, see also https://stackoverflow.com/a/4317090/6064933.
map("n", "<leader>v", "printf('`[%s`]', getregtype()[0])", {
  expr = true,
  desc = "reselect last pasted area",
})

-- Always use very magic mode for searching
map("n", "/", [[/\v]])

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Buffers.
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
-- Delete a buffer, without closing the window,
-- see https://stackoverflow.com/q/4465095/6064933
map("n", [[\d]], "<cmd>bprevious <bar> bdelete #<cr>",
  { silent = true, desc = "delete buffer" }
)

-- Break inserted text into smaller undo units when we
-- insert some punctuation chars.
local undo_ch = { ",", ".", "!", "?", ";", ":" }
for _, ch in ipairs(undo_ch) do
  map("i", ch, ch .. "<c-g>u")
end

-- Clear search
map("n", "<BackSpace>", "<cmd>nohl<cr>", { desc = "Clear hlsearch" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)

-- Toggle spell checking
map("n", "<F11>", "<cmd>set spell!<cr>", { desc = "toggle spell" })
map("i", "<F11>", "<c-o><cmd>set spell!<cr>", { desc = "toggle spell" })

-- Toggle cursor column
map("n", "<leader>cl", function ()
  if vim.o.cursorcolumn then
    vim.o.cursorcolumn = false
  else
    vim.o.cursorcolumn = true
  end
end, { desc = "toggle cursor column" })

-- Blink cursor row and column
map("n", "<leader>cb", function()
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
map("n", "<leader>st", function()
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

-- Terminal Mappings
map("n", "<leader>ft",
  function()
    require("config.utils").float_term()
  end,
  { desc = "Float Terminal" }
)
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- Diagnostic

-- Close location list or quickfix list if they are present, see https://superuser.com/q/355325/736190
map("n", [[\x]], "<cmd>windo lclose <bar> cclose <cr>", {
  silent = true,
  desc = "close qf and location list",
})

map('n', '<space>e', diagnostic.open_float, { desc = "Show diagnostics in a floating window." })
map('n', '<space>l', diagnostic.setloclist, { desc = "Add buffer diagnostics to the location list." })
map('n', '[d',       diagnostic.goto_prev,  { desc = "Move to the previous diagnostic in the current buffer." })
map('n', ']d',       diagnostic.goto_next,  { desc = "Move to the next diagnostic." })
map('n', 'gk',       diagnostic.goto_prev,  { desc = "Move to the previous diagnostic in the current buffer." })
map('n', 'gj',       diagnostic.goto_next,  { desc = "Move to the next diagnostic." })

-- Navigation in the location and quickfix list
map("n", "[l", "<cmd>lprevious<cr>zv", { silent = true, desc = "previous location item" })
map("n", "]l", "<cmd>lnext<cr>zv", { silent = true, desc = "next location item" })

map("n", "[L", "<cmd>lfirst<cr>zv", { silent = true, desc = "first location item" })
map("n", "]L", "<cmd>llast<cr>zv", { silent = true, desc = "last location item" })

map("n", "[q", "<cmd>cprevious<cr>zv", { silent = true, desc = "previous qf item" })
map("n", "]q", "<cmd>cnext<cr>zv", { silent = true, desc = "next qf item" })

map("n", "[Q", "<cmd>cfirst<cr>zv", { silent = true, desc = "first qf item" })
map("n", "]Q", "<cmd>clast<cr>zv", { silent = true, desc = "last qf item" })


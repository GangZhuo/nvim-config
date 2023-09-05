local utils = require("config.utils")

-- Custom mapping <leader>
vim.g.mapleader = ','

-- Enable highlighting for lua HERE doc inside vim script
vim.g.vimsyn_embed = 'l'

-- Change fillchars
-- See https://neovim.io/doc/user/options.html#'fillchars'
vim.o.fillchars = utils.join_dic({
  vert      = "│",
  eob       = " ",
  msgsep    = "‾",
  fold      = " ",
  foldopen  = "",
  foldsep   = " ",
  foldclose = "",
})

-- Split window below/right when creating horizontal/vertical windows
vim.o.splitbelow = true
vim.o.splitright = true

-- Time in milliseconds to wait for a mapped sequence to complete,
-- see https://unix.stackexchange.com/q/36882/221410 for more info
vim.o.timeoutlen = 500

-- For CursorHold events
-- Trigger CursorHold event when the user doesn't press a key for
-- the time specified with 'updatetime'.
vim.o.updatetime = 500

-- The number of command and search history to keep
vim.o.history = 500

-- Disable creating swapfiles, see https://stackoverflow.com/q/821902/6064933
vim.o.swapfile = false

local wildignore = utils.join_arr({
  "*.o",
  "*.obj",
  "*.dylib",
  "*.bin",
  "*.dll",
  "*.exe",

  "*/.git/*",
  "*/.svn/*",
  "*/__pycache__/*",
  "*/build/**",

  "*.jpg",
  "*.png",
  "*.jpeg",
  "*.bmp",
  "*.gif",
  "*.tiff",
  "*.svg",
  "*.ico",

  "*.pyc",
  "*.pkl",

  "*.DS_Store",

  "*.aux",
  "*.bbl",
  "*.blg",
  "*.brf",
  "*.fls",
  "*.fdb_latexmk",
  "*.synctex.gz",
  "*.xdv",
})

-- Ignore certain files and folders when globing
vim.o.wildignore = wildignore

-- ignore file and dir name cases in cmd-completion
vim.o.wildignorecase = true

-- Set up backup directory
vim.o.backupdir = vim.fn.stdpath('cache').."/backup//"

-- Skip backup for patterns in option wildignore
vim.o.backupskip = wildignore

-- create backup for files
vim.o.backup = false

-- copy the original file to backupdir and overwrite it
vim.o.backupcopy = "yes"

-- Persistent undo even after you close a file and re-open it
vim.o.undofile = true

-- General tab settings
vim.o.tabstop     = 4     -- number of visual spaces per TAB
vim.o.softtabstop = 4     -- number of spaces in tab when editing
vim.o.shiftwidth  = 4     -- number of spaces to use for autoindent
vim.o.expandtab   = true  -- expand tab to spaces so that tabs are spaces

-- Set matching pairs of characters and highlight matching brackets
vim.o.matchpairs = vim.o.matchpairs .. "," .. utils.join_arr({
  "<:>",
  "「:」",
  "『:』",
  "【:】",
  "“:”",
  "‘:’",
  "《:》",
})

-- Show line number and relative line number
vim.o.number = true
vim.o.relativenumber = true

-- Ignore case in general, but become case-sensitive
-- when uppercase is present
vim.o.ignorecase = true
vim.o.smartcase = true

-- File and script encoding settings for vim
vim.o.fileencoding = "utf-8"
vim.o.fileencodings = utils.join_arr({
  "ucs-bom",
  "utf-8",
  "cp936",
  "gb18030",
  "big5",
  "euc-jp",
  "euc-kr",
  "latin1",
})

-- Break line at predefined characters
vim.o.linebreak = true

-- List all matches and complete till longest common string
vim.o.wildmode = "list:longest"

-- Minimum lines to keep above and below cursor when scrolling
vim.o.scrolloff = 3

-- Use mouse to select and resize windows, etc.
vim.o.mouse = "nic"
vim.o.mousemodel = "popup"
--vim.o.mousescroll = "ver:1,hor:6"

-- Disable showing current mode on command line since
-- statusline plugins can show it.
vim.o.showmode = false

-- Ask for confirmation when handling unsaved or read-only files
vim.o.confirm = true

-- Do not use visual and errorbells
vim.o.visualbell = true
vim.o.errorbells = false

-- Use list mode and customized listchars
vim.o.list = true

-- Auto-write the file based on some condition
vim.o.autowrite = true

vim.o.pumheight = 10  -- Maximum number of items to show in popup menu
vim.o.pumblend  = 10  -- pseudo transparency for completion menu
vim.o.winblend = 0    -- pseudo transparency for floating window

vim.o.spelllang = "en"  -- Spell languages
vim.o.spellsuggest = 9  -- show 9 spell suggestions at most

-- Align indent to next multiple value of shiftwidth. For its meaning,
-- see http://vim.1045645.n5.nabble.com/shiftround-option-td5712100.html
vim.o.shiftround = true

-- Virtual edit is useful for visual block edit
vim.o.virtualedit = "block"

-- Correctly break multi-byte characters such as CJK,
-- see https://stackoverflow.com/q/32669814/6064933
vim.o.formatoptions = vim.o.formatoptions .. "mM"

-- Tilde (~) is an operator, thus must be followed by motions like `e` or `w`.
vim.o.tildeop = true

-- Text after this column number is not highlighted
vim.o.synmaxcol = 500
vim.o.startofline = false

vim.o.signcolumn = "yes:2"

-- diff options
vim.o.diffopt = utils.join_arr({
  "vertical",   -- show diff in vertical position
  "filler",     -- show filler for deleted lines
  "closeoff",   -- turn off diff when one file window is closed
  "context:3",  -- context for diff
  "internal",
  "indent-heuristic",
  "algorithm:histogram",
})

vim.o.wrap = true
vim.o.ruler = false
vim.o.colorcolumn = "80"
vim.o.cmdheight = 2

-- External program to use for grep command
if vim.fn.executable("rg") == 1 then
  vim.o.grepprg = utils.join_arr({
    "rg",
    "--vimgrep",
    "--no-heading",
    "--smart-case",
  }, " ")
  vim.o.grepformat = "%f:%l:%c:%m"
end

-- Enable true color support. Do not set this option if your terminal does not
-- support true colors! For a comprehensive list of terminals supporting true
-- colors, see https://github.com/termstandard/colors and https://gist.github.com/XVilka/8346728.
if vim.fn.has("termguicolors") == 1 then
  vim.o.termguicolors = true
  -- Set up cursor color and shape in various mode, ref:
  -- https://github.com/neovim/neovim/wiki/FAQ#how-to-change-cursor-color-in-the-terminal
  --vim.o.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor2/lCursor2,r-cr:hor20,o:hor20"
end


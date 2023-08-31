-- Load vim options
require("config.options")

-- Try auto-configuring a proxy if it is not in the environment
require("config.proxy")

-- Lazy load plugins
require("config.lazy")

-- Set colorscheme
vim.cmd.colorscheme("sonokai")

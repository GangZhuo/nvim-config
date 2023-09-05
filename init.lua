local utils = require("config.utils")

-- check version
local expected_ver = "0.9.0"
if not utils.expect_ver(expected_ver) then
  local msg = string.format(
      "Unsupported nvim version: expect %s, but got %s instead!",
      expected_ver, utils.version())
  utils.err(msg)
  return
end

-- Enable lua-loader that byte-compiles and caches lua files
vim.loader.enable()

require("config.options")    -- Load vim options
require("config.autocmds")   -- Load auto commands
require("config.usercmds")   -- Load user commands
require("config.mappings")   -- Load key mappings
require("config.proxy")      -- Auto-configuring a proxy
require("config.lazy")       -- Lazy load plugins

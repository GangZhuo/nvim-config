local utils = require("config.utils")

vim.api.nvim_create_user_command(
  'Sudowrite',
  function(opts)
    local filepath = opts.args;
    if utils.zstr(filepath) then
      filepath = vim.fn.expand("%")
    end
    local succ, output = utils.sudo_write(filepath);
    if succ then
      local msg = string.format('"%s" written', filepath)
      utils.info(msg)
    else
      local msg = string.format('%s', output or 'Sudowrite Failed!')
      utils.err(msg)
    end
  end,
  { nargs = '?', desc = 'Write file with privileges' }
)

vim.api.nvim_create_user_command(
  'SetProxy',
  function()
    require("config.proxy").set_proxy()
  end,
  { nargs = 0, desc = 'Set proxy' }
)

vim.api.nvim_create_user_command(
  'UnsetProxy',
  function()
    require("config.proxy").unset_proxy()
  end,
  { nargs = 0, desc = 'Unset proxy' }
)

vim.api.nvim_create_user_command(
  'CloseAllBuffers',
  function()
    utils.close_all_buffers_but_current()
  end,
  { nargs = 0, desc = 'Close all buffers but current' }
)

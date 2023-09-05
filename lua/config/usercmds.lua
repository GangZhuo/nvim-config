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

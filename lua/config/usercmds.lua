local fn = vim.fn
local api = vim.api

local function zstr(s)
  return s == nil or s == ""
end

local function _echo_multiline(msg)
  for _, s in ipairs(fn.split(msg, "\n")) do
    vim.cmd("echom '" .. s:gsub("'", "''") .. "'")
  end
end

local function info(msg)
  vim.cmd("echohl Directory")
  _echo_multiline(msg)
  vim.cmd("echohl None")
end

local function warn(msg)
  vim.cmd("echohl WarningMsg")
  _echo_multiline(msg)
  vim.cmd("echohl None")
end

local function err(msg)
  vim.cmd("echohl ErrorMsg")
  _echo_multiline(msg)
  vim.cmd("echohl None")
end

local function sudo_exec(cmd)
  fn.inputsave()
  local password = fn.inputsecret("Password: ")
  fn.inputrestore()
  if zstr(password) then
    return false, "Invalid password, sudo aborted"
  end
  local output = fn.system(string.format("sudo -p '' -S %s", cmd), password)
  if vim.v.shell_error ~= 0 then
    return false, output
  end
  return true, output
end

local function sudo_write(filepath, tmpfile)
  if zstr(filepath) then filepath = fn.expand("%") end
  if zstr(filepath) then
    return false, "No file name"
  end
  if zstr(tmpfile) then tmpfile = fn.tempname() end
  local cmd = string.format("dd if=%s of=%s bs=1048576",
    fn.shellescape(tmpfile),
    fn.shellescape(filepath))
  -- no need to check error as this fails the entire function
  vim.api.nvim_exec(string.format("write! %s", tmpfile), true)
  local succ, output = sudo_exec(cmd)
  if succ then
    vim.cmd("e!")
  end
  fn.delete(tmpfile)
  return succ, output
end

api.nvim_create_user_command(
  'Sudowrite',
  function(opts)
    local filepath = opts.args;
    if zstr(filepath) then
      filepath = fn.expand("%")
    end
    local succ, output = sudo_write(filepath);
    if succ then
      local msg = string.format('"%s" written', filepath)
      info(msg)
      vim.notify(msg, vim.log.levels.INFO, { title = "Sudowrite" })
    else
      local msg = string.format('%s', output or 'Sudowrite Failed!')
      err(msg)
      vim.notify(msg, vim.log.levels.ERROR, { title = "Sudowrite" })
    end
  end,
  { nargs = '?', desc = 'Write file with privileges' }
)

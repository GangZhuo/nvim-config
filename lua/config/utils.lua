local fn = vim.fn

local M = {}

function M.zstr(s)
  return s == nil or s == ""
end

function M._echo_multiline(msg)
  for _, s in ipairs(fn.split(msg, "\n")) do
    vim.cmd("echom '" .. s:gsub("'", "''") .. "'")
  end
end

function M.info(msg)
  vim.cmd("echohl Directory")
  M._echo_multiline(msg)
  vim.cmd("echohl None")
end

function M.warn(msg)
  vim.cmd("echohl WarningMsg")
  M._echo_multiline(msg)
  vim.cmd("echohl None")
end

function M.err(msg)
  vim.cmd("echohl ErrorMsg")
  M._echo_multiline(msg)
  vim.cmd("echohl None")
end

function M.exec_cmd(cmd)
  local handle = io.popen(cmd)
  if handle ~= nil then
    local result = handle:read("*a")
    handle:close()
    return result
  end
  return nil
end

---@param plugin string
function M.has(plugin)
  return require("lazy.core.config").spec.plugins[plugin] ~= nil
end

function M.fg(name)
  ---@type {foreground?:number}?
  local hl = vim.api.nvim_get_hl and vim.api.nvim_get_hl(0, { name = name })
      or vim.api.nvim_get_hl_by_name(name, true)
  local fg = hl and (hl.fg or hl.foreground)
  return fg and { fg = string.format("#%06x", fg) }
end

---@param on_attach fun(client, buffer)
function M.on_lsp_attach(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

--- Create a dir if it does not exist
function M.may_create_dir(dir)
  local res = fn.isdirectory(dir)
  if res == 0 then
    fn.mkdir(dir, "p")
  end
end

function M.firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function M.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

--- Join Directory
--- e.g.
---  local str = join_arr({a=1, b=2}, ",")
---  str: a:1,b:2
function M.join_dic(dic, sep)
  local str = ""
  sep = sep or ','
  for k,v in pairs(dic) do
      if str:len() == 0 then
        str = string.format("%s:%s", k, v)
      else
        str = str..string.format("%s%s:%s", sep, k, v)
      end
  end
  return str
end

--- Join array
--- e.g.
---  local str = join_arr({"a", "b","c","d"},",")
---  str: a,b,c,d
function M.join_arr(dic, sep)
  local str = ""
  sep = sep or ','
  for _,v in ipairs(dic) do
      if str:len() == 0 then
        str = v
      else
        str = str..string.format("%s%s", sep, v)
      end
  end
  return str
end

--- Remove element from array
function M.remove(arr, val)
  for i,v in ipairs(arr) do
    if v == val then
      table.remove(arr, i)
    end
  end
  return arr
end

-- Get nvim version
function M.version()
  local actual_ver = vim.version()
  local nvim_ver_str = string.format("%d.%d.%d", actual_ver.major, actual_ver.minor, actual_ver.patch)
  return nvim_ver_str
end

-- Check if nvim is the expected version
function M.expect_ver(expected_ver)
  local a = M.split(expected_ver, ".")
  local actual_ver = vim.version()
  local b = { actual_ver.major, actual_ver.minor, actual_ver.patch }
  for i,v in ipairs(a) do
    if tonumber(v) > b[i] then
      return false
    end
  end
  return true
end

function M.sudo_exec(cmd)
  fn.inputsave()
  local password = fn.inputsecret("Password: ")
  fn.inputrestore()
  if M.zstr(password) then
    return false, "Invalid password, sudo aborted"
  end
  local output = fn.system(string.format("sudo -p '' -S %s", cmd), password)
  if vim.v.shell_error ~= 0 then
    return false, output
  end
  return true, output
end

function M.sudo_write(filepath, tmpfile)
  if M.zstr(filepath) then filepath = fn.expand("%") end
  if M.zstr(filepath) then
    return false, "No file name"
  end
  if M.zstr(tmpfile) then tmpfile = fn.tempname() end
  -- `bs=1048576` is equivalent to `bs=1M` for GNU dd or `bs=1m` for BSD dd
  -- Both `bs=1M` and `bs=1m` are non-POSIX
  local cmd = string.format("dd if=%s of=%s bs=1048576",
    fn.shellescape(tmpfile),
    fn.shellescape(filepath))
  -- no need to check error as this fails the entire function
  vim.api.nvim_exec(string.format("write! %s", tmpfile), true)
  local succ, output = M.sudo_exec(cmd)
  if succ then
    vim.cmd("e!")
  end
  fn.delete(tmpfile)
  return succ, output
end

-- Get ctags status which shown in status line
function M.get_gutentags_status()
  if vim.g.loaded_gutentags ~= 1 or vim.g.gutentags_enabled ~= 1 then
    return
  end
  local icons = require("config.icons")
  local path = string.format("%s/tags", vim.loop.cwd())
  local f
  if vim.fn.filereadable(path) == 1 then
    f = io.popen(string.format("stat -c %%Y \"%s\"", path))
  end
  if f ~= nil then
    local last_modified = f:read()
    local today = os.date("%Y-%m-%d")
    local last_modified_date = os.date("%Y-%m-%d", last_modified)
    local last_modified_time = os.date("%H:%M:%S", last_modified)
    if today == last_modified_date then
    last_modified = last_modified_time
    else
    last_modified = string.format("%s %s",
        last_modified_date, last_modified_time)
    end
    f:close()
    local action = (not M.zstr(vim.fn["gutentags#statusline"]())) and " "..icons.refresh or ""
    return string.format("%s%s%s", icons.ctags, last_modified, action)
  else
    return (not M.zstr(vim.fn["gutentags#statusline"]())) and (icons.ctags..icons.refresh) or ""
  end
end

local terminals = {}

function M.float_term(cmd, opts)
  opts = vim.tbl_deep_extend("force", {
    ft = "lazyterm",
    size = { width = 0.9, height = 0.9 },
  }, opts or {}, { persistent = true })

  local termkey = vim.inspect({
    cmd = cmd or "shell",
    cwd = opts.cwd,
    env = opts.env,
    count = vim.v.count1,
  })

  if terminals[termkey] and terminals[termkey]:buf_valid() then
    terminals[termkey]:toggle()
  else
    terminals[termkey] = require("lazy.util").float_term(cmd, opts)
    local buf = terminals[termkey].buf
    vim.b[buf].lazyterm_cmd = cmd
    if opts.esc_esc == false then
      vim.keymap.set("t", "<esc>", "<esc>", { buffer = buf, nowait = true })
    end
    if opts.ctrl_hjkl == false then
      vim.keymap.set("t", "<c-h>", "<c-h>", { buffer = buf, nowait = true })
      vim.keymap.set("t", "<c-j>", "<c-j>", { buffer = buf, nowait = true })
      vim.keymap.set("t", "<c-k>", "<c-k>", { buffer = buf, nowait = true })
      vim.keymap.set("t", "<c-l>", "<c-l>", { buffer = buf, nowait = true })
    end

    vim.api.nvim_create_autocmd("BufEnter", {
      buffer = buf,
      callback = function()
        vim.cmd.startinsert()
      end,
    })
  end

  return terminals[termkey]
end

return M

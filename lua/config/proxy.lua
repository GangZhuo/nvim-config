-- Try auto-configuring a proxy if it is not in the environment
local env = vim.env
local proxy = nil
local no_proxy = nil

local function zstr(s)
  return s == nil or s == ""
end

local function get_proxy()
  if proxy then return proxy end
  local factory = function()
    local host = env.HPROXY_HOST
    local port = env.HPROXY_PORT
    if not (zstr(host) or zstr(port)) then
      return string.format("http://%s:%s", host, port)
    end
    return nil
  end
  proxy = factory() or ""
  return proxy
end

local function get_no_proxy()
  if no_proxy then return proxy end
  no_proxy = "localhost"..
    ",*.lan"..
    ",127.0.0.1/8"..
    ",10.0.0.0/8"..
    ",192.168.0.0/16"..
    ",169.254.0.0/16"..
    ",100.64.0.0/10"..
    ",fe80::/10"
  return no_proxy
end

local function set_proxy()
  for _,var in ipairs({
    "http_proxy",
    "https_proxy",
    "HTTP_PROXY",
    "HTTPS_PROXY",
  }) do
    if zstr(env[var]) then
      env[var] = get_proxy()
    end
  end
  for _,var in ipairs({
    "no_proxy",
    "NO_PROXY",
  }) do
    if zstr(env[var]) then
      env[var] = get_no_proxy()
    end
  end
end

local function unset_proxy()
  for _,var in ipairs({
    "http_proxy",
    "https_proxy",
    "no_proxy",
    "HTTP_PROXY",
    "HTTPS_PROXY",
    "NO_PROXY",
  }) do
    if env[var] then
      env[var] = nil
    end
  end
end

return {
    set_proxy = set_proxy,
    unset_proxy = unset_proxy,
}

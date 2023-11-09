-- Try auto-configuring a proxy if it is not in the environment
local env = vim.env
local proxy = nil

local function get_proxy()
  if proxy then return proxy end
  local factory = function()
    local host = env.HPROXY_HOST
    local port = env.HPROXY_PORT
    local zstr = function(s) return s == nil or s == "" end
    if not (zstr(host) or zstr(port)) then
      return string.format("http://%s:%s", host, port)
    end
    return nil
  end
  proxy = env.http_proxy or env.https_proxy or factory() or ""
  return proxy
end

local function set_proxy()
  for _,var in ipairs({
    "http_proxy",
    "https_proxy",
  }) do
    if not env[var] then
      env[var] = get_proxy()
    end
  end
  if not env.no_proxy then
    local no_proxy = "localhost,127.0.0.1"
    if env.IP4_GW then
     no_proxy = no_proxy .. "," .. env.IP4_GW
    end
    env.no_proxy = no_proxy
  end
end

local function unset_proxy()
  for _,var in ipairs({
    "http_proxy",
    "https_proxy",
  }) do
    if env[var] then
      env[var] = nil
    end
  end
  env.no_proxy = nil
end

return {
    set_proxy = set_proxy,
    unset_proxy = unset_proxy,
}

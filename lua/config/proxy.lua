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

for _,var in ipairs({
  "http_proxy",
  "https_proxy",
}) do
  if not env[var] then
    env[var] = get_proxy()
  end
end


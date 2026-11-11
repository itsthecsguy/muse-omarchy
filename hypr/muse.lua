-- Binds the user's key for Muse (muse.ai). The window itself needs no rules: it
-- tiles like any other. Installed to ~/.config/hypr/muse.lua by install.sh; the
-- key comes from ~/.config/muse-omarchy/config, written by `muse-omarchy set key`.

local function settings()
  local values = {}
  local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
  local file = io.open(config_home .. "/muse-omarchy/config", "r")
  if not file then
    return values
  end
  for line in file:lines() do
    local name, value = line:match("^(%w+)%s*=%s*(.-)%s*$")
    if name and value ~= "" then
      values[name] = value
    end
  end
  file:close()
  return values
end

-- There is no default key: each user picks one with `muse-omarchy set key`.
local key = settings().key
if key then
  o.bind(key, "Muse", "muse-omarchy toggle")
end

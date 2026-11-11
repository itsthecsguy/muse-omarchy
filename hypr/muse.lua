-- Muse (muse.ai) as a floating toggle window on its own special workspace.
-- Installed to ~/.config/hypr/muse.lua by install.sh; settings come from
-- ~/.config/muse-omarchy/config, written by `muse-omarchy set`.

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

local config = settings()
local width, height = (config.size or ""):match("^(%d+)x(%d+)$")

-- Not silent: a freshly launched Muse opens its workspace, so it shows at once.
o.window("^chrome-muse\\.ai__.*$", {
  workspace = "special:muse",
  float = true,
  center = true,
  size = { tonumber(width) or 1100, tonumber(height) or 800 },
})

-- There is no default key: each user picks one with `muse-omarchy set key`.
if config.key then
  o.bind(config.key, "Muse", "muse-omarchy toggle")
end

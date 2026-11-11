-- Muse (muse.ai) as a toggle window. The window needs no rules: it tiles like
-- any other. Loaded from the user's ~/.config/hypr/hyprland.lua by a line that
-- `muse-omarchy setup` adds; settings come from ~/.config/muse-omarchy/config,
-- written by `muse-omarchy set`.
--
-- The toggle runs here, inside Hyprland, so a key press starts no process
-- unless Muse has to be launched. `muse-omarchy toggle` calls the same function.

local URL = "https://muse.ai/"
-- Chromium names an --app window after the URL: chrome-<host>__<path>-<profile>.
local CLASS = "^chrome%-muse%.ai__"
-- Where the window waits while hidden. It is never shown there.
local HIDDEN = "special:muse"
-- A cold Chromium start can take this long to map its window. Presses inside
-- that time would otherwise each open another Muse.
local LAUNCH_GRACE = 15

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

local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function muse_window()
  for _, window in ipairs(hl.get_windows()) do
    if window.class and window.class:find(CLASS) then
      return window
    end
  end
end

local function target(window)
  return "address:" .. window.address
end

-- Survives nothing but a config reload, which is fine: it only guards a launch.
local launched_at = 0

local function launch()
  if os.time() - launched_at < LAUNCH_GRACE then
    return
  end
  launched_at = os.time()

  local command = "omarchy-launch-webapp " .. shell_quote(URL)
  -- Read at launch, so a profile change needs no reload.
  if settings().profile == "isolated" then
    local data_home = os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")
    command = command .. " " .. shell_quote("--user-data-dir=" .. data_home .. "/muse-omarchy/chromium-profile")
  end
  hl.exec_cmd(command)
end

local function show(window)
  local workspace = hl.get_active_workspace()
  -- Named workspaces report a negative id and are addressed by name.
  local destination = workspace.id > 0 and tostring(workspace.id) or ("name:" .. workspace.name)

  -- follow focuses it too. A separate focus dispatch in the same call is lost.
  hl.dispatch(hl.dsp.window.move({ workspace = destination, follow = true, window = target(window) }))
end

local function hide(window)
  hl.dispatch(hl.dsp.window.move({ workspace = HIDDEN, follow = false, window = target(window) }))
end

muse_omarchy = {}

-- Not running: launch. Hidden: bring to the current workspace. Focused: hide.
-- Open elsewhere: go to it.
function muse_omarchy.toggle()
  local window = muse_window()
  if not window then
    return launch()
  end
  launched_at = 0

  local active = hl.get_active_window()
  if window.workspace and window.workspace.name == HIDDEN then
    show(window)
  elseif active and active.address == window.address then
    hide(window)
  else
    hl.dispatch(hl.dsp.focus({ window = target(window) }))
  end
end

-- Bring a hidden Muse back into view, so removing this module strands nothing.
function muse_omarchy.reveal()
  local window = muse_window()
  if window and window.workspace and window.workspace.name == HIDDEN then
    show(window)
  end
end

-- Close Muse to free its memory. The next toggle starts it again.
function muse_omarchy.quit()
  local window = muse_window()
  if window then
    hl.dispatch(hl.dsp.window.close({ window = target(window) }))
  end
end

-- There is no default key: each user picks one with `muse-omarchy set key`.
local key = settings().key
if key then
  -- Lets the keybindings menu run a bind that Hyprland only reports as Lua.
  o.bind_commands[muse_omarchy.toggle] = "muse-omarchy toggle"
  o.bind(key, "Muse", muse_omarchy.toggle)
end

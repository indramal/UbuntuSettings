local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

-- Appearance
config.color_scheme = "Gruvbox Dark"
config.window_background_opacity = 0.92
config.front_end = "OpenGL"


-- Font
config.font = wezterm.font("JetBrains Mono", { weight = "Regular" })
config.font_size = 13.0
config.line_height = 1.2
config.cell_width = 1.0

-- Window
config.window_decorations = "RESIZE"
config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
config.initial_cols = 200
config.initial_rows = 50

-- Tab bar
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32

-- Format tab title to show process name + CWD basename
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local title = pane.title
  local cwd = pane.current_working_dir
  if cwd then
    local path = tostring(cwd)
    local base = path:match("([^/]+)/?$") or path
    title = " " .. base
  end
  if tab.is_active then
    return { { Foreground = { Color = "#58a6ff" } }, { Text = " " .. title .. " " } }
  end
  return { { Foreground = { Color = "#8b949e" } }, { Text = " " .. title .. " " } }
end)

-- Status bar: show git branch + time on right
wezterm.on("update-right-status", function(window, pane)
  local cells = {}

  -- CWD
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    local cwd = tostring(cwd_uri):gsub("file://[^/]*", "")
    local home = os.getenv("HOME")
    if home then cwd = cwd:gsub(home, "~") end
    table.insert(cells, { Foreground = { Color = "#1f6feb" } })
    table.insert(cells, { Text = "  " .. cwd })
  end

  -- Git branch (read from .git/HEAD in the current directory)
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    local cwd = tostring(cwd_uri):gsub("file://[^/]*", "")
    -- Walk up the directory tree to find .git/HEAD
    local dir = cwd
    local branch = nil
    for _ = 1, 10 do
      local head_file = dir .. "/.git/HEAD"
      local f = io.open(head_file, "r")
      if f then
        local content = f:read("*l")
        f:close()
        branch = content:match("ref: refs/heads/(.+)")
        break
      end
      local parent = dir:match("(.+)/[^/]+$")
      if not parent or parent == dir then break end
      dir = parent
    end
    if branch then
      table.insert(cells, { Foreground = { Color = "#44FFB1" } })
      table.insert(cells, { Text = "   " .. branch .. "  " })
    else
      table.insert(cells, { Text = "  " })
    end
  end

  window:set_right_status(wezterm.format(cells))
end)

-- Cursor
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- Scrollback
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- Keys
config.keys = {
  -- Tabs
  { key = "t", mods = "ALT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "ALT", action = act.CloseCurrentTab({ confirm = false }) },
  { key = "LeftArrow",  mods = "ALT", action = act.ActivateTabRelative(-1) },
  { key = "RightArrow", mods = "ALT", action = act.ActivateTabRelative(1) },

  -- Split panes
  { key = "d", mods = "ALT",       action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "ALT|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- Navigate panes
  { key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
  { key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
  { key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },

  -- Resize panes
  { key = "h", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "l", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
  { key = "k", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "j", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },

  -- Close pane / new window
  { key = "x", mods = "ALT", action = act.CloseCurrentPane({ confirm = false }) },
  { key = "n", mods = "ALT", action = act.SpawnWindow },
}
return config

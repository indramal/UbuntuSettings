local wezterm = require("wezterm")
local config  = wezterm.config_builder()
local act     = wezterm.action

-- Appearance
config.color_scheme            = "Gruvbox Dark"
config.window_background_opacity = 0.92
config.front_end               = "OpenGL"

-- Right click: copy if selected, paste otherwise
config.mouse_bindings = {
  {
    event  = { Down = { streak = 1, button = 'Right' } },
    mods   = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ''
      if has_selection then
        window:perform_action(act.CopyTo('ClipboardAndPrimarySelection'), pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act({ PasteFrom = 'Clipboard' }), pane)
      end
    end),
  },
}

-- Font
config.font      = wezterm.font("JetBrains Mono", { weight = "Regular" })
config.font_size = 13.0
config.line_height = 1.2
config.cell_width  = 1.0

-- Window
config.window_decorations = "RESIZE"
config.window_padding     = { left = 10, right = 10, top = 10, bottom = 10 }
config.initial_cols       = 200
config.initial_rows       = 50

-- Tab bar
config.use_fancy_tab_bar          = true
config.tab_bar_at_bottom          = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width              = 32

-- Tab title: CWD basename
wezterm.on("format-tab-title", function(tab)
  local pane  = tab.active_pane
  local title = pane.title
  local cwd   = pane.current_working_dir
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

-- Right status: CWD + git branch
wezterm.on("update-right-status", function(window, pane)
  local cells   = {}
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    local raw_cwd = tostring(cwd_uri):gsub("file://[^/]*", "")
    local home    = os.getenv("HOME")
    local display_cwd = raw_cwd
    if home then display_cwd = raw_cwd:gsub(home, "~") end

    table.insert(cells, { Foreground = { Color = "#1f6feb" } })
    table.insert(cells, { Text = "  " .. display_cwd })

    -- ✅ Walk raw_cwd (real path), NOT display_cwd (~ path)
    local dir    = raw_cwd
    local branch = nil
    for _ = 1, 10 do
      local f = io.open(dir .. "/.git/HEAD", "r")
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
config.default_cursor_style   = "BlinkingBar"
config.cursor_blink_rate      = 500
config.cursor_blink_ease_in   = "Constant"
config.cursor_blink_ease_out  = "Constant"

-- Scrollback
config.scrollback_lines  = 10000
config.enable_scroll_bar = false

-- ─────────────────────────────────────────────
-- Project definitions
-- ─────────────────────────────────────────────
local projects = {
  KADA = {
    workspace = "kada",
    panes = {
      { path = "/home/ihackerubuntu/ProjectFiles/Biz/KADA/kada_backend" },
      { path = "/home/ihackerubuntu/ProjectFiles/Biz/KADA/kada_biz_logic" },
      { path = "/home/ihackerubuntu/ProjectFiles/Biz/KADA/kada_frontend" },
      { path = "/home/ihackerubuntu/ProjectFiles/Biz/KADA/kada_doc" },
      { path = "/home/ihackerubuntu/ProjectFiles/Biz/KADA/kada_project_details" },
      { path = "/home/ihackerubuntu/ProjectFiles/Biz/KADA/kada_test" },
    },
  },
  EMS = {
    workspace = "ems",
    panes = {
      { path = "/home/ihackerubuntu/ProjectFiles/Biz/EMS/EMS-Service" },
      { path = "/home/ihackerubuntu/ProjectFiles/Biz/EMS/ems-package" },
      { path = "/home/ihackerubuntu/ProjectFiles/Biz/EMS/ems-client" },
      { path = "/home/ihackerubuntu/ProjectFiles/Biz/EMS/EMS-Details" },
    },
  },
}

-- ─────────────────────────────────────────────
-- Grid builder — clean explicit approach
--
-- KADA (6):  3 cols × 2 rows
--   Step 1 — create 3 equal columns from the root pane:
--     root  → split Right 0.667  → col_a(1/3) | rest(2/3)
--     rest  → split Right 0.5    → col_b(1/3) | col_c(1/3)
--   Step 2 — split each column pane downward at 0.5:
--     col_a → split Bottom 0.5   → pane[0,0] | pane[1,0]
--     col_b → split Bottom 0.5   → pane[0,1] | pane[1,1]
--     col_c → split Bottom 0.5   → pane[0,2] | pane[1,2]
--
-- EMS (4):   2 cols × 2 rows
--   Step 1 — root → split Right 0.5 → col_a | col_b
--   Step 2 — col_a → split Bottom 0.5
--             col_b → split Bottom 0.5
--
-- Key insight: each Right-split uses the fraction of the pane
-- being split, NOT the total window width.
--   2 cols: first split = 0.5  (half of full width)
--   3 cols: first split = 0.667 (we keep 1/3, give away 2/3)
--           second split on the 2/3 remainder = 0.5
-- ─────────────────────────────────────────────
local function cd_clear(p, path)
  p:send_text("cd " .. path .. " && clear\n")
end

local function build_pane_grid(root_pane, panes_cfg)
  local n = #panes_cfg

  -- Set up root pane
  cd_clear(root_pane, panes_cfg[1].path)
  if n == 1 then return end

  local cols = (n <= 4) and 2 or 3
  local rows = math.ceil(n / cols)

  -- ── Step 1: carve top-row column panes ───────────────────
  -- col_panes[c] = the top pane of column c  (1-indexed)
  local col_panes = { root_pane }

  if cols == 2 then
    -- root → split Right at 0.5 → left(1/2) + right(1/2)
    local right = root_pane:split({ direction = "Right", size = 0.5 })
    table.insert(col_panes, right)

  elseif cols == 3 then
	  local col_a = root_pane

	  -- col_a keeps 1/3, rest gets 2/3
	  local rest = root_pane:split({
	    direction = "Right",
	    size = 0.667,
	  })

	  -- split the 2/3 remainder exactly in half → each gets 1/3 of total
	  local col_c = rest:split({
	    direction = "Right",
	    size = 0.5,
	  })
	  local col_b = rest

	  col_panes = { col_a, col_b, col_c }
  end

  -- ── Step 2: split each column pane downward ──────────────
  -- all_panes[i] is the flat list in row-major order (left→right, top→bottom)
  -- We build a grid[row][col] table so we can assign paths correctly.
  local grid = {}
  for c = 1, cols do
    grid[1] = grid[1] or {}
    grid[1][c] = col_panes[c]
  end

  for r = 2, rows do
    grid[r] = {}
    for c = 1, cols do
      local above = grid[r - 1][c]
      -- Always split at 0.5: we only ever have 2 rows, so top and bottom
      -- each get exactly half of the column height.
      grid[r][c] = above:split({ direction = "Bottom", size = 0.5 })
    end
  end

  -- ── Step 3: assign cd && clear to each pane ──────────────
  local idx = 2   -- panes_cfg[1] already handled
  for r = 1, rows do
    for c = 1, cols do
      if not (r == 1 and c == 1) then
        local p = grid[r] and grid[r][c]
        if p and idx <= n then
          cd_clear(p, panes_cfg[idx].path)
          idx = idx + 1
        end
      end
    end
  end

  -- Return focus to top-left
  root_pane:activate()
end

-- ─────────────────────────────────────────────
-- Launch project (no-op if workspace already exists)
-- ─────────────────────────────────────────────
local function launch_project(win, pane, project)
  -- Don't open if a tab with this title already exists
  for _, t in ipairs(win:mux_window():tabs()) do
    if t:get_title() == project.workspace then
      t:activate()
      return
    end
  end
  -- Spawn a new tab in the current window
  local tab, first_pane, _ = win:mux_window():spawn_tab({
    cwd = project.panes[1].path,
  })
  tab:set_title(project.workspace)
  build_pane_grid(first_pane, project.panes)
  -- Activate the new tab
  tab:activate()
end

-- ─────────────────────────────────────────────
-- Fuzzy launcher
-- ─────────────────────────────────────────────
local function launcher_action()
  return wezterm.action_callback(function(win, pane)
    local choices = {}
    for name, _ in pairs(projects) do
      table.insert(choices, { label = "󰆍  Launch  " .. name, id = name })
    end
    win:perform_action(
      act.InputSelector {
        title             = "Project launcher",
        choices           = choices,
        fuzzy             = true,
        fuzzy_description = "Search projects: ",
        action = wezterm.action_callback(function(iwin, ipane, id, _label)
          if not id then return end
          if projects[id] then
            launch_project(iwin, ipane, projects[id])
          end
        end),
      },
      pane
    )
  end)
end

-- ─────────────────────────────────────────────
-- Keys
-- ─────────────────────────────────────────────
config.keys = {
  -- Tabs
  { key = "t", mods = "ALT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "ALT", action = act.CloseCurrentTab({ confirm = false }) },
  { key = "LeftArrow",  mods = "ALT", action = act.ActivateTabRelative(-1) },
  { key = "RightArrow", mods = "ALT", action = act.ActivateTabRelative(1) },

  -- Split panes
  { key = "d", mods = "ALT",       action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "ALT|SHIFT", action = act.SplitVertical({   domain = "CurrentPaneDomain" }) },

  -- Navigate panes
  { key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
  { key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
  { key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },

  -- Resize panes
  { key = "h", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left",  5 }) },
  { key = "l", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
  { key = "k", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up",    5 }) },
  { key = "j", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down",  5 }) },

  -- Close / new window
  { key = "x", mods = "ALT", action = act.CloseCurrentPane({ confirm = false }) },
  { key = "n", mods = "ALT", action = act.SpawnWindow },

  -- Project launcher
  { key = "p", mods = "ALT|SHIFT", action = launcher_action() },
  { key = "k", mods = "ALT|SHIFT",
    action = wezterm.action_callback(function(win, pane)
      launch_project(win, pane, projects.KADA)
    end),
  },
  { key = "e", mods = "ALT|SHIFT",
    action = wezterm.action_callback(function(win, pane)
      launch_project(win, pane, projects.EMS)
    end),
  },
  -- Clear all panes in current tab
	{ key = "c", mods = "ALT|SHIFT",
	  action = wezterm.action_callback(function(win, _pane)
	    local tab = win:active_tab()
	    for _, pane_info in ipairs(tab:panes()) do
	      pane_info:send_text("clear\n")
	    end
	  end),
	},
}

return config

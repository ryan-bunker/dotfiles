-- wezterm/main.lua
local wezterm = require("wezterm")
local act = wezterm.action

local LEFT_HALF_CIRCLE = wezterm.nerdfonts.ple_left_half_circle_thick
local RIGHT_HALF_CIRCLE = wezterm.nerdfonts.ple_right_half_circle_thick

local process_icons = {
	["docker"] = wezterm.nerdfonts.linux_docker,
	["docker-compose"] = wezterm.nerdfonts.linux_docker,
	["psql"] = wezterm.nerdfonts.dev_postgresql,
	["kuberlr"] = wezterm.nerdfonts.linux_docker,
	["kubectl"] = wezterm.nerdfonts.linux_docker,
	["stern"] = wezterm.nerdfonts.linux_docker,
	["nvim"] = wezterm.nerdfonts.custom_vim,
	["vim"] = wezterm.nerdfonts.dev_vim,
	["node"] = wezterm.nerdfonts.dev_nodejs_small,
	["zsh"] = wezterm.nerdfonts.dev_terminal,
	["bash"] = wezterm.nerdfonts.cod_terminal_bash,
	["htop"] = wezterm.nerdfonts.mdi_chart_donut_variant,
	["cargo"] = wezterm.nerdfonts.dev_rust,
	["go"] = wezterm.nerdfonts.mdi_language_go,
	["git"] = wezterm.nerdfonts.dev_git,
	["lazygit"] = wezterm.nerdfonts.dev_git,
	["lua"] = wezterm.nerdfonts.seti_lua,
	["wget"] = wezterm.nerdfonts.mdi_arrow_down_bold_box,
	["curl"] = wezterm.nerdfonts.mdi_flattr,
	["gh"] = wezterm.nerdfonts.dev_github_badge,
	["ruby"] = wezterm.nerdfonts.dev_ruby,
	["python"] = wezterm.nerdfonts.dev_python,
}

local function get_process_name(pane)
	local process_name = pane.foreground_process_name
	if not process_name or process_name == "" then
		return nil
	end

	-- Match the filename at the end of the path
	return process_name:match("([^/\\]+)$")
end

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

local function isViProcess(pane)
	-- get_foreground_process_name On Linux, macOS and Windows,
	-- the process can be queried to determine this path. Other operating systems
	-- (notably, FreeBSD and other unix systems) are not currently supported
	return pane:get_foreground_process_name():find("n?vim") ~= nil or pane:get_title():find("n?vim") ~= nil
end

local function conditionalActivatePane(window, pane, pane_direction, vim_direction)
	if isViProcess(pane) then
		window:perform_action(
			-- This should match the keybinds you set in Neovim.
			act.SendKey({ key = vim_direction, mods = "CTRL" }),
			pane
		)
	else
		window:perform_action(act.ActivatePaneDirection(pane_direction), pane)
	end
end

-- This function receives the table you built in Nix
return function(nix_options)
	local config = wezterm.config_builder()

	-- apply the catppuccin color theme
	if nix_options.catppuccin then
		local theme = dofile(nix_options.catppuccin.plugin)
		theme.apply_to_config(config, nix_options.catppuccin.config)
	end

	config.font = wezterm.font("JetBrains Mono", { weight = "Bold" })
	config.font_size = 12
	config.freetype_render_target = "HorizontalLcd"
	config.freetype_load_target = "HorizontalLcd"

	config.window_padding = {
		left = "12pt",
		right = "12pt",
		top = "8pt",
		bottom = "8pt",
	}
	config.window_decorations = "RESIZE"
	config.window_background_opacity = 0.9
	config.macos_window_background_blur = 12
	config.default_cursor_style = "BlinkingBar"
	config.cursor_blink_rate = 400
	config.use_fancy_tab_bar = false
	config.show_new_tab_button_in_tab_bar = false
	config.tab_bar_at_bottom = true
	config.tab_max_width = 64
	config.tab_and_split_indices_are_zero_based = false

	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		local tab_bar_colors = config.color_schemes[config.color_scheme].tab_bar
		local bar_bg = tab_bar_colors.background
		local tab_bg = tab_bar_colors.new_tab.bg_color
		local text_fg = tab_bar_colors.inactive_tab.fg_color
		local accent = tab_bar_colors.inactive_tab.fg_color
		local accent_text = tab_bar_colors.inactive_tab.bg_color
		local intensity = "Normal"

		if tab.is_active then
			tab_bg = tab_bar_colors.new_tab_hover.bg_color
			accent = tab_bar_colors.active_tab.bg_color
			accent_text = tab_bar_colors.active_tab.fg_color
			intensity = "Bold"
		end

		local title = tab_title(tab)
		local process = get_process_name(tab.active_pane)
		local icon = process_icons[process] or wezterm.nerdfonts.dev_terminal
		local display_title = string.format(" %s  %s ", icon, title)

		-- ensure that the titles fit in the available space,
		-- and that we have room for the edges.
		title = wezterm.truncate_right(title, max_width - 2)

		return {
			{ Background = { Color = bar_bg } },
			{ Foreground = { Color = accent } },
			{ Text = LEFT_HALF_CIRCLE },
			{ Background = { Color = accent } },
			{ Foreground = { Color = accent_text } },
			{ Text = tostring(tab.tab_index + 1) .. " " .. icon .. " " },
			{ Background = { Color = tab_bg } },
			{ Foreground = { Color = text_fg } },
			{ Attribute = { Intensity = intensity } },
			{ Text = " " .. title },
			{ Background = { Color = bar_bg } },
			{ Foreground = { Color = tab_bg } },
			{ Text = RIGHT_HALF_CIRCLE .. " " },
		}
	end)

	-- events for splits navigation
	wezterm.on("ActivatePaneDirection-right", function(window, pane)
		conditionalActivatePane(window, pane, "Right", "l")
	end)
	wezterm.on("ActivatePaneDirection-left", function(window, pane)
		conditionalActivatePane(window, pane, "Left", "h")
	end)
	wezterm.on("ActivatePaneDirection-up", function(window, pane)
		conditionalActivatePane(window, pane, "Up", "k")
	end)
	wezterm.on("ActivatePaneDirection-down", function(window, pane)
		conditionalActivatePane(window, pane, "Down", "j")
	end)

	config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

	config.keys = {
		-- Zoom (Toggle Maximize Pane)
		{
			key = "z",
			mods = "LEADER",
			action = act.TogglePaneZoomState,
		},

		-- Create New Tab (Tmux window)
		{
			key = "c",
			mods = "LEADER",
			action = act.SpawnTab("CurrentPaneDomain"),
		},

		-- Next/Prev Tab
		{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
		{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

		-- Go to Last Active Tab
		{ key = "l", mods = "LEADER", action = act.ActivateLastTab },

		-- Splits (Tmux style)
		-- Note: WezTerm "Vertical" split puts one pane ON TOP of the other.
		-- Kitty's "vsplit" puts them SIDE-BY-SIDE.
		-- I have mapped them to match standard Tmux/Kitty behavior here.
		{
			key = '"',
			mods = "LEADER|SHIFT",
			action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "%",
			mods = "LEADER|SHIFT",
			action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},

		-- Split navigation
		{ key = "h", mods = "CTRL", action = act.EmitEvent("ActivatePaneDirection-left") },
		{ key = "j", mods = "CTRL", action = act.EmitEvent("ActivatePaneDirection-down") },
		{ key = "k", mods = "CTRL", action = act.EmitEvent("ActivatePaneDirection-up") },
		{ key = "l", mods = "CTRL", action = act.EmitEvent("ActivatePaneDirection-right") },

		-- Switch workspaces
		{ key = "s", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
		-- Rename current workspace
		{
			key = "$",
			mods = "LEADER|SHIFT",
			action = act.PromptInputLine({
				description = "Enter new name for workspace",
				action = wezterm.action_callback(function(window, pane, line)
					-- 'line' is the input from the user.
					-- If they hit Escape, line will be nil.
					if line then
						wezterm.mux.rename_workspace(window:active_workspace(), line)
					end
				end),
			}),
		},
	}

	-- Tab Selection (0-9)
	for i = 1, 9 do
		table.insert(config.keys, {
			key = tostring(i),
			mods = "LEADER",
			-- wezterm tabs are 0-indexed so we need to decrement
			action = act.ActivateTab(i - 1),
		})
	end

	return config
end

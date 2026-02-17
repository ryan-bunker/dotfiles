-- Helper function to check environment variables safely
local function env(name)
	return os.getenv(name) or ""
end

-- Detect which terminal emulator we're running in
local function get_term_emulator()
	-- WezTerm always sets this
	if env("TERM_PROGRAM") == "WezTerm" then
		return "wezterm"
	end

	-- Kitty usually sets TERM to xterm-kitty, or sets KITTY_PID
	if env("TERM") == "xterm-kitty" or env("KITTY_PID") ~= "" or env("TERM_PROGRAM") == "kitty" then
		return "kitty"
	end

	-- Fallback
	return "generic"
end

local terminal = get_term_emulator()
local keys = { left = "<C-h>", down = "<C-j>", up = "<C-k>", right = "<C-l>" }
local maps = { left = "", right = "", up = "", down = "" }

-- Regardless of which terminal we're in, we want to make sure vim-kitty-navigator
-- doesn't add its own mappings
vim.g.kitty_navigator_no_mappings = 1

if terminal == "wezterm" then
	-- WEZTERM: Use Navigator plugin
	require("Navigator").setup()

	-- create keybindings (the Navigator plugin does not do this automatically)
	maps.left = "<CMD>NavigatorLeft<CR>"
	maps.right = "<CMD>NavigatorRight<CR>"
	maps.up = "<CMD>NavigatorUp<CR>"
	maps.down = "<CMD>NavigatorDown<CR>"
elseif terminal == "kitty" then
	-- KITTY: Use vim-kitty-navigator
	maps.left = "<CMD>KittyNavigateLeft<CR>"
	maps.right = "<CMD>KittyNavigateRight<CR>"
	maps.up = "<CMD>KittyNavigateUp<CR>"
	maps.down = "<CMD>KittyNavigateDown<CR>"
else
	-- GENERIC: Standard Vim splits
	maps.left = "<C-w>h"
	maps.right = "<C-w>l"
	maps.up = "<C-w>k"
	maps.down = "<C-w>j"
end

-- now apply the actual keybinds
for key, value in pairs(keys) do
	vim.keymap.set({ "n", "t" }, value, maps[key], { silent = true })
end

-- Finaly, create a command :CheckTerminalMode for debugging which mode this script chose
vim.api.nvim_create_user_command("CheckTerminalMode", function()
	print("Current Terminal Mode: " .. terminal)
end, {})

local M = {}

-- A list of modules to load in order
local modules = {
	"config.alpha",
	"config.auto-save",
	"config.auto-session",
	"config.catppuccin",
	"config.codecompanion",
	"config.comment",
	"config.completions",
	"config.conform",
	"config.gitsigns",
	"config.gopher",
	"config.indent-blankline",
	"config.leap",
	"config.lspconfig",
	"config.lualine",
	"config.mini",
	"config.neo-tree",
	"config.neotest",
	"config.notify",
	"config.nvim-autopairs",
	"config.nvim-surround",
	"config.pane-navigate",
	"config.rainbow-delimiters",
	"config.reactive",
	"config.telescope",
	"config.todo-comments",
	"config.treesitter",
	"config.which-key",
}

function M.setup()
	-- Iterate over the module list and safely load each one
	for _, module in ipairs(modules) do
		local ok, err = pcall(require, module)
		if not ok then
			-- Print an error if a file or module fails to load
			error("Failed to load module " .. module .. ": " .. tostring(err))
		end
	end
end

return M

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	config = function()
		require("neo-tree").setup({
			auto_clean_after_session_restore = true, -- Automatically clean up broken neo-tree buffers saved in sessions
			default_component_configs = {
				modified = { symbol = "" },
			},
		})

		vim.keymap.set("n", "<C-n>", ":Neotree filesystem toggle reveal float<CR>", { desc = "Open Neotree" })
	end,
}

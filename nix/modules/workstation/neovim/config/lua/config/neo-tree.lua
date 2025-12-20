require("neo-tree").setup({
	auto_clean_after_session_restore = true, -- Automatically clean up broken neo-tree buffers saved in sessions
	default_component_configs = {
		modified = { symbol = "" },
	},
})

vim.keymap.set("n", "<C-n>", ":Neotree filesystem toggle reveal float<CR>", { desc = "Open Neotree" })

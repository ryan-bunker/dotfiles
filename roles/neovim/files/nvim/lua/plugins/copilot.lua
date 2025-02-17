return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		{
			"zbirenbaum/copilot.lua",
			opts = {
				suggestion = { enabled = false },
				panel = { enabled = false },
			},
		},
		{ "nvim-lua/plenary.nvim" },
	},
	build = "make tiktoken",
	opts = {
		window = {
			width = 0.3,
		},
	},
}

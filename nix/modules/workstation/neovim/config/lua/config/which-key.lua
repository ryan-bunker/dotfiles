require("which-key").setup({
	win = { border = "rounded" },
	spec = {
		{ "<leader>c", group = "[C]ode" },
		{ "<leader>d", group = "[D]ocument" },
		{ "<leader>r", group = "[R]ename" },
		{ "<leader>f", group = "[F]ind" },
		{ "<leader>w", group = "[W]orkspace" },
	},
})

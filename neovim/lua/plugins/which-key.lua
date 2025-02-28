return {
	"folke/which-key.nvim",
	event = "VimEnter",
	config = function()
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
	end,
	-- init = function()
	-- 	vim.o.timeout = true
	-- 	vim.o.timeoutlen = 300
	-- end,
	-- opts = {
	-- 	window = {
	-- 		border = "rounded",
	-- 	},
	-- 	defaults = {
	-- 		["<leader>t"] = { name = "test+" },
	-- 	},
	-- },
}

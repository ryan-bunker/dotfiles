return {
	"echasnovski/mini.nvim",
	version = false,
	config = function()
		-- Better around/inside textobjects
		--
		-- Examples:
		--  - va)  - [V]isually select [A]round [)]paren
		--  - yinq - [Y]ank [I]nside [N]ext [']quote
		--  - ci'  - [C]hange [I]nside [']quote
		require("mini.ai").setup({ n_lines = 500 })

		-- Buffer removing (unshow, delete, wipeout), which saves window layout
		vim.keymap.set("n", "<leader>x", require("mini.bufremove").delete, { desc = "Close the current buffer" })

		-- Animate common Neovim actions
		require("mini.animate").setup({
			open = { enable = false },
			close = { enable = false },
		})
	end,
}

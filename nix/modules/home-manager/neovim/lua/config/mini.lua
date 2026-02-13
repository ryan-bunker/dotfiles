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
local animate = require("mini.animate")
animate.setup({
	resize = { enable = false },
	open = { enable = false },
	close = { enable = false },
	cursor = {
		timing = animate.gen_timing.quartic({ duration = 100, unit = "total", control = "out" }),
	},
	scroll = {
		timing = animate.gen_timing.quartic({ duration = 150, unit = "total", control = "out" }),
		subscroll = animate.gen_subscroll.equal({ max_step = 10 }),
	},
})

require("mini.icons").setup()

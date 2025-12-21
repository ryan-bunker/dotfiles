require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
})

require("codecompanion").setup()

vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion Chat" })

require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
})

local codecompanion_opts = {
	adapters = {
		acp = {},
	},
}

if _G.Nix and _G.Nix.enableGemini == "true" then
	codecompanion_opts.adapters.acp.gemini_cli = function()
		return require("codecompanion.adapters").extend("gemini_cli", {
			defaults = {
				auth_method = "oauth-personal",
			},
		})
	end
end

require("codecompanion").setup(codecompanion_opts)

vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion Chat" })

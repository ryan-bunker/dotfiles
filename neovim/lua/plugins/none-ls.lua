return {
-- 	"jay-babu/mason-null-ls.nvim",
-- 	event = { "BufReadPre", "BufNewFile" },
-- 	dependencies = {
-- 		"williambowman/mason.nvim",
-- 		"nvimtools/none-ls.nvim",
-- 	},
-- 	config = function()
-- 		require("mason-null-ls").setup({
-- 			ensure_installed = { "stylua", "gofumpt", "goimports-reviser", "prettierd" },
-- 			automatic_installation = false,
-- 			handlers = {},
-- 		})

-- 		local null_ls = require("null-ls")
-- 		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- 		null_ls.setup({
-- 			-- sources = {
-- 			-- 	-- Lua
-- 			-- 	null_ls.builtins.formatting.stylua,

-- 			-- 	-- Go
-- 			-- 	null_ls.builtins.formatting.gofumpt,
-- 			-- 	null_ls.builtins.formatting.goimports_reviser,

-- 			-- 	-- Multi
-- 			-- 	null_ls.builtins.formatting.prettierd,
-- 			-- },
-- 			on_attach = function(client, bufnr)
-- 				if client.supports_method("textDocument/formatting") then
-- 					vim.api.nvim_clear_autocmds({
-- 						group = augroup,
-- 						buffer = bufnr,
-- 					})
-- 					vim.api.nvim_create_autocmd("BufWritePre", {
-- 						group = augroup,
-- 						buffer = bufnr,
-- 						callback = function()
-- 							vim.lsp.buf.format({ bufnr = bufnr })
-- 						end,
-- 					})
-- 				end
-- 			end,
-- 		})

-- 		vim.keymap.set("n", "<leader>fm", vim.lsp.buf.format, { desc = "LSP format" })
-- 	end,
}

return {
	"stevearc/conform.nvim",
	config = function()
		local conform = require("conform")

		local prettier_format = { "prettierd", "prettier", stop_after_first = true }

		conform.setup({
			format_on_save = {
				lsp_fallback = true,
				timeout_ms = 500,
			},
			formatters_by_ft = {
				css = prettier_format,
				go = { "gofumpt", "goimports-reviser" },
				graphql = prettier_format,
				html = prettier_format,
				javascript = prettier_format,
				javascriptreact = prettier_format,
				json = prettier_format,
				lua = { "stylua" },
				markdown = prettier_format,
				nix = { "alejandra" },
				-- python = { "isort", "black" },
				-- sql = { "sql-formatter" },
				svelte = prettier_format,
				typescript = prettier_format,
				typescriptreact = prettier_format,
				yaml = prettier_format,
			},
		})

		vim.keymap.set("n", "<leader>fm", conform.format, { desc = "LSP [F]or[m]at" })
	end,
}

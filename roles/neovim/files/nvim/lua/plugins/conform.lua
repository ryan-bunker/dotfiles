return {
	"stevearc/conform.nvim",
	config = function()
		local conform = require("conform")

		conform.setup({
			format_on_save = {
				lsp_fallback = true,
				timeout_ms = 500,
			},
			formatters_by_ft = {
				css = { { "prettierd", "prettier" } },
				go = { "gofumpt", "goimports-reviser" },
				graphql = { { "prettierd", "prettier" } },
				html = { { "prettierd", "prettier" } },
				javascript = { { "prettierd", "prettier" } },
				javascriptreact = { { "prettierd", "prettier" } },
				json = { { "prettierd", "prettier" } },
				lua = { "stylua" },
				markdown = { { "prettierd", "prettier" } },
				-- python = { "isort", "black" },
				-- sql = { "sql-formatter" },
				svelte = { { "prettierd", "prettier" } },
				typescript = { { "prettierd", "prettier" } },
				typescriptreact = { { "prettierd", "prettier" } },
				yaml = { { "prettierd", "prettier" } },
			},
		})

		vim.keymap.set("n", "<leader>fm", conform.format, { desc = "LSP [F]or[m]at" })
	end,
}

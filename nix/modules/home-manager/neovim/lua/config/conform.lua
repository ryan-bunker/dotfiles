local conform = require("conform")

conform.setup({
	format_on_save = {
		lsp_fallback = true,
		timeout_ms = 500,
	},
	formatters_by_ft = {
		css = { "prettierd" },
		go = { "gofumpt", "goimports-reviser" },
		graphql = { "prettierd" },
		html = { "prettierd" },
		javascript = { "prettierd" },
		javascriptreact = { "prettierd" },
		json = { "prettierd" },
		lua = { "stylua" },
		markdown = { "prettierd" },
		nix = { "alejandra" },
		-- python = { "isort", "black" },
		-- sql = { "sql-formatter" },
		svelte = { "prettierd" },
		terraform = { "terraform_fmt" },
		tf = { "terraform_fmt" },
		["terraform-vars"] = { "terraform_fmt" },
		typescript = { "prettierd" },
		typescriptreact = { "prettierd" },
		yaml = { "prettierd" },
	},
})

vim.keymap.set("n", "<leader>fm", conform.format, { desc = "LSP [F]or[m]at" })

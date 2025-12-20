local servers = {
	-- ansiblels = {},  ansible-language-server is not available in nixpkgs
	buf_ls = {},
	gopls = {},
	helm_ls = {},
	lua_ls = {},
	omnisharp = {},
	powershell_es = {},
	yaml_ls = {
		settings = {
			yaml = {
				schemas = {
					["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
				},
			},
		},
	},
}

for name, opt in pairs(servers) do
	vim.lsp.config(name, opt)
	vim.lsp.enable(name)
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"AndreM222/copilot-lualine",
	},
	config = function()
		require("lualine").setup({
			options = {
				theme = "catppuccin",
			},
			sections = {
				lualine_c = {
					require("auto-session.lib").current_session_name,
					{
						"filename",
						symbols = {
							modified = "",
							readonly = "",
						},
					},
					{
						require("noice").api.statusline.mode.get,
						cond = require("noice").api.statusline.mode.has,
						color = { fg = "#ff9e64" },
					},
				},
				lualine_x = { "copilot", "encoding", "fileformat", "filetype" },
			},
		})
	end,
}

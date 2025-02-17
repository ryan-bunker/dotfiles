return {
	"rmagatti/auto-session",
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

		require("auto-session").setup({
			log_level = vim.log.levels.ERROR,
			auto_session_suppress_dirs = { "~/", "~/source", "~/Downloads", "/" },
			bypass_session_save_file_types = { "alpha" },
		})
		require("session-lens").setup()
		require("telescope").load_extension("session-lens")
	end,
}

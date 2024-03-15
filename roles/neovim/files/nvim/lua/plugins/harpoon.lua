return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup({})

		-- basic telescope configuration
		local conf = require("telescope.config").values
		local action_state = require("telescope.actions.state")
		local finders = require("telescope.finders")

		local function generate_new_finder()
			local file_paths = {}
			for _, item in ipairs(harpoon:list().items) do
				table.insert(file_paths, item.value)
			end
			return finders.new_table({
				results = file_paths,
			})
		end

		local function delete_harpoon_buffer(prompt_bufnr)
			local selection = action_state.get_selected_entry()
			harpoon:list():removeAt(selection.index)
			print("Removed " .. selection.value)

			local current_picker = action_state.get_current_picker(prompt_bufnr)
			current_picker:refresh(generate_new_finder(), { reset_prompt = true })
		end

		local function toggle_telescope()
			require("telescope.pickers")
				.new({}, {
					prompt_title = "Harpoon",
					finder = generate_new_finder(),
					previewer = conf.file_previewer({}),
					sorter = conf.generic_sorter({}),
					attach_mappings = function(_, map)
						map("i", "<c-x>", delete_harpoon_buffer)
						map("n", "<c-x>", delete_harpoon_buffer)
						return true
					end,
				})
				:find()
		end

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():append()
		end, { desc = "Add buffer to harpoon list" })
		vim.keymap.set("n", "<C-e>", toggle_telescope, { desc = "Open harpoon window" })

		vim.keymap.set("n", "<leader>1", function()
			harpoon:list():select(1)
		end, { desc = "Select first harpoon buffer" })
		vim.keymap.set("n", "<leader>2", function()
			harpoon:list():select(2)
		end, { desc = "Select second harpoon buffer" })
		vim.keymap.set("n", "<leader>3", function()
			harpoon:list():select(3)
		end, { desc = "Select third harpoon buffer" })
		vim.keymap.set("n", "<leader>4", function()
			harpoon:list():select(4)
		end, { desc = "Select fourth harpoon buffer" })
	end,
}

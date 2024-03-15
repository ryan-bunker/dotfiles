return {
  {
    "MaximilianLloyd/ascii.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },
  {
    "goolord/alpha-nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },

    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      --dashboard.section.header.val = {
      --  [[                                                                       ]],
      --  [[                                                                     ]],
      --  [[       ████ ██████           █████      ██                     ]],
      --  [[      ███████████             █████                             ]],
      --  [[      █████████ ███████████████████ ███   ███████████   ]],
      --  [[     █████████  ███    █████████████ █████ ██████████████   ]],
      --  [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
      --  [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
      --  [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
      --  [[                                                                       ]],
      --}
      dashboard.section.header.val = require("ascii").art.misc.hydra.hydra

      alpha.setup(dashboard.opts)
    end,
  },
}

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  opts = {
    spec = {
      { "<leader>c", group = "Code", mode = { "n", "v" } },
      { "<leader>e", group = "Explorer" },
      { "<leader>f", group = "Find" },
      { "<leader>h", group = "Git Hunk", mode = { "n", "v" } },
      { "<leader>m", group = "Format" },
      { "<leader>r", group = "Rename / Substitute" },
      { "<leader>s", group = "Split" },
      { "<leader>t", group = "Tabs" },
    },
  },
}

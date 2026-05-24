return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons, feel free to change it
    ---@module 'render-markdown'
    ---@type render_markdown.Config
    opts = {},
    config = function()
      require("render-markdown").setup({
        -- You can add your own config here
      })
      -- Recommended: set conceallevel=2 for markdown files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.opt_local.conceallevel = 2
        end,
      })
      -- Toggle markdown rendering
      vim.keymap.set("n", "<leader>mt", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle Markdown Rendering" })
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install --no-save --package-lock=false --no-audit --no-fund socket.io@4.8.3 socket.io-client@4.8.3 log4js@6.9.1",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
    config = function()
      -- Toggle browser preview
      vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle Markdown Browser Preview" })
    end,
  },
}

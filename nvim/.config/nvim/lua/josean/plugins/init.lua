return {
  "nvim-lua/plenary.nvim", -- lua functions that many plugins use
  {
    "christoomey/vim-tmux-navigator", -- tmux & split window navigation
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },
}

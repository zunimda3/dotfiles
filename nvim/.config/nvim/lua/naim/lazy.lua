-- 1. Ensure mapleader is set BEFORE lazy loads
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 2. Bootstrap lazy.nvim (automatically download it if missing)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- 3. Configure and launch lazy.nvim
require("lazy").setup({
  spec = {
    -- Import all plugin files from your lua/plugins/ directory
    { import = "naim.plugins" },
    { import = "naim.plugins.lsp" },
  },
  -- Automatically check for plugin updates
  checker = { enabled = true, notify = false },
  change_detection = {
      notify = false,
  },
  -- UI settings
  ui = {
    border = "rounded",
  },
  performance = {
    rtp = {
      -- Disable some built-in vim plugins you probably don't need
      disabled_plugins = {
        "gzip",
        "matchit",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

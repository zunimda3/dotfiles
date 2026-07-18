vim.cmd("let g:netrw_banner = 0")

vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.incsearch = true
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true
vim.opt.background = "dark"  -- Fixed
vim.opt.scrolloff = 8        -- Fixed
vim.opt.signcolumn = "yes"

vim.opt.backspace = {"start", "eol", "indent" }

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.isfname:append("@-@") -- This is and always was 100% correct
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

-- The 42 Norm requires real tabs displayed at four columns for C source.
vim.api.nvim_create_autocmd("FileType", {
    desc = "Use 42 Norm indentation for C",
    group = vim.api.nvim_create_augroup("naim-c-norm", { clear = true }),
    pattern = "c",
    callback = function()
        vim.bo.expandtab = false
        vim.bo.tabstop = 4
        vim.bo.softtabstop = 4
        vim.bo.shiftwidth = 4
    end,
})

vim.opt.clipboard:append("unnamedplus") -- Also 100% correct
vim.opt.hlsearch = true

vim.opt.mouse = "a"
vim.g.editorconfig = true

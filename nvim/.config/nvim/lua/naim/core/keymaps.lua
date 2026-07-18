vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opts = { noremap = true, silent = true }

vim.keymap.set('i', 'jk', '<Esc>', { desc = "Exit insert mode with jk" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "J", "mzJ`z")

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

-- paste without replacing clipboard content
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("v", "p", '"_dP', opts)

-- Change text without copying it to the clipboard
vim.keymap.set({"n", "v"}, "c", '"_c', opts)
vim.keymap.set("n", "C", '"_C', opts)

vim.keymap.set("n", "<C-c>", ":nohl<CR>", { desc = "clear search hl", silent = true })

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Replace word cursor is on globally" })
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "makes file executable" })

-- Highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- tab stuff
vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "new tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "close tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "next tab" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "previous tab" })
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "new tab (current buf)" })

vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "split vertical" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "split horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "split equal size" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "close current split" })

vim.keymap.set("n", "<leader>fp", function()
    local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home dir
    vim.fn.setreg("+", filePath)          -- Copy file path to clipboard reg
    print("File path copied")
end, { desc = "Copy file path to clipboard" })

return {
    "stevearc/oil.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    config = function()
        require("oil").setup({
            default_file_explorer = true, --start up nvim with oil instead of netrw
            columns = { },
            keymaps = {
                ["<C-h>"] = false,
                ["<C-c>"] = false, --prevents c-c from closing out oil
                ["<M-h>"] = "actions.select_split",
                ["q"] = "actions.close",
                ["l"] = "actions.select",
                ["h"] = "actions.parent",
            },
            delete_to_trash = true,
            view_options = {
                show_hidden = true,
            },
            skip_confirm_for_simple_edits = true,
        })

        --keymaps for oil
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", {desc = "Open parent dir"})
        vim.keymap.set("n", "<leader>-", function()
            require("oil").toggle_float()
        end, {desc = "Open parent dir"})

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "oil",
            callback = function()
                vim.opt_local.cursorline = true
            end,
        })

    end,
}

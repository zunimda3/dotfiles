return {
    --Mini nvim
    {"echasnovski/mini.nvim", version = false },
    
    -- File explorer (this works properly with oil unline nvim-tree)
    {
        'echasnovski/mini.files',
        config = function()
            local MiniFiles = require("mini.files")
            MiniFiles.setup({
                mappings = {
                    go_in = "<CR>",
                    go_in_plus = "l",
                    go_out = "-",
                    go_out_plus = "h",
                },
            })
            vim.keymap.set("n", "<leader>ee", "<cmd>lua MiniFiles.open()<CR>", { desc = "Toggle mini file explorer" })
            vim.keymap.set("n", "<leader>ef", function()
                MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
                MiniFiles.reveal_cwd()
            end, { desc = "Toggle into currently opened file" })
        end
    },
    {
        'echasnovski/mini.surround',
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            custom_surroundings = nil,
            highlight_duration = 300,
            mappings = {
                add = 'sa',
                delete = 'ds',
                find = 'sf',
                find_left = 'sF',
                highlight = 'sh',
                replace = 'sr',
                update_n_lines = 'sn',

                suffix_last = 'l',
                suffix_next = 'n',
            },

            n_lines = 20,

            respect_selection_type = false,

            search_method = 'cover',

            silent = false,
        }

    }
}

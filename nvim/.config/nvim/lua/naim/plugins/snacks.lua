local c_run_terminal

local function open_c_run_terminal(command, cwd, title)
    if c_run_terminal and c_run_terminal:buf_valid() then
        c_run_terminal:close()
    end

    c_run_terminal = require("snacks").terminal.open(command, {
        cwd = cwd,
        auto_close = false,
        win = {
            position = "float",
            width = 0.8,
            height = 0.7,
            border = "rounded",
            title = title,
            title_pos = "center",
            backdrop = 60,
        },
    })
end

return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            -- HACK: docs @ https://github.com/folke/snacks.nvim/blob/main/docs
            quickfile = {
                enabled = true,
                exclude = { "latex" },
            },
            -- HACK: read picker docs @ https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
            picker = {
                enabled = true,
                matchers = {
                    frecency = true,
                    cwd_bonus = true,
                },
                formatters = {
                    file = {
                        filename_first = false,
                        filename_only = false,
                        icon_width = 2,
                    },
                },
                layout = {
                    preset = "telescope",
                    cycle = false,
                },
                layouts = {
                    select = {
                        preview = false,
                        layout = {
                            backdrop = false,
                            width = 0.6,
                            min_width = 80,
                            height = 0.4,
                            min_height = 10,
                            box = "vertical",
                            border = "rounded",
                            title = "{title}",
                            title_pos = "center",
                            { win = "input", height = 1, border = "bottom" },
                            { win = "list", border = "none" },
                            { win = "preview", title = "{preview}", width = 0.6, height = 0.4, border = "top" },
                        },
                    },
                    telescope = {
                        reverse = true, -- set to false for search bar to be on top
                        layout = {
                            box = "horizontal",
                            backdrop = false,
                            width = 0.8,
                            height = 0.9,
                            border = "none",
                            {
                                box = "vertical",
                                { win = "list", title = " Result ", title_pos = "center", border = "rounded" },
                                { win = "input", height = 1, border = "rounded", title = "{title} {live} {flags}", title_pos = "center" },
                            },
                            {
                                win = "preview",
                                title = "{preview:Preview}",
                                width = 0.50,
                                border = "rounded",
                                title_pos = "center",
                            },
                        },
                    },
                    ivy = {
                        layout = {
                            box = "vertical",
                            backdrop = false,
                            width = 0,
                            height = 0.4,
                            position = "bottom",
                            border = "top",
                            title = " {title} {live} {flags} ",
                            title_pos = "left",
                            { win = "input", height = 1, border = "bottom" },
                            {
                                box = "horizontal",
                                { win = "list", border = "none" },
                                { win = "preview", title = "{preview}", width = 0.5, border = "left" },
                            },
                        },
                    },
                },
            },
            dashboard = {
                enabled = true,
                sections = {
                    { section = "header" },
                    { section = "keys", gap = 1, padding = 1 },
                    { section = "startup" },
                    {
                        section = "terminal",
                        cmd = "ascii-image-converter ~/Desktop/Others/profiles.JPG -C -c",
                        random = 10,
                        pane = 2,
                        indent = 4,
                        height = 30,
                    },
                },
            },
        },
        keys = { -- <-- Fixed: Added missing opening brace here
            { "<leader>lg", function() require("snacks").lazygit() end, desc = "Lazygit" },
            { "<leader>gl", function() require("snacks").lazygit.log() end, desc = "Lazygit Logs" },
            { "<leader>rN", function() require("snacks").rename.rename_file() end, desc = "Fast Rename" },
            { "<leader>dB", function() require("snacks").bufdelete() end, desc = "Delete buffer (current)" },
            {
                "<leader>cr",
                function()
                    if vim.bo.filetype ~= "c" then
                        vim.notify("Current file is not a C source file", vim.log.levels.WARN)
                        return
                    end

                    vim.cmd.write()

                    local source = vim.fn.expand("%:p")
                    local output = vim.fn.expand("%:p:r")
                    local command = string.format(
                        "cc -Wall -Wextra -Werror %s -o %s && %s",
                        vim.fn.shellescape(source),
                        vim.fn.shellescape(output),
                        vim.fn.shellescape(output)
                    )

                    open_c_run_terminal(command, vim.fn.expand("%:p:h"), " C Program ")
                end,
                desc = "Compile and run C file",
            },
            {
                "<leader>cm",
                function()
                    if vim.bo.filetype ~= "c" then
                        vim.notify("Current file is not a C source file", vim.log.levels.WARN)
                        return
                    end

                    vim.cmd.write()

                    local source_dir = vim.fn.expand("%:p:h")
                    local makefile = vim.fs.find({ "Makefile", "makefile", "GNUmakefile" }, {
                        path = source_dir,
                        upward = true,
                        type = "file",
                    })[1]
                    local cwd = source_dir
                    local command

                    if makefile then
                        cwd = vim.fs.dirname(makefile)
                        command = "make run"
                    else
                        local sources = {}
                        for name, kind in vim.fs.dir(source_dir) do
                            if kind == "file" and name:match("%.c$") then
                                sources[#sources + 1] = vim.fs.joinpath(source_dir, name)
                            end
                        end
                        table.sort(sources)

                        if #sources == 0 then
                            vim.notify("No C source files found in " .. source_dir, vim.log.levels.WARN)
                            return
                        end

                        local escaped_sources = vim.tbl_map(vim.fn.shellescape, sources)
                        local output = vim.fs.joinpath(source_dir, "program")
                        command = string.format(
                            "cc -Wall -Wextra -Werror %s -o %s && %s",
                            table.concat(escaped_sources, " "),
                            vim.fn.shellescape(output),
                            vim.fn.shellescape(output)
                        )
                    end

                    local title = makefile and " C Project: make run " or " C Project: all .c files "
                    open_c_run_terminal(command, cwd, title)
                end,
                desc = "Compile and run C project",
            },

            -- Snack picker
            { "<leader>pf", function() require("snacks").picker.files() end, desc = "Find Files (Snacks Picker)" },
            { "<leader>pc", function() require("snacks").picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
            { "<leader>ps", function() require("snacks").picker.grep() end, desc = "Grep word" },
            { "<leader>pws", function() require("snacks").picker.grep_word() end, desc = "Search Visual selection or Word", mode = { "n", "x" } },
            { "<leader>pk", function() require("snacks").picker.keymaps({ layout = "ivy" }) end, desc = "Search Keymaps (Snacks Picker)" },
            { "<leader>pm", function() require("snacks").picker.man() end, desc = "Search man pages" },

            {
                "<leader>m3",
                function()
                    vim.cmd.Man({ "3", vim.fn.expand("<cword>") })
                end,
                desc = "Library man page under cursor",
            },
            {
                "<leader>m2",
                function()
                    vim.cmd.Man({ "2", vim.fn.expand("<cword>") })
                end,
                desc = "System call man page under cursor",
            },

            { "<leader>gbr", function() require("snacks").picker.git_branches({ layout = "select" }) end, desc = "Pick and Switch Git Branches" },
            { "<leader>th", function() require("snacks").picker.colorschemes({ layout = "ivy" }) end, desc = "Pick Color Schemes" },
            { "<leader>vh", function() require("snacks").picker.help() end, desc = "Help Pages" },
        },
    },
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPre", "BufNewFile" },
        keys = {
            { "<leader>pt", function() require("snacks").picker.todo_comments() end, desc = "Todo" },
            { "<leader>pT", function() require("snacks").picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
        },
    },
}

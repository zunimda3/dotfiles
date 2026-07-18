local function global_git_value(key)
    local result = vim.system({ "git", "config", "--global", "--get", key }, { text = true }):wait()
    if result.code == 0 then
        local value = vim.trim(result.stdout or "")
        if value ~= "" then
            return value
        end
    end
end

local function environment_email()
    for _, name in ipairs({ "EMAIL", "MAIL" }) do
        local value = vim.env[name]
        if value and value:match("^[^%s@]+@[^%s@]+$") then
            return value
        end
    end
end

return {
    "Diogo-ss/42-header.nvim",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "Stdheader" },
    keys = {
        { "<F1>", "<cmd>Stdheader<CR>", desc = "Insert or update 42 header" },
    },
    opts = function()
        local user = vim.env.USER or global_git_value("user.name")
        local mail = environment_email() or global_git_value("user.email")

        -- The plugin gives these globals highest priority. Values are resolved at
        -- runtime so this dotfiles setup remains portable between machines.
        vim.g.user = user
        vim.g.mail = mail

        return {
            default_map = false,
            auto_update = false,
            user = user,
            mail = mail,
            git = {
                enabled = true,
                bin = "git",
                user_global = true,
                email_global = true,
            },
        }
    end,
    config = function(_, opts)
        require("42header").setup(opts)

        vim.api.nvim_create_autocmd("BufWritePre", {
            desc = "Insert or update the 42 header for C source",
            group = vim.api.nvim_create_augroup("naim-42-header", { clear = true }),
            pattern = { "*.c", "*.h" },
            callback = function()
                require("42header.utils.header").stdheader()
            end,
        })
    end,
}

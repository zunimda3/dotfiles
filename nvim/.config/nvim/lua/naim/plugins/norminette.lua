local function parse_norminette(output)
    local json_start = output:find("{", 1, true)
    if not json_start then
        return {}
    end

    local ok, result = pcall(vim.json.decode, output:sub(json_start))
    if not ok or type(result) ~= "table" then
        return {}
    end

    local diagnostics = {}
    for _, file in ipairs(result.files or {}) do
        for _, error in ipairs(file.errors or {}) do
            local highlights = error.highlights or { {} }
            for _, highlight in ipairs(highlights) do
                local line = math.max((highlight.lineno or 1) - 1, 0)
                local column = math.max((highlight.column or 1) - 1, 0)
                local length = type(highlight.length) == "number" and highlight.length or 1
                diagnostics[#diagnostics + 1] = {
                    lnum = line,
                    col = column,
                    end_lnum = line,
                    end_col = column + length,
                    severity = vim.diagnostic.severity.ERROR,
                    source = "norminette",
                    code = error.name,
                    message = error.text or error.name or "Norm error",
                }
            end
        end
    end
    return diagnostics
end

return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "Norminette" },
    config = function()
        local lint = require("lint")

        lint.linters.norminette = {
            cmd = "norminette",
            stdin = false,
            append_fname = true,
            ignore_exitcode = true,
            args = { "--format", "json", "--no-colors" },
            parser = parse_norminette,
        }
        lint.linters_by_ft.c = { "norminette" }

        vim.api.nvim_create_autocmd("BufWritePost", {
            desc = "Check C source with Norminette",
            group = vim.api.nvim_create_augroup("naim-norminette", { clear = true }),
            pattern = { "*.c", "*.h" },
            callback = function()
                lint.try_lint("norminette")
            end,
        })

        vim.api.nvim_create_user_command("Norminette", function()
            lint.try_lint("norminette")
        end, { desc = "Run Norminette on the current file" })
    end,
}

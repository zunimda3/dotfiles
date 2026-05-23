return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      python = { "pylint" },
      c = { "cpplint" },
      cpp = { "cpplint" },
    }

    local pylint = lint.linters.pylint
    local pylint_parser = pylint.parser
    pylint.parser = function(output, bufnr)
      local diagnostics = pylint_parser(output, bufnr)

      return vim.tbl_filter(function(diagnostic)
        return not (
          diagnostic.code == "W0511"
          and diagnostic.message
          and diagnostic.message:lower():find("todo", 1, true)
        )
      end, diagnostics)
    end

    local cpplint = lint.linters.cpplint
    cpplint.args = {
      "--filter=-legal/copyright,-whitespace/blank_line,-runtime/vla,-readability/naming",
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    local function file_in_cwd(file_name)
      return vim.fs.find(file_name, {
        upward = true,
        stop = vim.loop.cwd():match("(.+)/"),
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        type = "file",
      })[1]
    end

    local function remove_linter(linters, linter_name)
      for k, v in pairs(linters) do
        if v == linter_name then
          linters[k] = nil
          break
        end
      end
    end

    local function linter_in_linters(linters, linter_name)
      for k, v in pairs(linters) do
        if v == linter_name then
          return true
        end
      end
      return false
    end

    local function remove_linter_if_missing_config_file(linters, linter_name, config_file_name)
      if linter_in_linters(linters, linter_name) and not file_in_cwd(config_file_name) then
        remove_linter(linters, linter_name)
      end
    end

    local lint_timers = {}

    local function try_linting(bufnr)
      bufnr = bufnr or 0

      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      local linters = lint.linters_by_ft[vim.bo[bufnr].filetype]

      -- if linters then
      --   -- remove_linter_if_missing_config_file(linters, "eslint_d", ".eslintrc.cjs")
      --   remove_linter_if_missing_config_file(linters, "eslint_d", "eslint.config.js")
      -- end

      vim.api.nvim_buf_call(bufnr, function()
        lint.try_lint(linters)
      end)
    end

    local function debounce_linting(bufnr)
      bufnr = bufnr or 0

      if lint_timers[bufnr] then
        lint_timers[bufnr]:stop()
        lint_timers[bufnr]:close()
      end

      local timer = vim.loop.new_timer()
      lint_timers[bufnr] = timer

      timer:start(500, 0, function()
        timer:stop()
        timer:close()
        lint_timers[bufnr] = nil

        vim.schedule(function()
          try_linting(bufnr)
        end)
      end)
    end

    local function set_lint_diagnostics_enabled(enabled, bufnr)
      bufnr = bufnr or 0
      local linters = lint.linters_by_ft[vim.bo[bufnr].filetype]

      if not linters then
        return
      end

      for _, linter_name in ipairs(linters) do
        vim.diagnostic.enable(enabled, {
          bufnr = bufnr,
          ns_id = lint.get_namespace(linter_name),
        })
      end
    end

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
      group = lint_augroup,
      callback = function(args)
        try_linting(args.buf)
      end,
    })

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
      group = lint_augroup,
      callback = function(args)
        debounce_linting(args.buf)
      end,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
      group = lint_augroup,
      callback = function(args)
        set_lint_diagnostics_enabled(false, args.buf)
      end,
    })

    vim.api.nvim_create_autocmd("InsertLeave", {
      group = lint_augroup,
      callback = function(args)
        set_lint_diagnostics_enabled(true, args.buf)
        try_linting(args.buf)
      end,
    })

    vim.keymap.set("n", "<leader>l", function()
      try_linting(0)
    end, { desc = "Trigger linting for current file" })
  end,
}

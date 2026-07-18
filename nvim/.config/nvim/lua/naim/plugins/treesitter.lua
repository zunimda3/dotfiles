return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main", -- Modern, rewritten branch
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")

    -- 1. Initialize and set parser installation path
    ts.setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    -- 2. Pre-install your favorite parsers (runs asynchronously)
    ts.install({
      "lua",
      "vim",
      "vimdoc",
      "query",
      "markdown",
      "markdown_inline",
      "python",
      "javascript",
      "typescript",
      "tsx",
      "json",
      "yaml",
      "bash",
      "c",
    })

    -- 3. Highlighting and Indentation (Leverage Native Neovim APIs)
    -- We use an autocommand to auto-enable Tree-sitter on file load
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TS_Highlights", { clear = true }),
      desc = "Enable Treesitter highlights and indentation natively",
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        
        -- 1. Explicitly ignore oil and other non-code/special buffers
        local ignore_ft = {
          oil = true,
          TelescopePrompt = true,
          minifiles = true,
          qf = true,         -- Quickfix list
          netrw = true,
          lazy = true,
          mason = true,
          nofile = true,
          harpoon = true,
        }
        
        if ignore_ft[ft] or vim.bo[args.buf].buftype == "nofile" then
          return
        end

        local lang = vim.treesitter.language.get_lang(ft) or ft

        -- 2. Check if a parser is actually installed on runtimepath before starting
        -- We use inspect_language to safely probe if the grammar is loaded/loadable
        local has_parser = pcall(vim.treesitter.inspect_language, lang)
        
        if has_parser then
          -- Safe to start highlighting!
          pcall(vim.treesitter.start, args.buf, lang)
          
          -- Enable Treesitter experimental indentation safely
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    -- 4. Enable Native Treesitter Folds (Optional but awesome)
    vim.api.nvim_create_autocmd({ "BufReadPost", "FileReadPost" }, {
      group = vim.api.nvim_create_augroup("TS_Folds", { clear = true }),
      callback = function()
        vim.opt.foldmethod = "expr"
        vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.opt.foldlevel = 99 -- Start with files fully unfolded
      end,
    })
  end,
}

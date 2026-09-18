return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters = {
				["c_formatter_42"] = {
					command = "python3",
					args = {
						vim.fn.stdpath("config") .. "/scripts/c_formatter_42_native.py",
					},
					stdin = true,
				},
				["markdown-toc"] = {
					condition = function(_, ctx)
						for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
							if line:find("<!%-%- toc %-%->") then
								return true
							end
						end
					end,
				},
				["markdownlint-cli2"] = {
					condition = function(_, ctx)
						local diag = vim.tbl_filter(function(d)
							return d.source == "markdownlint"
						end, vim.diagnostic.get(ctx.buf))
						return #diag > 0
					end,
				},
			},
			formatters_by_ft = {
				javascript = { "biome-check" },
				typescript = { "biome-check" },
				javascriptreact = { "biome-check" },
				typescriptreact = { "biome-check" },
				css = { "biome-check" },
				html = { "prettier" },
				astro = { "prettier" },
				json = { "biome-check" },
				yaml = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				lua = { "stylua" },
				markdown = { "mdformat", "markdownlint-cli2", "markdown-toc" },
				c = { "c_formatter_42" },
				cpp = { "clang-format" },
				-- python = { "black" },
			},
			-- format_on_save = {
			--     lsp_fallback = true,
			--     async = false,
			--     timeout_ms = 1000,
			-- },
		})

		-- Configure individual formatters
		conform.formatters.prettier = {
			args = function(self, ctx)
				local args = {
					"--stdin-filepath",
					ctx.filename,
					"--tab-width",
					"4",
					"--use-tabs",
					"false",
				}
				-- Prettier 3 does not auto-load plugins; .astro needs the plugin from
				-- the project's node_modules. Node resolves the bare name against the
				-- process cwd, so the cwd below must be the dir holding node_modules.
				if vim.bo[ctx.buf].filetype == "astro" then
					table.insert(args, "--plugin")
					table.insert(args, "prettier-plugin-astro")
				end
				return args
			end,
			-- Conform defaults cwd to Neovim's cwd, which breaks the bare plugin
			-- name whenever Neovim was not started inside the project.
			cwd = function(self, ctx)
				local node_modules = vim.fs.find("node_modules", {
					path = ctx.dirname,
					upward = true,
					limit = 1,
				})[1]
				return node_modules and vim.fs.dirname(node_modules) or nil
			end,
		}

		conform.formatters.shfmt = {
			prepend_args = { "-i", "4" },
		}

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			-- c_formatter_42 only supports whole files. Leave Visual mode so
			-- Conform does not pass it an incomplete C selection.
			if vim.bo.filetype == "c" and vim.fn.mode():match("[vV\22]") then
				vim.cmd("normal! <Esc>")
			end
			conform.format({
				lsp_format = "fallback",
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format whole file or range in visual mode" })
	end,
}

return {
    "rmagatti/auto-session",
    lazy = false,

    opts = {
        auto_restore = false,
        suppressed_dirs = {
            "~/",
            "~/Downloads",
            "~/Documents",
            "~/Desktop",
        },
    },

    keys = {
        { "<leader>wr", "<cmd>AutoSession restore<CR>", desc = "Restore session" },
        { "<leader>ws", "<cmd>AutoSession save<CR>", desc = "Save session" },
    },
}

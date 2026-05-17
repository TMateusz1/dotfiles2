return {
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>cl",
                function()
                    require("conform").format({
                        async = true,
                        lsp_fallback = true,
                    })
                end,
                mode = { "n", "v" },
                desc = "Format file",
            },
        },
        opts = {
            formatters_by_ft = {
                go = {
                    "goimports",
                    "gofumpt",
                },

                lua = {
                    "stylua",
                },
            },

            format_on_save = function(bufnr)
                local filetype = vim.bo[bufnr].filetype

                local disabled_filetypes = {
                    -- example:
                    -- markdown = true,
                }

                if disabled_filetypes[filetype] then
                    return nil
                end

                return {
                    timeout_ms = 3000,
                    lsp_fallback = true,
                }
            end,

            notify_on_error = true,
            notify_no_formatters = false,
        },
    },
}

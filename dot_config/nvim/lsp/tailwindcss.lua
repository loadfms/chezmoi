local path = require("utils.path")

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

return {
    cmd = { "tailwindcss-language-server", "--stdio" },
    filetypes = { "html", "css", "scss", "less", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte" },
    root_dir = path.find_root({
        "tailwind.config.js",
        "tailwind.config.ts",
        "postcss.config.js",
        "package.json",
        ".git"
    }),
    capabilities = capabilities,
}

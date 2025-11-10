return {
    cmd = { "clojure-lsp" },
    filetypes = { "clojure", "clojurescript", "edn" },
    name = "clojure-lsp",
    root_dir = function(bufnr, on_dir)
        -- Usa vim.fs.root() (builtin desde o Neovim 0.11)
        local root = vim.fs.root(bufnr, { "deps.edn", "project.clj", ".git" })
        if root then
            on_dir(root)
        else
            -- fallback pro diretório atual (permite LSP mesmo sem projeto)
            on_dir(vim.fn.getcwd())
        end
    end,
    settings = {
        ["clojure-lsp"] = {
            lint = { clj_kondo = true },
            format = { enabled = true },
        },
    },
}

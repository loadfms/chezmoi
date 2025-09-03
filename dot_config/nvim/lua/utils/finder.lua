if vim.fn.executable("fd") == 1 and vim.fn.executable("fzf") == 1 then
    vim.cmd([[
    function! FuzzyFindFunc(cmdarg, cmdcomplete)
      return v:lua.FuzzyFindFunc(a:cmdarg, a:cmdcomplete)
    endfunction
  ]])
    vim.o.findfunc = "FuzzyFindFunc"
end

function _G.FuzzyFindFunc(cmdarg, _)
    return vim.fn.systemlist("fd --hidden . | fzf --filter='" .. cmdarg .. "'")
end

-- Função Lua: busca no conteúdo dos arquivos
function _G.FuzzyGrepFunc(pattern)
    -- ripgrep: procura padrão e retorna "arquivo:linha:conteúdo"
    local cmd = "rg --vimgrep " .. vim.fn.shellescape(pattern)
    return vim.fn.systemlist(cmd)
end

-- Quickfix com resultados do ripgrep
function _G.RgSetQuickfix(pattern)
    local results = _G.FuzzyGrepFunc(pattern)

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_err_writeln("rg error: " .. (results[1] or "unknown"))
        return
    end

    local qflist = {}
    for _, line in ipairs(results) do
        -- rg --vimgrep retorna: "arquivo:linha:coluna:conteúdo"
        local filename, lnum, col, text = line:match("([^:]+):(%d+):(%d+):(.*)")
        table.insert(qflist, {
            filename = filename,
            lnum = tonumber(lnum),
            col = tonumber(col),
            text = text,
        })
    end

    vim.fn.setqflist(qflist)
    vim.cmd("copen")
end

-- Comando :Rg para buscar no conteúdo
vim.api.nvim_create_user_command("Rg", function(opts)
    _G.RgSetQuickfix(table.concat(opts.fargs, " "))
end, {
    nargs = "+",
})

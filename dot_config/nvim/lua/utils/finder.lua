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

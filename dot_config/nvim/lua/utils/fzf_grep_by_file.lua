local M = {}

function M.select_extension_live_grep()
    local fzf = require("fzf-lua")

    -- roda rg para listar arquivos do projeto
    local handle = io.popen("rg --files --hidden")
    if not handle then return end

    local result = handle:read("*a")
    handle:close()

    local exts_set = {}
    for file in result:gmatch("[^\r\n]+") do
        -- ignora arquivos dentro de .git, node_modules, dist, build
        if not file:match("^%.git/") and not file:match("^node_modules/")
            and not file:match("^dist/") and not file:match("^build/") then
            -- pega só arquivos que tenham ponto no nome
            local ext = file:match("%.([^.]+)$")
            if ext and #ext > 0 then
                exts_set[ext] = true
            end
        end
    end

    -- converte set em lista
    local exts = {}
    for ext, _ in pairs(exts_set) do
        table.insert(exts, ext)
    end
    table.sort(exts)

    if vim.tbl_isempty(exts) then
        vim.notify("Nenhuma extensão encontrada no projeto", vim.log.levels.WARN)
        return
    end

    fzf.fzf_exec(exts, {
        prompt = "Extension>",
        actions = {
            ["default"] = function(selected)
                local ext = selected[1]
                if not ext or ext == "" then return end
                local glob = string.format("*.%s", ext)
                fzf.live_grep({
                    cmd = string.format(
                        'rg --hidden --column --line-number --no-heading --color=always --smart-case --glob "%s"',
                        glob
                    ),
                    prompt = string.format("Rg (%s)> ", glob),
                })
            end,
        },
    })
end

return M

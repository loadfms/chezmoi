local setKeymap = vim.keymap.set
local keymap = vim.api.nvim_set_keymap
local ns = { noremap = true, silent = true }
local fzf_grep = require("utils.fzf_grep_by_file")

-- General
keymap('n', '<Leader>w', ':w<CR>', ns)
keymap('n', '<Leader>qa', ':qa<CR>', ns)
keymap('n', '<Leader>ep', ':e ~/.local/share/chezmoi/dot_config/nvim/lua/plugins/init.lua<CR>', ns)
keymap('n', '<Leader>bd', ':bd<CR>', ns)
keymap("n", "<A-TAB>", "<C-^>", ns)
keymap('n', 'Y', 'y$', ns)
keymap('n', 'Q', '<Nop>', ns)
keymap('n', '<Leader><CR>', ':noh<CR>', ns)

-- Buffer Navigation
keymap('', ']b', ':bnext<CR>', ns)
keymap('', '[b', ':bprevious<CR>', ns)
keymap('', ']q', ':cnext<CR>', ns)
keymap('', '[q', ':cprevious<CR>', ns)

-- Oil
keymap('n', '-', ':Oil<CR>', ns)

-- Resize
keymap('n', '<C-S-Left>', ':vertical resize +1<CR>', ns)
keymap('n', '<C-S-Right>', ':vertical resize -1<CR>', ns)

-- LSP
keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', ns)
keymap('n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', ns)
keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', ns)
keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', ns)
keymap('n', '<Leader>xx', '<cmd>lua vim.diagnostic.setqflist()<CR>', ns)
keymap("n", "<leader>ca", '<cmd>lua vim.lsp.buf.code_action()<CR>', ns)
keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', ns)
keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', ns)

-- Comment
keymap("n", "<leader>cc", "gcc", { desc = "Toggle comment" })
keymap("v", "<leader>cc", "gc", { desc = "Toggle comment" })

-- FZF
keymap('n', '<C-p>', "<cmd>FzfLua files<CR>", ns)
keymap('n', '<Leader>k', "<cmd>FzfLua live_grep<CR>", ns)
keymap('n', '<Leader>K', '<cmd>FzfLua grep_cword<CR>', ns)
keymap('n', '<leader>B', '<cmd>FzfLua buffers<CR>', ns)
keymap('n', '<leader>M', '<cmd>FzfLua marks<CR>', ns)
setKeymap("n", "<leader>f", fzf_grep.select_extension_live_grep, { desc = "Live grep com seletor dinâmico de extensão" })

-- FUGITIVE
-- keymap('n', '<Leader>gs', ':G<CR>5j', ns)         -- Vim fugitive summary
-- keymap('n', '<Leader>dq', '<C-W>k <C-W>o', ns)    -- Close compare buffs
-- keymap('n', '<Leader>da', ':diffget //2<CR>', ns) -- Get content from left side
-- keymap('n', '<Leader>dl', ':diffget //3<CR>', ns) -- Get content from right side
-- keymap('n', '<Leader>diff', ':Gvdiffsplit!<CR>', ns)
-- keymap('n', '<Leader>gl', ':0GcLog<CR>', ns)

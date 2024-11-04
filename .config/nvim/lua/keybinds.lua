-- ╔═══════════════════════╗
-- ║    Local Variables    ║
-- ╚═══════════════════════╝
local keymap = vim.keymap.set

local split_sensibly = function()
    if vim.api.nvim_win_get_width(0) > math.floor(vim.api.nvim_win_get_height(0) * 2.3) then
        vim.cmd("vs")
    else
        vim.cmd("split")
    end
end

--  ─( Colorscheme Picker )─────────────────────────────────────────────
local set_colorscheme = function(name) pcall(vim.cmd, 'colorscheme ' .. name) end
local pick_colorscheme = function()
    local init_scheme = vim.g.colors_name
    local new_scheme = require('mini.pick').start({
        source = {
            items = vim.fn.getcompletion("", "color"),
            preview = function(_, item)
                set_colorscheme(item)
            end,
            choose = set_colorscheme
        },
        mappings = {
            preview = {
                char = '<C-p>',
                func = function()
                    local item = require('mini.pick').get_picker_matches()
                    pcall(vim.cmd, 'colorscheme ' .. item.current)
                end
            }
        }
    })
    if new_scheme == nil then set_colorscheme(init_scheme) end
end

-- ╔═══════════════════════╗
-- ║    General Keymaps    ║
-- ╚═══════════════════════╝
keymap("n", "<leader>q", "<cmd>wqa<cr>", { desc = 'Quit' })
keymap("n", "ö", ":")
keymap("i", "<C-S-v>", "<C-r><C-o>*", { desc = 'Paste from System in Insertmode' })
keymap("n", "<leader>mu", function() require('mini.deps').update() end, { desc = 'Update Plugins' })

-- ╔════════════════════╗
-- ║    Find Keymaps    ║
-- ╚════════════════════╝
keymap("n", "<leader>fs", function() require('mini.pick').builtin.files() end,
    { desc = 'Find File' })
keymap("n", "<leader>fa", function() require('mini.pick').builtin.resume() end,
    { desc = 'Resume File find' })
keymap("n", "<leader>e", function()
        local buffer_name = vim.api.nvim_buf_get_name(0)
        if buffer_name == "" or string.match(buffer_name, "Starter") then
            require('mini.files').open(vim.loop.cwd())
        else
            require('mini.files').open(vim.api.nvim_buf_get_name(0))
        end
    end,
    { desc = 'Find Manualy' })
keymap("n", "<leader><space>", function() require('mini.pick').builtin.buffers() end,
    { desc = 'Find Buffer' })
keymap("n", "<leader>fg", function() require('mini.pick').builtin.grep_live() end,
    { desc = 'Find String' })
keymap("n", "<leader>fG", function()
        local wrd = vim.fn.expand("<cword>")
        require('mini.pick').builtin.grep({ pattern = wrd })
    end,
    { desc = 'Find String Cursor' })
keymap("n", "<leader>fh", function() require('mini.pick').builtin.help() end,
    { desc = 'Find Help' })
keymap("n", "<leader>fl", function() require('mini.extra').pickers.hl_groups() end,
    { desc = 'Find HL Groups' })
keymap("n", "<leader>fc", pick_colorscheme, { desc = 'Change Colorscheme' })
keymap('n', ',', function() require('mini.extra').pickers.buf_lines({ scope = 'current' }) end,
    { nowait = true, desc = 'Search Lines' })

-- ╔═══════════════════════╗
-- ║    Session Keymaps    ║
-- ╚═══════════════════════╝
keymap("n", "<leader>ss", function()
    vim.cmd('wa')
    require('mini.sessions').write()
    require('mini.sessions').select()
end, { desc = 'Switch Session' })
keymap("n", "<leader>sw", function()
    local cwd = vim.fn.getcwd()
    local last_folder = cwd:match("([^/]+)$")
    require('mini.sessions').write(last_folder)
end, { desc = 'Save Session' })
keymap("n", "<leader>sf", function()
        vim.cmd('wa')
        require('mini.sessions').select()
    end,
    { desc = 'Load Session' })

-- ╔═══════════════════════╗
-- ║    Editing Keymaps    ║
-- ╚═══════════════════════╝
-- Insert a Password at point
keymap("n", "<leader>ip",
    function()
        local command = 'pwgen -N 1 -B 32'
        for _, line in ipairs(vim.fn.systemlist(command)) do
            vim.api.nvim_put({ line }, '', true, true)
        end
    end,
    { desc = 'Insert Password' })

keymap("n", "YY", "<cmd>%y<cr>", { desc = 'Yank Buffer' })
keymap("n", "<Esc>", "<cmd>noh<cr>", { desc = 'Clear Search' })

-- ╔══════════════════════╗
-- ║    Buffer Keymaps    ║
-- ╚══════════════════════╝
keymap("n", "<leader>bd", "<cmd>bd<cr>", { desc = 'Close Buffer' })
keymap("n", "<leader>bq", "<cmd>%bd|e#<cr>", { desc = 'Close other Buffers' })
keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = 'Next Buffer' })
keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = 'Previous Buffer' })
keymap("n", "<TAB>", "<C-^>", { desc = "Alternate buffers" })
-- Format Buffer
-- With and without LSP
if vim.tbl_isempty(vim.lsp.buf_get_clients()) then
    keymap("n", "<leader>bf", function() vim.lsp.buf.format() end,
        { desc = 'Format Buffer' })
else
    keymap("n", "<leader>bf", "gg=G<C-o>", { desc = 'Format Buffer' })
end

-- ╔═══════════════════╗
-- ║    Git Keymaps    ║
-- ╚═══════════════════╝
keymap("n", "<leader>gb", function() require('mini.extra').pickers.git_commits({ path = vim.fn.expand('%:p') }) end,
    { desc = 'Git Log this File' })
keymap("n", "<leader>gl", function()
    split_sensibly()
    vim.cmd('terminal lazygit')
end, { desc = 'Lazygit' })
keymap("n", "<leader>gp", "<cmd>:Git pull<cr>", { desc = 'Git Push' })
keymap("n", "<leader>gs", "<cmd>:Git push<cr>", { desc = 'Git Pull' })
keymap("n", "<leader>ga", "<cmd>:Git add .<cr>", { desc = 'Git Add All' })
keymap("n", "<leader>gc", '<cmd>:Git commit -m "Autocommit from MVIM"<cr>',
    { desc = 'Git Autocommit' })
keymap("", "<leader>gh", function() require('mini.git').show_range_history() end,
    { desc = 'Git Range History' })
keymap("n", "<leader>gx", function() require('mini.git').show_at_cursor() end,
    { desc = 'Git Context Cursor' })

-- ╔═══════════════════╗
-- ║    LSP Keymaps    ║
-- ╚═══════════════════╝
keymap("n", "<leader>ld", function() vim.lsp.buf.definition() end,
    { desc = 'Go To Definition' })
keymap("n", "<leader>ls", "<cmd>Pick lsp scope='document_symbol'<cr>",
    { desc = 'Show all Symbols' })
keymap("n", "<leader>lr", function() vim.lsp.buf.rename() end, { desc = 'Rename This' })
keymap("n", "<leader>la", function() vim.lsp.buf.code_action() end,
    { desc = 'Code Actions' })
keymap("n", "<leader>le", function() require('mini.extra').pickers.diagnostic({ scope = "current" }) end,
    { desc = "LSP Errors in Buffer" })
keymap("n", "<leader>lf", function()
    vim.diagnostic.setqflist({ open = true })
end, { desc = "LSP Quickfix" })
keymap("n", "<leader>qj", "<cmd>cnext<CR>zz")
keymap("n", "<leader>qk", "<cmd>cprev<CR>zz")

-- ╔══════════════════╗
-- ║    UI Keymaps    ║
-- ╚══════════════════╝
-- Window Navigation
keymap("n", "<M-l>", "<cmd>wincmd l<cr>", { desc = 'Focus Left' })
keymap("n", "<M-k>", "<cmd>wincmd k<cr>", { desc = 'Focus Up' })
keymap("n", "<M-j>", "<cmd>wincmd j<cr>", { desc = 'Focus Down' })
keymap("n", "<M-h>", "<cmd>wincmd h<cr>", { desc = 'Focus Right' })

keymap("n", "<leader>ur", "<cmd>colorscheme randomhue<cr>", { desc = 'Random Colorscheme' })

keymap("n", "<leader>wq", "<cmd>wincmd q<cr>", { desc = 'Close Window' })
keymap("n", "<leader>n", "<cmd>noh<cr>", { desc = 'Clear Search Highlight' })

--  ─( Split "Sensibly" )───────────────────────────────────────────────
-- Should automatically split or vsplit based on Ratios
keymap("n", "<leader>bs", split_sensibly, { desc = "Alternate buffers" })

--  ─( Change Colorscheme )─────────────────────────────────────────────
keymap("n", "<leader>ud", "<cmd>set background=dark<cr>", { desc = 'Dark Background' })
keymap("n", "<leader>ub", "<cmd>set background=light<cr>", { desc = 'Light Background' })
keymap("n", "<leader>um", "<cmd>lua MiniMap.open()<cr>", { desc = 'Mini Map' })

--  ─( Neotree )────────────────────────────────────────────────────────
keymap("n", "<leader>tt", "<cmd>Neotree toggle<cr>", { desc = 'Neotree' })

--  ─( Trying a "Center Code" Keymap )──────────────────────────────────
keymap("n", "<leader>uc", function()
    local margin = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(margin, false, {
        split = 'left',
        win = 0,
        style = 'minimal',
        width = 40
    })
end, { desc = 'Center Buffer' })

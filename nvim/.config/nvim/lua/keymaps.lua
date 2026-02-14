-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
local vim = vim
local api = vim.api
local M = {}
-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<S-Up>", ":resize -5<CR>", { desc = "Increase height" })
vim.keymap.set("n", "<S-Down>", ":resize +5<CR>", { desc = "Decrease height" })
vim.keymap.set("n", "<S-Left>", ":vertical resize +5<CR>", { desc = "Decrease width" })
vim.keymap.set("n", "<S-Right>", ":vertical resize -5<CR>", { desc = "Increase width" })
-- set keys for tab navigation
--
vim.keymap.set("n", "<Tab>", "<Cmd>BufferPrevious<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferNext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>x", "<Cmd>BufferClose<CR>", { noremap = true, silent = true, desc = "close Buffer" })

-- set keys for terminal toggle
-- Normal mode mapping
vim.keymap.set(
	"n",
	"<C-t>",
	'<Cmd>exe v:count1 . "ToggleTerm"<CR>',
	{ silent = true, desc = "Open Term in normal mode" }
)
-- Insert mode mapping
vim.keymap.set(
	"i",
	"<C-t>",
	'<Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>',
	{ silent = true, desc = "Open Term in insert mode" }
)
-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("TermEnter", {
	pattern = "term://*toggleterm#*",
	callback = function()
		vim.api.nvim_buf_set_keymap(
			0,
			"t",
			"<C-t>",
			[[<Cmd>exe v:count1 . "ToggleTerm"<CR>]],
			{ noremap = true, silent = true }
		)
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function()
		local params = vim.lsp.util.make_range_params()
		params.context = { only = { "source.organizeImports" } }
		-- buf_request_sync defaults to a 1000ms timeout. Depending on your
		-- machine and codebase, you may want longer. Add an additional
		-- argument after params if you find that you have to write the file
		-- twice for changes to be saved.
		-- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
		for cid, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do
				if r.edit then
					local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
					vim.lsp.util.apply_workspace_edit(r.edit, enc)
				end
			end
		end
		vim.lsp.buf.format({ async = false })
	end,
})

local function close_floating()
	local inactive_floating_wins = vim.fn.filter(vim.api.nvim_list_wins(), function(k, v)
		local file_type = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(v), "filetype")

		return vim.api.nvim_win_get_config(v).relative ~= ""
			and v ~= vim.api.nvim_get_current_win()
			and file_type ~= "hydra_hint"
	end)
	for _, w in ipairs(inactive_floating_wins) do
		pcall(vim.api.nvim_win_close, w, false)
	end
end

vim.keymap.set("n", "<C-m>", close_floating, { noremap = true, silent = true })

vim.api.nvim_create_autocmd("BufWinEnter", {
	callback = function()
		vim.defer_fn(function()
			-- Only open folds if folding is enabled
			if vim.wo.foldenable then
				vim.cmd("normal! zR")
			end
		end, 20) -- wait ~20ms to allow folds to settle
	end,
})

-- vim: ts=2 sts=2 sw=2 et

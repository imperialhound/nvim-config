vim.g.mapleader = ','

-- Copy/paste
vim.keymap.set({'n', 'x'}, 'yy', '"+y')
vim.keymap.set({'n', 'x'}, 'pp', '"+p')

-- Select all text in buffer
vim.keymap.set('n', '<leader>a', ':keepjumps normal! ggGV<cr>')


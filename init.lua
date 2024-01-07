-- Initial setup guide I used (https://vonheikemen.github.io/devlog/tools/build-your-first-lua-config-for-neovim/)

require('user.settings')

-- KEYBINDINGS
vim.g.mapleader = ','

-- Copy/paste
vim.keymap.set({'n', 'x'}, 'yy', '"+y')
vim.keymap.set({'n', 'x'}, 'pp', '"+p')

-- Select all text in buffer
vim.keymap.set('n', '<leader>a', ':keepjumps normal! ggGV<cr>')

-- PLUGIN MANAGER

-- Install and setup lazy.nvim plugin manager
local lazy = {}
function lazy.install(path)
  if not vim.loop.fs_stat(path) then
    print('Installing lazy.nvim....')
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      path,
    })
  end
end

function lazy.setup(plugins)
	if vim.g.plugins_ready then
		return
	end
	
	lazy.install(lazy.path)

	vim.opt.rtp:prepend(lazy.path)

	require('lazy').setup(plugins, lazy.opts)
	vim.g.plugins_ready = true
end 

lazy.path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
lazy.opts = {}

-- Install plugins
lazy.setup({
	{{'folke/tokyonight.nvim'}}
})

vim.cmd.colorscheme('tokyonight')



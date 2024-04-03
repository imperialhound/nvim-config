-- Initial setup guide I used (https://vonheikemen.github.io/devlog/tools/build-your-first-lua-config-for-neovim/)

require('user.bindings')
require('user.plugins')
require('user.settings')

-- Temporary hack until setup in plugins 
require("nvim-tree").setup()

vim.cmd('colorscheme kanagawa')

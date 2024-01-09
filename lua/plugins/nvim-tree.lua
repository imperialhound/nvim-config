local Plugin = {'nvim-tree/nvim-tree.lua'}

function Plugin.config()
  vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<cr>')
end

return Plugin

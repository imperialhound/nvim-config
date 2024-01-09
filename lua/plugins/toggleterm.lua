-- Handle terminal windows
local Plugin = {'akinsho/toggleterm.nvim'}
local open_mapping = '<M-i>'

Plugin.cmd = {'Term', 'ToggleTerm', 'TermExec'}

function Plugin.init()
  vim.keymap.set({'n', 'i', 'x'}, open_mapping, '<cmd>Term<cr>', {desc = 'Toggle terminal'})
  vim.keymap.set('t', open_mapping, '<cmd>ToggleTerm<cr>')

  vim.keymap.set('n', '<leader>tt', '<cmd>ToggleTerm direction=tab<cr>')
  vim.keymap.set('n', '<leader>tf', '<cmd>ToggleTerm direction=float<cr>')
  vim.keymap.set('t', '<leader>tt', '<cmd>ToggleTerm<cr><cmd>ToggleTerm direction=tab<cr>')
  vim.keymap.set('t', '<leader>tf', '<cmd>ToggleTerm<cr><cmd>ToggleTerm direction=float<cr>')

  vim.keymap.set('t', '<leader>tw', '<C-\\><C-n><C-w>w')
  vim.keymap.set('t', '<leader>th', '<C-\\><C-n><C-w>h')
  vim.keymap.set('t', '<leader>tk', '<C-\\><C-n><C-w>k')
  vim.keymap.set('t', '<leader>tj', '<C-\\><C-n><C-w>j')
  vim.keymap.set('t', '<leader>tl', '<C-\\><C-n><C-w>l')
end

function Plugin.config()
  require('toggleterm').setup({
    on_open = function()
      vim.w.status_style = 'short'
    end
  })

  local function toggle()
    local env = require('user.env')
    local term = require('toggleterm') 

    if vim.o.lines < env.small_screen_lines then
      local size = vim.o.columns * 0.4
      term.toggle(vim.v.count, size, nil, 'vertical')
      return
    end

    local size = vim.o.lines * 0.3
    term.toggle(vim.v.count, size, nil, 'horizontal')
  end

  vim.api.nvim_create_user_command('Term', toggle, {})
end

return Plugin

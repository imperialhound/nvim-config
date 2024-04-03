local Plugin = {'nvim-lualine/lualine.nvim'}

Plugin.opts = {
    theme = 'onedark',
    icons_enabled = true,
    component_separators = '|',
    section_separators = '',
    disabled_filetypes = {
      statusline = {'NvimTree'}
    }
}

return Plugin

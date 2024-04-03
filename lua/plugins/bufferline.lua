-- Modifies the tabline to show it can show the currently opened files
local Plugin = {'akinsho/bufferline.nvim'}

Plugin.opts = {
    mode = 'buffers',
    offsets = {
      {filetype = 'NvimTree'}
    },
}
function Plugin.config()
  highlights = {
    buffer_selected = {
      italic = false
    },
    indicator_selected = {
      fg = {attribute = 'fg', highlight = 'Function'},
      italic = false
    }
  }

end


return Plugin

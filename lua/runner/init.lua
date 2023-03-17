local handlers = require('runner.handlers')
local list_ui = require('nvim-list-ui')

local M = {}

M._handlers = handlers

M.set_handler = function(filetype, handler)
  M._handlers[filetype] = handler
end

M.list_commands = function()
  local command_items = {
    { label = 'docker container ls', value = 'docker container ls' },
    { label = 'docker container ls -a', value = 'docker container ls -a' },
    { label = 'docker images', value = 'docker images' },
  }

  local list_opts = {
    prompt = 'Selecione um comando do Docker: ',
    height = 10,
    width = 50,
    list = command_items,
    border = true,
    numbering = true,
  }

  list_ui.run(list_opts, function(selected)
    -- Aqui você pode adicionar a lógica para lidar com o comando selecionado
    print('Você selecionou o comando: ' .. selected)
    M.run_command(selected)
  end)
end

M.run_command = function(command)
  local handler = function(buffer)
    vim.fn.termopen(command)
  end
  handler(0)
end

M.run = function(bufnr)
  local buffer
  if bufnr == nil or bufnr == 0 then
    buffer = vim.api.nvim_get_current_buf()
  else
    buffer = bufnr
  end
  local filetype = vim.filetype.match({ buf = buffer })

  local handler = M._handlers[filetype]

  if not handler then
    print(string.format('No handler defined for filetype \'%s\'', filetype))
    return
  end

  handler(buffer)
end

return M

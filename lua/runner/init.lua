local handlers = require('runner.handlers')
local utils = require('runner.handlers.utils')
local config = require('runner.config')
local helpers = require('runner.handlers.helpers')

local M = {}

M._handlers = handlers

M.setup = function(options)
  config.setup(options)
end

M.set_handler = function(filetype, handler)
  M._handlers[filetype] = handler
end

M.run = function(bufnr)
  local buffer
  if bufnr == nil or bufnr == 0 then
    buffer = vim.api.nvim_get_current_buf()
  else
    buffer = bufnr
  end

  if buffer == utils._terminal_buffer then
    helpers.shell_handler(utils._last_command, false)()
    return
  end

  local filetype = vim.filetype.match { buf = buffer }

  local handler = M._handlers[filetype]

  if not handler then
    print(string.format("No handler defined for filetype '%s'", filetype))
    return
  end

  handler(buffer)
end

return M

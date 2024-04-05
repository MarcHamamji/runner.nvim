local handlers = require('runner.handlers')
local utils = require('runner.handlers.utils')
local config = require('runner.config')
local helpers = require('runner.handlers.helpers')

local M = {}

M._handlers = handlers

M.setup = function(options)
  config.setup(options)

  if type(options.handlers) == 'table' then
    for filetype, handler in pairs(options.handlers) do
      M.set_handler(filetype, handler)
    end
  end

  vim.api.nvim_create_user_command('Runner', function()
    require('runner').run()
  end, { desc = 'Run code inside the editor' })

  vim.api.nvim_create_user_command('AutoRunner', function()
    require('runner').autorun()
  end, { desc = 'Execute `Runner` on a file save' })

  vim.api.nvim_create_user_command('AutoRunnerStop', function()
    require('runner').autorun_stop()
  end, { desc = 'Stop `AutoRunner`' })
end

--- **Overrides** the handler for the specified filetype
---
--- Usage:
--- ```lua
--- local helpers = require('runner.handlers.helpers')
--- require('runner').set_handler(
---   'lua',
---   helpers.command_handler('luafile %'),
--- )
--- ```
---
--- @param filetype string The filetype on which to run the given handler
--- @param handler function The handler to run when the current file matches the filetype
M.set_handler = function(filetype, handler)
  M._handlers[filetype] = handler
end

--- @param bufnr integer?
M.run = function(bufnr)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  if bufnr == utils._terminal_buffer then
    helpers.shell_handler(utils._last_command, false)()
    return
  end

  local filetype = vim.filetype.match { buf = bufnr }

  local handler = M._handlers[filetype]

  if not handler then
    print('No handler defined for filetype ' .. filetype)
    return
  end

  utils._last_handler = handler
  handler(bufnr)
end

--- @param bufnr integer?
M.autorun = function(bufnr)
  M.run(bufnr)
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = vim.api.nvim_create_augroup('AutoRunner', { clear = true }),
    pattern = '*',
    callback = function()
      if utils._terminal_window then
        helpers.shell_handler(utils._last_command, false)()
      else
        utils._last_handler(bufnr)
      end
    end,
  })
end

M.autorun_stop = function()
  vim.api.nvim_del_augroup_by_name('AutoRunner')
  vim.api.nvim_win_close(utils._terminal_window, true)
end

return M

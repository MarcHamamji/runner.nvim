local handlers = require('runner.handlers')
local utils = require('runner.handlers.utils')
local config = require('runner.config')
local helpers = require('runner.handlers.helpers')

local M = {}

M._handlers = handlers

M.setup = function(options)
  config.setup(options)
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

--- @param bufnr integer|nil
M.run = function(bufnr)
	if bufnr == nil or bufnr == 0 then
		bufnr = vim.api.nvim_get_current_buf()
	end

	if bufnr == utils._terminal_buffer then
		helpers.shell_handler(utils._last_command, false)()
		return
	end

	local filetype = vim.filetype.match({ buf = bufnr })

  local handler = M._handlers[filetype]

	if not handler then
		print("No handler defined for filetype " .. filetype)
		return
	end

	handler(bufnr)
end

return M

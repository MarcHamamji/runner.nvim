local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local sorters = require('telescope.sorters')
local themes = require('telescope.themes')

local config = require('runner.config')
local utils = require('runner.handlers.utils')

local M = {}

--- Runs a command in a shell by opening it in a new split window, with a terminal buffer.
---
--- Usage:
--- ```lua
--- local helpers = require('runner.handlers.helpers')
--- require('runner').set_handler(
---   'rust',
---   helpers.shell_handler('cargo run', true),
--- )
--- ```
---
--- @param command string The shell command to run when the handler called
--- @param editable boolean  Whether the user should be prompted to edit the command using `vim.input()` before running it. Useful when giving command line arguments to a script
M.shell_handler = function(command, editable)
  if editable == nil then
    editable = false
  end
  return function(_)
    if editable then
      command = vim.fn.input {
        prompt = 'Command: ',
        default = command,
      }
    end

    local output_buffer = utils.create_buffer()

    local output_window = utils.create_window()
    vim.api.nvim_win_set_buf(output_window, output_buffer)

    utils._last_command = command

    vim.fn.termopen(command, {
      cwd = vim.fn.getcwd(),
    })
  end
end

--- Runs a vim command
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
--- @param command string The vim command to run when the handler called
M.command_handler = function(command)
  return function()
    vim.cmd(command)
  end
end

--- Opens a `Telescope` finder to allow the user to choose which handler to run
---
--- Usage:
--- ```lua
--- local helpers = require('runner.handlers.helpers')
--- require('runner').set_handler(
---   'lua',
---   helpers.choice({
---     ['Run current file'] = helpers.command_handler('luafile %'),
---     ['Foo'] = helpers.shell_handler('foo'),
---     ['Bar'] = function(buffer)
---       -- Custom handler here...
---     end,
---   }),
--- )
--- ```
---
--- @param handlers table<string, function> The vim command to run when the handler called
M.choice = function(handlers)
  local handlers_count = vim.tbl_count(handlers)
  if handlers_count == 0 then
    print('No handler available right now')
    return function() end
  elseif handlers_count == 1 then
    return vim.tbl_values(handlers)[1]
  end

  return function(buffer)
    local picker = pickers.new(
      {},
      themes.get_dropdown {
        prompt_title = 'Runner',
        finder = finders.new_table {
          results = vim.tbl_keys(handlers),
        },
        sorter = sorters.get_generic_fuzzy_sorter(),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local handler_name = action_state.get_selected_entry()[1]
            handlers[handler_name](buffer)
          end)
          actions.select_horizontal:replace(function()
            local default_position = config.options.position
            config.options.position = 'bottom'

            actions.close(prompt_bufnr)
            local handler_name = action_state.get_selected_entry()[1]
            handlers[handler_name](buffer)

            config.options.position = default_position
          end)
          actions.select_vertical:replace(function()
            local default_position = config.options.position
            config.options.position = 'right'

            actions.close(prompt_bufnr)
            local handler_name = action_state.get_selected_entry()[1]
            handlers[handler_name](buffer)

            config.options.position = default_position
          end)
          return true
        end,
      }
    )
    picker:find()
  end
end

return M

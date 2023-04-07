local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local sorters = require('telescope.sorters')
local themes = require('telescope.themes')

local config = require('runner.config')
local utils = require('runner.handlers.utils')

local M = {}

M.shell_handler = function(command, editable)
  if editable == nil then
    editable = false
  end
  return function(_)
    if editable then
      command = vim.fn.input('Command: ', command)
    end

    local output_buffer = utils.create_buffer()

    local output_window = utils.create_window()
    vim.api.nvim_win_set_buf(output_window, output_buffer)

    vim.fn.termopen(command, {
      cwd = vim.fn.getcwd(),
    })
  end
end

M.command_handler = function(command)
  return function()
    vim.cmd(command)
  end
end

-- handlers = { 'Run Tests' = test_handler, 'Run Code' = code_handler }
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
            config.options.position = 'bottom';

            actions.close(prompt_bufnr)
            local handler_name = action_state.get_selected_entry()[1]
            handlers[handler_name](buffer)

            config.options.position = default_position;
          end)
          actions.select_vertical:replace(function()
            local default_position = config.options.position
            config.options.position = 'top';

            actions.close(prompt_bufnr)
            local handler_name = action_state.get_selected_entry()[1]
            handlers[handler_name](buffer)

            config.options.position = default_position;
          end)
          return true
        end,
      }
    )
    picker:find()
  end
end

return M

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local sorters = require('telescope.sorters')

local utils = require('runner.handlers.utils')

local M = {}

M._job_id = nil

M.shell_handler = function(command, editable)
  if editable == nil then
    editable = false
  end
  return function(code_buffer)
    if editable then
      command = vim.fn.input('Command: ', command)
    end

    local current_buffer_name = vim.api.nvim_buf_get_name(code_buffer)

    local output_buffer = utils.create_buffer('OUTPUT - ' .. current_buffer_name)
    vim.api.nvim_create_autocmd('BufHidden', {
      buffer = output_buffer,
      callback = function()
        vim.schedule(function()
          vim.api.nvim_buf_delete(output_buffer, {})
          vim.fn.jobstop(M._job_id)
          M._job_id = nil
          print('Terminated running process')
        end)
      end
    })

    local output_window = utils.create_window()

    vim.api.nvim_win_set_buf(output_window, output_buffer)

    local add_line = utils.create_add_line(output_buffer)

    if M._job_id then
      vim.fn.jobstop(M._job_id)
      M._job_id = nil
    end

    M._job_id = vim.fn.jobstart(command, {
      pty = true,
      cwd = vim.fn.getcwd(),
      on_stdout = add_line,
      on_stderr = add_line
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
    local picker = pickers.new({}, {
      prompt_title = "Runner",
      finder = finders.new_table {
        results = vim.tbl_keys(handlers)
      },
      sorter = sorters.get_generic_fuzzy_sorter(),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local handler_name = action_state.get_selected_entry()[1]
          handlers[handler_name](buffer)
        end)
        return true
      end,
    })
    picker:find()
  end
end

return M

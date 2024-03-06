local M = {}

local config = require('runner.config')

M._terminal_buffer = nil
M._terminal_window = nil
M._last_command = nil
M._last_handler = nil

M.create_buffer = function()
  if M._terminal_buffer and vim.api.nvim_buf_is_valid(M._terminal_buffer) then
    vim.api.nvim_buf_delete(M._terminal_buffer, {})
  end

  local buffer = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_option(buffer, 'modifiable', false)

  M._terminal_buffer = buffer
  return buffer
end

M.create_window = function()
  -- Don't know why vim.api.nvim_win_is_valid(M._terminal_window) is always false...
  if M._terminal_window and vim.api.nvim_win_is_valid(M._terminal_window) then
    vim.api.nvim_set_current_win(M._terminal_window)
    return M._terminal_window
  end

  if config.options.position == 'right' then
    vim.cmd('botright ' .. config.options.width .. ' vsplit')
  elseif config.options.position == 'left' then
    vim.cmd('topleft ' .. config.options.width .. ' vsplit')
  elseif config.options.position == 'bottom' then
    vim.cmd('botright ' .. config.options.height .. 'split')
  elseif config.options.position == 'top' then
    vim.cmd('topleft ' .. config.options.height .. 'split')
  end

  local window = vim.api.nvim_get_current_win()

  local window_opts = {
    number = false,
    relativenumber = false,
    wrap = true,
    spell = false,
    foldenable = false,
    signcolumn = 'no',
    colorcolumn = '',
    cursorline = true,
  }

  for key, value in pairs(window_opts) do
    vim.api.nvim_win_set_option(window, key, value)
  end

  M._terminal_window = window
  return window
end

M.run_command = function(command, callback)
  local output = {}

  local add_line = function(_, data)
    output[#output + 1] = data
  end

  vim.fn.jobstart(command, {
    cwd = vim.fn.getcwd(),
    on_stdout = add_line,
    on_exit = function()
      callback(output)
    end,
  })
end

local is_win = function()
  return package.config:sub(1, 1) == '\\'
end

local get_path_separator = function()
  if package.config:sub(1, 1) == '\\' then
    return '\\'
  end
  return '/'
end

M.script_path = function()
  local str = debug.getinfo(2, 'S').source:sub(2)
  if is_win() then
    str = str:gsub('/', '\\')
  end
  return str:match('(.*' .. get_path_separator() .. ')')
end

return M

local baleia = require('baleia').setup {}

local M = {}

M._buffer = nil
M._window = nil

M.create_buffer = function(name)
  if M._buffer and vim.api.nvim_buf_is_valid(M._buffer) then
    vim.api.nvim_buf_set_option(M._buffer, 'modifiable', true)
    vim.api.nvim_buf_set_lines(M._buffer, 0, -1, false, {})
    vim.api.nvim_buf_set_option(M._buffer, 'modifiable', false)
    return M._buffer
  end

  local buffer = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_name(buffer, name)
  vim.api.nvim_buf_set_option(buffer, 'modifiable', false)

  M._buffer = buffer
  return buffer
end

M.create_window = function()
  if M._window and vim.api.nvim_win_is_valid(M._window) and vim.api.nvim_win_get_buf(M._window) == M._buffer then
    return M._window
  end
  vim.cmd [[ vsplit ]]
  local window = vim.api.nvim_get_current_win()

  local window_opts = {
    number = false,
    relativenumber = false,
    wrap = true,
    spell = false,
    foldenable = false,
    signcolumn = "no",
    colorcolumn = "",
    cursorline = true,
  }

  for key, value in pairs(window_opts) do
    vim.api.nvim_win_set_option(window, key, value)
  end

  M._window = window
  return window
end

M.create_add_line = function(buffer)
  return function(_, data)
    vim.api.nvim_buf_set_option(buffer, 'modifiable', true)
    local row = vim.api.nvim_buf_line_count(buffer) - 1
    local col = vim.fn.len(vim.api.nvim_buf_get_lines(buffer, -2, -1, false)[1])
    baleia.buf_set_text(buffer, row, col, row, col, vim.tbl_map(
      function(d)
        return vim.fn.trim(d, ('\x0D'))
      end,
      data
    ))
    vim.api.nvim_buf_set_option(buffer, 'modifiable', false)
  end
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
    end
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

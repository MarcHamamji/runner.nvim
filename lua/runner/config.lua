local M = {}

local defaults = {
  position = 'right', -- options: top, left, right, bottom
  width = 80,         -- width of window when position is left or right
  height = 10,        -- height of window when position is top or bottom
}

M.options = {}

M.setup = function(options)
  M.options = vim.tbl_deep_extend('force', {}, defaults, options or {})
end

M.setup()

return M;

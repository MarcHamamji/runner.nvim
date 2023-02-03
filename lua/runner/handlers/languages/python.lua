local helpers = require('runner.handlers.helpers')

return function(buffer)
  helpers.shell_handler('python ' .. vim.fn.expand('%'))(buffer)
end

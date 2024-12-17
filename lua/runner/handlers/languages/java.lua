local helpers = require('runner.handlers.helpers')

return function(buffer)
    local current_file = vim.fn.expand('%')

    local handlers = {
        ['Run current file'] = helpers.shell_handler('java ' .. current_file),
        ['Custom'] = helpers.shell_handler('java ' .. current_file, true),
    }

    helpers.choice(handlers)(buffer)
end

local helpers = require('runner.handlers.helpers')

return function(buffer)
  local handlers = {
    ['Run'] = helpers.shell_handler('go run .'),
    ['Test'] = helpers.shell_handler('go test .'),
    ['Custom'] = helpers.shell_handler('go ', true),
  }
  helpers.choice(handlers)(buffer)
end

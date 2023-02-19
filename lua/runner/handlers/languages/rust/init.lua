local helpers = require('runner.handlers.helpers')
local utils   = require('runner.handlers.utils')

return function(buffer)
  utils.run_command(utils.script_path() .. 'get-bins.sh', function(output)
    local bins = {}

    for _, line in pairs(output) do
      for _, data in pairs(line) do
        if vim.trim(data) ~= '' then
          bins[#bins + 1] = data
        end
      end
    end

    local handlers = {
      ['Test'] = helpers.shell_handler('cargo test'),
      ['Custom'] = helpers.shell_handler('cargo ', true),
    }

    for _, bin in pairs(bins) do
      handlers['Run "' .. bin .. '"'] = helpers.shell_handler('cargo run --bin ' .. bin)
    end

    helpers.choice(handlers)(buffer)
  end)
end

local helpers = require('runner.handlers.helpers')
local utils = require('runner.handlers.utils')

return function(buffer)
  utils.run_command(utils.script_path() .. 'get-bins.sh', function(bins_output)
    local bins = {}

    for _, line in pairs(bins_output) do
      for _, data in pairs(line) do
        if vim.trim(data) ~= '' then
          bins[#bins + 1] = data
        end
      end
    end

    local handlers = {}

    for _, bin in pairs(bins) do
      handlers['Run "' .. bin .. '"'] = helpers.shell_handler('cargo run --bin ' .. bin)
    end

    utils.run_command(utils.script_path() .. 'get-tests.sh', function(tests_output)
      local tests = {}

      for _, line in pairs(tests_output) do
        for _, data in pairs(line) do
          if vim.trim(data) ~= '' then
            tests[#tests + 1] = data
          end
        end
      end

      handlers['Custom'] = helpers.shell_handler('cargo ', true)
      handlers['Test all'] = helpers.shell_handler('cargo test')

      P(handlers)

      for _, bin in pairs(tests) do
        handlers['Test "' .. bin .. '"'] = helpers.shell_handler('cargo test --test ' .. bin)
      end

      helpers.choice(handlers)(buffer)
    end)
  end)
end

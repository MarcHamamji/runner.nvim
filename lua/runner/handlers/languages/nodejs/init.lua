local helpers = require("runner.handlers.helpers")
local utils = require("runner.handlers.utils")

return function(buffer)
	utils.run_command(utils.script_path() .. "get-scripts.sh", function(output)
		local bins = {}

		for _, line in pairs(output) do
			for _, data in pairs(line) do
				if vim.trim(data) ~= "" then
					bins[#bins + 1] = data
				end
			end
		end

		local handlers = {
			["Run current file"] = helpers.shell_handler("node " .. vim.fn.expand("%")),
		}

		for _, bin in pairs(bins) do
			handlers['Run "' .. bin .. '"'] = helpers.shell_handler("npm run " .. bin)
		end

		helpers.choice(handlers)(buffer)
	end)
end

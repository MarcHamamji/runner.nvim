local helpers = require('runner.handlers.helpers')
local utils = require('runner.handlers.utils')

return function(buffer)
	utils.run_command(utils.script_path() .. "get-bins.sh", function(output)
		local bins = {}

		for _, line in pairs(output) do
			for _, data in pairs(line) do
				if vim.trim(data) ~= "" then
					bins[#bins + 1] = data
				end
			end
		end

		local run_handlers = {}

		for _, bin in pairs(bins) do
			run_handlers['Run "' .. bin .. '"'] = helpers.shell_handler("cargo run --bin " .. bin)
		end

		utils.run_command(utils.script_path() .. "get-tests.sh", function(output)
			local bins = {}

			for _, line in pairs(output) do
				for _, data in pairs(line) do
					if vim.trim(data) ~= "" then
						bins[#bins + 1] = data
					end
				end
			end

			local handlers = {
				unpack(run_handlers),
				["Custom"] = helpers.shell_handler("cargo ", true),
				["Test all"] = helpers.shell_handler("cargo test"),
			}

			for _, bin in pairs(bins) do
				handlers['Test "' .. bin .. '"'] = helpers.shell_handler("cargo test --test " .. bin)
			end

			helpers.choice(handlers)(buffer)
		end)
	end)
end

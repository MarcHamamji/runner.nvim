vim.api.nvim_create_user_command("Runner", function()
	require("runner").run()
end, { desc = "Runner" })

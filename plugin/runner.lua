vim.api.nvim_create_user_command('Runner', function()
  require('runner').run()
end, { desc = 'Run code inside the editor' })

vim.api.nvim_create_user_command('AutoRunner', function()
  require('runner').autorun()
end, { desc = 'Execute `Runner` on a file save' })

vim.api.nvim_create_user_command('AutoRunnerStop', function()
  require('runner').autorun_stop()
end, { desc = 'Stop `AutoRunner`' })

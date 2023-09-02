vim.api.nvim_create_user_command('Runner', function()
  require('runner').run()
end, { desc = 'Runner' })

vim.api.nvim_create_user_command('AutoRunner', function()
  require('runner').autorun()
end, { desc = 'Run Runner on save' })

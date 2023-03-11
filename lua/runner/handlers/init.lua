local helpers = require('runner.handlers.helpers')

local handlers = {
  rust = require('runner.handlers.languages.rust'),
  python = require('runner.handlers.languages.python'),
  lua = helpers.command_handler('luafile %'),
  javascript = require('runner.handlers.languages.nodejs'),
  typescript = require('runner.handlers.languages.nodejs'),
  vue = require('runner.handlers.languages.nodejs')
}

return handlers

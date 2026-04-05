---@type ChadrcConfig
local M = {}
vim.g.vscode_snippets_path = vim.fn.stdpath("config") .. "/lua/custom/snippets"
M.ui = { theme = 'solarized_dark' }
M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"

return M

vim.g.copilot_node_command = "/home/tusch/.nvm/versions/node/v20.20.2/bin/node"

vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<C-g>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

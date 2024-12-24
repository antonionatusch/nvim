vim.g.copilot_no_tab_map = true -- Desactiva el mapeo por defecto de la tecla Tab
vim.api.nvim_set_keymap("i", "<C-x>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

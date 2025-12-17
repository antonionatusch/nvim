local on_attach = function(client, bufnr)
  -- Configuración específica de on_attach
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require("flutter-tools").setup({
  ui = {
    border = "rounded",
  },
  decorations = {
    statusline = {
      app_version = true,
      device = true,
    },
  },
  lsp = {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      showTodos = true,
      completeFunctionCalls = true,
    },
  },
  dev_tools = {
    autostart = true,
  },
})

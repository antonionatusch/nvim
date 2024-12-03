local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

require("flutter-tools").setup {
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
}

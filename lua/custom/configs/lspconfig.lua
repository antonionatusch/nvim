local config = require("plugins.configs.lspconfig")
local on_attach = config.on_attach
local capabilities = config.capabilities
local util = require "lspconfig/util"
local lspconfig = require("lspconfig")

local global_path = vim.fn.trim(vim.fn.system("npm root -g"))

local cmd = {
  "ngserver",
  "--stdio",
  "--tsProbeLocations",
  global_path,
  "--ngProbeLocations",
  global_path,
}

-- Configuración personalizada
lspconfig.angularls.setup {
  cmd = cmd,
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = util.root_pattern("angular.json", "nx.json"),
  filetypes = { "typescript", "html", "typescriptreact" },
}

local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
  }
  vim.lsp.buf.execute_command(params)
end

-- lspconfig.ts_ls.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   init_options = {
--     preferences = {
--       disableSuggestions = true,
--     }
--   },
--   commands = {
--     OrganizeImports = {
--       organize_imports,
--       description = "Organize Imports",
--     }
--   }
-- }


lspconfig.clangd.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
}
lspconfig.cssls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    css = {
      validate = true,
    },
    less = {
      validate = true,
    },
    scss = {
      validate = true,
    },
  },
}
lspconfig.html.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    html = {
      format = {
        enable = true, -- Habilitar formato automático
      },
      hover = {
        documentation = true,
        references = true,
      },
      validate = true, -- Validar HTML
    },
  },
}

lspconfig.dartls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = util.root_pattern("pubspec.yaml"),
  settings = {
    dart = {
      enableSdkFormatter = true, -- Habilitar formateador del SDK de Dart
    },
  },
}

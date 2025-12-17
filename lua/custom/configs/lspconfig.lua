local config = require("plugins.configs.lspconfig")
local on_attach = config.on_attach
local capabilities = config.capabilities

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
vim.lsp.enable("angularls", {
  cmd = cmd,
  on_attach = on_attach,
  capabilities = capabilities,
  root_markers = { "angular.json", "nx.json" },
  filetypes = { "typescript", "html", "typescriptreact" },
})

local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
  }
  vim.lsp.buf.execute_command(params)
end

vim.lsp.enable("ts_ls", {
  on_attach = function(client, bufnr)
    -- No se desactiva el formateo aquí
    on_attach(client, bufnr)

    -- Atajo para organizar imports
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>oi", "", {
      callback = organize_imports,
      noremap = true,
      silent = true,
      desc = "Organize Imports (TypeScript)"
    })
  end,
  capabilities = capabilities,
  root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
})




vim.lsp.enable("clangd", {
  cmd = { "clangd",
    "--compile-commands-dir=build",
    "--query-driver=/usr/bin/g++,/usr/bin/clang++" },
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
})
vim.lsp.enable("cssls", {
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
})
vim.lsp.enable("html", {
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
})

vim.lsp.enable("dartls", {
  on_attach = on_attach,
  capabilities = capabilities,
  root_markers = { "pubspec.yaml" },
  settings = {
    dart = {
      enableSdkFormatter = true, -- Habilitar formateador del SDK de Dart
    },
  },
})

vim.lsp.enable("tailwindcss", {
  on_attach = on_attach,
  capabilities = capabilities,
  root_markers = { "tailwind.config.js", "tailwind.config.cjs", "tailwind.config.ts", "postcss.config.js", "angular.json", ".git" },
  filetypes = {
    "html",
    "typescriptreact",
    "javascriptreact",
    "css",
    "scss",
    "sass",
  },
  settings = {
    tailwindCSS = {
      lint = {
        cssConflict = "warning",
        invalidApply = "error",
        invalidScreen = "error",
        invalidVariant = "error",
        recommendedVariantOrder = "warning",
      },
      experimental = {
        classRegex = {
          -- compatibilidad con Angular
          "class\\s*=\\s*\"([^\"]*)\"",
          "ngClass\\s*=\\s*\"([^\"]*)\"",
        },
      },
    },
  },
})

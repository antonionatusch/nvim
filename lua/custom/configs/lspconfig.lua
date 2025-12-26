local config = require("plugins.configs.lspconfig")
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

-- Define angularls config
vim.lsp.config["angularls"] = {
  cmd = cmd,
  capabilities = capabilities,
  root_markers = { "angular.json", "nx.json" },
  filetypes = { "typescript", "html", "typescriptreact" },
}

-- Define ts_ls config
vim.lsp.config["ts_ls"] = {
  capabilities = capabilities,
  root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
}

-- Define clangd config
vim.lsp.config["clangd"] = {
  cmd = { "clangd",
    "--compile-commands-dir=build",
    "--query-driver=/usr/bin/g++,/usr/bin/clang++" },
  capabilities = capabilities,
}

-- Define cssls config
vim.lsp.config["cssls"] = {
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

-- Define html config
vim.lsp.config["html"] = {
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

-- Define dartls config
vim.lsp.config["dartls"] = {
  capabilities = capabilities,
  root_markers = { "pubspec.yaml" },
  settings = {
    dart = {
      enableSdkFormatter = true, -- Habilitar formateador del SDK de Dart
    },
  },
}

-- Define tailwindcss config
vim.lsp.config["tailwindcss"] = {
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
}

-- Helper function for TypeScript organize imports
local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
  }
  vim.lsp.buf.execute_command(params)
end

-- Setup custom LspAttach handlers for specific servers
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    if not client then
      return
    end

    -- Handle ts_ls specific: organize imports keybinding
    if client.name == "ts_ls" then
      vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>oi", "", {
        callback = organize_imports,
        noremap = true,
        silent = true,
        desc = "Organize Imports (TypeScript)"
      })
    end

    -- Handle clangd specific: disable signature help
    if client.name == "clangd" then
      client.server_capabilities.signatureHelpProvider = false
    end
  end,
})

vim.lsp.config["texlab"] = {
  settings = {
    texlab = {
      build = {
        executable = "latexmk",
        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
        onSave = false,
      },
      -- Formatting: texlab uses latexindent for this :contentReference[oaicite:2]{index=2}
      latexFormatter = "latexindent",
      latexindent = {
        modifyLineBreaks = false,
      },
    },
  },
}

-- Enable all custom LSP servers
vim.lsp.enable({ "angularls", "ts_ls", "clangd", "cssls", "html", "dartls", "tailwindcss", "texlab" })

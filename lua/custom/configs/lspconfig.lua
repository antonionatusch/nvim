local config = require("plugins.configs.lspconfig")
local capabilities = config.capabilities

local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

-- Define angularls config
vim.lsp.config["angularls"] = {
  capabilities = capabilities,
  workspace_required = true,
}

vim.lsp.config["intelephense"] = {
  -- Ensure you have 'intelephense' installed via npm: npm install -g intelephense
  filetypes = { "html", "php" },
  settings = {
    intelephense = {
      -- Example: Add custom include paths for external libraries
      environment = {
        includePaths = { "vendor/**" }
      },
      -- Disable formatting if using a different tool like Laravel Pint
      format = {
        enable = true
      },
      -- Telemetry is often disabled for privacy
      telemetry = {
        enabled = false
      }
    }
  }
}

-- Define ts_ls config
vim.lsp.config["ts_ls"] = {
  capabilities = capabilities,
  root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
}
vim.lsp.config["pyright"] = {
  capabilities = capabilities,
  root_markers = { ".git" },
  filetypes = { "python" },
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
  filetypes = { "html", "php" },
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

vim.lsp.config["tinymist"] = {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  root_markers = { ".git/" },
  capabilities = capabilities,
  settings = {
    formatterMode = "typstyle"
  },
}

vim.lsp.config["plantuml_lsp"] = {
  cmd = {
    vim.fn.expand("~/go/bin/plantuml-lsp"),
    "--exec-path=plantuml",
    -- or use this instead of --exec-path if you want the jar:
    -- "--jar-path=/path/to/plantuml.jar",
  },
  filetypes = { "plantuml" },
  root_markers = { ".git" },
  settings = {},
}

vim.lsp.config["ltex"] = {
  capabilities = capabilities,
  filetypes = { "bibtex", "gitcommit", "markdown", "org" },
  settings = {
    ltex = {
      language = "en",
      enabled = { "bibtex", "gitcommit", "markdown", "org" },
    },
  },
}


vim.lsp.config["dockerls"] = {
  cmd = { mason_bin .. "/docker-langserver", "--stdio" },
  capabilities = capabilities,
  root_markers = { "Dockerfile", ".git" },
  filetypes = { "dockerfile" },
  settings = {
    docker = {
      languageserver = {
        formatter = {
          ignoreMultilineInstructions = true,
        },
      },
    },
  },
}

vim.lsp.config["docker_compose_language_service"] = {
  cmd = { mason_bin .. "/docker-compose-langserver", "--stdio" },
  capabilities = capabilities,
  root_markers = {
    "docker-compose.yml",
    "docker-compose.yaml",
    "compose.yml",
    "compose.yaml",
    ".git",
  },
  filetypes = { "yaml.docker-compose" },
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "es"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en"
  end,
})

vim.lsp.enable({ "angularls", "ts_ls", "clangd", "cssls", "html", "dartls", "tailwindcss", "texlab", "tinymist",
  "pyright", "intelephense", "plantuml_lsp", "ltex", "dockerls", "docker_compose_language_service" })

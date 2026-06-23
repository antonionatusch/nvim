local function img_clip_project_root()
  local buffer_path = vim.api.nvim_buf_get_name(0)

  if buffer_path == "" then
    return vim.fn.getcwd()
  end

  local start_path = vim.fs.dirname(buffer_path)
  local assets_dir = vim.fs.find("assets", {
    path = start_path,
    upward = true,
    type = "directory",
  })[1]

  if assets_dir then
    return vim.fs.dirname(assets_dir)
  end

  local root_marker = vim.fs.find({ "typst.toml", ".git", ".hg", ".svn" }, {
    path = start_path,
    upward = true,
  })[1]

  if root_marker then
    return vim.fs.dirname(root_marker)
  end

  return vim.fn.getcwd()
end

local plugins = {
  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      require("dapui").setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      require "custom.configs.dap"
      require("core.utils").load_mappings("dap")
    end
  },
  -- {
  --   "jose-elias-alvarez/null-ls.nvim",
  --   event = "VeryLazy",
  --   opts = function()
  --     return require "custom.configs.null-ls"
  --   end,
  -- },
  {
    "mhartington/formatter.nvim",
    event = "VeryLazy",
    opts = function()
      return require "custom.configs.formatter"
    end
  },
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    config = function()
      require "custom.configs.lint"
    end
  },
  {
    "williamboman/mason.nvim",
    opts = function()
      -- 1. Grab NvChad's baseline options (keeps the UI icons & settings)
      local opts = require "plugins.configs.mason"

      -- 2. Define your massive array of packages here
      opts.ensure_installed = {
        "eslint-lsp",
        "js-debug-adapter",
        "prettier",
        "typescript-language-server",
        "rust-analyzer",
        "clangd",
        "lua-language-server",
        "codelldb",
        "css-lsp",
        "html-lsp",
        "dcm",
        "tailwindcss-language-server",
        "texlab",
        "tinymist",
        "pyright",
        "black",
        "intelephense",
        "ltex-ls",
        "docker-compose-language-service",
        "docker-language-server",
        "dockerfmt"
      }
      return opts
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  { "nvim-neotest/nvim-nio" },
  {
    "mrcjkb/rustaceanvim",
    version = "^4",
    ft = { "rust" },
    dependencies = "neovim/nvim-lspconfig",
    config = function()
      require "custom.configs.rustaceanvim"
    end
  },
  {
    'saecki/crates.nvim',
    ft = { "toml" },
    config = function(_, opts)
      local crates = require('crates')
      crates.setup(opts)
      require('cmp').setup.buffer({
        sources = { { name = "crates" } }
      })
      crates.show()
      require("core.utils").load_mappings("crates")
    end,
  },

  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function()
      vim.g.rustfmt_autosave = 1
    end
  },


  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      handlers = {}
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    -- 🟢 Esto ejecuta el script oficial de instalación sin depender de yarn o npm globales
    build = "sh -c 'cd app && ./install.sh'",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    }
  },
  {
    "akinsho/flutter-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "stevearc/dressing.nvim" }, -- Requiere plenary.nvim
    lazy = false,
    config = function()
      require("custom.configs.flutter") -- Cargar configuración desde configs/flutter.lua
    end,
  },
  {
    "github/copilot.vim",
    lazy = false,
    config = function()
      require("custom.configs.copilot") -- Carga la configuración desde configs/copilot.lua
    end,
  },
  {
    "Redoxahmii/json-to-types.nvim",
    build = "sh install.sh npm", -- Replace `npm` with your preferred package manager (e.g., yarn, pnpm).
    ft = "json",
    keys = {
      {
        "<leader>cU",
        "<CMD>ConvertJSONtoLang typescript<CR>",
        desc = "Convert JSON to TS",
      },
      {
        "<leader>ct",
        "<CMD>ConvertJSONtoLangBuffer typescript<CR>",
        desc = "Convert JSON to TS Buffer",
      },
    },
  },
  {
    "lervag/vimtex",
    lazy = false, -- we don't want to lazy load VimTeX
    init = function()
      vim.g.vimtex_view_general_viewer = "okular"
      vim.g.vimtex_view_general_options = '--unique file:@pdf#src:@line@tex'
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        out_dir = 'build'
      }
      vim.g.vimtex_formatting_enabled = 1
    end
  },
  {
    "iurimateus/luasnip-latex-snippets.nvim",
    -- vimtex isn't required if using treesitter
    requires = { "L3MON4D3/LuaSnip", "lervag/vimtex" },
    config = function()
      require 'luasnip-latex-snippets'.setup()
      require("luasnip").config.setup { enable_autosnippets = true }
    end,
  },
  {
    "max397574/typst-tools.nvim",
    ft = "typst",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp", -- Optional: if using nvim-cmp
      "L3MON4D3/LuaSnip", -- Optional: if using LuaSnip
    },
    config = function()
      require("typst-tools").setup({
        -- Configuration options
      })
    end,
  },
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    build = ":TypstPreviewUpdate", -- Command to download necessary binaries
    config = function()
      require("typst-preview").setup({
        -- Configuration options (e.g., open_cmd)
      })
    end,
  },
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      filetypes = {
        typst = {
          dir_path = function()
            return vim.fs.joinpath(img_clip_project_root(), "assets", "images")
          end,
        },
      },
    },
    keys = {
      -- suggested keymap
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },
  {
    "aklt/plantuml-syntax",
    ft = "plantuml",
  },
  {
    "supabase-community/postgres-language-server",
  }
}
return plugins

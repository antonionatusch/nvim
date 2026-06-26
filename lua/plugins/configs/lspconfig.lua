dofile(vim.g.base46_cache .. "lsp")

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 2,
    source = "if_many",
  },
  virtual_lines = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "single",
    source = "always",
  },
})

local M = {}
local utils = require "core.utils"

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

local function should_open_signature(client, bufnr)
  local provider = client.server_capabilities.signatureHelpProvider

  if type(provider) ~= "table" then
    return false
  end

  local triggers = provider.triggerCharacters

  if client.name == "csharp" then
    triggers = { "(", "," }
  end

  if type(triggers) ~= "table" then
    return false
  end

  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local line_to_cursor = line:sub(1, pos[2])

  local current_char = line_to_cursor:sub(#line_to_cursor, #line_to_cursor)
  local prev_char = line_to_cursor:sub(#line_to_cursor - 1, #line_to_cursor - 1)

  for _, trigger_char in ipairs(triggers) do
    if current_char == trigger_char then
      return true
    end

    if current_char == " " and prev_char == trigger_char then
      return true
    end
  end

  return false
end

local signature_group = vim.api.nvim_create_augroup("ModernLspSignature", { clear = true })

local function setup_signature_autocmd(bufnr)
  vim.api.nvim_clear_autocmds {
    group = signature_group,
    buffer = bufnr,
  }

  vim.api.nvim_create_autocmd("TextChangedI", {
    group = signature_group,
    buffer = bufnr,
    callback = function()
      local clients = vim.lsp.get_clients({
        bufnr = bufnr,
        method = "textDocument/signatureHelp",
      })

      for _, client in ipairs(clients) do
        if should_open_signature(client, bufnr) then
          vim.lsp.buf.signature_help({
            border = "single",
            focusable = false,
            silent = true,
          })
          return
        end
      end
    end,
  })
end

M.on_attach = function(client, bufnr)
  utils.load_mappings("lspconfig", { buffer = bufnr })

  if client:supports_method("textDocument/signatureHelp") then
    setup_signature_autocmd(bufnr)
  end
end

M.on_init = function(client, _)
  if not utils.load_config().ui.lsp_semantic_tokens and client:supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

vim.lsp.config["lua_ls"] = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", "selene.toml", ".git" },
  capabilities = M.capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          [vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types"] = true,
          [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    if not client then
      return
    end

    M.on_init(client, bufnr)
    M.on_attach(client, bufnr)
  end,
})

vim.lsp.enable({ "lua_ls" })

return M

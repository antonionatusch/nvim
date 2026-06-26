-- Compatibility fixes for plugins still calling deprecated Neovim APIs.

-- Fix old vim.validate({ ... }) calls used by some plugins.
do
  if not vim.g.compat_validate_table_signature then
    local native_validate = vim.validate

    vim.validate = function(...)
      if select("#", ...) == 1 and type((...)) == "table" then
        local specs = ...

        for name, spec in pairs(specs) do
          if type(spec) == "table" then
            native_validate(name, spec[1], spec[2], spec[3])
          else
            native_validate(name, spec)
          end
        end

        return
      end

      return native_validate(...)
    end

    vim.g.compat_validate_table_signature = true
  end
end

-- Replace deprecated vim.lsp.util.stylize_markdown() used by nvim-cmp.
do
  local util = vim.lsp and vim.lsp.util

  if util then
    util.stylize_markdown = function(bufnr, contents, _opts)
      local lines = {}

      local function add_text(text)
        for _, line in ipairs(vim.split(text, "\n", { plain = true })) do
          table.insert(lines, line)
        end
      end

      local function add_item(item)
        if type(item) == "string" then
          add_text(item)
          return
        end

        if type(item) ~= "table" then
          return
        end

        if item.value then
          add_text(tostring(item.value))
          return
        end

        for _, child in ipairs(item) do
          add_item(child)
        end
      end

      add_item(contents)

      while #lines > 0 and vim.trim(lines[1]) == "" do
        table.remove(lines, 1)
      end

      while #lines > 0 and vim.trim(lines[#lines]) == "" do
        table.remove(lines, #lines)
      end

      if #lines == 0 then
        lines = { "" }
      end

      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.bo[bufnr].filetype = "markdown"

      pcall(vim.treesitter.start, bufnr, "markdown")

      return lines
    end
  end
end

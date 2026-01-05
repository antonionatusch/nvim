local prettier = function()
  return {
    exe = "prettier",
    args = { "--single-quote", "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
    stdin = true
  }
end

local black = function()
  return {
    exe = "black",
    args = { "--quiet", "-" },
    stdin = true
  }
end

local M = {
  filetype = {
    javascript = { prettier },
    typescript = { prettier },
    html = { prettier },
    python = { black },
    ["*"] = {
      require("formatter.filetypes.any").remove_trailing_whitespace
    }
  }
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  command = "FormatWriteLock"
})

return M

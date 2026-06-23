local prettier = function()
  return {
    exe = "prettier",
    args = { "--single-quote", "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
    stdin = true,
  }
end

local black = function()
  return {
    exe = "black",
    args = { "--quiet", "-" },
    stdin = true,
  }
end

local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

local dockerfmt = function()
  return {
    exe = mason_bin .. "/dockerfmt",
    args = { "-w", vim.api.nvim_buf_get_name(0) },
    stdin = false,
  }
end

local M = {
  filetype = {
    javascript = { prettier },
    typescript = { prettier },
    javascriptreact = { prettier },
    typescriptreact = { prettier },

    html = { prettier },
    css = { prettier },
    scss = { prettier },
    json = { prettier },

    yaml = { prettier },
    ["yaml.docker-compose"] = { prettier },

    python = { black },

    dockerfile = { dockerfmt },

    ["*"] = {
      require("formatter.filetypes.any").remove_trailing_whitespace,
    },
  },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  command = "FormatWriteLock",
})

return M

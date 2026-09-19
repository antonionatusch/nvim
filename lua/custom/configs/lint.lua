local lint = require('lint')

-- Fix ENOENT: el linter por defecto de nvim-lint solo mira ./node_modules/.bin/eslint
-- relativo al cwd. Si abres nvim fuera del root del proyecto falla.
-- Lo parcheamos para buscar hacia arriba desde el buffer.
if lint.linters.eslint then
  local eslint = lint.linters.eslint
  local orig_cmd = eslint.cmd
  eslint.cmd = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local dir = bufname ~= "" and vim.fs.dirname(bufname) or vim.fn.getcwd()
    local local_bin = vim.fs.find("node_modules/.bin/eslint", { path = dir, upward = true })[1]
    if local_bin and vim.loop.fs_stat(local_bin) then
      return local_bin
    end
    -- fallback al comportamiento original (mira ./node_modules/.bin relativo al cwd o "eslint" en PATH)
    if type(orig_cmd) == "function" then
      return orig_cmd()
    end
    return orig_cmd or "eslint"
  end
end

lint.linters_by_ft = {
  javascript = {"eslint"},
  typescript = {"eslint"},
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    -- pcall para no mostrar "Error in BufWritePost ... ENOENT" si eslint no está instalado
    pcall(lint.try_lint)
  end,
})

local augroup = vim.api.nvim_create_augroup("PlantumlExport", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup,
  pattern = "*.puml",
  callback = function(args)
    local file = vim.fn.fnamemodify(args.file, ":p")
    local dir = vim.fn.fnamemodify(file, ":h")
    local outdir = dir:gsub("/puml$", "/svg")

    vim.fn.mkdir(outdir, "p")

    local cmd = string.format(
      "plantuml -tsvg --output-dir %s %s",
      vim.fn.shellescape(outdir),
      vim.fn.shellescape(file)
    )

    vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
      vim.notify(vim.fn.systemlist(cmd)[1] or "PlantUML export failed", vim.log.levels.ERROR)
    end
  end,
})

local augroup = vim.api.nvim_create_augroup("PlantumlExport", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup,
  pattern = "*.puml",
  callback = function(args)
    local file = vim.fn.fnamemodify(args.file, ":p")
    local dir = vim.fn.fnamemodify(file, ":h")

    local puml_root, relative_subdir

    if dir:match("/puml$") then
      puml_root = dir:gsub("/puml$", "")
      relative_subdir = ""
    else
      puml_root = dir:match("^(.*)/puml/")
      relative_subdir = dir:match("/puml/(.*)$")
    end

    if not puml_root then
      vim.notify("PlantUML file is not inside a puml directory", vim.log.levels.WARN)
      return
    end

    local outdir = puml_root .. "/svg"
    if relative_subdir and relative_subdir ~= "" then
      outdir = outdir .. "/" .. relative_subdir
    end

    vim.fn.mkdir(outdir, "p")

    local cmd = string.format(
      "plantuml -tsvg --output-dir %s %s",
      vim.fn.shellescape(outdir),
      vim.fn.shellescape(file)
    )

    local result = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
      vim.notify(result ~= "" and result or "PlantUML export failed", vim.log.levels.ERROR)
    end
  end,
})


-- Add this to your init.lua to auto-start native treesitter highlighting
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    -- Check if a parser exists for the current filetype before starting
    local lang = vim.treesitter.language.get_lang(vim.bo.filetype) or vim.bo.filetype
    if pcall(vim.treesitter.start) then
      -- Successfully started native highlighting
    end
  end,
})

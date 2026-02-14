-- ~/.config/nvim/lua/filetype.lua (or any custom filename)
vim.filetype.add({
  extension = {
    tpl = "helm",  -- This helps catch other `.tpl` files too
    gotmpl = 'gotmpl',
  },
  pattern = {
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
})


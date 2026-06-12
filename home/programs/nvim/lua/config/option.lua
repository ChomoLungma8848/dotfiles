local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.expandtab = true
opt.shiftround = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2

opt.scrolloff = 3

opt.whichwrap = "b,s,h,l,<,>,[,],~"

opt.cursorcolumn = true
opt.cursorline = true

opt.virtualedit:append("block")
opt.clipboard:append("unnamedplus,unnamed")

vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NonText", { bg = "NONE" })

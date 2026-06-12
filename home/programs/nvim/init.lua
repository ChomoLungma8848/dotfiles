vim.loader.enable()

require("config")

vim.keymap.set("i", "jj", "<Esc>")

vim.cmd([[colorscheme catppuccin-mocha]])

return {
  'catppuccin/nvim',
  name = 'catppuccin',
  lazy = false,
  priority = 1000,
  opts = {
    flavour = 'mocha',
    transparent_background = true,
    integrations = {
      cmp = true,
      gitsigns = true,
      treesitter = true,
      notify = true,
      mini = true,
      noice = true,
      snacks = true,
    },
  },
}

---@type LazySpec
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>c", group = "code" },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>s", group = "search" },
      { "<leader>u", group = "ui/toggle" },
      { "<leader>b", group = "buffer" },
      { "[", group = "prev" },
      { "]", group = "next" },
      { "g", group = "goto" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps",
    },
  },
}

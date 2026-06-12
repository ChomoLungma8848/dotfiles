---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      config = function()
        require("nvim-treesitter-textobjects").setup({
          select = {
            lookahead = true,
          },
          move = {
            set_jumps = true,
          },
        })

        -- select keymaps
        local select = function(query)
          return function()
            require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
          end
        end
        local so = { "x", "o" }
        vim.keymap.set(so, "af", select("@function.outer"), { desc = "outer function" })
        vim.keymap.set(so, "if", select("@function.inner"), { desc = "inner function" })
        vim.keymap.set(so, "ac", select("@class.outer"), { desc = "outer class" })
        vim.keymap.set(so, "ic", select("@class.inner"), { desc = "inner class" })
        vim.keymap.set(so, "aa", select("@parameter.outer"), { desc = "outer argument" })
        vim.keymap.set(so, "ia", select("@parameter.inner"), { desc = "inner argument" })
        vim.keymap.set(so, "ai", select("@conditional.outer"), { desc = "outer conditional" })
        vim.keymap.set(so, "ii", select("@conditional.inner"), { desc = "inner conditional" })
        vim.keymap.set(so, "al", select("@loop.outer"), { desc = "outer loop" })
        vim.keymap.set(so, "il", select("@loop.inner"), { desc = "inner loop" })

        -- move keymaps
        local move = require("nvim-treesitter-textobjects.move")
        local nxo = { "n", "x", "o" }
        vim.keymap.set(nxo, "]f", function() move.goto_next_start("@function.outer", "textobjects") end, { desc = "Next function start" })
        vim.keymap.set(nxo, "]c", function() move.goto_next_start("@class.outer", "textobjects") end, { desc = "Next class start" })
        vim.keymap.set(nxo, "]a", function() move.goto_next_start("@parameter.inner", "textobjects") end, { desc = "Next argument" })
        vim.keymap.set(nxo, "]F", function() move.goto_next_end("@function.outer", "textobjects") end, { desc = "Next function end" })
        vim.keymap.set(nxo, "]C", function() move.goto_next_end("@class.outer", "textobjects") end, { desc = "Next class end" })
        vim.keymap.set(nxo, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Previous function start" })
        vim.keymap.set(nxo, "[c", function() move.goto_previous_start("@class.outer", "textobjects") end, { desc = "Previous class start" })
        vim.keymap.set(nxo, "[a", function() move.goto_previous_start("@parameter.inner", "textobjects") end, { desc = "Previous argument" })
        vim.keymap.set(nxo, "[F", function() move.goto_previous_end("@function.outer", "textobjects") end, { desc = "Previous function end" })
        vim.keymap.set(nxo, "[C", function() move.goto_previous_end("@class.outer", "textobjects") end, { desc = "Previous class end" })

        -- swap keymaps
        local swap = require("nvim-treesitter-textobjects.swap")
        vim.keymap.set("n", "<leader>a", function() swap.swap_next("@parameter.inner") end, { desc = "Swap with next argument" })
        vim.keymap.set("n", "<leader>A", function() swap.swap_previous("@parameter.inner") end, { desc = "Swap with previous argument" })
      end,
    },
  },
  config = function()
    -- Install parsers
    require("nvim-treesitter").install({
      "bash", "c", "diff", "html", "css", "javascript", "json",
      "lua", "luadoc", "markdown", "markdown_inline", "nix",
      "query", "regex", "toml", "vim", "vimdoc", "yaml",
    })

    -- Enable treesitter highlighting for all filetypes with a parser
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}

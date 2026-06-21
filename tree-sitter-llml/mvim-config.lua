-- ── LLML Tree-sitter config for Lazy.nvim ─────────────────────────
-- Save this to ~/.config/mvim/lua/plugins/llml.lua (or wherever
-- you keep your Lazy.nvim plugin specs)
-- Then restart mvim and open a .llml file.

return {
  -- 1. Register the LLML parser for nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.llml = {
        install_info = {
          url = "/home/davi/Projects/llml/tree-sitter-llml",
          files = { "src/parser.c" },
        },
        filetype = "llml",
      }

      require("nvim-treesitter.configs").setup({
        ensure_installed = { "llml" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- 2. Filetype detection for .llml files
  {
    dir = "/home/davi/Projects/llml/tree-sitter-llml",
    lazy = false,
    config = function()
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*.llml",
        callback = function()
          vim.bo.filetype = "llml"
        end,
      })
    end,
  },
}

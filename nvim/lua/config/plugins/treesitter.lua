-- ============================================================
-- TREESITTER
-- Auto-installs parsers when tree-sitter CLI is available,
-- falls back to Neovim's bundled parsers when it isn't.
--
-- Install the CLI once per machine: npm i -g tree-sitter-cli
-- Then parsers install automatically as you open new filetypes.
-- ============================================================
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      local ts = require 'nvim-treesitter'
      local has_cli = vim.fn.executable 'tree-sitter' == 1

      -- Pre-install parsers for common languages on startup (CLI required)
      if has_cli then
        ts.install {
          'bash', 'c', 'cpp', 'diff', 'html', 'lua', 'luadoc',
          'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc',
        }
      end

      ---@param buf integer
      ---@param language string
      local function treesitter_try_attach(buf, language)
        if not vim.treesitter.language.add(language) then return end
        vim.treesitter.start(buf, language)

        local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil
        if has_indent_query then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      local available = ts.get_available()

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local language = vim.treesitter.language.get_lang(args.match)
          if not language then return end

          local installed = ts.get_installed 'parsers'

          if vim.tbl_contains(installed, language) then
            -- Parser already installed — attach immediately
            treesitter_try_attach(args.buf, language)
          elseif has_cli and vim.tbl_contains(available, language) then
            -- CLI present — install then attach
            ts.install(language):await(function()
              treesitter_try_attach(args.buf, language)
            end)
          else
            -- No CLI — try Neovim's bundled parser (may or may not exist)
            treesitter_try_attach(args.buf, language)
          end
        end,
      })
    end,
  },
}

-- ============================================================
-- FORMATTING
-- conform.nvim — format on save and manual formatting
-- ============================================================
return {
  {
    'stevearc/conform.nvim',
    config = function()
      require('conform').setup {
        notify_on_error = false,
        format_on_save = function(bufnr)
          -- Add filetypes here to enable autoformat on save.
          local enabled_filetypes = {
            lua = true,
            python = true,
            go = true,
            systemverilog = true,
          }
          if enabled_filetypes[vim.bo[bufnr].filetype] then
            return { timeout_ms = 500 }
          else
            return nil
          end
        end,
        default_format_opts = {
          -- Use external formatters if configured below, otherwise fall back to LSP formatting.
          -- Set to `false` to disable LSP formatting entirely.
          lsp_format = 'fallback',
        },
        -- Specify formatters per filetype.
        formatters_by_ft = {
          python = { 'ruff_format' },
        },
      }

      vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
        require('conform').format { async = true }
      end, { desc = '[F]ormat buffer' })
    end,
  },
}

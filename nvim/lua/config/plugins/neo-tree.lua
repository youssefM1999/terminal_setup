-- ============================================================
-- NEO-TREE
-- File explorer sidebar
-- Toggle with <leader>e
-- ============================================================
return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup {
        close_if_last_window = true, -- Close nvim if neo-tree is the last window
        window = {
          width = 35,
          mappings = {
            ['<space>'] = 'none', -- Free up space so <leader> works normally
          },
        },
        filesystem = {
          follow_current_file = {
            enabled = true, -- Highlight the current file in the tree
          },
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      }

      vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<cr>', { desc = 'Toggle file [E]xplorer' })
      vim.keymap.set('n', '<leader>E', '<cmd>Neotree reveal<cr>', { desc = 'Reveal current file in [E]xplorer' })
    end,
  },
}

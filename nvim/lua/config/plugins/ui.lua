-- ============================================================
-- UI / CORE UX PLUGINS
-- guess-indent, icons, gitsigns, which-key, colorscheme,
-- todo-comments, mini.nvim modules
-- ============================================================
return {
  -- Automatically detect and set indentation
  {
    'NMAC427/guess-indent.nvim',
    config = function()
      require('guess-indent').setup {}
    end,
  },

  -- Pretty file-type icons (requires a Nerd Font)
  {
    'nvim-tree/nvim-web-devicons',
    cond = vim.g.have_nerd_font,
  },

  -- Git signs in the gutter + hunk utilities
  -- See `:help gitsigns` to understand what each configuration key does
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        signs = {
          add = { text = '+' }, ---@diagnostic disable-line: missing-fields
          change = { text = '~' }, ---@diagnostic disable-line: missing-fields
          delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
          topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
          changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
        },
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 500,
          virt_text_pos = 'eol', -- show at end of line
        },
        current_line_blame_formatter = ' <author>, <author_time:%Y-%m-%d> • <summary>',
      }
    end,
  },

  -- Show pending keybinds in a popup
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
      require('which-key').setup {
        -- Delay between pressing a key and opening which-key (milliseconds)
        delay = 0,
        icons = { mappings = vim.g.have_nerd_font },
        -- Document existing key chains
        spec = {
          { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
          { '<leader>t', group = '[T]oggle' },
          { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
          { 'gr', group = 'LSP Actions', mode = { 'n' } },
        },
      }
    end,
  },

  -- [[ Colorscheme ]]
  -- To switch themes, swap this block for another plugin and change the colorscheme name.
  -- You can browse themes at https://vimcolorschemes.com or :Telescope colorscheme
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000, -- Load before other plugins so colors are set early
    config = function()
      require('catppuccin').setup {
        -- flavour = 'mocha', -- latte, frappe, macchiato, mocha
      }
      vim.cmd.colorscheme 'catppuccin'
    end,
  },

  -- Highlight todo, notes, fixme, etc in comments
  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('todo-comments').setup { signs = false }
    end,
  },

  -- [[ mini.nvim ]]
  -- A collection of various small independent plugins/modules.
  -- See: https://github.com/nvim-mini/mini.nvim
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup {
        -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12
        -- (see `:help treesitter-incremental-selection`)
        mappings = {
          around_next = 'aa',
          inside_next = 'ii',
        },
        n_lines = 500,
      }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      -- You could remove this setup call if you don't like it,
      -- and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- Set `use_icons` to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return '%2l:%-2v' end
    end,
  },
}

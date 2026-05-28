-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- [[ lazy.nvim setup ]]
-- Plugin specs live in lua/config/plugins/
-- Each file there returns a table of lazy plugin specs.
-- See :help lazy.nvim for full documentation.
require('lazy').setup {
  spec = {
    { import = 'config.plugins' },
  },
  -- Colorscheme used while installing plugins for the first time
  install = { colorscheme = { 'catppuccin', 'habamax' } },
  -- Automatically check for plugin updates
  checker = { enabled = true },
}

-- General Settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.nvim_tree_show_icons = {
    git = 1,
    folders = 1,
    files = 0,
    folder_arrows = 1,
}

vim.g.nvim_tree_icons = {
    default = ''
}

vim.opt.softtabstop = 0
vim.opt.shiftwidth = 4
vim.opt.tabstop = 8
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitright = true

-- Keybindings
vim.keymap.set('n', '<c-b>', ':NvimTreeFindFileToggle<CR>')


-- Plugin Config
require('lualine').setup {
    options = {
        icons_enabled = false,
        section_separators = {left='', right=''},
        component_separators = {left='|', right='|'},
        disabled_filetypes = {},
    },
    sections = {
        lualine_a = {
            {
                'filename',
                path = 1
            },
        },
        lualine_c = {
            {
                'mode'
            }
        }
    }
}

require("nvim-tree").setup {
    renderer = {
        icons = {
          glyphs = {
            default = "",
            symlink = "",
            bookmark = "",
            modified = "●",
            folder = {
              arrow_closed = "",
              arrow_open = "",
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "",
              renamed = "➜",
              untracked = "★",
              deleted = "",
              ignored = "◌",
            },
          },
      }
  }
}


local builtin = require('telescope.builtin')

vim.keymap.set('n', '<c-p>', builtin.find_files, {})
vim.keymap.set('n', '<Space><Space>', builtin.oldfiles, {})
vim.keymap.set('n', '<Space>fg', builtin.live_grep, {})
vim.keymap.set('n', '<Space>fh', builtin.help_tags, {})
vim.keymap.set('n', '<Space>fb', builtin.buffers, {})


-- Packer bootstrap
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Packer config
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'github/copilot.vim'
  use 'nvim-tree/nvim-tree.lua'
  use {
      'nvim-lualine/lualine.nvim'
  }
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {
      'dracula/vim',
      config=function()
        vim.cmd('colorscheme dracula')
      end
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)


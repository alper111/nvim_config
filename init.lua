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
vim.opt.splitbelow = true

-- Keybindings
vim.keymap.set('n', '<c-b>', ':NvimTreeFindFileToggle<CR>')
-- Open the terminal in a new window below with 10 lines with insert mode
vim.keymap.set('n', 'gt', ':botright 10sp | terminal<CR>i')
-- Focus the below window
vim.keymap.set('n', '<c-j>', '<c-w>j')

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
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'github/copilot.vim'
    use {
        'saghen/blink.cmp',
        requires = { 'rafamadriz/friendly-snippets' }, -- optional dependency
        tag = '*', -- use a release tag for pre-built binaries
        -- OR build from source if needed
        -- run = 'cargo build --release',
        -- run = 'nix run .#build-plugin', -- for nix users
        config = function()
        require('blink.cmp').setup({
            keymap = { preset = 'super-tab' },
            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = 'mono'
            },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' }
            },
            fuzzy = { implementation = "prefer_rust_with_warning" }
            })
        end
    }

    use {
        'neovim/nvim-lspconfig',
        requires = { 'saghen/blink.cmp' }, -- Dependency on blink.cmp
        config = function()
            local capabilities = require('blink.cmp').get_lsp_capabilities()
            local lspconfig = require('lspconfig')

            -- Define LSP servers and their configurations
            local servers = {
                pyright = lspconfig.pyright
            }

            for server, config in pairs(servers) do
                -- Merge blink.cmp capabilities with existing capabilities if defined
                config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
                lspconfig[server].setup(config)
            end

            -- Global mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
            vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

            -- Use LspAttach autocommand to only map the following keys
            -- after the language server attaches to the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
              group = vim.api.nvim_create_augroup('UserLspConfig', {}),
              callback = function(ev)
                -- Enable completion triggered by <c-x><c-o>
                vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                -- Buffer local mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local opts = { buffer = ev.buf }
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
                vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
                vim.keymap.set('n', '<space>wl', function()
                  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, opts)
                vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
                vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
                vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                vim.keymap.set('n', '<space>f', function()
                  vim.lsp.buf.format { async = true }
                end, opts)
              end,
            })
        end
    }

    use {
        'nvim-tree/nvim-tree.lua',
        config = function()
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
                        }
                    }
                }
            }
        end
    }

    use 'PontusPersson/pddl.vim'
    use {
        'nvim-lualine/lualine.nvim',
	config = function()
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
	end
    }

    use 'tpope/vim-commentary'
    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<c-p>', builtin.find_files, {})
            vim.keymap.set('n', '<Space><Space>', builtin.oldfiles, {})
            vim.keymap.set('n', '<Space>fg', builtin.live_grep, {})
            vim.keymap.set('n', '<Space>fh', builtin.help_tags, {})
            vim.keymap.set('n', '<Space>fb', builtin.buffers, {})
            vim.keymap.set('n', '<Space>fc', builtin.commands, {})
        end
    }

    use {
        'projekt0n/github-nvim-theme',
        config = function()
            vim.cmd('colorscheme github_light_default')
        end
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)


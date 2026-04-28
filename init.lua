-- General Settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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
-- highlight current line
vim.opt.cursorline = true

-- Keybindings
vim.keymap.set('n', '<c-b>', ':NvimTreeFindFileToggle<CR>')
vim.keymap.set('n', '<leader>bd', ':bd<CR>', { noremap = true })

-- VSCode-like terminal toggle: opens a 10-line split below on first press,
-- hides it on the next, and re-shows the same buffer (not a new one) after that.
local term = { buf = nil }
local function toggle_terminal()
    if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
        local win = vim.fn.bufwinid(term.buf)
        if win ~= -1 then
            vim.api.nvim_win_close(win, false)
            return
        end
        vim.cmd('botright 10sp')
        vim.api.nvim_win_set_buf(0, term.buf)
        vim.cmd('startinsert')
        return
    end
    vim.cmd('botright 10sp | terminal')
    term.buf = vim.api.nvim_get_current_buf()
    vim.cmd('startinsert')
end
vim.keymap.set({ 'n', 't' }, '<c-j>', toggle_terminal)

vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        if vim.bo.buftype == 'terminal' then
            vim.cmd('startinsert')
        end
    end,
})

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        'git', 'clone', '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    {
        'hrsh7th/nvim-cmp',
        dependencies = { 'hrsh7th/cmp-nvim-lsp' },
        config = function()
            local cmp = require('cmp')
            cmp.setup({
                mapping = {
                    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
                },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
                }
            })
        end
    },

    {
        'neovim/nvim-lspconfig',
        config = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local cap = require('cmp_nvim_lsp').default_capabilities(capabilities)

            vim.lsp.config('pylsp', { capabilities = cap })
            vim.lsp.enable('pylsp')

            -- Global mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
            vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end)
            vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end)
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
    },

    {
        'mfussenegger/nvim-lint',
        config = function()
            require('lint').linters_by_ft = {
                python = { 'flake8' }
            }

            require('lint').linters.flake8.args = {
                '--max-line-length=120',
                '--format=%(path)s:%(row)d:%(col)d:%(code)s:%(text)s',
                '--no-show-source',
                '-',
            }

            vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
                callback = function()
                    require('lint').try_lint()
                end
            })
        end
    },

    {
        'nvim-tree/nvim-tree.lua',
        config = function()
            require('nvim-tree').setup {
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
    },

    'PontusPersson/pddl.vim',

    {
        'nvim-lualine/lualine.nvim',
        config = function()
            require('lualine').setup {
                options = {
                    icons_enabled = false,
                    section_separators = { left = '', right = '' },
                    component_separators = { left = '|', right = '|' },
                    disabled_filetypes = {},
                },
                sections = {
                    lualine_a = { { 'filename', path = 1 } },
                    lualine_c = { { 'mode' } }
                }
            }
        end
    },

    'tpope/vim-commentary',

    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<c-p>', builtin.find_files, {})
            vim.keymap.set('n', '<Space><Space>', builtin.oldfiles, {})
            vim.keymap.set('n', '<Space>fg', builtin.live_grep, {})
            vim.keymap.set('n', '<Space>fh', builtin.help_tags, {})
            vim.keymap.set('n', '<Space>fb', builtin.buffers, {})
            vim.keymap.set('n', '<Space>fc', builtin.commands, {})
        end
    },

    {
        'projekt0n/github-nvim-theme',
        config = function()
            vim.cmd('colorscheme github_light_default')
        end
    },
})

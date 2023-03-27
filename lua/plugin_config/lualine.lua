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

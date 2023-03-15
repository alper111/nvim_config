require('lualine').setup {
    options = {
        icons_enabled = true,
        component_separators = {'', ''},
        section_separators = {'', ''},
        disabled_filetypes = {}
    },
    sections = {
        lualine_a = {
            {
                'filename',
                path = 1
            }
        },
        lualine_b = {
            {
                'branch',
                icon = ''
            }
        },
    }
}

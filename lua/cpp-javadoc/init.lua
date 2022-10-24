local config = require('cpp-javadoc.config')

local M = {}

M.setup = function(args)
    local opts = config.opts
    if args then
        for key, value in pairs(args) do
            if opts[key] then
                opts[key] = value
            else
                print('Key %s does not exist.', key)
                return
            end
        end
    end
    vim.api.nvim_create_user_command('Javadoc', config.insert_javadoc, {})
    vim.api.nvim_set_keymap('n', opts.add_javadoc, '<cmd>Javadoc<CR>', { noremap = true })
end

return M


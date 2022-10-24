local buffer = require('cpp-javadoc.buffer')

local pad_spaces = function(str, length)
    return str .. string.rep(' ', length - string.len(str))
end

local M = {}

M.opts = { add_javadoc = '<C-j>', silent = true, align = true, left_spaces = 4, right_spaces = 4 }

M.insert_javadoc = function(opts)
    if (vim.opt_local.filetype:get() ~= 'cpp') then
        return
    end

    local header
    if not buffer.has_javadoc() then
        header = buffer.get_fn_header()
    else
        if not M.opts.silent then print('Function already has a Javadoc.') end
        return nil
    end

    if not header then
        if not M.opts.silent then print('Move cursor into a function.') end
        return nil
    end

    local javadoc = {'/** ', ''}

    local max_length = 0
    for _, param in ipairs(header.parameters) do
        max_length = math.max(max_length, string.len(param))
    end

    local param_length = max_length + M.opts.right_spaces
    for _, param in ipairs(header.parameters) do
        if M.opts.align then
            table.insert(javadoc, '@param' .. string.rep(' ', M.opts.left_spaces) .. pad_spaces(param, param_length))
        else
            table.insert(javadoc, '@param' .. string.rep(' ', M.opts.left_spaces) .. param .. string.rep(' ', M.opts.right_spaces))
        end
    end

    if header.return_type ~= 'void' then
        table.insert(javadoc, '')
        table.insert(javadoc, '@return ')
    end

    table.insert(javadoc, '*/')

    local row, _, _, _ = buffer.get_fn_root_node():range()
    buffer.insert_lines(javadoc, row)

    vim.api.nvim_win_set_cursor(0, {row+1, 3})
end

return M


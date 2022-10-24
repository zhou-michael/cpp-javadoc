local M = {}

M.get_curr_pos = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    return { row = pos[1], col = pos[2] }
end

M.get_fn_root_node = function()
    local pos = M.get_curr_pos()
    local node = vim.treesitter.get_node_at_pos(0, pos.row, pos.col)

    while node and node:type() ~= 'function_definition' do
        node = node:parent()
    end

    return node
end

M.get_fn_header = function()
    local node = M.get_fn_root_node()
    if node == nil then
        return nil
    end

    local row, _, _, _ = node:range()
    local return_type = vim.treesitter.query.get_node_text(node:field('type')[1], 0)
    local parameters = node:field('declarator')[1]:field('parameters')[1]
    local parameters_list = {}
    for parameter in parameters:iter_children() do
        if parameter:type() == 'parameter_declaration' then
            local parameter_name = vim.treesitter.query.get_node_text(parameter:field('declarator')[1], 0)
            table.insert(parameters_list, parameter_name)
        end
    end

    return { row = row, return_type = return_type, parameters = parameters_list }
end

M.insert_lines = function(lines, line_nr)
    vim.api.nvim_buf_set_lines(0, line_nr, line_nr, true, lines)
end

M.has_javadoc = function()
    local node = M.get_fn_root_node()
    if node == nil then return false end

    local row, _, _, _ = node:range()
    if row == 1 then return false end
    local prev_node = vim.treesitter.get_node_at_pos(0, row-1, 0)

    if prev_node:type() == 'comment' then
        local comment = vim.treesitter.query.get_node_text(prev_node, 0)
        if string.len(comment) >= 3 and string.sub(comment, 0, 3) == '/**' then
            return true
        end
    end
    return false
end

return M

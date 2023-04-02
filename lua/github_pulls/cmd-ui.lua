M = {}

M.open_url = function(url)
    local cmd = ""
    if vim.fn.has("mac") == 1 then
        cmd = "open"
    elseif vim.fn.has("unix") == 1 then
        cmd = "xdg-open"
    elseif vim.fn.has("win32") == 1 then
        cmd = "start"
    else
        print("Unsupported platform")
        return
    end
    vim.fn.jobstart({cmd, url})
end

return M

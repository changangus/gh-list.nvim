local api = require("github_pulls.api")
local popup = require("plenary.popup")

local M = {}

local bufnr = vim.api.nvim_create_buf(false, false)

local getUrls = function(pulls)
  local urls = {}
  for _, pull in ipairs(pulls) do
    table.insert(urls, pull.html_url)
  end
  return urls
end


local pulls = api.get_pulls()
M.data = api.translate_data(pulls)
M.urls = getUrls(pulls)

M.open_pull = function()
  local url = M.urls[1]
  M.open_url(url)
end

M.show_pulls = function()
  local winnr = popup.create(bufnr, {
    title = "Pull Requests",
    minwidth = 50,
    minheight = 10,
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
  })

  vim.api.nvim_win_set_buf(winnr, bufnr)
end

for i, pull in ipairs(M.data) do
  vim.api.nvim_buf_set_lines(bufnr, i, i, false, { pull.title })
end
vim.api.nvim_buf_set_keymap(bufnr, "n", "<esc>", ":q<CR>", { noremap = true, silent = true })
vim.api.nvim_buf_set_keymap(bufnr, "n", "<cr>", ":lua require('github_pulls.ui').open_pull()<CR>", { noremap = true, silent = true })

return M

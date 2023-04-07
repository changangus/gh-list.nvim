local api = require("github_pulls.api")
local popup = require("plenary.popup")

local M = {}

local getUrls = function(pulls)
  local urls = {}
  for _, pull in ipairs(pulls) do
    table.insert(urls, pull.html_url)
  end
  return urls
end

local pulls = api.get_prs()
M.data = api.translate_data(pulls)
M.urls = getUrls(pulls)

local function create_window()
  local width = 60
  local height = 10
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  local bufnr = vim.api.nvim_create_buf(true, true)

  local Gh_pulls_win_id, win = popup.create(bufnr, {
    title = "Pull Requests",
    highlight = "PRsWindow",
    line = math.floor(((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    minwidth = width,
    minheight = height,
    borderchars = borderchars,
  })

  vim.api.nvim_win_set_option(
    win.border.win_id,
    "winhl",
    "Normal:Gh_pullsBorder"
  )

  return {
    bufnr = bufnr,
    win_id = Gh_pulls_win_id,
  }
end

M.toggle_quick_menu = function()
  if Gh_pulls_win_id ~= nil and vim.api.nvim_win_is_valid(Gh_pulls_win_id) then
    vim.api.nvim_win_close(Gh_pulls_win_id, true)
    return
  end

  local win_info = create_window()

  Gh_pulls_win_id = win_info.win_id
  Gh_pulls_bufh = win_info.bufnr

  for i, pull in ipairs(M.data) do
    vim.api.nvim_buf_set_lines(Gh_pulls_bufh, i, i, false, { pull.title })
  end
  vim.api.nvim_buf_set_keymap(Gh_pulls_bufh, "n", "<esc>", ":q<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(Gh_pulls_bufh, "n", "<cr>", ":lua require('github_pulls.ui').open_pull()<CR>",
    { noremap = true, silent = true })
end

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
  vim.fn.jobstart({ cmd, url })
end

M.open_pull = function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local url = M.urls[line - 1]
  M.open_url(url)
  vim.api.nvim_win_close(Gh_pulls_win_id, true)
end


return M

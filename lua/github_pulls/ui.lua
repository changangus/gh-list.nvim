local api = require("github_pulls.api")
local popup = require("plenary.popup")

local getUrls = function(pulls)
  local urls = {}
  for _, pull in ipairs(pulls) do
    table.insert(urls, pull.html_url)
  end
  return urls
end

M.prs = api.get_prs_by_user()
M.pr_urls = getUrls(M.prs)
M.reviews = api.get_reviews_by_user()
M.review_urls = getUrls(M.reviews)

local function create_pr_window()
  local width = M.config.width
  local height = M.config.height
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  local bufnr = vim.api.nvim_create_buf(true, true)

  local Prs_win_id, win = popup.create(bufnr, {
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
    "Normal:PrsBorder"
  )

  return {
    bufnr = bufnr,
    win_id = Prs_win_id,
  }
end

M.toggle_pr_menu = function()
  if Prs_win_id ~= nil and vim.api.nvim_win_is_valid(Prs_win_id) then
    vim.api.nvim_win_close(Prs_win_id, true)
    return
  end

  local win_info = create_pr_window()

  Prs_win_id = win_info.win_id
  Prs_bufh = win_info.bufnr

  for i, pull in ipairs(M.prs) do
    vim.api.nvim_buf_set_lines(Prs_bufh, i, i, false, { pull.title })
  end
  vim.api.nvim_buf_set_keymap(Prs_bufh, "n", "<esc>", ":q<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(Prs_bufh, "n", "<cr>", ":lua require('github_pulls.ui').open_pull()<CR>",
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
  local url = M.pr_urls[line - 1]
  M.open_url(url)
  vim.api.nvim_win_close(Prs_win_id, true)
end

M.open_review = function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local url = M.review_urls[line - 1]
  M.open_url(url)
  vim.api.nvim_win_close(Reviews_win_id, true)
end

local function create_review_window()
  local width = M.config.width
  local height = M.config.height
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  local bufnr = vim.api.nvim_create_buf(true, true)

  local Reviews_win_id, win = popup.create(bufnr, {
    title = "Reviews",
    highlight = "ReviewsWindow",
    line = math.floor(((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    minwidth = width,
    minheight = height,
    borderchars = borderchars,
  })

  vim.api.nvim_win_set_option(
    win.border.win_id,
    "winhl",
    "Normal:ReviewsBorder"
  )

  return {
    bufnr = bufnr,
    win_id = Reviews_win_id,
  }
end

M.toggle_reviews_menu = function()
  if Reviews_win_id ~= nil and vim.api.nvim_win_is_valid(Reviews_win_id) then
    vim.api.nvim_win_close(Reviews_win_id, true)
    return
  end

  local win_info = create_review_window()

  Reviews_win_id = win_info.win_id
  Reviews_bufh = win_info.bufnr

  for i, review in ipairs(M.reviews) do
    vim.api.nvim_buf_set_lines(Reviews_bufh, i, i, false, { review.title })
  end
  vim.api.nvim_buf_set_keymap(Reviews_bufh, "n", "<esc>", ":q<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(Reviews_bufh, "n", "<cr>", ":lua require('github_pulls.ui').open_review()<CR>",
    { noremap = true, silent = true })
end

return M

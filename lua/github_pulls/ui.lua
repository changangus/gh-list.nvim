local api = require("github_pulls.api")
local popup = require("plenary.popup")

local get_urls = function(pulls)
  local urls = {}
  for _, pull in ipairs(pulls) do
    table.insert(urls, pull.html_url)
  end
  return urls
end

local get_branch_name = function(pulls)
  local branch_names = {}
  for _, pull in ipairs(pulls) do
    table.insert(branch_names, pull.branch_name)
  end
  return branch_names
end

M.prs = api.get_prs_by_user()
M.pr_branch_names = get_branch_name(M.prs)
M.pr_urls = get_urls(M.prs)
M.reviews = api.get_reviews_by_user()
M.review_urls = get_urls(M.reviews)
M.review_branch_names = get_branch_name(M.reviews)

local function create_pr_window()
  local width = M.config.width
  local height = M.config.height
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  local bufnr = vim.api.nvim_create_buf(false, true)

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

  vim.api.nvim_command("hi PRsWindow guibg=bg")
  vim.api.nvim_command("hi PrsBorder guibg=bg")

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
  vim.api.nvim_buf_set_keymap(Prs_bufh, "n", "gco", ":lua require('github_pulls.ui').pr_checkout_branch()<CR>",
    { noremap = true, silent = true })
  vim.api.nvim_buf_set_option(Prs_bufh, "modifiable", false)
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

M.pr_checkout_branch = function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local branch_name = M.pr_branch_names[line - 1]

  -- execute the Git command and capture the stderr output
  local git_cmd = "git checkout " .. branch_name .. " 2> /tmp/git_error.log"
  local status = os.execute(git_cmd)

  if status == 0 then
    -- checkout succeeded, close the window
    vim.api.nvim_win_close(Prs_win_id, true)
  else
    -- checkout failed, set buffer lines to the error message
    local error_file = io.open("/tmp/git_error.log", "r")
    if error_file == nil then
      print("Error opening /tmp/git_error.log")
      return
    end
    local error_message = error_file:read("*all")
    error_file:close()

    error_message = string.gsub(error_message, "\n", " ")
    -- replace multiple spaces with a single space
    error_message = string.gsub(error_message, "%s+", " ")

    -- set the color to red
    local red = "ErrorMsg"

    -- print a message in red
    vim.api.nvim_echo({ { error_message, red } }, true, {})
  end
end


M.open_review = function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local url = M.review_urls[line - 1]
  M.open_url(url)
  vim.api.nvim_win_close(Reviews_win_id, true)
end

M.review_checkout_branch = function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local branch_name = M.review_branch_names[line - 1]

  -- execute the Git command and capture the stderr output
  local git_cmd = "git checkout " .. branch_name .. " 2> /tmp/git_error.log"
  local status = os.execute(git_cmd)

  if status == 0 then
    -- checkout succeeded, close the window
    vim.api.nvim_win_close(Reviews_win_id, true)
  else
    -- checkout failed, set buffer lines to the error message
    local error_file = io.open("/tmp/git_error.log", "r")
    if error_file == nil then
      print("Error opening /tmp/git_error.log")
      return
    end
    local error_message = error_file:read("*all")
    error_file:close()

    error_message = string.gsub(error_message, "\n", " ")
    -- replace multiple spaces with a single space
    error_message = string.gsub(error_message, "%s+", " ")

    -- set the color to red
    local red = "ErrorMsg"

    -- print a message in red
    vim.api.nvim_echo({ { error_message, red } }, true, {})
  end
end

local function create_review_window()
  local width = M.config.width
  local height = M.config.height
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  local bufnr = vim.api.nvim_create_buf(false, true)

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
  vim.api.nvim_command("hi ReviewsWindow guibg=bg")
  vim.api.nvim_command("hi ReviewsBorder guibg=bg")

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
  vim.api.nvim_buf_set_option(Reviews_bufh, "modifiable", false)
end

return M

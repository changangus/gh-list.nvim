local curl = require("plenary.curl")
local decode = vim.fn.json_decode
local setup = require("github_pulls.init")

local config = setup.config
local M = {}

M.username = config.username

local headers = {
  ["Accept"] = "application/json",
  ["Authorization"] = "Bearer <TOKEN_GOES_HERE>",
  ["X-GitHub-Api-Version"] = "2022-11-28"
}

  local response = curl.get({ url = 'https://api.github.com/repos/<username>/<repo>/pulls', headers = headers })
M.get_prs = function()

  return decode(response.body)
end

M.translate_data = function(pulls)
  local data = {}

  for _, pull in ipairs(pulls) do
      table.insert(data, {
        title = pull.title,
        number = pull.number,
        html_url = pull.html_url,
        reviewers = pull.requested_reviewers,
        branch_name = pull.head.ref,
      })
  end

  return data
end

M.get_prs_by_user = function()
  local pulls = M.get_prs()
  local data = {}

  for _, pull in ipairs(pulls) do
    if pull.user.login == M.username then
      table.insert(data, {
        title = pull.title,
        number = pull.number,
        html_url = pull.html_url,
        reviewers = pull.requested_reviewers,
        branch_name = pull.head.ref,
      })
    end
  end

  return data
end

M.get_reviews_by_user = function()
  local pulls = M.get_prs()
  local data = {}

  for _, pull in ipairs(pulls) do
    for _, reviewer in ipairs(pull.requested_reviewers) do
      if reviewer.login == M.username then
        table.insert(data, {
          title = pull.title,
          number = pull.number,
          html_url = pull.html_url,
          branch_name = pull.head.ref,
        })
      end
    end
  end

  return data
end


return M

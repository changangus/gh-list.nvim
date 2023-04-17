local curl = require("plenary.curl")
local decode = vim.fn.json_decode

local setup_config = function ()
  if M.is_config_updated then
    M.username = M.config.username
    M.is_config_updated = false
    return
  end
end

local function get_git_remote_origin_url()
    -- Get the remote origin URL from the Git config file
    local remote_origin_url = vim.fn.systemlist('git config --get remote.origin.url')[1]

    local username = remote_origin_url:match('github%.com/([^/]+)/')
    local repo_name = remote_origin_url:match('github%.com/[^/]+/(.-)%.git$')

    return username, repo_name
end

local username, repo_name = get_git_remote_origin_url()

local headers = {
  ["Accept"] = "application/json",
  ["Authorization"] = "Bearer " .. os.getenv("GH_TOKEN"),
  ["X-GitHub-Api-Version"] = "2022-11-28"
}

local url = 'https://api.github.com/repos/' .. username .. '/' .. repo_name .. '/pulls'

M.get_prs = function()
  local response = curl.get({ url = url, headers = headers })

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
  setup_config()
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
  setup_config()
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

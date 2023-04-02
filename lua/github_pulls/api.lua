local curl = require("plenary.curl")
local decode = vim.fn.json_decode

local M = {}

local headers = {
  ["Accept"] = "application/json",
  ["Authorization"] = "Bearer <TOKEN_GOES_HERE>",
  ["X-GitHub-Api-Version"] = "2022-11-28"
}

M.get_pulls = function()
  local response = curl.get({ url = 'https://api.github.com/repos/<username>/<repo>/pulls', headers = headers })

  return decode(response.body)
end

M.translate_data = function(pulls)
  local data = {}

  for _, pull in ipairs(pulls) do
    table.insert(data, {
      title = pull.title,
      number = pull.number,
      html_url = pull.html_url,
    })
  end

  return data
end

return M

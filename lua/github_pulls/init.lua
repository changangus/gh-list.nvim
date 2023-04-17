print('loaded the plugin')

local M = {}

M.config = {
  width = 80,
  height = 20,
  username = '',
}

M.setup = function(options)
  M.config = vim.tbl_extend('force', M.config, options or {})
end

return M


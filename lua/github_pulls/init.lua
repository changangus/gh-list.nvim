_G.M = _G.M or {}

M.config = {
  width = 80,
  height = 20,
  username = '',
}

M.is_config_updated = false

M.setup = function(options)
  M.config = vim.tbl_extend('force', M.config, options or {})
  M.is_config_updated = true
end

return M


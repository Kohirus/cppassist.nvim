local M = {}

M.options = {
  switch_sh = {
		include_dirs = { ".", ".." },
    exclude_dirs = {},
    search_flags = "-tf -s -L",
    return_type = {
      int = "0",
      short = "0",
      long = "0",
      char = "0",
      double = "0.0",
      float = "0.0",
      bool = "false",
      pointer = "nullptr",
    }
  },
	goto_header = {
		include_dirs = { ".", "..", "/usr/include", "/usr/local/include", "~" },
		exclude_dirs = {},
		search_flags = "-tf -s -L",
	},
}

function M.set_options(custom_opts)
	M.options = vim.tbl_deep_extend("force", M.options, custom_opts or {})
end

return M

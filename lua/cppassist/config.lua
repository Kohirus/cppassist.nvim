local M = {}

M.options = {
	goto_header = {
		include_dirs = { ".", "..", "/usr/include", "/usr/local/include", "~" },
		exclude_dirs = {},
		search_flags = "-tf -s",
	},
}

function M.set_options(custom_opts)
	M.options = vim.tbl_deep_extend("force", M.options, custom_opts or {})
end

return M

local fn = vim.fn
local utils = require("cppassist.utils")

local M = {}

-- Return the name of the header file name from the specified line
function M.GetHeaderName(line)
	local line_str = fn.getline(line)
	line_str = string.gsub(line_str, "^%s+", "", 1)
	local exist_inc = string.find(line_str, "^#include%s+")
	if exist_inc ~= nil then
		local idx_start, idx_end = string.find(line_str, '[<"][a-zA-z0-9_%.]+[>"]')
		if idx_start ~= nil and idx_end ~= nil then
			local filename = string.sub(line_str, idx_start + 1, idx_end - 1)
			return filename
		end
	end
	return ""
end

-- Jump to the header file in current line
function M.GotoHeaderFile(options)
	local curline = fn.line(".")
	local filename = M.GetHeaderName(curline)
	if filename ~= "" then
	    local exclude_dirs = options.goto_header.exclude_dirs
	    local include_dirs = options.goto_header.include_dirs
	    local flags = options.goto_header.search_flags
	    local results = utils.SearchFile(flags, filename, exclude_dirs, include_dirs)
	    utils.DisplayOptionalList(results, filename)
	else
		print("Can't find the header file declaration in current line!")
	end
end

return M

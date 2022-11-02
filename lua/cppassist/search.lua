local api = vim.api
local scan = require("plenary.scandir")
local utils = require("cppassist.utils")

local M = {}

function M.FindFile(matching_files, filename, extension, desired_extension)
	for index, value in ipairs(matching_files) do
		local _, matched_filename, matched_extension = utils.SpiltFilename(value)
		if
			(matched_extension == desired_extension and matched_extension ~= extension)
			and filename == matched_filename
		then
			return matching_files[index]
		end
	end
	return ""
end

function M.SearchSourceFile()
	local current_file = api.nvim_eval('expand("%:p")')
	local _, filename, extension = utils.SpiltFilename(current_file)

	--- m.scan_dir
	-- Search directory recursive and syncronous
	-- @param path: string or table
	--   string has to be a valid path
	--   table has to be a array of valid paths
	-- @param opts: table to change behavior
	--   opts.hidden (bool):              if true hidden files will be added
	--   opts.add_dirs (bool):            if true dirs will also be added to the results
	--   opts.only_dirs (bool):           if true only dirs will be added to the results
	--   opts.respect_gitignore (bool):   if true will only add files that are not ignored by the git (uses each gitignore found in path table)
	--   opts.depth (int):                depth on how deep the search should go
	--   opts.search_pattern (regex):     regex for which files will be added, string, table of strings, or callback (should return bool)
	--   opts.on_insert(entry):           Will be called for each element
	--   opts.silent (bool):              if true will not echo messages that are not accessible
	-- @return array with files
	local scan_opts = {
		respect_gitignore = true,
		search_pattern = "^.*" .. filename .. "%..*$",
	}
	local matching_files = scan.scan_dir(".", scan_opts)

	local next = next
	if next(matching_files) ~= nil then
		local desired_extension = nil

		if extension == "cpp" or extension == "hpp" then
			desired_extension = M.Ternary(extension == "cpp", "hpp", "cpp")
		elseif extension == "c" or extension == "h" then
			desired_extension = M.Ternary(extension == "c", "h", "c")
		elseif extension == "cc" then
			desired_extension = "h"
		end

		local found_match = M.FindFile(matching_files, filename, extension, desired_extension)
		if found_match ~= "" then
			return found_match
		end

		if desired_extension == "cpp" or desired_extension == "hpp" then
			desired_extension = M.Ternary(desired_extension == "cpp", "c", "h")
		elseif desired_extension == "c" or desired_extension == "h" then
			desired_extension = M.Ternary(desired_extension == "c", "cpp", "hpp")
		end

		found_match = M.FindFile(matching_files, filename, extension, desired_extension)
		if found_match ~= "" then
			return found_match
		end

		if desired_extension == "c" or desired_extension == "cpp" then
			desired_extension = "cc"
		elseif extension == "cc" then
			desired_extension = "hpp"
		end

		print("Failed to find matching files for " .. filename .. "." .. extension)
	end
	return ""
end

function M.Ternary(condition, T, F)
	if condition then
		return T
	else
		return F
	end
end

return M

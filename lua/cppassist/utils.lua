local fn = vim.fn
local api = vim.api
local cmd = vim.cmd
local scan = require("plenary.scandir")

local M = {}

function M.Ternary(condition, T, F)
	if condition then
		return T
	else
		return F
	end
end

function M.SpiltFilename(file)
	local path, filename, extension = string.match(file, "(.-)([^\\/]-)([^\\/%.]+)$")
	filename = filename:sub(1, -2)
	return path, filename, extension
end

function M.SplitString(inputstr, seq)
	if seq == nil then
		seq = "%s"
	end
	local t = {}
	local i = 1
	for str in string.gmatch(inputstr, "([^" .. seq .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

function M.Find(matching_files, filename, extension, desired_extension, funcstr)
	for index, value in ipairs(matching_files) do
		local path, matched_filename, matched_extension = M.SpiltFilename(value)
		if
			(matched_extension == desired_extension and matched_extension ~= extension)
			and filename == matched_filename
		then
			local command_string = "edit " .. matching_files[index]
			cmd(command_string)
			if funcstr ~= "" then
				local t = M.SplitString(funcstr, "\n")
				for _, j in ipairs(t) do
					fn.append(fn.line("$"), j)
				end
        fn.append(fn.line("$"), " ")
			end
			return true
		end
	end
	return false
end

function M.GetCursorDeclare(isFunc)
	local startline = fn.line(".")
	local endline = fn.search(";")
	local lines = fn.getline(startline, endline)
	local ln = fn.join(lines, "\n")
	ln = string.gsub(ln, "^%s+", "", 1)
	if isFunc then
		ln = string.gsub(ln, "virtual%s+", "", 1)
	else
		ln = string.gsub(ln, "static%s+", "", 1)
	end
	ln = string.gsub(ln, ";", "", 1)

	local class = fn.search("class", "bn")
	class = fn.getline(class)
	if string.len(class) > 0 then
		class = fn.matchlist(class, "class\\s\\+\\([a-zA-Z_]\\+\\)")[1]
		class = string.gsub(class, "class%s+", "", 1)
		local obj = "\\1" .. class .. "::\\2"
		local fname = fn.substitute(ln, "\\([a-zA-Z_%*]\\+\\s\\+\\)*\\(.*\\)", obj, "")
		ln = fname
	end

	return ln
end

function M.GeneratreStaticVarUnderCursor()
	local ln = M.GetCursorDeclare(false)
	-- local data_type = string.match(ln, "([a-zA-Z_%*]+)%s+")
	-- ln = ln .. " = " .. data_type .. "();\n"
	ln = ln .. ";\n"
	return ln
end

function M.GenerateFuncUnderCursor()
	local ln = M.GetCursorDeclare(true)
	local start, _ = string.find(ln, "[%(].*[%)]")
	local sub = string.sub(ln, 1, start)
	local data_type = string.match(sub, "([a-zA-Z_%*]+)%s+")
	-- Constructor/Destructor
	if data_type == nil then
		ln = ln .. " {\n}\n"
	else
		local pointer, _ = string.find(data_type, "%*")
		-- return pointer
		if pointer ~= nil then
			ln = ln .. " {\n\t return NULL;\n}\n"
		-- return void
		elseif data_type == "void" then
			ln = ln .. " {\n}\n"
		else
			ln = ln .. " {\n\treturn " .. data_type .. "();\n}\n"
		end
	end
	return ln
end

function M.AppendSourceFile(funcstr)
	local current_file = api.nvim_eval('expand("%:p")')
	local _, filename, extension = M.SpiltFilename(current_file)

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

		local found_match = M.Find(matching_files, filename, extension, desired_extension, funcstr)
		if found_match then
			return
		end

		if desired_extension == "cpp" or desired_extension == "hpp" then
			desired_extension = M.Ternary(desired_extension == "cpp", "c", "h")
		elseif desired_extension == "c" or desired_extension == "h" then
			desired_extension = M.Ternary(desired_extension == "c", "cpp", "hpp")
		end

		local found_match = M.Find(matching_files, filename, extension, desired_extension, funcstr)
		if found_match then
			return
		end

		if desired_extension == "c" or desired_extension == "cpp" then
			desired_extension = "cc"
		elseif extension == "cc" then
			desired_extension = "hpp"
		end

		print("Failed to find matching files for " .. filename .. "." .. extension)
	end
	return matching_files
end

return M

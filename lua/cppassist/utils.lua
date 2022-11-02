local fn = vim.fn
local cmd = vim.cmd

local M = {}

local fd_exe = vim.g.cppassist_fd_binary_name

-- Display optional list in the command area
-- @param list The table of ptional list
-- @param obj The target file to be searched
-- @param If there is only one in table, it will be displayed directly
function M.DisplayOptionalList(list, obj)
	if #list == 0 then
		print("Couldn't find " .. obj)
	else
		if #list == 1 then
			M.OpenFile(list[1])
		else
			print("Searching for " .. obj .. " ...")
			for idx, val in ipairs(list) do
				print(idx, ": " .. val)
			end
			print("0 : cancel")
			local idx = fn.input("Select the file you want: ")
			if #idx == 0 then
				return
			end
			idx = tonumber(idx)
			if idx > #list then
				print("\nInvalid index : " .. idx)
				return
			elseif idx == 0 then
				return
			else
				M.OpenFile(list[idx])
			end
		end
	end
end

-- Show fd error
function M.ShowFdError(error)
	print("Failed to search file with fd:")
	for _, val in ipairs(error) do
		print(val)
	end
end

-- Use fd to search object file
-- @param flags The flags when using fd
-- @param file_name The name of target file to be searched
-- @param exclude_dirs The table of directories that needs to be excluded when searching for files
-- @param include_dirs The table of directories that needs to be included when searching for files
-- @return The table of the target files
-- @remarks The include_dirs has priority, if found in the first directory, it will return immediately
function M.SearchFile(flags, file_name, exclude_dirs, include_dirs)
	local exclude_cmd = " "
	for _, edir in ipairs(exclude_dirs) do
		exclude_cmd = exclude_cmd .. "--exclude " .. edir .. " "
	end

	local results = {}
	for _, idir in ipairs(include_dirs) do
		local fd_cmd = fd_exe .. " -L " .. flags .. exclude_cmd .. file_name .. " " .. idir
		results = fn.systemlist(fd_cmd)
		if vim.v.shell_error ~= 0 then
			M.ShowFdError(results)
			return {}
		end
		if #results ~= 0 then
			break
		end
	end
	return results
end

-- Separate the path, file name, and file suffix from the full file name
-- @param file: the full file name
-- @return table of information about filename
function M.SpiltFilename(file)
	local path, filename, extension = string.match(file, "(.-)([^\\/]-)([^\\/%.]+)$")
	filename = filename:sub(1, -2)
	return path, filename, extension
end

-- Splits the string with the specified separator
-- @param inputstr: the string need to split
-- @param seq: the specified separator
-- return the split substring
function M.SplitString(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	local i = 1
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

function M.SaveCurFile()
	local command_string = "w"
	cmd(command_string)
end

function M.OpenFile(file)
	if file ~= "" then
		local command_string = "edit " .. file
		cmd(command_string)
	end
end

-- Append the target string to the end of the specified file
function M.AppendFile(file, str)
	M.OpenFile(file)
	if str ~= "" then
		local t = M.SplitString(str, "\n")
		for _, j in ipairs(t) do
			fn.append(fn.line("$"), j)
		end
		fn.append(fn.line("$"), " ")
		M.SaveCurFile()
	end
end

return M

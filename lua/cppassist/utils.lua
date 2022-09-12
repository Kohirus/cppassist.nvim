local fn = vim.fn
local cmd = vim.cmd

local M = {}

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

return M

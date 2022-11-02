---@diagnostic disable: unused-local
local fn = vim.fn

local M = {}

local templatestr = ""
local templatefuncstr = ""
local constexpr = false
local const = false

function M.GenerateInViewMode(opts)
	local startline = fn.line("'<")
	local endline = fn.line("'>")
	local str = ""
	local curline = startline
	while curline <= endline do
		fn.cursor(curline, 1)
		local ignore, new_line = M.NeedIngore(curline)
		if ignore == true and new_line ~= nil then
			curline = new_line
		end
		if ignore == false then
			local funcstr, funcendline = M.GetCursorDeclaration()
			if funcstr ~= "" then
				funcstr = M.ForamtDeclaration(funcstr, opts)
				str = str .. funcstr .. " \n"
			end
			if funcendline ~= curline then
				curline = funcendline
			end
		end
		curline = curline + 1
	end
	return str
end

-- Determine whether the current line is an annotation or an empty line
function M.NeedIngore(ln)
	local str = fn.getline(ln)
	str = string.gsub(str, "^%s+", "", 1)
	-- if it is an empty line
	if str == "" or str == nil then
		return true
	else
		local substr = string.sub(str, 1, 2)
		-- if it has comments
		if substr == "//" then
			return true
		-- Multiline comment
		elseif substr == "/*" then
			local line = ln
			repeat
				line = line + 1
				local cur = fn.getline(line)
			until string.match(cur, "%*/%s*$") ~= nil
			return true, line
		end
		-- if it has some keywords: typedef template class public private protected
		-- =0 =default =delete
		if
			string.match(str, "^public%s*") ~= nil
			or string.match(str, "^private%s*") ~= nil
			or string.match(str, "^protected%s*") ~= nil
			or string.match(str, "^class%s+") ~= nil
			or string.match(str, "^template%s*") ~= nil
			or string.match(str, "^typedef%s+") ~= nil
			or string.match(str, "=%s*delete%s*;") ~= nil
			or string.match(str, "=%s*default%s*;") ~= nil
			or string.match(str, "=%s*0%s*;") ~= nil
		then
			return true
		end
	end
	return false
end

-- Gets the function declaration or variable declaration
-- at the cursor, ending with a semicolon
function M.GetCursorDeclaration()
	local startline = fn.line(".")
	local endline = fn.search(";", "cn", fn.line("$"))
	local lines = fn.getline(startline, endline)
	-- Check whether there is a template function definition at the beginning of the line
	if startline ~= 1 then
		local objline = startline - 1
		templatefuncstr = fn.getline(objline)
		templatefuncstr = string.gsub(templatefuncstr, "^%s+", "", 1)
		local start = string.find(templatefuncstr, "template")
		if start == nil then
			templatefuncstr = ""
		end
	end
	-- remove comments from each line
	for index, curline in ipairs(lines) do
		-- remove comments that begin with the '//'
		local start1 = string.find(curline, "//")
		if start1 ~= nil then
			lines[index] = string.sub(curline, 1, start1 - 1)
		else
			-- remove comments that surround with the '/* */'
			local start2 = string.find(curline, "/%*")
			if start2 ~= nil then
				lines[index] = string.sub(curline, 1, start2 - 1)
			end
		end
	end
	-- put a line break at the end of each line
	local ln = fn.join(lines, "\n")
	return ln, endline
end

-- Get information about a function, and then put it in a defined form
-- return class name, return type, function name, function parameters, keywords
function M.GetFuncDeclarationInfo(funcstr)
	local start1, end1 = string.find(funcstr, "^([a-zA-Z0-9_&:<>%*]+)%s+")
	local start2, end2 = string.find(funcstr, "%([a-zA-Z0-9_&:<>%[%]=%*'\"%.,%s+]*%)")
	local return_type = ""
	if start1 ~= nil then
		return_type = string.sub(funcstr, start1, end1)
	end
	local func_name = ""
	if end1 ~= nil then
		func_name = string.sub(funcstr, end1 + 1, start2 - 1)
	else
		func_name = string.sub(funcstr, 1, start2 - 1)
	end
	local func_param = string.sub(funcstr, start2, end2)
	-- delete the default arguments
	func_param = string.gsub(func_param, "%s*=%s*[a-zA-Z0-9'\"%.]+", "")
	local keywords = string.sub(funcstr, end2 + 1)
	local class = M.GetClassName()
	class = string.gsub(class, "%s+", "")
	return_type = string.gsub(return_type, "%s+", "")
	func_name = string.gsub(func_name, "%s+", "")
	keywords = string.gsub(keywords, "%s+", "")
	return class, return_type, func_name, func_param, keywords
end

-- return class name, data type, variable name, keywords
function M.GenerateVariableDefinition(funcstr)
	local class = M.GetClassName()
	class = string.gsub(class, "%s+", "")
	local str_arr = {}
	local index = 1
	for word in string.gmatch(funcstr, "[a-zA-Z0-9&:_<>%[%]%*]+") do
		str_arr[index] = word
		index = index + 1
	end
	local res = ""
	if #str_arr == 2 then
		res = str_arr[1] .. " " .. class .. "::" .. str_arr[2]
	elseif #str_arr == 3 then
		res = str_arr[1] .. " " .. str_arr[2] .. " " .. class .. "::" .. str_arr[3]
	else
		return ""
	end
	res = res .. ";"
	return res
end

-- Determine the value to return based on the different return types
function M.IdentifyReturnType(return_type, opts)
	local returnstr = ""
	-- Constructor/Destructor
	if return_type == "" then
		returnstr = returnstr .. " {\n \n}\n"
	else
		local pointer, _ = string.find(return_type, "%*")
		-- return pointer
		if pointer ~= nil then
			returnstr = returnstr .. " {\n\t return " .. opts.switch_sh.return_type.pointer .. ";\n}\n"
		-- return void
		elseif return_type == "void" then
			returnstr = returnstr .. " {\n \n}\n"
		elseif return_type == "bool" then
			returnstr = returnstr .. " {\n\treturn " .. opts.switch_sh.return_type.bool .. ";\n}\n"
		elseif string.find(return_type, 'int', 1, true) ~= nil then
			returnstr = returnstr .. " {\n\treturn " .. opts.switch_sh.return_type.int .. ";\n}\n"
		elseif string.find(return_type, 'short', 1, true) ~= nil then
			returnstr = returnstr .. " {\n\treturn " .. opts.switch_sh.return_type.short .. ";\n}\n"
		elseif string.find(return_type, 'long', 1, true) ~= nil then
			returnstr = returnstr .. " {\n\treturn " .. opts.switch_sh.return_type.long .. ";\n}\n"
		elseif string.find(return_type, 'char', 1, true) ~= nil then
			returnstr = returnstr .. " {\n\treturn " .. opts.switch_sh.return_type.char .. ";\n}\n"
		elseif string.find(return_type, 'double', 1, true) ~= nil then
			returnstr = returnstr .. " {\n\treturn " .. opts.switch_sh.return_type.double .. ";\n}\n"
		elseif string.find(return_type, 'float', 1, true) ~= nil then
			returnstr = returnstr .. " {\n\treturn " .. opts.switch_sh.return_type.float .. ";\n}\n"
		else
			returnstr = returnstr .. " {\n\treturn " .. return_type .. "();\n}\n"
		end
	end
	return returnstr
end

-- Identify specific keywords, such as:
-- const, =0, =delete, =default, override, noexcept, final
-- return The first return value is whether the implementation
-- is required and the second return value is the keyword that
-- needs to be added to the tail of the function implementation
function M.IdentifyKeywords(keywords)
	if keywords == "" then
		return true, keywords
	end
	local res = string.find(keywords, "=")
	if res ~= nil then
		print("This function does not need to be implemented!")
		return false, ""
	else
		keywords = string.gsub(keywords, "override%s*", "")
		keywords = string.gsub(keywords, "final%s*", "")
		return true, keywords
	end
end

function M.IsVariable(str)
	local start = string.find(str, "%([a-zA-Z0-9_&:<>%*=,'%.\"%[%]%s+]*%)")
	if start == nil then
		return true
	else
		return false
	end
end

-- Format function declarations to remove leading
-- keywords, leading Spaces, and trailing semicolons
function M.ForamtDeclaration(funcstr, opts)
	funcstr = string.gsub(funcstr, "^%s+", "", 1)
	funcstr = string.gsub(funcstr, ";", " ", 1)
	if M.IsVariable(funcstr) then
		local start = string.find(funcstr, "static")
		if start == nil then
			print("Only support `static` variable!")
			return ""
		else
			funcstr = M.RemoveLeadingKeywords(funcstr)
			funcstr = M.GenerateVariableDefinition(funcstr)
			return funcstr
		end
	else
		funcstr = M.RemoveLeadingKeywords(funcstr)
		local class, return_type, func_name, func_param, keywords = M.GetFuncDeclarationInfo(funcstr)
		local need = true
		need, keywords = M.IdentifyKeywords(keywords)
		if need then
			local bracket = M.IdentifyReturnType(return_type, opts)
			if class == "" then
				funcstr = return_type .. " "
			else
				if return_type == "" then
					funcstr = class .. "::"
				else
					funcstr = return_type .. " " .. class .. "::"
				end
			end
			funcstr = funcstr .. func_name .. func_param .. " " .. keywords .. bracket
			-- Add const keyword
			if const then
				funcstr = "const " .. funcstr
				const = false
			end
			-- Add constexpr keyword
			if constexpr then
				funcstr = "constexpr " .. funcstr
				constexpr = false
			end
			-- Add template headers
			-- Prefer to use function template instead of templates
			if templatefuncstr ~= "" then
				funcstr = templatefuncstr .. "\n" .. funcstr
				templatefuncstr = ""
			elseif templatestr ~= "" then
				funcstr = templatestr .. "\n" .. funcstr
				templatestr = ""
			end
			return funcstr
		else
			return ""
		end
	end
end

function M.GetClassName()
	local class = fn.search("\\Cclass", "bn", 1)
	if class ~= 1 then
		local template = class - 1
		templatestr = fn.getline(template)
		templatestr = string.gsub(templatestr, "%s+", "", 1)
		local start = string.find(templatestr, "template")
		if start == nil then
			templatestr = ""
		end
	end
	class = fn.getline(class)
	if string.len(class) > 0 then
		class = fn.matchlist(class, "class\\s\\+\\([a-zA-Z_]\\+\\)")[1]
		class = string.gsub(class, "^class%s+", "", 1)
		return class
	else
		return ""
	end
end

-- Remove the leading keyword, such as:
-- virtual, static, explicit, friend, constexpr, const, struct
function M.RemoveLeadingKeywords(funcstr)
	funcstr = string.gsub(funcstr, "^static%s+", "", 1)
	funcstr = string.gsub(funcstr, "^virtual%s+", "", 1)
	funcstr = string.gsub(funcstr, "^explicit%s+", "", 1)
	funcstr = string.gsub(funcstr, "^friend%s+", "", 1)
	local res = string.find(funcstr, "^const%s+")
	if res ~= nil then
		const = true
		funcstr = string.gsub(funcstr, "^const%s+", "", 1)
	end
	res = string.find(funcstr, "^constexpr%s+")
	if res ~= nil then
		constexpr = true
		funcstr = string.gsub(funcstr, "^constexpr%s+", "", 1)
	end
	return funcstr
end

return M

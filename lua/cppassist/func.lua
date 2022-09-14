local fn = vim.fn

local M = {}

local templatestr = ""
local constexpr = false

-- Gets the function declaration or variable declaration
-- at the cursor, ending with a semicolon
function M.GetCursorDeclaration()
	local startline = fn.line(".")
	local endline = fn.search(";")
	local lines = fn.getline(startline, endline)
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
	return ln
end

-- Get information about a function, and then put it in a defined form
-- return class name, return type, function name, function parameters, keywords
function M.GetFuncDeclarationInfo(funcstr)
	local start1, end1 = string.find(funcstr, "^([a-zA-Z0-9_&:%*]+)%s+")
	local start2, end2 = string.find(funcstr, "%([a-zA-Z0-9_&:<>=%*,%s+]*%)")
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
	for word in string.gmatch(funcstr, "[a-zA-Z0-9&:_<>%*]+") do
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
function M.IdentifyReturnType(return_type)
	local returnstr = ""
	-- Constructor/Destructor
	if return_type == "" then
		returnstr = returnstr .. " {\n \n}\n"
	else
		local pointer, _ = string.find(return_type, "%*")
		-- return pointer
		if pointer ~= nil then
			returnstr = returnstr .. " {\n\t return NULL;\n}\n"
		-- return void
		elseif return_type == "void" then
			returnstr = returnstr .. " {\n \n}\n"
		elseif return_type == "bool" then
			returnstr = returnstr .. " {\n\treturn false;\n}\n"
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
	local start = string.find(str, "%([a-zA-Z0-9_&:%<>*=,%s+]*%)")
	if start == nil then
		return true
	else
		return false
	end
end

-- Format function declarations to remove leading
-- keywords, leading Spaces, and trailing semicolons
function M.ForamtDeclaration(funcstr)
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
			local bracket = M.IdentifyReturnType(return_type)
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
			-- Add constexpr
			if M.constexpr then
				funcstr = "constexpr " .. funcstr
				M.constexpr = false
			end
			-- Add template headers
			if templatestr ~= "" then
				funcstr = templatestr .. "\n" .. funcstr
				M.templatestr = ""
			end
			return funcstr
		else
			return ""
		end
	end
end

function M.GetClassName()
	local class = fn.search("class", "bn")
	if class ~= 1 then
		local template = class - 1
		templatestr = fn.getline(template)
		local start = string.find(templatestr, "template")
		if start == nil then
			templatestr = ""
		end
	end
	class = fn.getline(class)
	if string.len(class) > 0 then
		class = fn.matchlist(class, "class\\s\\+\\([a-zA-Z_]\\+\\)")[1]
		class = string.gsub(class, "class%s+", "", 1)
		return class
	else
		return ""
	end
end

-- Remove the leading keyword, such as:
-- virtual, static, explicit, friend
function M.RemoveLeadingKeywords(funcstr)
	funcstr = string.gsub(funcstr, "static%s+", "", 1)
	funcstr = string.gsub(funcstr, "virtual%s+", "", 1)
	funcstr = string.gsub(funcstr, "explicit%s+", "", 1)
	funcstr = string.gsub(funcstr, "friend%s+", "", 1)
	local res = string.find(funcstr, "constexpr")
	if res ~= nil then
		M.constexpr = true
		funcstr = string.gsub(funcstr, "constexpr%s+", "", 1)
	end
	return funcstr
end

return M

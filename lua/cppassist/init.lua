local utils = require("cppassist.utils")
local search = require("cppassist.search")
local func = require("cppassist.func")

local M = {}

function M.ImplementInSource()
	local file = search.SearchSourceFile()
	if file ~= "" then
		local funcstr = func.GetCursorDeclaration()
		if funcstr ~= "" then
			funcstr = func.ForamtDeclaration(funcstr)
			utils.OpenFile(file)
			utils.AppendFile(file, funcstr)
		end
	else
		print("Not find the source file!")
	end
end

function M.ImplementOutOfClass()
	local funcstr = func.GetCursorDeclaration()
	if funcstr ~= "" then
		funcstr = func.ForamtDeclaration(funcstr)
		utils.AppendFile("", funcstr)
	end
end

function M.SwitchSourceAndHeader()
	local file = search.SearchSourceFile()
	if file ~= "" then
		utils.OpenFile(file)
	else
		print("Not find the source file!")
	end
end

return M

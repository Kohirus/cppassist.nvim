local utils = require("cppassist.utils")
local search = require("cppassist.search")
local func = require("cppassist.func")

local M = {}

function M.ImplementInSourceInVisualMode()
	local file = search.SearchSourceFile()
	if file ~= "" then
		local startline = vim.fn.line("'<")
		local endline = vim.fn.line("'>")
		local str = ""
		for curline = startline, endline, 1 do
			vim.fn.cursor(curline, 1)
			local ignore = func.NeedIngore(curline)
			if ignore == false then
				local funcstr, funcendline = func.GetCursorDeclaration()
				if funcstr ~= "" then
					funcstr = func.ForamtDeclaration(funcstr)
					str = str .. funcstr
				end
				if funcendline ~= curline then
					curline = funcendline
				end
			end
		end
		if str ~= "" then
			utils.OpenFile(file)
			utils.AppendFile(file, str)
		end
	end
end

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

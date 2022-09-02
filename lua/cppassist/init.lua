local utils = require("cppassist.utils")

local M = {}

function M.CreateFuncDefInSource()
	local funstr = utils.GenerateFuncUnderCursor()
	if funstr == "" then
		print("Failed to implement function definition.")
	else
		utils.AppendSourceFile(funstr)
	end
end

function M.SwitchSourceAndHeader()
	utils.AppendSourceFile("")
end

function M.CreateStaticVarDefInSource()
	local varstr = utils.GeneratreStaticVarUnderCursor()
	if varstr == "" then
		print("Failed to implement static variable definition.")
	else
		utils.AppendSourceFile(varstr)
	end
end

return M

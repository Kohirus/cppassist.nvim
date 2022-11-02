local utils = require("cppassist.utils")
local func = require("cppassist.func")
local header = require("cppassist.header")
local config = require("cppassist.config")

local M = {}

local opts

function M.setup(custom_opts)
	config.set_options(custom_opts)
	opts = require("cppassist.config").options
end

function M.ImplementInSourceInVisualMode()
	local files = utils.SearchPeerFile(opts)
	if files ~= nil then
		local str = func.GenerateInViewMode()
		if str ~= "" then
			local res = utils.DisplayOptionalList(files, "source file")
			if res == true then
				utils.AppendFile(str)
			end
		end
	else
		print("Couldn't find the source file!")
	end
end

function M.ImplementInSource()
	local files = utils.SearchPeerFile(opts)
	if files ~= nil then
		local funcstr = func.GetCursorDeclaration()
		if funcstr ~= "" then
			funcstr = func.ForamtDeclaration(funcstr)
			local res = utils.DisplayOptionalList(files, "source file")
			if res == true then
				utils.AppendFile(funcstr)
			end
		end
	else
		print("Couldn't find the source file!")
	end
end

function M.ImplementOutOfClass()
	local funcstr = func.GetCursorDeclaration()
	if funcstr ~= "" then
		funcstr = func.ForamtDeclaration(funcstr)
		utils.AppendFile(funcstr)
	end
end

function M.SwitchSourceAndHeader()
	local files = utils.SearchPeerFile(opts)
	utils.DisplayOptionalList(files, "source file or header file!")
end

function M.GotoHeaderFile()
	header.GotoHeaderFile(opts)
end

return M

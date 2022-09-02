if exists('g:loaded_nvim_cppassist')
	finish
endif

command! CreateFuncDefInSource lua require("cppassist").CreateFuncDefInSource()

command! SwitchSourceAndHeader lua require("cppassist").SwitchSourceAndHeader()

command! CreateStaticVarDefInSource lua require("cppassist").CreateStaticVarDefInSource()

let g:loaded_nvim_cppassist = 1

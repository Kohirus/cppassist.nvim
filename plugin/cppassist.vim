if exists('g:loaded_nvim_cppassist')
	finish
endif

command! ImplementInSource lua require("cppassist").ImplementInSource()

command! ImplementOutOfClass lua require("cppassist").ImplementOutOfClass()

command! SwitchSourceAndHeader lua require("cppassist").SwitchSourceAndHeader()

let g:loaded_nvim_cppassist = 1

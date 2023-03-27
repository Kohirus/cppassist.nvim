if exists('g:loaded_nvim_cppassist')
	finish
endif
let g:loaded_nvim_cppassist = 1

" check fd binary name (needed because it's called fdfdind on ubuntu)
" Then check if it's installed
if system('which fd')[0] ==# '/'
    let g:cppassist_fd_binary_name = 'fd'
elseif system('which fdfind')[0] ==# '/'
    let g:cppassist_fd_binary_name = 'fdfind'
elseif executable('fd') == 1 && has('win32') == 1
	let g:cppassist_fd_binary_name = 'fd'
else
    echoerr "fd not found, please install it"
    finish
endif

command! ImplementInSource lua require("cppassist").ImplementInSource()

command! ImplementOutOfClass lua require("cppassist").ImplementOutOfClass()

command! SwitchSourceAndHeader lua require("cppassist").SwitchSourceAndHeader()

command! GotoHeaderFile lua require("cppassist").GotoHeaderFile()


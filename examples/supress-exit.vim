let s:barModeInputHistory = ''

function! s:BarMode()
	echom 'INPUT >' g:barModeInput
	echom 'EXIT >' g:barModeExit
	if g:barModeInput ==# '\<Esc>'
		echom 'You cant leave using <Esc>.'
	elseif g:barModeInput ==# 'q'
		let g:barModeExit = 1
	endif
endfunction

call libmodal#Enter('BAR', funcref('s:BarMode'), 1)

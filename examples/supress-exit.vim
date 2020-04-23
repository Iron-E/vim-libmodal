let s:barModeInputHistory = ''

function! s:BarMode()
	if g:barModeInput ==# '\<Esc>'
		echom 'You cant leave using <Esc>.'
	elseif g:barModeInput ==# 'q'
		let g:barModeExit = 1
	endif
endfunction

call libmodal#Enter('BAR', funcref('s:BarMode'), 1)

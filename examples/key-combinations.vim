let s:barModeInputHistory = ''

function! s:ClearHistory(indexToCheck)
	if len(s:barModeInputHistory)-1 >= a:indexToCheck
		let s:barModeInputHistory = ''
	endif
endfunction

function! s:BarMode()
	let s:barModeInputHistory .= g:barModeInput

	if s:barModeInputHistory[0] ==# 'z'
		if s:barModeInputHistory[1] ==# 'f'
			if s:barModeInputHistory[2] ==# 'o'
				echom 'It works!'
				let l:index = 0
			else
				let l:index = 2
			endif
		else
			let l:index = 1
		endif
	else
		let l:index = 0
	endif

	call s:ClearHistory(l:index)
endfunction

call libmodal#Enter('BAR', funcref('s:BarMode'))

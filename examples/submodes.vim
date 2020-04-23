let s:barModeInputHistory = []
let s:barModeRecurse = 0

function! s:ClearHistory(indexToCheck)
	if len(s:barModeInputHistory[s:barModeRecurse])-1 >= a:indexToCheck
		let s:barModeInputHistory[s:barModeRecurse] = ''
	endif
endfunction

function! s:BarMode()
	if len(s:barModeInputHistory) <= s:barModeRecurse+1
		let s:barModeInputHistory = add(s:barModeInputHistory, '')
	endif

	let s:barModeInputHistory[s:barModeRecurse] .= g:bar{s:barModeRecurse}ModeInput

	if s:barModeInputHistory[s:barModeRecurse][0] ==# 'z'
		if s:barModeInputHistory[s:barModeRecurse][1] ==# 'f'
			if s:barModeInputHistory[s:barModeRecurse][2] ==# 'o'
				let s:barModeRecurse += 1
				call libmodal#Enter('BAR' . s:barModeRecurse, funcref('s:BarMode'))
				let s:barModeRecurse -= 1
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

call libmodal#Enter('BAR' . s:barModeRecurse, funcref('s:BarMode'))

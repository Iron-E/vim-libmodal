let s:popupwin = has('popupwin')
let s:floatwin = exists('*nvim_open_win') && exists('*nvim_win_close')


" #  ____       _            _
" # |  _ \ _ __(_)_   ____ _| |_ ___
" # | |_) | '__| \ \ / / _` | __/ _ \
" # |  __/| |  | |\ V / (_| | ||  __/
" # |_|   |_|  |_| \_/ \__,_|\__\___|

function! s:Beep()
	execute "normal \<Esc>"
endfunction

function! s:Contains(list, element)
	return index(a:list, a:element) !=# -1
endfunction

" Takes a list of lists. Each sublist is comprised of a highlight group name
" and a corresponding string to echo.
function! s:Echo(echo_list)
	mode
	for [l:hlgroup, l:string] in a:echo_list
		execute 'echohl ' . l:hlgroup | echon l:string
	endfor
	echohl None
endfunction

" Returns a state that can be used for restoration.
function! s:Init()
	let l:winState = {
	\	'winwidth': &winwidth,
	\	'winheight': &winheight
	\}
	" Minimize winwidth and winheight so that moving around doesn't unexpectedly
	" cause window resizing.
	let &winwidth = max([1, &winminwidth])
	let &winheight = max([1, &winminheight])
	return l:winState
endfunction

" Get try to navigate `comboDict` through the chars in `comboString` and return the result.
function! s:Get(comboDict, comboString) abort
	let l:dictAccess = a:3[0]

	if has_key(a:comboDict, l:dictAccess)
		let l:valType = type(a:comboDict[l:dictAccess])
		if  l:valType == v:t_dict
			return s:Get(
			\	a:comboDict[l:dictAccess], a:3[1:]
			\)
		elseif l:valType == v:t_string
			return a:comboDict[l:dictAccess]
		endif
	endif

	return 0
endfunction

function! s:GetChar() abort
	try
		while 1
			" Get the next character.
			let l:modeInput = getchar()
			" Break condition
			" XXX: this might be broken, you won't know until you test older stuff.
			if !(v:mouse_win < 1 && l:modeInput ==# "\<CursorHold>")
				break
			endif
		endwhile
	catch
		" Tell the outer function to break.
		return 0
	endtry

	" If the user inputs a raw number, convert it back to a string.
	if type(l:modeInput) ==# v:t_number
		let l:modeInput = nr2char(l:modeInput)
	endif

	return l:modeInput
endfunction

" Underlying logic for entering a mode using the global variable to update input.
" a:1 => `modeName` as `l:input`
" a:2 => `modeCallback`
" a:3 => `supressExit`
function! s:LibmodalEnter(...) abort
	" If `supressExit` is off and user inputs escape.
	" This check must be performed AFTER `s:GetChar()` and BEFORE `call a:1()`.
	if (!a:3 && g:{a:1} ==# '')
		return 0
	endif

	" Pass input to calling function.
	call a:2()
	return 1
endfunction

" Underlying logic for entering a mode using pre-defined combos.
" a:1 => `modeName` as `l:input`
" a:2 => `modeCombos`
" a:3 => `supressExit`
function! s:LibmodalEnterWithCombos(...) abort
	if !exists('s:' . a:1 . 'ModeCombos')
		let s:{a:1}ModeCombos = s:NewComboDict(s:SplitArgDict(a:2))
	endif

	if 0
		return 0
		unlet s:{a:1}ModeCombos
	endif

	return 1
endfunction

" Transforms a key combination in the form of:
" >
"     {'<key_combo>': '<execute_string>'}
" <
"
" And turns it into a dict that libmodal can parse.
" >
"     {'k':
"     \    'j' {
"     \         'echo "Hello!"'
"     \    \}
"     \}
" <
" That defines a command for `kj` that echoes "Hello".
function! s:NewComboDict(comboDict, subKeys, keyCommand) abort
	let l:dictAccess = remove(a:subKeys, 0)

	if len(a:subKeys) > 0
		if !has_key(a:comboDict, l:dictAccess)
			let a:comboDict[l:dictAccess] = {}
		endif

		let a:comboDict[l:dictAccess] = s:NewComboDict(
		\	a:comboDict[l:dictAccess], a:subKeys, a:keyCommand
		\)
	else
		let a:comboDict[l:dictAccess] = a:keyCommand
	endif

	return a:comboDict
endfunction

" Change the window to some `state`.
function! s:Restore(state)
	let &winwidth = a:state['winwidth']
	let &winheight = a:state['winheight']
endfunction

" Show some error `message`.
function! s:ShowError(message)
	let l:echo_list = []
	call add(l:echo_list, ['Title', "vim-libmodal error\n"])
	call add(l:echo_list, ['Error', a:message])
	call add(l:echo_list, ['Question', "\n[Press any key to return]"])
	call s:Echo(l:echo_list)
	call s:GetChar()
	redraw | echo ''
endfunction

" Show some warning `messaage`.
function! s:ShowWarning(message)
	let l:echo_list = []
	call add(l:echo_list, ['Title', "vim-libmodal warning\n"])
	call add(l:echo_list, ['Error', a:message])
	call add(l:echo_list, ['Question', "\n[Press any key to return]"])
	call s:Echo(l:echo_list)
	call s:GetChar()
	redraw | echo ''
endfunction

" Function that extracts all of the `keys()` in `a:comboDict` and returns them as a list of character arrays.
function! s:SplitArgDict(comboDict) abort
	" Define containers for the characters of each combo.
	let l:keyChars = []

	" Iterate over the keys of the a:combo dict.
	for l:item in keys(a:comboDict)
		let l:keyChars = add(
		\	keyChars, s:SplitString(a:comboDict[l:item])
		\)
	endfor

	return l:keyChars
endfunction

function s:SplitString(stringToSplit) abort
	let l:charArr = []

	for l:i in range(len(a:stringToSplit))
		let l:charArr = add(l:charArr, a:stringToSplit[l:i])
	endfor
endfunction


" #  ____        _     _ _
" # |  _ \ _   _| |__ | (_) ___
" # | |_) | | | | '_ \| | |/ __|
" # |  __/| |_| | |_) | | | (__
" # |_|    \__,_|_.__/|_|_|\___|

" Runs the vim-libmodal command prompt loop. The function takes an optional
" argument specifying how many times to run (runs until exiting by default).
function! libmodal#Enter(...) abort
	" Define mode indicator
	let l:indicator = [
	\	 ['LibmodalStar', '*'],
	\	 ['None', ' '],
	\	 ['LibmodalPrompt', a:1],
	\	 ['None', ' > ']
	\]
	" Initialize the window state for the mode.
	let l:winState = s:Init()

	" Name of variable used for input.
	let l:input = tolower(a:1) . "ModeInput"

	" If the third argument, representing exit supression, has been passed.
	if len(a:000) > 2
		" Create the variable used to control the exit.
		let l:exit = tolower(a:1) . "ModeExit"
		let g:{l:exit} = 0
	else
		let l:exit = 0
	endif

	" Outer loop to keep accepting commands
	while 1
		try
			" If `supressExit` is on and `modeCallback` has registered the exit variable.
			" This check must be performed BEFORE `s:GetChar()`.
			if (l:exit && g:{l:exit})
				break
			endif

			" Make sure that we are not in a command-line window.
			if &buftype ==# 'nofile' && bufname('%') ==# '[Command Line]'
				call s:Beep()
				call s:ShowError('vim-libmodal does not work with the command-line window')
				break
			endif

			" Print the indicator for the mode.
			call s:Echo(l:indicator)

			" Accept input
			let g:{l:input} = s:GetChar()

			" Only want to run this block once
			if !exists('l:funcExt')
				" If `a:2` is a function
				if type(a:2) == v:t_func
				" If `a:2` is a dictionary
					let l:funcExt = ''
				elseif type(a:2) == v:t_dict
					let l:funcExt = 'WithCombos'
				endif
			endif

			let l:continue = s:LibmodalEnter{l:funcExt}(l:input, a:2, l:exit)
		catch
			call s:Beep()
			let l:message = v:throwpoint . "\n" . v:exception
			call s:ShowError(l:message)
			break
		endtry
	endwhile
	" Put the window back to the way it was before the mode enter.
	call s:Restore(l:winState)
	mode | echo ''
	call garbagecollect()
endfunction

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

" Check vim/nvim version, show corresponding messages, and return a boolean
" indicating whether check succeeded.
function! s:CheckVersion()
	if !has('patch-8.1.1140') && !has('nvim-0.4.0')
		" Vim 8.1.1140 and nvim-0.4.0 updated the libmodalnr function to take a motion
		" character, functionality utilized by vim-libmodal.
		let l:message_lines = [
		\	'vim-libmodal requires vim>=8.1.1140 or nvim>=0.4.0.',
		\	'Use :version to check the current version.'
		\]
		call s:ShowError(join(l:message_lines, "\n"))
		return 0
	endif
	if !s:popupwin && !s:floatwin
		let l:message_lines = [
		\	'Full vim-libmodal functionality requires vim>=8.2 or nvim>=0.4.0.',
		\	'Use :version to check the current version.',
		\	'Set g:libmodal_disable_version_warning = 1 to disable this warning.'
		\]
		call s:ShowWarning(join(l:message_lines, "\n"))
	endif
	return 1
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

function! s:GetChar()
	try
		while 1
			let l:modeInput = getchar()
			if v:mouse_win ># 0 | continue | endif
			if l:modeInput ==# "\<CursorHold>" | continue | endif
			break
		endwhile
	catch
		" E.g., <c-c>
		let l:modeInput = char2nr("\<esc>")
	endtry
	if type(l:modeInput) ==# v:t_number
		let l:modeInput = nr2char(l:modeInput)
	endif
	return l:modeInput
endfunction

" Function that extracts
function! s:GetComboKeys(comboDict) abort
	" Define containers for the characters of each combo.
	let l:keyChars = []

	" Iterate over the keys of the a:combo dict.
	for l:item in keys(a:comboDict)
		let l:charArr = []

		" Grab all the characters in the array.
		for l:i in range(len(a:comboDict[l:item]))
			let l:charArr = add(l:charArr, a:comboDict[l:item][l:i])
		endfor

		let keyChars = add(keyChars, l:charArr)
	endfor

	return l:keyChars
endfunction

function! s:LibmodalEnter(...) abort
	" TODO: define unifying enter function
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

function! s:ParseKeyCombos(testDict, subKeys, keyCommand) abort
	let l:dictAccess = remove(a:subKeys, 0)

	if len(a:subKeys) > 0

		if !has_key(a:testDict, l:dictAccess)
			let a:testDict[l:dictAccess] = {}
		endif

		let a:testDict[l:dictAccess] = s:Test(a:testDict[l:dictAccess], a:subKeys, a:keyCommand)

	else

		let a:testDict[l:dictAccess] = a:keyCommand

	endif

	return a:testDict
endfunction

function! s:Restore(state)
	let &winwidth = a:state['winwidth']
	let &winheight = a:state['winheight']
endfunction

function! s:ShowError(message)
	let l:echo_list = []
	call add(l:echo_list, ['Title', "vim-libmodal error\n"])
	call add(l:echo_list, ['Error', a:message])
	call add(l:echo_list, ['Question', "\n[Press any key to return]"])
	call s:Echo(l:echo_list)
	call s:GetChar()
	redraw | echo ''
endfunction

function! s:ShowWarning(message)
	let l:echo_list = []
	call add(l:echo_list, ['Title', "vim-libmodal warning\n"])
	call add(l:echo_list, ['Error', a:message])
	call add(l:echo_list, ['Question', "\n[Press any key to return]"])
	call s:Echo(l:echo_list)
	call s:GetChar()
	redraw | echo ''
endfunction

" #  ____        _     _ _
" # |  _ \ _   _| |__ | (_) ___
" # | |_) | | | | '_ \| | |/ __|
" # |  __/| |_| | |_) | | | (__
" # |_|    \__,_|_.__/|_|_|\___|

" Runs the vim-libmodal command prompt loop. The function takes an optional
" argument specifying how many times to run (runs until exiting by default).
function! libmodal#Enter(...) abort
	if !s:CheckVersion() | return | endif
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
	endif

	" Outer loop to keep accepting commands
	while 1
		try
			" If `supressExit` is on and `modeCallback` has registered the exit variable.
			" This check must be performed BEFORE `s:GetChar()`.
			if (exists('l:exit') && g:{l:exit})
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

			" If `supressExit` is off and user inputs escape.
			" This check must be performed AFTER `s:GetChar()` and BEFORE `call a:2()`.
			if (!exists('l:exit') && g:{l:input} ==# '')
				break
			endif

			" Pass input to calling function.
			call a:2()
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
endfunction

function! libmodal#EnterWithCombos(...) abort

endfunction

" Transforms a key combination in the form of:
" >
"     {'<key_combo>': '<execute_string>'}
" <
"
" And turns it into a dict that libmodal can parse.
function! libmodal#Parse(comboDict) abort
	" The keys of the `a:comboDict`.
	let l:comboDictKeys = keys(a:comboDict)
	" The keys of the `a:comboDict` separated into character arrays.
	let l:separatedCombos = s:GetComboKeys(a:comboDict)
	" A placeholder for the transformed dictionary.
	let l:compatableComboDict = {}

	" Iterate over the `l:separatedCombos`
	for l:i in range(len(l:separatedCombos))
		" Get the command for this combo
		let l:comboCommand = l:comboDict[l:comboDictKeys[l:i]]

		" Update the `l:compatableComboDict` to include the transformed sub-array of `l:separatedCombos`.
		let l:compatableComboDict = s:ParseKeyCombos(
		\	l:compatableComboDict, l:separatedCombos[i], l:comboCommand
		\)
	endfor

	" Return the compatable combo dictionary.
	return l:compatableComboDict
endfunction

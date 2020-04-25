let s:FALSE = 0
let s:replacements = ['\.', ':', '(', ')', '{', '}', '[', ']', '+', '\*', '&', '\^', '%', '\$', ',', '@', '\!', '/', '?', '>', '<', '\\', '=']
let s:TRUE = 1

" #  ____       _            _
" # |  _ \ _ __(_)_   ____ _| |_ ___
" # | |_) | '__| \ \ / / _` | __/ _ \
" # |  __/| |  | |\ V / (_| | ||  __/
" # |_|   |_|  |_| \_/ \__,_|\__\___|

" SUMMARY:
" Make vim beep at the user.
function! s:Beep()
	execute "normal \<Esc>"
endfunction

" SUMMARY:
" * Return whether or not the `list` contains `element`.
" PARAMS:
" * `list` => the list to search in.
" * `element` => the element to search for.
" RETURNS:
" * `0` => `list` does not contain `element`.
" * `1` => `list` contains `element`.
function! s:Contains(list, element)
	return index(a:list, a:element) !=# -1
endfunction

" SUMMARY:
" * Takes a list of lists. Each sublist is comprised of a highlight group name
"   and a corresponding string to echo.
" PARAMS:
" * `echo_list` => the list of strings to echo.
function! s:Echo(echo_list)
	mode
	echo s:Highlight(a:echo_list)
endfunction

" SUMMARY:
" * Takes a list of lists. Each sublist is comprised of a highlight group name
"   and a corresponding string to highlight.
" PARAMS:
" * `echo_list` => the list of strings to highlight.
" RETURNS:
" * The highlighted `hl_list` as one string.
function! s:Highlight(hl_list)
	let l:text = ''
	for [l:hlgroup, l:string] in a:hl_list
		let l:text .= execute('echohl ' . l:hlgroup . ' | echon ' . l:string)
	endfor
	return l:text
endfunction

" SUMMARY:
" Get a state that can be used for restoration.
" RETURNS:
" The state currently represented by the window layout.
function! s:Init() abort
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

function! s:IsNum(var, num) abort
	return type(a:var) == v:t_number && a:var == a:num
endfunction

" SUMMARY:
" Get try to navigate `comboDict` through the chars in `comboString` and return the result.
" PARAMS:
" * `comboDict` => The parsed dictionary of combos.
" * `comboString` => the string that describes a list of characters to enter.
" RETURNS:
" * A command to run when `comboString` fully describes a combo in `comboDict`.
" * `-1` => `comboString` is not ANYWHERE in the dict.
" * `0` => `comboString` partially describes a combo in `comboDict.`
function! s:Get(comboDict, comboString) abort
	" Get the next character in the combo string.
	let l:comboChar = a:comboString[0]

	" Make sure the dicitonary has a key for that value.
	if has_key(a:comboDict, l:comboChar)
		let l:valType = type(a:comboDict[l:comboChar])

		if  l:valType == v:t_dict
			return s:Get(
			\	a:comboDict[l:comboChar], a:comboString[1:]
			\)
		elseif l:valType == v:t_string && len(a:comboString) <= 1
			return a:comboDict[l:comboChar]
		endif
	elseif a:comboString == ''
		return 0
	endif
	return -1
endfunction

" SUMMARY:
" * Get input from the user.
" RETURNS:
" * The input from the user.
" * `0` => there is no valid input.
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

" SUMMARY:
" * Underlying logic for entering a mode using pre-defined combos.
" PARAMS:
" * a:1 => `modeName` as `l:input`
" * a:2 => `modeCombos`
" RETURNS:
" * `0` => the calling function should break.
" * `1` => the calling function should continue.
function! s:LibmodalEnterWithCombos(modeName, modeCombos) abort
	" Initialize variables necessary to execute combo modes.
	if !exists('s:' . a:modeName . 'ModeCombos')

		" Build a pseudo-parse-tree.
		let s:{a:modeName}ModeCombos = {}
		for l:splitCombos in s:SplitArgDict(a:modeCombos)
			let s:{a:modeName}ModeCombos = s:NewComboDict(
			\	s:{a:modeName}ModeCombos, l:splitCombos, a:modeCombos[join(l:splitCombos, '')]
			\)
		endfor

		" Initialize the input history variable.
		let s:{a:modeName}ModeInput = ''
	endif

	" Append latest input to history.
	let s:{a:modeName}ModeInput .= g:{a:modeName}ModeInput

	" Try to grab the command for the input.
	let l:command = s:Get(s:{a:modeName}ModeCombos, s:{a:modeName}ModeInput)

	" Read the 'RETURNS' section of `s:Get()`.
	if type(l:command) == v:t_number
		if l:command < 0 | let l:clearInput = 1 | endif
	else
		execute l:command
		let l:clearInput = 1
	endif

	if exists('l:clearInput') | let s:{a:modeName}ModeInput = '' | endif
endfunction

" SUMMARY:
" * Transforms a `comboDict` into a pseudo-parse-tree.
" PARAMS:
" * `comboDict` => The user's `comboDict`.
" * `splitCombos` => The combo split into chars.
" * `keyCommand` => The command to map `splitCombos` to.
" RETURNS:
" * The existing `comboDict` as a pseudo-parse-tree.
" EXAMPLE:
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
function! s:NewComboDict(comboDict, splitCombos, keyCommand) abort
	let l:comboChar = remove(a:splitCombos, 0)

	if len(a:splitCombos) > 0
		if !has_key(a:comboDict, l:comboChar)
			let a:comboDict[l:comboChar] = {}
		endif

		let a:comboDict[l:comboChar] = s:NewComboDict(
		\	a:comboDict[l:comboChar], a:splitCombos, a:keyCommand
		\)
	else
		let a:comboDict[l:comboChar] = a:keyCommand
	endif

	return a:comboDict
endfunction

function! s:NewIndicator(modeName) abort
	return [
	\	 ['LibmodalStar', '*'],
	\	 ['None', ' '],
	\	 ['LibmodalPrompt', a:modeName],
	\	 ['None', ' > ']
	\]
endfunction

" SUMMARY:
" * Change the window to some `state`.
" PARAMS:
" * `state` => The previous layout of the windows.
function! s:Restore(state)
	let &winwidth = a:state['winwidth']
	let &winheight = a:state['winheight']
endfunction

" SUMMARY:
" * Show some error `message`.
" PARAMS:
" * `message` => The error to show.
function! s:ShowError(message)
	let l:echo_list = []
	call add(l:echo_list, ['Title', "vim-libmodal error\n"])
	call add(l:echo_list, ['Error', a:message])
	call add(l:echo_list, ['Question', "\n[Press any key to return]"])
	call s:Echo(l:echo_list)
	call s:GetChar()
	redraw | echo ''
endfunction

" SUMMARY:
" * Show some warning `messaage`.
" PARAMS:
" * `message` => The warning to show.
function! s:ShowWarning(message)
	let l:echo_list = []
	call add(l:echo_list, ['Title', "vim-libmodal warning\n"])
	call add(l:echo_list, ['Error', a:message])
	call add(l:echo_list, ['Question', "\n[Press any key to return]"])
	call s:Echo(l:echo_list)
	call s:GetChar()
	redraw | echo ''
endfunction

" SUMMARY:
" * Function that extracts all of the `keys()` in `a:comboDict` and returns them as a list of character arrays.
" PARAMS:
" * `comboDict` => the user-defined dictionary to transform into a list of split strings.
" RETURNS:
" * The list of combos as character arrays.
function! s:SplitArgDict(comboDict) abort
	" Define containers for the characters of each combo.
	let l:keyChars = []

	" Iterate over the keys of the a:combo dict.
	for l:item in keys(a:comboDict)
		let l:keyChars = add(
		\	keyChars, s:SplitString(l:item)
		\)
	endfor

	return l:keyChars
endfunction

" SUMMARY:
" * Split some `stringToSplit` into individual characters.
" PARAMS:
" * `stringToSplit` => the string to split
" RETURNS:
" * The character array made from `stringToSplit`.
function s:SplitString(stringToSplit) abort
	let l:charArr = []

	for l:i in range(len(a:stringToSplit))
		let l:charArr = add(l:charArr, a:stringToSplit[l:i])
	endfor

	return l:charArr
endfunction

" SUMMARY:
" * Check if a variable is set to 1 or not.
" PARAMS:
" * `var` => The variable whose value should be checked.
" RETURNS:
" * Whether or not `var` is set to `1`.
function! s:True(var)
	return s:IsNum(a:var, s:TRUE)
endfunction

" SUMMARY:
" * Check if a variable is set to 0 or not.
" PARAMS:
" * `var` => The variable whose value should be checked.
" RETURNS:
" * Whether or not `var` is set to `0`.
function! s:Zero(var)
	return s:IsNum(a:var, s:FALSE)
endfunction

" #  ____        _     _ _
" # |  _ \ _   _| |__ | (_) ___
" # | |_) | | | | '_ \| | |/ __|
" # |  __/| |_| | |_) | | | (__
" # |_|    \__,_|_.__/|_|_|\___|

" SUMMARY:
" * Runs the vim-libmodal command prompt loop. The function takes an optional
"   argument specifying how many times to run (runs until exiting by default).
" PARAMS:
" * `a:1` => `modeName`
" * `a:2` => `modeCallback` OR `modeCombos` OR `modeCommands`
" * `a:3` => `supressExit`
" * `a:4` => `prompt`
function! libmodal#Enter(...) abort
	" Define mode indicator
	let l:indicator = s:NewIndicator(a:1)

	" Initialize the window state for the mode.
	let l:winState = s:Init()

	" Name of variable used for input.
	let l:input = tolower(a:1) . "ModeInput"

	" If the third argument, representing exit supression, has been passed.
	if len(a:000) > 2 && s:True(a:3)

		" Create the variable used to control the exit.
		let l:exit = tolower(a:1) . "ModeExit"
		let g:{l:exit} = 0

	else

		let l:exit = 0

	endif

	let l:showPrompt = len(a:000) > 3 && s:True(a:4)

	" Create a completion function if there are preset commands.
	if s:True(l:showPrompt)
		function! a:2.provideCompletions(ArgLead,CmdLine,CursorPos) abort
			let l:arglead = a:ArgLead
			for l:replacement in s:replacements
				let l:arglead = substitute(l:arglead, l:replacement, ' ', 'g')
			endfor

			let l:word = split(l:arglead)[-1]

			let l:completions = []
			for l:command in keys(self)
				if stridx(l:completion, l:word) > -1
					let l:completions = add(l:completions, l:command)
				endif
			endfor

			return l:completions
		endfunction
	endif


	" Outer loop to keep accepting commands
	while 1
		try
			" This check must be performed BEFORE `s:GetChar()`.
			" If `supressExit` is on and `modeCallback` has registered the exit variable.
			if !( s:Zero(l:exit) || s:Zero(g:{l:exit}) ) | break | endif

			" Make sure that we are not in a command-line window.
			if &buftype ==# 'nofile' && bufname('%') ==# '[Command Line]'

				call s:Beep()
				call s:ShowError('vim-libmodal does not work with the command-line window')
				break

			endif

			if s:True(l:showPrompt)

				" Prompt the user.
				if type(a:2) == v:t_func
					let g:{l:input} = input( s:Highlight(l:indicator) )
				elseif type(a:2) == v:t_dict
					let g:{l:input} = input( s:Highlight(l:indicator), '', 'customlist,a:2.provideCompletions' )
				endif

			else

				" Print the indicator for the mode.
				call s:Echo(l:indicator)
				" Accept input
				let g:{l:input} = s:GetChar()

			endif

			" If `supressExit` is off and user inputs escape.
			" This check must be performed AFTER `s:GetChar()` and BEFORE `call a:1()`.
			if s:Zero(g:{l:input}) || (s:Zero(l:exit) && g:{l:input} ==# '')
				break
			endif

			" If `a:2` is a function
			if type(a:2) == v:t_func | call a:2()

			" If `a:2` is a dictionary
			elseif type(a:2) == v:t_dict

				if s:True(l:showPrompt)

					if has_key(a:2, g:{l:input})
						execute a:2[g:{l:input}]
					else
						s:ShowError('Unknown command.')
					endif

				else | call s:LibmodalEnterWithCombos(tolower(a:1), a:2)

				endif

			else | break

			endif

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

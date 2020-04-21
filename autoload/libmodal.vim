let s:popupwin = has('popupwin')
let s:floatwin = exists('*nvim_open_win') && exists('*nvim_win_close')

function! s:Contains(list, element)
	return index(a:list, a:element) !=# -1
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

" Takes a list of lists. Each sublist is comprised of a highlight group name
" and a corresponding string to echo.
function! s:Echo(echo_list)
	redraw
	for [l:hlgroup, l:string] in a:echo_list
		execute 'echohl ' .  l:hlgroup | echon l:string
	endfor
	echohl None
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

function! s:Restore(state)
	let &winwidth = a:state['winwidth']
	let &winheight = a:state['winheight']
endfunction

" Runs the vim-libmodal command prompt loop. The function takes an optional
" argument specifying how many times to run (runs until exiting by default).
function! libmodal#Enter(modeName, modeFunc)
	if !s:CheckVersion() | return | endif
	" Define mode indicator
	let l:indicator = [
	\	 ['LibmodalStar', '*'],
	\	 ['None', ' '],
	\	 ['LibmodalPrompt', a:modeName],
	\	 ['None', ' >']
	\]
	" Initialize the window state for the mode.
	let l:winState = s:Init()
	" Outer loop to keep accepting commands
	while 1
		try
			" Make sure that we are not in a command-line window.
			if &buftype ==# 'nofile' && bufname('%') ==# '[Command Line]'
				call s:Beep()
				call s:ShowError('vim-libmodal does not work with the command-line window')
				break
			endif

			" Print the indicator for the mode.
			call s:Echo(l:indicator)

			" Accept input
			let l:modeInput = s:GetChar()

			" Break on <Esc>
			if l:modeInput ==# "\<Esc>"
				break
			else
				" Pass input to calling function.
				call a:modeFunc(l:modeInput)
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
	redraw | echo ''
endfunction

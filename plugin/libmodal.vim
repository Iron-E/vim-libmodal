if exists('g:loaded_libmodal')
	finish
endif
let g:loaded_libmodal = 1

let s:save_cpo = &cpo
set cpo&vim

" ************************************************************
" * User Configuration
" ************************************************************

" The default highlight groups (for colors) are specified below.
" Change these default colors by defining or linking the corresponding highlight group.
highlight default link LibmodalPrompt ModeMsg
highlight default link LibmodalStar StatusLine

let &cpo = s:save_cpo
unlet s:save_cpo

if exists('g:loaded_tabmode')
	finish
endif
let g:loaded_tabmode = 1

let s:save_cpo = &cpo
set cpo&vim

if !hasmapto('<Plug>TabmodeEnter')
	silent! map <unique> <leader><Tab> <Plug>TabmodeEnter
endif
noremap <unique> <silent> <script> <Plug>TabmodeEnter <SID>Tabmode
noremap <SID>Tabmode :<C-u>call tabmode#Enter()<CR>

if !exists(':TabmodeEnter')
	command -nargs=* TabmodeEnter :call tabmode#Enter(<f-args>)
endif

" ************************************************************
" * User Configuration
" ************************************************************

" The default highlight groups (for colors) are specified below.
" Change these default colors by defining or linking the corresponding
" highlight group.
" E.g., the follotabmodeg will use the Error highlight for the active tabmodedow.
" :highlight link TabmodeActive Error
" E.g., the follotabmodeg will use custom highlight colors for the inactive tabmodedows.
" :highlight TabmodeInactive term=bold ctermfg=12 ctermbg=159 guifg=Blue guibg=LightCyan
highlight default link TabmodeActive DiffAdd
highlight default link TabmodeInactive Todo
highlight default link TabmodeNeighbor Todo
highlight default link TabmodeStar StatusLine
highlight default link TabmodePrompt ModeMsg

let &cpo = s:save_cpo
unlet s:save_cpo

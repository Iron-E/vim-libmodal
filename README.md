# Description

* __Forked From:__ [vim-win](https://github.com/dstein64/vim-win)
* __Original Author:__ [Daniel Steinberg](https://www.dannyadam.com)

`vim-libmodal` is a Neo/vim library/plugin aimed at simplifying the creation of new "modes" (e.g. Insert, Normal).

The entrance of modes is user-defined, and their exit is defaults to `<Esc>`. The function and name of modes is also user-defined, and is outlined in the documentation.

# Installation

Use `packadd` or one of the many package managers:

| Manager   | Command                                                   |
|:---------:|:---------------------------------------------------------|
| dein.vim  | `call dein#add('https://github.com/Iron_E/vim-libmodal')` |
| NeoBundle | `NeoBundle 'https://github.com/Iron_E/vim-libmodal'`      |
| Vim-Plug  | `Plug 'https://github.com/Iron_E/vim-libmodal'`           |
| Vundle    | `Plugin 'https://github.com/Iron_E/vim-libmodal'`         |

# Usage

For an example of a plugin that uses `vim-libmodal`, see [vim-tabmode](https://github.com/Iron-E/vim-tabmode).

## `libmodal#Enter`

`libmodal#Enter` takes two arguments: `modeName` and `modeCallback`.

| Arg            | Index | Use                                                          |
|:--------------:|:-----:|:-------------------------------------------------------------|
| `modeName`     | 0     | The name for the mode when prompting the user.               |
| `modeCallback` | 1     | The function used to control the mode. Takes one char param. |
| `supressExit`  | 2     | Whether or not to leave the mode on (`<Esc>`).               |

## Receiving Input

When a user of `libmodal` calls `libmodal#Enter`, the `modeName` parameter is used to generate a __unique global variable__ for the specific purpose of receiving said input. The variable is generated as follows:

```viml
let g:{tolower(a:modeName)}ModeInput = …
```

For example, if `modeName` is 'FOO', then the variable that is created is `g:fooModeInput`.

## Creating Modes

To define a new mode, you must first create a function to pass into `libmodal#Enter`. Example:

```viml
function! s:FooMode()
	if g:fooModeInput ==# "a"
		execute 'tabnew'
	elseif g:fooModeInput ==# "d"
		execute 'tabclose'
	endif
endfunction
```

After defining said function, you can create a mapping to enter the mode. Be sure to use `<expr>`. Example:

```viml
command! FooModeEnter call libmodal#Enter('FOO', funcref('s:FooMode'))
nnoremap <expr> <leader>n FooModeEnter
```

__Note the `funcref`__. It is important that it be present, else the call to `libmodal#Enter` will fail.

## Supressing Exit

When the `supressExit` parameter is specified, `libmodal#Enter` will ignore `<Esc>` presses and instead listen for changes to a unique variable created for the specific purpose of exiting the mode.

The variable is generated as follows:

```viml
let g:{tolower(a:modeName)}ModeExit = 0
```

When this variable becomes set to `1`, the mode will exit the next time that the `modeCallback` function returns.

## Key Combinations

Although `libmodal` will overwrite your mode's unique variable with each key press from a user, a `modeCallback` function can track previous keypresses in order to determine what action should be taken.

Here is an example that shows how to perform an action if the user presses `zfo`:

```viml
" Define history variable
let s:barModeInputHistory = ''

" Create function to conditionally clear history.
function! s:ClearHistory(indexToCheck)
	" Only clear if there was actually enough input
	"     to reach the index specified.
	if len(s:barModeInputHistory)-1 >= a:indexToCheck
		let s:barModeInputHistory = ''
	endif
endfunction

" Define mode function
function! s:BarMode()
	" Concatenate history string with input
	let s:barModeInputHistory .= g:barModeInput

	" Perform actions based on the history.
	if s:barModeInputHistory[0] ==# 'z'
		" Check if there are characters at index '1'.
		if s:barModeInputHistory[1] ==# 'f'
			" Check if there are characters at index '2'.
			if s:barModeInputHistory[2] ==# 'o'
				echom 'It works!'
				let l:index = 0
			" Clear the history if a character was provided at index
			"     '2' and it does not match any previous cases.
			else
				let l:index = 2
			endif

		" Clear the history if a character was provided at index '1'
		"     and it does not match any previous cases.
		else
			let l:index = 1
		endif
	else
		let l:index = 0
	endif

	call s:ClearHistory(l:index)
endfunction
```

And then to enter that mode, you can call:

```viml
libmodal#Enter('BAR', funcref('s:BarMode'))
```

Note that any approach will work for tracking the history of input— this is just an example. Because `libmodal` accepts a function as a parameter, its limitations are few.

## Submodes

`libmodal` has built-in support for entering additional modes while already in a `libmodal` mode.

To enter another mode, one must only call `libmodal#Enter` from within a `modeCallback`. Additionally, when a user presses `<Esc>` they will automatically be taken back to the mode that they were previously inside of.

To display this feature, one may alter the `echom 'It works!'` line from the above example, and change it to the following:

```viml
call libmodal#Enter('BAR2', funcref('s:BarMode'))
```

This will trigger `libmodal#Enter` to start a new mode called 'BAR2'. When the user presses `<Esc>`, they will automatically be returned to 'BAR'.

# Configuration

The following highlight groups can be configured to change the mode's colors:

| Name             | Default      | Description                         |
|:----------------:|:------------:|:-----------------------------------|
| `LibmodalPrompt` | `ModeMsg`    | Color for the mode text.            |
| `LibmodalStar`   | `StatusLine` | Color for the `*` at the beginning. |

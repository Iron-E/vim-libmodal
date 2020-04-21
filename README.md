# Description

__Forked From:__ [vim-win](https://github.com/dstein64/vim-win)
__Original Author:__ [Daniel Steinberg](https://www.dannyadam.com)

`vim-libmodal` is a Neo/vim library/plugin aimed at simplifying the creation of new "modes" (e.g. Insert, Normal).

The entrance of modes is user-defined, and their exit is set to `<Esc>`. The function and name of modes is also user-defined, and is outlined in the documentation.

# Requirements

* `vim>=8.2` or `nvim>=0.4.0`

# Installation

Use `packadd` or one of the many package managers:

| Manager   | Command                                                   |
|:---------:|:---------------------------------------------------------:|
| dein.vim  | `call dein#add('https://github.com/Iron_E/vim-libmodal')` |
| NeoBundle | `NeoBundle 'https://github.com/Iron_E/vim-libmodal'`      |
| Vim-Plug  | `Plug 'https://github.com/Iron_E/vim-libmodal'`           |
| Vundle    | `Plugin 'https://github.com/Iron_E/vim-libmodal'`         |

# Usage

## `libmodal#Enter`

`libmodal#Enter` takes two arguments: `modeName` and `modeFunc`.

| Arg        | Use                                                          |
|:----------:|:------------------------------------------------------------:|
| `modeName` | The name for the mode when prompting the user.               |
| `modeFunc` | The function used to control the mode. Takes one char param. |

## `g:modalInput`

As `libmodal#Enter` accepts input from a user, it updates `g:modalInput` with the latest character entered.

Functions may reference this variable to determine what action to take when a user presses a button.

## Creating Modes

To define a new mode, you must first create a function to pass into `libmodal#Enter`. Example:

```viml
function! s:MyNewMode()
	if g:libmodalInput ==# "a"
		execute 'tabnew'
	elsif g:libmodalInput ==# "d"
		execute 'tabclose'
	endif
endfunction
```

After defining said function, you can create a mapping to enter the mode. Be sure to use `<expr>`. Example:

```viml
nnoremap <expr> <leader>m libmodal#Enter("MyNewModeName", s:MyNewMode())
```

# Configuration

The following highlight groups can be configured to change the mode's colors:

| Name             | Default      | Description                         |
|:----------------:|:------------:|:-----------------------------------:|
| `LibmodalPrompt` | `ModeMsg`    | Color for the mode text.            |
| `LibmodalStar`   | `StatusLine` | Color for the `*` at the beginning. |

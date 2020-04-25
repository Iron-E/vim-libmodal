# Description

* __Forked From:__ [vim-win](https://github.com/dstein64/vim-win)
* __Original Author:__ [Daniel Steinberg](https://www.dannyadam.com)

`vim-libmodal` is a Neo/vim library/plugin aimed at simplifying the creation of new "modes" (e.g. Insert, Normal).

The entrance of modes is user-defined, and their exit defaults to `<Esc>`. The function and name of modes is also user-defined, and is outlined in the documentation.

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

| Arg            | Index | Use                                            |
|:--------------:|:-----:|:-----------------------------------------------|
| `modeName`     | 0     | The name for the mode when prompting the user. |
| `modeCallback` | 1     | The function used to control the mode.         |
| `supressExit`  | 2     | Whether or not to leave the mode on (`<Esc>`). |

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

While normally `libmodal` dictates that a user should define their own function for controlling a mode, there is a way to specify key combinations. If the second argument is set to a `modeCombos` dictionary, `libmodal#Enter` will automatically detect the caller's intent and pass control over to an auxilliary function built to handle pre-defined combos.

When providing `modeCombos`, it is important to note that one no longer has to receive input for themselves. Despite this, the unique variable (see `libmodal-receiving-input`) is still updated, and you can create a listener for it just like for any other variable. Note that one may still supress exit (see `libmodal-supressing-exit`) while defining key combinations.

Here is an example that shows how to create a dictionary that defines the following actions:

| Combo | Action                            |
|:-----:|:----------------------------------|
| `zfo` | Echo a message saying "It works!" |
| `zfc` | Create a new tab.                 |

```viml
let s:barModeCombos = {
\	'zfo': 'echom "It works!"',
\	'zfc': 'tabnew'
\}
```

And then to enter that mode, you can call:

```viml
call libmodal#Enter('BAR', s:barModeCombos)
```

`libmodal`'s internal processing of that dictionary becomes more useful the larger the dictionary is. Internally, `s:barModeCombos` is rendered into a dictionary that looks like this:

```viml
let s:barModeCombosInternal = {
\	'z': {
\		'f': {
\			'c': 'echom "It works!"',
\			'o': 'tabnew'
\		}
\	}
\}
```

This allows `libmodal` to quickly determine which mappings are and are not part of the mode. Because of this method, modes with mappings that have similar beginnings are more efficient, and modes with more mappings get more benefit from the quick tree-like traversal.

Note that `libmodal#Enter` will only parse a `modeCombos` dict once upon entrance, so changes to the mapping dictionary that may occur while in a mode are not reflected until the mode is entered again and the dictionary is re-parsed.

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

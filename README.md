# About

`vim-libmodal`:

- Author: Iron-E
	- [GitHub](https://github.com/Iron-E)
	- [GitLab](https://gitlab.com/Iron_E)

Forked from [`vim-win`](https://github.com/dstein64/vim-win):

- Author: [Daniel Steinberg](https://www.dannyadam.com)

`libmodal` is a Neo/vim library/plugin aimed at simplifying the creation of new "modes" (e.g. Insert, Normal). The entrance of modes is user-defined, and their exit defaults to `<Esc>`. The function and name of modes is also user-defined, and is outlined in `libmodal-usage`.

# Installation

Use the built-in package manager or one of the various package managers.

| Manager   | Command                                                   |
|:----------|:----------------------------------------------------------|
| dein.vim  | `call dein#add('https://github.com/Iron-E/vim-libmodal')` |
| NeoBundle | `NeoBundle 'https://github.com/Iron-E/vim-libmodal'`      |
| Vim-Plug  | `Plug 'https://github.com/Iron-E/vim-libmodal'`           |
| Vundle    | `Plugin 'https://github.com/Iron-E/vim-libmodal'`         |

# Usage

## Commands

### `libmodal#Enter`

`libmodal#Enter` takes three parameters. These parameters are not formally named by the editor (as `libmodal#Enter` is declared `libmodal#Enter(...)` ). However, the names of these parameters will be used throughout the document to describe the index of the parameter (see `E740`).

| Arg            | Index | Use                                            |
|:---------------|:-----:|:-----------------------------------------------|
| `modeName`     | 0     | The name for the mode when prompting the user. |
| `modeCallback` | 1     | The function used to control the mode.         |
| `modeCombos`   | 1     | A dictionary of `libmodal-key-combinations`.   |
| `supressExit`  | 2     | A flag to enable `libmodal-exit-supression`.   |

- Note that _either_ `modeCallback` _or_ `modeCombos` may be specified, __not both__.

### `libmodal#Prompt`

`libmodal#Prompt` takes two parameters. These parameters are not formally named by the editor (as `libmodal#Prompt` is declared `libmodal#Prompt(...)` ). However, the names of these parameters will be used throughout the document to describe the index of the parameter (see `E740`).

| Arg            | Index | Use                                            |
|:---------------|:-----:|:-----------------------------------------------|
| `modeName`     | 0     | The name for the mode when prompting the user. |
| `modeCallback` | 1     | The function used to control the mode.         |
| `modeCommands` | 1     | A dictionary of commands→strings to execute.   |
| `commandList`  | 2     | A list of the commands in a `modeCallback`.    |

- Note that _either_ `modeCallback` _or_ `modeCommands` may be specified, __not both__.
- Note that `commandList` is an optional parameter.
	- It is used as a completion source for when `modeCallback` is specified.
	- Additionally, `commandList` is __ignored__ when `modeCommands` is specified since completions can be created from the dictionary keys.
	- If `commandList` is not specified when `modeCallback` is, no completions will be provided for the prompt.

## Receiving Input

When a user of `libmodal` calls `libmodal#Enter` or `libmodal#Prompt`, the `modeName` parameter is used to generate a unique global variable for the specific purpose of receiving said input. The variable is generated as follows:

```viml
let g:{tolower(a:modeName)}ModeInput = …
```

For example, if `modeName` is 'FOO', then the variable that is created is `g:fooModeInput`.

## Creating Modes

For an example of a plugin that uses `vim-libmodal`, see [vim-tabmode](https://github.com/Iron-E/vim-tabmode).

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

- Note the `funcref()` call. __It must be there__ or else `libmodal#Enter` won't execute properly.

### Key Combinations

While normally `libmodal` dictates that a user should define their own function for controlling a mode, there is a way to specify key combinations. If the second argument is set to a `modeCombos` dictionary, `libmodal#Enter` will automatically detect the caller's intent and pass control over to an auxilliary function built to handle pre-defined combos.

When providing `modeCombos`, it is important to note that one no longer has to receive input for themselves. Despite this, the unique variable (see `libmodal-receiving-input`) is still updated, and you can create a listener for it just like for any other variable.

- Note that `libmodal-exit-supression` is still compatable with defining key combinations.

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

- NOTE: When defining actions that involve a chorded keypress (e.g. `CTRL-W_s`), mode creators should use `i_CTRL-V` to insert the literal of that character.
	- For example, if a mode creator wants a mapping for `<C-s>v`, then it should be specified as `v`.

And then to enter that mode, you can call:

```viml
call libmodal#Enter('BAR', s:barModeCombos)
```

`libmodal`'s internal processing of that dictionary becomes more useful the larger the dictionary is. Internally, `s:barModeCombos` is rendered into a dictionary that looks like this:

![Internal Tree Structure](https://mermaid.ink/img/eyJjb2RlIjoiZ3JhcGggVEJcbnp7en0gLS0-IGZ7Zn1cbmYgLS0-IGN7Y31cbmYgLS0-IG97b31cblxuYyAtLT4gZWNob1tcImVjaG9tICZxdW90O0l0IHdvcmtzISZxdW90O1wiXVxubyAtLT4gdGFibmV3IiwibWVybWFpZCI6eyJ0aGVtZSI6ImRlZmF1bHQifSwidXBkYXRlRWRpdG9yIjpmYWxzZX0 "Internal Tree Structure")

This allows `libmodal` to quickly determine which mappings are and are not part of the mode. Because of this method, modes with mappings that have similar beginnings are more efficient, and modes with more mappings get more benefit from the quick tree-like traversal.

- Note that `libmodal#Enter` will only parse a `modeCombos` dict _once_ upon entrance.
	- Changes to the mapping dictionary that may occur while in a mode _are not reflected_ until the mode is entered again and the dictionary is re-parsed.

### Libmodal Timeouts

When key combinations are being used, mode creators may also enable the use of Vim's built-in `timeout` feature. Unlike other options which are specified by passing arguments to `libmodal#Enter`, this feature is enabled through a variable.

- Note that if two keybinds share a beginning, and one is shorter than the other, (e.g. `zf` and `zfo`), then the user must press <CR> to execute it.
	- This also means that commands ending in `^M` are not permitted.
	- Unfortunately, because of the limitations of Vimscript (more specifically `getchar()`) it is not possible to execute a function on |timeout| using |timers| exposed by the API. `getchar()` blocks execution and there is no combination of |sleep| or `wait()` that will allow `getchar()` to be called asynchronously
	- If you are reading this and know how to do something like this without using a secondary language, please let me know or open a pull request.

The reasoning for this is that the use of `timeout`s is primarily chosen by the user of a mode, rather than the creator (whereas other features like exit supression are largely creator-oriented).

To enable `timeout`s, one may set the following variables:

```viml
" Set libmodal modes to turn timeouts on.
let g:libmodalTimeouts = 1
" Enable timeouts for specific mode.
let g:{modeName}ModeTimeout = 1
```

Similarly, to disable them, one may set them to `0`.

- Note that If not specified by the user, `g:libmodalTimeouts` automatically references the `timeout` on/off value.
- Note that the `g:limbodalTimeouts` variable should NOT be defined by plugins.
	- Allow users to decide whether or not they want timeouts to be enabled globally by themselves.
- Note that mode-specific timeout variables will override `g:libmodalTimeouts`.
	- This is so a default may be set but overridden.

When enabled, `libmodal` will reference the mode user's `timeoutlen` as specified in their config. This way, modes will feel consistent to users by default.

However, mode creators may change `timeoutlen` upon entrance of a mode, and then reset it upon exit. Example:

```viml
function! s:BarMode() abort
	" Get the user's preferred timeout length.
	let l:timeoutlen = &timeoutlen
	" Set it to something else, like 1500ms
	let &timeoutlen = 1500
	" Enter a mode
	call libmodal#Enter(…)
	" Reset the timeout
	let &timeoutlen = l:timeoutlen
endfunction
```

Mode creators who use `modeCallback`s may define timeouts manually using `timers`, which is how `libmodal` implements them internally.

### Exit Supression

When the `supressExit` parameter is specified, `libmodal#Enter` will ignore `<Esc>` presses and instead listen for changes to a unique variable created for the specific purpose of exiting the mode. The variable is generated as follows:

```viml
let g:{tolower(a:modeName)}ModeExit = 0
```

When this variable becomes set to `1`, the mode will exit the next time that the `modeCallback` function returns.

## Creating Prompts

Besides accepting user input like keys in `Normal-mode`, `libmodal` is also capable of prompting the user for input like `Cmdline-mode`. To define a `Cmdline-mode`-like prompt, use `libmodal#Prompt` rather than `libmodal#Enter`.

When `modeCommands` is specified, completions are provided for every key in the dictionary. See an example of this below:

```viml
let s:barModeCommands = {
\	'new': 'tabnew',
\	'close': 'tabclose',
\	'last': 'tablast'
\}
```

When `modeCallback` is specified, completions must be provided separately.  An equivalent to the above using a `modeCallback` would be:

```viml
" Define callback
function! s:BarMode() abort
	if g:barModeInput ==# 'new'
		execute 'tabnew'
	elseif g:barModeInput ==# 'close'
		execute 'tabclose'
	elseif g:barModeInput ==# 'last'
		execute 'tablast'
	endif
endfunction

" Define completion list
let s:barModeCommandList = ['new', 'close', 'last']
```

You can then enter the mode using one of the following commands (depending on whether or not you used a dictionary or a callback):

```viml
" Command dict
call libmodal#Prompt('BAR', s:barModeCommands)
" Callback + completion list
call libmodal#Prompt('BAR', funcref('s:BarMode'), s:barModeCommandList)
```

- Note that if you want to create commands with arguments, _you will need to use a callback_.

# Submodes

`libmodal` has built-in support for entering additional modes while already in a `libmodal` mode. To enter another mode, one must only call `libmodal#Enter` from within a `modeCallback`. Additionally, when a user presses `<Esc>` they will automatically be taken back to the mode that they were previously inside of.

To display this feature, one view the [submode example](./examples/submodes.vim).

# Configuration

The following highlight groups can be configured to change a mode's colors:

| Name             | Default      | Description                         |
|:-----------------|:-------------|:------------------------------------|
| `LibmodalPrompt` | `ModeMsg`    | Color for the mode text.            |
| `LibmodalStar`   | `StatusLine` | Color for the `*` at the beginning. |

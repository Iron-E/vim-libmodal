# Description

`vim-tabmode` is a Vim plugin for managing windows. Built-in functionality includes window selection, window buffer swapping, and window resizing. The plugin is extensible, allowing additional functionality to be added (see *Configuration* below).

<img src="screenshot.png?raw=true" width="800"/>

# Requirements

* Full functionality
	* `vim>=8.2` or `nvim>=0.4.0`
* Limited functionality (no window labels)
	* `vim>=8.1.1140`

# Installation

Use one of the following package managers:

* [Vim8 packages][vim8pack]:
	* `git clone https://github.com/Iron_E/vim-tabmode ~/.vim/pack/plugins/start/vim-win`
* [Vundle][vundle]:
	* Add `Plugin 'https://github.com/Iron_E/vim-tabmode'` to `~/.vimrc`
	* `:PluginInstall` or `$ vim +PluginInstall +qall`
* [Pathogen][pathogen]:
	* `git clone --depth=1 https://github.com/Iron_E/vim-tabmode ~/.vim/bundle/vim-win`
* [vim-plug][vimplug]:
	* Add `Plug 'https://github.com/Iron_E/vim-tabmode'` to `~/.vimrc`
	* `:PlugInstall` or `$ vim +PlugInstall +qall`
* [dein.vim][dein]:
	* Add `call dein#add('https://github.com/Iron_E/vim-tabmode')` to `~/.vimrc`
	* `:call dein#install()`
* [NeoBundle][neobundle]:
	* Add `NeoBundle 'https://github.com/Iron_E/vim-tabmode'` to `~/.vimrc`
	* Re-open vim or execute `:source ~/.vimrc`

# Usage

Enter `vim-tabmode` with `<leader><Tab>` or `:TabmodeEnter`.

| Key         | Use                                              |
|:-----------:|:------------------------------------------------:|
| `<Esc>`     | Leave `tabmode`                                  |
| `?`         | Show help message                                |
| `^`/`0`     | Go to the beginning of the tab list.             |
| `$`         | Go to the end of the tab list.                   |
| `b`/`j`/`h` | Tab left                                         |
| `w`/`k`/`l` | Tab right                                        |
| `a`         | Append a tab and switch to it.                   |
| `A`         | Append a tab to the end and switch to it.        |
| `i`         | Prepend a tab and switch to it.                  |
| `I`         | Prepend a tab to the beginning and switch to it. |
| `d`         | Delete the current tab.                          |
| `s`         | Replace the current tab with a new tab.          |

See `:help win-usage` for additional details.

# Documentation

```vim
:help vim-tabmode
```

The underlying markup is in [tabmode.txt](doc/win.txt).

## Demo

<img src="screencast.gif?raw=true" width="735"/>

# License

The source code has an [MIT License](https://en.wikipedia.org/wiki/MIT_License).

See [LICENSE](LICENSE).

[dein]: https://github.com/Shougo/dein.vim
[neobundle]: https://github.com/Shougo/neobundle.vim
[pathogen]: https://github.com/tpope/vim-pathogen
[vim8pack]: http://vimhelp.appspot.com/repeat.txt.html#packages
[vimplug]: https://github.com/junegunn/vim-plug
[vundle]: https://github.com/gmarik/vundle
||||||| parent of b38a46b... Refactor to allow generalized modes
=======
# Description

`vim-tabmode` is a Vim plugin for managing windows. Built-in functionality includes window selection, window buffer swapping, and window resizing. The plugin is extensible, allowing additional functionality to be added (see *Configuration* below).

<img src="screenshot.png?raw=true" width="800"/>

# Requirements

* Full functionality
	* `vim>=8.2` or `nvim>=0.4.0`
* Limited functionality (no window labels)
	* `vim>=8.1.1140`

# Installation

Use one of the following package managers:

* [Vim8 packages][vim8pack]:
	* `git clone https://github.com/Iron_E/vim-tabmode ~/.vim/pack/plugins/start/vim-win`
* [Vundle][vundle]:
	* Add `Plugin 'https://github.com/Iron_E/vim-tabmode'` to `~/.vimrc`
	* `:PluginInstall` or `$ vim +PluginInstall +qall`
* [Pathogen][pathogen]:
	* `git clone --depth=1 https://github.com/Iron_E/vim-tabmode ~/.vim/bundle/vim-win`
* [vim-plug][vimplug]:
	* Add `Plug 'https://github.com/Iron_E/vim-tabmode'` to `~/.vimrc`
	* `:PlugInstall` or `$ vim +PlugInstall +qall`
* [dein.vim][dein]:
	* Add `call dein#add('https://github.com/Iron_E/vim-tabmode')` to `~/.vimrc`
	* `:call dein#install()`
* [NeoBundle][neobundle]:
	* Add `NeoBundle 'https://github.com/Iron_E/vim-tabmode'` to `~/.vimrc`
	* Re-open vim or execute `:source ~/.vimrc`

# Usage

Enter `vim-tabmode` with `<leader><Tab>` or `:TabmodeEnter`.

| Key         | Use                                              |
|:-----------:|:------------------------------------------------:|
| `<Esc>`     | Leave `tabmode`                                  |
| `?`         | Show help message                                |
| `^`/`0`     | Go to the beginning of the tab list.             |
| `$`         | Go to the end of the tab list.                   |
| `b`/`j`/`h` | Tab left                                         |
| `w`/`k`/`l` | Tab right                                        |
| `a`         | Append a tab and switch to it.                   |
| `A`         | Append a tab to the end and switch to it.        |
| `i`         | Prepend a tab and switch to it.                  |
| `I`         | Prepend a tab to the beginning and switch to it. |
| `d`         | Delete the current tab.                          |
| `s`         | Replace the current tab with a new tab.          |

See `:help win-usage` for additional details.

# Documentation

```vim
:help vim-tabmode
```

The underlying markup is in [tabmode.txt](doc/win.txt).

## Demo

<img src="screencast.gif?raw=true" width="735"/>

# License

The source code has an [MIT License](https://en.wikipedia.org/wiki/MIT_License).

See [LICENSE](LICENSE).

[dein]: https://github.com/Shougo/dein.vim
[neobundle]: https://github.com/Shougo/neobundle.vim
[pathogen]: https://github.com/tpope/vim-pathogen
[vim8pack]: http://vimhelp.appspot.com/repeat.txt.html#packages
[vimplug]: https://github.com/junegunn/vim-plug
[vundle]: https://github.com/gmarik/vundle
>>>>>>> b38a46b... Refactor to allow generalized modes

# Vim VSCode-like Configuration

A comprehensive Vim configuration that provides a VSCode-like editing experience using Vim's native package system (no external plugin managers required).

## Installation

1. **Run the setup script:**
   ```bash
   ./vim-vscode-setup.sh
   ```

2. **Requirements:**
   - Vim 8.0+ (preferably Vim 8.2+ for full features)
   - Git (for plugin installation)
   - Optional: `fzf` binary + plugins for fuzzy finding (`brew install fzf` on macOS, `apt install fzf` on Ubuntu)

## Key Features

### 🎨 VSCode-like Appearance
- **Gruvbox** dark theme
- **Relative line numbers** with current line absolute
- **Status line** with file info and git status
- **Sign column** for git changes and diagnostics
- **Cursor line highlighting**

### ⌨️ VSCode-like Keybindings

| Keybinding | Action |
|------------|--------|
| `<leader>s` | Save file |
| `<C-s>` | Save file (alternative) |
| `<leader>q` | Quit |
| `<C-w>` | Quit (alternative) |
| `<leader>e` | Open file explorer |
| `<C-b>` | Open left sidebar explorer |
| `<leader>f` | Search in file |
| `<leader>h` | Clear search highlighting |
| `<C-h/j/k/l>` | Navigate between splits |
| `<leader>bn` | Next buffer |
| `<leader>bp` | Previous buffer |
| `<leader>bd` | Delete buffer |
| `<leader>n` | Toggle line numbers |
| `<leader>y` | Copy to system clipboard |
| `<leader>p` | Paste from system clipboard |

### 📁 File Management

#### NERDTree File Explorer
- **Toggle:** `<leader>n`
- **Features:**
  - Tree view navigation
  - Hidden files visible
  - Auto-close on file open
  - Auto-delete buffer when file deleted

#### Built-in Netrw Explorer
- **Open:** `<leader>e` (horizontal) or `<C-b>` (vertical split)
- **Navigation:** Use Vim keys (h,j,k,l)
- **Open file:** Enter on file
- **Create file/directory:** `%` (file) or `d` (directory)

### 🔍 Fuzzy Finding (requires fzf binary + plugins)

#### File Search
- **Command:** `<leader>ff`
- **Usage:** Type to fuzzy search files in current directory
- **Navigation:** Arrow keys or Ctrl-j/k
- **Open:** Enter
- **Troubleshooting:** Make sure you're in NORMAL mode (press Esc first)

#### Content Search (Grep)
- **Command:** `<leader>fg`
- **Usage:** Type to search text across all files
- **Navigation:** Same as file search
- **Preview:** Shows matching lines

#### Buffer Search
- **Command:** `<leader>fb`
- **Usage:** Fuzzy search open buffers
- **Switch:** Enter to switch to buffer

#### Command Search
- **Command:** `<leader>fc`
- **Usage:** Fuzzy search Vim commands
- **Execute:** Enter to run selected command

#### Line Search
- **Command:** `<leader>fl`
- **Usage:** Fuzzy search lines in current buffer
- **Jump:** Enter to jump to selected line

### 🖥️ Terminal Integration

#### Floating Terminal
- **Toggle:** `<leader>tt`
- **Features:**
  - Floating popup terminal
  - 80% width/height of screen
  - Toggle with same keybinding
- **Exit terminal mode:** `<leader>tt` or `<C-\><C-n>`

### 📝 Editing Features

#### Auto Pairs
- Automatically closes brackets, quotes, etc.
- **Fly mode:** Jump over closing characters

#### Commentary
- **Comment line:** `gcc`
- **Comment block:** `gc` + motion (e.g., `gc3j` for 3 lines)

#### Surround
- **Change surroundings:** `cs"'` (change " to ')
- **Delete surroundings:** `ds"`
- **Add surroundings:** `ysiw"` (surround word with ")

#### Indent Guides
- Visual indent lines
- Character: `│`

### 🔧 Git Integration

#### Vim Fugitive
- **Git status:** `:G`
- **Git commit:** `:G commit`
- **Git log:** `:G log`
- **Git diff:** `:G diff`

#### Git Gutter
- Shows git changes in sign column
- **Next hunk:** `]c`
- **Previous hunk:** `[c`
- **Stage hunk:** `<leader>hs`
- **Undo hunk:** `<leader>hu`

### 💻 Language Support

#### Syntax Highlighting
- **vim-polyglot** provides syntax for 100+ languages
- Automatic detection based on file extension

#### LSP Support (Neovim only)
If using Neovim instead of Vim, LSP support is available for:
- Python (pyright)
- JavaScript/TypeScript (tsserver)
- Rust (rust_analyzer)
- Go (gopls)

## Configuration Details

### File Structure
```
~/.vim/
├── pack/plugins/start/     # Auto-loaded plugins
│   ├── gruvbox/
│   ├── nerdtree/
│   ├── vim-airline/
│   └── ...
├── colors/                 # Custom colors
└── vimrc                   # Main configuration
```

### Customization

#### Adding New Plugins
1. Clone to `~/.vim/pack/plugins/start/plugin-name/` for auto-load
2. Or `~/.vim/pack/plugins/opt/plugin-name/` for manual load (`:packadd plugin-name`)

#### Modifying Keybindings
Edit `~/.vimrc` and change the mappings in the "Key mappings" section.

#### Changing Theme
Replace `colorscheme gruvbox` in `~/.vimrc` with another installed theme.

## Troubleshooting

### Plugin Not Loading
- Check if plugin is in `~/.vim/pack/plugins/start/`
- Restart Vim
- Run `:helptags ALL` to generate help tags

### FZF Not Working
- Install fzf binary: `brew install fzf` (macOS) or `apt install fzf` (Ubuntu)
- Restart Vim

### Colors Not Showing
- Ensure terminal supports 256 colors or true color
- Add `export TERM=xterm-256color` to your shell profile

### Slow Startup
- Remove unused plugins from `~/.vim/pack/plugins/start/`
- Move optional plugins to `opt/` and load manually

### Fuzzy Search Not Working
- **Check fzf installation:** `which fzf`
- **Check plugins:** Both `junegunn/fzf` and `junegunn/fzf.vim` must be installed
- **Ensure normal mode:** Press `Esc` before using `<leader>ff`
- **Leader key timing:** Press Space, then `ff` quickly (within 1 second)
- **Restart Vim:** After `.vimrc` changes
- **Check PATH:** `echo $PATH` should include fzf directory
- **Test manually:** Run `:Files` command directly in Vim
- **Error about fzf#run:** Install the base fzf plugin: `git clone https://github.com/junegunn/fzf ~/.vim/pack/plugins/start/fzf`

### LSP Not Working
- This configuration includes LSP setup for Neovim only
- For Vim 8.2+, consider adding coc.nvim using the same package approach

## VSCode Comparison

| VSCode Feature | Vim Equivalent |
|----------------|----------------|
| Ctrl+P (file search) | `<leader>ff` (fuzzy file search) |
| Ctrl+Shift+F (grep) | `<leader>fg` (ripgrep search) |
| Ctrl+B (sidebar) | `<leader>n` (NERDTree) |
| Ctrl+` (terminal) | `<leader>tt` (floating terminal) |
| Ctrl+S (save) | `<leader>s` |
| Alt+Shift+A (block comment) | `gc` (commentary) |
| Ctrl+Shift+K (delete line) | `dd` |
| Ctrl+D (multi-cursor) | Use Vim's `.` repeat or macros |

## Tips for VSCode Users

1. **Leader key** is space - press space first, then the shortcut
2. **Escape** exits insert mode (like clicking outside edit area in VSCode)
3. **Visual mode** (`v`) is like selecting text in VSCode
4. **Command mode** (`:`) is like VSCode's command palette
5. **Split windows** work like VSCode panels (`:vsplit`, `:split`)

## Contributing

To modify this configuration:
1. Edit `vim-vscode-setup.sh` to add/remove plugins
2. Update this README with new features
3. Test the changes

## License

This configuration is provided as-is for personal use. Plugins maintain their respective licenses.
A Neovim plugin that can do sometings like VAssistX.

<video src="https://user-images.githubusercontent.com/45937428/188934929-f462c7f4-8323-49a7-940f-d68322563313.mp4" width="100%"></video>

## Installation📦

```lua
use {
  'tuilk/cppassist.nvim',
  opt = true,
  ft = { "h", "cpp", "hpp", "c", "cc" },
  requires = { {'nvim-lua/plenary.nvim'} }
}
```

## Details📝

- It uses regular expressions instead of LSP;
- It can recognize underscores and asterisks in data types;
- It can recognize the simple return type;
- It can recognize multi-line function declarations;
- It can recognize class templates;
- It can recognize function default parameters and remove them;
- It can recognize the following keywords: const，explicit, static, override, final, virtual, friend, = 0, = default,
= delete, noexcept, constexpr;

> In my opinion, the inline keyword should be defined in the source file and not in the header file, 
because this keyword needs to be told to the compiler, not the user, so it is not implemented here

## Usage🔨

Place the cursor on the line where the declaration is located, and press 
the shortcut key to generate the corresponding definition. Be careful not 
to place the cursor at the semicolon, it will cause an error!

If a function is defined on more than one line, place the cursor on the 
starting line in the function definition!

```lua
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- switch between source and header
map('n', '<A-o>', '<Cmd>SwitchSourceAndHeader<CR>', opts)
-- generate the function definition or static variable definition in source
map('n', '<leader>cf', '<Cmd>ImplementInSource<CR>', opts)
-- generate the function definition or static variable definition in header
map('n', '<leader>cv', '<Cmd>ImplementOutOfClass<CR>', opts)
```

## TODO🚀

- [x] switch between source and header
- [x] generate the function definition in source
- [x] generate the static variable in source
- [ ] generate the Get()/Set() method for variable
- [ ] generate the multi function definitions in the view mode

## Special Thanks🙏

- [ouroboros.nvim](https://github.com/jakemason/ouroboros.nvim): quickly switching between header and implementation files

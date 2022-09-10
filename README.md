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
- It can recognize the pointer type and uses `NULL` as the return type;
- It can recognize a single function multi-line declaration;
- It supports for virtual function and static variable definitions;

## Usage🔨

Place the cursor on the line where the declaration is located, and press 
the shortcut key to generate the corresponding definition. Be careful not 
to place the cursor at the semicolon, it will cause an error!

```lua
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- switch between source and header
map('n', '<A-o>', '<Cmd>SwitchSourceAndHeader<CR>', opts)
-- generate the function definition in source
map('n', '<leader>cf', '<Cmd>CreateFuncDefInSource<CR>', opts)
-- generate the static variable definition in source
map('n', '<leader>cv', '<Cmd>CreateStaticVarDefInSource<CR>', opts)
```

## Shortcoming👎

- Unable to generate a function definition in the order of the declaration;
- Unable to replace the type defined by `typedef`;
- Unable to return specific values according to the different return types;
- If the function definition already exists, it will still generate;
- Unable to generate multiple function definitions at the same time in the view mode;

> In addition, the code is very bad, and it may need to be reconstructed later.

## TODO🚀

- [x] switch between source and header
- [x] generate the function definition in source
- [x] generate the static variable in source
- [ ] generate the Get()/Set() method for variable
- [ ] generate the multi function definitions in the view mode

## Special Thanks🙏

- [ouroboros.nvim](https://github.com/jakemason/ouroboros.nvim): quickly switching between header and implementation files

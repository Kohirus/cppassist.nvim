A Neovim plugin that can do sometings like VAssistX.

<video src="https://user-images.githubusercontent.com/45937428/188934929-f462c7f4-8323-49a7-940f-d68322563313.mp4" width="100%"></video>

# Installation

```lua
use {
  'tuilk/cppassist.nvim',
  opt = true,
  ft = { "h", "cpp", "hpp", "c", "cc" },
  requires = { {'nvim-lua/plenary.nvim'} }
}
```

# Usage

```lua
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- switch between source and header
map('n', '<A-o>', '<Cmd>SwitchSourceAndHeader<CR>', opts)
-- generate the function definition in source
map('n', '<leader>cf', '<Cmd>CreateFuncDefInSource<CR>', opts)
-- generate the static variable in source
map('n', '<leader>cv', '<Cmd>CreateStaticVarDefInSource<CR>', opts)
```

> 🚨 Now, the `CreateStaticVarDefInSource` command has some error !

# TODO

- [x] switch between source and header
- [x] generate the function definition in source
- [x] generate the static variable in source
- [ ] generate the Get()/Set() method for variable
- [ ] switch between definition and declaration

# Special Thanks

- [ouroboros.nvim](https://github.com/jakemason/ouroboros.nvim): quickly switching between header and implementation files

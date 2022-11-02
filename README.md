A Neovim plugin that can do sometings like VAssistX.

<video src="https://user-images.githubusercontent.com/45937428/188934929-f462c7f4-8323-49a7-940f-d68322563313.mp4" width="100%"></video>

## Installation📦

```lua
use {
  'Kohirus/cppassist.nvim',
  opt = true,
  ft = { "h", "cpp", "hpp", "c", "cc", "cxx" },
  config = function()
    require("cppassist").setup()
  end,
}
```

## Dependency💻

Now this plugin depends on `fd` instead of `plenary.nvim`. So please make sure 
the `fd` has been installed in your system.

## Configuration🧱

**Default configuration**

```lua
require('cppassist').setup {
  -- For `SwitchSourceAndHeader`, `ImplementInSource` and `ImplementOutOfClass` command
  switch_sh = {
    -- Search for target files in the following directories
    include_dirs = { ".", ".." },
    -- Exclude the following directories when searching for target files
    exclude_dirs = {},
    -- If you want other flags, see `man fd`
    -- -t: This option can be specified more than once to include multiple file types.
    -- -s: Perform a case-sensitive search.
    -- -L: Using this flag, symbolic links are also traversed.
    search_flags = "-tf -s -L",
    -- If the return type contains the following keywords, the value of the right side will be used in the return statement
    return_type = {
      int = "0",
      short = "0",
      long = "0",
      char = "0",
      double = "0.0",
      float = "0.0",
      bool = "false",
      pointer = "nullptr",
    }
  },
  -- For `GotoHeaderFile` command
  goto_header = {
    include_dirs = { ".", "..", "/usr/include", "/usr/local/include", "~" },
    exclude_dirs = {},
    search_flags = "-tf -s",
  },
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
- It supports multiple functions at the same time in `Visual` mode;
- It supports the custom return value of the basic data type;
- **If there are multiple matching at the same time, it will display the optional list**;
- **Now, it Supports the jump of the header file**;

> In my opinion, the inline keyword should be defined in the source file and not in the header file, 
because this keyword needs to be told to the compiler, not the user, so it is not implemented here

## Usage🔨

Place the cursor on the line where the declaration is located, and press 
the shortcut key to generate the corresponding definition.

If a function is defined on more than one line, place the cursor on the 
starting line in the function definition!

If you want to jump to the specified header file, place the cursor on the 
`#include` line. If there are multiple matches at the same time, there will 
be a optional list for selection.

```lua
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- switch between source and header
map('n', '<A-o>', '<Cmd>SwitchSourceAndHeader<CR>', opts)
-- generate the function definition or static variable definition in source
map('n', '<leader>cf', '<Cmd>ImplementInSource<CR>', opts)
-- generate the function definition or static variable definition in source in visual mode
map('v', '<leader>cf', '<Cmd>lua require("cppassist").ImplementInSourceInVisualMode<CR>', opts)
-- generate the function definition or static variable definition in header
map('n', '<leader>cv', '<Cmd>ImplementOutOfClass<CR>', opts)
-- goto the header file
map('n', '<leader>gh', '<Cmd>GotoHeaderFile<CR>', opts)
```

## TODO🚀

- [x] switch between source and header
- [x] generate the function definition in source
- [x] generate the static variable in source
- [ ] generate the Get()/Set() method for variable
- [x] generate the multi function definitions in the view mode
- [x] goto the header file

## Special Thanks🙏

- [ouroboros.nvim](https://github.com/jakemason/ouroboros.nvim): quickly switching between header and implementation files

## Ideas💡

If you have a better idea, please tell me with email: kohiurs@foxmail.com

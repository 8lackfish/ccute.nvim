<h1 align="center">c<sup>3</sup> - A color code colorizer</h1>

- Support the code formats: HEX, RGB, HSL. More formats are planned.
- Apply/clear on any line or range of lines using keymaps.

## Installation

### [vim.pack](https://neovim.io/doc/user/pack/#vim.pack)

On Neovim 0.12 and later:

```lua
vim.pack.add({
  'https://github.com/8lackfish/lum.nvim',
  'https://github.com/8lackfish/ccute.nvim'
})
```

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  '8lackfish/ccute.nvim',
  dependencies = { '8lackfish/lum.nvim' }
}
```

## Usage

### Commands

| Command | Description |
| --- | --- |
| `Cute` | Enable or disable colorizing to all buffers |

### Default configuration

```lua
require('ccute').setup({
  keymaps = {
    -- Neovim uses '\' as <Leader> by default
    apply_line = '<Leader>cc', -- apply to the current line.
    clear_line = '<Leader>CC', -- clear from the current line.
    apply_range = '<Leader>cr', -- apply to a range of lines.
    clear_range = '<Leader>CR' -- clear from a range of lines.
  },
})
```

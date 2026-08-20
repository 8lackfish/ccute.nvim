local M = {}

function M.setup(opts)
  if opts.apply_line then

    -- apply current line
    vim.keymap.set("n", opts.apply_line, function()
      require("ccute").apply_line()
    end)
  end

  if opts.clear_line then
    -- clear on current line
    vim.keymap.set("n", opts.clear_line, function()
      require("ccute").clear_line()
    end)
  end

  if opts.apply_range then
    -- apply selected lines
    vim.keymap.set("v", opts.apply_range, function()
      local s, e = vim.fn.line("v"), vim.fn.line(".")
      for i = s > e and e or s, s > e and s or e do
        require("ccute").apply_line(0, i)
      end
    end)
  end

  if opts.clear_range then
    -- clear on selected lines
    vim.keymap.set("v",opts.clear_range, function()
      local s, e = vim.fn.line("v"), vim.fn.line(".")
      for i = s > e and e or s, s > e and s or e do
        require("ccute").clear_line(0, i)
      end
    end)
  end

end

return M

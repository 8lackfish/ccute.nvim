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
    -- apply to a range of lines in visual mode
    vim.keymap.set("v", opts.apply_range, function()
      local s, e = vim.fn.line("v"), vim.fn.line(".")
      for i = s > e and e or s, s > e and s or e do
        require("ccute").apply_line(0, i)
      end
    end)

    ---@private
    function _G._ccute_apply_range()
      local s = vim.fn.line("'[")
      local e = vim.fn.line("']")

      for i = math.min(s, e), math.max(s, e) do
        require("ccute").apply_line(0, i)
      end
    end

    -- apply to a range of lines in normal mode
    vim.keymap.set("n", opts.apply_range, function()
      vim.go.operatorfunc = "v:lua._ccute_apply_range"
      return "g@"
    end, { expr = true })
  end

  if opts.clear_range then
    -- clear on a range of lines in visual mode
    vim.keymap.set("v",opts.clear_range, function()
      local s, e = vim.fn.line("v"), vim.fn.line(".")
      for i = s > e and e or s, s > e and s or e do
        require("ccute").clear_line(0, i)
      end
    end)

    ---@private
    function _G._ccute_clear_range()
      local s = vim.fn.line("'[")
      local e = vim.fn.line("']")

      for i = math.min(s, e), math.max(s, e) do
        require("ccute").clear_line(0, i)
      end
    end

    -- clear on a range of lines in normal mode
    vim.keymap.set("n", opts.clear_range, function()
      vim.go.operatorfunc = "v:lua._ccute_clear_range"
      return "g@"
    end, { expr = true })
  end
end

return M

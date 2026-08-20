local M = {}

function M.setup()

  local ccuteActive = false
  local attachedBufs = {}
  local triggeredBufs = {}

  vim.api.nvim_create_user_command("Cute", function() -- toggle
    ccuteActive = not ccuteActive
    if ccuteActive then
      print("C³: ON")
      require'ccute'.linear()
      triggeredBufs[vim.api.nvim_get_current_buf()] = true
    else
      print("C³: OFF")
      for bufnr in pairs(triggeredBufs) do
        if vim.api.nvim_buf_is_valid(bufnr) then
          require'ccute'.clear(bufnr)
        end
      end
      triggeredBufs = {}
    end
  end, {})

  local function attach(bufnr) -- buffer tracking (register on_lines callback)
    if attachedBufs[bufnr] then return end

    attachedBufs[bufnr] = true

    vim.api.nvim_buf_attach(bufnr, false, {
      on_lines = function(_, bufnr, _, first_line, _, last_line_new)
        if not ccuteActive then return end

        vim.schedule(function() -- defer editor operations until leaving textlock restriction
          if not ccuteActive then return end

          -- clamp the range to the current line count in case the buffer changed before the scheduled callback runs
          local line_count = vim.api.nvim_buf_line_count(bufnr)
          local last = math.min(last_line_new, line_count)

          for lnum = first_line, last - 1 do
            require'ccute'.apply_line(bufnr, lnum + 1)
          end
        end)
      end,
    })

  end

  attach(vim.api.nvim_get_current_buf())

  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function(args)
      attach(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufWritePost" }, { -- trigger
    callback = function(args)
      if not ccuteActive then return end
      local bufnr = args.buf
      if args.event ~= "BufWritePost" then
        if triggeredBufs[bufnr] then return end
        triggeredBufs[bufnr] = true
      end
      require'ccute'.linear()
    end
  })
end

return M

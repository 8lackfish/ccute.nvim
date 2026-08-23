local M = {}

local lum = {}
lum.color = require 'lum.color'

local ccc_ns = vim.api.nvim_create_namespace("color_codes_colorizer")

---@class CodeTarget
---@field bufnr? integer The buffer number, or if 0|nil, uses the current buffer.
---@field code string The color code string (HEX, RGB, HSL).
---@field lnum? integer The line number of the color code, if nil, uses the current line (under cursor) when bufnr is 0|nil (current buffer), otherwise defaults to line 1
---@field col integer The column index where the color code starts.
---@field len integer The length of the color code.

---Highlight a color code in the buffer.
---Available: HEX (#rrggbb | #rgb), RGB, HSL.
---@param opts CodeTarget
function M.apply(opts)
  if not lum.color.is_color_code(opts.code) then return end

  local r, g, b = opts.code:match("^rgb%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)$")
  local h, s, l = opts.code:match("^hsl%(%s*(%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*%)$")

  local hexcolor

  if r and g and b then
    r = tonumber(r) ---@cast r number
    g = tonumber(g) ---@cast g number
    b = tonumber(b) ---@cast b number
    if r <= 255 and r >= 0 and g <= 255 and g >= 0 and b <= 255 and b >= 0 then
      hexcolor = lum.color.rgb_to_hex(r, g, b)
    else
      return
    end
  elseif h and s and l then
    h = tonumber(h) ---@cast h number
    s = tonumber(s) ---@cast s number
    l = tonumber(l) ---@cast l number
    if h <= 360 and h >= 0 and s <= 100 and s >= 0 and l <= 100 and l >= 0 then
      hexcolor = lum.color.hsl_to_hex(h, s, l)
    else
      return
    end
  else
    hexcolor = opts.code
  end

  hexcolor = lum.color.expand_hexcolor(hexcolor)
  local fg = lum.color.relative_luminance(hexcolor) > 0.179 and '#000000' or '#ffffff'
  local group = "Ccute_" .. hexcolor:sub(2):lower()
  if vim.fn.hlID(group) == 0 then
    vim.api.nvim_set_hl(0, group, { fg = fg, bg = hexcolor })
  end

  opts.bufnr = opts.bufnr or 0
  opts.lnum = opts.lnum or ((opts.bufnr == 0) and vim.api.nvim_win_get_cursor(0)[1]) or 1

  vim.api.nvim_buf_add_highlight(opts.bufnr, ccc_ns, group, opts.lnum - 1, opts.col - 1, opts.col - 1 + opts.len)
end

---Highlight color codes on the line.
---Available: HEX (#rrggbb | #rgb), RGB, HSL.
---@param bufnr integer|nil The buffer number, or if 0|nil, uses the current buffer
---@param lnum integer|nil The line number, if nil, uses the current line (under cursor) when bufnr is 0|nil (current buffer), otherwise defaults to line 1
function M.apply_line(bufnr, lnum)
  bufnr = bufnr or 0
  lnum = lnum or ((bufnr == 0) and vim.api.nvim_win_get_cursor(0)[1]) or 1
  local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
  local patterns = {
    "#%x%x%x%x?%x?%x?",
    "rgb%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)",
    "hsl%(%s*%d+%s*,%s*%d+%%%s*,%s*%d+%%%s*%)"
  }

  vim.api.nvim_buf_clear_namespace(bufnr, ccc_ns, lnum - 1, lnum)

  for _, pat in ipairs(patterns) do
    for s, m in line:gmatch("()(" .. pat .. ")") do
      M.apply({ code = m, lnum = lnum, col = s, len = #m })
    end
  end
end

---Clear color code highlights on the line.
---@param bufnr integer|nil The buffer number, or if 0|nil, uses the current buffer
---@param lnum integer|nil The line number, if nil, uses the current line (under cursor) when bufnr is 0|nil (current buffer), otherwise defaults to line 1
function M.clear_line(bufnr, lnum)
  bufnr = bufnr or 0
  lnum = lnum or ((bufnr == 0) and vim.api.nvim_win_get_cursor(0)[1]) or 1
  vim.api.nvim_buf_clear_namespace(bufnr, ccc_ns, lnum - 1, lnum)
end

---Apply color code highlights linearly in the buffer.
---Available: HEX (#rrggbb | #rgb), RGB, HSL.
---@param bufnr integer|nil The buffer number, or if 0|nil, uses the current buffer
function M.linear(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr or 0, ccc_ns, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(bufnr or 0, 0, -1, false)

  for lnum, line in ipairs(lines) do
    for col, m in line:gmatch("()(#%x%x%x%x?%x?%x?)") do
      local len = #m
      if len == 4 or len == 7 then -- #rgb or #rrggbb
        M.apply({
          bufnr = bufnr,
          code = m,
          lnum = lnum,
          col = col,
          len = len
        })
      end
    end

    for col, m in line:gmatch("()(hsl%(%s*%d+%s*,%s*%d+%%%s*,%s*%d+%%%s*%))") do
      M.apply({
        bufnr = bufnr,
        code = m,
        lnum = lnum,
        col = col,
        len = #m
      })
    end

    for col, m in line:gmatch("()(rgb%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%))") do
      M.apply({
        bufnr = bufnr,
        code = m,
        lnum = lnum,
        col = col,
        len = #m
      })
    end
  end
end


---Clear color code highlights in the buffer.
---@param bufnr integer|nil The buffer number, or if 0|nil, uses the current buffer
function M.clear(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr or 0, ccc_ns, 0, -1)
end

M.defaults = {
  keymaps = {
    apply_line = "<Leader>cc",
    clear_line = "<Leader>CC",
    apply_range = "<Leader>cr",
    clear_range = "<Leader>CR"
  },
  lazy = false
}

function M.setup(opts)
  opts = vim.tbl_deep_extend("force", M.defaults, opts or {})

  require'ccute.keymaps'.setup(opts.keymaps)
  require'ccute.commands'.setup(opts)
end

return M

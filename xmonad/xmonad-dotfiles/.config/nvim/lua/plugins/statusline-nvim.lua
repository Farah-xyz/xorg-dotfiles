----------------------------------------------------------
-- Statusline configuration file
-----------------------------------------------------------
-- Plugin: feline.nvim
-- url: https://github.com/feline-nvim/feline.nvim

-- For the configuration see the Usage section:
-- https://github.com/feline-nvim/feline.nvim/blob/master/USAGE.md

-- Thanks to ibhagwan for the example to follow:
-- https://github.com/ibhagwan/nvim-lua

local status_ok, feline = pcall(require, 'feline')
if not status_ok then
  return
end

-- Set colorscheme (from core/colors.lua/colorscheme_name)
----------------------------------------------------------
-- Statusline configuration file
-----------------------------------------------------------

-- Plugin: feline.nvim
-- url: https://github.com/feline-nvim/feline.nvim

-- For the configuration see the Usage section:
-- https://github.com/feline-nvim/feline.nvim/blob/master/USAGE.md

-- Thanks to ibhagwan for the example to follow:
-- https://github.com/ibhagwan/nvim-lua
local feline = require('feline')
local vi_mode = require('feline.providers.vi_mode')

--
-- 1. define some constants
--

-- left and right constants (first and second items of the components array)
local LEFT = 1
local RIGHT = 2

-- vi mode color configuration
local MODE_COLORS = {
  ['NORMAL'] = 'green',
  ['COMMAND'] = 'skyblue',
  ['INSERT'] = 'orange',
  ['REPLACE'] = 'red',
  ['LINES'] = 'violet',
  ['VISUAL'] = 'violet',
  ['OP'] = 'yellow',
  ['BLOCK'] = 'yellow',
  ['V-REPLACE'] = 'yellow',
  ['ENTER'] = 'yellow',
  ['MORE'] = 'yellow',
  ['SELECT'] = 'yellow',
  ['SHELL'] = 'yellow',
  ['TERM'] = 'yellow',
  ['NONE'] = 'yellow',
}

-- FrhXM theme
local GRUVBOX = {
  fg = '#a9b1d6',
  bg = '#11121D',
  black = '#000000',
  skyblue = '#f7768e',
  cyan = '#449dab',
  green = '#f7768e',
  oceanblue = '#076678',
  blue = '#7aa2f7',
  magenta = '#d3869b',
  orange = '#bb9af7',
  red = '#f7768e',
  violet = '#b16286',
  white = '#a9b1d6',
  yellow = '#fabd2f',
}

--
-- 2. setup some helpers
--

--- get the current buffer's file name, defaults to '[no name]'
function get_filename()
  local filename = vim.api.nvim_buf_get_name(0)
  if filename == '' then
    filename = '[no name]'
  end
  -- this is some vim magic to remove the current working directory path
  -- from the absilute path of the filename in order to make the filename
  -- relative to the current working directory
  return vim.fn.fnamemodify(filename, ':~:.')
end

--- get the current buffer's file type, defaults to '[not type]'
function get_filetype()
  local filetype = vim.bo.filetype
  if filetype == '' then
    filetype = '[no type]'
  end
  return filetype:lower()
end

--- get the cursor's line
function get_line_cursor()
  local cursor_line, _ = unpack(vim.api.nvim_win_get_cursor(0))
  return cursor_line
end

--- get the file's total number of lines
function get_line_total()
  return vim.api.nvim_buf_line_count(0)
end

--- wrap a string with whitespaces
function wrap(string)
  return ' ' .. string .. ' '
end

--- wrap a string with whitespaces and add a '' on the left,
-- use on left section components for a nice  transition
function wrap_left(string)
  return ' ' .. string .. ' '
end

--- wrap a string with whitespaces and add a '' on the right,
-- use on left section components for a nice  transition
function wrap_right(string)
  return ' ' .. string .. ' '
end

--- decorate a provider with a wrapper function
-- the provider must conform to signature: (component, opts) -> string
-- the wrapper must conform to the signature: (string) -> string
function wrapped_provider(provider, wrapper)
  return function(component, opts)
    return wrapper(provider(component, opts))
  end
end

--
-- 3. setup custom providers
--

--- provide the vim mode (NOMRAL, INSERT, etc.)
function provide_mode(component, opts)
  return vi_mode.get_vim_mode()
end

--- provide the buffer's file name
function provide_filename(component, opts)
  return get_filename()
end

--- provide the line's information (curosor position and file's total lines)
function provide_linenumber(component, opts)
  return get_line_cursor() .. '/' .. get_line_total()
end

-- provide the buffer's file type
function provide_filetype(component, opts)
  return get_filetype()
end

--
-- 4. build the components
--

local components = {
  -- components when buffer is active
  active = {
    {}, -- left section
    {}, -- right section
  },
  -- components when buffer is inactive
  inactive = {
    {}, -- left section
    {}, -- right section
  },
}

-- insert the mode component at the beginning of the left section
table.insert(components.active[LEFT], {
  name = 'mode',
  provider = wrapped_provider(provide_mode, wrap),
  right_sep = 'slant_right',
  -- hl needs to be a function to avoid calling get_mode_color
  -- before feline initiation
  hl = function()
    return {
      fg = 'black',
      bg = vi_mode.get_mode_color(),
    }
  end,
})

-- insert the filename component after the mode component
table.insert(components.active[LEFT], {
  name = 'filename',
  provider = wrapped_provider(provide_filename, wrap_left),
  right_sep = 'slant_right',
  hl = {
    bg = 'white',
    fg = 'black',
  },
})

-- insert the filetype component before the linenumber component
table.insert(components.active[RIGHT], {
  name = 'filetype',
  provider = wrapped_provider(provide_filetype, wrap_right),
  left_sep = 'slant_left',
  hl = {
    bg = 'white',
    fg = 'black',
  },
})

-- insert the linenumber component at the end of the left right section
table.insert(components.active[RIGHT], {
  name = 'linenumber',
  provider = wrapped_provider(provide_linenumber, wrap),
  left_sep = 'slant_left',
  hl = {
    bg = 'skyblue',
    fg = 'black',
  },
})

-- insert the inactive filename component at the beginning of the left section
table.insert(components.inactive[LEFT], {
  name = 'filename_inactive',
  provider = wrapped_provider(provide_filename, wrap),
  right_sep = 'slant_right',
  hl = {
    fg = 'white',
    bg = 'bg',
  },
})

--
-- 5. run the feline setup
--

feline.setup({
  theme = GRUVBOX,
  components = components,
  vi_mode_colors = MODE_COLORS,
})

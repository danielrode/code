local wezterm = require("wezterm")
local act = wezterm.action

return {
	-- Set space between inner window border and terminal view
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},

	-- Set typeface
	--font = wezterm.font("Hack Nerd Font"),
	-- font = wezterm.font("FiraCode Nerd Font"),
	font = wezterm.font("Cousine Nerd Font Mono"),
	font_size = 11,

	-- Force cursor to use reverse colors based on current fg/bg colorss
	force_reverse_video_cursor = true,

	-- Theme
	color_scheme = "Tokyo Night Moon",

	-- Hide main window tab bar
	enable_tab_bar = false,

	-- Set terminfo so neovim can use red squiggly underline
	term = "wezterm",

  -- Disable window confirm dialog
  window_close_confirmation = "NeverPrompt",

  -- Prevent links from being so easy (annoying) to click
  mouse_bindings = {
      -- Disable the default click behavior
      {
        event = { Up = { streak = 1, button = "Left"} },
        mods = "NONE",
        action = wezterm.action.DisableDefaultAssignment,
      },
      -- Ctrl-click will open the link under the mouse cursor
      {
          event = { Up = { streak = 1, button = "Left" } },
          mods = "CTRL",
          action = wezterm.action.OpenLinkAtMouseCursor,
      },
      -- Disable the Ctrl-click down event to stop programs from seeing it when a URL is clicked
      {
          event = { Down = { streak = 1, button = "Left" } },
          mods = "CTRL",
          action = wezterm.action.Nop,
      },
  },

  -- Keyboard shortcuts
  keys = {
  	-- Smart copy
    {
      key="c",
      mods="CTRL",
      action = wezterm.action_callback(function(window, pane)
        local has_selection = window:get_selection_text_for_pane(pane) ~= ""
        if has_selection then
          window:perform_action(
            wezterm.action{CopyTo="ClipboardAndPrimarySelection"},
            pane)
          window:perform_action("ClearSelection", pane)
        else
          window:perform_action(
            wezterm.action{SendKey={key="c", mods="CTRL"}},
            pane)
        end
      end)
    },
    -- Paste
    { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
    -- Disable default Alt-Enter key binding
    {
      key = 'Enter',
      mods = 'ALT',
      action = wezterm.action.DisableDefaultAssignment,
    },
  }
}


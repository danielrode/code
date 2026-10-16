-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Allow Left arrow key to wrap to the previous line
vim.opt.whichwrap:append("<")
vim.opt.whichwrap:append(">")

-- Combine git gutter and line number column (if there is space)
vim.opt.signcolumn = "number"

-- Tabs as spaces
vim.opt.expandtab = true   -- Convert tabs to spaces
vim.opt.tabstop = 4        -- Number of spaces that equal a 'tab'
vim.opt.shiftwidth = 4     -- Number of spaces for indentation (by default)
vim.opt.softtabstop = 4    -- Number of spaces a tab equals while editing

-- Yank to system clipboard
vim.opt.clipboard = "unnamedplus"

-----------------------------------------------------------
-- Plugins
----

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo,
        lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        -- PLUGINS HERE
        {
            -- Tokyo Night theme
            -- https://github.com/folke/tokyonight.nvim
            "folke/tokyonight.nvim",
            lazy = false,
            priority = 1000,
            opts = { style = "storm" },
            config = function()
                vim.cmd([[colorscheme tokyonight]])
            end,
        },
        {
            'nvim-mini/mini.pairs', version = false
        },
        {
            'nvim-mini/mini.ai', version = false
        },
        {
            'nvim-treesitter/nvim-treesitter',
            lazy = false,
            build = ':TSUpdate'
        },
        {
            "nvim-treesitter/nvim-treesitter-textobjects",
            branch = "main",
            init = function()
                -- Disable entire built-in ftplugin mappings to avoid conflicts.
                -- See
                -- https://github.com/neovim/neovim/tree/master/runtime/ftplugin
                -- for built-in ftplugins.
                vim.g.no_plugin_maps = true

                -- Or, disable per filetype (add as you like)
                -- vim.g.no_python_maps = true
                -- vim.g.no_ruby_maps = true
                -- vim.g.no_rust_maps = true
                -- vim.g.no_go_maps = true
            end,
            config = function()
                -- put your config here
            end,
        },
        -- {
        --   'akinsho/bufferline.nvim',
        --   version = "*",
        --   dependencies = 'nvim-tree/nvim-web-devicons',
        -- },
        {
            'nvim-lualine/lualine.nvim',
            dependencies = { 'nvim-tree/nvim-web-devicons' },
        },
        {
            'lewis6991/gitsigns.nvim',
        },
        {
            "folke/flash.nvim",
            event = "VeryLazy",
            vscode = true,
            ---@type Flash.Config
            opts = {},
            -- stylua: ignore
            keys = {
                {
                    "s", mode = { "n", "x", "o" },
                    function() require("flash").jump() end,
                    desc = "Flash"
                },
                {
                    "S", mode = { "n", "o", "x" },
                    function() require("flash").treesitter() end,
                    desc = "Flash Treesitter"
                },
                {
                    "r", mode = "o",
                    function() require("flash").remote() end,
                    desc = "Remote Flash"
                },
                {
                    "R", mode = { "o", "x" },
                    function() require("flash").treesitter_search() end,
                    desc = "Treesitter Search"
                },
                {
                    "<c-s>", mode = { "c" },
                    function() require("flash").toggle() end,
                    desc = "Toggle Flash Search"
                },
                -- Simulate nvim-treesitter incremental selection
                { "<c-space>", mode = { "n", "o", "x" },
                function()
                    require("flash").treesitter({
                        actions = {
                            ["<c-space>"] = "next",
                            ["<BS>"] = "prev"
                        }
                    })
                end, desc = "Treesitter Incremental Selection" },
            },
        },
        {
            'nvim-telescope/telescope.nvim', version = '*',
            dependencies = {
                'nvim-lua/plenary.nvim',
                -- optional but recommended
                {
                    'nvim-telescope/telescope-fzf-native.nvim',
                    build = 'make'
                },
            }
        },
        {
            -- Keybindings reference popup
            "folke/which-key.nvim",
            event = "VeryLazy",
            opts_extend = { "spec" },
            opts = {
                preset = "helix",
                defaults = {},
                spec = {
                    {
                        mode = { "n", "x" },
                        { "<leader><tab>", group = "tabs" },
                        { "<leader>c", group = "code" },
                        { "<leader>d", group = "debug" },
                        { "<leader>dp", group = "profiler" },
                        { "<leader>f", group = "file/find" },
                        { "<leader>g", group = "git" },
                        { "<leader>gh", group = "hunks" },
                        { "<leader>q", group = "quit/session" },
                        { "<leader>s", group = "search" },
                        { "<leader>u", group = "ui" },
                        { "<leader>x", group = "diagnostics/quickfix" },
                        { "[", group = "prev" },
                        { "]", group = "next" },
                        { "g", group = "goto" },
                        { "gs", group = "surround" },
                        { "z", group = "fold" },
                        {
                            "<leader>b",
                            group = "buffer",
                            expand = function()
                                return require(
                                    "which-key.extras").expand.buf()
                            end,
                        },
                        {
                            "<leader>w",
                            group = "windows",
                            proxy = "<c-w>",
                            expand = function()
                                return require(
                                    "which-key.extras").expand.win()
                            end,
                        },
                        { "gx", desc = "Open with system app" },
                    },
                },
            },
            keys = {
                {
                    "<leader>?",
                    function()
                        require("which-key").show({
                            global = false
                        })
                    end,
                    desc = "Buffer Keymaps (which-key)",
                },
                {
                    "<c-w><space>",
                    function()
                        require("which-key").show({
                            keys = "<c-w>", loop = true 
                        })
                    end,
                    desc = "Window Hydra Mode (which-key)",
                },
            },
            config = function(_, opts)
                local wk = require("which-key")
                wk.setup(opts)
            end,
        }
    },
    -- Colorscheme that will be used when installing plugins
    install = { colorscheme = { "habamax" } },
    checker = { enabled = false },  -- Check for plugin updates
})

-- Load https://github.com/nvim-mini/mini.pairs
require('mini.pairs').setup()

-- Load https://github.com/nvim-mini/mini.ai
require('mini.ai').setup()

-- -- Load https://github.com/akinsho/bufferline.nvim
-- vim.opt.termguicolors = true
-- require("bufferline").setup{}

-- Load https://github.com/nvim-lualine/lualine.nvim
require('lualine').setup()

-- Load https://github.com/nvim-telescope/telescope.nvim
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-----------------------------------------------------------
-- Editor configs
----

vim.opt.colorcolumn = "80"         -- Rulers at column 80
vim.opt.wrap = true                -- Enable soft-wrap by default
vim.opt.number = true              -- Line numbers
vim.opt.relativenumber = false     -- Absolute line numbers
vim.opt.ignorecase = true          -- Case-insensitive search
vim.opt.smartcase = true           -- Case-sensitive if uppercase present
vim.opt.termguicolors = true       -- True color support

-- Cursor shapes per mode
vim.opt.guicursor = {
    "n-v-c:block",
    "i-ci-ve:ver25",
    "r-cr:hor20"
}

-----------------------------------------------------------
-- Keybindings
----

-- Save and quit
vim.keymap.set({'n', 'i', 'v'}, '<C-d>', '<cmd>qa<CR>', { desc = "Quit all" })
vim.keymap.set({'n', 'v'}, '<C-q>', '<cmd>qa<CR>', { desc = "Quit all" })
vim.keymap.set(
    {'n', 'i', 'v'}, '<C-s>', '<cmd>w<CR><Esc>', { desc = "Save file" }
)

-- Undo redo
vim.keymap.set('n', 'U', '<C-r>', {
    noremap = true, silent = true, desc = "Redo"
})

-- Insert date/time
local insert_date = function()
    local date_str = os.date("%Y-%m-%d %H:%M")
    vim.api.nvim_put({date_str}, 'c', true, true)
end
vim.keymap.set(
    {'n', 'i'},
    '<F3>',
    insert_date,
    { desc = "Insert current date/time" })

vim.keymap.set('v', '<F3>', function()
    vim.cmd('normal! d')
    insert_date()
    end, { desc = "Replace selection with date" })

-- Toggle comments
vim.keymap.set({'n'}, '<C-/>', 'gcc',
    { remap = true, desc = "Toggle comment" })
vim.keymap.set({'v'}, '<C-/>', 'gc',
    { remap = true, desc = "Toggle comment" })

-- Sort
vim.keymap.set('n', '<F9>', ':%sort<CR>', { desc = "Sort file" })
vim.keymap.set('v', '<F9>', ':sort<CR>', { desc = "Sort selection" })

-- Toggle soft wrap
vim.keymap.set({'n', 'i', 'v'}, '<F10>', function()
    vim.wo.wrap = not vim.wo.wrap
    print("Soft wrap: " .. tostring(vim.wo.wrap))
end, { desc = "Toggle soft wrap" })

-- Buffer (tab) management
vim.keymap.set(
    'n', 'gn', '<cmd>tabnext<CR>', { desc = "Next buffer" })
vim.keymap.set(
    'n', 'gN', '<cmd>tabNext<CR>', { desc = "Previous buffer" })
vim.keymap.set(
    'n', '<leader>x', '<cmd>bdelete<CR>', { desc = "Close buffer" })
vim.keymap.set(
    'n', '<leader>X', '<cmd>bdelete!<CR>',
    { desc = "Force close buffer" })

-- Delete selection without yanking
vim.keymap.set({'n', 'v'}, '<Del>', '"_x',
    { desc = "Delete without yank" })

-- Copy current file path to Wayland clipboard
vim.keymap.set('n', '<leader>Ay', function()
    local filepath = vim.fn.expand('%:p')
    vim.fn.system('wl-copy', filepath)
    print("Copied path to clipboard: " .. filepath)
    end, { desc = "Copy file path to Wayland clipboard" })

-- Hard-wrap text
vim.keymap.set({'n', 'v'}, '<C-,>', function()
    vim.cmd('normal! V')
    vim.cmd("'<,'>w !hard-wrap-text")
    end, { desc = "Run hard-wrap-text script" })

-- Markdown Paste command (<space>p)
vim.keymap.set(
    {'n', 'v'},
    '<leader>p',
    ':r !md-paste<CR>',
    { desc = "Paste markdown output" })

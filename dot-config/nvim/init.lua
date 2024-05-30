vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup({
  {
    "williamboman/mason.nvim",
    name = "mason",
    config = function()
      require("mason").setup()
    end
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.6',
    -- or                              , branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>ff', function() require("telescope.builtin").find_files() end, desc = "fuzzy find" },
      { '<leader>fg', function() require("telescope.builtin").live_grep() end, desc = "live grep" },
      { '<leader>fb', function() require("telescope.builtin").buffers() end, desc = "fuzzy buffer find" },
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({ flavor = "mocha",})
    end,
  },
})

vim.cmd.colorscheme "catppuccin" 
vim.keymap.set("n","<leader>pv",vim.cmd.Ex)

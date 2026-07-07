-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0.04
  vim.g.neovide_refresh_rate = 240
  vim.o.guifont = "JetBrains Mono:h16"
  -- vim.o.guifont = "MesloLGS Nerd Font:h16"
end

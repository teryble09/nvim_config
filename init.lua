-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/nvim-mini/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end



require('mini.deps').setup({ path = { package = path_package } })

local add = MiniDeps.add

vim.g.maplocalleader = ' '
vim.g.mapleader = ' '

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.expandtab   = true
vim.opt.tabstop     = 4
vim.opt.shiftwidth  = 4
vim.opt.softtabstop = 4
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase  = true
vim.opt.cursorline = true


require('mini.statusline').setup()
require('mini.jump').setup()

require('mini.pick').setup()
vim.keymap.set('n', '<leader>ff', '<cmd>Pick files<cr>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', '<cmd>Pick grep_live<cr>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', '<cmd>Pick buffers<cr>', { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fh', '<cmd>Pick help<cr>', { desc = 'Help' })

require('mini.pairs').setup()
require('mini.surround').setup()
require('mini.icons').setup()
require('mini.files').setup()
vim.keymap.set('n', 'mf', function()
    require('mini.files').open()
end, { desc = 'MiniFiles.open()' })

require('mini.diff').setup({
  view = { style = 'sign' }
})

require('mini.ai').setup()
require('mini.git').setup()
require('mini.extra').setup({})

add('williamboman/mason.nvim')
require('mason').setup()    

vim.lsp.enable('gopls')

-- Автоформатирование и организация импортов при сохранении
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("gopls_format", { clear = true }),
  callback = function(args)
    -- Проверяем, что это gopls
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.name ~= "gopls" then
      return
    end

    -- Функция для удобной настройки keymaps
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
    end

    -- Основные LSP keymaps
    map('n', 'K', vim.lsp.buf.hover, 'Показать документацию')
    map('n', 'gd', vim.lsp.buf.definition, 'Перейти к определению')
    map('n', 'gD', vim.lsp.buf.declaration, 'Перейти к объявлению')
    map('n', 'gi', vim.lsp.buf.implementation, 'Перейти к реализации')
    map('n', 'gr', vim.lsp.buf.references, 'Показать использования')
    map('n', 'gs', vim.lsp.buf.signature_help, 'Сигнатура функции')
    map('n', '<leader>rn', vim.lsp.buf.rename, 'Переименовать')
    map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code Action')
    map('n', '<leader>D', vim.lsp.buf.type_definition, 'Определение типа')

    -- Настраиваем форматирование при сохранении
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = args.buf,
      callback = function()
        -- Организация импортов
        local params = vim.lsp.util.make_range_params()
        params.context = { only = { "source.organizeImports" } }
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
        
        for cid, res in pairs(result or {}) do
          for _, r in pairs(res.result or {}) do
            if r.edit then
              local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
              vim.lsp.util.apply_workspace_edit(r.edit, enc)
            end
          end
        end

        -- Форматирование кода
        vim.lsp.buf.format({ async = false, id = args.data.client_id })
      end,
    })
  end,
})

require('mini.snippets').setup()
require('mini.completion').setup()

add('rachartier/tiny-inline-diagnostic.nvim')
require('tiny-inline-diagnostic').setup()
vim.diagnostic.config({
  virtual_text = false, -- уже есть tiny-inline-diagnostic
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = true,
  },
})

add('rebelot/kanagawa.nvim')
vim.cmd.colorscheme('kanagawa')

require('mini.comment').setup()

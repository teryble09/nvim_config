-- ============================================================================
-- BOOTSTRAP: Установка mini.nvim
-- ============================================================================
-- Автоматически клонирует mini.nvim при первом запуске
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

-- Инициализация менеджера плагинов mini.deps
require('mini.deps').setup({ path = { package = path_package } })
local add = MiniDeps.add

-- ============================================================================
-- БАЗОВЫЕ НАСТРОЙКИ VIM
-- ============================================================================
-- Leaders - клавиши-префиксы для пользовательских команд
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Внешний вид
vim.opt.termguicolors = true          -- Поддержка 24-bit цветов
vim.opt.number = true                 -- Номера строк
vim.opt.relativenumber = true         -- Относительная нумерация
vim.opt.cursorline = true             -- Подсветка текущей строки
vim.opt.signcolumn = 'yes'            -- Всегда показывать колонку для git/diagnostic знаков
vim.opt.wrap = false                  -- Не переносить длинные строки

-- Управление временными файлами
-- Отключаем временные файлы (swap/backup/undo) для минимизации конфликтов
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = false              -- Не сохранять историю отмен между сессиями

-- Отступы и табуляция (по умолчанию - для большинства языков)
vim.opt.expandtab = true              -- Использовать пробелы вместо табов
vim.opt.tabstop = 4                   -- Ширина табуляции
vim.opt.shiftwidth = 4                -- Размер отступа при >> и <<
vim.opt.softtabstop = 4               -- Количество пробелов при нажатии Tab

-- Поведение редактора
vim.opt.clipboard = 'unnamedplus'     -- Использовать системный буфер обмена
vim.opt.ignorecase = true             -- Игнорировать регистр при поиске
vim.opt.smartcase = true              -- Учитывать регистр, если в запросе есть заглавные буквы
vim.opt.scrolloff = 8                 -- Минимум строк сверху/снизу от курсора
vim.opt.sidescrolloff = 8             -- Минимум колонок слева/справа от курсора

-- ============================================================================
-- АВТОКОМАНДЫ
-- ============================================================================
-- Go использует табы вместо пробелов (стандарт gofmt)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function()
    vim.opt_local.expandtab = false   -- Использовать настоящие табы в Go
  end,
})

-- ============================================================================
-- ВНЕШНИЕ ПЛАГИНЫ
-- ============================================================================
-- Цветовая схема
-- Цветовая схема с прозрачностью
add('rebelot/kanagawa.nvim')

require('kanagawa').setup({
  compile = false,
  undercurl = true,
  dimInactive = false,
  terminalColors = true,
  theme = "dragon",                  -- "wave" (тёмная), "dragon" (тёмная тёплая), "lotus" (светлая)
  background = {
    dark = "wave",
    light = "lotus"
  },
})

-- vim.cmd.colorscheme('kanagawa')

add('folke/tokyonight.nvim')
require('tokyonight').setup()

vim.cmd.colorscheme('tokyonight')

-- Дополнительная прозрачность для всех элементов
vim.cmd([[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight NormalNC guibg=none
  highlight NormalFloat guibg=none
]])

-- Улучшенное отображение диагностики
add('rachartier/tiny-inline-diagnostic.nvim')
require('tiny-inline-diagnostic').setup()

-- Mason - менеджер LSP серверов (используется для установки gopls)
add('williamboman/mason.nvim')
require('mason').setup()

-- ============================================================================
-- MINI.NVIM: UI МОДУЛИ
-- ============================================================================
-- Иконки для файлов (должны быть загружены первыми)
require('mini.icons').setup()

-- Статусная строка внизу экрана
require('mini.statusline').setup()

-- ============================================================================
-- MINI.NVIM: НАВИГАЦИЯ
-- ============================================================================
-- Fuzzy finder - поиск файлов, grep, буферов, help
require('mini.pick').setup()
vim.keymap.set('n', '<leader>ff', '<cmd>Pick files<cr>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', '<cmd>Pick grep_live<cr>', { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', '<cmd>Pick buffers<cr>', { desc = 'Buffers' })
vim.keymap.set('n', '<leader>fh', '<cmd>Pick help<cr>', { desc = 'Help' })

-- Файловый менеджер
require('mini.files').setup()
vim.keymap.set('n', '<leader>e', function()
  require('mini.files').open()
end, { desc = 'File explorer' })

-- Быстрые прыжки по экрану (f/F/t/T усиления)
require('mini.jump').setup()

-- ============================================================================
-- MINI.NVIM: РЕДАКТИРОВАНИЕ
-- ============================================================================
-- Автозакрытие скобок, кавычек
require('mini.pairs').setup()

-- Работа с окружением (скобки, кавычки, теги) - sa/sd/sr
require('mini.surround').setup()

-- Комментирование кода - gcc, gc в visual mode
require('mini.comment').setup()

-- Расширенные text objects (функции, классы, аргументы)
require('mini.ai').setup()

-- ============================================================================
-- MINI.NVIM: АВТОДОПОЛНЕНИЕ И СНИППЕТЫ
-- ============================================================================
-- Сниппеты (должны быть до completion для интеграции с LSP)
require('mini.snippets').setup()

-- Автодополнение с интеграцией LSP и snippets
require('mini.completion').setup()

-- ============================================================================
-- MINI.NVIM: GIT ИНТЕГРАЦИЯ
-- ============================================================================
-- Визуализация изменений в gutter (знаки +/-/~)
require('mini.diff').setup({
  view = { style = 'sign' }
})

-- Git команды и интеграция
require('mini.git').setup()
-- ============================================================================
-- MINI.NVIM: ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================================
-- Дополнительные пикеры и утилиты (diagnostic, lsp, git_hunks и т.д.)
require('mini.extra').setup({})

-- ============================================================================
-- LSP КОНФИГУРАЦИЯ
-- ============================================================================
-- Включить gopls для Go-разработки
vim.lsp.enable('gopls')

-- Настройка keymaps и форматирования при подключении LSP
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp_config', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    
    -- Применяется только для gopls
    if client.name ~= 'gopls' then
      return
    end

    -- Вспомогательная функция для создания buffer-local keymaps
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
    end

    -- LSP навигация и информация
    map('n', 'K', vim.lsp.buf.hover, 'Показать документацию')
    map('n', 'gd', vim.lsp.buf.definition, 'Перейти к определению')
    map('n', 'gD', vim.lsp.buf.declaration, 'Перейти к объявлению')
    map('n', 'gi', vim.lsp.buf.implementation, 'Перейти к реализации')
    map('n', 'gr', vim.lsp.buf.references, 'Показать использования')
    map('n', 'gs', vim.lsp.buf.signature_help, 'Сигнатура функции')
    map('n', '<leader>D', vim.lsp.buf.type_definition, 'Определение типа')
    
    -- LSP действия
    map('n', '<leader>rn', vim.lsp.buf.rename, 'Переименовать')
    map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code Action')

    -- Форматирование и организация импортов при сохранении
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = args.buf,
      callback = function()
        -- Шаг 1: Организация импортов (удаление неиспользуемых, добавление недостающих)
        local params = vim.lsp.util.make_range_params()
        params.context = { only = { 'source.organizeImports' } }
        local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 3000)
        
        for cid, res in pairs(result or {}) do
          for _, r in pairs(res.result or {}) do
            if r.edit then
              local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or 'utf-16'
              vim.lsp.util.apply_workspace_edit(r.edit, enc)
            end
          end
        end

        -- Шаг 2: Форматирование кода (gofmt/gofumpt)
        vim.lsp.buf.format({ async = false, id = args.data.client_id })
      end,
    })
  end,
})

-- Настройка LSP handlers для красивых окон с rounded borders
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
  vim.lsp.handlers.hover,
  { border = 'rounded' }
)
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  { border = 'rounded' }
)

-- ============================================================================
-- DIAGNOSTICS КОНФИГУРАЦИЯ
-- ============================================================================
-- Настройка отображения диагностических сообщений (ошибки, предупреждения)
vim.diagnostic.config({
  virtual_text = false,              -- Отключить встроенный virtual text (используем tiny-inline-diagnostic)
  signs = true,                      -- Показывать знаки в signcolumn
  underline = true,                  -- Подчёркивать проблемные места
  update_in_insert = false,          -- Не обновлять в режиме вставки (для производительности)
  severity_sort = true,              -- Сортировать по важности
  float = {
    border = 'rounded',              -- Скруглённые углы для floating окон
    source = true,                   -- Показывать источник диагностики
  },
})

-- Keymaps для навигации по диагностике
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostic' })

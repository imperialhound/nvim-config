-- Implements integration of defined language servers and autocomplete
-- Inspired from :
-- https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/
-- https://github.com/valorl/dotfiles/blob/master/home/.config/nvim/lua/valorl/lazy/lsp.lua
-- https://github.com/VonHeikemen/dotfiles/blob/master/my-configs/neovim/lua/specs/lsp.lua


local Plugin = {"neovim/nvim-lspconfig"}

Plugin.dependencies = {
        {"williamboman/mason.nvim"},
        {"williamboman/mason-lspconfig.nvim"},
        {"hrsh7th/nvim-cmp"},
        {"hrsh7th/cmp-nvim-lsp"},
        {"hrsh7th/cmp-buffer"},
        {"hrsh7th/cmp-path"},
        {"hrsh7th/cmp-cmdline"},
        {"L3MON4D3/LuaSnip"},
        {"saadparwaiz1/cmp_luasnip"},
        {"j-hui/fidget.nvim"}, -- Neovim notifications and LSP progress messages
}

function Plugin.config()
  local lspconfig = require('lspconfig')
  
  -- Create autocommand to automatically update imports of go files
  -- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#imports-and-formatting
  vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = "*.go",
    callback = function()
      local params = vim.lsp.util.make_range_params()
      params.context = {only = {"source.organizeImports"}}
      -- buf_request_sync defaults to a 1000ms timeout. Depending on your
      -- machine and codebase, you may want longer. Add an additional
      -- argument after params if you find that you have to write the file
      -- twice for changes to be saved.
      -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
      local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
      for cid, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
          if r.edit then
            local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
            vim.lsp.util.apply_workspace_edit(r.edit, enc)
          end
        end
      end
      vim.lsp.buf.format({async = false})
    end
  })
  -- Create autocommand to set keybindings each time an LspAttach event occurs
  -- An lspAttach event is when a language server is attached to a buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function()
        local opts = {
            buffer = true,
            noremap = true
        }
        
        -- Jump to definition
        vim.keymap.set("n", "<leader>gg", vim.lsp.buf.definition, opts)
        
        -- List all implentations for the symbol under the cursor
        vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)
        
        -- Jump to declaration
        vim.keymap.set("n", "<leader>gd", vim.lsp.buf.declaration, opts)
        
        -- Displays a functions singature information
        vim.keymap.set("n", "<leader>gs", vim.lsp.buf.signature_help, opts)
        
        -- List all references
        vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)

        -- Rename all references to the symbol under the cursor
        vim.keymap.set("n", "<leader>gn", vim.lsp.buf.rename, opts)

        -- Displays hover information about the symbol under the cursor
        vim.keymap.set("n", "<leader>gh", vim.lsp.buf.hover, opts)

        -- Selects a code action available at the current cursor in position
        vim.keymap.set("n", "<leader>gca", vim.lsp.buf.code_action, opts)

        -- Move to previous diagnostic
        vim.keymap.set("n", "<leader>gdp", vim.diagnostic.goto_prev, opts)

        -- Move to next diagnostic
        vim.keymap.set("n", "<leader>gdn", vim.diagnostic.goto_next, opts)

        -- Show diagnostics in a floating window
        vim.keymap.set("n", "<leader>gdf", vim.diagnostic.goto_prev, opts)
    end
  }) 
    -- Autocompletion and language server setup
    local cmp = require("cmp")
    local cmp_lsp = require("cmp_nvim_lsp")
    local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_lsp.default_capabilities())

    require("fidget").setup({})

    -- Mason is a NVIM package manager for setting up LSP servers, DAP servers, linters and formatters
    require("mason").setup()
    require("mason-lspconfig").setup({
        ensure_installed = {
            "terraformls", "tflint",
            "gopls", "golangci_lint_ls",
            "pyright",
            "yamlls",
            "lua_ls",
            "rust_analyzer",
            "tsserver",
        },
        handlers = {
            function(server_name) -- default handler (optional)

                require("lspconfig")[server_name].setup {
                    capabilities = capabilities
                }
            end,

            ["lua_ls"] = function()
                local lspconfig = require("lspconfig")
                lspconfig.lua_ls.setup {
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim", "it", "describe", "before_each", "after_each" },
                            }
                        }
                    }
                }
            end,
        }
    })

    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    cmp.setup({
        snippet = {
            expand = function(args)
                require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            end,
        },
        -- keybindings for seleting completions
        mapping = cmp.mapping.preset.insert({
            ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
            ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
            ['<C-y>'] = cmp.mapping.confirm({ select = true }),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<C-u>'] = cmp.mapping.scroll_docs(-4),
            ['<C-d>'] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ['<Tab>'] = cmp.mapping(function(fallback)
                local col = vim.fn.col('.') - 1

                if cmp.visible() then
                  cmp.select_next_item(cmp_select)
                elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                  fallback()
                else
                  cmp.complete()
                end
            end, {'i', 's'}),
          }),
        
        -- Data sources nvim-cmp will use to populate the completion list
        sources = cmp.config.sources({
            { name = 'nvim_lsp' }, -- Suggestions from language server
            { name = 'luasnip' }, -- For luasnip users.
        }, {
            { name = 'buffer' }, -- Suggest words found in current buffer
        })
    })

    
    vim.diagnostic.config({
        -- update_in_insert = true,
        float = {
            focusable = false,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
        },
    })

end

return Plugin

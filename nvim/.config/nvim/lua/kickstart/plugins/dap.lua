return {
    {
          "mfussenegger/nvim-dap",
          lazy = true,
          -- Copied from LazyVim/lua/lazyvim/plugins/extras/dap/core.lua and
          -- modified.
          config = function()
              local dap = require('dap')
              dap.adapters.delve = function(callback, config)
                  if config.mode == 'remote' and config.request == 'attach' then
                      callback({
                          type = 'server',
                          host = config.host or '127.0.0.1',
                          port = config.port or '38697'
                      })
                  else
                      callback({
                          type = 'server',
                          port = '${port}',
                          executable = {
                              command = 'dlv',
                              args = { 'dap', '-l', '127.0.0.1:${port}', '--log', '--log-output=dap' },
                              detached = vim.fn.has("win32") == 0,
                          }
                      })
                  end
              end
              -- dap.adapters.delve = {
              --   type = "server",
              --   host = "127.0.0.1",
              --   port = 38697,
              -- }


              -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
              dap.configurations.go = {
                {
                  type = "delve",
                  name = "Debug",
                  request = "launch",
                  program = "${workspaceFolder}/cmd/api",
                  showLog = true,
				},
                {
                  type = "delve",
                  name = "Debug test", -- configuration for debugging test files
                  request = "launch",
                  mode = "test",
                  program = "${fileDirname}",
                  cwd = "${workspaceFolder}"
                },
                -- works with go.mod packages and sub packages 
                {
                  type = "delve",
                  name = "Debug test (go.mod)",
                  request = "launch",
                  mode = "test",
                  program = "./${relativeFileDirname}"
                } 
              } 
          end,
          keys = {
            {
              "<leader>db",
              function() require("dap").toggle_breakpoint() end,
              desc = "Toggle Breakpoint"
            },

            {
              "<leader>dc",
              function() require("dap").continue() end,
              desc = "Continue"
            },

            {
              "<leader>dC",
              function() require("dap").run_to_cursor() end,
              desc = "Run to Cursor"
            },

            {
              "<leader>dT",
              function() require("dap").terminate() end,
              desc = "Terminate"
            },
            {
              "<leader>dus",
              function ()
                local widgets = require('dap.ui.widgets');
                local sidebar = widgets.sidebar(widgets.scopes);
                sidebar.open();
              end,
              desc = "Open debugging sidebar"
            },
          },
          -- vim.fn.sign_define("DapBreakpoint", {text = "⏺", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl="DapBreakpoint"})
        },
        {
          "jay-babu/mason-nvim-dap.nvim",
          opts = {
            -- This line is essential to making automatic installation work
            -- :exploding-brain
            handlers = {},
            automatic_installation = {
              -- These will be configured by separate plugins.
              exclude = {
                "delve",
                "python",
              },
            },
            -- DAP servers: Mason will be invoked to install these if necessary.
            ensure_installed = {
              "bash",
              "python",
            },
          },
          dependencies = {
            "mfussenegger/nvim-dap",
            "williamboman/mason.nvim",
          },
        },
        {
          "leoluz/nvim-dap-go",
          dependencies = {
            "mfussenegger/nvim-dap",
          },
          config = function()
              local dap_go = require('dap-go')
              dap_go.setup({
                -- delve = {
                  -- Ensure dlv is in your PATH for Neovim.
                  -- If not, uncomment and set the path to your dlv executable.
                  -- path = vim.fn.expand("~") .. "/go/bin/dlv", -- Example for GOPATH install
                  -- path = "/usr/local/bin/dlv", -- Example for system install
                  -- For more verbose dlv logging (helps debug dlv issues):
                  -- dlv_flags = {"--log", "--log-output=dap,debugger,rpc"},
                -- },
                -- nvim-dap-go provides default configurations.
                -- If you want to add your own or override them, you can use dap_configurations:
                dap_configurations = {
                  {
                    type = "delve",
                    name = "My Custom Launch",
                    request = "launch",
                    program = "${fileDirname}", -- Example
                  }
                }
                -- By default, nvim-dap-go sets up configurations like:
                -- 1. Launch current package: `program = "${fileDirname}"`
                -- 2. Debug test (used by debug_test()): `program = "${fileDirname}", mode = "test"`
              })

              -- You can verify if configurations are loaded:
              vim.defer_fn(function()
                local go_configs = require('dap').configurations.go
                if go_configs and #go_configs > 0 then
                  print("nvim-dap-go configurations loaded:")
                  for _, cfg in ipairs(go_configs) do
                    print("- " .. cfg.name)
                  end
                else
                  print("WARN: No nvim-dap-go configurations found after setup.")
                end
              end, 1000) -- Defer to allow setup to complete
            end,
        },
        {
          "theHamsta/nvim-dap-virtual-text",
          config = true,
          dependencies = {
            "mfussenegger/nvim-dap",
          },
        },
        {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        config = function(_, opts)
            local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python3"
            require("dap-python").setup(path)
            -- require("core.utils").load_mappings("dap_python")
        end,
    },
{
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      { "fredrikaverpil/neotest-golang", version = "*" }, -- Installation
    },
    config = function()
      local neotest_golang_opts = {}  -- Specify custom configuration
      require("neotest").setup({
        adapters = {
          require("neotest-golang")(neotest_golang_opts), -- Registration
        },
      })
    end,
    keys = {
      {
        "<leader>dt",
        function()
          require("neotest").run.run({ suite = false, strategy = "dap" })
        end,
        desc = "Debug nearest test",
      },
    },
  },
}



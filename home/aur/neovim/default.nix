{ config
, lib
, pkgs }:

#TODO: make the "empty buffer" switch to the dashboard immediately

let
  mkRaw = config.lib.nixvim.mkRaw;
in {
  enable = true;
  viAlias = true;
  vimAlias = true;
  enableMan = true;
  defaultEditor = true;

  nixpkgs.useGlobalPackages = true;

  opts = {
    number = true;
    relativenumber = true;
    expandtab = true;
    smartcase = true;
    incsearch = true;
    breakindent = true;
    list = true;
    showmode = false;
    shiftwidth = 4;
    tabstop = 4;
    scrolloff = 8;
    colorcolumn = "120"; # lol why does this need to be a string
    clipboard = "unnamedplus";

    listchars = {
      multispace = "⋅";
      trail = "␣";
      tab = "» ";
      extends = "›";
      precedes = "‹";
    };
  };

  globals = {
    mapleader = " ";
  };

  keymaps = [
    {
      key = "o"; #TODO: this isn't working with Shift+o, it does the normal Shift+o behaviour rah
      action = "k";
    }
    {
      key = "k";
      action = "h";
    }
    {
      key = "l";
      action = "j";
    }
    {
      key = ";";
      action = "l";
    }
    {
      key = "<leader>g";
      action = "<cmd>XplrPicker %:p:h<CR>";
      options.desc = "Opens XPLR";
    }
    {
      key = "<leader>f";
      action = "<cmd>Telescope find_files<CR>";
      options.desc = "Opens the Telescope file picker";
    }
    {
      key = "<leader>t";
      action = "<cmd>Telescope live_grep<CR>";
      options.desc = "Opens the Telescope text search";
    }
    {
      key = "<leader>v";
      action = "<cmd>Telescope zoxide<CR>";
      options.desc = "Opens the Telescope directory picker";
    }
    {
      key = "<leader>c";
      action = "<cmd>LazyGit<CR>";
      options.desc = "Opens lazygit";
    }
    {
      key = "<leader>n";
      action = "<cmd>Navbuddy<CR>";
      options.desc = "Opens the symbol navigation window";
    }
    {
      key = "<leader>b";
      action = "<cmd>BufferPick<CR>";
      options.desc = "Opens the tab picker";
    }
    {
      key = "<leader>q";
      action = "<cmd>BufferClose<CR>";
      options.desc = "Closes the current tab";
    }
    {
      key = "<leader>Q";
      action = "<cmd>BufferCloseAllButCurrent<CR>";
      options.desc = "Closes all other tabs";
    }
    {
      key = "<leader>EE";
      action = "<cmd>execute \"bufdo w | BufferClose\" | q<CR>";
      options.desc = "Saves all open tabs individually and then quits";
    }
    {
      key = "<leader>j";
      action = "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR })<CR>";
      options.desc = "Hop forwards";
    }
    {
      key = "<leader>J";
      action = "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR })<CR>";
      options.desc = "Hop backwards";
    }
    {
      key = "<leader>i";
      action = mkRaw ''
        function()
          local file = vim.fn.expand("%:p")
          local first_line = vim.fn.getline(1)

          if string.match(first_line, "^#!/") then
            local escaped_file = vim.fn.shellescape(file)
            vim.cmd("silent! !chmod +x " .. escaped_file)
            vim.cmd("TermExec cmd=" .. escaped_file)
          else
            vim.cmd("echo 'Cannot execute file, missing shebang.'")
          end
        end
      '';
      options.desc = "Executes the current file in the terminal";
    }
    {
      key = "<leader>.";
      action = "<cmd>lua require'dap'.toggle_breakpoint()<CR>";
      options.desc = "Toggles a breakpoint on the current line";
    }
    {
      key = "<leader>,";
      action = "<cmd>lua require'dap'.step_over()<CR>";
      options.desc = "Step over line";
    }
    {
      key = "<leader>l";
      action = "<cmd>lua require'dap'.step_into()<CR>";
      options.desc = "Step into line";
    }
    {
      key = "<C-s>";
      action = "<cmd>lua require'dap'.continue()<CR>";
      options.desc = "Debugger";

      mode = [
        "n"
        "v"
      ];
    }
    {
      key = "<C-d>";
      action = "<cmd>lua require'dap'.repl.toggle()<CR>";
      options.desc = "Toggles the DAP REPL";

      mode = [
        "n"
        "v"
      ];
    }
    {
      key = "<C-a>";
      action = "<cmd>ToggleTerm<CR>";
      options.desc = "Toggles the terminal";

      mode = [
        "n"
        "t"
        "v"
      ];
    }
    {
      key = "<C-c>";
      action = "<cmd>MurenToggle<CR>";
      options.desc = "Toggles the advanced find-and-replace window";

      mode = [
        "n"
        "v"
        "i"
      ];
    }
  ];

  filetype = {
    filename = {
      "flake.lock" = "json";
    };

    extension = {
      nix = "nix";
      xaml = "xml";
      axaml = "xml";
    };
  };

  autoCmd = [
    {
      event = [ "BufWritePost" ];
      pattern = [ "*.java" ];
      callback = mkRaw ''
        function()
          pcall(vim.lsp.codelens.refresh)
        end
      '';
    }
    {
      event = [ "BufLeave" ];
      pattern = [ "term://*" ];
      command = "stopinsert";
    }
  ];

  colorschemes.catppuccin = {
    enable = true;
    settings.flavour = "mocha";
  };

  extraPlugins = with pkgs; [
    (vimUtils.buildVimPlugin {
      name = "xplr.vim";

      src = fetchFromGitHub {
        owner = "aurakle";
        repo = "xplr.vim";
        rev = "f9bc3800a213d5cb7eaf979e71a96b1f43a81a66";
        hash = "sha256-eLF//fM3+Qxj/fJ1ydrMCrXAvX0kX8Yl7Iz181Fc2Xo=";
      };
    })
    (vimUtils.buildVimPlugin {
      name = "telescope-zoxide.nvim";

      src = fetchFromGitHub {
        owner = "aurakle";
        repo = "telescope-zoxide.nvim";
        rev = "fbc14fbac6d21a8d133526158f69190d62a5d8bf";
        hash = "sha256-q6ojZiCnDjZzxCmhG08uGSoK7BRHJXdTdVgePj9tgKI=";
      };
    })
  ];

  plugins = {
    todo-comments.enable = true;
    toggleterm.enable = true;
    refactoring.enable = true;
    scope.enable = true;
    which-key.enable = true;
    hex.enable = true;
    gitignore.enable = true;
    lz-n.enable = true;
    compiler.enable = true;
    lsp-lines.enable = true;
    web-devicons.enable = true;
    hmts.enable = true; #TODO: possibly causes issues?
    lazygit.enable = true;
    nvim-surround.enable = true;
    git-conflict.enable = true;
    treesitter.enable = true;
    hop.enable = true;
    direnv.enable = true;
    twilight.enable = true;
    rainbow-delimiters.enable = true;
    render-markdown.enable = true;
    telescope.enable = true;
    intellitab.enable = true;
    inc-rename.enable = true;
    illuminate.enable = true;
    comment.enable = true;
    dressing.enable = true;
    neocord.enable = true;
    notify.enable = true;
    friendly-snippets.enable = true;
    godot.enable = true;
    dap-ui.enable = true;
    typst-preview.enable = true;
    flutter-tools.enable = true;
    barbecue.enable = true;
    actions-preview.enable = true;
    ccc.enable = true;
    dap-lldb.enable = true;
    dap-virtual-text.enable = true;
    fidget.enable = true;
    guess-indent.enable = true;

    barbar = {
      enable = true;

      settings = {
        sidebar_filetypes = {
          NvimTree = true;
        };
      };
    };

    # nvim-tree = {
    #   enable = true;
    #
    #   openOnSetupFile = true;
    #   hijackCursor = true;
    #   selectPrompts = true;
    #
    #   updateFocusedFile = {
    #     enable = true;
    #     updateRoot = true;
    #   };
    #
    #   view = {
    #     width = 50;
    #   };
    #
    #   renderer = {
    #     addTrailing = true;
    #     groupEmpty = true;
    #     symlinkDestination = true;
    #     indentWidth = 2;
    #     highlightOpenedFiles = "all";
    #   };
    # };

    dap = {
      enable = true;

      configurations = {
        java = [
          {
            name = "Attach Debugger";
            type = "java";
            request = "attach";
            hostName = "localhost";
            port = 5005;
          }
          {
            name = "Launch Debug";
            type = "java";
            request = "launch";
          }
        ];
      };
    };

    lsp = {
      enable = true;
      inlayHints = true;

      keymaps = {
        diagnostic = {
          "<leader>d" = "open_float";
          "<leader>s" = "goto_next";
          "<leader>w" = "goto_prev";
        };
        lspBuf = {
          gd = "definition";
          gr = "references";
          gi = "implementation";
          cs = "code_action";
          rn = "rename";
          "<C-k>" = "signature_help";
        };
      };

      onAttach = ''
        pcall(vim.lsp.codelens.refresh)
      '';

      servers = {
        nixd = {
          enable = true;

          settings = {
            formatting.command = [
              "nixfmt"
            ];

            diagnostic.suppress = [
              "sema-escaping-with"
            ];
          };
        };

        tinymist = {
          enable = true;
        };

        metals = {
          enable = true;
        };

        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;

          settings = {
            checkOnSave = false;

            completion = {
              autoimport = {
                enable = true;
              };
            };

            lens = {
              enable = true;

              implementations = {
                enable = true;
              };

              references = {
                adt.enable = true;
                enumVariant.enable = true;
                method.enable = true;
                trait.enable = true;
              };
            };

            inlayHints = {
              renderColons = true;
              maxLength = 25;

              bindingModeHints = {
                enable = false;
              };

              chainingHints = {
                enable = true;
              };

              closingBraceHints = {
                enable = true;
                minLines = 25;
              };

              closureReturnTypeHints = {
                enable = "never";
              };

              lifetimeElisionHints = {
                enable = "never";
                useParameterNames = false;
              };

              parameterHints = {
                enable = true;
              };

              reborrowHints = {
                enable = "never";
              };

              typeHints = {
                enable = true;
                hideClosureInitialization = false;
                hideNamedConstructor = false;
              };
            };
          };
        };

        hls = {
          enable = true;
          installGhc = true;
        };

        clangd = {
          enable = true;

          settings = {
            InlayHints = {
              Designators = true;
              Enabled = true;
              ParameterNames = true;
              DeducedTypes = true;
            };

            fallbackFlags = [ "-std=c++20" ];
          };
        };

        csharp_ls = {
          enable = true;
        };

        kotlin_language_server = {
          enable = true;

          settings = {
            hints = {
              typeHints = true;
              parameterHints = true;
              chaineHints = true;
            };
          };
        };

        volar = {
          enable = true;
          tslsIntegration = true;
        };

        ts_ls = {
          enable = true;
        };

        typos_lsp = {
          enable = true;
        };

        bashls = {
          enable = true;
        };

        yamlls = {
          enable = true;
        };

        systemd_ls = {
          enable = true;
        };

        sqls = {
          enable = true;
        };

        # html = {
        #   enable = true;
        # };

        jdtls = {
          onAttach.function = ''
            require('jdtls.dap').setup_dap({ hotcodereplace = 'auto' })
            require('jdtls.dap').setup_dap_main_class_configs()
            vim.lsp.codelens.refresh()
          '';

          extraOptions = {
            signatureHelp = {
              enabled = true;
            };

            contentProvider = {
              preferred = "fernflower";
            };

            sources = {
              organizeImports = {
                starThreshold = 5;
                staticStarThreshold = 5;
              };
            };

            codeGeneration = {
              toString = {
                template = "\${object.className}{\${member.name()}=\${member.value}, \${otherMembers}}";
              };

              useBlocks = true;
            };

            flags = {
              allow_incremental_sync = true;
            };
          };

          settings = {
            java = {
              eclipse = {
                downloadSources = true;
              };

              gradle = {
                enabled = true;
              };

              maven = {
                downloadSources = true;
              };

              implementationsCodeLens = {
                enabled = true;
              };

              referencesCodeLens = {
                enabled = true;
              };

              references = {
                includeDecompiledSources = true;
              };

              inlayHints = {
                parameterNames = {
                  enabled = "all";
                };
              };

              codeGeneration = {
                toString = {
                  template = "\${object.className}{\${member.name()}=\${member.value}, \${otherMembers}}";
                };

                hashCodeEquals = {
                  useJava7Objects = true;
                };

                useBlocks = true;
              };
            };
          };
        };
      };
    };

    jdtls = {
      enable = true;

      settings = {
        cmd = [
          "jdtls"
          "-data"
          (mkRaw "'${config.home.homeDirectory}/.local/share/jdtls/workspace' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')")
          "-configuration"
          "${config.home.homeDirectory}/.config/jdtls/config"
        ];

        init_options = {
          bundles = mkRaw "{ vim.fn.glob('${./.}/com.microsoft.java.debug.plugin-*.jar'), }";
        };
      };
    };

    cmp = {
      enable = true;
      autoEnableSources = true;

      settings = {
        sources = [
          { name = "nvim_lsp"; }
          { name = "nvim_lsp_signature_help"; }
          { name = "path"; }
          { name = "buffer"; }
          { name = "luasnip"; }
          { name = "yanky"; }
          { name = "dap"; }
        ];

        snippet = {
          expand = "function(args) require('luasnip').lsp_expand(args.body) end";
        };

        view.entries = {
          name = "custom";
          selection_order = "near_cursor";
        };

        mapping = {
          "<Left>" = mkRaw ''cmp.mapping(function(fallback)
            cmp.abort()
            fallback()
          end, {'i'})'';
          "<S-Left>" = mkRaw ''cmp.mapping(function(fallback)
            local luasnip = require('luasnip')
            cmp.abort()

            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, {'i'})'';
          "<Right>" = mkRaw ''cmp.mapping(function(fallback)
            cmp.abort()
            fallback()
          end, {'i'})'';
          "<S-Right>" = mkRaw ''cmp.mapping(function(fallback)
            local luasnip = require('luasnip')
            cmp.abort()

            if luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, {'i'})'';
          "<CR>" = mkRaw ''cmp.mapping(function(fallback)
            local luasnip = require('luasnip')

            if cmp.visible() then
              if luasnip.expandable() then
                luasnip.expand()
              else
                local entry = cmp.get_selected_entry()

                if not entry then
                  cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                end

                cmp.confirm()
              end
            else
              fallback()
            end
          end, {'i'})'';
          "<Tab>" = mkRaw ''cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, {'i'})'';
          "<S-Tab>" = mkRaw ''cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, {'i'})'';
        };
      };
    };

    luasnip = {
      enable = true;

      fromVscode = [
        {
          lazyLoad = false;
        }
      ];
    };

    navbuddy = {
      enable = true;
      lsp.autoAttach = true;

      mappings = {
        "<DOWN>" = "next_sibling";
        "<UP>" = "previous_sibling";
        "<LEFT>" = "parent";
        "<RIGHT>" = "children";
      };
    };

    muren = {
      enable = true;
      #TODO: probably needs configuring
    };

    lightline = {
      enable = true;

      settings = {
        colorscheme = "catppuccin";
      };
    };

    hardtime = {
      enable = true;

      settings = {
        max_time = 0;

        disabled_keys = {
          "<Down>" = mkRaw "{}";
          "<Left>" = mkRaw "{}";
          "<Right>" = mkRaw "{}";
          "<Up>" = mkRaw "{}";
        };
      };
    };

    gitsigns = {
      enable = true;

      settings = {
        current_line_blame = true;
        current_line_blame_opts.virt_text_pos = "right_align";
        diff_opts.algorithm = "minimal";

        signs = {
          add.text = " ";
          untracked.text = "";
          change.text = " ";
          changedelete.text = " ";
          delete.text = " ";
          topdelete.text = "󱂥 ";
        };
      };
    };

    specs = {
      enable = true;
      #TODO: configure
    };

    indent-blankline = {
      #TODO: doesn't work nice with neovide
      # enable = true;

      lazyLoad = {
        enable = true;

        settings = {
          event = [
            "BufNewFile"
            "BufReadPre"
            "FileReadPre"
          ];
        };
      };

      settings = {
        whitespace = {
          remove_blankline_trail = false;
        };

        scope = {
          show_start = true;
          show_exact_scope = true;
          show_end = false;
        };

        exclude = {
          filetypes = [
            "dashboard"
            "yaml"
            "yml"
          ];
        };
      };

      luaConfig.post = ''
        local highlight = {
            "RainbowRed",
            "RainbowYellow",
            "RainbowBlue",
            "RainbowOrange",
            "RainbowGreen",
            "RainbowViolet",
            "RainbowCyan",
        }

        local hooks = require "ibl.hooks"
        -- create the highlight groups in the highlight setup hook, so they are reset
        -- every time the colorscheme changes
        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
            vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
            vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
            vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
            vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
            vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
            vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
        end)

        vim.g.rainbow_delimiters = { highlight = highlight }
        require("ibl").setup { scope = { highlight = highlight } }

        hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
      '';
    };

    dashboard = {
      enable = true;

      settings = {
        theme = "doom";

        config = {
          header = let
            moth = [
              "                                                 "
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡈⢷⣄⠀⠀⣠⡶⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠄"
              "⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⣿⣿⠃⠀⣿⣿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀"
              "⠀⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⠿⠿⠟⠛⠋⠉⣁⣠⣴⣶⣿⠟⠀⠀⠻⣿⣷⣦⣤⣈⠉⠙⠛⠛⠿⠿⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀"
              "⠀⠀⠀⠀⠈⠛⠛⠉⠉⠀⠀⠀⣀⣠⣴⣶⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠈⢻⣿⣿⣿⣿⣶⣦⣄⣀⠀⠀⠀⠈⠉⠙⠛⠁⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣶⣿⣿⣿⣿⣿⣿⣿⡿⠋⢠⠀⠀⠀⠀⠀⠀⢀⠈⠻⣿⣿⣿⣿⣿⣿⣿⣶⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⢿⣿⣿⣿⡿⠋⢀⣼⣿⣆⠀⠀⠀⠀⣠⣿⣧⡀⠙⢿⣿⣿⣿⣿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠋⠀⣠⣾⠟⣻⣿⣷⡆⠀⣾⣿⣿⠻⢿⣦⠀⠙⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠞⠋⠁⢠⣿⣿⣿⡇⠀⣿⣿⣿⣇⠀⠉⠻⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⢀⣿⠋⣿⣿⡇⠀⣿⣿⠙⢿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢜⠁⠀⣿⣿⡇⠀⣿⣿⠀⠈⠳⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⡇⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠃⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⠀⠀⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⠀⠀⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
            ];
            nixvim = [
              "                                            "
              "███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗"
              "████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║"
              "██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║"
              "██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║"
              "██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║"
              "╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝"
            ];
            women = [
              "                                                                                       "
              "⢰⡿⠛⢿⡆⠀⠀⠀⠀⢰⡾⠛⢿⡆⢰⡿⠛⣷⡄⢰⡿⠛⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠘⣷⣤⣾⠇⠀⠀⠀⠀⢸⡇⠀⢸⡇⢸⣷⣤⣿⠃⢸⡇⠀⣿⣤⣶⣦⡄⠀⣀⣤⣤⣤⣀⡀⠀⠀⠀⠀⢀⣤⣤⡀⠀⠀⠀⠀⠀⣠⣤⣄⠀⣀⣤⣤⣤⣄⡀⠀⣀⣤⣤⣠⣤⣄⣀⣠⣤⣤⣀⠀⠀⢀⣠⣤⣤⣄⣀⠀⠀⣠⣤⣄⣤⣤⣄⡀⠀"
              "⢸⡟⠉⢹⡇⠀⠀⠀⠀⢸⡇⠀⢸⡇⢸⡏⠉⣿⡇⢸⡇⠀⣿⠋⢀⣼⣷⣾⠟⢁⣀⡈⠙⢻⡆⠀⠀⠀⣿⡋⠙⣿⣴⡿⣿⣷⣾⡟⢿⣿⣿⠏⠁⣀⡈⠙⢿⣤⣿⠁⠙⢏⡁⠉⠛⢋⡁⠈⢻⣇⣰⡿⠋⢀⣀⡉⠛⣷⣸⡏⠁⠹⣋⡀⠙⣿⡆"
              "⢸⡇⠀⢸⡇⠀⠀⠀⠀⢸⡇⠀⢸⡇⢸⡇⠀⣿⡇⢸⡇⠀⠀⠀⢿⣏⢸⡇⠀⠸⠿⠿⠀⢨⣿⠀⠀⠀⠸⣧⠀⢹⡿⢁⡀⠹⣿⠀⢰⣿⡇⠀⢸⣿⡧⠀⢸⣿⣿⠀⠀⣿⣿⠀⠀⣿⣿⠀⠀⣿⣿⠀⠀⠿⠿⠇⠀⣿⣿⡇⠀⢸⣿⡇⠀⢸⡇"
              "⢸⡇⠀⢸⡇⠀⠀⠀⠀⢸⡇⠀⢸⡇⢸⡇⠀⢻⡇⢸⡇⠀⣶⡄⠈⢿⣾⣇⠀⢸⣿⣿⠿⢿⡇⠀⠀⠀⠀⢻⣆⠀⠁⢸⣷⠀⠁⢠⣿⢿⡇⠀⢸⣿⡷⠀⢸⣿⣿⠀⠀⣿⣿⠀⠀⣿⣿⠀⠀⣿⣿⡀⠀⣿⣿⡿⠿⣿⣸⡇⠀⢸⣿⡇⠀⢸⡇"
              "⢸⣧⣀⣼⡇⠀⠀⠀⠀⢸⣧⣀⣼⡇⢸⣇⣀⣿⠀⢸⣇⣀⣿⣿⣤⣨⣿⢿⣦⣀⣉⣁⣠⣼⠇⠀⠀⠀⠀⠈⢿⣄⣠⣿⢿⣧⣰⣿⠇⠈⢿⣦⣀⣉⣁⣠⣿⠋⣿⣀⣰⡿⣿⣄⣠⡿⣿⣄⣠⡿⠹⣷⣄⣈⣉⣀⣤⡿⢹⣧⣀⣼⡿⣧⣀⣿⡇"
              "⠀⠙⠛⠋⠀⠀⠀⠀⠀⠀⠉⠉⠉⠀⠀⠉⠉⠉⠀⠀⠉⠉⠁⠈⠉⠉⠁⠀⠉⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠉⠁⠀⠉⠀⠈⠀⠀⠀⠉⠙⠛⠋⠉⠀⠀⠈⠉⠉⠁⠈⠉⠉⠁⠈⠉⠉⠁⠀⠀⠉⠉⠉⠉⠁⠀⠀⠉⠉⠉⠀⠉⠉⠉⠀"
            ];
            girlkisser = [
              "                                                                                                                          "
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣴⣴⡀⣠⣷⣄⢠⣶⣶⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣶⣦⡆⠀⠀⠀⠀⢠⣶⣶⣤⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⠛⢽⣿⡧⢾⣿⣿⠃⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣷⡟⠀⠀⠀⠀⢸⣿⣿⠋⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⢠⣶⣶⣶⣄⠀⠀⢠⣿⣾⣷⣖⠀⠀⢠⣿⣾⣷⣔⠀⠀⢠⣿⣶⣷⣔⠂⠀⢠⣿⣶⣷⣄⠀⠀⢠⣿⣶⣿⣆⠀⠀⠀⠀⢰⣷⣶⡦⢀⣶⣶⣦⣀⣴⣿⣾⣧⡀⠀⣶⣶⡇⢰⣶⣾⡇⠀⠀⠀⢸⣿⣿⣅⢤⣤⡠⣽⣿⣿⣀⣦⣶⣶⡶⢃⣴⣷⣥⣀⡀⠀⠀⠀⢀⣶⣶⣤⣦⡞⢄⣿⣿⣿⢵⣶⣶⣄⣤⢸⣿⣿⣧⣀⣼⣶⣾⣦⡀⠀"
              "⠀⢀⣴⣿⣿⠿⣿⣿⣧⣴⣿⣿⠿⣿⣿⣷⣴⣿⣿⠿⣿⣿⣷⣴⣿⣿⡿⣿⣿⣷⣴⣿⣿⠿⣿⣿⣷⣴⣿⣿⠿⡻⣿⣷⡀⠀⠀⠉⣿⣿⣷⣸⣿⣿⣽⣿⣿⡟⢻⢿⣿⣯⣿⣿⡇⢸⣿⣿⠁⠀⠀⠀⢸⣿⣿⣷⢾⣿⠴⣿⣿⣿⣿⡿⡫⢡⣾⣯⣤⣠⣽⣿⡇⠀⠀⠀⣼⣿⣿⢿⣿⣿⣩⣿⣾⣿⢫⣿⣿⣿⡿⢸⣿⣿⣞⣽⣿⣿⣿⠟⠁⠀"
              "⠀⠘⢿⣿⣿⣀⣿⣿⣿⢿⣿⣿⣀⣿⣿⣿⢿⣿⣿⣀⣿⣿⣿⢿⣿⣿⣄⣿⣿⣿⣿⣿⣧⣁⣾⣿⣿⣿⣿⣿⣆⣵⣿⣿⠇⠀⠀⠀⢸⣿⣿⣿⣿⠓⠻⣿⣿⣇⢸⣿⣿⣿⣿⣿⣧⣸⣿⣿⠀⠀⠀⠀⢸⣿⣿⣷⢾⣿⣾⢾⣿⣿⣿⣿⣿⣼⣿⣿⣶⣶⣾⣤⣥⠀⠀⠸⣿⣿⣿⣤⣿⣿⡔⣿⣿⣿⢬⣿⣿⡇⠀⢸⣿⣿⠽⢹⣿⣿⣿⣷⣦⠀"
              "⠀⠀⠘⢿⣿⣿⣿⡿⠃⠘⢿⣿⣿⣿⡿⠃⠘⠿⣿⣿⣿⡿⠇⠈⠻⣿⣿⣿⡿⡇⠈⠻⣿⣿⣿⡿⡏⠈⠻⣿⣿⣿⡿⠏⠀⠀⠀⠀⠀⢿⣿⣿⡟⠀⠀⠻⣿⣿⣿⣿⡟⠀⠻⣿⣿⣿⣿⠟⠀⠀⠀⠀⢸⣿⣿⡊⢻⣿⣬⢹⣿⣿⠈⣿⣿⣷⡛⢿⣿⣿⡿⠟⠁⠀⠀⠀⠻⢿⣿⠿⣿⣿⡆⢸⣿⣿⡇⣿⣿⡇⠀⢸⣿⣿⡇⠧⣿⣿⣿⡿⠁⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣷⣶⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠛⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠛⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠤⠀⠀⠀⠀⠀⠀⠀⠠⠄⠀⠀⢶⠄⠀⠀⠀⠀⠀⠤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣦⠀⠀⠀⠀⠀⣿⣿⣿⠸⣿⣿⡇⠀⠀⠀⢰⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⠀⠀⣀⠀⠀⣀⠀⠀⠀⠀⠀⣀⠀⠀⠀⡄⠀⠀⠀⠀⠀⠀⡀⠀⠀⣠⠀⣸⣿⣿⠟⣁⣄⠀⠀⢀⣿⣿⣧⢸⣿⣿⡇⠀⠀⠀⢸⣿⣿⠏⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⣿⣿⣇⣼⣿⣿⣾⣿⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⡇⠀⠀⠀⢀⣼⣿⣿⣿⣿⣿⣽⣿⣾⢦⣿⣿⣷⣾⣿⣿⣿⢿⠺⣿⣿⣿⣿⣿⣿⢻⣿⣿⣷⣶⣿⣿⣿⣷⣤⣴⣿⣿⣿⣿⣆⣶⣿⡿⣧⣶⣤⣼⣿⡿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⢿⣿⣿⠀⣿⣿⣷⣿⣿⣿⡟⠛⠀⠀⠀⢸⣿⣿⡟⣿⣿⣿⡇⠀⠀⠀⣾⣿⠳⠘⣟⣴⣿⣼⣿⣿⢳⣿⣿⣿⠟⠛⣿⣿⢾⢝⣿⣿⣿⣿⣿⠁⢸⣿⣿⣿⢿⣿⣿⣯⢍⠈⢿⣿⣿⣭⣉⣿⣿⣭⣶⣷⣿⣾⣷⣿⣿⡟⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣷⣿⣿⡏⢹⣿⣿⡆⠀⠀⠀⠀⢸⣿⣿⣷⣿⣿⣿⡇⠀⠀⠀⢿⣿⣶⣷⣿⣿⣿⠻⣿⣯⢲⣿⣿⣿⡄⠀⣿⣿⣼⢚⣿⣿⣿⣿⣿⣧⣸⣿⣿⣷⣰⣮⣽⣿⣿⢇⣶⣯⣿⣿⣿⢿⣿⣿⣧⣴⣾⡷⢺⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠿⠿⠿⠋⠀⠸⠿⠿⠇⠀⠀⠀⠀⠀⠙⠿⠟⠻⠿⠿⠃⠀⠀⠀⢠⣿⣿⡟⣿⣿⣿⠀⠿⠿⠜⠻⠿⠿⠀⠀⠻⠿⠎⠘⠿⠿⠃⠻⠿⠿⠚⠿⠿⠏⠙⠻⠿⠟⠋⠈⠛⠿⠿⠟⠋⠀⠙⠿⠿⠿⠛⠀⠸⠿⠿⠓⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠿⣿⣿⣿⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠹⣿⣦⠠⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠏⠾⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠙⢿⣷⡄⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣴⣶⣶⣶⣶⣶⣶⣶⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣾⣿⠿⠿⠿⢿⣿⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⠃⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣮⠓⠄⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⠟⠉⠀⠀⠀⠀⠀⠙⠿⡿⢤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⠿⡧⠂⠀⠀⠀⠀⠈⠛⠛⢿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⣴⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣷⣦⠀⠀⠀⠀⠀⠀⠀⠘⠾⢦⣄⡀⠀⠀⠀⠀⠀⢀⣾⣿⣟⡁⠀⠀⠀⠀⠀⢀⣿⣶⣶⣶⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡿⠇⢸⣶⣤⣤⣤⣄⡀⠀⠀⠀⠀⠈⠻⣿⣶⡖⠀⠀⠀⠀⠀⠀⢀⡤⣢⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣤⣾⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠆⠻⣿⣿⣎⡀⠀⠀⠀⠀⠀⠀⠀⠘⠊⡍⣇⢤⣠⣠⣿⣿⠋⠛⠁⠀⠀⠀⡀⢡⣿⡿⣧⠀⠈⠻⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⣸⣿⡟⠛⠻⢿⣿⣦⡀⠀⠀⠀⠀⠙⢿⣿⣬⣢⠀⣞⣵⡿⡯⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠈⠛⠿⣿⣶⡖⣀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢵⣿⣿⢷⡆⠀⠀⠀⠀⢀⣡⣾⡟⠁⠀⠀⠀⠀⠙⣿⣟⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣟⣿⡟⠀⠀⠀⠀⠙⢿⣧⣀⠀⠀⠀⠀⠀⠹⣿⣿⣟⠭⠂⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣬⣁⠀⠀⠀⠀⠀⢀⣤⣤⣼⡿⠁⠀⠀⠀⠀⠀⠀⣈⣿⣿⡄⠀⠀⠀⠀⠀⠈⣿⣿⠱⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡏⣿⠀⡄⠀⠀⠀⠀⢘⣿⡏⡇⠀⠀⠀⠀⠀⢹⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠿⠛⠿⣿⣶⣶⣦⡀⠀⣠⣼⣿⠷⠇⠀⠀⠀⠀⠀⣴⣿⣿⡿⠀⠀⠀⠀⠀⠀⠈⣿⣿⢰⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⣿⠀⠀⠀⠀⠀⠀⠈⣿⣿⢷⠀⠀⠀⠀⠀⠀⠛⣿⣧⣀⠀⠀⠀⠀⠀⠀⠀⡀⣀⣀⣄⣀⣄⣠⣄⣤⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠸⣿⣧⣤⣤⣤⣄⣀⣀⡀⠀⠀⢤⡤⢨⡍⠉⠁⠁⢠⣵⣿⣿⠀⠀⠀⠀⠀⠀⠀⣼⢿⣿⠄⠀⠀⠀⠀⠀⠀⠀⣿⣿⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡿⣿⡄⠀⠀⠀⠀⠀⠀⣿⣿⢺⠀⠀⠀⠀⠀⠀⠀⣽⣿⣏⠁⠠⣶⣶⣾⣿⣿⡿⠿⠟⠛⠛⠛⠛⠛⠛⢻⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣯⡉⠉⠛⠛⠿⠿⢿⣿⣷⣶⣤⣤⣤⠀⠀⢸⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡄⠀⠀⠀⠀⠀⠀⢀⣿⡏⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠾⣿⣿⣶⠄⠀⠀⠀⠀⣿⣿⢻⠀⠀⠀⠀⠀⠀⠀⠠⢹⣿⡆⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⣴⣾⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣷⣤⡀⠀⠀⠀⠀⠀⠈⠉⠙⠛⠻⠀⠀⢸⣼⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣷⡀⠀⠀⠀⠀⢀⣾⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣄⠀⠀⠀⠀⢠⣿⡿⠾⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣾⣿⡂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣷⡀⠀⠀⢠⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣦⣐⠉⣼⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠐⢸⣿⡇⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣷⣤⣀⠀⠀⢀⠀⠀⠀⠀⠀⢸⣿⣿⣷⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠿⣿⣦⣤⣿⣿⠃⠀⠀⠀⠀⡀⠀⠀⠀⢀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢙⠿⠿⠷⠿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⡷⠂⠀⠀⠀⠀⠀⡀⢀⣠⣾⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠱⠉⠻⣿⣷⣶⣾⠀⠀⠀⠀⠀⠀⠉⠁⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠁⠀⠀⠀⠀⢀⣷⣿⣶⣾⣿⣿⣿⡗⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣶⣿⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢈⣿⡟⢿⣦⣀⡀⠀⠀⣀⣤⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣤⣿⣄⡀⠀⣠⣴⣦⣀⠀⠀⠀⠁⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⡿⢡⣼⣿⣯⣴⣿⣿⢿⣿⣿⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣴⣿⣿⠿⣿⣿⢀⣴⣿⣿⠿⡟⠋⠀⠀⠀⠀⡙⢿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀⠀⠀⠈⠛⠛⠉⠠⣾⣿⣿⣾⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠉⠁⠰⠿⠿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠈⠋⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣶⣶⠠⠀⢰⣶⣿⣷⣶⣶⣶⣶⣤⣤⣠⣴⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⠿⠿⠶⢿⣿⣍⠀⠀⠉⠉⠉⠉⠛⠉⢹⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⢙⣿⣧⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡿⠀⠀⠀⠀⠀⠀⠀⢠⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣷⣄⠀⠀⠀⠀⠀⠀⠚⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣧⡤⢀⣀⠀⠀⠀⠀⠀⠀⠀⣀⢀⡀⢘⣿⣿⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣧⣼⣴⣷⣶⣶⣿⠿⠿⠿⠻⣿⣶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⡤⠶⣀⠀⠀⠙⣿⣷⡀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣿⠿⠋⠉⠚⠿⠶⠶⠶⠶⠶⠶⠿⠿⠟⠛⠛⠛⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⠛⠛⠋⠉⠀⠀⠀⠀⠀⠀⠀⢈⠙⠿⣿⣷⣶⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⢟⠂⠀⠀⠑⣲⠀⠀⠈⠻⣿⣶⣄⡀⠀⣠⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣾⣿⠿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠤⢩⣛⡻⠿⣿⣷⣶⣦⣦⡀⠀⠀⠀⠀⠀⠸⣆⠀⠀⠀⠀⠀⠙⡆⠀⠀⠀⠉⠛⠛⠛⠻⠟⠁⠀⠀⠀⠀⠀⠀⠀⣾⣶⣧⣤⣾⣿⣿⠿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣷⣤⣤⣭⣿⣿⣾⣿⣿⣿⣿⣷⣶⣿⡇⠀⠀⠀⠀⠀⠸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠉⠉⣿⣯⣁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⢿⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⡦⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠾⢿⣷⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣶⣦⣤⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
              "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣹⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⢿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
            ];
          in moth;

          center = [
            {
              action = mkRaw "function(path) vim.cmd('Telescope zoxide') end";
              desc = "Open Directory";
              group = "Label";
              icon = "📁";
              icon_hl = "@variable";
              key = "v";
            }
            {
              action = mkRaw "function(path) vim.cmd('Telescope find_files') end";
              desc = "Open File";
              group = "Label";
              icon = "📄";
              icon_hl = "@variable";
              key = "f";
            }
            {
              action = mkRaw "function(path) vim.cmd('XplrPicker') end";
              desc = "XPLR";
              group = "Label";
              icon = "🌈";
              icon_hl = "@variable";
              key = "g";
            }
            {
              action = mkRaw "function(path) vim.cmd('LazyGit') end";
              desc = "Git";
              group = "Label";
              icon = "✨";
              icon_hl = "@variable";
              key = "c";
            }
          ];
        };
      };
    };
  };

  extraFiles = {
    "ftplugin/nix.vim".text = ''
      setlocal shiftwidth=2 softtabstop=2 expandtab
    '';
  };

  extraConfigLuaPost = ''
    -- Neovide
    if vim.g.neovide then
      vim.g.neovide_cursor_vfx_mode = "railgun"

      -- catppuccin mocha
      vim.g.terminal_color_0 = "#45475a"
      vim.g.terminal_color_1 = "#f38ba8"
      vim.g.terminal_color_2 = "#a6e3a1"
      vim.g.terminal_color_3 = "#f9e2af"
      vim.g.terminal_color_4 = "#89b4fa"
      vim.g.terminal_color_5 = "#f5c2e7"
      vim.g.terminal_color_6 = "#94e2d5"
      vim.g.terminal_color_7 = "#bac2de"
      vim.g.terminal_color_8 = "#585b70"
      vim.g.terminal_color_9 = "#f38ba8"
      vim.g.terminal_color_10 = "#a6e3a1"
      vim.g.terminal_color_11 = "#f9e2af"
      vim.g.terminal_color_12 = "#89b4fa"
      vim.g.terminal_color_13 = "#f5c2e7"
      vim.g.terminal_color_14 = "#94e2d5"
      vim.g.terminal_color_15 = "#a6adc8"
    end

    require("telescope").load_extension("zoxide")

    -- gdscript :c
    require("lspconfig").gdscript.setup({ capabilities = vim.lsp.protocol.make_client_capabilities() })
  '';
}

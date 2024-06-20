-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 500, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = false, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = false, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "auto", -- sets vim.opt.signcolumn to auto
        wrap = false, -- sets vim.opt.wrap
        scrolloff = 10,
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs with `H` and `L`
        -- L = {
        --   function() require("astrocore.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
        --   desc = "Next buffer",
        -- },
        -- H = {
        --   function() require("astrocore.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
        --   desc = "Previous buffer",
        -- },

        -- mappings seen under group name "Buffer"
        ["<Leader>bD"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Pick to close",
        },
        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        ["<Leader>b"] = { desc = "Buffers" },
        -- quick save
        ["<C-s>"] = { ":w!<cr>", desc = "Save File" }, -- change description but the same command
        [";"] = { ":", desc = "Enter command model." },
      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
      },
    },
    autocmds = {
      RunProg = {
        {
          event = "FileType",
          pattern = "c",
          callback = function()
            -- 绑定 <C-R> 键来编译和运行当前的 .c 文件
            vim.api.nvim_buf_set_keymap(0, "n", "<C-R>", "", {
              noremap = true,
              silent = true,
              callback = function()
                -- 获取当前文件名和输出文件名
                local filename = vim.fn.expand "%:p"
                local output = vim.fn.expand "%:r"

                -- 打开一个新的终端窗口
                vim.cmd "belowright split | resize 10 | terminal"

                -- 编译命令
                local compile_cmd = string.format("gcc %s -o %s", filename, output)

                -- 发送编译命令到终端
                vim.fn.chansend(vim.b.terminal_job_id, compile_cmd .. "\n")

                -- 发送运行命令到终端，如果编译成功
                local run_cmd =
                  string.format("if [ $? -eq 0 ]; then ./%s; else echo 'Compilation failed'; fi\n", output)
                vim.fn.chansend(vim.b.terminal_job_id, run_cmd)

                -- 切换回编辑窗口
                vim.cmd "wincmd p"
              end,
            })
          end,
        },
        {
          event = "FileType",
          pattern = "cpp",
          callback = function()
            vim.api.nvim_buf_set_keymap(
              0,
              "n",
              "<C-R>",
              ":w<CR>:!g++ % -o %< && ./%<<CR>",
              { noremap = true, silent = true }
            )
          end,
        },
      },
    },
  },
}

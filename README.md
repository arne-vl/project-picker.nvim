# project-picker.nvim
Telescope project navigator for neovim

## Installation
### Lazy:
```lua
{
    "arne-vl/project-picker.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
        vim.keymap.set('n', '<leader>fp', function()
            require('dev.project_picker').project_picker()
        end, { desc = 'Open project picker' })

        vim.keymap.set('n', '<leader>ap', function()
            local name = vim.fn.input("Enter project name: ")
            if name == "" then
                print("Error: Project name cannot be empty.")
                return
            end

            local path = vim.fn.input("Enter project path: ")
            if path == "" then
                print("Error: Project path cannot be empty.")
                return
            end

            require('dev.project_picker').add_project(name, path)
        end, { desc = 'Add project to picker' })

        vim.keymap.set('n', '<leader>dp', function()
            local name = vim.fn.input("Enter project name to delete: ")
            if name == "" then
                print("Error: Project name cannot be empty.")
                return
            end

            require('dev.project_picker').delete_project(name)
        end, { desc = 'Delete project from picker' })
    end
}
```

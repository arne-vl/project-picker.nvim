local M = {}

local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local function get_script_dir()
    local info = debug.getinfo(1, "S")
    local path = info.source:sub(2)
    return path:match("(.*/)")
end

local projects_file = get_script_dir() .. "projects.txt"

local load_project_data = function(filename)
    local projects = {}
    local file = io.open(filename, "r")

    if not file then
        print("Error: Could not open file '" .. filename .. "'")
        return {}
    end

    for line in file:lines() do
        local name, path = line:match("([^,]+),(.+)")
        if name and path then
            table.insert(projects, { name = name, path = path })
        else
            print("Warning: Skipping malformed line: " .. line)
        end
    end

    file:close()
    return projects
end

M.add_project = function(name, path)
    local file = io.open(projects_file, "a")
    if not file then
        print("Error: Could not open file '" .. projects_file .. "' for writing.")
        return
    end

    file:write(name .. "," .. path .. "\n")
    file:close()
    print("Project added: " .. name)
end

M.delete_project = function(name)
    local file = io.open(projects_file, "r")
    if not file then
        print("Error: Could not open file '" .. projects_file .. "' for reading.")
        return
    end

    local lines = {}
    local found = false
    for line in file:lines() do
        local project_name = line:match("^([^,]+),")
        if project_name ~= name then
            table.insert(lines, line)
        else
            found = true
        end
    end
    file:close()

    if not found then
        print("Error: Project '" .. name .. "' not found.")
        return
    end

    file = io.open(projects_file, "w")
    if not file then
        print("Error: Could not open file '" .. projects_file .. "' for writing.")
        return
    end

    for _, line in ipairs(lines) do
        file:write(line .. "\n")
    end
    file:close()

    print("Project deleted: " .. name)
end

M.project_picker = function(opts)
    local projects = load_project_data(projects_file)
    if not projects or #projects == 0 then
        print("Error: Failed to load projects or no projects found.")
        return
    end

    table.sort(projects, function(a, b)
        return a.name < b.name
    end)

    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = "Projects",
            finder = finders.new_table({
                results = projects,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = entry.name,
                        ordinal = entry.name,
                        path = entry.path,
                    }
                end,
            }),
            sorter = conf.generic_sorter(opts),
        })
        :find()
end

return M

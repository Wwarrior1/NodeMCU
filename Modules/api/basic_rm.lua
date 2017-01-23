-- | ===== MODULE ===== |
local M = {}
local module = ...
function M.cleanup()
    package.loaded[module] = nil
end

-- Remove all .lc files
function M.rm_lc_files()
    local l = file.list()
    print("### Remove All .lc Files ###")
    for k, _ in pairs(l) do
        if string.find(k, ".lc") then
            file.remove(k)
            print("+ removed: " .. k)
        end
    end
end

-- Remove all .lua files
function M.rm_lua_files()
    local l = file.list()
    print("### Remove All .lua Files ###")
    for k, _ in pairs(l) do
        if string.find(k, ".lua") then
            file.remove(k)
            print("+ removed: " .. k)
        end
    end
end

-- | ===== MODULE ===== |
return M
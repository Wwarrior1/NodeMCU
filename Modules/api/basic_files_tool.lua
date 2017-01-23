-- | ===== MODULE ===== |
local M = {}
local module = ...
function M.cleanup()
    package.loaded[module] = nil
end

-- Remove all files
function M.rm_all()
    for k, _ in pairs(file.list()) do
        file.remove(k)
        print(k .. " removed")
    end
end

-- List all files
function M.ls()
    for k, _ in pairs(file.list()) do
        print("file \"" .. k .. "\"")
    end
end

-- | ===== MODULE ===== |
return M

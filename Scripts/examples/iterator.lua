local function Iterator()
    local iterator = 0
    
    return function ()
        iterator = iterator + 1
        return iterator
    end
end

local x = Iterator()

print("First element ID " .. x())
print("Second element ID " .. x())
print("Third element ID " .. x())
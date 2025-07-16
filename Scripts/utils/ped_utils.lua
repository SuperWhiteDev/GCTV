local pedUtils = { }

function pedUtils.GetRandomPedModelName()
    local peds = JsonReadList("peds.json")

    if peds ~= nil then
        local pedIndex = math.random(1, #peds)
        return peds[pedIndex]
    end
    
    return ""
end

return pedUtils
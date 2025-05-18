local vehicleUtils = { }

function vehicleUtils.GetVehicleModelName(modelhash)
    local vehicles = JsonReadList("vehicles.json")

    for i = 1, #vehicles do
        if MISC.GET_HASH_KEY(vehicles[i]) == modelhash then
            return vehicles[i]
        end
    end

    return "Unknown Model"
end

function vehicleUtils.GetRandomVehicleModelName()
    local vehicles = JsonReadList("vehicles.json")

    if vehicles ~= nil then
        local vehicleIndex = math.random(1, #vehicles)
        return vehicles[vehicleIndex]
    end
    
    return ""
end

return vehicleUtils
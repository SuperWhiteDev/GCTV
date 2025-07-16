local inputUtils = { }

function inputUtils.InputVehicle()
    local veh = nil
    local vehicles = { "Pesonal vehicle", "Last vehicle", "Currect vehicle", "Custom" }
    local vehicle = InputFromList("Choose which vehicle you want to control: ", vehicles)
    
    if vehicle == 0 then
        veh = GetPersonalVehicle()
    elseif vehicle == 1 then
        veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
    elseif vehicle == 2 then
        veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    elseif vehicle == 3 then
        io.write("Enter vehicle handle: ")
        veh = tonumber(io.read())
        if not ENTITY.IS_ENTITY_A_VEHICLE(veh) then
            return nil
        end
    else
        return nil
    end

    if veh == 0.0 then
        return nil
    end

    return veh
end

return inputUtils
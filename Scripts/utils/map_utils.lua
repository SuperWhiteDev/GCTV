local mapUtils = { }

local blip_enums = require("blip_enums")

function mapUtils.GetWaypointCoords()
    local waypointBlip = HUD.GET_FIRST_BLIP_INFO_ID(blip_enums.BlipIcon.Waypoint)
    if HUD.DOES_BLIP_EXIST(waypointBlip) then
        local coords = HUD.GET_BLIP_COORDS(waypointBlip)
        coords.z = 0.0

        return coords
    else
        return nil
    end
end

function mapUtils.GetPersonalVehicle()
    local personalVehBlip = HUD.GET_FIRST_BLIP_INFO_ID(blip_enums.BlipIcon.PersonalVehicleCar)
    if HUD.DOES_BLIP_EXIST(personalVehBlip) then
        return HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(personalVehBlip)
    else
        personalVehBlip = HUD.GET_FIRST_BLIP_INFO_ID(blip_enums.BlipIcon.PersonalVehicleBike)
        if HUD.DOES_BLIP_EXIST(personalVehBlip) then
            return HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(personalVehBlip)
        end

        return nil
    end
end

function mapUtils.GetBlipFromEntityModel(model)
    if STREAMING.IS_MODEL_A_PED(model) then
        return blip_enums.BlipIcon.Standard
    elseif STREAMING.IS_MODEL_A_VEHICLE(model) then
        if VEHICLE.IS_THIS_MODEL_A_PLANE(model) then
            return blip_enums.BlipIcon.Plane
        elseif VEHICLE.IS_THIS_MODEL_A_HELI(model) then
            return blip_enums.BlipIcon.Helicopter
        elseif VEHICLE.IS_THIS_MODEL_A_BIKE(model) then
            return blip_enums.BlipIcon.PersonalVehicleBike
        else 
            return blip_enums.BlipIcon.PersonalVehicleCar
        end
    end
end

function mapUtils.GetZoneName(x, y, z)
    local zone = string.upper(ZONE.GET_NAME_OF_ZONE(x, y, z))

    local zonenames = JsonReadList("zones.json")
        
    for i = 1, #zonenames do
        local element = zonenames[i]
        if string.upper(element.Name) == zone then
            return element.DisplayName
        end
    end

    return zone
end

return mapUtils
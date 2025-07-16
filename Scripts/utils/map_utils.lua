-- This utility script provides helper functions related to map interactions,
-- such as retrieving waypoint coordinates, finding personal vehicles,
-- determining blip sprites for entities, and getting zone names.

local map_utils = {} -- Create a table to hold our utility functions.

-- Require the blip_enums module for blip icon constants.
local blip_enums = require("blip_enums")

--- Retrieves the coordinates of the active waypoint set by the player on the map.
-- Assumes `HUD` is a global object provided by the GTAV API.
-- @returns table A table with 'x', 'y', 'z' coordinates of the waypoint (z is set to 0.0),
--                or nil if no waypoint is currently set.
function map_utils.get_waypoint_coords()
    -- Get the blip ID for the first active waypoint.
    local waypoint_blip = HUD.GET_FIRST_BLIP_INFO_ID(blip_enums.BlipIcon.WAYPOINT)
    
    -- Check if the waypoint blip actually exists.
    if HUD.DOES_BLIP_EXIST(waypoint_blip) then
        -- Get the coordinates of the waypoint blip.
        local coords = HUD.GET_BLIP_COORDS(waypoint_blip)
        coords.z = 0.0 -- Set Z-coordinate to 0.0, often useful for ground-level interaction.

        return coords -- Return the waypoint coordinates.
    else
        return nil -- No waypoint found.
    end
end

--- Retrieves the entity handle of the player's personal vehicle.
-- It checks for both car and bike blips representing the personal vehicle.
-- Assumes `HUD` is a global object provided by the GTAV API.
-- @returns number The entity handle of the personal vehicle, or nil if not found.
function map_utils.get_personal_vehicle()
    -- First, try to find the blip for a personal car.
    local personal_veh_blip = HUD.GET_FIRST_BLIP_INFO_ID(blip_enums.BlipIcon.PERSONAL_VEHICLE_CAR)
    
    -- If a personal car blip exists, return its associated entity handle.
    if HUD.DOES_BLIP_EXIST(personal_veh_blip) then
        return HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(personal_veh_blip)
    else
        -- If no personal car, try to find the blip for a personal bike.
        personal_veh_blip = HUD.GET_FIRST_BLIP_INFO_ID(blip_enums.BlipIcon.PERSONAL_VEHICLE_BIKE)
        
        -- If a personal bike blip exists, return its associated entity handle.
        if HUD.DOES_BLIP_EXIST(personal_veh_blip) then
            return HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(personal_veh_blip)
        end

        return nil -- No personal vehicle (car or bike) blip found.
    end
end

--- Determines the appropriate blip icon for a given entity model hash.
-- This is useful for displaying entities on the map with relevant icons.
-- Assumes `STREAMING` and `VEHICLE` are global objects provided by the GTAV API.
-- @param model number The model hash of the entity.
-- @returns number The blip icon ID from `blip_enums.BlipIcon` that best represents the model.
function map_utils.get_blip_from_entity_model(model)
    -- Check if the model is a pedestrian.
    if STREAMING.IS_MODEL_A_PED(model) then
        return blip_enums.BlipIcon.STANDARD -- Use a standard blip for pedestrians.
    -- Check if the model is a vehicle.
    elseif STREAMING.IS_MODEL_A_VEHICLE(model) then
        -- Further categorize vehicle types for more specific blips.
        if VEHICLE.IS_THIS_MODEL_A_PLANE(model) then
            return blip_enums.BlipIcon.PLANE
        elseif VEHICLE.IS_THIS_MODEL_A_HELI(model) then
            return blip_enums.BlipIcon.HELICOPTER
        elseif VEHICLE.IS_THIS_MODEL_A_BIKE(model) then
            return blip_enums.BlipIcon.PERSONAL_VEHICLE_BIKE
        else 
            -- Default vehicle blip for cars and other ground vehicles.
            return blip_enums.BlipIcon.PERSONAL_VEHICLE_CAR
        end
    end
    -- If neither a ped nor a known vehicle type, return a default standard blip.
    return blip_enums.BlipIcon.STANDARD
end

--- Retrieves the display name of a game zone at specified coordinates.
-- It first gets the internal zone name and then attempts to find a more readable
-- display name from a "zones.json" configuration file.
-- Assumes `ZONE` is a global object from the GTAV API and `JsonReadList` is available.
-- @param x number The X-coordinate.
-- @param y number The Y-coordinate.
-- @param z number The Z-coordinate.
-- @returns string The display name of the zone, or the raw internal zone name if no display name is found.
function map_utils.get_zone_name(x, y, z)
    -- Get the internal (uppercase) name of the zone from the game API.
    local zone_internal_name = string.upper(ZONE.GET_NAME_OF_ZONE(x, y, z))

    -- Attempt to read a list of zone names from a JSON file.
    local zone_names_list = JsonReadList("zones.json")
    
    -- Iterate through the list to find a matching display name.
    if zone_names_list ~= nil then
        for i = 1, #zone_names_list do
            local element = zone_names_list[i]
            -- Compare the uppercase internal name with the uppercase name from the JSON.
            if string.upper(element.Name) == zone_internal_name then
                return element.DisplayName -- Return the more user-friendly display name.
            end
        end
    end

    return zone_internal_name -- If no display name found, return the raw internal name.
end

return map_utils -- Return the utility table for use in other scripts.

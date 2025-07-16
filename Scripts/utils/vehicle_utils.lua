-- This utility script provides helper functions related to vehicle models,
-- specifically for retrieving vehicle model names and selecting random ones
-- from a configuration file.

local vehicle_utils = {} -- Create a table to hold our utility functions.

--- Retrieves the original model name (string) corresponding to a given model hash.
-- It searches through a list of vehicle models defined in "vehicles.json".
-- Assumes `JsonReadList` is available and `MISC.GET_HASH_KEY` is a global GTAV API function.
-- @param model_hash number The hash of the vehicle model.
-- @returns string The string name of the vehicle model, or "Unknown Model" if not found.
function vehicle_utils.get_vehicle_model_name(model_hash)
    -- Attempt to read the list of vehicle model names from the JSON file.
    local vehicles = JsonReadList("vehicles.json")

    -- Check if the list was successfully read and is not nil.
    if vehicles ~= nil then
        -- Iterate through each vehicle name in the list.
        for i = 1, #vehicles do
            -- Get the hash key for the current vehicle name and compare it to the target hash.
            if MISC.GET_HASH_KEY(vehicles[i]) == model_hash then
                return vehicles[i] -- Return the matching vehicle model name.
            end
        end
    end

    return "Unknown Model" -- Return "Unknown Model" if the hash is not found or file is invalid.
end

--- Retrieves a random vehicle model name from the "vehicles.json" file.
-- Assumes `JsonReadList` is available and `math.random` is for random number generation.
-- @returns string A randomly selected vehicle model name, or an empty string if
--                 the "vehicles.json" file is not found, empty, or invalid.
function vehicle_utils.get_random_vehicle_model_name()
    -- Attempt to read the list of vehicle model names from the JSON file.
    local vehicles = JsonReadList("vehicles.json")

    -- Check if the list of vehicles was successfully read and is not empty.
    if vehicles ~= nil and #vehicles > 0 then
        -- Generate a random index within the bounds of the vehicles list.
        local vehicle_index = math.random(1, #vehicles)
        return vehicles[vehicle_index] -- Return the vehicle model name at the random index.
    end
    
    return "" -- Return an empty string if no vehicles are found or the file is invalid.
end

return vehicle_utils -- Return the utility table for use in other scripts.

-- This utility script provides helper functions related to pedestrian (ped) models,
-- specifically for retrieving a random ped model name from a configuration file.

local ped_utils = {} -- Create a table to hold our utility functions.

--- Retrieves a random pedestrian model name from the "peds.json" file.
-- Assumes `JsonReadList` is a global function available in the Lua environment,
-- which reads a JSON file and returns its content as a Lua table (list).
-- @returns string A randomly selected ped model name, or an empty string if
--                 the "peds.json" file is not found, empty, or invalid.
function ped_utils.get_random_ped_model_name()
    -- Attempt to read the list of ped models from the JSON file.
    local peds = JsonReadList("peds.json")

    -- Check if the list of peds was successfully read and is not empty.
    if peds ~= nil and #peds > 0 then
        -- Generate a random index within the bounds of the peds list.
        local ped_index = math.random(1, #peds)
        return peds[ped_index] -- Return the ped model name at the random index.
    end
    
    return "" -- Return an empty string if no peds are found or the file is invalid.
end

return ped_utils -- Return the utility table for use in other scripts.

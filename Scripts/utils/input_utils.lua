-- This utility script provides helper functions for handling user input,
-- particularly for selecting game entities like vehicles.

local input_utils = {} -- Create a table to hold our utility functions.

-- Require the map_utils module to access functions like GetPersonalVehicle.
local map_utils = require("map_utils")

--- Prompts the user to select a vehicle from predefined options or by entering a custom handle.
-- This function relies on global functions like `InputFromList`, `GetPersonalVehicle`,
-- `PED.GET_VEHICLE_PED_IS_IN`, and `ENTITY.IS_ENTITY_A_VEHICLE` provided by the GCTV environment.
-- @returns number The handle of the selected vehicle, or nil if no valid vehicle is chosen.
function input_utils.input_vehicle()
    local selected_vehicle_handle = nil -- Variable to store the chosen vehicle's handle.
    
    -- Options presented to the user for vehicle selection.
    local vehicle_selection_options = {
        "Personal vehicle", -- The player's currently tracked personal vehicle.
        "Last vehicle",     -- The last vehicle the player was in (even if they exited).
        "Current vehicle",  -- The vehicle the player is currently in.
        "Custom"            -- Allows the user to enter a vehicle handle manually.
    }
    
    -- Prompt the user to choose a vehicle selection method.
    local chosen_option_index = InputFromList("Choose which vehicle you want to control: ", vehicle_selection_options)
    
    -- Process the user's selection.
    if chosen_option_index == 0 then -- "Personal vehicle"
        selected_vehicle_handle = map_utils.get_personal_vehicle()
    elseif chosen_option_index == 1 then -- "Last vehicle"
        -- Get the last vehicle the player's ped was in, even if they're not in it now.
        selected_vehicle_handle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
    elseif chosen_option_index == 2 then -- "Current vehicle"
        -- Get the vehicle the player's ped is currently in.
        selected_vehicle_handle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    elseif chosen_option_index == 3 then -- "Custom"
        -- Prompt for a custom vehicle handle.
        local input_handle_str = Input("Enter vehicle handle: ", false)
        selected_vehicle_handle = tonumber(input_handle_str) -- Convert input string to number.
        
        -- Validate if the entered handle corresponds to an existing vehicle.
        if not ENTITY.IS_ENTITY_A_VEHICLE(selected_vehicle_handle) then
            DisplayError(false, "Invalid vehicle handle entered or entity is not a vehicle.")
            return nil -- Return nil if the custom handle is invalid.
        end
    else
        -- User cancelled or made an invalid selection from the list.
        return nil
    end

    -- After selection, perform a final check to ensure a valid non-zero handle was obtained.
    if selected_vehicle_handle == 0.0 or selected_vehicle_handle == nil then
        DisplayError(false, "No valid vehicle could be identified or selected.")
        return nil
    end

    return selected_vehicle_handle -- Return the handle of the selected vehicle.
end

return input_utils -- Return the utility table for use in other scripts.

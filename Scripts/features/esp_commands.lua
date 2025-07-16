-- This script defines commands for drawing and managing ESP (Extra Sensory Perception) lines
-- to target players or entities.

-- Register a global table to store player IDs for whom ESP lines are drawn.
RegisterGlobalVariable("EsplinePlayerTargets", {}) -- Registered as an empty table.
local max_espline_players_count = 32 -- Maximum number of players for whom ESP lines can be drawn.

--- Command to draw an ESP line to a specified target (Player or Entity).
-- Prompts the user to select a target type and then the specific target ID.
function draw_esp_line_command()
    local target_options = { "Player", "Entity" }
    local selected_option_index = InputFromList("Enter to whom you want to draw the esp line: ", target_options)

    if selected_option_index == 0 then -- Target is a Player
        local player_id_str = Input("Enter player ID: ", false)
        local player_id = tonumber(player_id_str)
        
        -- Validate player ID and check if the player ped exists.
        if player_id and PLAYER.GET_PLAYER_PED(player_id) ~= 0.0 then
            local espline_targets_table = GetGlobalVariable("EsplinePlayerTargets")
            local current_table_size = #espline_targets_table

            -- Check if the player is already in the list.
            for i = 1, current_table_size do
                if espline_targets_table[i] == player_id then
                    print("ESP line is already drawn for player " .. player_id .. ".")
                    return nil
                end
            end

            -- Check if the maximum number of ESP lines has been reached.
            if current_table_size < max_espline_players_count then
                -- Add the player ID to the global table.
                SetGlobalVariableValue("EsplinePlayerTargets", current_table_size + 1, player_id)
                printColoured("green", "ESP line drawing enabled for player " .. player_id .. ".")

                -- If this is the first player added, run the EspFeatures script.
                if current_table_size == 0 then
                    -- Using relative path for RunScript as per your instruction.
                    RunScript("features\\esp_features.lua") 
                end
            else
                DisplayError(false, "You have exceeded the maximum number of ESP lines for players (" .. max_espline_players_count .. ").")
            end
        else
            DisplayError(false, "Incorrect input or player not found. Please enter a valid player ID.")
        end
    elseif selected_option_index == 1 then -- Target is an Entity (Not yet implemented)
        print("Drawing ESP lines for entities is not yet implemented.")
        -- TODO: Implement logic for drawing ESP lines to generic entities.
    end
end

--- Removes a specific element from a global table.
-- This function is designed to work with global tables registered via RegisterGlobalVariableTable.
-- @param table_name string The name of the global table.
-- @param element_to_remove any The value of the element to remove.
-- @returns boolean True if the element was found and removed, false otherwise.
function remove_element_from_table(table_name, element_to_remove)
    local targets_table = GetGlobalVariable(table_name)
    
    if targets_table then
        local index_to_remove = nil
        
        -- Find the index of the element to remove.
        for i = 1, #targets_table do
            if targets_table[i] == element_to_remove then
                index_to_remove = i
                break
            end
        end
        
        -- If the element is found, remove it.
        if index_to_remove then
            -- Shift elements to the left to fill the gap.
            for i = index_to_remove, #targets_table - 1 do
                targets_table[i] = targets_table[i + 1]
            end
            
            -- Remove the last element (which is now a duplicate or should be nilled out).
            targets_table[#targets_table] = nil

            -- Update the global table in memory.
            -- This loop is crucial because Lua's table.remove doesn't directly update the global variable table.
            -- We need to re-set each value in the global variable table.
            for i = 1, #targets_table + 1 do -- Iterate one past the new size to nil out the last slot if needed.
                SetGlobalVariableValue(table_name, i, targets_table[i])
            end
            
            print("Element removed from '" .. table_name .. "'.")
            return true
        else
            print("Element not found in '" .. table_name .. "'.")
            return false
        end
    else
        DisplayError(false, "Global table '" .. table_name .. "' does not exist.")
        return false
    end
end

--- Command to disable (remove) an ESP line for a specified target.
-- Prompts the user to select a target type and then the specific target from the active list.
function disable_esp_line_command()
    local target_options = { "Player", "Entity" }
    local selected_option_index = InputFromList("Enter for whom you want to disable the esp line: ", target_options)

    if selected_option_index == 0 then -- Target is a Player
        local player_targets_list = GetGlobalVariable("EsplinePlayerTargets")
        local player_display_names = {}
        
        if #player_targets_list > 0 then
            -- Populate a list of player names for user selection.
            for i = 1, #player_targets_list do
                table.insert(player_display_names, NETWORK.NETWORK_PLAYER_GET_NAME(player_targets_list[i]))
            end
    
            local selected_player_index = InputFromList("Select player to disable ESP line for: ", player_display_names)
            if selected_player_index ~= -1 then
                local player_id_to_remove = player_targets_list[selected_player_index + 1] -- +1 for Lua 1-indexing
                
                if remove_element_from_table("EsplinePlayerTargets", player_id_to_remove) then
                    printColoured("green", "ESP line disabled for player " .. NETWORK.NETWORK_PLAYER_GET_NAME(player_id_to_remove) .. ".")
                else
                    DisplayError(false, "Could not find the player in the list of active ESP targets.")
                end
            else
                print("ESP line removal cancelled.") -- User cancelled selection.
            end
        else
            DisplayError(false, "ESP lines are not currently drawn for any player.")
        end
    elseif selected_option_index == 1 then -- Target is an Entity (Not yet implemented)
        print("Disabling ESP lines for entities is not yet implemented.")
        -- TODO: Implement logic for disabling ESP lines for generic entities.
    end
end

-- Define a dictionary with commands and their corresponding functions.
local commands = {
    ["draw esp line"] = draw_esp_line_command,
    ["disable esp line"] = disable_esp_line_command
}

-- Initialize the pseudo-random number generator based on the current time.
-- This ensures different results for math.random each time the script runs.
math.randomseed(os.time())

-- Loop for registering commands.
-- Iterates through all "command name" - "function" pairs in the 'commands' dictionary.
for command_name, command_function in pairs(commands) do
    -- Registers the command. 'BindCommand' is a custom function of your GCTV API.
    if not BindCommand(command_name, command_function) then
        -- Displays an error message if command registration failed.
        DisplayError(true, "Failed to register the command: " .. command_name)
    end
end

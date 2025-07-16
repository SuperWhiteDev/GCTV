-- This script is responsible for continuously drawing ESP (Extra Sensory Perception) lines
-- to specified player targets, as long as there are active targets.

local current_player_id = 0 -- Variable to track the current player (unused in original logic, but kept for context).

--- Checks if there are any active targets in the global "EsplinePlayerTargets" table.
-- @returns boolean True if there are targets, false otherwise.
function still_has_targets()
    -- Retrieve the global table containing player IDs for ESP lines.
    local player_targets_table = GetGlobalVariable("EsplinePlayerTargets")

    -- Check the size of the table. If it's greater than 0, there are targets.
    if player_targets_table and #player_targets_table > 0 then
        return true
    end

    return false
end

--- Draws an ESP line from the local player's position to a target entity's position.
-- The line is drawn in red.
-- @param entity_handle number The entity ID (handle) of the target.
function draw_esp_line(entity_handle)
    -- Get the coordinates of the local player.
    local local_player_coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    -- Get the coordinates of the target entity.
    local target_entity_coords = ENTITY.GET_ENTITY_COORDS(entity_handle, true)
        
    -- Draw a red line between the two sets of coordinates.
    -- Parameters: start_x, start_y, start_z, end_x, end_y, end_z, r, g, b, alpha
    GRAPHICS.DRAW_LINE(local_player_coords.x, local_player_coords.y, local_player_coords.z,
                       target_entity_coords.x, target_entity_coords.y, target_entity_coords.z,
                       255, 0, 0, 255)
end

--- Main update function that is called every tick to draw ESP lines.
-- Iterates through all player targets and draws a line to each.
function on_tick()
    -- Retrieve the global table of player targets.
    local player_targets = GetGlobalVariable("EsplinePlayerTargets")
    
    -- Iterate through each player ID in the targets table.
    for i = 1, #player_targets do
        local player_id = player_targets[i]
        local player_ped_handle = PLAYER.GET_PLAYER_PED(player_id)

        -- Only draw the line if the player ped exists.
        if player_ped_handle ~= 0.0 then
            draw_esp_line(player_ped_handle)
        end
    end
end

-- Main script loop.
-- This loop continues as long as the script is active and there are targets for ESP lines.
while ScriptStillWorking and still_has_targets() do
    on_tick() -- Call the main update function to draw lines.
    Wait(0)   -- Yield control to other scripts and the game engine.
end

-- print("ESP Features script stopped: No more targets or script is no longer working.")

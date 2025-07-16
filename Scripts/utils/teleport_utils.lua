-- This utility script provides functions for teleporting entities within the game world.

local teleport_utils = {} -- Create a table to hold our utility functions.

--- Teleports an entity to specified coordinates, adjusting Z-height if needed to land on ground.
-- If `coords.z` is 0.0, it attempts to find a safe ground Z-coordinate by iterating through
-- various heights. Otherwise, it teleports directly to `coords.z + 2.0`.
-- Assumes `ENTITY`, `TASK`, `MISC`, and `Game` (for `New`/`ReadFloat`/`Delete`) are
-- global objects/functions from the GTAV API / GCTV environment.
-- @param entity number The handle of the entity to teleport.
-- @param coords table A table with 'x', 'y', 'z' coordinates (z=0.0 to find ground, otherwise absolute).
function teleport_utils.teleport_entity(entity, coords)
    -- Predefined heights to try when searching for ground Z.
    local heights = { 100.0, 150.0, 50.0, 0.0, 200.0, 250.0, 300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0 }

    -- Allocate memory for a float pointer to receive the ground Z-coordinate.
    local coord_zp = New(4) -- 4 bytes for a float.

    -- If the target Z-coordinate is 0.0, attempt to find ground Z.
    if coords.z == 0.0 then
        -- Iterate through predefined heights to find a valid ground Z.
        for i = 1, #heights, 1 do
            -- Temporarily set entity coordinates to the current test height.
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, coords.x, coords.y, heights[i], false, false, true)
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(entity) -- Clear ped tasks to prevent falling/glitching.
            
            -- Attempt to get the ground Z-coordinate at the current XY and test height.
            if MISC.GET_GROUND_Z_FOR_3D_COORD(coords.x, coords.y, heights[i], coord_zp, false, false) then
                -- If ground Z is found, set entity coords to ground Z + 2.0 (to avoid sinking into ground).
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, coords.x, coords.y, Game.ReadFloat(coord_zp) + 2.0, false, false, true)
                break -- Exit loop as ground Z is found and entity is moved.
            end
        end
    else
        -- If coords.z is not 0.0, teleport directly to the specified Z + 2.0.
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, coords.x, coords.y, coords.z + 2.0, false, false, true)
    end

    -- Deallocate the memory pointer.
    Delete(coord_zp)
end

return teleport_utils -- Return the utility table for use in other scripts.

-- This utility script provides helper functions for interacting with game entities.

local entity_utils = {} -- Create a table to hold our utility functions.

--- Checks if an entity is within a specified cubic radius around target coordinates.
-- This function assumes `ENTITY.GET_ENTITY_COORDS` is available globally and returns
-- a table with `x`, `y`, `z` properties.
-- @param entity number The handle of the entity to check.
-- @param target_x number The X-coordinate of the target center.
-- @param target_y number The Y-coordinate of the target center.
-- @param target_z number The Z-coordinate of the target center.
-- @param radius number The cubic radius around the target coordinates.
-- @returns boolean True if the entity is within the radius, false otherwise.
function entity_utils.is_entity_at_coords(entity, target_x, target_y, target_z, radius)
    -- Get the current coordinates of the entity.
    local entity_coords = ENTITY.GET_ENTITY_COORDS(entity, true)
        
    -- Check if the entity's coordinates are within the cubic radius of the target coordinates.
    -- math.abs calculates the absolute difference.
    if math.abs(entity_coords.x - target_x) <= radius and
       math.abs(entity_coords.y - target_y) <= radius and
       math.abs(entity_coords.z - target_z) <= radius then
        return true -- Entity found within the specified coordinates.
    end
    
    return false -- Entity not found within the specified coordinates.
end

return entity_utils -- Return the utility table for use in other scripts.

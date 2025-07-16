-- This script manages dynamic vehicle modifications, specifically smooth RGB color transitions
-- for vehicle neon lights and primary/secondary paint colors.

-- Loading necessary utility modules.
local network_utils = require("network_utils") -- Module for network utilities (e.g., requesting control).

--- Initializes and returns a new transition state table.
-- This table holds the current step and color cycle index for a smooth color transition.
-- @returns table A new transition state table.
function create_transition_state()
    return {
        current_step = 0,         -- Current step in the transition (0 to transition_steps - 1).
        color_cycle_index = 1,    -- Index of the current starting color in the color cycle.
    }
end

-- Global script variables for timing and transition states.
local main_loop_wait_time = 500 -- Default wait time for the main script loop in milliseconds.

-- State tables for different dynamic color transitions.
-- Each transition (neon, primary/secondary color) maintains its own state.
local dynamic_neon_transition_state = create_transition_state()
local dynamic_color_transition_state = create_transition_state()

-- Common parameters for color transitions.
local transition_duration_ms = 2000 -- Total duration of one full color transition cycle in milliseconds.
local transition_steps = 100        -- Number of steps (frames) for one full color transition.

--- Sets the neon color of a vehicle.
-- This is a wrapper function for the native `SET_VEHICLE_NEON_COLOUR`.
-- @param vehicle_handle number The handle of the vehicle.
-- @param r number Red component (0-255).
-- @param g number Green component (0-255).
-- @param b number Blue component (0-255).
function set_dynamic_neon_color(vehicle_handle, r, g, b)
    VEHICLE.SET_VEHICLE_NEON_COLOUR(vehicle_handle, r, g, b)
end

--- Sets the custom primary and secondary colors of a vehicle.
-- This is a wrapper function for native vehicle color setting.
-- @param vehicle_handle number The handle of the vehicle.
-- @param r number Red component (0-255).
-- @param g number Green component (0-255).
-- @param b number Blue component (0-255).
function set_dynamic_vehicle_color(vehicle_handle, r, g, b)
    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle_handle, r, g, b)
    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle_handle, r, g, b)
end

--- Interpolates between two RGB colors.
-- @param start_color table A table {R, G, B} representing the starting color.
-- @param end_color table A table {R, G, B} representing the ending color.
-- @param t number The interpolation factor (0.0 to 1.0).
-- @returns table A table {R, G, B} representing the interpolated color.
function interpolate_rgb_color(start_color, end_color, t)
    local current_color = {}
    for i = 1, 3 do
        current_color[i] = math.floor(start_color[i] + (end_color[i] - start_color[i]) * t)
    end
    return current_color
end

--- Performs one iteration of a smooth RGB color transition for a vehicle.
-- This function manages the state of a single color transition (e.g., neon or paint).
-- It cycles through a predefined list of colors (Red, Green, Blue).
-- @param state_table table The state table for this specific transition (e.g., dynamic_neon_transition_state).
-- @param set_color_function function The function to call to apply the color (e.g., set_dynamic_neon_color).
-- @param target_vehicle number The handle of the vehicle to apply the color to.
-- @param transition_duration number The total duration of one full color cycle in milliseconds.
-- @param transition_total_steps number The total number of steps for one full color cycle.
function update_smooth_rgb_transition(state_table, set_color_function, target_vehicle, transition_duration, transition_total_steps)
    -- Predefined colors for the cycle (Red, Green, Blue).
    local colors = {
        {255, 0, 0},   -- Red
        {0, 255, 0},   -- Green
        {0, 0, 255},   -- Blue
    }

    -- If the current step has reached or exceeded the total steps, reset and move to the next color.
    if state_table.current_step >= transition_total_steps then
        state_table.current_step = 0
        state_table.color_cycle_index = (state_table.color_cycle_index % #colors) + 1 -- Move to the next color in the cycle.
    end

    -- Determine the starting and ending colors for the current interpolation segment.
    local start_color = colors[state_table.color_cycle_index]
    local end_color = colors[(state_table.color_cycle_index % #colors) + 1] -- The next color in the cycle.

    -- Calculate the normalized interpolation parameter (t from 0.0 to 1.0).
    local t_param = state_table.current_step / transition_total_steps
    local interpolated_color = interpolate_rgb_color(start_color, end_color, t_param)

    -- Apply the interpolated color to the vehicle using the provided function.
    set_color_function(target_vehicle, interpolated_color[1], interpolated_color[2], interpolated_color[3])

    -- Increment the current step for the next iteration.
    state_table.current_step = state_table.current_step + 1
end

--[[
-- Example of loading a particle effect asset.
STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2")
while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_rcbarry2") do
    Wait(0) -- Wait until the particle effect asset is loaded.
end
print("PTFX asset 'scr_rcbarry2' successfully loaded.")
]]

-- Main script loop.
-- This loop continuously checks global variables to apply dynamic vehicle modifications.
while ScriptStillWorking do
    main_loop_wait_time = 500 -- Reset wait time to default at the start of each loop.

    -- Check for Dynamic Neon Light feature.
    if IsGlobalVariableExist("DynamicNeonVehicle") and GetGlobalVariable("DynamicNeonVehicle") ~= 0.0 then
        local target_vehicle_handle = GetGlobalVariable("DynamicNeonVehicle")
        
        -- Ensure the vehicle exists before attempting to modify it.
        if target_vehicle_handle ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(target_vehicle_handle) then
            network_utils.request_control_of(target_vehicle_handle) -- Request network control of the vehicle.
            update_smooth_rgb_transition(dynamic_neon_transition_state, set_dynamic_neon_color, target_vehicle_handle, transition_duration_ms, transition_steps)
            main_loop_wait_time = 200 -- Reduce wait time if dynamic neon is active.
        end
    end

    -- Check for Dynamic Primary/Secondary Color feature.
    if IsGlobalVariableExist("DynamicColorVehicle") and GetGlobalVariable("DynamicColorVehicle") ~= 0.0 then
        local target_vehicle_handle = GetGlobalVariable("DynamicColorVehicle")
        
        -- Ensure the vehicle exists before attempting to modify it.
        if target_vehicle_handle ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(target_vehicle_handle) then
            network_utils.request_control_of(target_vehicle_handle) -- Request network control of the vehicle.
            update_smooth_rgb_transition(dynamic_color_transition_state, set_dynamic_vehicle_color, target_vehicle_handle, transition_duration_ms, transition_steps)
            main_loop_wait_time = 200 -- Reduce wait time if dynamic color is active.
        end
    end

    --[[
    -- Example of particle effects at vehicle taillights.
    local current_player_vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
    -- Check if the player is in a vehicle.
    if current_player_vehicle ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(current_player_vehicle) then
        local rear_right_light_bone = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(current_player_vehicle, "taillight_r") -- Rear right taillight bone.
        local rear_left_light_bone = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(current_player_vehicle, "taillight_l")  -- Rear left taillight bone.

        -- Get world coordinates for the taillight bones.
        local rear_right_light_pos = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(current_player_vehicle, rear_right_light_bone)
        local rear_left_light_pos = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(current_player_vehicle, rear_left_light_bone)

        -- Start non-looped particle effects at the taillight positions.
        -- Note: "scr_clown_appears" is a specific effect, ensure "scr_rcbarry2" asset is loaded for it.
        GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry2") -- Must use the asset containing the effect.
        GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_clown_appears", rear_right_light_pos.x, rear_right_light_pos.y, rear_right_light_pos.z + 0.5, 0.0, 0.0, 0.0, 0, 5.0, false, false, false)
        GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_clown_appears", rear_left_light_pos.x, rear_left_light_pos.y, rear_left_light_pos.z + 0.5, 0.0, 0.0, 0.0, 0, 5.0, false, false, false)
        main_loop_wait_time = 10 -- Reduce wait time for frequent particle updates.
    end
    ]]
    Wait(main_loop_wait_time) -- Pause script execution for the calculated wait time.
end

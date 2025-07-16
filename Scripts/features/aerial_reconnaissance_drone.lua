-- This script implements the Aerial Reconnaissance Drone (ARD) feature,
-- allowing the player to control a drone camera and fire missiles.

-- Global variables to manage the drone's state and missile count.
RegisterGlobalVariable("AerialReconnaissanceDroneState", 0.0)      -- 0.0 for inactive, 1.0 for active.
RegisterGlobalVariable("AerialReconnaissanceDroneMissilesCount", 0.0) -- Stores the number of missiles available.

-- Loading necessary utility modules.
local mission_utils = require("mission_utils") -- Module for mission-related utilities (e.g., camera creation).
local network_utils = require("network_utils") -- Module for network utilities (e.g., requesting control).
local config_utils = require("config_utils")   -- Module for configuration utilities.
local weapons_enum = require("weapon_enums")

-- Hotkey variables for drone control, initialized from configuration settings.
local ard_move_forward_key = nil
local ard_move_backward_key = nil
local ard_move_left_key = nil
local ard_move_right_key = nil
local ard_exit_key = nil

-- State variables for the drone.
local drone_camera = nil           -- Camera object for drone view.
local drone_entity = nil           -- Drone object handle.
local drone_sound_id = nil         -- Sound ID for drone engine/flight sound.
local drone_position_updated = false -- Flag to track if drone position was updated in current tick.
local player_ped_handle = nil      -- Player ped handle (who launched the drone).
local current_camera_position = { x = 0, y = 0, z = 150 } -- Initial camera position above the player.
local camera_rotation = { x = 0, y = 0 } -- Camera rotation angles (pitch, yaw).
local drone_move_speed = 2.0       -- Movement speed of the drone.
local max_camera_height = 1000.0   -- Maximum altitude the drone camera can reach.
local height_adjustment_speed = 3.0 -- Change in height when scrolling the mouse wheel.
local is_drone_active = false      -- Flag indicating if the drone system is currently active.

local current_missiles_count = 8   -- Number of missiles available for firing.

--- Fires a volley of missiles from the drone's current camera position.
-- Missiles are spread randomly within a defined radius.
function fire_drone_missiles()
    local explosion_radius = 35.0 -- Radius for random missile spread.

    -- Get the current camera's coordinates (which represents the drone's firing origin).
    local camera_coords = CAM.GET_CAM_COORD(drone_camera)
    local start_x = camera_coords.x
    local start_y = camera_coords.y
    local start_z = camera_coords.z - 1.0 -- Slightly below camera for firing.

    -- Iterate to fire multiple missiles.
    for i = 1, current_missiles_count do
        local target_x = start_x
        local target_y = start_y
        local target_z = start_z - 500.0 -- Missile travels downwards for 500 units.

        -- Generate random offsets within the radius for spread.
        local random_offset_x = math.random(-explosion_radius, explosion_radius)
        local random_offset_y = math.random(-explosion_radius, explosion_radius)

        -- Ensure offsets do not exceed the defined radius.
        if math.sqrt(random_offset_x^2 + random_offset_y^2) > explosion_radius then
            local scale_factor = explosion_radius / math.sqrt(random_offset_x^2 + random_offset_y^2)
            random_offset_x = random_offset_x * scale_factor
            random_offset_y = random_offset_y * scale_factor
        end

        -- Adjust target coordinates with random offsets.
        target_x = target_x + random_offset_x
        target_y = target_y + random_offset_y

        -- Fire a single bullet (missile) between the coordinates.
        -- Parameters: start_x, start_y, start_z, end_x, end_y, end_z,
        --             weapon_damage, speed, weapon_hash, owner_ped, is_audible, is_invisible, range
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(start_x, start_y, start_z,
                                                target_x, target_y, target_z,
                                                1000, true,
                                                weapons_enum.Weapon.WEAPON_STINGER --[[MISC.GET_HASH_KEY("VEHICLE_WEAPON_RUINER_ROCKET")]],
                                                PLAYER.PLAYER_PED_ID(), true, false, 2700.0)
    end
    Wait(50) -- Small delay after firing missiles to prevent spam.
end

--- Initializes (spawns) the drone object in the game world.
-- @param x number X-coordinate for spawn.
-- @param y number Y-coordinate for spawn.
-- @param z number Z-coordinate for spawn.
-- @param z_offset number Z-offset for drone position relative to camera (unused in calls, always 0.00).
function init_drone(x, y, z, z_offset)
    local drone_model_hash = MISC.GET_HASH_KEY("xs_prop_arena_drone_02") -- Model hash for the drone.
    local iterations = 0
    drone_entity = 0.0 -- Initialize drone handle.
    drone_position_updated = false -- Reset update flag.
    
    -- Request and load the drone model.
    STREAMING.REQUEST_MODEL(drone_model_hash)
    while not STREAMING.HAS_MODEL_LOADED(drone_model_hash) and iterations < 25 do
        iterations = iterations + 1
        Wait(10) -- Wait for model to load.
    end

    -- Create the drone object if model loaded successfully.
    if STREAMING.HAS_MODEL_LOADED(drone_model_hash) then
        drone_entity = OBJECT.CREATE_OBJECT_NO_OFFSET(drone_model_hash, x, y, z + z_offset, false, false, true, 0)
    else
        DisplayError(false, "Failed to load drone model: xs_prop_arena_drone_02")
        return nil -- Exit if model failed to load.
    end

    if drone_entity ~= 0.0 then
        network_utils.register_as_network(drone_entity) -- Register drone for network synchronization.

        -- Configure drone properties.
        ENTITY.SET_ENTITY_INVINCIBLE(drone_entity, true)
        ENTITY.SET_ENTITY_COLLISION(drone_entity, true, false)
        ENTITY.SET_ENTITY_VISIBLE(drone_entity, true, true)
        STREAMING.SET_FOCUS_ENTITY(drone_entity) -- Focus game rendering on the drone.

        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(drone_model_hash) -- Release model hash.

        -- Play drone engine sound.
        drone_sound_id = AUDIO.GET_SOUND_ID()
        AUDIO.PLAY_SOUND_FROM_ENTITY(drone_sound_id, "Flight_Loop", drone_entity, "DLC_H3_Prep_Drones_Sounds", true, 0)
    else
        DisplayError(false, "Failed to create drone entity.")
    end
end

--- Deletes and cleans up the drone object and its associated sound.
function delete_drone()
    if drone_entity then
        ENTITY.SET_ENTITY_INVINCIBLE(drone_entity, false) -- Make drone vulnerable before deletion.
        -- Move drone away before deleting (helps with cleanup in some cases).
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(drone_entity, current_camera_position.x, current_camera_position.y + 1.0, current_camera_position.z, false, false, false)

        -- Request network control of the drone before attempting deletion.
        network_utils.request_control_of(drone_entity)
        
        -- Delete the drone object.
        DeleteObject(drone_entity) -- Assuming DeleteObject takes the entity handle directly.
        
        -- If the drone still exists after DeleteObject (e.g., network sync issue), try marking as no longer needed.
        if ENTITY.DOES_ENTITY_EXIST(drone_entity) then
            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(drone_entity)
        end

        STREAMING.SET_FOCUS_ENTITY(PLAYER.PLAYER_PED_ID()) -- Return game focus to the player.
    end

    -- Stop and release drone sound.
    if drone_sound_id ~= 0 and drone_sound_id ~= -1 then -- Check for valid sound ID.
        AUDIO.STOP_SOUND(drone_sound_id)
        AUDIO.RELEASE_SOUND_ID(drone_sound_id)
    end
    drone_sound_id = nil -- Clear sound ID.
    drone_entity = nil   -- Clear drone handle.
end

--- Updates the drone's position to match the camera's position with an offset.
-- This function is called to keep the physical drone object synchronized with the camera.
-- @param cam_handle number The handle of the camera.
-- @param z_offset number Z-offset for drone position relative to camera (unused in calls, always 0.00).
function update_drone_from_camera(cam_handle, z_offset)
    -- Only update if the drone's position hasn't been updated yet in this tick.
    if not drone_position_updated then
        local camera_coords = CAM.GET_CAM_COORD(cam_handle)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(drone_entity, camera_coords.x, camera_coords.y, camera_coords.z + z_offset, false, false, false)
    end
    drone_position_updated = true -- Mark as updated for this tick.
end

--- Updates the drone's position based on explicit coordinates.
-- This function is similar to `update_drone_from_camera` but takes direct coordinates.
-- @param x number X-coordinate for drone.
-- @param y number Y-coordinate for drone.
-- @param z number Z-coordinate for drone.
-- @param z_offset number Z-offset for drone position relative to camera (unused in calls, always 0.00).
function update_drone_position(x, y, z, z_offset)
    -- Only update if the drone's position hasn't been updated yet in this tick.
    if not drone_position_updated then
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(drone_entity, x, y, z + z_offset, false, false, false)
    end
    drone_position_updated = true -- Mark as updated for this tick.
end

--- Enables the Aerial Reconnaissance Drone mode.
-- Sets up the camera, spawns the drone, and takes player control.
function enable_aerial_reconnaissance_drone()
    if not is_drone_active then
        AUDIO.PLAY_SOUND_FRONTEND(drone_sound_id, "Pilot_Perspective_Fire", "DLC_H3_Drone_Tranq_Weapon_Sounds", false) -- Play activation sound.

        player_ped_handle = PLAYER.PLAYER_PED_ID() -- Get the local player's ped handle.
        local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped_handle, true)

        -- Set initial camera position relative to the player.
        current_camera_position.x = player_coords.x
        current_camera_position.y = player_coords.y
        current_camera_position.z = player_coords.z + current_camera_position.z -- Adds initial Z offset.

        CAM.DO_SCREEN_FADE_OUT(450) -- Fade screen out.
        Wait(500)

        -- Create a fly camera for drone control.
        drone_camera = mission_utils.create_fly_camera(current_camera_position.x, current_camera_position.y, current_camera_position.z, 0.0, 0.0, -90.0, max_camera_height, 1000)

        init_drone(current_camera_position.x, current_camera_position.y, current_camera_position.z, 0.00) -- Initialize the drone object.

        PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), false, 0) -- Disable player control.

        Wait(200)
        CAM.DO_SCREEN_FADE_IN(1000) -- Fade screen in.

        -- Disable specific control actions (e.g., ESC menu, although original comments say "dont work").
        PAD.DISABLE_CONTROL_ACTION(1, 27, true)  -- Disable context action (e.g., weapon wheel).
        PAD.DISABLE_CONTROL_ACTION(2, 199, true) -- Disable Pause menu (ESC) - original comment: "dont work"
        PAD.DISABLE_CONTROL_ACTION(2, 200, true) -- Disable Pause menu (ESC) - original comment: "dont work"
        PAD.DISABLE_CONTROL_ACTION(2, 202, true) -- Disable Pause menu (ESC) - original comment: "dont work"

        is_drone_active = true -- Mark drone as active.
        SetGlobalVariableValue("AerialReconnaissanceDroneState", 1.0) -- Update global state.

        -- Retrieve missile count from global variable, default to 8 if not found or invalid.
        if IsGlobalVariableExist("AerialReconnaissanceDroneMissilesCount") then
            local loaded_missiles_count = GetGlobalVariable("AerialReconnaissanceDroneMissilesCount")
            if loaded_missiles_count and loaded_missiles_count >= 0 then
                current_missiles_count = loaded_missiles_count
            else
                current_missiles_count = 8 -- Default if global variable is invalid.
            end
        else
            current_missiles_count = 8 -- Default if global variable does not exist.
        end
    end
end

--- Disables the Aerial Reconnaissance Drone mode.
-- Returns player control, cleans up camera and drone.
function disable_aerial_reconnaissance_drone()
    if is_drone_active then
        player_ped_handle = nil -- Clear player ped handle.

        CAM.DO_SCREEN_FADE_OUT(450) -- Fade screen out.
        Wait(500)
        
        -- Stop rendering and destroy the drone camera.
        CAM.RENDER_SCRIPT_CAMS(false, false, 0, false, false, 0) -- Stop rendering script camera.
        CAM.SET_CAM_ACTIVE(drone_camera, false) -- Deactivate drone camera.
        mission_utils.delete_camera(drone_camera) -- Delete the camera object.
        drone_camera = nil

        delete_drone() -- Delete the physical drone object and stop its sound.

        PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), true, 0) -- Re-enable player control.

        Wait(200)
        CAM.DO_SCREEN_FADE_IN(1000) -- Fade screen in.

        Wait(1000) -- Additional wait after fade-in.
        
        -- Re-enable control actions (original comments: "dont work").
        PAD.ENABLE_CONTROL_ACTION(2, 199, true) -- Re-enable Pause menu (ESC) - original comment: "dont work"
        PAD.ENABLE_CONTROL_ACTION(2, 200, true) -- Re-enable Pause menu (ESC) - original comment: "dont work"
        PAD.ENABLE_CONTROL_ACTION(2, 202, true) -- Re-enable Pause menu (ESC) - original comment: "dont work"

        is_drone_active = false -- Mark drone as inactive.
        SetGlobalVariableValue("AerialReconnaissanceDroneState", 0.0) -- Update global state.
    end
end

--- Checks if the player's ped is currently below ground level.
-- This function was commented out in the original `OnTick` but is kept for completeness.
-- @returns boolean True if player is below ground, false otherwise.
function is_player_below_ground()
    local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped_handle, true) -- Get current player coordinates.
    local ground_z = nil

    local ground_z_ptr = New(4) -- Allocate memory for ground Z-coordinate.

    -- Get the ground Z-coordinate at player's X, Y position.
    MISC.GET_GROUND_Z_FOR_3D_COORD(player_coords.x, player_coords.y, player_coords.z, ground_z_ptr, false, true)
    ground_z = Game.ReadFloat(ground_z_ptr) -- Read the float value.

    Delete(ground_z_ptr) -- Free allocated memory.

    -- Check if the player's Z-coordinate is below the ground Z-coordinate.
    return player_coords.z < ground_z
end

--- Checks the state of the Aerial Reconnaissance Drone.
-- Disables the drone if the exit key is pressed or if the player ped no longer exists/is dead.
-- @returns boolean True if the drone should remain active, false otherwise.
function check_ard_state()
    -- Check if the exit key is pressed and drone is active.
    if IsPressedKey(ard_exit_key) and is_drone_active then
        disable_aerial_reconnaissance_drone()
        return false
    -- Check if the player ped (pilot) no longer exists or is dead.
    elseif not ENTITY.DOES_ENTITY_EXIST(player_ped_handle) or ENTITY.IS_ENTITY_DEAD(player_ped_handle, false) then
        disable_aerial_reconnaissance_drone()
        return false
    end

    return true -- Drone should remain active.
end

--- Main update loop for drone control and actions.
-- This function is called repeatedly when the drone is active.
function on_tick()
    if check_ard_state() then -- Only proceed if drone should remain active.

        -- Mouse wheel for adjusting camera height (Z-axis movement).
        if Mouse.IsMouseWheelScrolledUp() then
            current_camera_position.z = current_camera_position.z + height_adjustment_speed
            -- Update drone's physical position to match camera's new height.
            update_drone_position(current_camera_position.x, current_camera_position.y, current_camera_position.z, 0.00)
        elseif Mouse.IsMouseWheelScrolledDown() then
            current_camera_position.z = current_camera_position.z - height_adjustment_speed

            -- Original commented out logic to prevent going below ground:
            --[[
            if is_player_below_ground() then
                current_camera_position.z = current_camera_position.z + height_adjustment_speed
            end
            ]]
            -- Update drone's physical position to match camera's new height.
            update_drone_position(current_camera_position.x, current_camera_position.y, current_camera_position.z, 0.00)
        end

        -- Calculate forward and right vectors based on camera rotation (yaw).
        local forward_vector = { 
            x = -math.sin(math.rad(camera_rotation.y)), -- Y is yaw in original
            y = math.cos(math.rad(camera_rotation.y))
        }
        local right_vector = { 
            x = forward_vector.y, 
            y = -forward_vector.x 
        }

        -- Update camera position based on WASD key presses.
        if IsPressedKey(ard_move_forward_key) then
            current_camera_position.x = current_camera_position.x + forward_vector.x * drone_move_speed
            current_camera_position.y = current_camera_position.y + forward_vector.y * drone_move_speed
        end
        if IsPressedKey(ard_move_backward_key) then
            current_camera_position.x = current_camera_position.x - forward_vector.x * drone_move_speed
            current_camera_position.y = current_camera_position.y - forward_vector.y * drone_move_speed
        end
        if IsPressedKey(ard_move_left_key) then
            current_camera_position.x = current_camera_position.x - right_vector.x * drone_move_speed
            current_camera_position.y = current_camera_position.y - right_vector.y * drone_move_speed
        end
        if IsPressedKey(ard_move_right_key) then
            current_camera_position.x = current_camera_position.x + right_vector.x * drone_move_speed
            current_camera_position.y = current_camera_position.y + right_vector.y * drone_move_speed
        end

        -- Set the camera's new position.
        CAM.SET_CAM_COORD(drone_camera, current_camera_position.x, current_camera_position.y, current_camera_position.z)
        -- Update the physical drone object's position to match the camera.
        update_drone_from_camera(drone_camera, 0.00)

        -- Check for left mouse button press to fire missiles.
        if Mouse.IsLeftButtonPressed() then
            fire_drone_missiles()
        end

        drone_position_updated = false -- Reset flag for the next tick.
    end
end

--- Initializes hotkey settings for the Aerial Reconnaissance Drone from configuration.
-- Reads key codes for movement and exit from the config file.
function initialize_settings()
    ard_move_forward_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "ARDMoveForwardKey"))
    ard_move_backward_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "ARDMoveBackwardKey"))
    ard_move_left_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "ARDMoveLeftKey"))
    ard_move_right_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "ARDMoveRightKey"))
    ard_exit_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "ARDExit"))
end

-- Initialize settings when the script starts.
initialize_settings()

-- Enable the Aerial Reconnaissance Drone mode immediately upon script execution.
enable_aerial_reconnaissance_drone()

-- Main script loop.
-- This loop continues as long as the script is active, the drone system is active,
-- and the global state variable indicates the drone is active.
while ScriptStillWorking and is_drone_active and GetGlobalVariable("AerialReconnaissanceDroneState") == 1.0 do
    on_tick() -- Call the main update function for drone control.
    Wait(1)   -- Yield control to other scripts and the game engine.
end

-- If the loop exits (e.g., drone deactivated), ensure a final cleanup.
if is_drone_active then
    disable_aerial_reconnaissance_drone()
end

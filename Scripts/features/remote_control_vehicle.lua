-- This script provides functionality for remotely controlling a vehicle in GTA V.
-- It manages camera views, movement, engine sound, and hotkey configurations.

-- Loading necessary utility modules.
local bone_enums = require("bone_enums")     -- Module for vehicle bone enumerations.
local network_utils = require("network_utils") -- Module for network-related utilities (e.g., requesting control).
local mission_utils = require("mission_utils") -- Module for mission-related utilities (e.g., camera creation).
local config_utils = require("config_utils") -- Module for configuration utilities.

-- Hotkey variables, initialized from configuration settings.
local rc_move_forward_main_key = nil
local rc_move_backward_main_key = nil
local rc_move_left_main_key = nil
local rc_move_right_main_key = nil
local rc_move_forward_secondary_key = nil
local rc_move_backward_secondary_key = nil
local rc_move_left_secondary_key = nil
local rc_move_right_secondary_key = nil
local rc_change_view_key = nil
local rc_exit_key = nil

-- State variables for remote control.
local rc_active = false        -- True if remote control is currently active.
local rc_initialized = false   -- True if RC system has been initialized (camera, player control).
local rc_vehicle = 0.0         -- Handle of the vehicle being controlled.
local rc_camera = nil          -- Camera object for RC view.
local current_bone = 0         -- Current bone index (used for debugging camera attachment).

local current_view = 0         -- Current camera view mode (0: default, 1: bonnet, 2: interior, 3: player control).

local backward_movement_speed = 0.0 -- Accumulator for backward movement speed.
local steering_input = 0.0         -- Placeholder for steering input (not directly used in current turning logic).
local turn_speed = 2.0             -- Turning speed when using direct heading manipulation.


-- Default movement keys (can be overridden by secondary keys in certain views).
local move_forward_key = 0x57  -- W key
local move_backward_key = 0x53 -- S key
local move_left_key = 0x41     -- A key
local move_right_key = 0x44    -- D key

local engine_sound_id = nil       -- Variable to store the sound ID for engine audio.
local is_engine_sound_playing = false -- Flag to track if the engine sound is currently playing.

local wait_time = 100 -- Default wait time for the main loop, reduced when RC is active.

--- Enables remote control mode for the specified vehicle.
-- Sets up the camera, takes player control, and requests vehicle control.
function enable_remote_control()
    rc_vehicle = GetGlobalVariable("RemoteControlVehicle") -- Retrieve the vehicle handle from global variable.

    -- Create and attach the camera to the RC vehicle.
    rc_camera = mission_utils.create_camera(0.0, 0.0, 0.0, ENTITY.GET_ENTITY_HEADING(rc_vehicle), 0.0, 0.0, 1000)
    -- Initial camera attachment: slightly behind and above the vehicle.
    CAM.ATTACH_CAM_TO_ENTITY(rc_camera, rc_vehicle, 0.0, -5.0, 1.5, true)

    STREAMING.SET_FOCUS_ENTITY(rc_vehicle) -- Focus game rendering on the RC vehicle.
    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(PLAYER.PLAYER_PED_ID(), true, 0) -- Ensure player ped collision is loaded.
    PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), false, 0) -- Disable player control.

    network_utils.request_control_of(rc_vehicle) -- Request network control of the vehicle.
    VEHICLE.SET_VEHICLE_ENGINE_ON(rc_vehicle, true, true, false) -- Turn on the vehicle engine.

    rc_initialized = true -- Mark RC system as initialized.
end

--- Disables remote control mode.
-- Resets camera, returns player control, and stops engine sound.
function disable_remote_control()
    if rc_camera then
        mission_utils.delete_camera(rc_camera) -- Delete the RC camera.
        rc_camera = nil
    end

    STREAMING.SET_FOCUS_ENTITY(PLAYER.PLAYER_PED_ID()) -- Return focus to the player.
    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(PLAYER.PLAYER_PED_ID(), false, 0) -- Reset player ped collision flag.
    PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), true, 0) -- Return player control.

    VEHICLE.SET_VEHICLE_ENGINE_ON(rc_vehicle, false, false, false) -- Turn off the vehicle engine.

    if engine_sound_id then
        AUDIO.STOP_SOUND(engine_sound_id) -- Stop engine sound if playing.
        AUDIO.RELEASE_SOUND_ID(engine_sound_id) -- Release the sound ID.
        engine_sound_id = nil
    end

    rc_vehicle = nil -- Clear vehicle handle.
    rc_camera = nil  -- Clear camera handle.
    current_view = 0 -- Reset view mode.
    rc_initialized = false -- Mark RC system as uninitialized.

    SetGlobalVariableValue("RemoteControlVehicle", 0.0) -- Explicitly set global variable to 0.0 to disable RC.
end

--- Checks the state of the remote control system.
-- Disables RC if exit key is pressed or if the vehicle no longer exists or is dead.
-- @returns boolean True if RC should remain active, false if it should be disabled.
function check_rc_state()
    -- Check if the exit key is pressed and RC is active.
    if IsPressedKey(rc_exit_key) and rc_active then
        disable_remote_control()
        return false
    -- Check if the RC vehicle no longer exists or is dead.
    elseif not ENTITY.DOES_ENTITY_EXIST(rc_vehicle) or ENTITY.IS_ENTITY_DEAD(rc_vehicle, false) then
        disable_remote_control()
        return false
    end
    return true -- RC should remain active.
end

--- Plays the vehicle engine sound.
-- Initializes and plays the engine sound if it's not already playing.
function play_engine_sound()
    if not engine_sound_id then
        engine_sound_id = AUDIO.GET_SOUND_ID() -- Get a new sound ID.
        -- Play the engine sound from the vehicle entity.
        AUDIO.PLAY_SOUND_FROM_ENTITY(engine_sound_id, "Engine_Revs", rc_vehicle, "DLC_HEISTS_GENERIC_SOUNDS", true, 0)
        is_engine_sound_playing = true
    end
end

--- Stops the vehicle engine sound.
-- Releases the sound ID if the sound is playing.
function stop_engine_sound()
    if engine_sound_id then
        AUDIO.STOP_SOUND(engine_sound_id) -- Stop the sound.
        AUDIO.RELEASE_SOUND_ID(engine_sound_id) -- Release the sound ID.
    
        engine_sound_id = nil
        is_engine_sound_playing = false
    end
end

--- Drives the RC vehicle forward.
-- Increases the vehicle's forward speed.
function drive_forward()
    if not ENTITY.IS_ENTITY_IN_AIR(rc_vehicle) then
        -- Set vehicle forward speed based on current speed and acceleration.
        VEHICLE.SET_VEHICLE_FORWARD_SPEED(rc_vehicle, ENTITY.GET_ENTITY_SPEED(rc_vehicle) + VEHICLE.GET_VEHICLE_ACCELERATION(rc_vehicle) * 3.25)
    end
    play_engine_sound() -- Play engine sound when moving.
end

--- Drives the RC vehicle backward.
-- Decreases the vehicle's forward speed (applies reverse).
function drive_backward()
    if not ENTITY.IS_ENTITY_IN_AIR(rc_vehicle) then
        backward_movement_speed = backward_movement_speed + 0.2
        VEHICLE.SET_VEHICLE_FORWARD_SPEED(rc_vehicle, ENTITY.GET_ENTITY_SPEED(rc_vehicle) - backward_movement_speed)
    end
    play_engine_sound() -- Play engine sound when moving.
end

--- Turns the RC vehicle left.
-- Directly sets the entity's heading.
function turn_left()
    if not ENTITY.IS_ENTITY_IN_AIR(rc_vehicle) then
        local heading = ENTITY.GET_ENTITY_HEADING(rc_vehicle) -- Get current heading.
        heading = heading + turn_speed -- Increase heading for left turn.
        ENTITY.SET_ENTITY_HEADING(rc_vehicle, heading) -- Set new heading.
        CAM.SET_CAM_ROT(rc_camera, 0.0, 0.0, ENTITY.GET_ENTITY_HEADING(rc_vehicle), 2) -- Update camera rotation.
    end
end

--- Turns the RC vehicle right.
-- Directly sets the entity's heading.
function turn_right()
    if not ENTITY.IS_ENTITY_IN_AIR(rc_vehicle) then
        local heading = ENTITY.GET_ENTITY_HEADING(rc_vehicle) -- Get current heading.
        heading = heading - turn_speed -- Decrease heading for right turn.
        ENTITY.SET_ENTITY_HEADING(rc_vehicle, heading) -- Set new heading.
        CAM.SET_CAM_ROT(rc_camera, 0.0, 0.0, ENTITY.GET_ENTITY_HEADING(rc_vehicle), 2) -- Update camera rotation.
    end
end

--- Changes the camera view mode for the RC vehicle.
-- Cycles through different camera positions (default, bonnet, interior, player control).
function change_view()
    current_view = current_view + 1

    if current_view == 1 then
        -- Attach camera to bonnet bone.
        CAM.ATTACH_CAM_TO_VEHICLE_BONE(rc_camera, rc_vehicle, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(rc_vehicle, "bonnet"), false, ENTITY.GET_ENTITY_HEADING(rc_vehicle), 0.0, 0.0, 0.0, 0.0, 0.3, true)
        CAM.RENDER_SCRIPT_CAMS(true, true, 1000, true, true, 0)
    elseif current_view == 2 then
        -- Attach camera to driver's seat bone.
        CAM.ATTACH_CAM_TO_VEHICLE_BONE(rc_camera, rc_vehicle, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(rc_vehicle, "seat_dside_f"), false, ENTITY.GET_ENTITY_HEADING(rc_vehicle), 0.0, 0.0, 0.0, 0.0, 0.6, true)
        CAM.RENDER_SCRIPT_CAMS(true, true, 1000, true, true, 0)
    elseif current_view == 3 then
        -- Return control to player and disable script camera.
        CAM.RENDER_SCRIPT_CAMS(false, false, 0, true, true, 0)
        -- Switch to secondary keys (if defined for player control).
        move_forward_key = rc_move_forward_secondary_key
        move_backward_key = rc_move_backward_secondary_key
        move_left_key = rc_move_left_secondary_key
        move_right_key = rc_move_right_secondary_key

        STREAMING.SET_FOCUS_ENTITY(PLAYER.PLAYER_PED_ID()) -- Focus back on player.
        PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), true, 0) -- Re-enable player control.
    else
        -- Return to default external view.
        CAM.ATTACH_CAM_TO_ENTITY(rc_camera, rc_vehicle, 0.0, -5.0, 1.5, true)
        CAM.RENDER_SCRIPT_CAMS(true, true, 1000, true, true, 0)

        -- Switch back to main keys.
        move_forward_key = rc_move_forward_main_key
        move_backward_key = rc_move_backward_main_key
        move_left_key = rc_move_left_main_key
        move_right_key = rc_move_right_main_key

        STREAMING.SET_FOCUS_ENTITY(rc_vehicle) -- Focus back on RC vehicle.
        PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), false, 0) -- Disable player control.

        current_view = 0 -- Reset view counter.
    end
end

--- Main update loop for remote control logic.
-- This function is called repeatedly when RC is active.
function on_tick()
    if check_rc_state() then -- Only proceed if RC is still active and valid.
        -- Movement controls
        if IsPressedKey(move_forward_key) then -- Forward
            drive_forward()
        end
        if IsPressedKey(move_backward_key) then -- Backward
            drive_backward()
        else
            -- Decelerate backward movement when key is released.
            if backward_movement_speed > 0.0 then
                backward_movement_speed = backward_movement_speed - 0.2
            end
        end
        
        -- Turning controls
        if IsPressedKey(move_left_key) then -- Turn Left
            turn_left()
        end
        
        if IsPressedKey(move_right_key) then -- Turn Right
            turn_right()
        end

        -- Change view hotkey
        if IsPressedKey(rc_change_view_key) then
            change_view()
            Wait(100) -- Small delay to prevent rapid view changes.
        end

        -- DEBUG section (commented out in original, kept as is)
        --[[
        if IsPressedKey(0x25) then -- left arrow
            current_bone = current_bone + 1
            CAM.ATTACH_CAM_TO_VEHICLE_BONE(rc_camera, rc_vehicle, current_bone, false, ENTITY.GET_ENTITY_HEADING(rc_vehicle), 0.0, 0.0, 0.0, 0.0, 0.0, true)
            ResetLineAndPrint(current_bone)
            Wait(100)
        end
        if IsPressedKey(0x27) then -- right arrow
            current_bone = current_bone - 1
            CAM.ATTACH_CAM_TO_VEHICLE_BONE(rc_camera, rc_vehicle, current_bone, false, ENTITY.GET_ENTITY_HEADING(rc_vehicle), 0.0, 0.0, 0.0, 0.0, 0.0, true)
            ResetLineAndPrint(current_bone)
            Wait(100)
        end
        ]]

        -- Stop engine sound if vehicle is stationary.
        if ENTITY.GET_ENTITY_SPEED(rc_vehicle) == 0.0 then
            stop_engine_sound()
        else
            -- Ensure engine is on if moving (might be redundant if already on).
            VEHICLE.SET_VEHICLE_ENGINE_ON(rc_vehicle, true, true, false)
        end
    end
end

--- Initializes hotkey settings from configuration.
-- Reads key codes for remote control actions from "Hotkeys" section.
function initialize_settings()
    rc_move_forward_main_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "RCMoveForwardMainKey"))
    rc_move_backward_main_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "RCMoveBackwardMainKey"))
    rc_move_left_main_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "RCMoveLeftMainKey"))
    rc_move_right_main_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "RCMoveRightMainKey"))
    rc_move_forward_secondary_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "RCMoveForwardSecondaryKey"))
    rc_move_backward_secondary_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "RCMoveBackwardSecondaryKey"))
    rc_move_left_secondary_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "RCMoveLeftSecondaryKey"))
    rc_move_right_secondary_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "RCMoveRightSecondaryKey"))
    rc_change_view_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "RCChangeViewKey"))
    rc_exit_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "RCExitKey"))
end

-- Initialize settings when the script starts.
initialize_settings()

-- Main script loop.
while ScriptStillWorking do
    -- Check if the "RemoteControlVehicle" global variable exists.
    if IsGlobalVariableExist("RemoteControlVehicle") then
        -- Determine if RC is active based on the global variable's value.
        rc_active = GetGlobalVariable("RemoteControlVehicle") ~= 0.0

        -- State machine for enabling/disabling RC.
        if rc_active and not rc_initialized then 
            enable_remote_control()
            wait_time = 0 -- Reduce wait time for active RC loop.
        elseif not rc_active and rc_initialized then
            disable_remote_control()
            wait_time = 100 -- Restore default wait time when RC is inactive.
        end

        -- If RC is active, run the main tick logic.
        if rc_active then
            on_tick()
        end
    else
        -- If global variable doesn't exist, ensure default wait time.
        wait_time = 100
    end
    Wait(wait_time) -- Pause script execution.
end

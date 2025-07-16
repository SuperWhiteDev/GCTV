-- Hotkey variables, initialized from configuration settings.
local vehicle_boost_key = nil
local vehicle_extra_brake_key = nil
local vehicle_air_boost_key = nil
local vehicle_air_extra_brake_key = nil
local vehicle_indicator_light_left_key = nil
local vehicle_indicator_light_right_key = nil

-- State variables for vehicle features.
local vehicle_boost_value = 0.0 -- Current boost accumulation value.
local left_turn_signal_active = false -- True if left turn signal is on.
local right_turn_signal_active = false -- True if right turn signal is on.

-- Loading necessary utility modules.
local config_utils = require("config_utils") -- Module for configuration utilities.

--- Checks if the player is currently driving any vehicle (either directly or remotely).
-- @returns boolean True if the player is driving/controlling a vehicle, false otherwise.
function is_player_driving_any_vehicle()
    -- Check if a remote control vehicle is active.
    if IsGlobalVariableExist("RemoteControlVehicle") and GetGlobalVariable("RemoteControlVehicle") ~= 0.0 then
        return true
    else
        -- Check if the player is physically in any vehicle.
        -- The original `PED.IS_PED_IN_VEHICLE(PLAYER.PLAYER_PED_ID(), PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false), true)`
        -- is a bit redundant. `PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), true)` is simpler.
        return PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), true)
    end
end

--- Gets the handle of the vehicle currently being controlled by the player (local or remote).
-- @returns number The vehicle handle, or 0.0 if no vehicle is controlled.
function get_controlled_vehicle()
    -- Prioritize remote control vehicle if active.
    if IsGlobalVariableExist("RemoteControlVehicle") and GetGlobalVariable("RemoteControlVehicle") ~= 0.0 then
        return GetGlobalVariable("RemoteControlVehicle")
    else
        -- Otherwise, return the vehicle the local player is currently in.
        return PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    end
end

--- Updates the indicator lights of the player's controlled vehicle.
-- Sets the left and right turn signals based on their respective state variables.
function update_indicator_lights_player_vehicle()
    local current_vehicle = get_controlled_vehicle()
    if current_vehicle ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(current_vehicle) then
        VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(current_vehicle, 1, left_turn_signal_active)  -- 1 for left indicator.
        VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(current_vehicle, 0, right_turn_signal_active) -- 0 for right indicator.
    end
end

--- Updates various continuous vehicle features based on global variable states.
-- Includes auto-fix and disable lock-on.
function update_continuous_features()
    local current_vehicle = get_controlled_vehicle()

    -- Auto-Fix Current Vehicle.
    if IsGlobalVariableExist("AutoFixCurrentVehicleState") and GetGlobalVariable("AutoFixCurrentVehicleState") ~= 0.0 and is_player_driving_any_vehicle() then
        if current_vehicle ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(current_vehicle) then
            VEHICLE.SET_VEHICLE_FIXED(current_vehicle, false) -- Fixes visual damage, but not necessarily engine.
            -- Note: For full repair, VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, 1000.0) and VEHICLE.SET_VEHICLE_BODY_HEALTH(veh, 1000.0) might be needed.
        end
    end

    -- Disable Lock-On Current Vehicle.
    if IsGlobalVariableExist("DisableLockOnCurrentVehicleState") and GetGlobalVariable("DisableLockOnCurrentVehicleState") ~= 0.0 and is_player_driving_any_vehicle() then
        if current_vehicle ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(current_vehicle) then
            VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON(current_vehicle, false, false)
            VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(current_vehicle, false, false)
        end
    end
end

--- Initializes hotkey settings from configuration.
-- Reads key codes for vehicle boost, brake, and indicator lights.
function initialize_settings()
    vehicle_boost_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "VehicleBoostKey"))
    vehicle_extra_brake_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "VehicleExtraBrakeKey"))
    vehicle_air_boost_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "VehicleAirBoostKey"))
    vehicle_air_extra_brake_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "VehicleAirExtraBrakeKey"))
    vehicle_indicator_light_left_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "VehicleIndicatorLightLeftKey"))
    vehicle_indicator_light_right_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "VehicleIndicatorLightRightKey"))
end

-- Initialize settings when the script starts.
initialize_settings()

-- Main script loop for continuously checking hotkey presses and updating features.
while ScriptStillWorking do
    local current_vehicle = get_controlled_vehicle() -- Get vehicle once per loop iteration.

    -- Hotkey: Vehicle Boost (Ground)
    if IsPressedKey(vehicle_boost_key) and is_player_driving_any_vehicle() then
        if current_vehicle ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(current_vehicle) and not ENTITY.IS_ENTITY_IN_AIR(current_vehicle) then
            if vehicle_boost_value < 2.0 then
                vehicle_boost_value = 2.1 -- Initial boost value.
            else
                vehicle_boost_value = vehicle_boost_value + 0.34 -- Accumulate boost.
            end 
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(current_vehicle, ENTITY.GET_ENTITY_SPEED(current_vehicle) + vehicle_boost_value)
        end
    elseif vehicle_boost_value > 0.0 then
        -- Gradually reduce boost value when key is not pressed.
        vehicle_boost_value = vehicle_boost_value - 0.2
        if vehicle_boost_value < 0.0 then vehicle_boost_value = 0.0 end -- Ensure it doesn't go negative.
    end

    -- Hotkey: Vehicle Extra Brake (Ground)
    if IsPressedKey(vehicle_extra_brake_key) and is_player_driving_any_vehicle() then
        if current_vehicle ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(current_vehicle) and not ENTITY.IS_ENTITY_IN_AIR(current_vehicle) then
            local current_speed = ENTITY.GET_ENTITY_SPEED(current_vehicle)
            local target_speed = current_speed / 1.5 -- Reduce speed by a factor.
            if target_speed < 0.0 then
                target_speed = 0.0 -- Ensure speed doesn't go negative.
            end 
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(current_vehicle, target_speed)
            vehicle_boost_value = 0.0 -- Reset boost when braking.
        end
    end
    
    -- Hotkey: Vehicle Air Extra Brake
    if IsPressedKey(vehicle_air_extra_brake_key) and is_player_driving_any_vehicle() then
        if current_vehicle ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(current_vehicle) then
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(current_vehicle, 0.0) -- Stop vehicle immediately.
        end
    end

    -- Hotkey: Vehicle Air Boost
    if IsPressedKey(vehicle_air_boost_key) and is_player_driving_any_vehicle() then
        if current_vehicle ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(current_vehicle) then
            local vehicle_model = ENTITY.GET_ENTITY_MODEL(current_vehicle)
            -- Only apply air boost if vehicle is in air and is a plane or heli.
            if ENTITY.IS_ENTITY_IN_AIR(current_vehicle) and (VEHICLE.IS_THIS_MODEL_A_PLANE(vehicle_model) or VEHICLE.IS_THIS_MODEL_A_HELI(vehicle_model)) then
                if vehicle_boost_value < 3.0 then
                    vehicle_boost_value = 3.2 -- Initial air boost value.
                else
                    vehicle_boost_value = vehicle_boost_value + 0.65 -- Accumulate air boost.
                end 
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(current_vehicle, ENTITY.GET_ENTITY_SPEED(current_vehicle) + vehicle_boost_value)
            end
        end
    end

    -- Hotkey: Left Indicator Light
    if IsPressedKey(vehicle_indicator_light_left_key) and is_player_driving_any_vehicle() then
        left_turn_signal_active = not left_turn_signal_active -- Toggle left signal.
        right_turn_signal_active = false -- Turn off right signal if left is toggled.
        update_indicator_lights_player_vehicle()
        Wait(100) -- Small delay to prevent rapid toggling.
    -- Hotkey: Right Indicator Light
    elseif IsPressedKey(vehicle_indicator_light_right_key) and is_player_driving_any_vehicle() then
        right_turn_signal_active = not right_turn_signal_active -- Toggle right signal.
        left_turn_signal_active = false -- Turn off left signal if right is toggled.
        update_indicator_lights_player_vehicle()
        Wait(100) -- Small delay to prevent rapid toggling.
    end

    update_continuous_features() -- Update continuous features.

    Wait(100) -- General pause for the main loop to reduce CPU usage.
end

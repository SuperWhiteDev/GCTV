-- This script defines and manages hotkeys for various gameplay features,
-- such as healing the player, toggling thermal vision, and activating/deactivating noclip.

-- Global variable to control the active state of the noclip feature.
RegisterGlobalVariable("NoclipActive", 0.0) -- 0.0 for inactive, 1.0 for active.

-- Hotkey variables, initialized from configuration settings.
local heal_player_key = nil
local thermal_vision_key = nil
local noclip_key = nil

-- State variables for features.
local thermal_vision_state = false -- True if thermal vision is currently active.
local noclip_active_state = 0.0    -- Reflects the value of the "NoclipActive" global variable.

-- Loading necessary utility modules.
local config_utils = require("config_utils") -- Module for configuration utilities.

--- Toggles thermal vision on or off.
-- This function calls an external GCTV function (likely defined elsewhere) to apply the effect.
-- @param toggle boolean True to enable, false to disable thermal vision.
function set_thermal_vision(toggle)
    -- Assuming "SetThermalVision" is a global function provided by the GCTV API.
    -- The "nil" in the original Call("SetThermalVision", "nil", Toggle) might be a placeholder
    -- for a context or target, but given the usage, it's likely just the function name and arguments.
    Call("SetThermalVision", "nil", toggle)
end

--- Initializes hotkey settings from configuration.
-- Reads the key codes for "Heal Player", "Thermal Vision", and "Noclip" from the config file.
function initialize_settings()
    heal_player_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "HealPlayerKey"))
    thermal_vision_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "ThermalVisionKey"))
    noclip_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "NoclipKey"))
end

-- Initialize settings when the script starts.
initialize_settings()

-- Main script loop for continuously checking hotkey presses.
while ScriptStillWorking do
    -- Hotkey: Heal Player
    -- If the "HealPlayerKey" is pressed and player control is enabled.
    if IsPressedKey(heal_player_key) and PLAYER.IS_PLAYER_CONTROL_ON(PLAYER.PLAYER_ID()) then
        -- Heal player to full health and armor.
        ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), ENTITY.GET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID()), 0, 0)
        PED.SET_PED_ARMOUR(PLAYER.PLAYER_PED_ID(), 100)

        -- If the player is in a vehicle, heal the vehicle as well.
        local current_vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), 0) -- 0 for any vehicle.
        if current_vehicle ~= 0.0 then -- Check if a valid vehicle handle is returned.
            ENTITY.SET_ENTITY_HEALTH(current_vehicle, 1000, 0, 0) -- Set vehicle health to max (1000 is common max).
        end 
        
        Wait(100) -- Small delay to prevent rapid healing on single key press.
    end

    -- Hotkey: Thermal Vision
    -- If the "ThermalVisionKey" is pressed and player control is enabled.
    if IsPressedKey(thermal_vision_key) and PLAYER.IS_PLAYER_CONTROL_ON(PLAYER.PLAYER_ID()) then
        thermal_vision_state = not thermal_vision_state -- Toggle the state.
        set_thermal_vision(thermal_vision_state)      -- Apply the new state.

        Wait(100) -- Small delay to prevent rapid toggling.
    end

    -- Hotkey: Noclip
    -- If the "NoclipKey" is pressed.
    if IsPressedKey(noclip_key) then
        -- Toggle the global "NoclipActive" variable.
        if GetGlobalVariable("NoclipActive") == 0.0 then
            noclip_active_state = 1.0 -- Activate noclip.
        else
            noclip_active_state = 0.0 -- Deactivate noclip.
        end
        
        SetGlobalVariableValue("NoclipActive", noclip_active_state) -- Update the global variable.
        Wait(100) -- Small delay to prevent rapid toggling.
    end

    Wait(100) -- General pause for the main loop to reduce CPU usage.
end

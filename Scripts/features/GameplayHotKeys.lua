RegisterGlobalVariable("NoclipActive", 0.0)

local HealPlayerKey = nil
local ThermalVisionKey = nil
local NoclipKey = nil

local ThermalVisionState = false
local noclipActive = 0.0

local configUtils = require("config_utils")

function SetThermalVision(Toggle)
    Call("SetThermalVision", "nil", Toggle)
end

function InitializeSettings()
    HealPlayerKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "HealPlayerKey"))
    ThermalVisionKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "ThermalVisionKey"))
    NoclipKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "NoclipKey"))
end

InitializeSettings()

while ScriptStillWorking do
    if IsPressedKey(HealPlayerKey) and PLAYER.IS_PLAYER_CONTROL_ON(PLAYER.PLAYER_ID()) then
        ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), ENTITY.GET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID()), 0, 0)
        PED.SET_PED_ARMOUR(PLAYER.PLAYER_PED_ID(), 100)

        local veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), 0)
        if veh then
            ENTITY.SET_ENTITY_HEALTH(veh, 1000, 0, 0)
        end 
        
        Wait(100)
    end
    if IsPressedKey(ThermalVisionKey) and PLAYER.IS_PLAYER_CONTROL_ON(PLAYER.PLAYER_ID()) then
        ThermalVisionState = not ThermalVisionState
        SetThermalVision(ThermalVisionState)

        Wait(100)
    end
    if IsPressedKey(NoclipKey) then
        if GetGlobalVariable("NoclipActive") == 0.0 then
            noclipActive = 1.0
        else
            noclipActive = 0.0
        end
        
        SetGlobalVariableValue("NoclipActive", noclipActive)
        Wait(100)
    end

    Wait(100)
end
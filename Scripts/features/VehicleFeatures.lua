local VehicleBoostKey = nil
local VehicleExtraBrakeKey = nil
local VehicleAirBoostKey = nil
local VehicleAirExtraBrakeKey = nil
local VehicleIndicatorLightLeftKey = nil
local VehicleIndicatorLightRightKey = nil

local VehicleBoostValue = 0.0
local leftTurnSignal = false
local rightTurnSignal = false

local configUtils = require("config_utils")

function IsPlayerDrivingAnyVehicle()
    if IsGlobalVariableExist("RemoteControlVehicle") and GetGlobalVariable("RemoteControlVehicle") ~= 0.0 then
        return true
    else
        return PED.IS_PED_IN_VEHICLE(PLAYER.PLAYER_PED_ID(), PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false), true) --[[ PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), true) ]]
    end
end

function GetVehicle()
    if IsGlobalVariableExist("RemoteControlVehicle") and GetGlobalVariable("RemoteControlVehicle") ~= 0.0 then
        return GetGlobalVariable("RemoteControlVehicle")
    else
        return PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    end
end

function UpdateIndicatorLightsPlayerVehicle()
    VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(GetVehicle(), 1, leftTurnSignal)
    VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(GetVehicle(), 0, rightTurnSignal)
end

function UpdateFeatures()
    if IsGlobalVariableExist("AutoFixCurrentVehicleState") and GetGlobalVariable("AutoFixCurrentVehicleState") ~= 0.0 and IsPlayerDrivingAnyVehicle() then
        local veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
        VEHICLE.SET_VEHICLE_FIXED(veh, false)
    end
    if IsGlobalVariableExist("DisableLockOnCurrentVehicleState") and GetGlobalVariable("DisableLockOnCurrentVehicleState") ~= 0.0 and IsPlayerDrivingAnyVehicle() then
        local veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
        VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON(veh, false, false)
        VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(veh, false, false)
    end
end

function InitializeSettings()
    VehicleBoostKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "VehicleBoostKey"))
    VehicleExtraBrakeKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "VehicleExtraBrakeKey"))
    VehicleAirBoostKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "VehicleAirBoostKey"))
    VehicleAirExtraBrakeKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "VehicleAirExtraBrakeKey"))
    VehicleIndicatorLightLeftKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "VehicleIndicatorLightLeftKey"))
    VehicleIndicatorLightRightKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "VehicleIndicatorLightRightKey"))
end

InitializeSettings()

while ScriptStillWorking do
    if IsPressedKey(VehicleBoostKey) and IsPlayerDrivingAnyVehicle() then
        local veh = GetVehicle()
        --local model = ENTITY.GET_ENTITY_MODEL(veh)
        if not ENTITY.IS_ENTITY_IN_AIR(veh) then
            if VehicleBoostValue < 2.0 then
                VehicleBoostValue = 2.1
            else
                VehicleBoostValue = VehicleBoostValue + 0.34
            end 

            VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, ENTITY.GET_ENTITY_SPEED(veh) + VehicleBoostValue)
        end
    elseif VehicleBoostValue > 0.0 then
        VehicleBoostValue = VehicleBoostValue - 0.2
    end

    if IsPressedKey(VehicleExtraBrakeKey) and IsPlayerDrivingAnyVehicle() then
        local veh = GetVehicle()
        --local model = ENTITY.GET_ENTITY_MODEL(veh)
        if not ENTITY.IS_ENTITY_IN_AIR(veh) then
            local speed = ENTITY.GET_ENTITY_SPEED(veh) / 1.5
            if speed < 0.0 then
                speed = 0.0
            end 
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, speed)
            VehicleBoostValue = 0.0
        end
    end
    

    if IsPressedKey(VehicleAirExtraBrakeKey) and IsPlayerDrivingAnyVehicle() then
        VEHICLE.SET_VEHICLE_FORWARD_SPEED(GetVehicle(), 0.0)
    end
    if IsPressedKey(VehicleAirBoostKey) and IsPlayerDrivingAnyVehicle() then
        local veh = GetVehicle()
        local model = ENTITY.GET_ENTITY_MODEL(veh)

        if ENTITY.IS_ENTITY_IN_AIR(veh) and (VEHICLE.IS_THIS_MODEL_A_PLANE(model) or VEHICLE.IS_THIS_MODEL_A_HELI(model)) then
            if VehicleBoostValue < 3.0 then
                VehicleBoostValue = 3.2
            else
                VehicleBoostValue = VehicleBoostValue + 0.65
            end 
            
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, ENTITY.GET_ENTITY_SPEED(veh) + VehicleBoostValue)
        end
    end
    if IsPressedKey(VehicleIndicatorLightLeftKey) and IsPlayerDrivingAnyVehicle() then
        if leftTurnSignal then
            leftTurnSignal = false
        else
            leftTurnSignal = true
            rightTurnSignal = false
        end

        UpdateIndicatorLightsPlayerVehicle()
    elseif IsPressedKey(VehicleIndicatorLightRightKey) and IsPlayerDrivingAnyVehicle() then -- Right arrow
        if rightTurnSignal then
            rightTurnSignal = false
        else
            rightTurnSignal = true
            leftTurnSignal = false
        end

        UpdateIndicatorLightsPlayerVehicle()
    end

    UpdateFeatures()

    Wait(100)
end

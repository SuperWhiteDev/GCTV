local bone_enum = require("bone_enums")
local networkUtils = require("network_utils")
local missionUtils = require("mission_utils")
local configUtils = require("config_utils")

local RCMoveForwardMainKey = nil
local RCMoveBackwardMainKey = nil
local RCMoveLeftMainKey = nil
local RCMoveRightMainKey = nil
local RCMoveForwardSecondaryKey = nil
local RCMoveBackwardSecondaryKey = nil
local RCMoveLeftSecondaryKey = nil
local RCMoveRightSecondaryKey = nil
local RCChangeViewKey = nil
local RCExitKey = nil

local rcActive = false
local rcInitialized = false
local rcVehicle = 0.0
local rcCamera = nil
local bone = 0

local currentView = 0

local backwardMovement = 0.0
local steering = 0.0
local turnSpeed = 2.0 -- Скорость поворота

local moveForwardKey = 0x57
local moveBackwardKey = 0x53
local moveLeftKey = 0x41
local moveRightKey = 0x44

local engineSound = nil -- Переменная для звука двигателя
local isEngineSoundPlaying = false -- Флаг для отслеживания состояния звука двигателя

local waitTime = 100

function EnableRemoteControl()
    rcVehicle = GetGlobalVariable("RemoteControlVehicle")

    rcCamera = missionUtils.CreateCamera(0.0, 0.0, 0.0, ENTITY.GET_ENTITY_HEADING(rcVehicle), 0.0, 0.0, 1000)
    --CAM.ATTACH_CAM_TO_VEHICLE_BONE(rcCamera, rcVehicle, 1901, false, ENTITY.GET_ENTITY_HEADING(rcVehicle), 0.0, 0.0, 0.0, 0.0, 0.0, true)
    --CAM.ATTACH_CAM_TO_VEHICLE_BONE(rcCamera, rcVehicle, 160, false, ENTITY.GET_ENTITY_HEADING(rcVehicle), 0.0, 0.0, 0.0, 0.0, 0.0, true)
    CAM.ATTACH_CAM_TO_ENTITY(rcCamera, rcVehicle, 0.0, -5.0, 1.5, true)

    STREAMING.SET_FOCUS_ENTITY(rcVehicle)
    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(PLAYER.PLAYER_PED_ID(), true, 0)
    PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), false, 0)

    networkUtils.RequestControlOf(rcVehicle)
    VEHICLE.SET_VEHICLE_ENGINE_ON(rcVehicle, true, true, false)

    rcInitialized = true
end

function DisableRemoteControl()
    if rcCamera then
        missionUtils.DeleteCamera(rcCamera)
        rcCamera = nil
    end

    STREAMING.SET_FOCUS_ENTITY(PLAYER.PLAYER_PED_ID())
    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(PLAYER.PLAYER_PED_ID(), false, 0)
    PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), true, 0)

    VEHICLE.SET_VEHICLE_ENGINE_ON(rcVehicle, false, false, false)

    if engineSound then
        SOUND.STOP_SOUND(engineSound)  -- Остановить звук двигателя, если он воспроизводится
        engineSound = nil
    end

    rcVehicle = nil
    rcCamera = nil
    currentView = 0
    rcInitialized = false

    print(GetGlobalVariable("RemoteControlVehicle")) -- почемуто без этой строчки в переменную RemoteControlVehicle не присваивается 0.0 а там остаётся прежнее значение

    SetGlobalVariableValue("RemoteControlVehicle", 0.0) 
end

function CkeckRCState()
    if IsPressedKey(RCExitKey) and rcActive then -- ESC key
        DisableRemoteControl()
        return false
    elseif not ENTITY.DOES_ENTITY_EXIST(rcVehicle) or ENTITY.IS_ENTITY_DEAD(rcVehicle) then
        DisableRemoteControl()
        return false
    end

    return true
end

function PlayEngineSound()
    if not engineSound then
        engineSound = AUDIO.GET_SOUND_ID()
        AUDIO.PLAY_SOUND_FROM_ENTITY(engineSound, "Engine_Revs", rcVehicle, "DLC_HEISTS_GENERIC_SOUNDS", true, 0)

        isEngineSoundPlaying = true
    end
end

function StopEngineSound()
    if engineSound then
        AUDIO.STOP_SOUND(engineSound)
        engineSound = nil
        isEngineSoundPlaying = false
    end
end

function DriveForward()
    if not ENTITY.IS_ENTITY_IN_AIR(rcVehicle) then
        VEHICLE.SET_VEHICLE_FORWARD_SPEED(rcVehicle, ENTITY.GET_ENTITY_SPEED(rcVehicle) + VEHICLE.GET_VEHICLE_ACCELERATION(rcVehicle)*3.25) --VEHICLE.GET_VEHICLE_ACCELERATION(rcVehicle)
    end

    PlayEngineSound()
end

function DriveBackward()
    if not ENTITY.IS_ENTITY_IN_AIR(rcVehicle) then
        backwardMovement = backwardMovement + 0.2
        VEHICLE.SET_VEHICLE_FORWARD_SPEED(rcVehicle, ENTITY.GET_ENTITY_SPEED(rcVehicle) - backwardMovement)
    end

    PlayEngineSound()
end


function TurnLeft()
    if not ENTITY.IS_ENTITY_IN_AIR(rcVehicle) then
        local heading = ENTITY.GET_ENTITY_HEADING(rcVehicle) -- Получаем текущий угол
        heading = heading + turnSpeed -- Уменьшаем угол для поворота влево
        ENTITY.SET_ENTITY_HEADING(rcVehicle, heading) -- Устанавливаем новый угол
        CAM.SET_CAM_ROT(rcCamera, 0.0, 0.0, ENTITY.GET_ENTITY_HEADING(rcVehicle), 2)
    end
end

function TurnRight()
    if not ENTITY.IS_ENTITY_IN_AIR(rcVehicle) then
        local heading = ENTITY.GET_ENTITY_HEADING(rcVehicle) -- Получаем текущий угол
        heading = heading - turnSpeed -- Уменьшаем угол для поворота влево
        ENTITY.SET_ENTITY_HEADING(rcVehicle, heading) -- Устанавливаем новый угол
        CAM.SET_CAM_ROT(rcCamera, 0.0, 0.0, ENTITY.GET_ENTITY_HEADING(rcVehicle), 2)
    end
end

function ChangeView()
    currentView = currentView + 1

    if currentView == 1 then
        --CAM.ATTACH_CAM_TO_VEHICLE_BONE(rcCamera, rcVehicle, bone_enum.VehicleBone.frame_3, false, ENTITY.GET_ENTITY_HEADING(rcVehicle), 0.0, 0.0, 0.0, 0.0, 0.0, true)
        CAM.ATTACH_CAM_TO_VEHICLE_BONE(rcCamera, rcVehicle, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(rcVehicle, "bonnet"), false, ENTITY.GET_ENTITY_HEADING(rcVehicle), 0.0, 0.0, 0.0, 0.0, 0.3, true)
        CAM.RENDER_SCRIPT_CAMS(true, true, 1000, true, true)
    elseif currentView == 2 then
        --CAM.ATTACH_CAM_TO_VEHICLE_BONE(rcCamera, rcVehicle, 1921, false, ENTITY.GET_ENTITY_HEADING(rcVehicle), 0.0, 0.0, 0.0, 0.0, 0.0, true)
        CAM.ATTACH_CAM_TO_VEHICLE_BONE(rcCamera, rcVehicle, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(rcVehicle, "seat_dside_f"), false, ENTITY.GET_ENTITY_HEADING(rcVehicle), 0.0, 0.0, 0.0, 0.0, 0.6, true)
        CAM.RENDER_SCRIPT_CAMS(true, true, 1000, true, true)
    elseif currentView == 3 then
        CAM.RENDER_SCRIPT_CAMS(false, false, 0, true, true)
        moveForwardKey = RCMoveForwardSecondaryKey
        moveBackwardKey = RCMoveBackwardSecondaryKey
        moveLeftKey = RCMoveLeftSecondaryKey
        moveRightKey = RCMoveRightSecondaryKey

        STREAMING.SET_FOCUS_ENTITY(PLAYER.PLAYER_PED_ID())
        PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), true, 0)

    else
        --CAM.ATTACH_CAM_TO_VEHICLE_BONE(rcCamera, rcVehicle, 1901, false, ENTITY.GET_ENTITY_HEADING(rcVehicle), 0.0, 0.0, 0.0, 0.0, 0.0, true)
        --CAM.ATTACH_CAM_TO_VEHICLE_BONE(rcCamera, rcVehicle, 160, false, ENTITY.GET_ENTITY_HEADING(rcVehicle), 0.0, 0.0, 0.0, 0.0, 0.0, true)
        CAM.ATTACH_CAM_TO_ENTITY(rcCamera, rcVehicle, 0.0, -5.0, 1.5, true)
        CAM.RENDER_SCRIPT_CAMS(true, true, 1000, true, true)

        moveForwardKey = RCMoveForwardMainKey
        moveBackwardKey = RCMoveBackwardMainKey
        moveLeftKey = RCMoveLeftMainKey
        moveRightKey = RCMoveRightMainKey

        STREAMING.SET_FOCUS_ENTITY(rcVehicle)
        PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), false, 0)

        currentView = 0
    end

    ResetLineAndPrint(currentView)
end

function OnTick()
    if CkeckRCState() then
        if IsPressedKey(moveForwardKey) then -- W
            DriveForward()
        end
        if IsPressedKey(moveBackwardKey) then -- S
            DriveBackward()
        else
            if backwardMovement > 0.0 then
                backwardMovement = backwardMovement - 0.2
            end
        end
        
        -- Управление поворотом
        if IsPressedKey(moveLeftKey) then -- A
            TurnLeft()
        end
        
        if IsPressedKey(moveRightKey) then -- D
            TurnRight()
        end

        if IsPressedKey(RCChangeViewKey) then
            ChangeView()
            Wait(100)
        end

        --[[

        --DEBUG

        if IsPressedKey(0x25) then -- left arrow
            bone = bone + 1
            CAM.ATTACH_CAM_TO_VEHICLE_BONE(rcCamera, rcVehicle, bone, false, ENTITY.GET_ENTITY_HEADING(rcVehicle), 0.0, 0.0, 0.0, 0.0, 0.0, true)

            ResetLineAndPrint(bone)

            Wait(100)
        end
        if IsPressedKey(0x27) then -- left arrow
            bone = bone - 1
            CAM.ATTACH_CAM_TO_VEHICLE_BONE(rcCamera, rcVehicle, bone, false, ENTITY.GET_ENTITY_HEADING(rcVehicle), 0.0, 0.0, 0.0, 0.0, 0.0, true)

            ResetLineAndPrint(bone)
            Wait(100)
        end

        ]]

        if rcCamera then
            -- Вращение камеры по направлению транспорта
            CAM.SET_CAM_ROT(rcCamera, 0.0, 0.0, ENTITY.GET_ENTITY_HEADING(rcVehicle), 2) -- Устанавливаем новое направление камеры
        end

        if ENTITY.GET_ENTITY_SPEED(rcVehicle) == 0.0 then
            StopEngineSound() -- Остановить звук двигателя, если скорость 0
        else
            VEHICLE.SET_VEHICLE_ENGINE_ON(rcVehicle, true, true, false)
        end
    end
end

function InitializeSettings()
    RCMoveForwardMainKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "RCMoveForwardMainKey"))
    RCMoveBackwardMainKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "RCMoveBackwardMainKey"))
    RCMoveLeftMainKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "RCMoveLeftMainKey"))
    RCMoveRightMainKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "RCMoveRightMainKey"))
    RCMoveForwardSecondaryKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "RCMoveForwardSecondaryKey"))
    RCMoveBackwardSecondaryKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "RCMoveBackwardSecondaryKey"))
    RCMoveLeftSecondaryKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "RCMoveLeftSecondaryKey"))
    RCMoveRightSecondaryKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "RCMoveRightSecondaryKey"))
    RCChangeViewKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "RCChangeViewKey"))
    RCExitKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "RCExitKey"))
end

InitializeSettings()

while ScriptStillWorking do
    if IsGlobalVariableExist("RemoteControlVehicle") then
        rcActive = GetGlobalVariable("RemoteControlVehicle") ~= 0.0

        if rcActive and not rcInitialized then 
            EnableRemoteControl()
            waitTime = 0
        elseif not rcActive and rcInitialized then
            DisableRemoteControl()
            waitTime = 100
        end

        if rcActive then
            OnTick()
        end
    else
        waitTime = 100
    end
    Wait(waitTime)
end
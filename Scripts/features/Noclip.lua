local mathUtils = require("math_utils")
local worldUtils = require("world_utils")
local configUtils = require("config_utils")

local NoclipMoveForwardKey = nil
local NoclipMoveBackwardKey = nil
local NoclipMoveLeftKey = nil
local NoclipMoveRightKey = nil
local NoclipMoveUpKey = nil
local NoclipMoveDownKey = nil
local NoclipSprintKey = nil
local NoclipEnterExitVehicleKey = nil

local waitTime = 100
local previousPosition = {x = 0.0, y = 0.0, z = 0.0}
local playerAlpha = 0
local playerProofs = nil
local noclipActive = false
local noclipinitialized = false
local IsNoclipVehicle = false
local speed = nil
local speedmult = 1.0

--[[function GetEntityRightVector(playerPed)
    local forward = ENTITY.GET_ENTITY_FORWARD_VECTOR(playerPed)
    return {
        x = -forward.y,
        y = forward.x,
        z = 0 }
end 
]]

function EnableNoclip()
    local playerPed = PLAYER.PLAYER_PED_ID()
    playerAlpha = ENTITY.GET_ENTITY_ALPHA(playerPed)

    ENTITY.SET_ENTITY_VISIBLE(playerPed, false, false)
    ENTITY.SET_ENTITY_ALPHA(playerPed, 0, false)

    local bulletProof = New(4)
    local fireProof = New(4)
    local explosionProof = New(4)
    local collisionProof = New(4)
    local meleeProof = New(4)
    local steamProof = New(4)
    local p7 = New(4)
    local drownProof = New(4)
    
    ENTITY.GET_ENTITY_PROOFS(playerPed, bulletProof, fireProof, explosionProof, collisionProof, meleeProof, steamProof, p7, drownProof)

    playerProofs = {    Game.ReadBool(bulletProof),
                        Game.ReadBool(fireProof),
                        Game.ReadBool(explosionProof),
                        Game.ReadBool(collisionProof),
                        Game.ReadBool(meleeProof),
                        Game.ReadBool(steamProof),
                        Game.ReadBool(p7),
                        Game.ReadBool(drownProof)
    }

    Delete(bulletProof)
    Delete(fireProof)
    Delete(explosionProof)
    Delete(collisionProof)
    Delete(meleeProof)
    Delete(steamProof)
    Delete(p7)
    Delete(drownProof)

    ENTITY.SET_ENTITY_PROOFS(playerPed, true, playerProofs[2], true, true, playerProofs[5], playerProofs[6], playerProofs[7], playerProofs[8])

    if IsGlobalVariableExist("NoclipSpeed") then
        speed = GetGlobalVariable("NoclipSpeed")
    else
        speed = 1.0
    end

    --ShowNotification("Game Command Terminal", "Noclip activated", "CHAR_SOCIAL_CLUB", 7)

    noclipinitialized = true
end

function EnableVehicleNoclip()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)

    ENTITY.SET_ENTITY_COLLISION(vehicle, false, false)

    if IsGlobalVariableExist("NoclipSpeed") then
        speed = GetGlobalVariable("NoclipSpeed")
        if speed == 1.0 then
            speed = 2.0
        end
    else
        speed = 2.0
    end

    --ShowNotification("Game Command Terminal", "Noclip activated", "CHAR_SOCIAL_CLUB", 7)
    IsNoclipVehicle = true
    noclipinitialized = true
end

function DisableNoclip()
    local playerPed = PLAYER.PLAYER_PED_ID()

    ENTITY.SET_ENTITY_VISIBLE(playerPed, true, false)
    ENTITY.SET_ENTITY_ALPHA(playerPed, playerAlpha, false)

    ENTITY.SET_ENTITY_PROOFS(playerPed, playerProofs[1], playerProofs[2], playerProofs[3], playerProofs[4], playerProofs[5], playerProofs[6], playerProofs[7], playerProofs[8])

    playerProofs = nil

    --ShowNotification("Game Command Terminal", "Noclip deactivated", "CHAR_SOCIAL_CLUB", 7)

    noclipinitialized = false
end

function DisableVehicleNoclip()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)

    ENTITY.SET_ENTITY_COLLISION(vehicle, true, true)
    
    IsNoclipVehicle = false
    noclipinitialized = false

    SetGlobalVariableValue("NoclipActive", 0.0)
end

function OnTick()
    local playerPed = PLAYER.PLAYER_PED_ID()

    if noclipActive then
        if IsNoclipVehicle then
            local vehicle = nil
            if PED.IS_PED_IN_ANY_VEHICLE(playerPed, false) then
                vehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, true)
            else
                DisableVehicleNoclip()
            end

            local camRot = CAM.GET_GAMEPLAY_CAM_ROT(2) -- Получение текущего угла камеры
            local coord = ENTITY.GET_ENTITY_COORDS(playerPed, true) -- Получение текущих координат игрока
        
            -- Запоминаем углы вращения в радианах
            local heading = math.rad(camRot.z)
            local pitch = math.rad(camRot.x) -- Угол наклона

            local forward = {
                x = -math.sin(heading),
                y = math.cos(heading),
                z = math.sin(pitch) -- Изменение по Z в зависимости от угла наклона
            }

            -- Нормализуем вектор направления
            local forwardMagnitude = math.sqrt(forward.x^2 + forward.y^2 + forward.z^2)
            forward.x = forward.x / forwardMagnitude
            forward.y = forward.y / forwardMagnitude
            forward.z = forward.z / forwardMagnitude
            
            -- Устанавливаем направление перемещения
            local moveVector = { x = 0.0, y = 0.0, z = 0.0 }

            if IsPressedKey(NoclipSprintKey) then -- Shift
                speedmult = 3.0
            end
            if IsPressedKey(NoclipMoveForwardKey) then
                moveVector = mathUtils.SumVectors(moveVector, mathUtils.MultVector(forward, speed*speedmult))
            end
            if IsPressedKey(NoclipMoveLeftKey) then
                local left = { x = -forward.y, y = forward.x, z = 0.0 } -- вектор влево
                moveVector = mathUtils.SumVectors(moveVector, mathUtils.MultVector(left, speed*speedmult))
            end
            if IsPressedKey(NoclipMoveBackwardKey) then
                moveVector = mathUtils.SumVectors(moveVector, mathUtils.MultVector(forward, (speed * 1.5) * speedmult))
                moveVector = mathUtils.SubtractVectors(moveVector, mathUtils.MultVector(moveVector, (speed * 1.5) * speedmult))
            end
            if IsPressedKey(NoclipMoveRightKey) then
                local right = { x = forward.y, y = -forward.x, z = 0.0 } -- вектор вправо
                moveVector = mathUtils.SumVectors(moveVector, mathUtils.MultVector(right, speed*speedmult))
            end
            if IsPressedKey(NoclipMoveUpKey) then
                moveVector.z = moveVector.z + (speed*speedmult / 2.0)
            end
            if IsPressedKey(NoclipMoveDownKey) then
                moveVector.z = moveVector.z - (speed*speedmult / 2.0)
            end

            if IsPressedKey(NoclipEnterExitVehicleKey) then -- F
                DisableVehicleNoclip()

                TASK.CLEAR_PED_TASKS(PLAYER.PLAYER_PED_ID())
                SetGlobalVariableValue("NoclipActive", 1.0)

                EnableNoclip()
            end
            
            -- Обновление координат игрока
            coord = mathUtils.SumVectors(coord, moveVector)

            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(vehicle, coord.x, coord.y, coord.z, true, true, true)
            ENTITY.SET_ENTITY_ROTATION(vehicle, camRot.x, camRot.y, camRot.z, 2, true)
        else
            local camRot = CAM.GET_GAMEPLAY_CAM_ROT(2) -- Получение текущего угла камеры
            local coord = ENTITY.GET_ENTITY_COORDS(playerPed, true) -- Получение текущих координат игрока
        
            -- Запоминаем углы вращения в радианах
            local heading = math.rad(camRot.z)
            local pitch = math.rad(camRot.x) -- Угол наклона

            local forward = {
                x = -math.sin(heading),
                y = math.cos(heading),
                z = math.sin(pitch) -- Изменение по Z в зависимости от угла наклона
            }

            -- Нормализуем вектор направления
            local forwardMagnitude = math.sqrt(forward.x^2 + forward.y^2 + forward.z^2)
            forward.x = forward.x / forwardMagnitude
            forward.y = forward.y / forwardMagnitude
            forward.z = forward.z / forwardMagnitude
            
            -- Устанавливаем направление перемещения
            local moveVector = { x = 0.0, y = 0.0, z = 0.0 }

            if IsPressedKey(NoclipSprintKey) then -- Shift
                speedmult = 3.0
            end
            if IsPressedKey(NoclipMoveForwardKey) then
                moveVector = mathUtils.SumVectors(moveVector, mathUtils.MultVector(forward, speed*speedmult))
            end
            if IsPressedKey(NoclipMoveLeftKey) then
                local left = { x = -forward.y, y = forward.x, z = 0.0 } -- вектор влево
                moveVector = mathUtils.SumVectors(moveVector, mathUtils.MultVector(left, speed*speedmult))
            end
            if IsPressedKey(NoclipMoveBackwardKey) then
                moveVector = mathUtils.SumVectors(moveVector, mathUtils.MultVector(forward, (speed * 1.5) * speedmult))
                moveVector = mathUtils.SubtractVectors(moveVector, mathUtils.MultVector(moveVector, (speed * 1.5) * speedmult))
            end
            if IsPressedKey(NoclipMoveRightKey) then
                local right = { x = forward.y, y = -forward.x, z = 0.0 } -- вектор вправо
                moveVector = mathUtils.SumVectors(moveVector, mathUtils.MultVector(right, speed*speedmult))
            end
            if IsPressedKey(NoclipMoveUpKey) then
                moveVector.z = moveVector.z + (speed*speedmult / 2.0)
            end
            if IsPressedKey(NoclipMoveDownKey) then
                moveVector.z = moveVector.z - (speed*speedmult / 2.0)
            end
            if IsPressedKey(NoclipEnterExitVehicleKey) then
                local veh = worldUtils.GetNearestVehicleToEntity(PLAYER.PLAYER_PED_ID(), 5.0)
                if veh ~= 0.0 then
                    DisableNoclip()
                    SetGlobalVariableValue("NoclipActive", 0.0)

                    if VEHICLE.IS_VEHICLE_SEAT_FREE(veh, -1, true) then 
                        PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
                    else
                        PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -2)
                    end

                    return nil
                end
            end
            
            -- Обновление координат игрока
            coord = mathUtils.SumVectors(coord, moveVector)

            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(playerPed, coord.x, coord.y, coord.z, true, true, true)
            ENTITY.SET_ENTITY_VISIBLE(playerPed, false, false)
        end
    end

    speedmult = 1.0
end

function InitializeSettings()
    NoclipMoveForwardKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "NoclipMoveForwardKey"))
    NoclipMoveBackwardKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "NoclipMoveBackwardKey"))
    NoclipMoveLeftKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "NoclipMoveLeftKey"))
    NoclipMoveRightKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "NoclipMoveRightKey"))
    NoclipMoveUpKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "NoclipMoveUpKey"))
    NoclipMoveDownKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "NoclipMoveDownKey"))
    NoclipSprintKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "NoclipSprintKey"))
    NoclipEnterExitVehicleKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "NoclipEnterExitVehicleKey"))
end

InitializeSettings()

while ScriptStillWorking do
    if IsGlobalVariableExist("NoclipActive") then
        noclipActive = GetGlobalVariable("NoclipActive")
        if noclipActive == 1.0 and not noclipinitialized then
            if PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), false) then
                EnableVehicleNoclip()
            else
                EnableNoclip()
            end

            waitTime = 0
        elseif noclipActive == 0.0 and noclipinitialized then
            if IsNoclipVehicle then
                DisableVehicleNoclip()
            else
                DisableNoclip()
            end
            
            waitTime = 100
        end

        if noclipActive == 1.0 then
            OnTick()
        end
    else
        waitTime = 100
    end
    Wait(waitTime)
end
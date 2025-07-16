local missionUtils = require("mission_utils")
local networkUtils = require("network_utils")
local configUtils = require("config_utils")

local ARDMoveForwardKey = nil
local ARDMoveBackwardKey = nil
local ARDMoveLeftKey = nil
local ARDMoveRightKey = nil
local ARDExit = nil

local camera = nil
local drone = nil
local droneSound = nil
local droneUpdated = false
local pilot = nil
local cameraPosition = { x = 0, y = 0, z = 150 } -- Initial camera position above the player
local cameraRotation = { x = 0, y = 0 } -- Camera rotation angles
local moveSpeed = 2.0 -- Movement speed
local maxHeight = 1000.0 -- Максимальная высота
local heightAdjustment = 3.0 -- Change in height when scrolling the mouse wheel
local AerialReconnaissanceDroneActive = false

local missilesCount = 8

function FireDroneMissiles()
    local radius = 35.0

    -- Опрееляем точку ниже текущего положения камеры
    local cameraCoords = CAM.GET_CAM_COORD(camera)
    local startX = cameraCoords.x
    local startY = cameraCoords.y
    local startZ = cameraCoords.z-1.0

    for i = 1, missilesCount, 1 do
        local endX = startX
        local endY = startY
        local endZ = startZ - 500.0 -- выпустить снаряд вниз на 500 единиц (можно изменить)

        local offsetX = math.random(-radius, radius)
        local offsetY = math.random(-radius, radius)

        -- Чтобы не выйти за пределы радиуса
        if math.sqrt(offsetX^2 + offsetY^2) > radius then
            local scale = radius / math.sqrt(offsetX^2 + offsetY^2)
            offsetX = offsetX * scale
            offsetY = offsetY * scale
        end

        -- Корректируем конечные координаты с учетом отклонений
        endX = endX + offsetX
        endY = endY + offsetY

        -- Вызываем функцию для стрельбы снарядами
        --[[
            WEAPON_RPG
            WEAPON_STINGER
            VEHICLE_WEAPON_RUINER_ROCKET
            VEHICLE_WEAPON_PLANE_ROCKET
            VEHICLE_WEAPON_SPACE_ROCKET
            WEAPON_ARENA_HOMING_MISSILE
            WEAPON_AIR_DEFENCE_GUN
            VEHICLE_WEAPON_TANK
        ]]
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(startX, startY, startZ, endX, endY, endZ, 1000, true, MISC.GET_HASH_KEY("VEHICLE_WEAPON_RUINER_ROCKET"), PLAYER.PLAYER_PED_ID(), true, false, 2700.0)
    end
    Wait(50)
end

function InitDrone(x, y, z, zOffset)
    local droneModel = MISC.GET_HASH_KEY("xs_prop_arena_drone_02")
    local iters = 0
    drone = 0.0
    droneUpdated = false
    
    while drone == 0.0 and iters < 25 do
        drone = OBJECT.CREATE_OBJECT_NO_OFFSET(droneModel, x, y, z+zOffset, false, false, true, 0)
        iters = iters + 1

        Wait(10)
    end
    if drone ~= 0.0 then
        networkUtils.RegisterAsNetwork(drone)

        ENTITY.SET_ENTITY_INVINCIBLE(drone, true)
	    ENTITY.SET_ENTITY_COLLISION(drone, true, false)
        ENTITY.SET_ENTITY_VISIBLE(drone, true)
        STREAMING.SET_FOCUS_ENTITY(drone)

        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(droneModel)

        droneSound = AUDIO.GET_SOUND_ID()
        --AUDIO.PLAY_SOUND_FRONTEND(droneSound, "Flight_Loop", "DLC_H3_Prep_Drones_Sounds", true) -- 
        AUDIO.PLAY_SOUND_FROM_ENTITY(droneSound, "Flight_Loop", drone, "DLC_H3_Prep_Drones_Sounds", true, 0)
    end
end
function DeleteDrone()
    if drone then
        ENTITY.SET_ENTITY_INVINCIBLE(drone, false)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(drone, cameraPosition.x, cameraPosition.y+1.0, cameraPosition.z, false, false, false)

        local dronep = NewObject(drone)

        RequestControlOf(drone)
        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(dronep)
        DeleteObject(dronep)
        Delete(dronep)
    
        STREAMING.SET_FOCUS_ENTITY(PLAYER.PLAYER_PED_ID())
    end

    if droneSound ~= -1 then
        AUDIO.STOP_SOUND(droneSound)
    end
    
    droneSound = nil
end

function UpdateDrone(camera, zOffset)
    if not droneUpdated then
        local cameraCoords = CAM.GET_CAM_COORD(camera)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(drone, cameraCoords.x, cameraCoords.y, cameraCoords.z+zOffset, false, false, false)
    end
    droneUpdated = true
end
function UpdateDronePos(x, y, z, zOffset)
    if not droneUpdated then
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(drone, x, y, z+zOffset, false, false, false)
    end
    droneUpdated = true
end

function EnableAerialReconnaissanceDrone()
    if not AerialReconnaissanceDroneActive then
        AUDIO.PLAY_SOUND_FRONTEND(droneSound, "Pilot_Perspective_Fire", "DLC_H3_Drone_Tranq_Weapon_Sounds", false)

        pilot = PLAYER.PLAYER_PED_ID()
        local playerCoords = ENTITY.GET_ENTITY_COORDS(pilot, true)

        cameraPosition.x = playerCoords.x
        cameraPosition.y = playerCoords.y
        cameraPosition.z = playerCoords.z + cameraPosition.z

        CAM.DO_SCREEN_FADE_OUT(450)
        Wait(500)

        camera = missionUtils.CreateFlyCamera(cameraPosition.x, cameraPosition.y, cameraPosition.z, 0.0, 0.0, -90.0, maxHeight, 1000)

        InitDrone(cameraPosition.x, cameraPosition.y, cameraPosition.z, 0.00)

        PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), false, 0)

        Wait(200)
        CAM.DO_SCREEN_FADE_IN(1000)

        PAD.DISABLE_CONTROL_ACTION(1, 27, true)
        PAD.DISABLE_CONTROL_ACTION(2, 199, true) -- must disable action on pressing esc button, but actually dont work
        PAD.DISABLE_CONTROL_ACTION(2, 200, true) -- must disable action on pressing esc button, but actually dont work
        PAD.DISABLE_CONTROL_ACTION(2, 202, true) -- must disable action on pressing esc button, but actually dont work

        AerialReconnaissanceDroneActive = true
        SetGlobalVariableValue("AerialReconnaissanceDroneState", 1.0)

        if IsGlobalVariableExist("AerialReconnaissanceDroneMissilesCount") then
            missilesCount = GetGlobalVariable("AerialReconnaissanceDroneMissilesCount")
            if not missilesCount then
                missilesCount = 8
            end
        end
    end
end

function DisableAerialReconnaissanceDrone()
    if AerialReconnaissanceDroneActive then
        pilot = nil

        CAM.DO_SCREEN_FADE_OUT(450)
        Wait(500)
        CAM.RENDER_SCRIPT_CAMS(false, false, 0, false, false, false) -- Остановить рендеринг камеры
        CAM.SET_CAM_ACTIVE(camera, false) -- Деактивировать камеру дрона
        camera = nil

        -- Переключение обратно на камеру игрока
        CAM.RENDER_SCRIPT_CAMS(false, false, 0, false, false, false) 
        --local playerPed = PLAYER.PLAYER_PED_ID()
        --CAM.SET_CAM_ACTIVE(CAM.GET_RENDERING_CAM(), false) -- Команда сброса до игровой камеры
        --CAM.RENDER_SCRIPT_CAMS(true, false, 0, false, false, false) -- Включить обычную камеру игрока

        DeleteDrone()

        PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), true, 0) -- Включить контроль над игроком

        Wait(200)
        CAM.DO_SCREEN_FADE_IN(1000)

        Wait(1000)
        PAD.ENABLE_CONTROL_ACTION(2, 199, true) -- dont work 
        PAD.ENABLE_CONTROL_ACTION(2, 200, true) -- dont work
        PAD.ENABLE_CONTROL_ACTION(2, 202, true) -- dont work 

        AerialReconnaissanceDroneActive = false
        SetGlobalVariableValue("AerialReconnaissanceDroneState", 0.0)
    end
end

function IsPlayerBelowGround()
    local playerCoords = ENTITY.GET_ENTITY_COORDS(pilot, true) -- Получаем текущие координаты игрока
    local groundZ = nil

    local groundZp = New(4)

    -- Получаем высоту земли по координатам игрока
    MISC.GET_GROUND_Z_FOR_3D_COORD(playerCoords.x, playerCoords.y, playerCoords.z, groundZp, false, true)
    groundZ = Game.ReadFloat(groundZp)

    Delete(groundZp)

    -- Проверяем, ниже ли игрок уровень земли
    return playerCoords.z < groundZ
end

function CkeckARDState()
    if IsPressedKey(ARDExit) and AerialReconnaissanceDroneActive then
        DisableAerialReconnaissanceDrone() -- Turn off the camera if it's active
        return false
    elseif not ENTITY.DOES_ENTITY_EXIST(pilot) or ENTITY.IS_ENTITY_DEAD(pilot) then
        DisableAerialReconnaissanceDrone() -- Turn off the camera if it's active
        return false
    end

    return true
end

function OnTick()
    if CkeckARDState() then

        -- Mouse wheel for adjusting camera height
        if Mouse.IsMouseWheelScrolledUp() then
            cameraPosition.z = cameraPosition.z + heightAdjustment
            UpdateDronePos(cameraPosition.x, cameraPosition.y, cameraPosition.z, 0.00)
        elseif Mouse.IsMouseWheelScrolledDown() then
            cameraPosition.z = cameraPosition.z - heightAdjustment

            --[[
            if IsPlayerBelowGround() then
                cameraPosition.z = cameraPosition.z + heightAdjustment
            end
            ]]
        end
        local forward = { 
            x = -math.sin(math.rad(cameraRotation.y)),
            y = math.cos(math.rad(cameraRotation.y))
        }
        local right = { 
            x = forward.y, 
            y = -forward.x 
        }

        if IsPressedKey(ARDMoveForwardKey) then
            cameraPosition.x = cameraPosition.x + forward.x * moveSpeed
            cameraPosition.y = cameraPosition.y + forward.y * moveSpeed
        end
        if IsPressedKey(ARDMoveBackwardKey) then
            cameraPosition.x = cameraPosition.x - forward.x * moveSpeed
            cameraPosition.y = cameraPosition.y - forward.y * moveSpeed
        end
        if IsPressedKey(ARDMoveLeftKey) then
            cameraPosition.x = cameraPosition.x - right.x * moveSpeed
            cameraPosition.y = cameraPosition.y - right.y * moveSpeed
        end
        if IsPressedKey(ARDMoveRightKey) then
            cameraPosition.x = cameraPosition.x + right.x * moveSpeed
            cameraPosition.y = cameraPosition.y + right.y * moveSpeed
        end

        -- Set the camera position
        CAM.SET_CAM_COORD(camera, cameraPosition.x, cameraPosition.y, cameraPosition.z)
        UpdateDrone(camera, 0.00)

        if Mouse.IsLeftButtonPressed() then
            FireDroneMissiles()
        end

        droneUpdated = false
    end
end

function InitializeSettings()
    ARDMoveForwardKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "ARDMoveForwardKey"))
    ARDMoveBackwardKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "ARDMoveBackwardKey"))
    ARDMoveLeftKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "ARDMoveLeftKey"))
    ARDMoveRightKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "ARDMoveRightKey"))
    ARDExit = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "ARDExit"))
end

InitializeSettings()

EnableAerialReconnaissanceDrone()

while ScriptStillWorking and AerialReconnaissanceDroneActive and GetGlobalVariable("AerialReconnaissanceDroneState") == 1.0 do
    OnTick()
    Wait(1)
end
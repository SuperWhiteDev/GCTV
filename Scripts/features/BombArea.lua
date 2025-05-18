local bcActive = true
local bcInitialized = false
local targetCoords = { }

local avangerModelHash = nil
local pilotModelHash = nil
local avanger = nil
local pilot = nil

local bombs = { }
local bombscount = 40

local iters = 0

local networkUtils = require("network_utils")
local entityUtils = require("entity_utils")

function InitBC()
    iters = 0

    --Creating avanger
    avangerModelHash = MISC.GET_HASH_KEY("avenger3")
    if STREAMING.IS_MODEL_VALID(avangerModelHash) then
        STREAMING.REQUEST_MODEL(avangerModelHash)
        while not STREAMING.HAS_MODEL_LOADED(avangerModelHash) do
            if iters > 50 then
                DisplayError(false, "Failed to load the model")
                return nil
            end

            Wait(5)
            iters = iters + 1
        end
    end

    avanger = VEHICLE.CREATE_VEHICLE(avangerModelHash, targetCoords.x + 3.5, targetCoords.y + 130.0, targetCoords.z + 80.0, 180.0, false, false, false)
    networkUtils.RegisterAsNetwork(avanger)

    VEHICLE.OPEN_BOMB_BAY_DOORS(avanger)
    VEHICLE.CONTROL_LANDING_GEAR(avanger, 3)

    --Creating pilot
    pilotModelHash = MISC.GET_HASH_KEY("S_M_Y_Pilot_01")

    iters = 0
    if STREAMING.IS_MODEL_VALID(pilotModelHash) then
        STREAMING.REQUEST_MODEL(pilotModelHash)
        while not STREAMING.HAS_MODEL_LOADED(pilotModelHash) do
            if iters > 50 then
                DisplayError(false, "Failed to load the model")
                return nil
            end

            Wait(5)
            iters = iters + 1
        end
    end
    iters = 0

 
    pilot = PED.CREATE_PED(1, pilotModelHash, targetCoords.x + 3.5, targetCoords.y + 100.0, targetCoords.z + 80.0, 0.0, false, true)
    networkUtils.RegisterAsNetwork(pilot)

    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(pilot, true)

    PED.SET_PED_INTO_VEHICLE(pilot, avanger, -1)
    VEHICLE.SET_HELI_BLADES_SPEED(avanger, 1.0)

    TASK.TASK_PLANE_GOTO_PRECISE_VTOL(pilot, avanger, targetCoords.x, targetCoords.y, targetCoords.z+80.0, 10.0, 5.0, false, 0.0, true)

    bcInitialized = true
end

function DeInitBC()
    if avanger and pilot then
        local avangerPosition = ENTITY.GET_ENTITY_COORDS(avanger, true)

        TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(pilot, avanger, avangerPosition.x+8500, avangerPosition.y+5000, avangerPosition.z, 100.0, 262204, 25.0)
        
        Wait(1000)

        VEHICLE.CLOSE_BOMB_BAY_DOORS(avanger)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(pilot, false)
    end

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(avangerModelHash)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pilotModelHash)

    bcActive = false
    bcInitialized = false

    avanger = nil
    pilot = nil
end

function OnTick()
    if entityUtils.IsEntityAtCoords(avanger, targetCoords.x, targetCoords.y, targetCoords.z+80.0, 20.0) then
        --Creating bombs
        iters = 0
        local hash = MISC.GET_HASH_KEY("w_smug_bomb_04")
        if STREAMING.IS_MODEL_VALID(hash) then
            STREAMING.REQUEST_MODEL(hash)
            while not STREAMING.HAS_MODEL_LOADED(hash) do
                if iters > 50 then
                    DisplayError(false, "Failed to load the model")
                    return nil
                end

                Wait(5)
                iters = iters + 1
            end
        end

        bombs = { }

    

        for i = 1, bombscount, 1 do
            local avangerPosition = ENTITY.GET_ENTITY_COORDS(avanger, true)
        
            local offsetX = math.random()
            local offsetY = math.random()

            local bomb = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, avangerPosition.x+offsetX, avangerPosition.y+offsetY, avangerPosition.z-3.5, false, false, true, 0)
            if bomb ~= 0.0 then
                networkUtils.RegisterAsNetwork(bomb)

                local forward = ENTITY.GET_ENTITY_FORWARD_VECTOR(avanger)
                ENTITY.SET_ENTITY_VELOCITY(bomb, forward.x * 10.0, forward.y * 1.0, forward.z * 1.0)
                ENTITY.SET_ENTITY_ROTATION(bomb, 30.0, 50.0, 0.0, 2, true)

                bombs[i] = bomb
            end
            Wait(5)
        end
    

        iters = 0
        while #bombs > 0 and iters < 700 do
            for i = #bombs, 1, -1 do
                local bomb = bombs[i]
                -- Проверка, находится ли бомба на земле
                if not ENTITY.IS_ENTITY_IN_AIR(bomb) then
                    local coords = ENTITY.GET_ENTITY_COORDS(bomb)

                    FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 1, 100.0, true, false, 1.0, false)
                    FIRE.START_SCRIPT_FIRE(coords.x, coords.y, coords.z, 25, true)
                    FIRE.START_SCRIPT_FIRE(coords.x, coords.y+0.5, coords.z, 25, true)
                    FIRE.START_SCRIPT_FIRE(coords.x+0.5, coords.y+0.5, coords.z, 25, true)
                    FIRE.START_SCRIPT_FIRE(coords.x, coords.y+1.0, coords.z, 25, true)
                    FIRE.START_SCRIPT_FIRE(coords.x+1.0, coords.y, coords.z, 25, true)
                    FIRE.START_SCRIPT_FIRE(coords.x+1.0, coords.y+1.5, coords.z, 25, true)

                    -- Удаление бомбы
                    table.remove(bombs, i)

                    DeleteObject(bomb)
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)

                    if ENTITY.DOES_ENTITY_EXIST(bomb) then
                        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(bomb, -1000.0, 1000.0, 0.0, true, true, true)
                        DeleteObject(bomb)
                    end
                end
            end

            iters = iters + 1

            Wait(5)
        end

        DeInitBC()
    elseif iters >= 1500 then
        DeInitBC()
    end

    iters = iters + 1
end

targetCoords.x = GetGlobalVariable("BombAreaCoordX")
targetCoords.y = GetGlobalVariable("BombAreaCoordY")
targetCoords.z = GetGlobalVariable("BombAreaCoordZ")

while ScriptStillWorking and bcActive do
    if bcActive and not bcInitialized then 
        InitBC()
    end

    if bcActive then
        OnTick()
    end

    Wait(10)
end
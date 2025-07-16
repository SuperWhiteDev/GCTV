local target = nil
local aeActive = true
local aeInitialized = false
local targetforward = nil
local isTargetOnGround = false
local iters = 0

local pedModels = { "G_M_Y_StrPunk_02", "G_M_Y_MexGoon_03", "G_M_Y_SalvaGoon_01" }
local banditsCount = 5

local banditWeapons = { "WEAPON_POOLCUE", "WEAPON_HAMMER", "WEAPON_BAT" }

local bandits = { }
local banditModels = { }

local networkUtils = require("network_utils")

function InitAE()
    aeInitialized = true

    local banditRelationshipGroup = MISC.GET_HASH_KEY("BANDIT_GROUP")  -- Уникальное название группы для бандитов
    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, banditRelationshipGroup, banditRelationshipGroup)  -- Игнорировать друг друга

    for i = 1, banditsCount, 1 do
        local hash = MISC.GET_HASH_KEY(pedModels[math.random(1, #pedModels)])

        iters = 0
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
        iters = 0

        local coords = ENTITY.GET_ENTITY_COORDS(target, true)
        local heading = ENTITY.GET_ENTITY_HEADING(target) -- Получаем угол поворота
        local forwardVector = ENTITY.GET_ENTITY_FORWARD_VECTOR(target)
        
        -- Вычисление координат для спавна за спиной у цели
        local spawnX = coords.x - forwardVector.x * 6.0  -- На 6 единиц назад
        local spawnY = coords.y - forwardVector.y * 6.0
        local spawnZ = coords.z
     
        local bandit = PED.CREATE_PED(1, hash, spawnX, spawnY, spawnZ, 0.0, false, true)
        networkUtils.RegisterAsNetwork(bandit)

        PED.SET_PED_RELATIONSHIP_GROUP_HASH(bandit, banditRelationshipGroup)

        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(bandit, MISC.GET_HASH_KEY(banditWeapons[math.random(1, #banditWeapons)]), 1000, true)

        table.insert(bandits, bandit)
        table.insert(banditModels, hash)
    end

    for i = 1, #bandits, 1 do
        --TASK.TASK_GO_TO_ENTITY(bandits[i], target, 5000, 4.0, 100, 1073741824, 0)
        TASK.TASK_COMBAT_PED(bandits[i], target, 0, 16)
        PED.SET_PED_KEEP_TASK(bandits[i], true)
    end

    iters = 0
    aeInitialized = true
end

function EndAE()
    for i = 1, #bandits do
        TASK.TASK_GO_STRAIGHT_TO_COORD(bandits[i], 598.01196289062, -2116.3630371094, 5.752251625061, 20.0, 10000.0, 0.0, 0.0)
    end
    for i = 1, #banditModels, 1 do
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(banditModels[i])
    end

    bandits = { }
    banditModels = { }
    targetforward = nil

    aeActive = false
    aeInitialized = false
end

function OnTick()
    if not ENTITY.DOES_ENTITY_EXIST(target) or ENTITY.IS_ENTITY_DEAD(target, true) or iters >= 70 then
        isTargetOnGround = false
        EndAE()
    end

    for i = 1, #bandits, 1 do
        if ENTITY.HAS_ENTITY_BEEN_DAMAGED_BY_ANY_PED(target) then
            targetforward = ENTITY.GET_ENTITY_FORWARD_VECTOR(target)
            isTargetOnGround = true
        end
    end

    if isTargetOnGround and iters < 90 then
        PED.SET_PED_TO_RAGDOLL_WITH_FALL(target, 1500, 2000, 1, targetforward.x, targetforward.y, targetforward.z-0.5, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        iters = iters + 1
    end
end

target = GetGlobalVariable("BanditsTarget")

while ScriptStillWorking and aeActive do
    if aeActive and not aeInitialized then 
        InitAE()
    end

    if aeActive then
        OnTick()
    end

    Wait(10)
end
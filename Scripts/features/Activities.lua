local missionUtils = require("mission_utils")
local networkUtils = require("network_utils")

local weapons = require("weapon_enums")
local peds = require("ped_enums")

function IsInTable(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

function TestActivities()
    TASK.OPEN_PATROL_ROUTE("miss_Ass0") 
    TASK.ADD_PATROL_ROUTE_NODE(0, "WORLD_HUMAN_GUARD_STAND", -1304.7438964844, -3062.1459960938, 13.944447517395, 0.0, 0.0, 0.0, MISC.GET_RANDOM_INT_IN_RANGE(5000, 10000)) 
    TASK.ADD_PATROL_ROUTE_NODE(1, "WORLD_HUMAN_GUARD_STAND", -1337.7062988281, -3043.0068359375, 13.944443702698, 0.0, 0.0, 0.0, MISC.GET_RANDOM_INT_IN_RANGE(5000, 10000)) 
    TASK.ADD_PATROL_ROUTE_NODE(2, "WORLD_HUMAN_GUARD_STAND", -1321.13671875, -3067.8132324219, 13.944446563721, 0.0, 0.0, 0.0, MISC.GET_RANDOM_INT_IN_RANGE(5000, 10000)) 
    TASK.ADD_PATROL_ROUTE_LINK(0, 1) 
    TASK.ADD_PATROL_ROUTE_LINK(1, 2) 
    TASK.ADD_PATROL_ROUTE_LINK(2, 0) 
    TASK.CLOSE_PATROL_ROUTE() 
    TASK.CREATE_PATROL_ROUTE()

    local hash = 0x616C97B9
    local failed = false
    local Iters = 0
    if STREAMING.IS_MODEL_VALID(hash) then
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) and not failed do
            if Iters > 50 then
                DisplayError(false, "Failed to load the model")
                failed = true
            end

            Wait(5)
            Iters = Iters + 1
        end

        local ped = PED.CREATE_PED(2, hash, -1304.7438964844, -3062.1459960938, 13.5, 0.0, false, true)
        if ped ~= 0.0 then
            networkUtils.RegisterAsNetwork(ped)
            TASK.TASK_PATROL(ped, "miss_Ass0", 0, false, false)

            print("Created ped " .. ped)
        else
            print("Error")
        end
    else
        print("Error unable load model")
    end
end

--[[
    Military Convoy Activity Script
]]

local mcVehicles = { }
local mcPed = { }
local mcDrivers = { }
local mcDriversCount = 8
local mainVeh = nil
local reinforcementsVehsStart = nil
local reinforcementsPedsStart = nil
local mcConvoyIsMoving = false
local ReinforcementsReady = false
local ReinforcementsOnWay = false
local AlreadyRespawnedNearArmyBase = false
local mcActivitieStarted = false
local mcTimeout = 0

function StartMCActivity()
    -- Creating vehicles
    mcVehicles[1] = missionUtils.CreateMissionVehicle("barracks3", -2233.5217285156, 3146.6452636719, 32.810161590576, 90.0)
    mcVehicles[2] = missionUtils.CreateMissionVehicle("crusader", -2228.5571289062, 3166.7858886719, 32.810153961182, 90.0)
    mcVehicles[3] = missionUtils.CreateMissionVehicle("crusader", -2239.5297851562, 3161.7648925781, 32.810153961182, 90.0)
    mcVehicles[4] = missionUtils.CreateMissionVehicle("rhino", -2206.5329589844, 3155.5727539062, 32.810150146484, 90.0)
    mcVehicles[5] = missionUtils.CreateMissionVehicle("rhino", -2243.4587402344, 3133.9682617188, 32.810146331787, 90.0)
    mcVehicles[6] = missionUtils.CreateMissionVehicle("barrage", -2182.9187011719, 3120.2365722656, 32.536308288574, 90.0)
    mcVehicles[7] = missionUtils.CreateMissionVehicle("barrage", -2184.6301269531, 3133.4401855469, 32.810161590576, 90.0)

    mcVehicles[8] = missionUtils.CreateMissionVehicle("terbyte", -2206.2358398438, 3144.5886230469, 32.810150146484, 90.0)
    mainVeh = mcVehicles[8] 

    ENTITY.SET_ENTITY_MAX_HEALTH(mainVeh, 50000)
    ENTITY.SET_ENTITY_HEALTH(mainVeh, 50000, 0, 0)

    for i = 1, #mcVehicles, 1 do
        if mcVehicles[i] == 0.0 then
            mcDriversCount = mcDriversCount - 1
        end
    end

    -- Creating Peds
    
    mcPed[1] = missionUtils.CreateMissionPed("CSB_Ramp_marine", peds.PedType.PED_TYPE_ARMY, -2348.0, 3268.36, 32.8, 0.0)
    mcPed[2] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2349.0, 3268.36, 32.8, 0.0)
    mcPed[3] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2349.545, 3268.36, 32.8, 0.0)
    mcPed[4] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2350.0, 3268.36, 32.8, 0.0)
    mcPed[5] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2350.5, 3268.36, 32.8, 0.0)
    mcPed[6] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2349.0, 3267.0, 32.8, 0.0)
    mcPed[7] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2349.545, 3267.5, 32.8, 0.0)
    mcPed[8] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2350.0, 3268.0, 32.8, 0.0)
    mcPed[9] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2342.2, 3243.5, 33.0, 330.0)
    for i = 1, 9, 1 do
        TASK.TASK_ENTER_VEHICLE(mcPed[i], mcVehicles[1], 190000, i - 2, 1.0, 1, 0, 0)
    end


    mcPed[10] = missionUtils.CreateMissionPed("CSB_Ramp_marine", peds.PedType.PED_TYPE_ARMY, -2152.0, 3264.0, 32.8, 0.0)
    mcPed[11] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2153.0, 3263.0, 32.8, 0.0)
    mcPed[12] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2153.0, 3265.0, 32.8, 0.0)
    mcPed[13] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2154.0, 3264.0, 32.8, 0.0)
    for i = 1, 4, 1 do
        TASK.TASK_ENTER_VEHICLE(mcPed[9+i], mcVehicles[2], 190000, i - 2, 1.0, 1, 0, 0)
    end

    mcPed[14] = missionUtils.CreateMissionPed("CSB_Ramp_marine", peds.PedType.PED_TYPE_ARMY, -2152.0, 3261.0, 32.8, 0.0)
    mcPed[15] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2154.0, 3261.0, 32.8, 0.0)
    mcPed[16] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2154.0, 3261.0, 32.8, 0.0)
    mcPed[17] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2151.0, 3263.0, 32.8, 0.0)
    for i = 1, 4, 1 do
        TASK.TASK_ENTER_VEHICLE(mcPed[13+i], mcVehicles[3], 190000, i - 2, 1.0, 1, 0, 0)
    end

    mcPed[18] = missionUtils.CreateMissionPed("S_M_M_Marine_01", peds.PedType.PED_TYPE_ARMY, -2353.10546875, 3261.1391601562, 32.81, 0.0)
    mcPed[19] = missionUtils.CreateMissionPed("S_M_M_Marine_01", peds.PedType.PED_TYPE_ARMY, -2352.3757324219, 3259.1569824219, 32.81, 0.0)
    mcPed[20] = missionUtils.CreateMissionPed("CSB_Ramp_marine", peds.PedType.PED_TYPE_ARMY, -2351.1872558594, 3257.3666992188, 32.81, 0.0)

    TASK.TASK_ENTER_VEHICLE(mcPed[18], mcVehicles[4], 190000, -1, 1.0, 1, 0, 0)
    TASK.TASK_ENTER_VEHICLE(mcPed[19], mcVehicles[5], 190000, -1, 1.0, 1, 0, 0)
    TASK.TASK_ENTER_VEHICLE(mcPed[20], mcVehicles[8], 190000, -1, 1.0, 1, 0, 0)

    mcPed[21] = missionUtils.CreateMissionPed("CSB_Ramp_marine", peds.PedType.PED_TYPE_ARMY, -2153.5, 3261.0, 32.8, 0.0)
    mcPed[22] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2153.0, 3263.5, 32.8, 0.0)
    mcPed[23] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2150.0, 3261.0, 32.8, 0.0)
    mcPed[24] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2150.0, 3264.5, 32.8, 0.0)
    for i = 1, 4, 1 do
        TASK.TASK_ENTER_VEHICLE(mcPed[20+i], mcVehicles[6], 190000, i - 2, 1.0, 1, 0, 0)
    end

    mcPed[25] = missionUtils.CreateMissionPed("CSB_Ramp_marine", peds.PedType.PED_TYPE_ARMY, -2153.5, 3262.5, 32.8, 0.0)
    mcPed[26] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2153.5, 3260.5, 32.8, 0.0)
    mcPed[27] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2150.0, 3264.0, 32.8, 0.0)
    mcPed[28] = missionUtils.CreateMissionPed("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2155.5, 3264.0, 32.8, 0.0)
    for i = 1, 4, 1 do
        TASK.TASK_ENTER_VEHICLE(mcPed[24+i], mcVehicles[7], 190000, i - 2, 1.0, 1, 0, 0)
    end


    for i = 1, #mcPed, 1 do
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(mcPed[i], weapons.Weapon.WEAPON_MILITARYRIFLE, 1000, true)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(mcPed[i], weapons.Weapon.WEAPON_PISTOL_MK2, 1000, true)

        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(mcPed[i], weapons.Weapon.WEAPON_SMOKEGRENADE, 1000, true)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(mcPed[i], weapons.Weapon.WEAPON_GRENADE, 1000, true)

        WEAPON.SET_CURRENT_PED_WEAPON(mcPed[i], weapons.Weapon.WEAPON_MILITARYRIFLE, true)

        PED.SET_PED_ACCURACY(mcPed[i], 100)
    end

    local FirstPedGroup = PED.GET_PED_GROUP_INDEX(mcPed[1])
    
    for i = 1, #mcPed, 1 do
        PED.SET_PED_AS_GROUP_MEMBER(mcPed[i], FirstPedGroup)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(mcPed[i], true)
    end

    Wait(5)

    
    mcTimeout = 0
    mcActivitieStarted = true
end
function EndMCActivity(status)
    local blip = HUD.GET_BLIP_FROM_ENTITY(mainVeh);
    if HUD.DOES_BLIP_EXIST(blip) then
        local blipp = New(4)
        Game.WriteInt(blipp, blip)
        HUD.REMOVE_BLIP(blipp)
        Delete(blipp)
    end 

    for i = 1, #mcVehicles, 1 do
        local entityp = NewVehicle(mcVehicles[i])
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(mcVehicles[i], false, true)
        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(entityp)
        Delete(entityp)
    end
    for i = 1, #mcPed, 1 do
        local entityp = NewVehicle(mcPed[i])
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(mcVehicles[i], false, true)
        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(entityp)
        Delete(entityp)
    end

    mcPed = { }
    mcDrivers = { }
    mcVehicles = { }
    mcConvoyIsMoving = false
    ReinforcementsReady = false
    ReinforcementsOnWay = false
    AlreadyRespawnedNearArmyBase = false
    mcActivitieStarted = false

    SetGlobalVariableValue("MilitaryConvoyActivityState", 0.0)

    if status then
        print("The mission has been succesfully completed")
    end
end

function MakeAllPedsSeat()
    for i = 1, 9, 1 do
        PED.SET_PED_INTO_VEHICLE(mcPed[i], mcVehicles[1], i - 2)
    end

    for i = 1, 4, 1 do
        PED.SET_PED_INTO_VEHICLE(mcPed[9+i], mcVehicles[2], i - 2)
    end
    for i = 1, 4, 1 do
        PED.SET_PED_INTO_VEHICLE(mcPed[13+i], mcVehicles[3], i - 2)
    end

    PED.SET_PED_INTO_VEHICLE(mcPed[18], mcVehicles[4], -1)
    PED.SET_PED_INTO_VEHICLE(mcPed[19], mcVehicles[5], -1)
    PED.SET_PED_INTO_VEHICLE(mcPed[20], mcVehicles[8], -1)
    for i = 1, 4, 1 do
        PED.SET_PED_INTO_VEHICLE(mcPed[20+i], mcVehicles[6], i - 2)
    end
    for i = 1, 4, 1 do
        PED.SET_PED_INTO_VEHICLE(mcPed[24+i], mcVehicles[7], i - 2)
    end
end

function CreateReinforcements()
    -- Creating vehicles
    reinforcementsVehsStart = #mcVehicles + 1
    mcVehicles[reinforcementsVehsStart] = missionUtils.CreateMissionVehicle("apc", -1828.9190673828, -516.04241943359, 28.9, 285.0)
    mcVehicles[reinforcementsVehsStart+1] = missionUtils.CreateMissionVehicle("halftrack", -1837.6166992188, -515.97180175781, 28.5, 290.0)
    mcVehicles[reinforcementsVehsStart+2] = missionUtils.CreateMissionVehicle("apc", -1841.7521972656, -524.65478515625, 29.8, 340.0)
    mcVehicles[reinforcementsVehsStart+3] = missionUtils.CreateMissionVehicle("halftrack", -1845.2630615234, -515.36199951172, 28.5, 315.0)
    mcVehicles[reinforcementsVehsStart+4] = missionUtils.CreateMissionVehicle("rhino", -1851.3469238281, -510.86526489258, 27.9, 300.0)

    -- Creating Peds
    reinforcementsPedsStart = #mcPed + 1
    mcPed[reinforcementsPedsStart] = missionUtils.CreateMissionPed("S_M_Y_BlackOps_01", peds.PedType.PED_TYPE_ARMY, -1828.5555419922, -514.02404785156, 28.9, 2.5)
    mcPed[reinforcementsPedsStart+1] = missionUtils.CreateMissionPed("S_M_Y_BlackOps_01", peds.PedType.PED_TYPE_ARMY, -1844.9086914062, -524.63116455078, 29.5, 140.0)
    mcPed[reinforcementsPedsStart+2] = missionUtils.CreateMissionPed("S_M_Y_BlackOps_02", peds.PedType.PED_TYPE_ARMY, -1851.6458740234, -507.38906860352, 27.5, 106.0)
    mcPed[reinforcementsPedsStart+3] = missionUtils.CreateMissionPed("S_M_Y_BlackOps_03", peds.PedType.PED_TYPE_ARMY, -1853.9539794922, -508.90139770508, 27.5, 290.0)
    mcPed[reinforcementsPedsStart+4] = missionUtils.CreateMissionPed("S_M_Y_BlackOps_03", peds.PedType.PED_TYPE_ARMY, -1833.7620849609, -519.28356933594, 29.0, 200.0)
    mcPed[reinforcementsPedsStart+5] = missionUtils.CreateMissionPed("S_M_Y_BlackOps_03", peds.PedType.PED_TYPE_ARMY, -1832.3343505859, -520.33673095703, 29.0, 145.0)
    mcPed[reinforcementsPedsStart+6] = missionUtils.CreateMissionPed("S_M_Y_BlackOps_03", peds.PedType.PED_TYPE_ARMY, -1834.7995605469, -511.01068115234, 28.5, 360.0)
    mcPed[reinforcementsPedsStart+7] = missionUtils.CreateMissionPed("S_M_Y_BlackOps_03", peds.PedType.PED_TYPE_ARMY, -1836.9810791016, -510.52258300781, 28.5, 40.0)
    mcPed[reinforcementsPedsStart+8] = missionUtils.CreateMissionPedInVehicle(mcVehicles[reinforcementsVehsStart+1], -1, "S_M_Y_BlackOps_01", peds.PedType.PED_TYPE_ARMY, -1829.5555419922, -513.02404785156, 28.9, 2.5)
    mcPed[reinforcementsPedsStart+9] = missionUtils.CreateMissionPedInVehicle(mcVehicles[reinforcementsVehsStart+3], -1, "S_M_Y_BlackOps_01", peds.PedType.PED_TYPE_ARMY, -1842.9086914062, -522.63116455078, 29.5, 140.0)

    for i = reinforcementsPedsStart, #mcPed, 1 do
        
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(mcPed[i], weapons.Weapon.WEAPON_CARBINERIFLE_MK2, 1000, true)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(mcPed[i], weapons.Weapon.WEAPON_APPISTOL, 1000, true)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(mcPed[i], weapons.Weapon.WEAPON_GRENADE, 1000, true)
        WEAPON.SET_CURRENT_PED_WEAPON(mcPed[i], weapons.Weapon.WEAPON_CARBINERIFLE_MK2, true)
        PED.SET_PED_ACCURACY(mcPed[i], 100)
    end
    
    TASK.TASK_START_SCENARIO_IN_PLACE(mcPed[reinforcementsPedsStart], "WORLD_HUMAN_AA_COFFEE", 0, true)
    TASK.TASK_START_SCENARIO_IN_PLACE(mcPed[reinforcementsPedsStart+1], "WORLD_HUMAN_AA_COFFEE", 0, true)

    TASK.TASK_START_SCENARIO_IN_PLACE(mcPed[reinforcementsPedsStart+2], "WORLD_HUMAN_SMOKING_POT", 0, true)
    TASK.TASK_START_SCENARIO_IN_PLACE(mcPed[reinforcementsPedsStart+3], "WORLD_HUMAN_SMOKING_POT", 0, true)

    TASK.TASK_START_SCENARIO_IN_PLACE(mcPed[reinforcementsPedsStart+4], "WORLD_HUMAN_AA_COFFEE", 0, true)
    TASK.TASK_START_SCENARIO_IN_PLACE(mcPed[reinforcementsPedsStart+5], "WORLD_HUMAN_AA_COFFEE", 0, true)

    ReinforcementsReady = true
end

function RequestReinforcements()
    TASK.TASK_ENTER_VEHICLE(mcPed[reinforcementsPedsStart], mcVehicles[reinforcementsVehsStart], 500, -1, 2.0, 1, 0, 0)
    TASK.TASK_ENTER_VEHICLE(mcPed[reinforcementsPedsStart+1], mcVehicles[reinforcementsVehsStart+2], 500, -1, 2.0, 1, 0, 0)
    TASK.TASK_ENTER_VEHICLE(mcPed[reinforcementsPedsStart+2], mcVehicles[reinforcementsVehsStart+4], 500, -1, 2.0, 1, 0, 0)

    for i = 2, 3, 1 do
        TASK.TASK_ENTER_VEHICLE(mcPed[(reinforcementsPedsStart+1) + i], mcVehicles[reinforcementsVehsStart+1], 500, i - 2, 2.0, 1, 0, 0)
    end
    
    for i = 2, 3, 1 do
        TASK.TASK_ENTER_VEHICLE(mcPed[(reinforcementsPedsStart+3) + i], mcVehicles[reinforcementsVehsStart+3], 500, i - 2, 2.0, 1, 0, 0)
    end

    TASK.TASK_ENTER_VEHICLE(mcPed[reinforcementsPedsStart+7], mcVehicles[reinforcementsVehsStart], 500, -1, 2.0, 1, 0, 0)

    Wait(500)

    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[reinforcementsPedsStart], PED.GET_VEHICLE_PED_IS_IN(mcPed[reinforcementsPedsStart], false), -1406.7188720703, -2443.9128417969, 14.0, 25.0, 271, 25.0)
    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[reinforcementsPedsStart+1], PED.GET_VEHICLE_PED_IS_IN(mcPed[reinforcementsPedsStart+1], false), -1406.7188720703, -2449.9128417969, 14.0, 25.0, 271, 25.0)
    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[reinforcementsPedsStart+2], PED.GET_VEHICLE_PED_IS_IN(mcPed[reinforcementsPedsStart+2], false), -1423.7188720703, -2449.9128417969, 14.0, 25.0, 271, 25.0)
    
    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[reinforcementsPedsStart+8], PED.GET_VEHICLE_PED_IS_IN(mcPed[reinforcementsPedsStart+8], false), -1406.7188720703, -2455.9128417969, 14.0, 25.0, 271, 25.0)
    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[reinforcementsPedsStart+9], PED.GET_VEHICLE_PED_IS_IN(mcPed[reinforcementsPedsStart+9], false), -1406.7188720703, -2462.9128417969, 14.0, 25.0, 271, 25.0)

    ReinforcementsOnWay = true
end

function RespawnConvoyNearArmyBase()

    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mcVehicles[1], -2578.4711914062, 3405.8054199219, 14.0, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mcVehicles[1], 200.0)

    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mcVehicles[2], -2576.6633300781, 3422.0734863281, 14.0, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mcVehicles[2], 200.0)

    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mcVehicles[3], -2595.5637207031, 3412.4396972656, 14.0, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mcVehicles[3], 200.0)

    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mcVehicles[4], -2579.689453125,3443.7888183594, 14.0, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mcVehicles[4], 200.0)

    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mcVehicles[5], -2603.4038085938, 3435.2810058594, 14.0, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mcVehicles[5], 200.0)

    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mcVehicles[8], -2616.8571777344, 3423.84765625, 17.5, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mcVehicles[8], 250.0)

    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mcVehicles[6], -2611.0341796875, 3442.1936035156, 15.0, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mcVehicles[6], 240.0)

    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mcVehicles[7], -2557.6052246094, 3464.9541015625, 15.0, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mcVehicles[7], 160.0)

    AlreadyRespawnedNearArmyBase = true

    for i = 1, #mcPed, 1 do
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(mcPed[i], false)
    end
end

function UpdateMCActivity()
    if mcActivitieStarted then
        if not IsInTable(mcDrivers, mcPed[1]) and PED.IS_PED_IN_ANY_VEHICLE(mcPed[1]) then
            for i = 2, 9, 1 do
                TASK.TASK_ENTER_VEHICLE(mcPed[i], mcVehicles[1], 190000, i - 2, 1.0, 1, 0, 0)
            end
            table.insert(mcDrivers, mcPed[1])
        end
        if not IsInTable(mcDrivers, mcPed[10]) and PED.IS_PED_IN_ANY_VEHICLE(mcPed[10]) then
            for i = 2, 4, 1 do
                TASK.TASK_ENTER_VEHICLE(mcPed[9+i], mcVehicles[2], 190000, i - 2, 1.0, 1, 0, 0)
            end
            table.insert(mcDrivers, mcPed[10])
        end
        if not IsInTable(mcDrivers, mcPed[14]) and PED.IS_PED_IN_ANY_VEHICLE(mcPed[14]) then
            for i = 2, 4, 1 do
                TASK.TASK_ENTER_VEHICLE(mcPed[13+i], mcVehicles[3], 190000, i - 2, 1.0, 1, 0, 0)
            end
            table.insert(mcDrivers, mcPed[14])
        end
        if not IsInTable(mcDrivers, mcPed[18]) and PED.IS_PED_IN_ANY_VEHICLE(mcPed[18]) then
            table.insert(mcDrivers, mcPed[18])
        end
        if not IsInTable(mcDrivers, mcPed[19]) and PED.IS_PED_IN_ANY_VEHICLE(mcPed[19]) then
            table.insert(mcDrivers, mcPed[19])
        end
        if not IsInTable(mcDrivers, mcPed[20]) and PED.IS_PED_IN_ANY_VEHICLE(mcPed[20]) then
            table.insert(mcDrivers, mcPed[20])
        end
        if not IsInTable(mcDrivers, mcPed[21]) and PED.IS_PED_IN_ANY_VEHICLE(mcPed[21]) then
            for i = 2, 4, 1 do
                TASK.TASK_ENTER_VEHICLE(mcPed[20+i], mcVehicles[6], 190000, i - 2, 1.0, 1, 0, 0)
            end
            table.insert(mcDrivers, mcPed[21])
        end
        if not IsInTable(mcDrivers, mcPed[25]) and PED.IS_PED_IN_ANY_VEHICLE(mcPed[25]) then
            for i = 2, 4, 1 do
                TASK.TASK_ENTER_VEHICLE(mcPed[24+i], mcVehicles[7], 190000, i - 2, 1.0, 1, 0, 0)
            end
            table.insert(mcDrivers, mcPed[25])
        end
        
        --print(#mcDrivers >= mcDriversCount, #mcDrivers)

        if not mcConvoyIsMoving and #mcDrivers >= mcDriversCount then
            if PED.IS_PED_IN_ANY_VEHICLE(mcPed[9]) == 0.0 or PED.IS_PED_IN_ANY_VEHICLE(mcPed[2]) == 0.0 then
                return nil
            end

            MakeAllPedsSeat()
            RespawnConvoyNearArmyBase()
            
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[1], PED.GET_VEHICLE_PED_IS_IN(mcPed[1], false), -1363.6254882812, -2430.97265625, 13.94619846344, 15.0, 271, 25.0)
            Wait(500)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[10], PED.GET_VEHICLE_PED_IS_IN(mcPed[10], false), -1373.7124023438, -2428.8376464844, 13.949308395386, 13.0, 271, 25.0)
            Wait(500)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[14], PED.GET_VEHICLE_PED_IS_IN(mcPed[14], false), -1374.0899658203, -2450.9594726562, 13.945671081543, 15.0, 271, 25.0)
            Wait(500)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[18], PED.GET_VEHICLE_PED_IS_IN(mcPed[18], false),  -1326.5135498047, -2423.5234375, 13.945148468018, 15.0, 271, 25.0)
            Wait(500)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[19], PED.GET_VEHICLE_PED_IS_IN(mcPed[19], false), -1317.78515625, -2410.8020019531, 13.945151329041, 15.0, 271, 25.0)
            Wait(500)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[20], PED.GET_VEHICLE_PED_IS_IN(mcPed[20], false), -1348.6295166016, -2440.5349121094, 13.945145606995, 15.0, 271, 25.0)
            Wait(500)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[21], PED.GET_VEHICLE_PED_IS_IN(mcPed[21], false), -1249.2175292969, -2423.9575195312, 13.94514465332, 15.0, 271, 25.0)
            Wait(500)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[25], PED.GET_VEHICLE_PED_IS_IN(mcPed[25], false), -1251.0859375, -2436.2224121094, 13.945145606995, 15.0, 271, 25.0)

            local blip = HUD.ADD_BLIP_FOR_ENTITY(mainVeh)
            HUD.SET_BLIP_AS_FRIENDLY(blip, true)
            HUD.SET_BLIP_SPRITE(blip, 632)
            HUD.SET_BLIP_COLOUR(blip, 66)
            HUD.SET_BLIP_DISPLAY(blip, 6)

            mcConvoyIsMoving = true

            print("Convoy is started")
            Wait(5000)
        end


        --[[
        print("Time to timeout ", mcTimeout)
        if mcTimeout >= 300 and mcDriversCount ~= #mcDrivers then
            print("Timeout extra start")
            mcDriversCount = #mcDrivers
        else
            mcTimeout = mcTimeout + 1
        end
        ]]
        if mcConvoyIsMoving then
            print(ENTITY.IS_ENTITY_IN_ZONE(mainVeh, "ARMYB"), AlreadyRespawnedNearArmyBase, ENTITY.IS_ENTITY_IN_ZONE(mainVeh, "ARMYB") and not AlreadyRespawnedNearArmyBase)
            --print("MainVeh dead ", ENTITY.IS_ENTITY_DEAD(mainVeh), " Main veh in airp ", ENTITY.IS_ENTITY_IN_ZONE(mainVeh, "AirP"), " ConvoyStuct ", ENTITY.IS_ENTITY_IN_ZONE(mainVeh, "ARMYB") == 1.0 and ENTITY.GET_ENTITY_SPEED(mainVeh) < 1.0 and not AlreadyRespawnedNearArmyBase)
            if ENTITY.IS_ENTITY_DEAD(mainVeh) then
                ShowMessage("Mission failed")
                print("Missiong Failed")
                EndMCActivity(false)
            elseif ENTITY.IS_ENTITY_IN_ZONE(mainVeh, "AirP") then
                ShowMessage("Mission Completed")
                EndMCActivity(true)
            elseif ENTITY.IS_ENTITY_IN_ZONE(mainVeh, "PBLUF") and not ReinforcementsReady then
                CreateReinforcements()
            elseif ENTITY.IS_ENTITY_IN_ZONE(mainVeh, "DELPE") and not ReinforcementsOnWay then
                RequestReinforcements()
            elseif ENTITY.IS_ENTITY_IN_ZONE(mainVeh, "ARMYB") and not AlreadyRespawnedNearArmyBase then
                RespawnConvoyNearArmyBase()
            else
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[1], PED.GET_VEHICLE_PED_IS_IN(mcPed[1], false), -1363.6254882812, -2430.97265625, 13.94619846344, 15.0, 271, 25.0)
                Wait(500)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[10], PED.GET_VEHICLE_PED_IS_IN(mcPed[10], false), -1373.7124023438, -2428.8376464844, 13.949308395386, 15.0, 271, 25.0)
                Wait(500)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[14], PED.GET_VEHICLE_PED_IS_IN(mcPed[14], false), -1374.0899658203, -2450.9594726562, 13.945671081543, 15.0, 271, 25.0)
                Wait(500)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[18], PED.GET_VEHICLE_PED_IS_IN(mcPed[18], false),  -1326.5135498047, -2423.5234375, 13.945148468018, 15.0, 271, 25.0)
                Wait(500)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[19], PED.GET_VEHICLE_PED_IS_IN(mcPed[19], false), -1317.78515625, -2410.8020019531, 13.945151329041, 15.0, 271, 25.0)
                Wait(500)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[20], PED.GET_VEHICLE_PED_IS_IN(mcPed[20], false), -1348.6295166016, -2440.5349121094, 13.945145606995, 15.0, 271, 25.0)
                Wait(500)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[21], PED.GET_VEHICLE_PED_IS_IN(mcPed[21], false), -1249.2175292969, -2423.9575195312, 13.94514465332, 15.0, 271, 25.0)
                Wait(500)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[25], PED.GET_VEHICLE_PED_IS_IN(mcPed[25], false), -1251.0859375, -2436.2224121094, 13.945145606995, 15.0, 271, 25.0)
                
                if VEHICLE.GET_PED_IN_VEHICLE_SEAT(mainVeh, -1 , false) == 0.0 then
                    local randomPedIndex
                    repeat
                        randomPedIndex = math.random(1, #mcPed)
                    until ENTITY.DOES_ENTITY_EXIST(mcPed[randomPedIndex]) == 0.0 or ENTITY.IS_ENTITY_DEAD(mcPed[randomPedIndex]) == 1.0 

                    TASK.TASK_ENTER_VEHICLE(mcPed[randomPedIndex], mainVeh, 1000, -1, 2.0, 1, 0, 0)
                    Wait(1000)
                    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[randomPedIndex], PED.GET_VEHICLE_PED_IS_IN(mcPed[randomPedIndex], false), -1348.6295166016, -2440.5349121094, 13.945145606995, 50.0, 271, 25.0)
                end 
                if ENTITY.IS_ENTITY_DEAD(mcVehicles[1]) == 0.0 and VEHICLE.GET_PED_IN_VEHICLE_SEAT(mcVehicles[1], -1 , false) == 0.0 then
                    for i = 3, 9, 1 do
                        TASK.TASK_ENTER_VEHICLE(mcPed[i], mcVehicles[1], 10000, i - 2, 2.0, 1, 0, 0)
                    end

                    if ENTITY.IS_ENTITY_DEAD(mcPed[1]) == 1.0 then
                        repeat
                            local randomPedIndex = math.random(1, #mcPed)
                        until ENTITY.DOES_ENTITY_EXIST(mcPed[randomPedIndex]) == 0.0 or ENTITY.IS_ENTITY_DEAD(mcPed[randomPedIndex]) == 1.0 

                        TASK.TASK_ENTER_VEHICLE(mcPed[randomPedIndex], mcVehicles[1], 1000, -1, 2.0, 1, 0, 0)
                    else
                        TASK.TASK_ENTER_VEHICLE(mcPed[1], mcVehicles[1], 1000, -1, 2.0, 1, 0, 0)
                    end
                    Wait(1000)
                    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mcPed[1], PED.GET_VEHICLE_PED_IS_IN(mcPed[1], false), -1363.6254882812, -2430.97265625, 13.94619846344, 40.0, 271, 25.0)
                end
                
            end 
        end
    end
end

--reset point1  -2505.8774414062 y = 3596.7341308594 z = 14.447336196899
--reset point2  -2727.5102539062, 2310.0847167969, 18.07469367981
--reset point3  -1783.8172607422 y = -312.63812255859 z = 43.619632720947

local waitTime = 1000

while ScriptStillWorking do
    if IsGlobalVariableExist("TestActivitieState") then
    elseif IsGlobalVariableExist("MilitaryConvoyActivityState") then
        if GetGlobalVariable("MilitaryConvoyActivityState") == 1.0 and not mcActivitieStarted then
            StartMCActivity()
        elseif GetGlobalVariable("MilitaryConvoyActivityState") == 0.0 and mcActivitieStarted then
            EndMCActivity(false)
        end

        UpdateMCActivity()

        waitTime = 50
    else
        waitTime = 1000
    end
    Wait(waitTime)
end
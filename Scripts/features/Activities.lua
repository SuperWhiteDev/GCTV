-- This script manages various in-game activities, specifically implementing
-- the "Military Convoy" activity.

-- Loading necessary utility modules.
local mission_utils = require("mission_utils") -- Module for mission-related utilities (e.g., creating mission vehicles/peds).
local network_utils = require("network_utils") -- Module for network utilities (e.g., requesting control).

-- Loading enumeration modules for weapons and peds.
local weapons = require("weapon_enums") -- Enumerations for weapon hashes.
local peds = require("ped_enums")       -- Enumerations for ped types.

--- Checks if a given value exists within a table.
-- @param tbl table The table to search within.
-- @param value any The value to search for.
-- @returns boolean True if the value is found, false otherwise.
function is_in_table(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

--- Placeholder function for testing activities.
-- This function currently sets up a simple patrol route and spawns a ped to follow it.
function test_activities()
    -- Define a patrol route.
    TASK.OPEN_PATROL_ROUTE("miss_Ass0") 
    TASK.ADD_PATROL_ROUTE_NODE(0, "WORLD_HUMAN_GUARD_STAND", -1304.7438964844, -3062.1459960938, 13.944447517395, 0.0, 0.0, 0.0, MISC.GET_RANDOM_INT_IN_RANGE(5000, 10000)) 
    TASK.ADD_PATROL_ROUTE_NODE(1, "WORLD_HUMAN_GUARD_STAND", -1337.7062988281, -3043.0068359375, 13.944443702698, 0.0, 0.0, 0.0, MISC.GET_RANDOM_INT_IN_RANGE(5000, 10000)) 
    TASK.ADD_PATROL_ROUTE_NODE(2, "WORLD_HUMAN_GUARD_STAND", -1321.13671875, -3067.8132324219, 13.944446563721, 0.0, 0.0, 0.0, MISC.GET_RANDOM_INT_IN_RANGE(5000, 10000)) 
    TASK.ADD_PATROL_ROUTE_LINK(0, 1) 
    TASK.ADD_PATROL_ROUTE_LINK(1, 2) 
    TASK.ADD_PATROL_ROUTE_LINK(2, 0) 
    TASK.CLOSE_PATROL_ROUTE() 
    TASK.CREATE_PATROL_ROUTE() -- Finalize and create the patrol route.

    local ped_model_hash = 0x616C97B9 -- Example ped model hash (S_M_Y_MARINE_01)
    local failed_to_load = false
    local iterations = 0

    -- Request and load the ped model.
    if STREAMING.IS_MODEL_VALID(ped_model_hash) then
        STREAMING.REQUEST_MODEL(ped_model_hash)
        while not STREAMING.HAS_MODEL_LOADED(ped_model_hash) and not failed_to_load do
            if iterations > 50 then
                DisplayError(false, "Failed to load the model for test activity.")
                failed_to_load = true
            end
            Wait(5)
            iterations = iterations + 1
        end

        if not failed_to_load then
            -- Create the ped at the first patrol node's coordinates.
            local created_ped = PED.CREATE_PED(peds.PedType.PED_TYPE_ARMY, ped_model_hash, -1304.7438964844, -3062.1459960938, 13.5, 0.0, false, true)
            if created_ped ~= 0.0 then
                network_utils.register_as_network(created_ped) -- Register ped for network synchronization.
                TASK.TASK_PATROL(created_ped, "miss_Ass0", 0, false, false) -- Task ped to follow patrol route.
                print("Created test ped: " .. created_ped)
            else
                print("Error: Failed to create test ped.")
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ped_model_hash) -- Release model.
        end
    else
        print("Error: Unable to load model for test activity (model hash not valid).")
    end
end

--[[
    Military Convoy Activity Script Variables
]]

local mc_vehicles = {}          -- Table to store handles of convoy vehicles.
local mc_ped = {}               -- Table to store handles of convoy peds.
local mc_drivers = {}           -- Table to track peds currently driving vehicles in the convoy.
local mc_drivers_count = 8      -- Expected number of initial drivers.
local main_convoy_vehicle = nil -- The main vehicle of the convoy (e.g., Terabyte).
local reinforcements_veh_start_index = nil -- Starting index for reinforcement vehicles in mc_vehicles.
local reinforcements_ped_start_index = nil -- Starting index for reinforcement peds in mc_ped.
local mc_convoy_is_moving = false   -- Flag indicating if the convoy is currently moving.
local reinforcements_ready = false  -- Flag indicating if reinforcements are spawned and ready.
local reinforcements_on_way = false -- Flag indicating if reinforcements are en route.
local already_respawned_near_army_base = false -- Flag to prevent multiple respawns near army base.
local mc_activity_started = false   -- Flag indicating if the military convoy activity has been initialized.
local mc_timeout = 0                -- Timeout counter (unused in original logic, kept commented for context).

--- Starts the Military Convoy activity.
-- Spawns initial vehicles and peds, assigns them to vehicles, and gives them weapons.
function start_mc_activity()
    -- Create initial convoy vehicles.
    mc_vehicles[1] = mission_utils.create_mission_vehicle("barracks3", -2233.5217285156, 3146.6452636719, 32.810161590576, 90.0)
    mc_vehicles[2] = mission_utils.create_mission_vehicle("crusader", -2228.5571289062, 3166.7858886719, 32.810153961182, 90.0)
    mc_vehicles[3] = mission_utils.create_mission_vehicle("crusader", -2239.5297851562, 3161.7648925781, 32.810153961182, 90.0)
    mc_vehicles[4] = mission_utils.create_mission_vehicle("rhino", -2206.5329589844, 3155.5727539062, 32.810150146484, 90.0)
    mc_vehicles[5] = mission_utils.create_mission_vehicle("rhino", -2243.4587402344, 3133.9682617188, 32.810146331787, 90.0)
    mc_vehicles[6] = mission_utils.create_mission_vehicle("barrage", -2182.9187011719, 3120.2365722656, 32.536308288574, 90.0)
    mc_vehicles[7] = mission_utils.create_mission_vehicle("barrage", -2184.6301269531, 3133.4401855469, 32.810161590576, 90.0)
    mc_vehicles[8] = mission_utils.create_mission_vehicle("terbyte", -2206.2358398438, 3144.5886230469, 32.810150146484, 90.0)
    main_convoy_vehicle = mc_vehicles[8] -- Assign the Terabyte as the main vehicle.

    -- Set main vehicle's health (e.g., for invincibility or high durability).
    ENTITY.SET_ENTITY_MAX_HEALTH(main_convoy_vehicle, 50000)
    ENTITY.SET_ENTITY_HEALTH(main_convoy_vehicle, 50000, 0, 0)

    -- Adjust driver count if any vehicles failed to spawn.
    for i = 1, #mc_vehicles do
        if mc_vehicles[i] == 0.0 then
            mc_drivers_count = mc_drivers_count - 1
        end
    end

    -- Create initial convoy peds (soldiers/marines).
    mc_ped[1] = mission_utils.create_mission_ped("CSB_Ramp_marine", peds.PedType.PED_TYPE_ARMY, -2348.0, 3268.36, 32.8, 0.0)
    mc_ped[2] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2349.0, 3268.36, 32.8, 0.0)
    mc_ped[3] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2349.545, 3268.36, 32.8, 0.0)
    mc_ped[4] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2350.0, 3268.36, 32.8, 0.0)
    mc_ped[5] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2350.5, 3268.36, 32.8, 0.0)
    mc_ped[6] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2349.0, 3267.0, 32.8, 0.0)
    mc_ped[7] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2349.545, 3267.5, 32.8, 0.0)
    mc_ped[8] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2350.0, 3268.0, 32.8, 0.0)
    mc_ped[9] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2342.2, 3243.5, 33.0, 330.0)
    
    -- Task peds to enter the first vehicle (Barracks3).
    for i = 1, 9 do
        -- Seat index i-2: for i=1, seat is -1 (driver); for i=2, seat is 0 (first passenger), etc.
        TASK.TASK_ENTER_VEHICLE(mc_ped[i], mc_vehicles[1], 190000, i - 2, 1.0, 1, 0, 0)
    end

    -- Create peds for the second vehicle (Crusader).
    mc_ped[10] = mission_utils.create_mission_ped("CSB_Ramp_marine", peds.PedType.PED_TYPE_ARMY, -2152.0, 3264.0, 32.8, 0.0)
    mc_ped[11] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2153.0, 3263.0, 32.8, 0.0)
    mc_ped[12] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2153.0, 3265.0, 32.8, 0.0)
    mc_ped[13] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2154.0, 3264.0, 32.8, 0.0)
    -- Task peds to enter the second vehicle.
    for i = 1, 4 do
        TASK.TASK_ENTER_VEHICLE(mc_ped[9+i], mc_vehicles[2], 190000, i - 2, 1.0, 1, 0, 0)
    end

    -- Create peds for the third vehicle (Crusader).
    mc_ped[14] = mission_utils.create_mission_ped("CSB_Ramp_marine", peds.PedType.PED_TYPE_ARMY, -2152.0, 3261.0, 32.8, 0.0)
    mc_ped[15] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2154.0, 3261.0, 32.8, 0.0)
    mc_ped[16] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2154.0, 3261.0, 32.8, 0.0)
    mc_ped[17] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2151.0, 3263.0, 32.8, 0.0)
    -- Task peds to enter the third vehicle.
    for i = 1, 4 do
        TASK.TASK_ENTER_VEHICLE(mc_ped[13+i], mc_vehicles[3], 190000, i - 2, 1.0, 1, 0, 0)
    end

    -- Create peds for the fourth, fifth, and eighth vehicles (Rhino, Rhino, Terabyte).
    mc_ped[18] = mission_utils.create_mission_ped("S_M_M_Marine_01", peds.PedType.PED_TYPE_ARMY, -2353.10546875, 3261.1391601562, 32.81, 0.0)
    mc_ped[19] = mission_utils.create_mission_ped("S_M_M_Marine_01", peds.PedType.PED_TYPE_ARMY, -2352.3757324219, 3259.1569824219, 32.81, 0.0)
    mc_ped[20] = mission_utils.create_mission_ped("CSB_Ramp_marine", peds.PedType.PED_TYPE_ARMY, -2351.1872558594, 3257.3666992188, 32.81, 0.0)

    TASK.TASK_ENTER_VEHICLE(mc_ped[18], mc_vehicles[4], 190000, -1, 1.0, 1, 0, 0) -- Driver for Rhino 1
    TASK.TASK_ENTER_VEHICLE(mc_ped[19], mc_vehicles[5], 190000, -1, 1.0, 1, 0, 0) -- Driver for Rhino 2
    TASK.TASK_ENTER_VEHICLE(mc_ped[20], mc_vehicles[8], 190000, -1, 1.0, 1, 0, 0) -- Driver for Terabyte

    -- Create peds for the sixth vehicle (Barrage).
    mc_ped[21] = mission_utils.create_mission_ped("CSB_Ramp_marine", peds.PedType.PED_TYPE_ARMY, -2153.5, 3261.0, 32.8, 0.0)
    mc_ped[22] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2153.0, 3263.5, 32.8, 0.0)
    mc_ped[23] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2150.0, 3261.0, 32.8, 0.0)
    mc_ped[24] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2150.0, 3264.5, 32.8, 0.0)
    -- Task peds to enter the sixth vehicle.
    for i = 1, 4 do
        TASK.TASK_ENTER_VEHICLE(mc_ped[20+i], mc_vehicles[6], 190000, i - 2, 1.0, 1, 0, 0)
    end

    -- Create peds for the seventh vehicle (Barrage).
    mc_ped[25] = mission_utils.create_mission_ped("CSB_Ramp_marine", peds.PedType.PED_TYPE_ARMY, -2153.5, 3262.5, 32.8, 0.0)
    mc_ped[26] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2153.5, 3260.5, 32.8, 0.0)
    mc_ped[27] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2150.0, 3264.0, 32.8, 0.0)
    mc_ped[28] = mission_utils.create_mission_ped("S_M_Y_Marine_03", peds.PedType.PED_TYPE_ARMY, -2155.5, 3264.0, 32.8, 0.0)
    -- Task peds to enter the seventh vehicle.
    for i = 1, 4 do
        TASK.TASK_ENTER_VEHICLE(mc_ped[24+i], mc_vehicles[7], 190000, i - 2, 1.0, 1, 0, 0)
    end

    -- Give weapons and set accuracy for all convoy peds.
    for i = 1, #mc_ped do
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(mc_ped[i], weapons.weapon.WEAPON_MILITARYRIFLE, 1000, true)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(mc_ped[i], weapons.weapon.WEAPON_PISTOL_MK2, 1000, true)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(mc_ped[i], weapons.weapon.WEAPON_SMOKEGRENADE, 1000, true)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(mc_ped[i], weapons.weapon.WEAPON_GRENADE, 1000, true)
        WEAPON.SET_CURRENT_PED_WEAPON(mc_ped[i], weapons.weapon.WEAPON_MILITARYRIFLE, true)
        PED.SET_PED_ACCURACY(mc_ped[i], 100) -- Set peds to be highly accurate.
    end

    -- Set all peds to be members of the same group for coordinated behavior.
    local first_ped_group = PED.GET_PED_GROUP_INDEX(mc_ped[1])
    for i = 1, #mc_ped do
        PED.SET_PED_AS_GROUP_MEMBER(mc_ped[i], first_ped_group)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(mc_ped[i], true) -- Prevent peds from reacting to random events.
    end

    Wait(5) -- Small delay.

    mc_timeout = 0
    mc_activity_started = true -- Mark activity as started.
    printColoured("green", "Military Convoy activity initialized.")
end

--- Ends the Military Convoy activity, cleaning up all spawned entities.
-- @param status boolean True if the mission was completed successfully, false otherwise.
function end_mc_activity(status)
    -- Remove the blip from the main convoy vehicle.
    local blip_handle = HUD.GET_BLIP_FROM_ENTITY(main_convoy_vehicle)
    if HUD.DOES_BLIP_EXIST(blip_handle) then
        HUD.REMOVE_BLIP(blip_handle)
    end 

    -- Clean up all spawned vehicles.
    for i = 1, #mc_vehicles do
        if mc_vehicles[i] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_vehicles[i]) then
            network_utils.request_control_of(mc_vehicles[i]) -- Request control before deleting.
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(mc_vehicles[i], false, true) -- Mark as non-mission entity for cleanup.
            -- Using DeleteVehicle directly if available, otherwise just mark as no longer needed.
            DeleteVehicle(mc_vehicles[i])
            if ENTITY.DOES_ENTITY_EXIST(mc_vehicles[i]) then
                ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(mc_vehicles[i])
            end
        end
    end

    -- Clean up all spawned peds.
    for i = 1, #mc_ped do
        if mc_ped[i] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[i]) then
            network_utils.request_control_of(mc_ped[i]) -- Request control before deleting.
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(mc_ped[i], false, true) -- Mark as non-mission entity for cleanup.
            -- Using DeletePed directly if available, otherwise just mark as no longer needed.
            DeletePed(mc_ped[i])
            if ENTITY.DOES_ENTITY_EXIST(mc_ped[i]) then
                ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(mc_ped[i])
            end
        end
    end

    -- Reset all activity state variables.
    mc_ped = {}
    mc_drivers = {}
    mc_vehicles = {}
    main_convoy_vehicle = nil
    reinforcements_veh_start_index = nil
    reinforcements_ped_start_index = nil
    mc_convoy_is_moving = false
    reinforcements_ready = false
    reinforcements_on_way = false
    already_respawned_near_army_base = false
    mc_activity_started = false

    SetGlobalVariableValue("MilitaryConvoyActivityState", 0.0) -- Update global state to inactive.

    if status then
---@diagnostic disable-next-line: undefined-global
        ShowMessage("Mission completed successfully!") -- Display success message.
        print("The mission has been successfully completed.")
    else
---@diagnostic disable-next-line: undefined-global
        ShowMessage("Mission failed!") -- Display failure message.
        print("Mission failed.")
    end
end

--- Ensures all peds are seated in their designated vehicles.
-- This function is called to re-seat peds who might have exited their vehicles.
function make_all_peds_seat()
    -- Re-seat peds in Barracks3 (mc_vehicles[1]).
    for i = 1, 9 do
        if mc_ped[i] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[i]) then
            TASK.TASK_ENTER_VEHICLE(mc_ped[i], mc_vehicles[1], 190000, i - 2, 1.0, 1, 0, 0)
        end
    end

    -- Re-seat peds in Crusader 1 (mc_vehicles[2]).
    for i = 1, 4 do
        if mc_ped[9+i] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[9+i]) then
            TASK.TASK_ENTER_VEHICLE(mc_ped[9+i], mc_vehicles[2], 190000, i - 2, 1.0, 1, 0, 0)
        end
    end
    -- Re-seat peds in Crusader 2 (mc_vehicles[3]).
    for i = 1, 4 do
        if mc_ped[13+i] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[13+i]) then
            TASK.TASK_ENTER_VEHICLE(mc_ped[13+i], mc_vehicles[3], 190000, i - 2, 1.0, 1, 0, 0)
        end
    end

    -- Re-seat drivers for Rhino 1, Rhino 2, and Terabyte.
    if mc_ped[18] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[18]) then TASK.TASK_ENTER_VEHICLE(mc_ped[18], mc_vehicles[4], 190000, -1, 1.0, 1, 0, 0) end
    if mc_ped[19] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[19]) then TASK.TASK_ENTER_VEHICLE(mc_ped[19], mc_vehicles[5], 190000, -1, 1.0, 1, 0, 0) end
    if mc_ped[20] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[20]) then TASK.TASK_ENTER_VEHICLE(mc_ped[20], mc_vehicles[8], 190000, -1, 1.0, 1, 0, 0) end

    -- Re-seat peds in Barrage 1 (mc_vehicles[6]).
    for i = 1, 4 do
        if mc_ped[20+i] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[20+i]) then
            TASK.TASK_ENTER_VEHICLE(mc_ped[20+i], mc_vehicles[6], 190000, i - 2, 1.0, 1, 0, 0)
        end
    end
    -- Re-seat peds in Barrage 2 (mc_vehicles[7]).
    for i = 1, 4 do
        if mc_ped[24+i] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[24+i]) then
            TASK.TASK_ENTER_VEHICLE(mc_ped[24+i], mc_vehicles[7], 190000, i - 2, 1.0, 1, 0, 0)
        end
    end
end

--- Creates reinforcement vehicles and peds at a predefined location.
function create_reinforcements()
    -- Store the starting indices for reinforcements.
    reinforcements_veh_start_index = #mc_vehicles + 1
    reinforcements_ped_start_index = #mc_ped + 1

    -- Create reinforcement vehicles.
    mc_vehicles[reinforcements_veh_start_index] = mission_utils.create_mission_vehicle("apc", -1828.9190673828, -516.04241943359, 28.9, 285.0)
    mc_vehicles[reinforcements_veh_start_index+1] = mission_utils.create_mission_vehicle("halftrack", -1837.6166992188, -515.97180175781, 28.5, 290.0)
    mc_vehicles[reinforcements_veh_start_index+2] = mission_utils.create_mission_vehicle("apc", -1841.7521972656, -524.65478515625, 29.8, 340.0)
    mc_vehicles[reinforcements_veh_start_index+3] = mission_utils.create_mission_vehicle("halftrack", -1845.2630615234, -515.36199951172, 28.5, 315.0)
    mc_vehicles[reinforcements_veh_start_index+4] = mission_utils.create_mission_vehicle("rhino", -1851.3469238281, -510.86526489258, 27.9, 300.0)

    -- Create reinforcement peds.
    mc_ped[reinforcements_ped_start_index] = mission_utils.create_mission_ped("S_M_Y_BlackOps_01", peds.PedType.PED_TYPE_ARMY, -1828.5555419922, -514.02404785156, 28.9, 2.5)
    mc_ped[reinforcements_ped_start_index+1] = mission_utils.create_mission_ped("S_M_Y_BlackOps_01", peds.PedType.PED_TYPE_ARMY, -1844.9086914062, -524.63116455078, 29.5, 140.0)
    mc_ped[reinforcements_ped_start_index+2] = mission_utils.create_mission_ped("S_M_Y_BlackOps_02", peds.PedType.PED_TYPE_ARMY, -1851.6458740234, -507.38906860352, 27.5, 106.0)
    mc_ped[reinforcements_ped_start_index+3] = mission_utils.create_mission_ped("S_M_Y_BlackOps_03", peds.PedType.PED_TYPE_ARMY, -1853.9539794922, -508.90139770508, 27.5, 290.0)
    mc_ped[reinforcements_ped_start_index+4] = mission_utils.create_mission_ped("S_M_Y_BlackOps_03", peds.PedType.PED_TYPE_ARMY, -1833.7620849609, -519.28356933594, 29.0, 200.0)
    mc_ped[reinforcements_ped_start_index+5] = mission_utils.create_mission_ped("S_M_Y_BlackOps_03", peds.PedType.PED_TYPE_ARMY, -1832.3343505859, -520.33673095703, 29.0, 145.0)
    mc_ped[reinforcements_ped_start_index+6] = mission_utils.create_mission_ped("S_M_Y_BlackOps_03", peds.PedType.PED_TYPE_ARMY, -1834.7995605469, -511.01068115234, 28.5, 360.0)
    mc_ped[reinforcements_ped_start_index+7] = mission_utils.create_mission_ped("S_M_Y_BlackOps_03", peds.PedType.PED_TYPE_ARMY, -1836.9810791016, -510.52258300781, 28.5, 40.0)
    -- Create peds directly in vehicles (drivers for HalfTrack 1 and HalfTrack 2).
    mc_ped[reinforcements_ped_start_index+8] = mission_utils.create_mission_ped_in_vehicle(mc_vehicles[reinforcements_veh_start_index+1], -1, "S_M_Y_BlackOps_01", peds.PedType.PED_TYPE_ARMY, -1829.5555419922, -513.02404785156, 28.9, 2.5)
    mc_ped[reinforcements_ped_start_index+9] = mission_utils.create_mission_ped_in_vehicle(mc_vehicles[reinforcements_veh_start_index+3], -1, "S_M_Y_BlackOps_01", peds.PedType.PED_TYPE_ARMY, -1842.9086914062, -522.63116455078, 29.5, 140.0)

    -- Give weapons and set accuracy for reinforcement peds.
    for i = reinforcements_ped_start_index, #mc_ped do
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(mc_ped[i], weapons.weapon.WEAPON_CARBINERIFLE_MK2, 1000, true)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(mc_ped[i], weapons.weapon.WEAPON_APPISTOL, 1000, true)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(mc_ped[i], weapons.weapon.WEAPON_GRENADE, 1000, true)
        WEAPON.SET_CURRENT_PED_WEAPON(mc_ped[i], weapons.weapon.WEAPON_CARBINERIFLE_MK2, true)
        PED.SET_PED_ACCURACY(mc_ped[i], 100)
    end
    
    -- Task some reinforcement peds to perform scenarios (e.g., waiting).
    TASK.TASK_START_SCENARIO_IN_PLACE(mc_ped[reinforcements_ped_start_index], "WORLD_HUMAN_AA_COFFEE", 0, true)
    TASK.TASK_START_SCENARIO_IN_PLACE(mc_ped[reinforcements_ped_start_index+1], "WORLD_HUMAN_AA_COFFEE", 0, true)
    TASK.TASK_START_SCENARIO_IN_PLACE(mc_ped[reinforcements_ped_start_index+2], "WORLD_HUMAN_SMOKING_POT", 0, true)
    TASK.TASK_START_SCENARIO_IN_PLACE(mc_ped[reinforcements_ped_start_index+3], "WORLD_HUMAN_SMOKING_POT", 0, true)
    TASK.TASK_START_SCENARIO_IN_PLACE(mc_ped[reinforcements_ped_start_index+4], "WORLD_HUMAN_AA_COFFEE", 0, true)
    TASK.TASK_START_SCENARIO_IN_PLACE(mc_ped[reinforcements_ped_start_index+5], "WORLD_HUMAN_AA_COFFEE", 0, true)

    reinforcements_ready = true -- Mark reinforcements as ready.
    printColoured("green", "Reinforcements created and ready.")
end

--- Requests reinforcements to move towards the main convoy.
-- Tasks reinforcement peds to enter vehicles and drive to specific coordinates.
function request_reinforcements()
    -- Task reinforcement peds to enter their vehicles.
    TASK.TASK_ENTER_VEHICLE(mc_ped[reinforcements_ped_start_index], mc_vehicles[reinforcements_veh_start_index], 500, -1, 2.0, 1, 0, 0)
    TASK.TASK_ENTER_VEHICLE(mc_ped[reinforcements_ped_start_index+1], mc_vehicles[reinforcements_veh_start_index+2], 500, -1, 2.0, 1, 0, 0)
    TASK.TASK_ENTER_VEHICLE(mc_ped[reinforcements_ped_start_index+2], mc_vehicles[reinforcements_veh_start_index+4], 500, -1, 2.0, 1, 0, 0)

    for i = 2, 3 do -- Passengers for HalfTrack 1
        TASK.TASK_ENTER_VEHICLE(mc_ped[(reinforcements_ped_start_index+1) + i], mc_vehicles[reinforcements_veh_start_index+1], 500, i - 2, 2.0, 1, 0, 0)
    end
    
    for i = 2, 3 do -- Passengers for HalfTrack 2
        TASK.TASK_ENTER_VEHICLE(mc_ped[(reinforcements_ped_start_index+3) + i], mc_vehicles[reinforcements_veh_start_index+3], 500, i - 2, 2.0, 1, 0, 0)
    end

    TASK.TASK_ENTER_VEHICLE(mc_ped[reinforcements_ped_start_index+7], mc_vehicles[reinforcements_veh_start_index], 500, -1, 2.0, 1, 0, 0)

    Wait(500)

    -- Task reinforcement vehicles to drive to specific coordinates (rendezvous points).
    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[reinforcements_ped_start_index], PED.GET_VEHICLE_PED_IS_IN(mc_ped[reinforcements_ped_start_index], false), -1406.7188720703, -2443.9128417969, 14.0, 25.0, 271, 25.0)
    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[reinforcements_ped_start_index+1], PED.GET_VEHICLE_PED_IS_IN(mc_ped[reinforcements_ped_start_index+1], false), -1406.7188720703, -2449.9128417969, 14.0, 25.0, 271, 25.0)
    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[reinforcements_ped_start_index+2], PED.GET_VEHICLE_PED_IS_IN(mc_ped[reinforcements_ped_start_index+2], false), -1423.7188720703, -2449.9128417969, 14.0, 25.0, 271, 25.0)
    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[reinforcements_ped_start_index+8], PED.GET_VEHICLE_PED_IS_IN(mc_ped[reinforcements_ped_start_index+8], false), -1406.7188720703, -2455.9128417969, 14.0, 25.0, 271, 25.0)
    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[reinforcements_ped_start_index+9], PED.GET_VEHICLE_PED_IS_IN(mc_ped[reinforcements_ped_start_index+9], false), -1406.7188720703, -2462.9128417969, 14.0, 25.0, 271, 25.0)

    reinforcements_on_way = true -- Mark reinforcements as en route.
    printColoured("green", "Reinforcements dispatched.")
end

--- Respawns the convoy vehicles near the army base at new positions and headings.
-- This is likely a reset or repositioning mechanism.
function respawn_convoy_near_army_base()
    -- Reposition each convoy vehicle.
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mc_vehicles[1], -2578.4711914062, 3405.8054199219, 14.0, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mc_vehicles[1], 200.0)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mc_vehicles[2], -2576.6633300781, 3422.0734863281, 14.0, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mc_vehicles[2], 200.0)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mc_vehicles[3], -2595.5637207031, 3412.4396972656, 14.0, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mc_vehicles[3], 200.0)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mc_vehicles[4], -2579.689453125,3443.7888183594, 14.0, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mc_vehicles[4], 200.0)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mc_vehicles[5], -2603.4038085938, 3435.2810058594, 14.0, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mc_vehicles[5], 200.0)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mc_vehicles[8], -2616.8571777344, 3423.84765625, 17.5, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mc_vehicles[8], 250.0)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mc_vehicles[6], -2611.0341796875, 3442.1936035156, 15.0, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mc_vehicles[6], 240.0)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(mc_vehicles[7], -2557.6052246094, 3464.9541015625, 15.0, false, false, false)
    ENTITY.SET_ENTITY_HEADING(mc_vehicles[7], 160.0)

    already_respawned_near_army_base = true -- Mark as respawned to prevent repeated calls.

    -- Re-enable non-temporary events for peds (they were blocked at start).
    for i = 1, #mc_ped do
        if mc_ped[i] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[i]) then
            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(mc_ped[i], false)
        end
    end
    printColoured("green", "Convoy respawned near army base.")
end

--- Updates the state and behavior of the Military Convoy activity.
-- This is the main logic loop for the convoy's progression, including seating peds,
-- starting movement, handling mission objectives, and reacting to convoy status.
function update_mc_activity()
    if mc_activity_started then
        -- Logic to ensure peds are in their vehicles (drivers).
        -- If a driver is not in their vehicle, try to re-seat them.
        if not is_in_table(mc_drivers, mc_ped[1]) and PED.IS_PED_IN_ANY_VEHICLE(mc_ped[1], false) then
            -- If driver of first vehicle is in it, task passengers to enter.
            for i = 2, 9 do
                if mc_ped[i] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[i]) then
                    TASK.TASK_ENTER_VEHICLE(mc_ped[i], mc_vehicles[1], 190000, i - 2, 1.0, 1, 0, 0)
                end
            end
            table.insert(mc_drivers, mc_ped[1])
        end
        -- Repeat for other main convoy vehicles' drivers.
        if not is_in_table(mc_drivers, mc_ped[10]) and PED.IS_PED_IN_ANY_VEHICLE(mc_ped[10], false) then
            for i = 2, 4 do
                if mc_ped[9+i] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[9+i]) then
                    TASK.TASK_ENTER_VEHICLE(mc_ped[9+i], mc_vehicles[2], 190000, i - 2, 1.0, 1, 0, 0)
                end
            end
            table.insert(mc_drivers, mc_ped[10])
        end
        if not is_in_table(mc_drivers, mc_ped[14]) and PED.IS_PED_IN_ANY_VEHICLE(mc_ped[14], false) then
            for i = 2, 4 do
                if mc_ped[13+i] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[13+i]) then
                    TASK.TASK_ENTER_VEHICLE(mc_ped[13+i], mc_vehicles[3], 190000, i - 2, 1.0, 1, 0, 0)
                end
            end
            table.insert(mc_drivers, mc_ped[14])
        end
        if not is_in_table(mc_drivers, mc_ped[18]) and PED.IS_PED_IN_ANY_VEHICLE(mc_ped[18], false) then
            table.insert(mc_drivers, mc_ped[18])
        end
        if not is_in_table(mc_drivers, mc_ped[19]) and PED.IS_PED_IN_ANY_VEHICLE(mc_ped[19], false) then
            table.insert(mc_drivers, mc_ped[19])
        end
        if not is_in_table(mc_drivers, mc_ped[20]) and PED.IS_PED_IN_ANY_VEHICLE(mc_ped[20], false) then
            table.insert(mc_drivers, mc_ped[20])
        end
        if not is_in_table(mc_drivers, mc_ped[21]) and PED.IS_PED_IN_ANY_VEHICLE(mc_ped[21], false) then
            for i = 2, 4 do
                if mc_ped[20+i] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[20+i]) then
                    TASK.TASK_ENTER_VEHICLE(mc_ped[20+i], mc_vehicles[6], 190000, i - 2, 1.0, 1, 0, 0)
                end
            end
            table.insert(mc_drivers, mc_ped[21])
        end
        if not is_in_table(mc_drivers, mc_ped[25]) and PED.IS_PED_IN_ANY_VEHICLE(mc_ped[25], false) then
            for i = 2, 4 do
                if mc_ped[24+i] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[24+i]) then
                    TASK.TASK_ENTER_VEHICLE(mc_ped[24+i], mc_vehicles[7], 190000, i - 2, 1.0, 1, 0, 0)
                end
            end
            table.insert(mc_drivers, mc_ped[25])
        end
        
        -- Start convoy movement once all initial drivers are in their vehicles.
        if not mc_convoy_is_moving and #mc_drivers >= mc_drivers_count then
            -- Additional check for specific peds being in vehicles.
            if PED.IS_PED_IN_ANY_VEHICLE(mc_ped[9], false) == 0.0 or PED.IS_PED_IN_ANY_VEHICLE(mc_ped[2], false) == 0.0 then
                return nil -- Wait until these specific peds are in vehicles.
            end

            make_all_peds_seat() -- Ensure all peds are seated.
            respawn_convoy_near_army_base() -- Reposition convoy near army base for the start of the route.
            
            -- Task all convoy drivers to drive to their initial long-range coordinates.
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[1], PED.GET_VEHICLE_PED_IS_IN(mc_ped[1], false), -1363.6254882812, -2430.97265625, 13.94619846344, 15.0, 271, 25.0)
            Wait(500)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[10], PED.GET_VEHICLE_PED_IS_IN(mc_ped[10], false), -1373.7124023438, -2428.8376464844, 13.949308395386, 13.0, 271, 25.0)
            Wait(500)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[14], PED.GET_VEHICLE_PED_IS_IN(mc_ped[14], false), -1374.0899658203, -2450.9594726562, 13.945671081543, 15.0, 271, 25.0)
            Wait(500)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[18], PED.GET_VEHICLE_PED_IS_IN(mc_ped[18], false), -1326.5135498047, -2423.5234375, 13.945148468018, 15.0, 271, 25.0)
            Wait(500)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[19], PED.GET_VEHICLE_PED_IS_IN(mc_ped[19], false), -1317.78515625, -2410.8020019531, 13.945151329041, 15.0, 271, 25.0)
            Wait(500)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[20], PED.GET_VEHICLE_PED_IS_IN(mc_ped[20], false), -1348.6295166016, -2440.5349121094, 13.945145606995, 15.0, 271, 25.0)
            Wait(500)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[21], PED.GET_VEHICLE_PED_IS_IN(mc_ped[21], false), -1249.2175292969, -2423.9575195312, 13.94514465332, 15.0, 271, 25.0)
            Wait(500)
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[25], PED.GET_VEHICLE_PED_IS_IN(mc_ped[25], false), -1251.0859375, -2436.2224121094, 13.945145606995, 15.0, 271, 25.0)

            -- Add a blip to the main convoy vehicle.
            local blip_handle = HUD.ADD_BLIP_FOR_ENTITY(main_convoy_vehicle)
            HUD.SET_BLIP_AS_FRIENDLY(blip_handle, true)
            HUD.SET_BLIP_SPRITE(blip_handle, 632) -- Military convoy blip sprite.
            HUD.SET_BLIP_COLOUR(blip_handle, 66) -- Green color.
            HUD.SET_BLIP_DISPLAY(blip_handle, 6) -- Display on both maps.

            mc_convoy_is_moving = true -- Mark convoy as moving.
            printColoured("green", "Convoy has started its route.")
            Wait(5000) -- Wait after starting movement.
        end

        -- Check mission objectives and conditions.
        if mc_convoy_is_moving then
            -- Mission failure: Main vehicle is dead.
            if ENTITY.IS_ENTITY_DEAD(main_convoy_vehicle, false) then
                end_mc_activity(false) -- End activity with failure.
            -- Mission success: Main vehicle reached "AirP" zone.
            elseif ENTITY.IS_ENTITY_IN_ZONE(main_convoy_vehicle, "AirP") then
                end_mc_activity(true) -- End activity with success.
            -- Reinforcements creation: Main vehicle reached "PBLUF" zone and reinforcements not ready.
            elseif ENTITY.IS_ENTITY_IN_ZONE(main_convoy_vehicle, "PBLUF") and not reinforcements_ready then
                create_reinforcements()
            -- Reinforcements dispatch: Main vehicle reached "DELPE" zone and reinforcements not en route.
            elseif ENTITY.IS_ENTITY_IN_ZONE(main_convoy_vehicle, "DELPE") and not reinforcements_on_way then
                request_reinforcements()
            -- Convoy respawn near army base: Main vehicle reached "ARMYB" zone and not yet respawned.
            elseif ENTITY.IS_ENTITY_IN_ZONE(main_convoy_vehicle, "ARMYB") and not already_respawned_near_army_base then
                respawn_convoy_near_army_base()
            else
                -- Re-task convoy drivers if they somehow stop or deviate.
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[1], PED.GET_VEHICLE_PED_IS_IN(mc_ped[1], false), -1363.6254882812, -2430.97265625, 13.94619846344, 15.0, 271, 25.0)
                Wait(500)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[10], PED.GET_VEHICLE_PED_IS_IN(mc_ped[10], false), -1373.7124023438, -2428.8376464844, 13.949308395386, 15.0, 271, 25.0)
                Wait(500)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[14], PED.GET_VEHICLE_PED_IS_IN(mc_ped[14], false), -1374.0899658203, -2450.9594726562, 13.945671081543, 15.0, 271, 25.0)
                Wait(500)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[18], PED.GET_VEHICLE_PED_IS_IN(mc_ped[18], false), -1326.5135498047, -2423.5234375, 13.945148468018, 15.0, 271, 25.0)
                Wait(500)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[19], PED.GET_VEHICLE_PED_IS_IN(mc_ped[19], false), -1317.78515625, -2410.8020019531, 13.945151329041, 15.0, 271, 25.0)
                Wait(500)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[20], PED.GET_VEHICLE_PED_IS_IN(mc_ped[20], false), -1348.6295166016, -2440.5349121094, 13.945145606995, 15.0, 271, 25.0)
                Wait(500)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[21], PED.GET_VEHICLE_PED_IS_IN(mc_ped[21], false), -1249.2175292969, -2423.9575195312, 13.94514465332, 15.0, 271, 25.0)
                Wait(500)
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[25], PED.GET_VEHICLE_PED_IS_IN(mc_ped[25], false), -1251.0859375, -2436.2224121094, 13.945145606995, 15.0, 271, 25.0)
                
                -- Logic to replace dead/missing drivers in main_convoy_vehicle and mc_vehicles[1].
                if VEHICLE.GET_PED_IN_VEHICLE_SEAT(main_convoy_vehicle, -1 , false) == 0.0 then -- If main vehicle driver seat is empty
                    local random_ped_index
                    -- Loop until a living, existing ped is found to be the new driver.
                    repeat
                        random_ped_index = math.random(1, #mc_ped)
                    until mc_ped[random_ped_index] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[random_ped_index]) and not ENTITY.IS_ENTITY_DEAD(mc_ped[random_ped_index], false)
                    
                    if mc_ped[random_ped_index] ~= 0.0 then
                        TASK.TASK_ENTER_VEHICLE(mc_ped[random_ped_index], main_convoy_vehicle, 1000, -1, 2.0, 1, 0, 0)
                        Wait(1000)
                        TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[random_ped_index], PED.GET_VEHICLE_PED_IS_IN(mc_ped[random_ped_index], false), -1348.6295166016, -2440.5349121094, 13.945145606995, 50.0, 271, 25.0)
                    end
                end 

                if mc_vehicles[1] ~= 0.0 and not ENTITY.IS_ENTITY_DEAD(mc_vehicles[1], false) and VEHICLE.GET_PED_IN_VEHICLE_SEAT(mc_vehicles[1], -1 , false) == 0.0 then -- If first convoy vehicle driver seat is empty and vehicle is not dead
                    -- This loop seems to be trying to re-seat passengers into vehicle 1.
                    for i = 3, 9 do
                        if mc_ped[i] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[i]) then
                            TASK.TASK_ENTER_VEHICLE(mc_ped[i], mc_vehicles[1], 10000, i - 2, 2.0, 1, 0, 0)
                        end
                    end

                    if mc_ped[1] ~= 0.0 and ENTITY.IS_ENTITY_DEAD(mc_ped[1], false) then -- If the original driver (mc_ped[1]) is dead
                        local random_ped_index
                        -- Loop until a living, existing ped is found to be the new driver.
                        repeat
                            random_ped_index = math.random(1, #mc_ped)
                        until mc_ped[random_ped_index] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[random_ped_index]) and not ENTITY.IS_ENTITY_DEAD(mc_ped[random_ped_index], false)
                        
                        if mc_ped[random_ped_index] ~= 0.0 then
                            TASK.TASK_ENTER_VEHICLE(mc_ped[random_ped_index], mc_vehicles[1], 1000, -1, 2.0, 1, 0, 0) -- Put a random living ped as driver
                        end
                    else
                        -- Otherwise, if original driver is not dead, try to put them back (if they somehow exited).
                        if mc_ped[1] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[1]) then
                            TASK.TASK_ENTER_VEHICLE(mc_ped[1], mc_vehicles[1], 1000, -1, 2.0, 1, 0, 0)
                        end
                    end
                    Wait(1000)
                    -- Re-task the driver of the first vehicle.
                    if mc_ped[1] ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(mc_ped[1]) then
                        TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(mc_ped[1], PED.GET_VEHICLE_PED_IS_IN(mc_ped[1], false), -1363.6254882812, -2430.97265625, 13.94619846344, 40.0, 271, 25.0)
                    end
                end 
            end 
        end
    end
end

-- Define reset points for convoy (commented out in original, kept for context).
-- reset point1  -2505.8774414062 y = 3596.7341308594 z = 14.447336196899
-- reset point2  -2727.5102539062, 2310.0847167969, 18.07469367981
-- reset point3  -1783.8172607422 y = -312.63812255859 z = 43.619632720947

local main_loop_wait_time = 1000 -- Default wait time for the main script loop.

-- Main script loop.
-- This loop continuously checks the state of various activities and updates them.
while ScriptStillWorking do
    -- This block for "TestActivitieState" is empty in the original and serves no purpose.
    -- It is kept commented out for fidelity to original structure, but could be removed.
    -- if IsGlobalVariableExist("TestActivitieState") then
    --     -- No logic here.
    -- end

    -- Check and manage "Military Convoy" activity state.
    if IsGlobalVariableExist("MilitaryConvoyActivityState") then
        local current_mc_state = GetGlobalVariable("MilitaryConvoyActivityState")
        
        if current_mc_state == 1.0 and not mc_activity_started then
            start_mc_activity() -- Start the activity if global state is active and not yet started.
        elseif current_mc_state == 0.0 and mc_activity_started then
            end_mc_activity(false) -- End the activity if global state is inactive and it was started.
        end

        -- Always update the activity if the global variable exists (regardless of its 0.0/1.0 value).
        -- This allows the update function to handle transitions and ongoing logic.
        update_mc_activity()

        main_loop_wait_time = 50 -- Reduce wait time when the convoy activity is being managed.
    else
        main_loop_wait_time = 1000 -- Default wait time if no activity global variable exists.
    end
    Wait(main_loop_wait_time) -- Pause script execution.
end

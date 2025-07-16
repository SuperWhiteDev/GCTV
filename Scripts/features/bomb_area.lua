
local bcActive = true -- Controls the overall activity state of the bomb area script.
local bcInitialized = false -- Tracks if the bomb area setup (Avenger and pilot) has been completed.
local targetCoords = nil -- Stores the coordinates for the bombing target area.

local avangerModelHash = nil -- Stores the model hash for the Avenger aircraft.
local pilotModelHash = nil -- Stores the model hash for the pilot ped.
local avanger = nil -- Stores the entity handle of the created Avenger.
local pilot = nil -- Stores the entity handle of the created pilot ped.

local bombs = { } -- Table to hold the handles of active bombs.
local bombscount = 40 -- The total number of bombs to be dropped.

local iters = 0 -- General-purpose counter for loops, especially for model loading timeouts.

local network_utils = require("network_utils") -- Utility module for network-related operations.
local entity_utils = require("entity_utils") -- Utility module for entity-related operations.

--- Initializes the bomb area script components: creates the Avenger and its pilot, and sets their initial tasks.
function InitBC()
    iters = 0 -- Reset iteration counter for model loading.

    -- Load the Avenger model.
    avangerModelHash = MISC.GET_HASH_KEY("avenger3")
    
    if STREAMING.IS_MODEL_VALID(avangerModelHash) then
        STREAMING.REQUEST_MODEL(avangerModelHash)
        while not STREAMING.HAS_MODEL_LOADED(avangerModelHash) do
            if iters > 50 then
                DisplayError(false, "Failed to load the avenger model within timeout.")
                return nil -- Indicate failure to initialize.
            end
            Wait(5)
            iters = iters + 1
        end
    else
        DisplayError(false, "Invalid avenger model hash.")
        return nil -- Indicate failure to initialize.
    end

    -- Create the Avenger vehicle. Coordinates are offset relative to targetCoords.
    avanger = VEHICLE.CREATE_VEHICLE(avangerModelHash, targetCoords.x + 3.5, targetCoords.y + 130.0, targetCoords.z + 80.0, 180.0, false, false, false)
    network_utils.register_as_network(avanger) -- Ensure the vehicle is networked.

    VEHICLE.OPEN_BOMB_BAY_DOORS(avanger) -- Open bomb bay doors for dropping.
    VEHICLE.CONTROL_LANDING_GEAR(avanger, 3) -- Retract landing gear.

    -- Load the pilot model.
    pilotModelHash = MISC.GET_HASH_KEY("S_M_Y_Pilot_01")
    iters = 0 -- Reset iteration counter for pilot model loading.
    if STREAMING.IS_MODEL_VALID(pilotModelHash) then
        STREAMING.REQUEST_MODEL(pilotModelHash)
        while not STREAMING.HAS_MODEL_LOADED(pilotModelHash) do
            if iters > 50 then
                DisplayError(false, "Failed to load the pilot model within timeout.")
                return nil -- Indicate failure to initialize.
            end
            Wait(5)
            iters = iters + 1
        end
    else
        DisplayError(false, "Invalid pilot model hash.")
        return nil -- Indicate failure to initialize.
    end
    iters = 0 -- Reset iteration counter for general use.

    -- Create the pilot ped.
    pilot = PED.CREATE_PED(1, pilotModelHash, targetCoords.x + 3.5, targetCoords.y + 100.0, targetCoords.z + 80.0, 0.0, false, true)
    network_utils.register_as_network(pilot) -- Ensure the pilot is networked.

    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(pilot, true) -- Prevent pilot from reacting to external events.
    PED.SET_PED_INTO_VEHICLE(pilot, avanger, -1) -- Place pilot into the Avenger.
    VEHICLE.SET_HELI_BLADES_SPEED(avanger, 1.0) -- Start Avenger blades (if applicable, for air vehicles).

    -- Task the pilot to fly the Avenger to the target area.
    TASK.TASK_PLANE_GOTO_PRECISE_VTOL(pilot, avanger, targetCoords.x, targetCoords.y, targetCoords.z+80.0, 10.0, 5.0, false, 0.0, true)

    bcInitialized = true -- Mark initialization as complete.
end

--- De-initializes the bomb area script: sends the Avenger away and cleans up resources.
function DeInitBC()
    if avanger and pilot then
        local avangerPosition = ENTITY.GET_ENTITY_COORDS(avanger, true)

        -- Task the Avenger to fly far away.
        TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(pilot, avanger, avangerPosition.x+8500, avangerPosition.y+5000, avangerPosition.z, 100.0, 262204, 25.0)
        
        Wait(1000) -- Wait for a moment to allow the task to begin.

        VEHICLE.CLOSE_BOMB_BAY_DOORS(avanger) -- Close bomb bay doors.
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(pilot, false) -- Allow pilot to react to events again.
    end

    -- Release model assets.
    if avangerModelHash then STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(avangerModelHash) end
    if pilotModelHash then STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pilotModelHash) end

    bcActive = false -- Deactivate the script.
    bcInitialized = false -- Reset initialization state.

    -- Nullify entity handles to prevent memory leaks and ensure proper cleanup.
    avanger = nil
    pilot = nil

    -- Clean up any remaining bombs in the `bombs` table if DeInitBC is called prematurely.
    -- This ensures that resources associated with these objects are properly released.
    for i = #bombs, 1, -1 do
        local bomb = bombs[i]
        if ENTITY.DOES_ENTITY_EXIST(bomb) then
            DeleteObject(bomb)
        end
        table.remove(bombs, i)
    end
end

--- Main loop tick function for bomb area operations.
function OnTick()
    -- Check if the Avenger is within the bombing range.
    if avanger and entity_utils.is_entity_at_coords(avanger, targetCoords.x, targetCoords.y, targetCoords.z+80.0, 20.0) then
        -- Load bomb model.
        iters = 0
        local hash = MISC.GET_HASH_KEY("w_smug_bomb_04")
        if STREAMING.IS_MODEL_VALID(hash) then
            STREAMING.REQUEST_MODEL(hash)
            while not STREAMING.HAS_MODEL_LOADED(hash) do
                if iters > 50 then
                    DisplayError(false, "Failed to load the bomb model within timeout.")
                    return nil -- Indicate failure.
                end
                Wait(5)
                iters = iters + 1
            end
        else
            DisplayError(false, "Invalid bomb model hash.")
            return nil -- Indicate failure.
        end

        bombs = { } -- Clear previous bombs, ensuring a fresh drop.

        -- Drop bombs sequentially.
        for i = 1, bombscount, 1 do
            local avangerPosition = ENTITY.GET_ENTITY_COORDS(avanger, true)
            local offsetX = math.random() * 2 - 1 -- Random offset between -1 and 1
            local offsetY = math.random() * 2 - 1 -- Random offset between -1 and 1

            local bomb = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, avangerPosition.x+offsetX, avangerPosition.y+offsetY, avangerPosition.z-3.5, false, false, true, 0)
            if bomb ~= 0.0 then -- Check if bomb creation was successful.
                network_utils.register_as_network(bomb) -- Network the bomb.

                local forward = ENTITY.GET_ENTITY_FORWARD_VECTOR(avanger)
                -- Apply initial velocity to the bomb to simulate being dropped from a moving plane.
                ENTITY.SET_ENTITY_VELOCITY(bomb, forward.x * 10.0, forward.y * 1.0, forward.z * 1.0)
                ENTITY.SET_ENTITY_ROTATION(bomb, 30.0, 50.0, 0.0, 2, true) -- Set an initial rotation for visual effect.

                bombs[i] = bomb -- Add bomb to tracking table.
            end
            Wait(5) -- Small delay between bomb drops.
        end
    
        iters = 0 -- Reset iteration counter for bomb cleanup phase.
        -- Wait for bombs to hit the ground and then detonate/cleanup.
        while #bombs > 0 and iters < 700 do -- Timeout to prevent infinite loop.
            for i = #bombs, 1, -1 do -- Iterate backwards to safely remove elements.
                local bomb = bombs[i]
                -- Check if the bomb exists and is no longer in the air.
                if ENTITY.DOES_ENTITY_EXIST(bomb) and not ENTITY.IS_ENTITY_IN_AIR(bomb) then
                    local coords = ENTITY.GET_ENTITY_COORDS(bomb, true)

                    -- Create explosion and fire effects.
                    FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 1, 100.0, true, false, 1.0, false)
                    -- Spreading fire effects around the impact point.
                    FIRE.START_SCRIPT_FIRE(coords.x, coords.y, coords.z, 25, true)
                    FIRE.START_SCRIPT_FIRE(coords.x, coords.y+0.5, coords.z, 25, true)
                    FIRE.START_SCRIPT_FIRE(coords.x+0.5, coords.y+0.5, coords.z, 25, true)
                    FIRE.START_SCRIPT_FIRE(coords.x, coords.y+1.0, coords.z, 25, true)
                    FIRE.START_SCRIPT_FIRE(coords.x+1.0, coords.y, coords.z, 25, true)
                    FIRE.START_SCRIPT_FIRE(coords.x+1.0, coords.y+1.5, coords.z, 25, true)

                    table.remove(bombs, i) -- Remove bomb from tracking table.
                    DeleteObject(bomb) -- Delete the bomb entity.
                    -- STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash) -- This line will be discussed in feedback.

                    -- if ENTITY.DOES_ENTITY_EXIST(bomb) then -- This line will be discussed in feedback.
                    --     ENTITY.SET_ENTITY_COORDS_NO_OFFSET(bomb, -1000.0, 1000.0, 0.0, true, true, true)
                    --     DeleteObject(bomb)
                    -- end
                end
            end
            iters = iters + 1
            Wait(5)
        end
        -- After all bombs are dropped and processed, de-initialize the script.
        DeInitBC()
    elseif iters >= 1500 then -- Timeout if Avenger never reaches target or if bombing phase is too long.
        DeInitBC()
    end

    iters = iters + 1 -- Increment main script iteration counter.
end

-- Initialize target coordinates from a global variable.
-- Note: Global variable "BombAreaCoords" is expected to be a table with numerical indices.
local bomb_area_coords = GetGlobalVariable("BombAreaCoords")

if bomb_area_coords ~= nil then
    targetCoords = {x = bomb_area_coords[1], y = bomb_area_coords[2], z = bomb_area_coords[3]}
end

-- Main script loop.
while ScriptStillWorking and bcActive do
    if bcActive and not bcInitialized then 
        InitBC() -- Initialize if active and not yet initialized.
    end

    if bcActive then
        OnTick() -- Execute main logic if active.
    end

    Wait(10) -- Control script execution rate.
end
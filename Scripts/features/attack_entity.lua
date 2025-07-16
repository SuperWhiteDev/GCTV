local target = nil -- Stores the entity handle of the target to be attacked.
local aeActive = true -- Controls the overall activity state of the attack entity script.
local aeInitialized = false -- Tracks if the attack entity setup (bandits) has been completed.
local targetforward = nil -- Stores the forward vector of the target, used for ragdoll effect.
local isTargetOnGround = false -- Flag to check if the target has been knocked to the ground.
local iters = 0 -- General-purpose counter for loops and timeouts.

local pedModels = { "G_M_Y_StrPunk_02", "G_M_Y_MexGoon_03", "G_M_Y_SalvaGoon_01" } -- List of potential bandit ped models.
local banditsCount = 5 -- The number of bandits to spawn.

local banditWeapons = { "WEAPON_POOLCUE", "WEAPON_HAMMER", "WEAPON_BAT" } -- List of weapons for bandits.

local bandits = { } -- Table to hold the handles of spawned bandit peds.
local banditModels = { } -- Table to hold the model hashes of spawned bandit peds.

local networkUtils = require("network_utils") -- Utility module for network-related operations.

--- Initializes the attack entity script: spawns bandits, assigns them to a relationship group, and gives them weapons.
function InitAE()
    aeInitialized = true -- Mark initialization as complete early to prevent re-entry.

    local banditRelationshipGroup = MISC.GET_HASH_KEY("BANDIT_GROUP")    -- Unique relationship group for bandits.
    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(0, banditRelationshipGroup, banditRelationshipGroup)    -- Make bandits ignore each other.

    -- Loop to spawn each bandit.
    for i = 1, banditsCount, 1 do
        local hash = MISC.GET_HASH_KEY(pedModels[math.random(1, #pedModels)]) -- Select a random bandit model.

        iters = 0 -- Reset iteration counter for model loading.
        if STREAMING.IS_MODEL_VALID(hash) then
            STREAMING.REQUEST_MODEL(hash)
            while not STREAMING.HAS_MODEL_LOADED(hash) do
                if iters > 50 then
                    DisplayError(false, "Failed to load a bandit model within timeout.")
                    return nil -- Indicate initialization failure.
                end
                Wait(5)
                iters = iters + 1
            end
        else
            DisplayError(false, "Invalid bandit model hash generated.")
            return nil -- Indicate initialization failure.
        end
        iters = 0 -- Reset iteration counter for general use.

        local coords = ENTITY.GET_ENTITY_COORDS(target, true) -- Get target's coordinates.
        -- local heading = ENTITY.GET_ENTITY_HEADING(target) -- Not used.
        local forwardVector = ENTITY.GET_ENTITY_FORWARD_VECTOR(target) -- Get target's forward direction.
        
        -- Calculate spawn coordinates behind the target.
        local spawnX = coords.x - forwardVector.x * 6.0    
        local spawnY = coords.y - forwardVector.y * 6.0
        local spawnZ = coords.z -- Spawn at the same Z-level as the target.
        
        local bandit = PED.CREATE_PED(1, hash, spawnX, spawnY, spawnZ, 0.0, false, true) -- Create the bandit.
        networkUtils.register_as_network(bandit) -- Ensure the bandit is networked.

        PED.SET_PED_RELATIONSHIP_GROUP_HASH(bandit, banditRelationshipGroup) -- Assign bandit to its group.

        -- Give the bandit a random melee weapon.
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(bandit, MISC.GET_HASH_KEY(banditWeapons[math.random(1, #banditWeapons)]), 1000, true)

        table.insert(bandits, bandit) -- Add bandit to tracking table.
        table.insert(banditModels, hash) -- Store bandit model hash for later cleanup.
    end

    -- Task each bandit to combat the target.
    for i = 1, #bandits, 1 do
        TASK.TASK_COMBAT_PED(bandits[i], target, 0, 16)
        PED.SET_PED_KEEP_TASK(bandits[i], true) -- Ensure the task persists.
    end

    iters = 0 -- Reset iteration counter for the main loop.
    -- aeInitialized = true -- This line is redundant as it's set at the beginning of InitAE.
end

--- Ends the attack entity script: tasks bandits to leave and cleans up resources.
function EndAE()
    -- Task all bandits to go to a far-off coordinate, effectively despawning them.
    for i = 1, #bandits do
        if ENTITY.DOES_ENTITY_EXIST(bandits[i]) then
            TASK.TASK_GO_STRAIGHT_TO_COORD(bandits[i], 598.01196289062, -2116.3630371094, 5.752251625061, 20.0, 10000.0, 0.0, 0.0)
        else
            -- If bandit doesn't exist, remove from table immediately.
            table.remove(bandits, i)
        end
    end
    -- Release model assets.
    for i = 1, #banditModels, 1 do
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(banditModels[i])
    end

    bandits = { } -- Clear bandits table.
    banditModels = { } -- Clear bandit models table.
    targetforward = nil -- Clear target forward vector.

    aeActive = false -- Deactivate the script.
    aeInitialized = false -- Reset initialization state.
end

--- Main loop tick function for attack entity operations.
function OnTick()
    -- Check if the target no longer exists, is dead, or the script has timed out.
    if not ENTITY.DOES_ENTITY_EXIST(target) or ENTITY.IS_ENTITY_DEAD(target, true) or iters >= 70 then
        isTargetOnGround = false -- Reset state.
        EndAE() -- Terminate the script.
    end

    -- Check if the target has been damaged by any ped (including bandits).
    for i = 1, #bandits, 1 do -- Iterate through active bandits.
        -- It's more efficient to check for target damage once per tick, not per bandit.
        -- This logic implies that ANY damage sets the flag.
        if ENTITY.DOES_ENTITY_EXIST(target) and ENTITY.HAS_ENTITY_BEEN_DAMAGED_BY_ANY_PED(target) then
            targetforward = ENTITY.GET_ENTITY_FORWARD_VECTOR(target) -- Get current forward vector for ragdoll.
            isTargetOnGround = true -- Set flag.
            break -- No need to check other bandits if damage is detected.
        end
    end

    -- Apply ragdoll effect if target is on ground and within the iteration limit.
    if isTargetOnGround and iters < 90 then
        PED.SET_PED_TO_RAGDOLL_WITH_FALL(target, 1500, 2000, 1, targetforward.x, targetforward.y, targetforward.z-0.5, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        iters = iters + 1 -- Increment counter for ragdoll duration.
    end
    
    iters = iters + 1 -- Increment main script iteration counter.
end

-- Retrieve target entity from a global variable.
-- Note: "EntityAttackTarget" is expected to be a valid entity handle (number).
target = GetGlobalVariable("EntityAttackTarget")

-- Main script loop.
while ScriptStillWorking and aeActive do
    if aeActive and not aeInitialized then 
        InitAE() -- Initialize if active and not yet initialized.
    end

    if aeActive then
        OnTick() -- Execute main logic if active.
    end

    Wait(10) -- Control script execution rate.
end
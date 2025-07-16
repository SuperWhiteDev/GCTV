-- This utility script provides functions for creating and managing mission-specific
-- game entities (vehicles, peds) and cameras.

local mission_utils = {} -- Create a table to hold our utility functions.

-- Require necessary modules.
local network_utils = require("network_utils") -- For network registration of entities.

--- Creates a vehicle and registers it as a mission entity and network entity.
-- This function includes retry logic with slight coordinate adjustments if spawning fails.
-- Assumes `MISC`, `STREAMING`, `VEHICLE`, `ENTITY` are global objects from the GTAV API.
-- @param model string The model name (e.g., "ADDER", "BUZZARD").
-- @param x number The X-coordinate for spawning.
-- @param y number The Y-coordinate for spawning.
-- @param z number The Z-coordinate for spawning.
-- @param heading number The heading (rotation around Z-axis) for the vehicle.
-- @returns number The handle of the created vehicle, or nil if creation fails after retries.
function mission_utils.create_mission_vehicle(model, x, y, z, heading)
    local model_hash = MISC.GET_HASH_KEY(model)
    local max_attempts = 10 -- Define a maximum number of spawn attempts.
    local current_attempt = 0

    -- Check if the model is valid.
    if not STREAMING.IS_MODEL_VALID(model_hash) then
        DisplayError(false, "Invalid vehicle model: " .. model .. ".")
        return nil
    end

    -- Request and load the model if not already loaded.
    if not STREAMING.HAS_MODEL_LOADED(model_hash) then
        STREAMING.REQUEST_MODEL(model_hash)
        -- Wait for the model to load, with a timeout.
        local load_iters = 0
        while not STREAMING.HAS_MODEL_LOADED(model_hash) do
            Wait(5)
            load_iters = load_iters + 1
            if load_iters > 100 then -- Timeout after 500ms
                DisplayError(false, "Failed to load vehicle model: " .. model .. ".")
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash)
                return nil
            end
        end
    end

    local spawned_veh = 0.0
    while spawned_veh == 0.0 and current_attempt < max_attempts do
        -- Attempt to create the vehicle.
        spawned_veh = VEHICLE.CREATE_VEHICLE(model_hash, x, y, z, heading, false, false, false)
        
        if spawned_veh == 0.0 then
            -- If creation failed, slightly adjust coordinates for the next attempt.
            x = x + 0.15
            y = y + 0.15
            z = z + 0.05
            Wait(10) -- Small delay before retrying.
            current_attempt = current_attempt + 1
        end
    end

    -- If vehicle was successfully created after attempts.
    if spawned_veh ~= 0.0 then
        network_utils.register_as_network(spawned_veh) -- Register the vehicle with the network.
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(spawned_veh, true, true) -- Mark as mission entity.
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash) -- Release model.
        return spawned_veh
    else
        DisplayError(false, "Failed to create mission vehicle after " .. max_attempts .. " attempts: " .. model .. ".")
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash) -- Release model even on failure.
        return nil
    end
end

--- Creates a pedestrian (ped) and registers it as a mission entity and network entity.
-- This function includes retry logic with slight coordinate adjustments if spawning fails.
-- Assumes `MISC`, `STREAMING`, `PED`, `ENTITY` are global objects from the GTAV API.
-- @param model string The model name (e.g., "MP_M_FREEMODE_01", "A_M_M_FATLATINO_01").
-- @param ped_type number The ped type (e.g., 0 for CIVILIAN_PED).
-- @param x number The X-coordinate for spawning.
-- @param y number The Y-coordinate for spawning.
-- @param z number The Z-coordinate for spawning.
-- @param heading number The heading (rotation around Z-axis) for the ped.
-- @returns number The handle of the created ped, or nil if creation fails after retries.
function mission_utils.create_mission_ped(model, ped_type, x, y, z, heading)
    local model_hash = MISC.GET_HASH_KEY(model)
    local max_attempts = 10 -- Define a maximum number of spawn attempts.
    local current_attempt = 0

    -- Check if the model is valid.
    if not STREAMING.IS_MODEL_VALID(model_hash) then
        DisplayError(false, "Invalid ped model: " .. model .. ".")
        return nil
    end

    -- Request and load the model if not already loaded.
    if not STREAMING.HAS_MODEL_LOADED(model_hash) then
        STREAMING.REQUEST_MODEL(model_hash)
        -- Wait for the model to load, with a timeout.
        local load_iters = 0
        while not STREAMING.HAS_MODEL_LOADED(model_hash) do
            Wait(5)
            load_iters = load_iters + 1
            if load_iters > 100 then -- Timeout after 500ms
                DisplayError(false, "Failed to load ped model: " .. model .. ".")
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash)
                return nil
            end
        end
    end

    local spawned_ped = 0.0
    while spawned_ped == 0.0 and current_attempt < max_attempts do
        -- Attempt to create the ped.
        spawned_ped = PED.CREATE_PED(ped_type, model_hash, x, y, z, heading, false, true)
        
        if spawned_ped == 0.0 then
            -- If creation failed, slightly adjust coordinates for the next attempt.
            x = x + 0.01
            y = y + 0.01
            -- z is not adjusted in original Lua, maintaining that.
            Wait(10) -- Small delay before retrying.
            current_attempt = current_attempt + 1
        end
    end

    -- If ped was successfully created after attempts.
    if spawned_ped ~= 0.0 then
        network_utils.register_as_network(spawned_ped) -- Register the ped with the network.
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(spawned_ped, true, true) -- Mark as mission entity.
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash) -- Release model.
        return spawned_ped
    else
        DisplayError(false, "Failed to create mission ped after " .. max_attempts .. " attempts: " .. model .. ".")
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash) -- Release model even on failure.
        return nil
    end
end

--- Creates a mission ped and places them directly into a specified vehicle.
-- @param vehicle number The handle of the vehicle to place the ped into.
-- @param seat number The seat index in the vehicle (e.g., -1 for driver, 0 for passenger).
-- @param model string The ped model name.
-- @param ped_type number The ped type.
-- @param x number The X-coordinate for initial ped spawning (before entering vehicle).
-- @param y number The Y-coordinate for initial ped spawning.
-- @param z number The Z-coordinate for initial ped spawning.
-- @param heading number The heading for initial ped spawning.
-- @returns number The handle of the created ped, or nil if creation fails.
function mission_utils.create_mission_ped_in_vehicle(vehicle, seat, model, ped_type, x, y, z, heading)
    -- First, create the mission ped.
    local ped = mission_utils.create_mission_ped(model, ped_type, x, y, z, heading)

    -- If the ped was successfully created, place them into the vehicle.
    if ped then
        PED.SET_PED_INTO_VEHICLE(ped, vehicle, seat)
    end

    return ped -- Return the handle of the created ped.
end

--- Creates and activates a scripted camera at specified coordinates and rotation.
-- Assumes `CAM` is a global object from the GTAV API.
-- @param x number The X-coordinate for the camera position.
-- @param y number The Y-coordinate for the camera position.
-- @param z number The Z-coordinate for the camera position.
-- @param pitch number The pitch (X-rotation) of the camera.
-- @param roll number The roll (Y-rotation) of the camera.
-- @param yaw number The yaw (Z-rotation) of the camera.
-- @param transition_time number The time in milliseconds for the camera transition.
-- @returns number The handle of the created camera.
function mission_utils.create_camera(x, y, z, pitch, roll, yaw, transition_time)
    -- Create a default scripted camera.
    local cam = CAM.CREATE_CAM("DEFAULT_SCRIPTED_CAMERA", true)
    CAM.SET_CAM_COORD(cam, x, y, z) -- Set camera position.
    -- Set camera rotation. Note the order: pitch, roll, yaw (X, Y, Z).
    CAM.SET_CAM_ROT(cam, yaw, roll, pitch, 2) -- Order 2 is typically X, Y, Z.
    -- Render the script camera, with a transition.
    CAM.RENDER_SCRIPT_CAMS(true, true, transition_time, true, true, 0)

    return cam -- Return the camera handle.
end

--- Creates and activates a scripted "fly" camera.
-- This camera type often has different properties and rendering behavior.
-- Assumes `CAM` is a global object from the GTAV API.
-- @param x number The X-coordinate for the camera position.
-- @param y number The Y-coordinate for the camera position.
-- @param z number The Z-coordinate for the camera position.
-- @param pitch number The pitch (X-rotation) of the camera.
-- @param roll number The roll (Y-rotation) of the camera.
-- @param yaw number The yaw (Z-rotation) of the camera.
-- @param max_height number The maximum height the fly camera can reach.
-- @param transition_time number The time in milliseconds for the camera transition.
function mission_utils.create_fly_camera(x, y, z, pitch, roll, yaw, max_height, transition_time)
    -- Create a default scripted fly camera.
    local cam = CAM.CREATE_CAM("DEFAULT_SCRIPTED_FLY_CAMERA", true)
    CAM.SET_CAM_COORD(cam, x, y, z) -- Set camera position.
    -- Set camera rotation. Note the order: pitch, roll, yaw (X, Y, Z).
    CAM.SET_CAM_ROT(cam, yaw, roll, pitch, 2) -- Order 2 is typically X, Y, Z.
    CAM.SET_FLY_CAM_MAX_HEIGHT(cam, max_height) -- Set max height for fly camera.
    -- Render the script camera. Note the different last three parameters compared to CreateCamera.
    CAM.RENDER_SCRIPT_CAMS(true, true, transition_time, false, false, 0)
    
    return cam -- Return the camera handle (added for consistency, original didn't return).
end

--- Deletes a previously created camera and deactivates script cameras.
-- Assumes `CAM` is a global object from the GTAV API.
-- @param camera number The handle of the camera to destroy.
function mission_utils.delete_camera(camera)
    -- Deactivate all script cameras.
    CAM.RENDER_SCRIPT_CAMS(false, false, 0, true, true, 0)
    -- Destroy the specific camera.
    CAM.DESTROY_CAM(camera, false)
end

return mission_utils -- Return the utility table for use in other scripts.

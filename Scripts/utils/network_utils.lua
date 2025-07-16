-- This utility script provides functions for managing network control and registration
-- of game entities, ensuring they are properly synchronized across the network.

local network_utils = {} -- Create a table to hold our utility functions.

-- Require necessary modules.
local map_utils = require("map_utils")

--- Requests control of a specific entity on the network.
-- This is crucial in a multiplayer environment to ensure that local script changes
-- to an entity are synchronized and visible to other players.
-- The function retries the request multiple times until control is gained or attempts run out.
-- Assumes `NETWORK` is a global object from the GTAV API.
-- @param entity number The handle of the entity for which to request control.
function network_utils.request_control_of(entity)
    -- Attempt to request control.
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
    
    -- Loop to continuously request control until it's gained.
    -- The loop runs up to 50 times (original was 51, adjusted for common practice).
    for i = 1, 50 do -- It's common to loop 50 times with a small wait for network sync.
        if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
            break -- Exit loop if control is successfully gained.
        end
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity) -- Re-request control.
        Wait(1) -- Small delay to prevent spamming the network and allow time for response.
    end
end

--- Registers an entity on the network, making it visible and interactive for all players.
-- This involves marking it as networked, requesting control, and ensuring its network ID
-- exists on all machines.
-- Assumes `NETWORK` is a global object from the GTAV API and `Wait` is available.
-- @param entity number The handle of the entity to register as networked.
function network_utils.register_as_network(entity)
    -- Mark the entity as networked. This is the first step to making it multiplayer-aware.
    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(entity)
    Wait(1) -- Small delay after registration to allow the network to process.
    
    -- Request control of the entity to ensure the local client can manipulate it.
    network_utils.request_control_of(entity)
    
    -- Get the network ID associated with the entity.
    local net_id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
    
    -- Ensure the network ID exists on all machines, making the entity fully synchronized.
    -- The second parameter '1' typically means 'true' or 'force'.
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, 1)
end
--- Creates a networked vehicle with a given model and coordinates, and optionally adds a blip.
-- and `map_utils` is available.
-- @param model number The model hash of the vehicle to create.
-- @param coords table A table with 'x', 'y', 'z' coordinates for spawning.
-- @param heading number The heading (rotation around Z-axis) for the vehicle.
-- @param blip_info table|nil An optional table containing blip customization:
--                            `sprite` (number), `modifier` (number), `scale` (number), `name` (string).
-- @returns number|nil The handle of the created vehicle, or nil if creation fails.
function network_utils.create_net_vehicle(model, coords, heading, blip_info)
    -- Check if the model is valid and in CDImage (on disk).
    if STREAMING.IS_MODEL_IN_CDIMAGE(model) and STREAMING.IS_MODEL_VALID(model) then
        STREAMING.REQUEST_MODEL(model, true) -- Request the model, true for `p2` (load as network model).
        local iters = 0
        -- Wait for the model to load.
        while not STREAMING.HAS_MODEL_LOADED(model) do
            if iters > 50 then -- Timeout after 50 attempts (5 seconds with Wait(100)).
                DisplayError(false, "Failed to load model " .. model)
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model)
                return nil
            end
            Wait(100) -- Wait 100ms
            iters = iters + 1
        end

        -- Create the vehicle.
        local veh = VEHICLE.CREATE_VEHICLE(model, coords.x, coords.y, coords.z, heading, false, false, false)
        
        -- Check if vehicle was successfully created and exists.
        if veh ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(veh) then
            network_utils.register_as_network(veh) -- Register the vehicle on the network.

            VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh, 5.0) -- Ensure vehicle is properly placed on ground.
            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false) -- Turn engine on.
            VEHICLE.SET_VEHICLE_IS_WANTED(veh, false) -- Ensure vehicle is not wanted.
            
            -- Add blip if blip_info is provided.
            if blip_info ~= nil and type(blip_info) == "table" then
                local blip_sprite = map_utils.get_blip_from_entity_model(model) -- Get default blip sprite.
                if blip_info.sprite then
                    blip_sprite = blip_info.sprite -- Override with custom sprite if provided.
                end

                local blip = HUD.ADD_BLIP_FOR_ENTITY(veh) -- Add blip for the vehicle.
                HUD.SET_BLIP_SPRITE(blip, blip_sprite) -- Set blip sprite.

                if blip_info.modifier then
                    HUD.BLIP_ADD_MODIFIER(blip, blip_info.modifier) -- Add blip modifier.
                end

                if blip_info.scale ~= nil then
                    HUD.SET_BLIP_SCALE(blip, blip_info.scale) -- Set blip scale.
                end

                if blip_info.name then
                    HUD._SET_BLIP_NAME(blip, blip_info.name) -- Set blip name.
                end
            end

            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model) -- Release model.
            return veh -- Return the handle of the created vehicle.
        else
            DisplayError(false, "Failed to create vehicle entity for model " .. model)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model)
            return nil
        end
    else
        DisplayError(false, "Not valid model or model not in CDImage: " .. model)
    end
    return nil
end

--- Deletes a networked vehicle.
-- This function requests control of the vehicle and then deletes it.
-- Assumes `ENTITY`, `VEHICLE` are global objects from the GTAV API.
-- Note: `Game.NewVehicle` and `Game.Delete` are not standard Lua GTA V API calls
-- and are typically used for specific memory management or custom object wrappers.
-- In standard Lua scripting for GTA V, `VEHICLE.DELETE_VEHICLE` directly takes the entity handle.
-- I'm keeping the original calls for fidelity, but they might be redundant/incorrect
-- depending on your `Game` library implementation.
-- @param veh number The handle of the vehicle to delete.
function network_utils.delete_net_vehicle(veh)
    if not ENTITY.DOES_ENTITY_EXIST(veh) then
        DisplayError(false, "Attempted to delete non-existent vehicle handle: " .. veh)
        return
    end

    network_utils.request_control_of(veh) -- Request control to ensure proper deletion.
    
    -- Mark as mission entity (often done before deletion in some contexts to prevent recreation).
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, true)
    
    -- Original Lua code used Game.NewVehicle and Game.Delete.
    -- If 'Game' is a custom wrapper, this might be necessary.
    -- Otherwise, VEHICLE.DELETE_VEHICLE(veh) is usually sufficient.
    local veh_ptr = NewVehicle(veh) -- Assuming this creates a wrapper/pointer.
    VEHICLE.DELETE_VEHICLE(veh_ptr) -- Delete using the wrapper/pointer.
    Delete(veh_ptr) -- Delete the wrapper/pointer.

    -- Fallback/ensure deletion if custom Game wrapper isn't fully effective
    if ENTITY.DOES_ENTITY_EXIST(veh) then
        NETWORK.NETWORK_FADE_OUT_ENTITY(veh, true, false) -- Fade out for other players
        Wait(500) -- Give time to fade
        VEHICLE.DELETE_VEHICLE(veh) -- Direct delete
        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(veh)
    end

    print("Networked vehicle " .. veh .. " deleted.")
end

return network_utils -- Return the utility table for use in other scripts.

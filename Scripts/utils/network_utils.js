/// <reference path="../js_typings/gctv.d.ts" />
/// <reference path="../js_typings/gtav_natives.d.ts" /> 

require("utils\\map_utils.js")

var networkUtils = {
    /**
     * Requests control of a specific entity on the network.
     * This is crucial in a multiplayer environment to ensure that local script changes
     * to an entity are synchronized and visible to other players.
     * The function retries the request multiple times until control is gained or attempts run out.
     * @param {number} entity - The handle of the entity for which to request control.
     */
    requestControlOf: function(entity) { // Use function expression for methods
        // Attempt to request control. Native function names are UPPER_SNAKE_CASE.
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity);
        
        // Loop to continuously request control until it's gained.
        // The loop runs up to 50 times.
        for (var i = 0; i < 50; i++) { // Use var for loop variable
            if (NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)) {
                break; // Exit loop if control is successfully gained.
            }
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity); // Re-request control.
            Wait(1); // Simulate Lua's Wait(1) for 1 millisecond.
        }
    },

    /**
     * Registers an entity on the network, making it visible and interactive for all players.
     * This involves marking it as networked, requesting control, and ensuring its network ID
     * exists on all machines.
     * @param {number} entity - The handle of the entity to register as networked.
     */
    registerAsNetwork: function(entity) { // Use function expression for methods
        // Mark the entity as networked. Native function names are UPPER_SNAKE_CASE.
        NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(entity);
        Wait(1); // Simulate Lua's Wait(1) after registration.
        
        // Request control of the entity to ensure the local client can manipulate it.
        networkUtils.requestControlOf(entity); // Call internal method
        
        // Get the network ID associated with the entity. Native function names are UPPER_SNAKE_CASE.
        var netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity); // Use var for local variable
        
        // Ensure the network ID exists on all machines, making the entity fully synchronized.
        // The second parameter 'true' (equivalent to 1 in Lua) typically means 'force'.
        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netId, true);
    },
    /**
     * Creates a networked vehicle with a given model and coordinates, and optionally adds a blip.
     * @param {number} model - The model hash of the vehicle to create.
     * @param {object} coords - An object with 'x', 'y', 'z' coordinates for spawning.
     * @param {number} heading - The heading (rotation around Z-axis) for the vehicle.
     * @param {object|null} [blipInfo=null] - An optional object containing blip customization:
     * `sprite` (number), `modifier` (number), `scale` (number), `name` (string).
     * @returns {number|null} The handle of the created vehicle, or null if creation fails.
     */

    createNetVehicle: function(model, coords, heading, blipInfo) {
        // Check if the model is valid and in CDImage (on disk). Native function names are UPPER_SNAKE_CASE.
        if (STREAMING.IS_MODEL_IN_CDIMAGE(model) && STREAMING.IS_MODEL_VALID(model)) {
            STREAMING.REQUEST_MODEL(model, true); // Request the model, true for `p2` (load as network model).
            var iters = 0; // Use var
            // Wait for the model to load. Native function names are UPPER_SNAKE_CASE.
            while (!STREAMING.HAS_MODEL_LOADED(model)) {
                if (iters > 50) { // Timeout after 50 attempts (5 seconds with Wait(100)).
                    console.error("Failed to load model " + model);
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model);
                    return null;
                }
                Wait(100); // Wait 100ms
                iters++;
            }

            // Create the vehicle. Native function names are UPPER_SNAKE_CASE.
            var veh = VEHICLE.CREATE_VEHICLE(model, coords.x, coords.y, coords.z, heading, false, false, false); // Use var
            
            // Check if vehicle was successfully created and exists. Native function names are UPPER_SNAKE_CASE.
            if (veh !== 0.0 && ENTITY.DOES_ENTITY_EXIST(veh)) {
                networkUtils.registerAsNetwork(veh); // Register the vehicle on the network.

                VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh, 5.0); // Ensure vehicle is properly placed on ground.
                VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false); // Turn engine on.
                VEHICLE.SET_VEHICLE_IS_WANTED(veh, false); // Ensure vehicle is not wanted.
                
                // Add blip if blipInfo is provided.
                if (blipInfo !== null && typeof blipInfo === "object") {
                    // Assuming mapUtils is a global object.
                    var blipSprite = mapUtils.getBlipFromEntityModel(model); // Use var
                    if (blipInfo.sprite) {
                        blipSprite = blipInfo.sprite; // Override with custom sprite if provided.
                    }

                    var blip = HUD.ADD_BLIP_FOR_ENTITY(veh); // Use var
                    HUD.SET_BLIP_SPRITE(blip, blipSprite); // Set blip sprite.

                    if (blipInfo.modifier) {
                        HUD.BLIP_ADD_MODIFIER(blip, blipInfo.modifier); // Add blip modifier.
                    }

                    if (blipInfo.scale !== undefined) {
                        HUD.SET_BLIP_SCALE(blip, blipInfo.scale); // Set blip scale.
                    }

                    if (blipInfo.name) {
                        HUD._SET_BLIP_NAME(blip, blipInfo.name); // Set blip name.
                    }
                }

                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model); // Release model.
                return veh; // Return the handle of the created vehicle.
            } else {
                console.error("Failed to create vehicle entity for model " + model);
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model);
                return null;
            }
        } else {
            console.error("Not valid model or model not in CDImage: " + model);
        }
        return null;
    },

    /**
     * Deletes a networked vehicle.
     * This function requests control of the vehicle and then deletes it.
     * @param {number} veh - The handle of the vehicle to delete.
     */
    deleteNetVehicle: function(veh) {
        // Check if entity exists before attempting to delete. Native function names are UPPER_SNAKE_CASE.
        if (!ENTITY.DOES_ENTITY_EXIST(veh)) {
            console.error("Attempted to delete non-existent vehicle handle: " + veh);
            return;
        }

        networkUtils.requestControlOf(veh); // Request control to ensure proper deletion.
        
        // Mark as mission entity (often done before deletion in some contexts to prevent recreation).
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, true);
        
        // Original Lua code used Game.NewVehicle and Game.Delete.
        // In JavaScript (Duktape), entity handles are direct numbers.
        // Assuming VEHICLE.DELETE_VEHICLE takes the direct handle.
        VEHICLE.DELETE_VEHICLE(veh); // Direct delete.

        // Fallback/ensure deletion if direct delete isn't fully effective immediately
        if (ENTITY.DOES_ENTITY_EXIST(veh)) {
            NETWORK.NETWORK_FADE_OUT_ENTITY(veh, true, false); // Fade out for other players
            Wait(500); // Give time to fade (500ms)
            VEHICLE.DELETE_VEHICLE(veh); // Direct delete again
            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(veh);
        }

        console.log("Networked vehicle " + veh + " deleted.");
    }
};
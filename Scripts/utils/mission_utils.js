/// <reference path="../js_typings/gctv.d.ts" />
/// <reference path="../js_typings/gtav_natives.d.ts" /> 

/**
 * This utility script provides functions for creating and managing mission-specific
 * game entities (vehicles, peds) and cameras.
 */

const missionUtils = {
    /**
     * Creates a vehicle and registers it as a mission entity and network entity.
     * This function includes retry logic with slight coordinate adjustments if spawning fails.
     * @param {string} model - The model name (e.g., "ADDER", "BUZZARD").
     * @param {number} x - The X-coordinate for spawning.
     * @param {number} y - The Y-coordinate for spawning.
     * @param {number} z - The Z-coordinate for spawning.
     * @param {number} heading - The heading (rotation around Z-axis) for the vehicle.
     * @returns {number|null} The handle of the created vehicle, or null if creation fails after retries.
     */
    createMissionVehicle(model, x, y, z, heading) {
        const modelHash = MISC.GET_HASH_KEY(model);
        const maxAttempts = 10; // Define a maximum number of spawn attempts.
        let currentAttempt = 0;

        // Check if the model is valid. Native function names are UPPER_SNAKE_CASE.
        if (!STREAMING.IS_MODEL_VALID(modelHash)) {
            console.error(`Invalid vehicle model: ${model}.`);
            return null;
        }

        // Request and load the model if not already loaded. Native function names are UPPER_SNAKE_CASE.
        if (!STREAMING.HAS_MODEL_LOADED(modelHash)) {
            STREAMING.REQUEST_MODEL(modelHash);
            // Wait for the model to load, with a timeout.
            var loadIters = 0;
            while (!STREAMING.HAS_MODEL_LOADED(modelHash)) {
                Wait(5); // Simulate Lua's Wait(5)
                loadIters++;
                if (loadIters > 100) { // Timeout after 500ms
                    console.error(`Failed to load vehicle model: ${model}.`);
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash);
                    return null;
                }
            }
        }

        var spawnedVeh = 0.0; // Initialize with 0.0 (invalid handle)
        var currentX = x;
        var currentY = y;
        var currentZ = z; // Use mutable coordinates for retries

        while (spawnedVeh === 0.0 && currentAttempt < maxAttempts) {
            // Attempt to create the vehicle. Native function names are UPPER_SNAKE_CASE.
            spawnedVeh = VEHICLE.CREATE_VEHICLE(modelHash, currentX, currentY, currentZ, heading, false, false, false);
            
            if (spawnedVeh === 0.0) {
                // If creation failed, slightly adjust coordinates for the next attempt.
                currentX += 0.15;
                currentY += 0.15;
                currentZ += 0.05;
                Wait(10); // Simulate Lua's Wait(10)
                currentAttempt++;
            }
        }

        // If vehicle was successfully created after attempts.
        if (spawnedVeh !== 0.0) {
            // Assuming networkUtils is a global object with registerAsNetwork method.
            networkUtils.registerAsNetwork(spawnedVeh); // Register the vehicle with the network.
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(spawnedVeh, true, true); // Mark as mission entity.
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash); // Release model.
            return spawnedVeh;
        } else {
            console.error(`Failed to create mission vehicle after ${maxAttempts} attempts: ${model}.`);
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash); // Release model even on failure.
            return null;
        }
    },

    /**
     * Creates a pedestrian (ped) and registers it as a mission entity and network entity.
     * This function includes retry logic with slight coordinate adjustments if spawning fails.
     * @param {string} model - The model name (e.g., "MP_M_FREEMODE_01").
     * @param {number} pedType - The ped type (e.g., 0 for CIVILIAN_PED).
     * @param {number} x - The X-coordinate for spawning.
     * @param {number} y - The Y-coordinate for spawning.
     * @param {number} z - The Z-coordinate for spawning.
     * @param {number} heading - The heading (rotation around Z-axis) for the ped.
     * @returns {number|null} The handle of the created ped, or null if creation fails after retries.
     */
    createMissionPed(model, pedType, x, y, z, heading) {
        const modelHash = MISC.GET_HASH_KEY(model);
        const maxAttempts = 10; // Define a maximum number of spawn attempts.
        var currentAttempt = 0;

        // Check if the model is valid. Native function names are UPPER_SNAKE_CASE.
        if (!STREAMING.IS_MODEL_VALID(modelHash)) {
            console.error(`Invalid ped model: ${model}.`);
            return null;
        }

        // Request and load the model if not already loaded. Native function names are UPPER_SNAKE_CASE.
        if (!STREAMING.HAS_MODEL_LOADED(modelHash)) {
            STREAMING.REQUEST_MODEL(modelHash);
            // Wait for the model to load, with a timeout.
            var loadIters = 0;
            while (!STREAMING.HAS_MODEL_LOADED(modelHash)) {
                Wait(5); // Simulate Lua's Wait(5)
                loadIters++;
                if (loadIters > 100) { // Timeout after 500ms
                    console.error(`Failed to load ped model: ${model}.`);
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash);
                    return null;
                }
            }
        }

        var spawnedPed = 0.0; // Initialize with 0.0 (invalid handle)
        var currentX = x;
        var currentY = y;
        var currentZ = z; // Use mutable coordinates for retries

        while (spawnedPed === 0.0 && currentAttempt < maxAttempts) {
            // Attempt to create the ped. Native function names are UPPER_SNAKE_CASE.
            spawnedPed = PED.CREATE_PED(pedType, modelHash, currentX, currentY, currentZ, heading, false, true);
            
            if (spawnedPed === 0.0) {
                // If creation failed, slightly adjust coordinates for the next attempt.
                currentX += 0.01;
                currentY += 0.01;
                // z is not adjusted in original Lua, maintaining that.
                Wait(10); // Simulate Lua's Wait(10)
                currentAttempt++;
            }
        }

        // If ped was successfully created after attempts.
        if (spawnedPed !== 0.0) {
            networkUtils.registerAsNetwork(spawnedPed); // Register the ped with the network.
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(spawnedPed, true, true); // Mark as mission entity.
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash); // Release model.
            return spawnedPed;
        } else {
            console.error(`Failed to create mission ped after ${maxAttempts} attempts: ${model}.`);
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash); // Release model even on failure.
            return null;
        }
    },

    /**
     * Creates a mission ped and places them directly into a specified vehicle.
     * @param {number} vehicle - The handle of the vehicle to place the ped into.
     * @param {number} seat - The seat index in the vehicle (e.g., -1 for driver, 0 for passenger).
     * @param {string} model - The ped model name.
     * @param {number} pedType - The ped type.
     * @param {number} x - The X-coordinate for initial ped spawning (before entering vehicle).
     * @param {number} y - The Y-coordinate for initial ped spawning.
     * @param {number} z - The Z-coordinate for initial ped spawning.
     * @param {number} heading - The heading for initial ped spawning.
     * @returns {number|null} The handle of the created ped, or null if creation fails.
     */
    createMissionPedInVehicle(vehicle, seat, model, pedType, x, y, z, heading) {
        // First, create the mission ped.
        const ped = missionUtils.createMissionPed(model, pedType, x, y, z, heading);

        // If the ped was successfully created, place them into the vehicle. Native function names are UPPER_SNAKE_CASE.
        if (ped) {
            PED.SET_PED_INTO_VEHICLE(ped, vehicle, seat);
        }

        return ped; // Return the handle of the created ped.
    },

    /**
     * Creates and activates a scripted camera at specified coordinates and rotation.
     * @param {number} x - The X-coordinate for the camera position.
     * @param {number} y - The Y-coordinate for the camera position.
     * @param {number} z - The Z-coordinate for the camera position.
     * @param {number} pitch - The pitch (X-rotation) of the camera.
     * @param {number} roll - The roll (Y-rotation) of the camera.
     * @param {number} yaw - The yaw (Z-rotation) of the camera.
     * @param {number} transitionTime - The time in milliseconds for the camera transition.
     * @returns {number} The handle of the created camera.
     */
    createCamera(x, y, z, pitch, roll, yaw, transitionTime) {
        // Create a default scripted camera. Native function names are UPPER_SNAKE_CASE.
        const cam = CAM.CREATE_CAM("DEFAULT_SCRIPTED_CAMERA", true);
        CAM.SET_CAM_COORD(cam, x, y, z); // Set camera position.
        // Set camera rotation. Note the order: pitch, roll, yaw (X, Y, Z).
        CAM.SET_CAM_ROT(cam, pitch, roll, yaw, 2); // Order 2 is typically X, Y, Z.
        // Render the script camera, with a transition.
        CAM.RENDER_SCRIPT_CAMS(true, true, transitionTime, true, true);

        return cam; // Return the camera handle.
    },

    /**
     * Creates and activates a scripted "fly" camera.
     * This camera type often has different properties and rendering behavior.
     * @param {number} x - The X-coordinate for the camera position.
     * @param {number} y - The Y-coordinate for the camera position.
     * @param {number} z - The Z-coordinate for the camera position.
     * @param {number} pitch - The pitch (X-rotation) of the camera.
     * @param {number} roll - The roll (Y-rotation) of the camera.
     * @param {number} yaw - The yaw (Z-rotation) of the camera.
     * @param {number} maxHeight - The maximum height the fly camera can reach.
     * @param {number} transitionTime - The time in milliseconds for the camera transition.
     * @returns {number} The handle of the created camera.
     */
    createFlyCamera(x, y, z, pitch, roll, yaw, maxHeight, transitionTime) {
        // Create a default scripted fly camera. Native function names are UPPER_SNAKE_CASE.
        const cam = CAM.CREATE_CAM("DEFAULT_SCRIPTED_FLY_CAMERA", true);
        CAM.SET_CAM_COORD(cam, x, y, z); // Set camera position.
        // Set camera rotation. Note the order: pitch, roll, yaw (X, Y, Z).
        CAM.SET_CAM_ROT(cam, pitch, roll, yaw, 2); // Order 2 is typically X, Y, Z.
        CAM.SET_FLY_CAM_MAX_HEIGHT(cam, maxHeight); // Set max height for fly camera.
        // Render the script camera. Note the different last three parameters compared to CreateCamera.
        CAM.RENDER_SCRIPT_CAMS(true, true, transitionTime, false, false, false);
        
        return cam; // Return the camera handle.
    },

    /**
     * Deletes a previously created camera and deactivates script cameras.
     * @param {number} camera - The handle of the camera to destroy.
     */
    deleteCamera(camera) {
        // Deactivate all script cameras. Native function names are UPPER_SNAKE_CASE.
        CAM.RENDER_SCRIPT_CAMS(false, false, 0, true, true);
        // Destroy the specific camera. Native function names are UPPER_SNAKE_CASE.
        CAM.DESTROY_CAM(camera, false);
    }
};

/*
// Example Usage (commented out for production, uncomment for testing in your Duktape environment)
// To run this example, you would need to mock the global GCTV API functions
// and modules (GTAV, networkUtils, console, Wait).
if (typeof console !== 'undefined' && typeof Wait !== 'undefined') {
    console.log("--- Testing missionUtils JavaScript ---");

    // --- Mock GCTV API functions and modules for testing ---
    // In a real Duktape environment, these would be provided by the host.

    // global.GTAV = {
    //     MISC: {
    //         GET_HASH_KEY: function(modelName) {
    //             var hash = 0;
    //             for (var i = 0; i < modelName.length; i++) {
    //                 hash = (hash << 5) - hash + modelName.charCodeAt(i);
    //                 hash |= 0; // Ensure 32-bit integer
    //             }
    //             return hash;
    //         }
    //     },
    //     STREAMING: {
    //         _loadedModels: new Set(),
    //         IS_MODEL_VALID: function(modelHash) { return modelHash !== 0; },
    //         HAS_MODEL_LOADED: function(modelHash) { return this._loadedModels.has(modelHash); },
    //         REQUEST_MODEL: function(modelHash) { this._loadedModels.add(modelHash); },
    //         SET_MODEL_AS_NO_LONGER_NEEDED: function(modelHash) { this._loadedModels.delete(modelHash); }
    //     },
    //     VEHICLE: {
    //         _nextVehId: 10000,
    //         CREATE_VEHICLE: function(modelHash, x, y, z, heading, isNetwork, isMission, isDynamic) {
    //             if (modelHash === MISC.GET_HASH_KEY("FAIL_VEHICLE")) return 0.0;
    //             this._nextVehId++;
    //             console.log(`Mock: Created vehicle ${this._nextVehId} at (${x},${y},${z})`);
    //             return this._nextVehId;
    //         }
    //     },
    //     PED: {
    //         _nextPedId: 20000,
    //         CREATE_PED: function(pedType, modelHash, x, y, z, heading, isNetwork, isMission) {
    //             if (modelHash === MISC.GET_HASH_KEY("FAIL_PED")) return 0.0;
    //             this._nextPedId++;
    //             console.log(`Mock: Created ped ${this._nextPedId} at (${x},${y},${z})`);
    //             return this._nextPedId;
    //         },
    //         SET_PED_INTO_VEHICLE: function(ped, vehicle, seat) {
    //             console.log(`Mock: Ped ${ped} set into vehicle ${vehicle} seat ${seat}`);
    //         }
    //     },
    //     ENTITY: {
    //         SET_ENTITY_AS_MISSION_ENTITY: function(entity, isMission, isNetwork) {
    //             console.log(`Mock: Entity ${entity} set as mission entity (mission=${isMission}, network=${isNetwork})`);
    //         }
    //     },
    //     CAM: {
    //         _nextCamId: 30000,
    //         CREATE_CAM: function(camType, isActive) {
    //             this._nextCamId++;
    //             console.log(`Mock: Created camera ${this._nextCamId} of type ${camType}`);
    //             return this._nextCamId;
    //         },
    //         SET_CAM_COORD: function(cam, x, y, z) { console.log(`Mock: Cam ${cam} coords set to (${x},${y},${z})`); },
    //         SET_CAM_ROT: function(cam, p, r, y, order) { console.log(`Mock: Cam ${cam} rot set to (${p},${r},${y}) order ${order}`); },
    //         SET_FLY_CAM_MAX_HEIGHT: function(cam, height) { console.log(`Mock: Cam ${cam} max height ${height}`); },
    //         RENDER_SCRIPT_CAMS: function(enable, ease, time, p1, p2, p3) {
    //             console.log(`Mock: Render script cams enable=${enable}, ease=${ease}, time=${time}, p1=${p1}, p2=${p2}, p3=${p3}`);
    //         },
    //         DESTROY_CAM: function(cam, p) { console.log(`Mock: Cam ${cam} destroyed`); }
    //     }
    // };

    // global.networkUtils = {
    //     registerAsNetwork: function(entityId) {
    //         console.log(`Mock: Entity ${entityId} registered as network entity.`);
    //     }
    // };

    // global.Wait = function(ms) {
    //     // In a real Duktape environment, this would be a blocking sleep or a yield.
    //     // For console testing, it just simulates a delay message.
    //     // console.log(`Mock: Waiting for ${ms}ms...`);
    // };

    // // Test createMissionVehicle
    // console.log("\n--- Testing createMissionVehicle ---");
    // const vehHandle = missionUtils.createMissionVehicle("TEST_VEHICLE", 0.0, 0.0, 70.0, 90.0);
    // console.log(`Created Vehicle Handle: ${vehHandle}`);

    // // Test createMissionPed
    // console.log("\n--- Testing createMissionPed ---");
    // const pedHandle = missionUtils.createMissionPed("TEST_PED", 0, 10.0, 10.0, 70.0, 0.0);
    // console.log(`Created Ped Handle: ${pedHandle}`);

    // // Test createMissionPedInVehicle
    // console.log("\n--- Testing createMissionPedInVehicle ---");
    // const vehForPed = missionUtils.createMissionVehicle("TEST_VEHICLE_2", 20.0, 20.0, 70.0, 0.0);
    // const pedInVehHandle = missionUtils.createMissionPedInVehicle(vehForPed, -1, "TEST_PED_2", 0, 20.0, 20.0, 70.0, 0.0);
    // console.log(`Created Ped In Vehicle Handle: ${pedInVehHandle}`);

    // // Test createCamera
    // console.log("\n--- Testing createCamera ---");
    // const camHandle = missionUtils.createCamera(50.0, 50.0, 100.0, 10.0, 0.0, 45.0, 500);
    // console.log(`Created Camera Handle: ${camHandle}`);

    // // Test createFlyCamera
    // console.log("\n--- Testing createFlyCamera ---");
    // const flyCamHandle = missionUtils.createFlyCamera(60.0, 60.0, 110.0, 15.0, 5.0, 60.0, 200.0, 1000);
    // console.log(`Created Fly Camera Handle: ${flyCamHandle}`);

    // // Test deleteCamera
    // console.log("\n--- Testing deleteCamera ---");
    // missionUtils.deleteCamera(camHandle);
    // missionUtils.deleteCamera(flyCamHandle);
}
*/

/// <reference path="../js_typings/gctv.d.ts" />
/// <reference path="../js_typings/gtav_natives.d.ts" /> 

/**
 * This utility script provides helper functions for handling user input,
 * particularly for selecting game entities like vehicles.
 *
 * This implementation assumes the GCTV JavaScript environment provides the
 * following global modules/objects:
 * - `GCT`: For `InputFromList`, `Input`.
 * - `GTAV`: For `PED`, `ENTITY`, `PLAYER` (e.g., `PED.GET_VEHICLE_PED_IS_IN`).
 * - `mapUtils`: For `getPersonalVehicle`.
 * - `console.error`: For displaying error messages.
 */
const inputUtils = {
    /**
     * Prompts the user to select a vehicle from predefined options or by entering a custom handle.
     * @returns {number|null} The handle of the selected vehicle, or null if no valid vehicle is chosen.
     */
    inputVehicle() {
        let selectedVehicleHandle = null;
        
        // Options presented to the user for vehicle selection.
        const vehicleSelectionOptions = [
            "Personal vehicle", // The player's currently tracked personal vehicle.
            "Last vehicle",     // The last vehicle the player was in (even if they exited).
            "Current vehicle",  // The vehicle the player is currently in.
            "Custom"            // Allows the user to enter a vehicle handle manually.
        ];
        
        // Prompt the user to choose a vehicle selection method using GCT.InputFromList.
        const chosenOptionIndex = GCT.InputFromList("Choose which vehicle you want to control: ", vehicleSelectionOptions);
        
        // Process the user's selection.
        if (chosenOptionIndex === 0) { // "Personal vehicle"
            selectedVehicleHandle = mapUtils.getPersonalVehicle();
        } else if (chosenOptionIndex === 1) { // "Last vehicle"
            // Access PED and PLAYER through the GTAV module. Native function names are UPPER_SNAKE_CASE.
            selectedVehicleHandle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true);
        } else if (chosenOptionIndex === 2) { // "Current vehicle"
            selectedVehicleHandle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false);
        } else if (chosenOptionIndex === 3) { // "Custom"
            // Prompt for a custom vehicle handle using GCT.Input.
            const inputHandleStr = GCT.Input("Enter vehicle handle: ", false);
            selectedVehicleHandle = parseInt(inputHandleStr, 10); // Convert input string to integer.
            
            // Validate if the entered handle corresponds to an existing vehicle using ENTITY.
            // Native function names are UPPER_SNAKE_CASE.
            if (isNaN(selectedVehicleHandle) || !ENTITY.IS_ENTITY_A_VEHICLE(selectedVehicleHandle)) {
                console.error("Invalid vehicle handle entered or entity is not a vehicle."); // Replaced DisplayError
                return null; // Return null if the custom handle is invalid.
            }
        } else {
            // User cancelled or made an invalid selection from the list.
            return null;
        }

        // After selection, perform a final check to ensure a valid non-zero handle was obtained.
        // Assuming 0.0 is an invalid handle in the GTAV API for JavaScript.
        if (selectedVehicleHandle === 0.0 || selectedVehicleHandle === null) {
            console.error("No valid vehicle could be identified or selected."); // Replaced DisplayError
            return null;
        }

        return selectedVehicleHandle; // Return the handle of the selected vehicle.
    }
};

/*
// Example Usage (commented out for production, uncomment for testing in your Duktape environment)
// To run this example, you would need to mock the global GCTV API functions
// and modules (GCT, GTAV, mapUtils).
if (typeof console !== 'undefined') {
    console.log("--- Testing inputUtils JavaScript ---");

    // --- Mock GCTV API functions and modules for testing ---
    // In a real Duktape environment, these would be provided by the host.

    // global.GCT = {
    //     InputFromList: function(prompt, options) {
    //         console.log(prompt);
    //         options.forEach((opt, i) => console.log(`[${i}] ${opt}`));
    //         // Simulate selection, e.g., return 0 for "Personal vehicle"
    //         return 0;
    //     },
    //     Input: function(prompt, toLowerCase) {
    //         console.log(prompt);
    //         // Simulate input, e.g., "404" for custom handle
    //         const val = "404";
    //         return toLowerCase ? val.toLowerCase() : val;
    //     }
    // };

    // global.GTAV = {
    //     PED: {
    //         GET_VEHICLE_PED_IS_IN: function(pedId, lastVehicle) {
    //             if (lastVehicle) {
    //                 console.log(`Mock: Getting last vehicle for ped ${pedId} (returning 202).`);
    //                 return 202;
    //             } else {
    //                 console.log(`Mock: Getting current vehicle for ped ${pedId} (returning 303).`);
    //                 return 303;
    //             }
    //         }
    //     },
    //     ENTITY: {
    //         IS_ENTITY_A_VEHICLE: function(entityId) {
    //             console.log(`Mock: Checking if entity ${entityId} is a vehicle.`);
    //             return [101, 202, 303, 404, 505].includes(entityId); // Example valid handles
    //         }
    //     },
    //     PLAYER: {
    //         PLAYER_PED_ID: function() {
    //             console.log("Mock: Getting player ped ID (returning 1).");
    //             return 1;
    //         }
    //     }
    // };

    // global.mapUtils = {
    //     getPersonalVehicle: function() {
    //         console.log("Mock: Getting personal vehicle (returning 101).");
    //         return 101;
    //     }
    // };

    // global.console.error = function(message) { // Mock console.error
    //     console.log(`Mock Error: ${message}`);
    // };
    // --- End Mocking ---

    // Example Test Call (uncomment and ensure mocks are set up)
    // const selectedVeh = inputUtils.inputVehicle();
    // console.log(`Final selected vehicle handle: ${selectedVeh}`);
}
*/

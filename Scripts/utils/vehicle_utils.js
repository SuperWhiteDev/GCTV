/// <reference path="../js_typings/gctv.d.ts" />
/// <reference path="../js_typings/gtav_natives.d.ts" /> 

/**
 * This utility script provides helper functions related to vehicle models,
 * specifically for retrieving vehicle model names and selecting random ones
 * from a configuration file.
 */

const vehicleUtils = {
    /**
     * Internal helper to read the "vehicles.json" file.
     * Returns an empty array if the file does not exist, is empty, or is invalid JSON.
     * @returns {Array<string>} An array of vehicle model names.
     */
    _readVehiclesJson: function() { // Use function expression
        var filePath = "vehicles.json"; // Use var
        if (!fs.fileExists(filePath)) {
            return [];
        }
        try {
            var data = fs.readFile(filePath); // Use var
            if (data === null || data === undefined || data === "") {
                return []; // Return empty array if file is empty
            }
            var parsedData = JSON.parse(data); // Use var
            if (Array.isArray(parsedData)) {
                return parsedData;
            }
            console.error("vehicles.json content is not an array. Returning empty list.");
            return [];
        } catch (e) {
            console.error("Error: Could not read or decode JSON from " + filePath + ". Returning empty list.", e);
            return [];
        }
    },

    /**
     * Retrieves the original model name (string) corresponding to a given model hash.
     * It searches through a list of vehicle models defined in "vehicles.json".
     * @param {number} modelHash - The hash of the vehicle model.
     * @returns {string} The string name of the vehicle model, or "Unknown Model" if not found.
     */
    getVehicleModelName: function(modelHash) { // Use function expression
        var vehicles = this._readVehiclesJson(); // Use var

        // Iterate through each vehicle name in the list.
        for (var i = 0; i < vehicles.length; i++) { // Use var for loop variable
            var vehicleName = vehicles[i]; // Use var
            // Get the hash key for the current vehicle name and compare it to the target hash.
            // Native function names are UPPER_SNAKE_CASE.
            if (MISC.GET_HASH_KEY(vehicleName) === modelHash) {
                return vehicleName; // Return the matching vehicle model name.
            }
        }

        return "Unknown Model"; // Return "Unknown Model" if the hash is not found or file is invalid.
    },

    /**
     * Retrieves a random vehicle model name from the "vehicles.json" file.
     * @returns {string} A randomly selected vehicle model name, or an empty string if
     * the "vehicles.json" file is not found, empty, or invalid.
     */
    getRandomVehicleModelName: function() { // Use function expression
        var vehicles = this._readVehiclesJson(); // Use var

        // Check if the list of vehicles was successfully read and is not empty.
        if (vehicles.length > 0) {
            // Generate a random index within the bounds of the vehicles array.
            var vehicleIndex = Math.floor(Math.random() * vehicles.length); // Use var
            return vehicles[vehicleIndex]; // Return the vehicle model name at the random index.
        }
        
        return ""; // Return an empty string if no vehicles are found or the file is invalid.
    }
};

/*
// Example Usage (commented out for production, uncomment for testing in your Duktape environment)
// To run this example, you would need to mock the global `fs` object and `MISC`.
if (typeof console !== 'undefined' && typeof fs !== 'undefined') {
    console.log("--- Testing vehicleUtils JavaScript ---");

    // --- Mock `fs` module for testing ---
    // global.fs = {
    //     _files: {},
    //     readFile: function(path) { return this._files[path] || ""; },
    //     fileExists: function(path) { return path in this._files && this._files[path] !== ""; },
    //     writeFile: function(path, content) { this._files[path] = content; }
    // };

    // --- Mock `MISC` for testing ---
    // global.GTAV = {
    //     MISC: {
    //         GET_HASH_KEY: function(modelName) {
    //             // A simple mock hash function for testing purposes
    //             var hash = 0;
    //             for (var i = 0; i < modelName.length; i++) {
    //                 hash = (hash << 5) - hash + modelName.charCodeAt(i);
    //                 hash |= 0; // Ensure 32-bit integer
    //             }
    //             return hash;
    //         }
    //     }
    // };

    // Create a mock vehicles.json file for testing
    // fs.writeFile("vehicles.json", JSON.stringify(["adder", "buzzard", "zentorno", "faggio"]));

    // Test getVehicleModelName
    // var adderHash = MISC.GET_HASH_KEY("adder");
    // console.log("Model name for hash " + adderHash + ": " + vehicleUtils.getVehicleModelName(adderHash)); // Expected: adder
    
    // var unknownHash = MISC.GET_HASH_KEY("non_existent_car");
    // console.log("Model name for hash " + unknownHash + ": " + vehicleUtils.getVehicleModelName(unknownHash)); // Expected: Unknown Model

    // Test getRandomVehicleModelName
    // console.log("Random Vehicle Model 1: " + vehicleUtils.getRandomVehicleModelName());
    // console.log("Random Vehicle Model 2: " + vehicleUtils.getRandomVehicleModelName());
    // console.log("Random Vehicle Model 3: " + vehicleUtils.getRandomVehicleModelName());

    // Test with an empty vehicles.json
    // fs.writeFile("vehicles.json", "[]");
    // console.log("Random Vehicle Model (empty file): " + vehicleUtils.getRandomVehicleModelName()); // Expected: ""
    // console.log("Model name for adder hash (empty file): " + vehicleUtils.getVehicleModelName(adderHash)); // Expected: Unknown Model

    // Test with a non-existent vehicles.json (requires fs.deleteFile if it exists)
    // if (fs.deleteFile) fs.deleteFile("vehicles.json");
    // console.log("Random Vehicle Model (non-existent file): " + vehicleUtils.getRandomPedModelName()); // Expected: ""
    // console.log("Model name for adder hash (non-existent file): " + vehicleUtils.getVehicleModelName(adderHash)); // Expected: Unknown Model

    // console.log("--- End Testing vehicleUtils JavaScript ---");
}
*/

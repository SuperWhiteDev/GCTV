/// <reference path="../js_typings/gctv.d.ts" />
/// <reference path="../js_typings/gtav_natives.d.ts" /> 

/**
 * This utility script provides helper functions related to ped models,
 * specifically for retrieving a random ped model name from a configuration file.
 */

var pedUtils = {
    /**
     * Internal helper to read JSON data from a file using the global `fs` module.
     * This is a duplicate of the one in config_utils.js, but included here for
     * self-containment if this file were to be used independently.
     * @param {string} filePath - The path to the JSON configuration file.
     * @returns {object|Array} The parsed JSON data, or an empty object/array if the file
     * does not exist, is empty, or contains invalid JSON.
     */
    _readJsonFile: function(filePath) { // Use function expression
        if (!fs.fileExists(filePath)) {
            // console.log(`File does not exist: ${filePath}. Returning empty data.`);
            return {}; // Return empty object or array based on expected content
        }
        try {
            var data = fs.readFile(filePath); // Use var
            if (data === null || data === undefined || data === "") {
                return {}; // Return empty object if file is empty
            }
            return JSON.parse(data);
        } catch (e) {
            console.error("Error: Could not read or decode JSON from " + filePath + ". Returning empty config.", e);
            return {};
        }
    },

    /**
     * Retrieves a random pedestrian model name from the "peds.json" file.
     * @returns {string} A randomly selected ped model name, or an empty string if
     * the "peds.json" file is not found, empty, or invalid.
     */
    getRandomPedModelName: function() { // Use function expression
        var pedModels = []; // Use var
        var filePath = "peds.json"; // Use var

        // Attempt to read the list of ped models from the JSON file.
        var fileContent = this._readJsonFile(filePath); // Use var
        
        // Ensure the content is an array and not empty.
        if (Array.isArray(fileContent) && fileContent.length > 0) {
            pedModels = fileContent;
        }

        // Check if the list of ped models was successfully read and is not empty.
        if (pedModels.length > 0) {
            // Generate a random index within the bounds of the pedModels array.
            var pedIndex = Math.floor(Math.random() * pedModels.length); // Use var
            return pedModels[pedIndex]; // Return the ped model name at the random index.
        }
        
        return ""; // Return an empty string if no peds are found or the file is invalid.
    }
};

/*
// Example Usage (commented out for production, uncomment for testing in your Duktape environment)
// To run this example, you would need to mock the global `fs` object.
if (typeof console !== 'undefined' && typeof fs !== 'undefined') {
    console.log("--- Testing pedUtils JavaScript ---");

    // --- Mock `fs` module for testing ---
    // In a real Duktape environment, this would be provided by the host.
    // global.fs = {
    //     _files: {},
    //     readFile: function(path) { return this._files[path] || ""; },
    //     fileExists: function(path) { return path in this._files && this._files[path] !== ""; },
    //     writeFile: function(path, content) { this._files[path] = content; }
    // };

    // Create a mock peds.json file for testing
    // fs.writeFile("peds.json", JSON.stringify(["a_m_m_fatlatino_01", "s_m_y_cop_01", "u_m_m_fibsec_01", "g_m_m_chigoon_01"]));

    // Test getRandomPedModelName multiple times
    // console.log("Random Ped Model 1: " + pedUtils.getRandomPedModelName());
    // console.log("Random Ped Model 2: " + pedUtils.getRandomPedModelName());
    // console.log("Random Ped Model 3: " + pedUtils.getRandomPedModelName());

    // Test with an empty peds.json
    // fs.writeFile("peds.json", "[]");
    // console.log("Random Ped Model (empty file): " + pedUtils.getRandomPedModelName()); // Expected: ""

    // Test with a non-existent peds.json
    // fs.deleteFile("peds.json"); // Assuming fs.deleteFile exists for cleanup
    // console.log("Random Ped Model (non-existent file): " + pedUtils.getRandomPedModelName()); // Expected: ""

    // console.log("--- End Testing pedUtils JavaScript ---");
}
*/

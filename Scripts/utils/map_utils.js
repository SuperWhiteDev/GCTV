/// <reference path="../js_typings/gctv.d.ts" />
/// <reference path="../js_typings/gtav_natives.d.ts" /> 

require("enums\\blip_enums.js")
/**
 * This utility script provides helper functions related to map interactions,
 * such as retrieving waypoint coordinates, finding personal vehicles,
 * determining blip sprites for entities, and getting zone names.
 */

const mapUtils = {
    /**
     * Internal helper to read JSON data from a file using the global `fs` module.
     * This is a duplicate of the one in config_utils.js, but included here for
     * self-containment if this file were to be used independently.
     * @param {string} filePath - The path to the JSON configuration file.
     * @returns {object} The parsed JSON data, or an empty object if the file
     * does not exist, is empty, or contains invalid JSON.
     */
    _readJsonFile(filePath) {
        if (!fs.fileExists(filePath)) {
            // console.log(`File does not exist: ${filePath}. Returning empty config.`);
            return {};
        }
        try {
            const data = fs.readFile(filePath);
            if (data === null || data === undefined || data === "") {
                return {}; // Return empty object if file is empty
            }
            return JSON.parse(data);
        } catch (e) {
            console.error(`Error: Could not read or decode JSON from ${filePath}. Returning empty config.`, e);
            return {};
        }
    },

    /**
     * Retrieves the coordinates of the active waypoint set by the player on the map.
     * @returns {object|null} An object with 'x', 'y', 'z' coordinates of the waypoint (z is set to 0.0),
     * or null if no waypoint is currently set.
     */
    getWaypointCoords() {
        // Get the blip ID for the first active waypoint. Native function names are UPPER_SNAKE_CASE.
        const waypointBlip = HUD.GET_FIRST_BLIP_INFO_ID(blipEnums.BlipIcon.WAYPOINT);
        
        // Check if the waypoint blip actually exists.
        if (HUD.DOES_BLIP_EXIST(waypointBlip)) {
            // Get the coordinates of the waypoint blip.
            const coords = HUD.GET_BLIP_COORDS(waypointBlip);
            coords.z = 0.0; // Set Z-coordinate to 0.0, often useful for ground-level interaction.

            return coords; // Return the waypoint coordinates.
        } else {
            return null; // No waypoint found.
        }
    },

    /**
     * Retrieves the entity handle of the player's personal vehicle.
     * It checks for both car and bike blips representing the personal vehicle.
     * @returns {number|null} The entity handle of the personal vehicle, or null if not found.
     */
    getPersonalVehicle() {
        // First, try to find the blip for a personal car. Native function names are UPPER_SNAKE_CASE.
        let personalVehBlip = HUD.GET_FIRST_BLIP_INFO_ID(blipEnums.BlipIcon.PERSONAL_VEHICLE_CAR);
        
        // If a personal car blip exists, return its associated entity handle.
        if (HUD.DOES_BLIP_EXIST(personalVehBlip)) {
            return HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(personalVehBlip);
        } else {
            // If no personal car, try to find the blip for a personal bike.
            personalVehBlip = HUD.GET_FIRST_BLIP_INFO_ID(blipEnums.BlipIcon.PERSONAL_VEHICLE_BIKE);
            
            // If a personal bike blip exists, return its associated entity handle.
            if (HUD.DOES_BLIP_EXIST(personalVehBlip)) {
                return HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(personalVehBlip);
            }

            return null; // No personal vehicle (car or bike) blip found.
        }
    },

    /**
     * Determines the appropriate blip icon for a given entity model hash.
     * This is useful for displaying entities on the map with relevant icons.
     * @param {number} model - The model hash of the entity.
     * @returns {number} The blip icon ID from `blipEnums.BlipIcon` that best represents the model.
     */
    getBlipFromEntityModel(model) {
        // Check if the model is a pedestrian. Native function names are UPPER_SNAKE_CASE.
        if (STREAMING.IS_MODEL_A_PED(model)) {
            return blipEnums.BlipIcon.STANDARD; // Use a standard blip for pedestrians.
        // Check if the model is a vehicle.
        } else if (STREAMING.IS_MODEL_A_VEHICLE(model)) {
            // Further categorize vehicle types for more specific blips.
            if (VEHICLE.IS_THIS_MODEL_A_PLANE(model)) {
                return blipEnums.BlipIcon.PLANE;
            } else if (VEHICLE.IS_THIS_MODEL_A_HELI(model)) {
                return blipEnums.BlipIcon.HELICOPTER;
            } else if (VEHICLE.IS_THIS_MODEL_A_BIKE(model)) {
                return blipEnums.BlipIcon.PERSONAL_VEHICLE_BIKE;
            } else { 
                // Default vehicle blip for cars and other ground vehicles.
                return blipEnums.BlipIcon.PERSONAL_VEHICLE_CAR;
            }
        }
        // If neither a ped nor a known vehicle type, return a default standard blip.
        return blipEnums.BlipIcon.STANDARD;
    },

    /**
     * Retrieves the display name of a game zone at specified coordinates.
     * It first gets the internal zone name and then attempts to find a more readable
     * display name from a "zones.json" configuration file.
     * @param {number} x - The X-coordinate.
     * @param {number} y - The Y-coordinate.
     * @param {number} z - The Z-coordinate.
     * @returns {string} The display name of the zone, or the raw internal zone name if no display name is found.
     */
    getZoneName(x, y, z) {
        // Get the internal (uppercase) name of the zone from the game API. Native function names are UPPER_SNAKE_CASE.
        const zoneInternalName = ZONE.GET_NAME_OF_ZONE(x, y, z).toUpperCase();

        let zoneNamesList = [];
        try {
            const fileContent = this._readJsonFile("zones.json");
            if (fileContent && Object.keys(fileContent).length > 0) {
                 // Assuming zones.json is an array of objects like [{Name: "...", DisplayName: "..."}]
                if (Array.isArray(fileContent)) {
                    zoneNamesList = fileContent;
                } else {
                    // If it's an object, convert it to an array of its values if needed
                    // Or handle a different structure, e.g., { "DELPERO": { "DisplayName": "Del Perro Beach" } }
                    // For now, assuming it's an array for consistency with Lua's JsonReadList
                    console.warn("zones.json might not be an array. Please check its structure.");
                }
            }
        } catch (e) {
            console.error(`Error reading zones.json: ${e}. Using default zone name.`);
            // Silently fail and use default if file is bad or missing.
        }

        // Iterate through the list to find a matching display name.
        for (let i = 0; i < zoneNamesList.length; i++) {
            const element = zoneNamesList[i];
            // Compare the uppercase internal name with the uppercase name from the JSON.
            if (element.Name && element.Name.toUpperCase() === zoneInternalName) {
                return element.DisplayName || zoneInternalName; // Return display name or fallback
            }
        }

        return zoneInternalName; // If no display name found, return the raw internal name.
    }
};

/*
// Example Usage (commented out for production, uncomment for testing in your Duktape environment)
// To run this example, you would need to mock the global GCTV API functions
// and modules (GTAV, blipEnums, fs, console).
if (typeof console !== 'undefined' && typeof fs !== 'undefined') {
    console.log("--- Testing mapUtils JavaScript ---");

    // --- Mock GCTV API functions and modules for testing ---
    // In a real Duktape environment, these would be provided by the host.

    // global.GTAV = {
    //     HUD: {
    //         GET_FIRST_BLIP_INFO_ID: function(blipIcon) {
    //             if (blipIcon === blipEnums.BlipIcon.WAYPOINT) return 1001;
    //             if (blipIcon === blipEnums.BlipIcon.PERSONAL_VEHICLE_CAR) return 1002;
    //             if (blipIcon === blipEnums.BlipIcon.PERSONAL_VEHICLE_BIKE) return 0; // No bike
    //             return 0;
    //         },
    //         DOES_BLIP_EXIST: function(blipId) { return blipId !== 0; },
    //         GET_BLIP_COORDS: function(blipId) { return { x: 100.0, y: 200.0, z: 300.0 }; },
    //         GET_BLIP_INFO_ID_ENTITY_INDEX: function(blipId) { return 5001; }
    //     },
    //     STREAMING: {
    //         IS_MODEL_A_PED: function(model) { return model === 12345; },
    //         IS_MODEL_A_VEHICLE: function(model) { return [67890, 11223, 44556, 77889].includes(model); }
    //     },
    //     VEHICLE: {
    //         IS_THIS_MODEL_A_PLANE: function(model) { return model === 11223; },
    //         IS_THIS_MODEL_A_HELI: function(model) { return model === 44556; },
    //         IS_THIS_MODEL_A_BIKE: function(model) { return model === 77889; }
    //     },
    //     ZONE: {
    //         GET_NAME_OF_ZONE: function(x, y, z) {
    //             if (x === 10.0) return "DELPERO";
    //             if (x === 20.0) return "ROCKFORD";
    //             return "UNKNOWN";
    //         }
    //     }
    // };

    // global.blipEnums = {
    //     BlipIcon: {
    //         WAYPOINT: 1,
    //         PERSONAL_VEHICLE_CAR: 2,
    //         PERSONAL_VEHICLE_BIKE: 3,
    //         STANDARD: 4,
    //         PLANE: 5,
    //         HELICOPTER: 6
    //     }
    // };

    // global.fs = {
    //     _files: {},
    //     readFile: function(path) { return this._files[path] || ""; },
    //     fileExists: function(path) { return path in this._files && this._files[path] !== ""; },
    //     writeFile: function(path, content) { this._files[path] = content; }
    // };

    // // Setup mock zones.json content
    // fs.writeFile("zones.json", JSON.stringify([
    //     { Name: "DELPERO", DisplayName: "Del Perro Beach" },
    //     { Name: "ROCKFORD", DisplayName: "Rockford Hills" }
    // ]));

    // // Test getWaypointCoords
    // const waypoint = mapUtils.getWaypointCoords();
    // console.log(`Waypoint Coords:`, waypoint); // Expected: { x: 100, y: 200, z: 0 }

    // // Test getPersonalVehicle
    // const personalVeh = mapUtils.getPersonalVehicle();
    // console.log(`Personal Vehicle Handle: ${personalVeh}`); // Expected: 5001

    // // Test getBlipFromEntityModel
    // console.log(`Blip for Ped (12345): ${mapUtils.getBlipFromEntityModel(12345)}`); // Expected: STANDARD
    // console.log(`Blip for Plane (11223): ${mapUtils.getBlipFromEntityModel(11223)}`); // Expected: PLANE
    // console.log(`Blip for Car (67890): ${mapUtils.getBlipFromEntityModel(67890)}`); // Expected: PERSONAL_VEHICLE_CAR

    // // Test getZoneName
    // console.log(`Zone Name (10,20,30): ${mapUtils.getZoneName(10.0, 20.0, 30.0)}`); // Expected: Del Perro Beach
    // console.log(`Zone Name (20,40,60): ${mapUtils.getZoneName(20.0, 40.0, 60.0)}`); // Expected: Rockford Hills
    // console.log(`Zone Name (99,99,99): ${mapUtils.getZoneName(99.0, 99.0, 99.0)}`); // Expected: UNKNOWN
}
*/

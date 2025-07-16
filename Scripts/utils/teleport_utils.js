/// <reference path="../js_typings/gctv.d.ts" />
/// <reference path="../js_typings/gtav_natives.d.ts" /> 

/**
 * This utility script provides functions for teleporting entities within the game world.
 */

const teleportUtils = { 
    /**
     * Teleports an entity to specified coordinates, adjusting Z-height if needed to land on ground.
     * If `coords.z` is 0.0, it attempts to find a safe ground Z-coordinate by iterating through
     * various heights. Otherwise, it teleports directly to `coords.z + 2.0`.
     * @param {number} entity - The handle of the entity to teleport.
     * @param {object} coords - An object with 'x', 'y', 'z' coordinates (z=0.0 to find ground, otherwise absolute).
     */
    teleportEntity: function(entity, coords) { // Use function expression
        // Predefined heights to try when searching for ground Z.
        var heights = [ 100.0, 150.0, 50.0, 0.0, 200.0, 250.0, 300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0 ]; // Use var

        // If the target Z-coordinate is 0.0, attempt to find ground Z.
        if (coords.z === 0.0) {
            var foundGround = false; // Use var
            // Iterate through predefined heights to find a valid ground Z.
            for (var i = 0; i < heights.length; i++) { // Use var for loop variable
                var height = heights[i]; // Use var
                // Temporarily set entity coordinates to the current test height. Native function names are UPPER_SNAKE_CASE.
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, coords.x, coords.y, height, false, false, true);
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(entity); // Clear ped tasks to prevent falling/glitching.
                
                // Attempt to get the ground Z-coordinate at the current XY and test height.
                // Assuming MISC.GET_GROUND_Z_FOR_3D_COORD returns an array [success_bool, ground_z_value]
                var groundResult = MISC.GET_GROUND_Z_FOR_3D_COORD(coords.x, coords.y, height); // Use var
                var success = groundResult[0]; // Use var
                var groundZ = groundResult[1]; // Use var
                
                if (success) {
                    // If ground Z is found, set entity coords to ground Z + 2.0 (to avoid sinking into ground).
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, coords.x, coords.y, groundZ + 2.0, false, false, true);
                    foundGround = true;
                    break; // Exit loop as ground Z is found and entity is moved.
                }
            }
            
            if (!foundGround) {
                console.error("Failed to find ground Z for entity " + entity + " at (" + coords.x + "," + coords.y + ").");
            }
        } else {
            // If coords.z is not 0.0, teleport directly to the specified Z + 2.0.
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, coords.x, coords.y, coords.z + 2.0, false, false, true);
        }
    }
};

/*
// Example Usage (commented out for production, uncomment for testing in your Duktape environment)
// To run this example, you would need to mock the global GCTV API functions
// and modules (GTAV, console).
if (typeof console !== 'undefined') {
    console.log("--- Testing teleportUtils JavaScript ---");

    // --- Mock GTAV module for testing ---
    // In a real Duktape environment, these would be provided by the host.

    // global.GTAV = {
    //     ENTITY: {
    //         SET_ENTITY_COORDS_NO_OFFSET: function(entity, x, y, z, p1, p2, p3) {
    //             console.log(`Mock: Entity ${entity} coords set to (${x}, ${y}, ${z})`);
    //         }
    //     },
    //     TASK: {
    //         CLEAR_PED_TASKS_IMMEDIATELY: function(entity) {
    //             console.log(`Mock: Ped tasks cleared for entity ${entity}`);
    //         }
    //     },
    //     MISC: {
    //         _groundZMap: {
    //             "10,20,100": 98.5, // Example ground Z
    //             "10,20,150": 98.5,
    //             "10,20,50": 98.5,
    //             "10,20,0": 98.5,
    //             "10,20,200": 198.0,
    //             "10,20,300": 298.0,
    //             "50,50,100": 95.0,
    //         },
    //         GET_GROUND_Z_FOR_3D_COORD: function(x, y, zTest) {
    //             var key = x + "," + y + "," + zTest;
    //             if (this._groundZMap.hasOwnProperty(key)) {
    //                 console.log(`Mock: Found ground Z for (${x},${y},${zTest}) -> ${this._groundZMap[key]}`);
    //                 return [true, this._groundZMap[key]];
    //             }
    //             console.log(`Mock: No ground Z found for (${x},${y},${zTest})`);
    //             return [false, 0.0]; // Return false and a default value if not found
    //         }
    //     }
    // };

    // // Test teleportEntity with z=0.0 (find ground)
    // console.log("\n--- Testing teleportEntity (find ground) ---");
    // var testEntity1 = 1;
    // var testCoords1 = { x: 10.0, y: 20.0, z: 0.0 };
    // teleportUtils.teleportEntity(testEntity1, testCoords1);

    // // Test teleportEntity with specific z
    // console.log("\n--- Testing teleportEntity (specific Z) ---");
    // var testEntity2 = 2;
    // var testCoords2 = { x: 50.0, y: 50.0, z: 100.0 };
    // teleportUtils.teleportEntity(testEntity2, testCoords2);

    // // Test teleportEntity with z=0.0 but no ground found (mock failure)
    // console.log("\n--- Testing teleportEntity (find ground, no success) ---");
    // var testEntity3 = 3;
    // var testCoords3 = { x: 999.0, y: 999.0, z: 0.0 }; // Coordinates not in mock map
    // teleportUtils.teleportEntity(testEntity3, testCoords3);
}
*/

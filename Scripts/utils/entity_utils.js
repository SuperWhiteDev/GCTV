/// <reference path="../js_typings/gctv.d.ts" />
/// <reference path="../js_typings/gtav_natives.d.ts" /> 

/**
 * A utility object providing helper functions for interacting with game entities.
 */
const entityUtils = {
    /**
     * Checks if an entity is within a specified cubic radius around target coordinates.
     * This function expects the entity's coordinates directly as an object with x, y, z properties.
     *
     * @param {object} entityCoords - An object with 'x', 'y', 'z' properties representing the entity's coordinates.
     * @param {number} targetX - The X-coordinate of the target center.
     * @param {number} targetY - The Y-coordinate of the target center.
     * @param {number} targetZ - The Z-coordinate of the target center.
     * @param {number} radius - The cubic radius around the target coordinates.
     * @returns {boolean} True if the entity is within the radius, false otherwise.
     */
    isEntityAtCoords(entityCoords, targetX, targetY, targetZ, radius) {
        // Check if the entity's coordinates are within the cubic radius of the target coordinates.
        // Math.abs calculates the absolute difference.
        if (Math.abs(entityCoords.x - targetX) <= radius &&
            Math.abs(entityCoords.y - targetY) <= radius &&
            Math.abs(entityCoords.z - targetZ) <= radius) {
            return true; // Entity found within the specified coordinates.
        }
        
        return false; // Entity not found within the specified coordinates.
    }
};

/*
// Example Usage (commented out for production, uncomment for testing in your Duktape environment)
if (typeof console !== 'undefined') {
    console.log("--- Testing entityUtils JavaScript ---");

    // Mock entity coordinates
    const mockEntity1Coords = { x: 10.0, y: 20.0, z: 30.0 };
    const mockEntity2Coords = { x: 15.0, y: 25.0, z: 35.0 };
    const mockEntity3Coords = { x: 100.0, y: 200.0, z: 300.0 };

    const targetCoords = { x: 12.0, y: 22.0, z: 32.0 };
    const searchRadius = 3.0;

    // Test cases
    console.log(`Entity 1 at target coords (radius ${searchRadius}): ${entityUtils.isEntityAtCoords(mockEntity1Coords, targetCoords.x, targetCoords.y, targetCoords.z, searchRadius)}`); // Expected: true
    console.log(`Entity 2 at target coords (radius ${searchRadius}): ${entityUtils.isEntityAtCoords(mockEntity2Coords, targetCoords.x, targetCoords.y, targetCoords.z, searchRadius)}`); // Expected: false (x diff is 3, > radius)
    console.log(`Entity 3 at target coords (radius ${searchRadius}): ${entityUtils.isEntityAtCoords(mockEntity3Coords, targetCoords.x, targetCoords.y, targetCoords.z, searchRadius)}`); // Expected: false

    const searchRadiusLarge = 100.0;
    console.log(`Entity 3 at target coords (radius ${searchRadiusLarge}): ${entityUtils.isEntityAtCoords(mockEntity3Coords, targetCoords.x, targetCoords.y, targetCoords.z, searchRadiusLarge)}`); // Expected: true
}
*/

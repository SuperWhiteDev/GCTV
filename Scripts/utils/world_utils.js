/// <reference path="../js_typings/gctv.d.ts" />
/// <reference path="../js_typings/gtav_natives.d.ts" /> 

/**
 * This utility script provides functions for managing aspects of the game world,
 * such as loading specific map interiors (IPLs) and finding nearby entities.
 */

var worldUtils = {
    /**
     * Initializes the North Yankton map region by requesting all necessary IPLs.
     * This makes the North Yankton area visible and loaded in the game.
     */
    initNorthYankton: function() { // Use function expression
        // List of IPLs (Interior Proxy Levels) required for North Yankton.
        var ipls = [ // Use var
            "plg_01", "prologue01", "prologue01_lod", "prologue01c", "prologue01c_lod", "prologue01d", "prologue01d_lod",
            "prologue01e", "prologue01e_lod", "prologue01f", "prologue01f_lod", "prologue01g", "prologue01h", "prologue01h_lod",
            "prologue01i", "prologue01i_lod", "prologue01j", "prologue01j_lod", "prologue01k", "prologue01k_lod",
            "prologue01z", "prologue01z_lod", "plg_02", "prologue02", "prologue02_lod", "plg_03",
            "prologue03", "prologue03_lod", "prologue03b", "prologue03b_lod", "prologue03_grv_dug", "prologue03_grv_dug_lod",
            "prologue_grv_torch", "plg_04", "prologue04", "prologue04_lod", "prologue04b", "prologue04b_lod",
            "prologue04_cover", "des_protree_end", "des_protree_start", "des_protree_start_lod", "plg_05",
            "prologue05", "prologue05_lod", "prologue05b", "prologue05b_lod", "plg_06", 
            "prologue06", "prologue06_lod", "prologue06b", "prologue06b_lod", "prologue06_int",
            "prologue06_int_lod", "prologue06_pannel", "prologue06_pannel_lod", "prologue_m2_door", "prologue_m2_door_lod",
            "plg_occl_00", "prologue_occl", "plg_rd", "prologuerd", "prologuerdb", "prologuerd_lod"
        ];

        // Request each IPL to be loaded. Native function names are UPPER_SNAKE_CASE.
        for (var i = 0; i < ipls.length; i++) { // Use var for loop variable
            STREAMING.REQUEST_IPL(ipls[i]);
        }

        // Set the minimap to display the prologue (North Yankton) map. Native function names are UPPER_SNAKE_CASE.
        HUD.SET_MINIMAP_IN_PROLOGUE(true);
    },

    /**
     * Initializes the Cayo Perico map region by requesting all necessary IPLs.
     * This makes the Cayo Perico island visible and loaded in the game.
     */
    initCayoPerico: function() { // Use function expression
        // List of IPLs (Interior Proxy Levels) required for Cayo Perico.
        var ipls = [ // Use var
            "h4_ch2_mansion_final", "h4_clubposter_keinemusik", "h4_clubposter_moodymann",
            "h4_clubposter_palmstraxx", "h4_islandx_yacht_01", "h4_islandx_yacht_01_int",
            "h4_mpapa_yacht", "h4_islandx_yacht_02", "h4_islandx_yacht_02_int",
            "h4_mpapa_yacht", "h4_islandx_yacht_03", "h4_islandx_yacht_03_int",
            "h4_mpapa_yacht", "h4_boatblockers", "h4_islandx",
            "h4_islandx_disc_strandedshark", "h4_islandx_disc_strandedwhale",
            "h4_islandx_props", "h4_islandx_sea_mines", "h4_aa_guns",
            "h4_beach", "h4_beach_bar_props", "h4_beach_party",
            "h4_beach_props", "h4_beach_props_party", "h4_island_padlock_props",
            "h4_islandairstrip", "h4_islandairstrip_doorsclosed",
            "h4_islandairstrip_doorsopen", "h4_islandairstrip_hangar_props",
            "h4_islandairstrip_props", "h4_islandairstrip_propsb",
            "h4_islandx_barrack_hatch", "h4_islandx_barrack_props",
            "h4_islandx_checkpoint", "h4_islandx_checkpoint_props",
            "h4_islandx_maindock", "h4_islandx_maindock_props",
            "h4_islandx_maindock_props_2", "h4_islandx_mansion",
            "h4_islandx_mansion_b", "h4_islandx_mansion_b_side_fence",
            "h4_islandx_mansion_entrance_fence", "h4_islandx_mansion_guardfence",
            "h4_islandx_mansion_lights", "h4_islandx_mansion_lockup_01",
            "h4_dlc_island_store_2", "h4_islandx_mansion_lockup_02",
            "h4_dlc_island_store_3", "h4_islandx_mansion_lockup_03",
            "h4_dlc_island_store_1", "h4_islandx_mansion_office",
            "h4_dlc_island_office", "h4_islandx_mansion_props",
            "h4_islandx_mansion_vault", "h4_dlc_island_vault",
            "h4_islandxcanal_props", "h4_islandxdock",
            "h4_islandxdock_props", "h4_islandxdock_props_2",
            "h4_islandxdock_water_hatch", "h4_islandxtower",
            "h4_islandxtower_veg", "h4_mansion_gate_broken",
            "h4_mansion_gate_closed", "h4_mansion_remains_cage",
            "h4_ne_ipl_00", "h4_ne_ipl_01", "h4_ne_ipl_02",
            "h4_ne_ipl_03", "h4_ne_ipl_04", "h4_ne_ipl_05",
            "h4_ne_ipl_06", "h4_ne_ipl_07", "h4_ne_ipl_08",
            "h4_ne_ipl_09", "h4_nw_ipl_00", "h4_nw_ipl_01",
            "h4_nw_ipl_02", "h4_nw_ipl_03", "h4_nw_ipl_04",
            "h4_nw_ipl_05", "h4_nw_ipl_06", "h4_nw_ipl_07",
            "h4_nw_ipl_08", "h4_nw_ipl_09", "h4_se_ipl_00",
            "h4_se_ipl_01", "h4_se_ipl_02", "h4_se_ipl_03",
            "h4_se_ipl_04", "h4_se_ipl_05", "h4_se_ipl_06",
            "h4_se_ipl_07", "h4_se_ipl_08", "h4_se_ipl_09",
            "h4_sw_ipl_00", "h4_sw_ipl_01", "h4_sw_ipl_02",
            "h4_sw_ipl_03", "h4_sw_ipl_04", "h4_sw_ipl_05",
            "h4_sw_ipl_06", "h4_sw_ipl_07", "h4_sw_ipl_08",
            "h4_sw_ipl_09", "h4_underwater_gate_closed",
            "h4_islandx_placement_01", "h4_islandx_placement_02",
            "h4_islandx_placement_03", "h4_islandx_placement_04",
            "h4_islandx_placement_05", "h4_islandx_placement_06",
            "h4_islandx_placement_07", "h4_islandx_placement_08",
            "h4_islandx_placement_09", "h4_islandx_placement_10",
            "h4_islandx_terrain_01", "h4_islandx_terrain_02",
            "h4_islandx_terrain_03", "h4_islandx_terrain_04",
            "h4_islandx_terrain_05", "h4_islandx_terrain_06",
            "h4_islandx_terrain_props_05_a", "h4_islandx_terrain_props_05_b",
            "h4_islandx_terrain_props_05_c", "h4_islandx_terrain_props_05_d",
            "h4_islandx_terrain_props_05_e", "h4_islandx_terrain_props_05_f",
            "h4_islandx_terrain_props_06_a", "h4_islandx_terrain_props_06_b",
            "h4_islandx_terrain_props_06_c"
        ];

        // Request each IPL to be loaded. Native function names are UPPER_SNAKE_CASE.
        for (var i = 0; i < ipls.length; i++) { // Use var for loop variable
            STREAMING.REQUEST_IPL(ipls[i]);
        }

        // Load global water file (often related to Cayo Perico's unique water). Native function names are UPPER_SNAKE_CASE.
        STREAMING.LOAD_GLOBAL_WATER_FILE(1);
        // Set the minimap to display the island map (Cayo Perico). Native function names are UPPER_SNAKE_CASE.
        HUD.SET_USE_ISLAND_MAP(true);
    },

    /**
     * Gets the nearest vehicle to a specified entity within a given radius.
     * @param {number} entity - The handle of the entity to search around.
     * @param {number} radius - The search radius.
     * @returns {number} The handle of the nearest vehicle, or 0 if no vehicle is found.
     */
    getNearestVehicleToEntity: function(entity, radius) { // Use function expression
        // Get the coordinates of the reference entity. Native function names are UPPER_SNAKE_CASE.
        var entityCoords = ENTITY.GET_ENTITY_COORDS(entity, true); // Use var
        
        // Check if any vehicle exists near the specified point. Native function names are UPPER_SNAKE_CASE.
        if (VEHICLE.IS_ANY_VEHICLE_NEAR_POINT(entityCoords.x, entityCoords.y, entityCoords.z + 0.1, radius)) {
            // Assuming PED.GET_PED_NEARBY_VEHICLES returns an array of handles,
            // and we only need the first one as max_num_of_veh is 1.
            var maxNumOfVeh = 1; // Use var
            var nearbyVehicles = PED.GET_PED_NEARBY_VEHICLES(entity, maxNumOfVeh); // Use var
            
            if (nearbyVehicles && nearbyVehicles.length > 0) {
                return nearbyVehicles[0]; // Return the handle of the nearest vehicle.
            } else {
                return 0; // Should not happen if IS_ANY_VEHICLE_NEAR_POINT is true, but as a safeguard.
            }
        } else {
            return 0; // No vehicle found nearby.
        }
    },

    /**
     * Gets the nearest pedestrian (ped) to a specified entity within a given radius.
     * @param {number} entity - The handle of the entity to search around.
     * @param {number} radius - The search radius.
     * @returns {number} The handle of the nearest ped, or 0 if no ped is found.
     */
    getNearestPedToEntity: function(entity, radius) { // Use function expression
        // Get the coordinates of the reference entity. Native function names are UPPER_SNAKE_CASE.
        var entityCoords = ENTITY.GET_ENTITY_COORDS(entity, true); // Use var
        
        // Check if any ped exists near the specified point. Native function names are UPPER_SNAKE_CASE.
        if (PED.IS_ANY_PED_NEAR_POINT(entityCoords.x, entityCoords.y, entityCoords.z + 0.1, radius)) {
            // Assuming PED.GET_PED_NEARBY_PEDS returns an array of handles,
            // and we only need the first one as max_num_of_peds is 1.
            var maxNumOfPeds = 1; // Use var
            var nearbyPeds = PED.GET_PED_NEARBY_PEDS(entity, maxNumOfPeds, -1); // Use var

            if (nearbyPeds && nearbyPeds.length > 0) {
                return nearbyPeds[0]; // Return the handle of the nearest ped.
            } else {
                return 0; // Should not happen if IS_ANY_PED_NEAR_POINT is true, but as a safeguard.
            }
        } else {
            return 0; // No ped found nearby.
        }
    }
};

/*
// Example Usage (commented out for production, uncomment for testing in your Duktape environment)
// To run this example, you would need to mock the global GCTV API functions
// and modules (GTAV, console).
if (typeof console !== 'undefined') {
    console.log("--- Testing worldUtils JavaScript ---");

    // --- Mock GTAV module for testing ---
    // global.GTAV = {
    //     STREAMING: {
    //         REQUEST_IPL: function(iplName) { console.log(`Mock: Requested IPL: ${iplName}`); },
    //         LOAD_GLOBAL_WATER_FILE: function(p) { console.log(`Mock: Loaded global water file: ${p}`); }
    //     },
    //     HUD: {
    //         SET_MINIMAP_IN_PROLOGUE: function(state) { console.log(`Mock: Minimap in prologue: ${state}`); },
    //         SET_USE_ISLAND_MAP: function(state) { console.log(`Mock: Use island map: ${state}`); }
    //     },
    //     ENTITY: {
    //         GET_ENTITY_COORDS: function(entity, p) {
    //             if (entity === 1) return { x: 100.0, y: 200.0, z: 30.0 };
    //             if (entity === 2) return { x: 50.0, y: 50.0, z: 20.0 };
    //             return { x: 0.0, y: 0.0, z: 0.0 };
    //         }
    //     },
    //     VEHICLE: {
    //         IS_ANY_VEHICLE_NEAR_POINT: function(x, y, z, radius) {
    //             // Simulate a vehicle near (100,200,30) with radius 50
    //             return (x === 100.0 && y === 200.0 && radius === 50.0);
    //         }
    //     },
    //     PED: {
    //         IS_ANY_PED_NEAR_POINT: function(x, y, z, radius) {
    //             // Simulate a ped near (50,50,20) with radius 20
    //             return (x === 50.0 && y === 50.0 && radius === 20.0);
    //         },
    //         GET_PED_NEARBY_VEHICLES: function(entity, maxCount) {
    //             if (entity === 1 && maxCount === 1) return [1001]; // Mock vehicle handle
    //             return [];
    //         },
    //         GET_PED_NEARBY_PEDS: function(entity, maxCount) {
    //             if (entity === 2 && maxCount === 1) return [2001]; // Mock ped handle
    //             return [];
    //         }
    //     }
    // };

    // // Test initNorthYankton
    // console.log("\n--- Testing initNorthYankton ---");
    // worldUtils.initNorthYankton();

    // // Test initCayoPerico
    // console.log("\n--- Testing initCayoPerico ---");
    // worldUtils.initCayoPerico();

    // // Test getNearestVehicleToEntity
    // console.log("\n--- Testing getNearestVehicleToEntity ---");
    // var nearestVeh = worldUtils.getNearestVehicleToEntity(1, 50.0);
    // console.log("Nearest Vehicle Handle: " + nearestVeh); // Expected: 1001
    // var nearestVehNone = worldUtils.getNearestVehicleToEntity(1, 10.0); // Too small radius
    // console.log("Nearest Vehicle Handle (none found): " + nearestVehNone); // Expected: 0

    // // Test getNearestPedToEntity
    // console.log("\n--- Testing getNearestPedToEntity ---");
    // var nearestPed = worldUtils.getNearestPedToEntity(2, 20.0);
    // console.log("Nearest Ped Handle: " + nearestPed); // Expected: 2001
    // var nearestPedNone = worldUtils.getNearestPedToEntity(2, 5.0); // Too small radius
    // console.log("Nearest Ped Handle (none found): " + nearestPedNone); // Expected: 0
}
*/

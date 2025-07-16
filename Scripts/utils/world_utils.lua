-- This utility script provides functions for managing aspects of the game world,
-- such as loading specific map interiors (IPLs) and finding nearby entities.

local world_utils = {} -- Create a table to hold our utility functions.

--- Initializes the North Yankton map region by requesting all necessary IPLs.
-- This makes the North Yankton area visible and loaded in the game.
-- Assumes `STREAMING` and `HUD` are global objects from the GTAV API.
function world_utils.init_north_yankton()
    -- List of IPLs (Interior Proxy Levels) required for North Yankton.
    local ipls = {
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
    }

    -- Request each IPL to be loaded.
    for i = 1, #ipls do
        STREAMING.REQUEST_IPL(ipls[i])
    end

    -- Set the minimap to display the prologue (North Yankton) map.
    HUD.SET_MINIMAP_IN_PROLOGUE(true)
end

--- Initializes the Cayo Perico map region by requesting all necessary IPLs.
-- This makes the Cayo Perico island visible and loaded in the game.
-- Assumes `STREAMING` and `HUD` are global objects from the GTAV API.
function world_utils.init_cayo_perico()
    -- List of IPLs (Interior Proxy Levels) required for Cayo Perico.
    local ipls = {
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
    }

    -- Request each IPL to be loaded.
    for i = 1, #ipls do
        STREAMING.REQUEST_IPL(ipls[i])
    end

    -- Load global water file (often related to Cayo Perico's unique water).
    STREAMING.LOAD_GLOBAL_WATER_FILE(1)
    -- Set the minimap to display the island map (Cayo Perico).
    HUD.SET_USE_ISLAND_MAP(true)
end

--- Gets the nearest vehicle to a specified entity within a given radius.
-- for low-level memory/array operations.
-- @param entity number The handle of the entity to search around.
-- @param radius number The search radius.
-- @returns number The handle of the nearest vehicle, or 0.0 if no vehicle is found.
function world_utils.get_nearest_vehicle_to_entity(entity, radius)
    local nearest_veh = nil
    local max_num_of_veh = 1 -- We only need the single nearest vehicle.

    -- Get the coordinates of the reference entity.
    local entity_coords = ENTITY.GET_ENTITY_COORDS(entity, true)
    
    -- Check if any vehicle exists near the specified point.
    if VEHICLE.IS_ANY_VEHICLE_NEAR_POINT(entity_coords.x, entity_coords.y, entity_coords.z + 0.1, radius) then
        -- Allocate a memory array to receive vehicle handles.
        -- Size: 2 ints (header) + max_num_of_veh * 2 ints (for each vehicle handle, assuming 64-bit or two 32-bit parts)
        local array_ptr = New(2 + max_num_of_veh * 2)
        Game.WriteInt(array_ptr, max_num_of_veh) -- Write the max number of vehicles to the array header.

        -- Populate the array with nearby vehicle handles.
        PED.GET_PED_NEARBY_VEHICLES(entity, array_ptr)

        -- Read the first vehicle handle from the array (offset by 8 bytes for header).
        nearest_veh = Game.ReadInt(array_ptr + 8)

        Delete(array_ptr) -- Deallocate the memory.
        return nearest_veh
    else
        return 0.0 -- No vehicle found nearby.
    end
end

--- Gets the nearest ped to a specified entity within a given radius.
-- for low-level memory/array operations.
-- @param entity number The handle of the entity to search around.
-- @param radius number The search radius.
-- @returns number The handle of the nearest ped, or 0.0 if no ped is found.
function world_utils.get_nearest_ped_to_entity(entity, radius)
    local nearest_ped = nil
    local max_num_of_peds = 1 -- We only need the single nearest ped.

    -- Get the coordinates of the reference entity.
    local entity_coords = ENTITY.GET_ENTITY_COORDS(entity, true)
    
    -- Check if any ped exists near the specified point.
    if PED.IS_ANY_PED_NEAR_POINT(entity_coords.x, entity_coords.y, entity_coords.z + 0.1, radius) then
        -- Allocate a memory array to receive ped handles.
        -- Size: 2 ints (header) + max_num_of_peds * 2 ints (for each ped handle).
        local array_ptr = New(2 + max_num_of_peds * 2)
        Game.WriteInt(array_ptr, max_num_of_peds) -- Write the max number of peds to the array header.

        -- Populate the array with nearby ped handles.
        PED.GET_PED_NEARBY_PEDS(entity, array_ptr, -1)

        -- Read the first ped handle from the array (offset by 8 bytes for header).
        nearest_ped = Game.ReadInt(array_ptr + 8)

        Game.Delete(array_ptr) -- Deallocate the memory.
        return nearest_ped
    else
        return 0.0 -- No ped found nearby.
    end
end

return world_utils -- Return the utility table for use in other scripts.

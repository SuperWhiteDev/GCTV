# This utility script provides functions for managing aspects of the game world,
# such as loading specific map interiors (IPLs) and finding nearby entities.

# Assume these modules are available in the GCTV Python environment.
import GTAV # For STREAMING, HUD, ENTITY, VEHICLE, PED native functions.

class WorldUtils:
    """
    A utility class providing functions for managing aspects of the game world.

    This implementation assumes the GCTV Python environment provides the
    following global modules/objects:
    - `GTAV`: For `STREAMING`, `HUD`, `ENTITY`, `VEHICLE`, `PED`
              (native functions in UPPER_SNAKE_CASE).
    - `DisplayError`: A global function for displaying errors.
    
    Note on nearby entities: Python's GTAV API is assumed to provide a more
    direct way to get nearby entities (e.g., returning a list), avoiding
    low-level memory pointer operations.
    """

    @staticmethod
    def init_north_yankton():
        """
        Initializes the North Yankton map region by requesting all necessary IPLs.
        This makes the North Yankton area visible and loaded in the game.
        """
        # List of IPLs (Interior Proxy Levels) required for North Yankton.
        ipls = [
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
        ]

        # Request each IPL to be loaded. Native function names are UPPER_SNAKE_CASE.
        for ipl in ipls:
            GTAV.STREAMING.REQUEST_IPL(ipl)

        # Set the minimap to display the prologue (North Yankton) map. Native function names are UPPER_SNAKE_CASE.
        GTAV.HUD.SET_MINIMAP_IN_PROLOGUE(True)

    @staticmethod
    def init_cayo_perico():
        """
        Initializes the Cayo Perico map region by requesting all necessary IPLs.
        This makes the Cayo Perico island visible and loaded in the game.
        """
        # List of IPLs (Interior Proxy Levels) required for Cayo Perico.
        ipls = [
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
        ]

        # Request each IPL to be loaded. Native function names are UPPER_SNAKE_CASE.
        for ipl in ipls:
            GTAV.STREAMING.REQUEST_IPL(ipl)

        # Load global water file (often related to Cayo Perico's unique water). Native function names are UPPER_SNAKE_CASE.
        GTAV.STREAMING.LOAD_GLOBAL_WATER_FILE(1)
        # Set the minimap to display the island map (Cayo Perico). Native function names are UPPER_SNAKE_CASE.
        GTAV.HUD.SET_USE_ISLAND_MAP(True)

    @staticmethod
    def get_nearest_vehicle_to_entity(entity, radius):
        """
        Gets the nearest vehicle to a specified entity within a given radius.

        Args:
            entity (int): The handle of the entity to search around.
            radius (float): The search radius.

        Returns:
            int or 0: The handle of the nearest vehicle, or 0 if no vehicle is found.
                      Returns 0 (int) to match Lua's 0.0 for "no entity".
        """
        # Get the coordinates of the reference entity. Native function names are UPPER_SNAKE_CASE.
        entity_coords = GTAV.ENTITY.GET_ENTITY_COORDS(entity, True)
        
        # Check if any vehicle exists near the specified point. Native function names are UPPER_SNAKE_CASE.
        if GTAV.VEHICLE.IS_ANY_VEHICLE_NEAR_POINT(entity_coords['x'], entity_coords['y'], entity_coords['z'] + 0.1, radius):
            # Assuming GTAV.PED.GET_PED_NEARBY_VEHICLES returns a list of handles,
            # and we only need the first one as max_num_of_veh is 1.
            # If the API only returns a single nearest vehicle, adapt accordingly.
            max_num_of_veh = 1
            nearby_vehicles = GTAV.PED.GET_PED_NEARBY_VEHICLES(entity, max_num_of_veh)
            
            if nearby_vehicles and len(nearby_vehicles) > 0:
                return nearby_vehicles[0] # Return the handle of the nearest vehicle.
            else:
                return 0 # Should not happen if IS_ANY_VEHICLE_NEAR_POINT is true, but as a safeguard.
        else:
            return 0 # No vehicle found nearby.

    @staticmethod
    def get_nearest_ped_to_entity(entity, radius):
        """
        Gets the nearest pedestrian (ped) to a specified entity within a given radius.

        Args:
            entity (int): The handle of the entity to search around.
            radius (float): The search radius.

        Returns:
            int or 0: The handle of the nearest ped, or 0 if no ped is found.
                      Returns 0 (int) to match Lua's 0.0 for "no entity".
        """
        # Get the coordinates of the reference entity. Native function names are UPPER_SNAKE_CASE.
        entity_coords = GTAV.ENTITY.GET_ENTITY_COORDS(entity, True)
        
        # Check if any ped exists near the specified point. Native function names are UPPER_SNAKE_CASE.
        if GTAV.PED.IS_ANY_PED_NEAR_POINT(entity_coords['x'], entity_coords['y'], entity_coords['z'] + 0.1, radius):
            # Assuming GTAV.PED.GET_PED_NEARBY_PEDS returns a list of handles,
            # and we only need the first one as max_num_of_peds is 1.
            max_num_of_peds = 1
            nearby_peds = GTAV.PED.GET_PED_NEARBY_PEDS(entity, max_num_of_peds, -1)

            if nearby_peds and len(nearby_peds) > 0:
                return nearby_peds[0] # Return the handle of the nearest ped.
            else:
                return 0 # Should not happen if IS_ANY_PED_NEAR_POINT is true, but as a safeguard.
        else:
            return 0 # No ped found nearby.

# Example Usage (for testing purposes, requires mocking GTAV and DisplayError)
"""
if __name__ == "__main__":
    print("--- Testing WorldUtils Python ---")

    # --- Mock GTAV module for testing ---
    class MockSTREAMING:
        def REQUEST_IPL(self, ipl_name): print(f"Mock: Requested IPL: {ipl_name}")
        def LOAD_GLOBAL_WATER_FILE(self, p): print(f"Mock: Loaded global water file: {p}")

    class MockHUD:
        def SET_MINIMAP_IN_PROLOGUE(self, state): print(f"Mock: Minimap in prologue: {state}")
        def SET_USE_ISLAND_MAP(self, state): print(f"Mock: Use island map: {state}")

    class MockENTITY:
        def GET_ENTITY_COORDS(self, entity, p):
            if entity == 1: return {'x': 100.0, 'y': 200.0, 'z': 30.0}
            if entity == 2: return {'x': 50.0, 'y': 50.0, 'z': 20.0}
            return {'x': 0.0, 'y': 0.0, 'z': 0.0}

    class MockVEHICLE:
        def IS_ANY_VEHICLE_NEAR_POINT(self, x, y, z, radius):
            # Simulate a vehicle near (100,200,30) with radius 50
            return (x == 100.0 and y == 200.0 and radius == 50.0)

    class MockPED:
        def IS_ANY_PED_NEAR_POINT(self, x, y, z, radius):
            # Simulate a ped near (50,50,20) with radius 20
            return (x == 50.0 and y == 50.0 and radius == 20.0)

        def GET_PED_NEARBY_VEHICLES(self, entity, max_count):
            if entity == 1 and max_count == 1: return [1001] # Mock vehicle handle
            return []

        def GET_PED_NEARBY_PEDS(self, entity, max_count):
            if entity == 2 and max_count == 1: return [2001] # Mock ped handle
            return []

    class MockGTAV_Module:
        def __init__(self):
            self.STREAMING = MockSTREAMING()
            self.HUD = MockHUD()
            self.ENTITY = MockENTITY()
            self.VEHICLE = MockVEHICLE()
            self.PED = MockPED()

    # Assign mocks
    GTAV = MockGTAV_Module()
    # --- End Mocking ---

    # Test init_north_yankton
    print("\n--- Testing init_north_yankton ---")
    WorldUtils.init_north_yankton()

    # Test init_cayo_perico
    print("\n--- Testing init_cayo_perico ---")
    WorldUtils.init_cayo_perico()

    # Test get_nearest_vehicle_to_entity
    print("\n--- Testing get_nearest_vehicle_to_entity ---")
    nearest_veh = WorldUtils.get_nearest_vehicle_to_entity(1, 50.0)
    print(f"Nearest Vehicle Handle: {nearest_veh}") # Expected: 1001
    nearest_veh_none = WorldUtils.get_nearest_vehicle_to_entity(1, 10.0) # Too small radius
    print(f"Nearest Vehicle Handle (none found): {nearest_veh_none}") # Expected: 0

    # Test get_nearest_ped_to_entity
    print("\n--- Testing get_nearest_ped_to_entity ---")
    nearest_ped = WorldUtils.get_nearest_ped_to_entity(2, 20.0)
    print(f"Nearest Ped Handle: {nearest_ped}") # Expected: 2001
    nearest_ped_none = WorldUtils.get_nearest_ped_to_entity(2, 5.0) # Too small radius
    print(f"Nearest Ped Handle (none found): {nearest_ped_none}") # Expected: 0
"""

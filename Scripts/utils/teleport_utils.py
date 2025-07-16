# This utility script provides functions for teleporting entities within the game world.

# Assume these modules are available in the GCTV Python environment.
import GTAV # For ENTITY, TASK, MISC native functions.


class TeleportUtils:
    """
    A utility class providing functions for teleporting entities within the game world.

    This implementation assumes the GCTV Python environment provides the
    following global modules/objects:
    - `GTAV`: For `ENTITY`, `TASK`, `MISC` (native functions in UPPER_SNAKE_CASE).
    - `DisplayError`: A global function for displaying errors.
    
    Note: `MISC.GET_GROUND_Z_FOR_3D_COORD` in Python is assumed to return a tuple
    `(success_bool, ground_z_value)` for direct use, unlike the Lua version which uses a pointer.
    """

    @staticmethod
    def teleport_entity(entity, coords):
        """
        Teleports an entity to specified coordinates, adjusting Z-height if needed to land on ground.
        If `coords['z']` is 0.0, it attempts to find a safe ground Z-coordinate by iterating through
        various heights. Otherwise, it teleports directly to `coords['z'] + 2.0`.

        Args:
            entity (int): The handle of the entity to teleport.
            coords (dict): A dictionary with 'x', 'y', 'z' coordinates (z=0.0 to find ground, otherwise absolute).
        """
        # Predefined heights to try when searching for ground Z.
        heights = [100.0, 150.0, 50.0, 0.0, 200.0, 250.0, 300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0]

        # If the target Z-coordinate is 0.0, attempt to find ground Z.
        if coords['z'] == 0.0:
            found_ground = False
            # Iterate through predefined heights to find a valid ground Z.
            for height in heights:
                # Temporarily set entity coordinates to the current test height. Native function names are UPPER_SNAKE_CASE.
                GTAV.ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, coords['x'], coords['y'], height, False, False, True)
                GTAV.TASK.CLEAR_PED_TASKS_IMMEDIATELY(entity) # Clear ped tasks to prevent falling/glitching.
                
                # Attempt to get the ground Z-coordinate at the current XY and test height.
                # Assuming GTAV.MISC.GET_GROUND_Z_FOR_3D_COORD returns (success_bool, ground_z_value)
                success, ground_z = GTAV.MISC.GET_GROUND_Z_FOR_3D_COORD(coords['x'], coords['y'], height)
                
                if success:
                    # If ground Z is found, set entity coords to ground Z + 2.0 (to avoid sinking into ground).
                    GTAV.ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, coords['x'], coords['y'], ground_z + 2.0, False, False, True)
                    found_ground = True
                    break # Exit loop as ground Z is found and entity is moved.
            
            #if not found_ground:
            #    GCT.DisplayError(False, f"Failed to find ground Z for entity {entity} at ({coords['x']},{coords['y']}).")
        else:
            # If coords['z'] is not 0.0, teleport directly to the specified Z + 2.0.
            GTAV.ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, coords['x'], coords['y'], coords['z'] + 2.0, False, False, True)

# Example Usage (for testing purposes, requires mocking GTAV and DisplayError)
"""
if __name__ == "__main__":
    print("--- Testing TeleportUtils Python ---")

    # --- Mock GTAV module for testing ---
    class MockENTITY:
        def SET_ENTITY_COORDS_NO_OFFSET(self, entity, x, y, z, p1, p2, p3):
            print(f"Mock: Entity {entity} coords set to ({x}, {y}, {z})")

    class MockTASK:
        def CLEAR_PED_TASKS_IMMEDIATELY(self, entity):
            print(f"Mock: Ped tasks cleared for entity {entity}")

    class MockMISC:
        _ground_z_map = {
            (10.0, 20.0, 100.0): 98.5, # Example ground Z
            (10.0, 20.0, 150.0): 98.5, # Same ground Z
            (10.0, 20.0, 50.0): 98.5, # Same ground Z
            (10.0, 20.0, 0.0): 98.5, # Default for 0.0
            (10.0, 20.0, 200.0): 198.0,
            (10.0, 20.0, 300.0): 298.0,
            (50.0, 50.0, 100.0): 95.0,
        }
        def GET_GROUND_Z_FOR_3D_COORD(self, x, y, z_test):
            # Simulate finding ground Z for specific coordinates/test heights
            key = (x, y, z_test)
            if key in self._ground_z_map:
                print(f"Mock: Found ground Z for ({x},{y},{z_test}) -> {self._ground_z_map[key]}")
                return True, self._ground_z_map[key]
            print(f"Mock: No ground Z found for ({x},{y},{z_test})")
            return False, 0.0 # Return False and a default value if not found

    class MockGTAV_Module:
        def __init__(self):
            self.ENTITY = MockENTITY()
            self.TASK = MockTASK()
            self.MISC = MockMISC()

    def mock_display_error(is_fatal, message):
        print(f"Mock Error (Fatal: {is_fatal}): {message}")

    # Assign mocks
    GTAV = MockGTAV_Module()
    DisplayError = mock_display_error
    # --- End Mocking ---

    # Test teleport_entity with z=0.0 (find ground)
    print("\n--- Testing teleport_entity (find ground) ---")
    test_entity_1 = 1
    test_coords_1 = {'x': 10.0, 'y': 20.0, 'z': 0.0}
    TeleportUtils.teleport_entity(test_entity_1, test_coords_1)
    # Expected output:
    # Mock: Entity 1 coords set to (10.0, 20.0, 100.0)
    # Mock: Ped tasks cleared for entity 1
    # Mock: Found ground Z for (10.0,20.0,100.0) -> 98.5
    # Mock: Entity 1 coords set to (10.0, 20.0, 100.5)

    # Test teleport_entity with specific z
    print("\n--- Testing teleport_entity (specific Z) ---")
    test_entity_2 = 2
    test_coords_2 = {'x': 50.0, 'y': 50.0, 'z': 100.0}
    TeleportUtils.teleport_entity(test_entity_2, test_coords_2)
    # Expected output:
    # Mock: Entity 2 coords set to (50.0, 50.0, 102.0)

    # Test teleport_entity with z=0.0 but no ground found (mock failure)
    print("\n--- Testing teleport_entity (find ground, no success) ---")
    test_entity_3 = 3
    test_coords_3 = {'x': 999.0, 'y': 999.0, 'z': 0.0} # Coordinates not in mock map
    TeleportUtils.teleport_entity(test_entity_3, test_coords_3)
    # Expected output:
    # Mock: Entity 3 coords set to (999.0, 999.0, 100.0) ... for all heights
    # Mock Error (Fatal: False): Failed to find ground Z for entity 3 at (999.0,999.0).
"""

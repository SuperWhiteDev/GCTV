# This utility script provides helper functions for handling user input,
# particularly for selecting game entities like vehicles.

# Assume these modules are available in the GCTV Python environment.
# GCT for general GCTV API functions like InputFromList, Input.
import GCT
# GTAV for game-specific native functions and entities like PED, ENTITY, PLAYER.
import GTAV
# map_utils for map-related utilities, including GetPersonalVehicle.
import map_utils

class InputUtils:
    """
    A utility class providing helper functions for handling user input,
    particularly for selecting game entities like vehicles.

    This implementation assumes the GCTV Python environment provides the
    following global modules/objects:
    - `GCT`: For `InputFromList`, `Input`.
    - `GTAV`: For `PED`, `ENTITY`, `PLAYER` (e.g., `GTAV.PED.GET_VEHICLE_PED_IS_IN`).
    - `map_utils`: For `get_personal_vehicle`.
    - `DisplayError`: A global function for displaying errors.
    """

    @staticmethod
    def input_vehicle():
        """
        Prompts the user to select a vehicle from predefined options or by entering a custom handle.

        Returns:
            int or None: The handle of the selected vehicle, or None if no valid vehicle is chosen.
        """
        selected_vehicle_handle = None
        
        # Options presented to the user for vehicle selection.
        vehicle_selection_options = [
            "Personal vehicle", # The player's currently tracked personal vehicle.
            "Last vehicle",     # The last vehicle the player was in (even if they exited).
            "Current vehicle",  # The vehicle the player is currently in.
            "Custom"            # Allows the user to enter a vehicle handle manually.
        ]
        
        # Prompt the user to choose a vehicle selection method using GCT.InputFromList.
        chosen_option_index = GCT.InputFromList("Choose which vehicle you want to control: ", vehicle_selection_options)
        
        # Process the user's selection.
        if chosen_option_index == 0: # "Personal vehicle"
            selected_vehicle_handle = map_utils.get_personal_vehicle()
        elif chosen_option_index == 1: # "Last vehicle"
            # Access PED and PLAYER through the GTAV module. Native function names are UPPER_SNAKE_CASE.
            selected_vehicle_handle = GTAV.PED.GET_VEHICLE_PED_IS_IN(GTAV.PLAYER.PLAYER_PED_ID(), True)
        elif chosen_option_index == 2: # "Current vehicle"
            selected_vehicle_handle = GTAV.PED.GET_VEHICLE_PED_IS_IN(GTAV.PLAYER.PLAYER_PED_ID(), False)
        elif chosen_option_index == 3: # "Custom"
            # Prompt for a custom vehicle handle using GCT.Input.
            input_handle_str = GCT.Input("Enter vehicle handle: ", False)
            try:
                selected_vehicle_handle = int(input_handle_str) # Convert input string to integer.
            except ValueError:
                GCT.DisplayError(False, "Invalid input: Please enter a numeric vehicle handle.")
                return None
            
            # Validate if the entered handle corresponds to an existing vehicle using GTAV.ENTITY.
            # Native function names are UPPER_SNAKE_CASE.
            if not GTAV.ENTITY.IS_ENTITY_A_VEHICLE(selected_vehicle_handle):
                GCT.DisplayError(False, "Invalid vehicle handle entered or entity is not a vehicle.")
                return None # Return None if the custom handle is invalid.
        else:
            # User cancelled or made an invalid selection from the list.
            return None

        # After selection, perform a final check to ensure a valid non-zero handle was obtained.
        # Assuming 0 is an invalid handle in the GTAV API for Python.
        if selected_vehicle_handle == 0 or selected_vehicle_handle is None:
            GCT.DisplayError(False, "No valid vehicle could be identified or selected.")
            return None

        return selected_vehicle_handle # Return the handle of the selected vehicle.

# Example Usage (commented out for production, uncomment for testing)
# To run this example, you would need to mock the global GCTV API functions
# and modules (GCT, GTAV, map_utils, DisplayError).
"""
if __name__ == "__main__":
    # --- Mock GCTV API functions and modules for testing ---
    class MockGCT:
        def InputFromList(self, prompt, options):
            print(prompt)
            for i, opt in enumerate(options):
                print(f"[{i}] {opt}")
            choice = input("Enter choice index: ")
            try:
                return int(choice)
            except ValueError:
                return -1

        def Input(self, prompt, to_lower=False):
            val = input(prompt)
            return val.lower() if to_lower else val

    class MockGTAV_PED:
        def GET_VEHICLE_PED_IS_IN(self, ped_id, last_vehicle):
            if last_vehicle:
                print(f"Mock: Getting last vehicle for ped {ped_id} (returning 202).")
                return 202
            else:
                print(f"Mock: Getting current vehicle for ped {ped_id} (returning 303).")
                return 303

    class MockGTAV_ENTITY:
        def IS_ENTITY_A_VEHICLE(self, entity_id):
            print(f"Mock: Checking if entity {entity_id} is a vehicle.")
            return entity_id in [101, 202, 303, 404, 505] # Example valid handles

    class MockGTAV_PLAYER:
        def PLAYER_PED_ID(self):
            print("Mock: Getting player ped ID (returning 1).")
            return 1

    class MockGTAV:
        def __init__(self):
            self.PED = MockGTAV_PED()
            self.ENTITY = MockGTAV_ENTITY()
            self.PLAYER = MockGTAV_PLAYER()

    class MockMapUtils:
        def get_personal_vehicle(self):
            print("Mock: Getting personal vehicle (returning 101).")
            return 101

    def mock_display_error(is_fatal, message):
        print(f"Mock Error (Fatal: {is_fatal}): {message}")

    # Assign mocks to the names used in the script
    GCT = MockGCT()
    GTAV = MockGTAV()
    map_utils = MockMapUtils()
    DisplayError = mock_display_error
    # --- End Mocking ---

    print("--- Testing InputUtils Python ---")

    # Test "Personal vehicle" (simulate user entering '0')
    _inputs = iter(['0'])
    __builtins__.input = lambda x: next(_inputs) if 'choice index' in x else _original_input(x)
    veh_personal = InputUtils.input_vehicle()
    print(f"Selected personal vehicle handle: {veh_personal}")

    # Test "Custom" with valid handle (simulate user entering '3' then '404')
    _inputs = iter(['3', '404'])
    __builtins__.input = lambda x: next(_inputs) if 'choice index' in x or 'vehicle handle' in x else _original_input(x)
    veh_custom_valid = InputUtils.input_vehicle()
    print(f"Selected custom valid vehicle handle: {veh_custom_valid}")

    # Test "Custom" with invalid handle (simulate user entering '3' then '999')
    _inputs = iter(['3', '999'])
    __builtins__.input = lambda x: next(_inputs) if 'choice index' in x or 'vehicle handle' in x else _original_input(x)
    veh_custom_invalid = InputUtils.input_vehicle()
    print(f"Selected custom invalid vehicle handle: {veh_custom_invalid}")

    # Restore original input (important if running in a larger script)
    __builtins__.input = input
"""

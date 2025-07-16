# This utility script provides helper functions related to vehicle models,
# specifically for retrieving vehicle model names and selecting random ones
# from a configuration file.

import json   # For JSON parsing.
import os     # For file system path operations (e.g., os.path.exists, os.path.getsize).
import random # For random selection.
import GTAV   # For MISC native functions (e.g., GTAV.MISC.GET_HASH_KEY).

class VehicleUtils:
    """
    A utility class providing helper functions related to vehicle models.

    This implementation assumes the GCTV Python environment provides the
    following global modules/objects:
    - `GTAV`: For `MISC` (native functions in UPPER_SNAKE_CASE).
    - Standard Python libraries like `json`, `os`, and `random`.
    """

    @staticmethod
    def _read_vehicles_json():
        """
        Internal helper to read the "vehicles.json" file.
        Returns an empty list if the file does not exist, is empty, or is invalid JSON.
        """
        file_path = "vehicles.json"
        if not os.path.exists(file_path) or os.path.getsize(file_path) == 0:
            return []
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                if content:
                    return json.loads(content)
        except json.JSONDecodeError:
            # print(f"Error decoding JSON from {file_path}. Returning empty list.") # For debugging
            pass
        except Exception as e:
            # print(f"An unexpected error occurred while reading {file_path}: {e}") # For debugging
            pass
        return []

    @staticmethod
    def get_vehicle_model_name(model_hash):
        """
        Retrieves the original model name (string) corresponding to a given model hash.
        It searches through a list of vehicle models defined in "vehicles.json".

        Args:
            model_hash (int): The hash of the vehicle model.

        Returns:
            str: The string name of the vehicle model, or "Unknown Model" if not found.
        """
        vehicles = VehicleUtils._read_vehicles_json()

        # Iterate through each vehicle name in the list.
        for vehicle_name in vehicles:
            # Get the hash key for the current vehicle name and compare it to the target hash.
            # Native function names are UPPER_SNAKE_CASE.
            if GTAV.MISC.GET_HASH_KEY(vehicle_name) == model_hash:
                return vehicle_name # Return the matching vehicle model name.

        return "Unknown Model" # Return "Unknown Model" if the hash is not found or file is invalid.

    @staticmethod
    def get_random_vehicle_model_name():
        """
        Retrieves a random vehicle model name from the "vehicles.json" file.

        Returns:
            str: A randomly selected vehicle model name, or an empty string if
                 the "vehicles.json" file is not found, empty, or invalid.
        """
        vehicles = VehicleUtils._read_vehicles_json()

        # Check if the list of vehicles was successfully read and is not empty.
        if vehicles and len(vehicles) > 0:
            # Return a randomly selected vehicle model name from the list.
            return random.choice(vehicles)
        
        return "" # Return an empty string if no vehicles are found or the file is invalid.

# Example Usage (for testing purposes, requires mocking GTAV.MISC or actual GTAV environment)
"""
if __name__ == "__main__":
    print("--- Testing VehicleUtils Python ---")

    # --- Mock GTAV.MISC for testing ---
    class MockMISC:
        def GET_HASH_KEY(self, model_name):
            # A simple mock hash function for testing purposes
            return hash(model_name) % (2**32) # Ensure positive hash

    class MockGTAV_Module:
        def __init__(self):
            self.MISC = MockMISC()

    GTAV = MockGTAV_Module()
    # --- End Mocking ---

    # Create a mock vehicles.json file for testing
    mock_vehicles_content = ["adder", "buzzard", "zentorno", "faggio"]
    with open("vehicles.json", 'w', encoding='utf-8') as f:
        json.dump(mock_vehicles_content, f)

    # Test get_vehicle_model_name
    adder_hash = GTAV.MISC.GET_HASH_KEY("adder")
    print(f"Model name for hash {adder_hash}: {VehicleUtils.get_vehicle_model_name(adder_hash)}") # Expected: adder
    
    unknown_hash = GTAV.MISC.GET_HASH_KEY("non_existent_car")
    print(f"Model name for hash {unknown_hash}: {VehicleUtils.get_vehicle_model_name(unknown_hash)}") # Expected: Unknown Model

    # Test get_random_vehicle_model_name
    print(f"Random Vehicle Model 1: {VehicleUtils.get_random_vehicle_model_name()}")
    print(f"Random Vehicle Model 2: {VehicleUtils.get_random_vehicle_model_name()}")
    print(f"Random Vehicle Model 3: {VehicleUtils.get_random_vehicle_model_name()}")

    # Test with an empty vehicles.json
    with open("vehicles.json", 'w', encoding='utf-8') as f:
        f.write("[]")
    print(f"Random Vehicle Model (empty file): {VehicleUtils.get_random_vehicle_model_name()}") # Expected: ""
    print(f"Model name for adder hash (empty file): {VehicleUtils.get_vehicle_model_name(adder_hash)}") # Expected: Unknown Model

    # Test with a non-existent vehicles.json
    os.remove("vehicles.json")
    print(f"Random Vehicle Model (non-existent file): {VehicleUtils.get_random_vehicle_model_name()}") # Expected: ""
    print(f"Model name for adder hash (non-existent file): {VehicleUtils.get_vehicle_model_name(adder_hash)}") # Expected: Unknown Model

    print("--- End Testing VehicleUtils Python ---")
"""

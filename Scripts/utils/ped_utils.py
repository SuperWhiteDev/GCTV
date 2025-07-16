# This utility script provides helper functions related to ped models,
# specifically for retrieving a random ped model name from a configuration file.

import json # For JSON parsing.
import os   # For file system path operations (e.g., os.path.exists, os.path.getsize).
import random # For random selection.

class PedUtils:
    """
    A utility class providing helper functions related to pedestrian (ped) models.

    This implementation assumes the GCTV Python environment allows standard
    Python libraries like `json`, `os`, and `random`.
    """

    @staticmethod
    def get_random_ped_model_name():
        """
        Retrieves a random pedestrian model name from the "peds.json" file.

        Returns:
            str: A randomly selected ped model name, or an empty string if
                 the "peds.json" file is not found, empty, or invalid.
        """
        ped_models = []
        file_path = "peds.json"

        # Use standard Python file I/O to read the JSON file.
        if os.path.exists(file_path) and os.path.getsize(file_path) > 0:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    file_content = f.read()
                    if file_content: # Ensure content is not an empty string
                        ped_models = json.loads(file_content)
            except json.JSONDecodeError:
                # print(f"Error decoding JSON from {file_path}. Returning empty list.") # For debugging
                pass # Silently fail and return empty list if file is invalid JSON.
            except Exception as e:
                # print(f"An unexpected error occurred while reading {file_path}: {e}") # For debugging
                pass # Catch other potential file errors.

        # Check if the list of ped models was successfully read and is not empty.
        if ped_models and isinstance(ped_models, list) and len(ped_models) > 0:
            # Return a randomly selected ped model name from the list.
            return random.choice(ped_models)
        
        return "" # Return an empty string if no peds are found or the file is invalid.

# Example Usage (for testing purposes, requires mocking file system or actual file)
"""
if __name__ == "__main__":
    print("--- Testing PedUtils Python ---")

    # Create a mock peds.json file for testing
    mock_peds_content = ["a_m_m_fatlatino_01", "s_m_y_cop_01", "u_m_m_fibsec_01", "g_m_m_chigoon_01"]
    with open("peds.json", 'w', encoding='utf-8') as f:
        json.dump(mock_peds_content, f)

    # Test get_random_ped_model_name multiple times
    print(f"Random Ped Model 1: {PedUtils.get_random_ped_model_name()}")
    print(f"Random Ped Model 2: {PedUtils.get_random_ped_model_name()}")
    print(f"Random Ped Model 3: {PedUtils.get_random_ped_model_name()}")

    # Test with an empty peds.json
    with open("peds.json", 'w', encoding='utf-8') as f:
        f.write("[]")
    print(f"Random Ped Model (empty file): {PedUtils.get_random_ped_model_name()}") # Expected: ""

    # Test with a non-existent peds.json
    os.remove("peds.json")
    print(f"Random Ped Model (non-existent file): {PedUtils.get_random_ped_model_name()}") # Expected: ""

    print("--- End Testing PedUtils Python ---")
"""

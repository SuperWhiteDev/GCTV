# This utility script provides helper functions related to map interactions,
# such as retrieving waypoint coordinates, finding personal vehicles,
# determining blip sprites for entities, and getting zone names.

# Assume these modules are available in the GCTV Python environment.
import GTAV # For HUD, STREAMING, VEHICLE, ZONE native functions.
import blip_enums # For blip icon constants.
import json # For JSON parsing.
import os   # For file system path operations (e.g., os.path.exists, os.path.getsize).

class MapUtils:
    """
    A utility class providing helper functions related to map interactions.

    This implementation assumes the GCTV Python environment provides the
    following global modules/objects:
    - `GTAV`: For `HUD`, `STREAMING`, `VEHICLE`, `ZONE` (native functions in UPPER_SNAKE_CASE).
    - `blip_enums`: For blip icon constants.
    - Standard Python libraries like `json` and `os`.
    """

    @staticmethod
    def get_waypoint_coords():
        """
        Retrieves the coordinates of the active waypoint set by the player on the map.

        Returns:
            dict or None: A dictionary with 'x', 'y', 'z' coordinates of the waypoint (z is set to 0.0),
                          or None if no waypoint is currently set.
        """
        # Get the blip ID for the first active waypoint. Native function names are UPPER_SNAKE_CASE.
        waypoint_blip = GTAV.HUD.GET_FIRST_BLIP_INFO_ID(blip_enums.BlipIcon.WAYPOINT)
        
        # Check if the waypoint blip actually exists. Native function names are UPPER_SNAKE_CASE.
        if GTAV.HUD.DOES_BLIP_EXIST(waypoint_blip):
            # Get the coordinates of the waypoint blip. Native function names are UPPER_SNAKE_CASE.
            coords = GTAV.HUD.GET_BLIP_COORDS(waypoint_blip)
            coords['z'] = 0.0 # Set Z-coordinate to 0.0, often useful for ground-level interaction.

            return coords # Return the waypoint coordinates.
        else:
            return None # No waypoint found.

    @staticmethod
    def get_personal_vehicle():
        """
        Retrieves the entity handle of the player's personal vehicle.
        It checks for both car and bike blips representing the personal vehicle.

        Returns:
            int or None: The entity handle of the personal vehicle, or None if not found.
        """
        # First, try to find the blip for a personal car. Native function names are UPPER_SNAKE_CASE.
        personal_veh_blip = GTAV.HUD.GET_FIRST_BLIP_INFO_ID(blip_enums.BlipIcon.PERSONAL_VEHICLE_CAR)
        
        # If a personal car blip exists, return its associated entity handle. Native function names are UPPER_SNAKE_CASE.
        if GTAV.HUD.DOES_BLIP_EXIST(personal_veh_blip):
            return GTAV.HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(personal_veh_blip)
        else:
            # If no personal car, try to find the blip for a personal bike. Native function names are UPPER_SNAKE_CASE.
            personal_veh_blip = GTAV.HUD.GET_FIRST_BLIP_INFO_ID(blip_enums.BlipIcon.PERSONAL_VEHICLE_BIKE)
            
            # If a personal bike blip exists, return its associated entity handle. Native function names are UPPER_SNAKE_CASE.
            if GTAV.HUD.DOES_BLIP_EXIST(personal_veh_blip):
                return GTAV.HUD.GET_BLIP_INFO_ID_ENTITY_INDEX(personal_veh_blip)

            return None # No personal vehicle (car or bike) blip found.

    @staticmethod
    def get_blip_from_entity_model(model):
        """
        Determines the appropriate blip icon for a given entity model hash.
        This is useful for displaying entities on the map with relevant icons.

        Args:
            model (int): The model hash of the entity.

        Returns:
            int: The blip icon ID from `blip_enums.BlipIcon` that best represents the model.
        """
        # Check if the model is a pedestrian. Native function names are UPPER_SNAKE_CASE.
        if GTAV.STREAMING.IS_MODEL_A_PED(model):
            return blip_enums.BlipIcon.STANDARD # Use a standard blip for pedestrians.
        # Check if the model is a vehicle. Native function names are UPPER_SNAKE_CASE.
        elif GTAV.STREAMING.IS_MODEL_A_VEHICLE(model):
            # Further categorize vehicle types for more specific blips. Native function names are UPPER_SNAKE_CASE.
            if GTAV.VEHICLE.IS_THIS_MODEL_A_PLANE(model):
                return blip_enums.BlipIcon.PLANE
            elif GTAV.VEHICLE.IS_THIS_MODEL_A_HELI(model):
                return blip_enums.BlipIcon.HELICOPTER
            elif GTAV.VEHICLE.IS_THIS_MODEL_A_BIKE(model):
                return blip_enums.BlipIcon.PERSONAL_VEHICLE_BIKE
            else: 
                # Default vehicle blip for cars and other ground vehicles.
                return blip_enums.BlipIcon.PERSONAL_VEHICLE_CAR
        # If neither a ped nor a known vehicle type, return a default standard blip.
        return blip_enums.BlipIcon.STANDARD

    @staticmethod
    def get_zone_name(x, y, z):
        """
        Retrieves the display name of a game zone at specified coordinates.
        It first gets the internal zone name and then attempts to find a more readable
        display name from a "zones.json" configuration file.

        Args:
            x (float): The X-coordinate.
            y (float): The Y-coordinate.
            z (float): The Z-coordinate.

        Returns:
            str: The display name of the zone, or the raw internal zone name if no display name is found.
        """
        # Get the internal (uppercase) name of the zone from the game API. Native function names are UPPER_SNAKE_CASE.
        zone_internal_name = GTAV.ZONE.GET_NAME_OF_ZONE(x, y, z).upper()

        zone_names_list = []
        file_path = "zones.json"
        
        # Use standard Python file I/O to read the JSON file.
        if os.path.exists(file_path) and os.path.getsize(file_path) > 0:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    file_content = f.read()
                    if file_content: # Ensure content is not empty string
                        zone_names_list = json.loads(file_content)
            except json.JSONDecodeError:
                # print(f"Error decoding JSON from {file_path}. Using default zone name.") # For debugging
                pass # Silently fail and use default if file is invalid JSON.
            except Exception as e:
                # print(f"An unexpected error occurred while reading {file_path}: {e}") # For debugging
                pass # Catch other potential file errors.

        # Iterate through the list to find a matching display name.
        for element in zone_names_list:
            # Check if 'Name' key exists and compare its uppercase value.
            if isinstance(element, dict) and element.get("Name", "").upper() == zone_internal_name:
                # Return display name if available, otherwise fallback to internal name.
                return element.get("DisplayName", zone_internal_name) 

        return zone_internal_name # If no display name found, return the raw internal name.

# Example Usage (for testing purposes, requires mocking GTAV and standard Python modules)
"""
if __name__ == "__main__":
    print("--- Testing MapUtils Python ---")

    # Mock GTAV module
    class MockHUD:
        def GET_FIRST_BLIP_INFO_ID(self, blip_icon):
            if blip_icon == blip_enums.BlipIcon.WAYPOINT: return 1001
            if blip_icon == blip_enums.BlipIcon.PERSONAL_VEHICLE_CAR: return 1002
            if blip_icon == blip_enums.BlipIcon.PERSONAL_VEHICLE_BIKE: return 0 # No bike
            return 0
        def DOES_BLIP_EXIST(self, blip_id): return blip_id != 0
        def GET_BLIP_COORDS(self, blip_id): return {'x': 100.0, 'y': 200.0, 'z': 300.0}
        def GET_BLIP_INFO_ID_ENTITY_INDEX(self, blip_id): return 5001 if blip_id == 1002 else 0

    class MockSTREAMING:
        def IS_MODEL_A_PED(self, model): return model == 12345
        def IS_MODEL_A_VEHICLE(self, model): return model in [67890, 11223, 44556, 77889]
    
    class MockVEHICLE:
        def IS_THIS_MODEL_A_PLANE(self, model): return model == 11223
        def IS_THIS_MODEL_A_HELI(self, model): return model == 44556
        def IS_THIS_MODEL_A_BIKE(self, model): return model == 77889

    class MockZONE:
        def GET_NAME_OF_ZONE(self, x, y, z):
            if x == 10.0: return "DELPERO"
            if x == 20.0: return "ROCKFORD"
            return "UNKNOWN"

    class MockGTAV_Module:
        def __init__(self):
            self.HUD = MockHUD()
            self.STREAMING = MockSTREAMING()
            self.VEHICLE = MockVEHICLE()
            self.ZONE = MockZONE()

    # Mock blip_enums
    class MockBlipEnums:
        WAYPOINT = 1
        PERSONAL_VEHICLE_CAR = 2
        PERSONAL_VEHICLE_BIKE = 3
        STANDARD = 4
        PLANE = 5
        HELICOPTER = 6
    
    # Assign mocks
    GTAV = MockGTAV_Module()
    blip_enums = MockBlipEnums()

    # Setup mock zones.json file (using actual file system for this mock)
    # This part would actually write a file to disk for the mock to read.
    # In a real test, you might use unittest.mock.patch('builtins.open') or similar.
    mock_zones_content = [
        {"Name": "DELPERO", "DisplayName": "Del Perro Beach"},
        {"Name": "ROCKFORD", "DisplayName": "Rockford Hills"}
    ]
    with open("zones.json", 'w', encoding='utf-8') as f:
        json.dump(mock_zones_content, f)

    # Test get_waypoint_coords
    waypoint = MapUtils.get_waypoint_coords()
    print(f"Waypoint Coords: {waypoint}") # Expected: {'x': 100.0, 'y': 200.0, 'z': 0.0}

    # Test get_personal_vehicle
    personal_veh = MapUtils.get_personal_vehicle()
    print(f"Personal Vehicle Handle: {personal_veh}") # Expected: 5001

    # Test get_blip_from_entity_model
    print(f"Blip for Ped (12345): {MapUtils.get_blip_from_entity_model(12345)}") # Expected: STANDARD
    print(f"Blip for Plane (11223): {MapUtils.get_blip_from_entity_model(11223)}") # Expected: PLANE
    print(f"Blip for Car (67890): {MapUtils.get_blip_from_entity_model(67890)}") # Expected: PERSONAL_VEHICLE_CAR

    # Test get_zone_name
    print(f"Zone Name (10,20,30): {MapUtils.get_zone_name(10.0, 20.0, 30.0)}") # Expected: Del Perro Beach
    print(f"Zone Name (20,40,60): {MapUtils.get_zone_name(20.0, 40.0, 60.0)}") # Expected: Rockford Hills
    print(f"Zone Name (99,99,99): {MapUtils.get_zone_name(99.0, 99.0, 99.0)}") # Expected: UNKNOWN

    # Clean up mock file
    os.remove("zones.json")
"""

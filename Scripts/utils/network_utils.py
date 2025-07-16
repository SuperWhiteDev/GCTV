# This utility script provides functions for managing network control and registration
# of game entities, ensuring they are properly synchronized across the network.
# It also includes functions for creating and deleting networked vehicles.

# Assume these modules are available in the GCTV Python environment.
import GCT
import GTAV # For MISC, STREAMING, VEHICLE, ENTITY, HUD, NETWORK native functions.
import map_utils # For map-related utilities, including get_blip_from_entity_model.
import time # For delays (simulating Wait).

class NetworkUtils:
    """
    A utility class providing functions for managing network control and registration
    of game entities, and for creating/deleting networked vehicles.

    This implementation assumes the GCTV Python environment provides the
    following global modules/objects:
    - `GTAV`: For `MISC`, `STREAMING`, `VEHICLE`, `ENTITY`, `HUD`, `NETWORK`
              (native functions in UPPER_SNAKE_CASE).
    - `map_utils`: For `get_blip_from_entity_model`.
    - `DisplayError`: A global function for displaying errors.
    - `time`: For `time.sleep` (to simulate `Wait`).
    """

    @staticmethod
    def request_control_of(entity):
        """
        Requests control of a specific entity on the network.
        This is crucial in a multiplayer environment to ensure that local script changes
        to an entity are synchronized and visible to other players.
        The function retries the request multiple times until control is gained or attempts run out.

        Args:
            entity (int): The handle of the entity for which to request control.
        """
        # Attempt to request control. Native function names are UPPER_SNAKE_CASE.
        GTAV.NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        
        # Loop to continuously request control until it's gained.
        # The loop runs up to 50 times.
        for _ in range(50):
            if GTAV.NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity):
                break # Exit loop if control is successfully gained.
            GTAV.NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity) # Re-request control.
            time.sleep(0.001) # Simulate Wait(1) for 1 millisecond.

    @staticmethod
    def register_as_network(entity):
        """
        Registers an entity on the network, making it visible and interactive for all players.
        This involves marking it as networked, requesting control, and ensuring its network ID
        exists on all machines.

        Args:
            entity (int): The handle of the entity to register as networked.
        """
        # Mark the entity as networked. Native function names are UPPER_SNAKE_CASE.
        GTAV.NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(entity)
        time.sleep(0.001) # Simulate Wait(1) after registration.
        
        # Request control of the entity to ensure the local client can manipulate it.
        NetworkUtils.request_control_of(entity)
        
        # Get the network ID associated with the entity. Native function names are UPPER_SNAKE_CASE.
        net_id = GTAV.NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
        
        # Ensure the network ID exists on all machines, making the entity fully synchronized.
        # The second parameter 'True' (equivalent to 1 in Lua) typically means 'force'.
        GTAV.NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, True)

    @staticmethod
    def create_net_vehicle(model_hash, coords, heading, blip_info=None):
        """
        Creates a networked vehicle with a given model and coordinates, and optionally adds a blip.

        Args:
            model_hash (int): The model hash of the vehicle to create.
            coords (dict): A dictionary with 'x', 'y', 'z' coordinates for spawning.
            heading (float): The heading (rotation around Z-axis) for the vehicle.
            blip_info (dict, optional): An optional dictionary containing blip customization:
                                        'sprite' (int), 'modifier' (int), 'scale' (float), 'name' (str).
                                        Defaults to None.

        Returns:
            int or None: The handle of the created vehicle, or None if creation fails.
        """
        # Check if the model is valid and in CDImage (on disk). Native function names are UPPER_SNAKE_CASE.
        if GTAV.STREAMING.IS_MODEL_IN_CDIMAGE(model_hash) and GTAV.STREAMING.IS_MODEL_VALID(model_hash):
            GTAV.STREAMING.REQUEST_MODEL(model_hash, True) # Request the model, True for `p2` (load as network model).
            iters = 0
            # Wait for the model to load. Native function names are UPPER_SNAKE_CASE.
            while not GTAV.STREAMING.HAS_MODEL_LOADED(model_hash):
                if iters > 50: # Timeout after 50 attempts (5 seconds with time.sleep(0.1)).
                    GCT.DisplayError(False, f"Failed to load model {model_hash}")
                    GTAV.STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash)
                    return None
                time.sleep(0.1) # Wait 100ms
                iters += 1

            # Create the vehicle. Native function names are UPPER_SNAKE_CASE.
            veh = GTAV.VEHICLE.CREATE_VEHICLE(model_hash, coords['x'], coords['y'], coords['z'], heading, False, False, False)
            
            # Check if vehicle was successfully created and exists. Native function names are UPPER_SNAKE_CASE.
            if veh != 0 and GTAV.ENTITY.DOES_ENTITY_EXIST(veh):
                NetworkUtils.register_as_network(veh) # Register the vehicle on the network.

                GTAV.VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh, 5.0) # Ensure vehicle is properly placed on ground.
                GTAV.VEHICLE.SET_VEHICLE_ENGINE_ON(veh, True, True, False) # Turn engine on.
                GTAV.VEHICLE.SET_VEHICLE_IS_WANTED(veh, False) # Ensure vehicle is not wanted.
                
                # Add blip if blip_info is provided.
                if blip_info is not None and isinstance(blip_info, dict):
                    blip_sprite = map_utils.get_blip_from_entity_model(model_hash) # Get default blip sprite.
                    if 'sprite' in blip_info and blip_info['sprite'] is not None:
                        blip_sprite = blip_info['sprite'] # Override with custom sprite if provided.

                    blip = GTAV.HUD.ADD_BLIP_FOR_ENTITY(veh) # Add blip for the vehicle.
                    GTAV.HUD.SET_BLIP_SPRITE(blip, blip_sprite) # Set blip sprite.

                    if 'modifier' in blip_info and blip_info['modifier'] is not None:
                        GTAV.HUD.BLIP_ADD_MODIFIER(blip, blip_info['modifier']) # Add blip modifier.

                    if 'scale' in blip_info and blip_info['scale'] is not None:
                        GTAV.HUD.SET_BLIP_SCALE(blip, blip_info['scale']) # Set blip scale.

                    if 'name' in blip_info and blip_info['name'] is not None:
                        GTAV.HUD._SET_BLIP_NAME(blip, blip_info['name']) # Set blip name.
                
                GTAV.STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash) # Release model.
                return veh # Return the handle of the created vehicle.
            else:
                GCT.DisplayError(False, f"Failed to create vehicle entity for model {model_hash}")
                GTAV.STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash)
                return None
        else:
            GCT.DisplayError(False, f"Not valid model or model not in CDImage: {model_hash}")
        return None

    @staticmethod
    def delete_net_vehicle(veh):
        """
        Deletes a networked vehicle.
        This function requests control of the vehicle and then deletes it.

        Args:
            veh (int): The handle of the vehicle to delete.
        """
        # Check if entity exists before attempting to delete. Native function names are UPPER_SNAKE_CASE.
        if not GTAV.ENTITY.DOES_ENTITY_EXIST(veh):
            GCT.DisplayError(False, f"Attempted to delete non-existent vehicle handle: {veh}")
            return

        NetworkUtils.request_control_of(veh) # Request control to ensure proper deletion.
        
        # Mark as mission entity (often done before deletion in some contexts to prevent recreation).
        GTAV.ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, True, True)
        
        # In Python, entity handles are direct integers. No need for Game.NewVehicle/Game.Delete.
        GTAV.VEHICLE.DELETE_VEHICLE(veh) # Direct delete.

        # Fallback/ensure deletion if direct delete isn't fully effective immediately
        if GTAV.ENTITY.DOES_ENTITY_EXIST(veh):
            GTAV.NETWORK.NETWORK_FADE_OUT_ENTITY(veh, True, False) # Fade out for other players
            time.sleep(0.5) # Give time to fade (500ms)
            GTAV.VEHICLE.DELETE_VEHICLE(veh) # Direct delete again
            GTAV.ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(veh)

        print(f"Networked vehicle {veh} deleted.")

# Example Usage (for testing purposes, requires mocking GTAV, map_utils, and DisplayError)
"""
if __name__ == "__main__":
    print("--- Testing NetworkUtils Python ---")

    # --- Mock GCTV API functions and modules for testing ---
    class MockMISC:
        def GET_HASH_KEY(self, model_name):
            return hash(model_name) % (2**32) # Simple hash for mock

    class MockSTREAMING:
        _loaded_models = set()
        def IS_MODEL_IN_CDIMAGE(self, model_hash): return True # Always true for mock
        def IS_MODEL_VALID(self, model_hash): return model_hash != 0
        def HAS_MODEL_LOADED(self, model_hash): return model_hash in self._loaded_models
        def REQUEST_MODEL(self, model_hash, p2): self._loaded_models.add(model_hash)
        def SET_MODEL_AS_NO_LONGER_NEEDED(self, model_hash): self._loaded_models.discard(model_hash)

    class MockVEHICLE:
        _next_veh_id = 10000
        def CREATE_VEHICLE(self, model_hash, x, y, z, heading, is_network, is_mission, is_dynamic):
            if model_hash == GTAV.MISC.GET_HASH_KEY("FAIL_VEHICLE"): return 0
            self._next_veh_id += 1
            print(f"Mock: Created vehicle {self._next_veh_id} at ({x},{y},{z})")
            return self._next_veh_id
        def SET_VEHICLE_ON_GROUND_PROPERLY(self, veh, p): print(f"Mock: Veh {veh} on ground properly")
        def SET_VEHICLE_ENGINE_ON(self, veh, p1, p2, p3): print(f"Mock: Veh {veh} engine on")
        def SET_VEHICLE_IS_WANTED(self, veh, p): print(f"Mock: Veh {veh} is wanted: {p}")
        def DELETE_VEHICLE(self, veh): print(f"Mock: Deleted vehicle {veh}")

    class MockENTITY:
        _existing_entities = set()
        def DOES_ENTITY_EXIST(self, entity_id): return entity_id in self._existing_entities
        def SET_ENTITY_AS_MISSION_ENTITY(self, entity, is_mission, is_network):
            print(f"Mock: Entity {entity} set as mission entity (mission={is_mission}, network={is_network})")
            if is_mission: self._existing_entities.add(entity) # Simulate existence for mission entities
            else: self._existing_entities.discard(entity) # Simulate removal if not mission
        def SET_ENTITY_AS_NO_LONGER_NEEDED(self, entity): self._existing_entities.discard(entity)

    class MockHUD:
        def ADD_BLIP_FOR_ENTITY(self, entity): return entity + 100000 # Mock blip ID
        def SET_BLIP_SPRITE(self, blip, sprite): print(f"Mock: Blip {blip} sprite {sprite}")
        def BLIP_ADD_MODIFIER(self, blip, modifier): print(f"Mock: Blip {blip} modifier {modifier}")
        def SET_BLIP_SCALE(self, blip, scale): print(f"Mock: Blip {blip} scale {scale}")
        def _SET_BLIP_NAME(self, blip, name): print(f"Mock: Blip {blip} name {name}")

    class MockNETWORK:
        _has_control = False
        _registered_entities = set()
        _entity_net_ids = {}
        _next_net_id = 1
        _request_count = {}

        def NETWORK_REQUEST_CONTROL_OF_ENTITY(self, entity):
            if entity not in self._request_count: self._request_count[entity] = 0
            self._request_count[entity] += 1
            if self._request_count[entity] >= 3: self._has_control = True # Gain control after 3 requests

        def NETWORK_HAS_CONTROL_OF_ENTITY(self, entity):
            return self._has_control

        def NETWORK_REGISTER_ENTITY_AS_NETWORKED(self, entity):
            self._registered_entities.add(entity)
            if entity not in self._entity_net_ids:
                self._entity_net_ids[entity] = self._next_net_id
                self._next_net_id += 1

        def NETWORK_GET_NETWORK_ID_FROM_ENTITY(self, entity):
            return self._entity_net_ids.get(entity, 0)

        def SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(self, net_id, exists):
            print(f"Mock: Setting network ID {net_id} exists on all machines: {exists}")
        
        def NETWORK_FADE_OUT_ENTITY(self, entity, p1, p2): print(f"Mock: Entity {entity} faded out")

        def reset(self):
            self._has_control = False
            self._registered_entities = set()
            self._entity_net_ids = {}
            self._next_net_id = 1
            self._request_count = {}

    class MockGTAV_Module:
        def __init__(self):
            self.MISC = MockMISC()
            self.STREAMING = MockSTREAMING()
            self.VEHICLE = MockVEHICLE()
            self.ENTITY = MockENTITY()
            self.HUD = MockHUD()
            self.NETWORK = MockNETWORK()

    class MockMapUtils:
        def get_blip_from_entity_model(self, model):
            return 1 # Generic blip for mock

    def mock_display_error(is_fatal, message):
        print(f"Mock Error (Fatal: {is_fatal}): {message}")

    # Assign mocks
    GTAV = MockGTAV_Module()
    map_utils = MockMapUtils()
    DisplayError = mock_display_error
    # --- End Mocking ---

    # Test create_net_vehicle
    print("\n--- Testing create_net_vehicle ---")
    GTAV.NETWORK.reset()
    GTAV.ENTITY._existing_entities.clear()
    veh_coords = {'x': 10.0, 'y': 20.0, 'z': 30.0}
    blip_info_test = {'sprite': 5, 'scale': 0.8, 'name': 'My Net Car'}
    created_veh = NetworkUtils.create_net_vehicle(GTAV.MISC.GET_HASH_KEY("ADDER"), veh_coords, 90.0, blip_info_test)
    print(f"Created Net Vehicle Handle: {created_veh}")
    print(f"Entity exists: {GTAV.ENTITY.DOES_ENTITY_EXIST(created_veh)}") # Should be True

    # Test delete_net_vehicle
    print("\n--- Testing delete_net_vehicle ---")
    NetworkUtils.delete_net_vehicle(created_veh)
    print(f"Entity exists after delete: {GTAV.ENTITY.DOES_ENTITY_EXIST(created_veh)}") # Should be False
"""

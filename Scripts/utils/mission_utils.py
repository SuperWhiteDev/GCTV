# This utility script provides functions for creating and managing mission-specific
# game entities (vehicles, peds) and cameras.

# Assume these modules are available in the GCTV Python environment.
import GCT
import GTAV # For MISC, STREAMING, VEHICLE, PED, ENTITY, CAM native functions.
import network_utils # For network registration of entities.
import time # For delays (simulating Wait).

class MissionUtils:
    """
    A utility class providing functions for creating and managing mission-specific
    game entities (vehicles, peds) and cameras.

    This implementation assumes the GCTV Python environment provides the
    following global modules/objects:
    - `GTAV`: For `MISC`, `STREAMING`, `VEHICLE`, `PED`, `ENTITY`, `CAM`
              (native functions in UPPER_SNAKE_CASE).
    - `network_utils`: For `register_as_network`.
    - `DisplayError`: A global function for displaying errors.
    - `time`: For `time.sleep` (to simulate `Wait`).
    """

    @staticmethod
    def create_mission_vehicle(model, x, y, z, heading):
        """
        Creates a vehicle and registers it as a mission entity and network entity.
        This function includes retry logic with slight coordinate adjustments if spawning fails.

        Args:
            model (str): The model name (e.g., "ADDER", "BUZZARD").
            x (float): The X-coordinate for spawning.
            y (float): The Y-coordinate for spawning.
            z (float): The Z-coordinate for spawning.
            heading (float): The heading (rotation around Z-axis) for the vehicle.

        Returns:
            int or None: The handle of the created vehicle, or None if creation fails after retries.
        """
        model_hash = GTAV.MISC.GET_HASH_KEY(model)
        max_attempts = 10 # Define a maximum number of spawn attempts.
        current_attempt = 0

        # Check if the model is valid. Native function names are UPPER_SNAKE_CASE.
        if not GTAV.STREAMING.IS_MODEL_VALID(model_hash):
            GCT.DisplayError(False, f"Invalid vehicle model: {model}.")
            return None

        # Request and load the model if not already loaded. Native function names are UPPER_SNAKE_CASE.
        if not GTAV.STREAMING.HAS_MODEL_LOADED(model_hash):
            GTAV.STREAMING.REQUEST_MODEL(model_hash)
            # Wait for the model to load, with a timeout.
            load_iters = 0
            while not GTAV.STREAMING.HAS_MODEL_LOADED(model_hash):
                time.sleep(0.005) # Simulate Wait(5)
                load_iters += 1
                if load_iters > 100: # Timeout after 500ms
                    GCT.DisplayError(False, f"Failed to load vehicle model: {model}.")
                    GTAV.STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash)
                    return None
        
        spawned_veh = 0 # Initialize with 0 (invalid handle)
        current_x, current_y, current_z = x, y, z # Use mutable coordinates for retries

        while spawned_veh == 0 and current_attempt < max_attempts:
            # Attempt to create the vehicle. Native function names are UPPER_SNAKE_CASE.
            spawned_veh = GTAV.VEHICLE.CREATE_VEHICLE(model_hash, current_x, current_y, current_z, heading, False, False, False)
            
            if spawned_veh == 0:
                # If creation failed, slightly adjust coordinates for the next attempt.
                current_x += 0.15
                current_y += 0.15
                current_z += 0.05
                time.sleep(0.010) # Simulate Wait(10)
                current_attempt += 1
        
        # If vehicle was successfully created after attempts.
        if spawned_veh != 0:
            network_utils.register_as_network(spawned_veh) # Register the vehicle with the network.
            GTAV.ENTITY.SET_ENTITY_AS_MISSION_ENTITY(spawned_veh, True, True) # Mark as mission entity.
            GTAV.STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash) # Release model.
            return spawned_veh
        else:
            GCT.DisplayError(False, f"Failed to create mission vehicle after {max_attempts} attempts: {model}.")
            GTAV.STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash) # Release model even on failure.
            return None

    @staticmethod
    def create_mission_ped(model, ped_type, x, y, z, heading):
        """
        Creates a pedestrian (ped) and registers it as a mission entity and network entity.
        This function includes retry logic with slight coordinate adjustments if spawning fails.

        Args:
            model (str): The model name (e.g., "MP_M_FREEMODE_01").
            ped_type (int): The ped type (e.g., 0 for CIVILIAN_PED).
            x (float): The X-coordinate for spawning.
            y (float): The Y-coordinate for spawning.
            z (float): The Z-coordinate for spawning.
            heading (float): The heading (rotation around Z-axis) for the ped.

        Returns:
            int or None: The handle of the created ped, or None if creation fails after retries.
        """
        model_hash = GTAV.MISC.GET_HASH_KEY(model)
        max_attempts = 10 # Define a maximum number of spawn attempts.
        current_attempt = 0

        # Check if the model is valid. Native function names are UPPER_SNAKE_CASE.
        if not GTAV.STREAMING.IS_MODEL_VALID(model_hash):
            GCT.DisplayError(False, f"Invalid ped model: {model}.")
            return None

        # Request and load the model if not already loaded. Native function names are UPPER_SNAKE_CASE.
        if not GTAV.STREAMING.HAS_MODEL_LOADED(model_hash):
            GTAV.STREAMING.REQUEST_MODEL(model_hash)
            # Wait for the model to load, with a timeout.
            load_iters = 0
            while not GTAV.STREAMING.HAS_MODEL_LOADED(model_hash):
                time.sleep(0.005) # Simulate Wait(5)
                load_iters += 1
                if load_iters > 100: # Timeout after 500ms
                    GCT.DisplayError(False, f"Failed to load ped model: {model}.")
                    GTAV.STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash)
                    return None
        
        spawned_ped = 0 # Initialize with 0 (invalid handle)
        current_x, current_y, current_z = x, y, z # Use mutable coordinates for retries

        while spawned_ped == 0 and current_attempt < max_attempts:
            # Attempt to create the ped. Native function names are UPPER_SNAKE_CASE.
            spawned_ped = GTAV.PED.CREATE_PED(ped_type, model_hash, current_x, current_y, current_z, heading, False, True)
            
            if spawned_ped == 0:
                # If creation failed, slightly adjust coordinates for the next attempt.
                current_x += 0.01
                current_y += 0.01
                # z is not adjusted in original Lua, maintaining that.
                time.sleep(0.010) # Simulate Wait(10)
                current_attempt += 1
        
        # If ped was successfully created after attempts.
        if spawned_ped != 0:
            network_utils.register_as_network(spawned_ped) # Register the ped with the network.
            GTAV.ENTITY.SET_ENTITY_AS_MISSION_ENTITY(spawned_ped, True, True) # Mark as mission entity.
            GTAV.STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash) # Release model.
            return spawned_ped
        else:
            GCT.DisplayError(False, f"Failed to create mission ped after {max_attempts} attempts: {model}.")
            GTAV.STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash) # Release model even on failure.
            return None

    @staticmethod
    def create_mission_ped_in_vehicle(vehicle, seat, model, ped_type, x, y, z, heading):
        """
        Creates a mission ped and places them directly into a specified vehicle.

        Args:
            vehicle (int): The handle of the vehicle to place the ped into.
            seat (int): The seat index in the vehicle (e.g., -1 for driver, 0 for passenger).
            model (str): The ped model name.
            ped_type (int): The ped type.
            x (float): The X-coordinate for initial ped spawning (before entering vehicle).
            y (float): The Y-coordinate for initial ped spawning.
            z (float): The Z-coordinate for initial ped spawning.
            heading (float): The heading for initial ped spawning.

        Returns:
            int or None: The handle of the created ped, or None if creation fails.
        """
        # First, create the mission ped.
        ped = MissionUtils.create_mission_ped(model, ped_type, x, y, z, heading)

        # If the ped was successfully created, place them into the vehicle. Native function names are UPPER_SNAKE_CASE.
        if ped:
            GTAV.PED.SET_PED_INTO_VEHICLE(ped, vehicle, seat)

        return ped # Return the handle of the created ped.

    @staticmethod
    def create_camera(x, y, z, pitch, roll, yaw, transition_time):
        """
        Creates and activates a scripted camera at specified coordinates and rotation.

        Args:
            x (float): The X-coordinate for the camera position.
            y (float): The Y-coordinate for the camera position.
            z (float): The Z-coordinate for the camera position.
            pitch (float): The pitch (X-rotation) of the camera.
            roll (float): The roll (Y-rotation) of the camera.
            yaw (float): The yaw (Z-rotation) of the camera.
            transition_time (int): The time in milliseconds for the camera transition.

        Returns:
            int: The handle of the created camera.
        """
        # Create a default scripted camera. Native function names are UPPER_SNAKE_CASE.
        cam = GTAV.CAM.CREATE_CAM("DEFAULT_SCRIPTED_CAMERA", True)
        GTAV.CAM.SET_CAM_COORD(cam, x, y, z) # Set camera position.
        # Set camera rotation. Note the order: pitch, roll, yaw (X, Y, Z).
        GTAV.CAM.SET_CAM_ROT(cam, pitch, roll, yaw, 2) # Order 2 is typically X, Y, Z.
        # Render the script camera, with a transition.
        GTAV.CAM.RENDER_SCRIPT_CAMS(True, True, transition_time, True, True)

        return cam # Return the camera handle.

    @staticmethod
    def create_fly_camera(x, y, z, pitch, roll, yaw, max_height, transition_time):
        """
        Creates and activates a scripted "fly" camera.
        This camera type often has different properties and rendering behavior.

        Args:
            x (float): The X-coordinate for the camera position.
            y (float): The Y-coordinate for the camera position.
            z (float): The Z-coordinate for the camera position.
            pitch (float): The pitch (X-rotation) of the camera.
            roll (float): The roll (Y-rotation) of the camera.
            yaw (float): The yaw (Z-rotation) of the camera.
            max_height (float): The maximum height the fly camera can reach.
            transition_time (int): The time in milliseconds for the camera transition.

        Returns:
            int: The handle of the created camera.
        """
        # Create a default scripted fly camera. Native function names are UPPER_SNAKE_CASE.
        cam = GTAV.CAM.CREATE_CAM("DEFAULT_SCRIPTED_FLY_CAMERA", True)
        GTAV.CAM.SET_CAM_COORD(cam, x, y, z) # Set camera position.
        # Set camera rotation. Note the order: pitch, roll, yaw (X, Y, Z).
        GTAV.CAM.SET_CAM_ROT(cam, pitch, roll, yaw, 2) # Order 2 is typically X, Y, Z.
        GTAV.CAM.SET_FLY_CAM_MAX_HEIGHT(cam, max_height) # Set max height for fly camera.
        # Render the script camera. Note the different last three parameters compared to CreateCamera.
        GTAV.CAM.RENDER_SCRIPT_CAMS(True, True, transition_time, False, False, False)
        
        return cam # Return the camera handle.

    @staticmethod
    def delete_camera(camera):
        """
        Deletes a previously created camera and deactivates script cameras.

        Args:
            camera (int): The handle of the camera to destroy.
        """
        # Deactivate all script cameras. Native function names are UPPER_SNAKE_CASE.
        GTAV.CAM.RENDER_SCRIPT_CAMS(False, False, 0, True, True)
        # Destroy the specific camera. Native function names are UPPER_SNAKE_CASE.
        GTAV.CAM.DESTROY_CAM(camera, False)

# Example Usage (for testing purposes, requires mocking GTAV, network_utils, and DisplayError)
"""
if __name__ == "__main__":
    print("--- Testing MissionUtils Python ---")

    # --- Mock GCTV API functions and modules for testing ---
    class MockMISC:
        def GET_HASH_KEY(self, model_name):
            return hash(model_name) % (2**32) # Simple hash for mock

    class MockSTREAMING:
        _loaded_models = set()
        def IS_MODEL_VALID(self, model_hash): return model_hash != 0
        def HAS_MODEL_LOADED(self, model_hash): return model_hash in self._loaded_models
        def REQUEST_MODEL(self, model_hash): self._loaded_models.add(model_hash)
        def SET_MODEL_AS_NO_LONGER_NEEDED(self, model_hash): self._loaded_models.discard(model_hash)

    class MockVEHICLE:
        _next_veh_id = 10000
        def CREATE_VEHICLE(self, model_hash, x, y, z, heading, is_network, is_mission, is_dynamic):
            if model_hash == hash("FAIL_VEHICLE") % (2**32): return 0
            self._next_veh_id += 1
            print(f"Mock: Created vehicle {self._next_veh_id} at ({x},{y},{z})")
            return self._next_veh_id

    class MockPED:
        _next_ped_id = 20000
        def CREATE_PED(self, ped_type, model_hash, x, y, z, heading, is_network, is_mission):
            if model_hash == hash("FAIL_PED") % (2**32): return 0
            self._next_ped_id += 1
            print(f"Mock: Created ped {self._next_ped_id} at ({x},{y},{z})")
            return self._next_ped_id
        def SET_PED_INTO_VEHICLE(self, ped, vehicle, seat):
            print(f"Mock: Ped {ped} set into vehicle {vehicle} seat {seat}")

    class MockENTITY:
        def SET_ENTITY_AS_MISSION_ENTITY(self, entity, is_mission, is_network):
            print(f"Mock: Entity {entity} set as mission entity (mission={is_mission}, network={is_network})")

    class MockCAM:
        _next_cam_id = 30000
        def CREATE_CAM(self, cam_type, is_active):
            self._next_cam_id += 1
            print(f"Mock: Created camera {self._next_cam_id} of type {cam_type}")
            return self._next_cam_id
        def SET_CAM_COORD(self, cam, x, y, z): print(f"Mock: Cam {cam} coords set to ({x},{y},{z})")
        def SET_CAM_ROT(self, cam, p, r, y, order): print(f"Mock: Cam {cam} rot set to ({p},{r},{y}) order {order}")
        def SET_FLY_CAM_MAX_HEIGHT(self, cam, height): print(f"Mock: Cam {cam} max height {height}")
        def RENDER_SCRIPT_CAMS(self, enable, ease, time, p1, p2, p3=None):
            print(f"Mock: Render script cams enable={enable}, ease={ease}, time={time}, p1={p1}, p2={p2}, p3={p3}")
        def DESTROY_CAM(self, cam, p): print(f"Mock: Cam {cam} destroyed")

    class MockGTAV_Module:
        def __init__(self):
            self.MISC = MockMISC()
            self.STREAMING = MockSTREAMING()
            self.VEHICLE = MockVEHICLE()
            self.PED = MockPED()
            self.ENTITY = MockENTITY()
            self.CAM = MockCAM()

    class MockNetworkUtils:
        def register_as_network(self, entity_id):
            print(f"Mock: Entity {entity_id} registered as network entity.")

    def mock_display_error(is_fatal, message):
        print(f"Mock Error (Fatal: {is_fatal}): {message}")

    # Assign mocks
    GTAV = MockGTAV_Module()
    network_utils = MockNetworkUtils()
    DisplayError = mock_display_error
    # --- End Mocking ---

    # Test create_mission_vehicle
    print("\n--- Testing create_mission_vehicle ---")
    veh_handle = MissionUtils.create_mission_vehicle("TEST_VEHICLE", 0.0, 0.0, 70.0, 90.0)
    print(f"Created Vehicle Handle: {veh_handle}")

    # Test create_mission_ped
    print("\n--- Testing create_mission_ped ---")
    ped_handle = MissionUtils.create_mission_ped("TEST_PED", 0, 10.0, 10.0, 70.0, 0.0)
    print(f"Created Ped Handle: {ped_handle}")

    # Test create_mission_ped_in_vehicle
    print("\n--- Testing create_mission_ped_in_vehicle ---")
    veh_for_ped = MissionUtils.create_mission_vehicle("TEST_VEHICLE_2", 20.0, 20.0, 70.0, 0.0)
    ped_in_veh_handle = MissionUtils.create_mission_ped_in_vehicle(veh_for_ped, -1, "TEST_PED_2", 0, 20.0, 20.0, 70.0, 0.0)
    print(f"Created Ped In Vehicle Handle: {ped_in_veh_handle}")

    # Test create_camera
    print("\n--- Testing create_camera ---")
    cam_handle = MissionUtils.create_camera(50.0, 50.0, 100.0, 10.0, 0.0, 45.0, 500)
    print(f"Created Camera Handle: {cam_handle}")

    # Test create_fly_camera
    print("\n--- Testing create_fly_camera ---")
    fly_cam_handle = MissionUtils.create_fly_camera(60.0, 60.0, 110.0, 15.0, 5.0, 60.0, 200.0, 1000)
    print(f"Created Fly Camera Handle: {fly_cam_handle}")

    # Test delete_camera
    print("\n--- Testing delete_camera ---")
    MissionUtils.delete_camera(cam_handle)
    MissionUtils.delete_camera(fly_cam_handle)
"""

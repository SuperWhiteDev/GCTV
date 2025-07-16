import math

class EntityUtils:
    """
    A utility class providing helper functions for interacting with game entities.
    """

    @staticmethod
    def is_entity_at_coords(entity_coords, target_x, target_y, target_z, radius):
        """
        Checks if an entity is within a specified cubic radius around target coordinates.
        This function expects the entity's coordinates directly as a dictionary/object.

        Args:
            entity_coords (dict): A dictionary with 'x', 'y', 'z' keys representing the entity's coordinates.
            target_x (float): The X-coordinate of the target center.
            target_y (float): The Y-coordinate of the target center.
            target_z (float): The Z-coordinate of the target center.
            radius (float): The cubic radius around the target coordinates.

        Returns:
            bool: True if the entity is within the radius, False otherwise.
        """
        # Check if the entity's coordinates are within the cubic radius of the target coordinates.
        # math.fabs calculates the absolute difference.
        if (math.fabs(entity_coords['x'] - target_x) <= radius and
            math.fabs(entity_coords['y'] - target_y) <= radius and
            math.fabs(entity_coords['z'] - target_z) <= radius):
            return True # Entity found within the specified coordinates.
        
        return False # Entity not found within the specified coordinates.

# Example Usage (for testing purposes)
if __name__ == "__main__":
    print("--- Testing EntityUtils Python ---")

    # Mock entity coordinates
    mock_entity_1_coords = {'x': 10.0, 'y': 20.0, 'z': 30.0}
    mock_entity_2_coords = {'x': 15.0, 'y': 25.0, 'z': 35.0}
    mock_entity_3_coords = {'x': 100.0, 'y': 200.0, 'z': 300.0}

    target_coords = {'x': 12.0, 'y': 22.0, 'z': 32.0}
    search_radius = 3.0

    # Test cases
    print(f"Entity 1 at target coords (radius {search_radius}): {EntityUtils.is_entity_at_coords(mock_entity_1_coords, target_coords['x'], target_coords['y'], target_coords['z'], search_radius)}") # Expected: True
    print(f"Entity 2 at target coords (radius {search_radius}): {EntityUtils.is_entity_at_coords(mock_entity_2_coords, target_coords['x'], target_coords['y'], target_coords['z'], search_radius)}") # Expected: False (x diff is 3, > radius)
    print(f"Entity 3 at target coords (radius {search_radius}): {EntityUtils.is_entity_at_coords(mock_entity_3_coords, target_coords['x'], target_coords['y'], target_coords['z'], search_radius)}") # Expected: False

    search_radius_large = 100.0
    print(f"Entity 3 at target coords (radius {search_radius_large}): {EntityUtils.is_entity_at_coords(mock_entity_3_coords, target_coords['x'], target_coords['y'], target_coords['z'], search_radius_large)}") # Expected: True

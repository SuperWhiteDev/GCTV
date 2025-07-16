import json
import os

# Constants for configuration file names.
FEATURE_SETTINGS_FILE = "feature_settings.json"
GCT_CONFIG_FILE = "config.json"

class ConfigUtils:
    """
    A utility class for managing configuration settings stored in JSON files.
    Provides methods to get and set feature-specific and general GCTV settings.
    """

    @staticmethod
    def _read_json_file(file_path):
        """
        Internal helper to read a JSON file.
        Returns an empty dictionary if the file does not exist or is empty/invalid.
        """
        if not os.path.exists(file_path) or os.path.getsize(file_path) == 0:
            return {}
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except json.JSONDecodeError:
            print(f"Error: Could not decode JSON from {file_path}. Returning empty config.")
            return {}
        except Exception as e:
            print(f"An unexpected error occurred while reading {file_path}: {e}")
            return {}

    @staticmethod
    def _save_json_file(file_path, data):
        """
        Internal helper to save data to a JSON file.
        """
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=4) # Use indent for pretty-printing
        except Exception as e:
            print(f"Error: Could not save JSON to {file_path}: {e}")

    @staticmethod
    def get_feature_setting(section, setting):
        """
        Retrieves a specific feature setting from the feature_settings.json file.
        
        Args:
            section (str): The main section name (e.g., "Hotkeys").
            setting (str): The specific setting name within the section (e.g., "VehicleBoostKey").
            
        Returns:
            any: The value of the setting, or None if not found.
        """
        features_settings = ConfigUtils._read_json_file(FEATURE_SETTINGS_FILE)
        return features_settings.get(section, {}).get(setting)

    @staticmethod
    def set_feature_setting(section, setting, value):
        """
        Sets a specific feature setting and saves it to the feature_settings.json file.
        Creates the section or file if they do not exist.
        
        Args:
            section (str): The main section name.
            setting (str): The specific setting name.
            value (any): The value to set.
        """
        features_settings = ConfigUtils._read_json_file(FEATURE_SETTINGS_FILE)
        if section not in features_settings:
            features_settings[section] = {}
        features_settings[section][setting] = value
        ConfigUtils._save_json_file(FEATURE_SETTINGS_FILE, features_settings)
        print(f"Feature setting '{section}.{setting}' set to '{value}'.")

    @staticmethod
    def get_gct_setting(setting):
        """
        Retrieves a general GCTV setting from the config.json file.
        
        Args:
            setting (str): The specific setting name.
            
        Returns:
            any: The value of the setting, or None if not found.
        """
        gct_settings = ConfigUtils._read_json_file(GCT_CONFIG_FILE)
        return gct_settings.get(setting)

    @staticmethod
    def set_gct_setting(setting, value):
        """
        Sets a general GCTV setting and saves it to the config.json file.
        Creates the file if it does not exist.
        
        Args:
            setting (str): The specific setting name.
            value (any): The value to set.
        """
        gct_settings = ConfigUtils._read_json_file(GCT_CONFIG_FILE)
        gct_settings[setting] = value
        ConfigUtils._save_json_file(GCT_CONFIG_FILE, gct_settings)
        print(f"GCT setting '{setting}' set to '{value}'.")

# Example Usage (for testing purposes, remove in production if not needed)
if __name__ == "__main__":
    print("--- Testing ConfigUtils Python ---")

    # Set and get feature settings
    ConfigUtils.set_feature_setting("Hotkeys", "VehicleBoostKey", "F5")
    ConfigUtils.set_feature_setting("VehicleOptions", "AutoFixVehicle", True)
    boost_key = ConfigUtils.get_feature_setting("Hotkeys", "VehicleBoostKey")
    auto_fix = ConfigUtils.get_feature_setting("VehicleOptions", "AutoFixVehicle")
    print(f"Retrieved VehicleBoostKey: {boost_key}")
    print(f"Retrieved AutoFixVehicle: {auto_fix}")
    print(f"Non-existent setting: {ConfigUtils.get_feature_setting('NonExistent', 'Key')}")

    # Set and get GCT settings
    ConfigUtils.set_gct_setting("GameVolume", 0.75)
    ConfigUtils.set_gct_setting("PlayerName", "TestPlayer")
    volume = ConfigUtils.get_gct_setting("GameVolume")
    player_name = ConfigUtils.get_gct_setting("PlayerName")
    print(f"Retrieved GameVolume: {volume}")
    print(f"Retrieved PlayerName: {player_name}")
    print(f"Non-existent GCT setting: {ConfigUtils.get_gct_setting('DebugMode')}")

    # Clean up (optional, for testing)
    # import os
    # if os.path.exists(FEATURE_SETTINGS_FILE):
    #     os.remove(FEATURE_SETTINGS_FILE)
    # if os.path.exists(GCT_CONFIG_FILE):
    #     os.remove(GCT_CONFIG_FILE)
    # print("Cleaned up test config files.")

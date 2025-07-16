import GCT  # Imports the GCT module, providing access to GCT's API (e.g., globals, memory functions).

# Define global constants for supported game build versions.
# These versions indicate which game builds the script is compatible with for memory patching.
global SUPPORTED_BUILD_VERSION_ENHANCED, SUPPORTED_BUILD_VERSION_LEGACY
SUPPORTED_BUILD_VERSION_ENHANCED = "1.0.889.19"  # Supported version for the Enhanced edition of the game.
SUPPORTED_BUILD_VERSION_LEGACY = "1.0.3586.0"    # Supported version for the Legacy edition of the game.

def disable_vehicle_kick():
    """
    Disables the vehicle 'kick' or ejection mechanic in the game by patching specific memory addresses.
    Compatibility is checked against predefined game versions.
    """
    import Game  # Imports the Game module, which provides game-specific functions like memory operations.
    
    # Retrieve the detected game version (e.g., "Enhanced" or "Legacy") from GCT's global variables.
    version = GCT.Globals.get("GTA_VERSION")
    
    # Determine the memory address to patch based on the game version and build number.
    address = 0
    if version == "Enhanced":
        # Check if the Enhanced version's build number matches the supported version.
        if GCT.Globals.get("GTA_BUILD_VERSION") == SUPPORTED_BUILD_VERSION_ENHANCED:
            address = Game.GetBaseAddress() + 0x22164A0  # Specific offset for Enhanced version.
        else:
            # Raise an error if the build version is not supported.
            raise RuntimeError(f"The script is not compatible with your version of the game. Your game version is {GCT.Globals.get('GTA_BUILD_VERSION')}")
    elif version == "Legacy":
        # Check if the Legacy version's build number matches the supported version.
        if GCT.Globals.get("GTA_BUILD_VERSION") == SUPPORTED_BUILD_VERSION_LEGACY:
            address = Game.GetBaseAddress() + 0xD733E8  # Specific offset for Legacy version.
        else:
            # Raise an error if the build version is not supported.
            raise RuntimeError(f"The script is not compatible with your version of the game. Your game version is {GCT.Globals.get('GTA_BUILD_VERSION')}")
    else:
        # Raise an error if the game version cannot be determined.
        raise RuntimeError("Failed to determine the game version. Ensure GCT can identify it.")
    
    # Write the patch bytes to the calculated memory address.
    # [195, 144, 144, 144, 144] likely translates to assembly instructions (e.g., 
    # address    : ret
    # address + 1: nop (x4)
    #)
    # that disable the original function responsible for the vehicle kick.
    Game.WriteBytes(address, [195, 144, 144, 144, 144])
    
# Entry point of the script when executed directly.
if __name__ == "__main__":
    disable_vehicle_kick()
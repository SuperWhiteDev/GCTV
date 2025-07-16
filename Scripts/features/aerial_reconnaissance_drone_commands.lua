-- This script defines commands for launching and configuring the Aerial Reconnaissance Drone (ARD).

-- Global variables to manage the drone's state and missile count.
RegisterGlobalVariable("AerialReconnaissanceDroneState", 0.0)      -- 0.0 for inactive, 1.0 for active.
RegisterGlobalVariable("AerialReconnaissanceDroneMissilesCount", 0.0) -- Stores the number of missiles available.

-- Loading necessary utility modules.
local config_utils = require("config_utils") -- Module for configuration utilities.

--- Command to launch the Aerial Reconnaissance Drone.
-- Checks if player control is active and if the drone is not already launched.
function aerial_reconnaissance_drone_command()
    if PLAYER.IS_PLAYER_CONTROL_ON(PLAYER.PLAYER_ID()) then
        -- Check if the drone is already active via its global state.
        if GetGlobalVariable("AerialReconnaissanceDroneState") == 0.0 then
            -- Launch the main drone script.
            RunScript("features\\aerial_reconnaissance_drone.lua")
            printColoured("green", "Reconnaissance drone successfully launched.")
            print("You can move the camera using the WASD keys and adjust the height with the mouse wheel. Additionally, you have the option to fire guided missiles by pressing the left mouse button. If desired, you can change the number of missiles with the command \"set ard missiles count\".")
        else
            DisplayError(false, "The reconnaissance drone has already been launched.")
        end
    else
        DisplayError(false, "Player control is not active. Cannot launch drone.") -- Added a message if player control is off.
    end
end

--- Command to set the number of missiles for the Aerial Reconnaissance Drone.
-- Prompts the user for a new missile count and updates the global variable.
function set_aerial_reconnaissance_drone_missiles_count_command()
    local missiles_count_str = Input("Enter the number of missiles for the aerial reconnaissance drone: ", false)
    local missiles_count = tonumber(missiles_count_str)

    if missiles_count and missiles_count >= 0 then -- Validate input is a non-negative number.
        SetGlobalVariableValue("AerialReconnaissanceDroneMissilesCount", missiles_count)
        print("Aerial Reconnaissance Drone missile count set to: " .. missiles_count .. ".") -- Confirmation message.
    else
        DisplayError(false, "Incorrect input: Please enter a valid non-negative number for missiles count.")
    end
end

--- Initializes Aerial Reconnaissance Drone settings from configuration.
-- Reads the default missile count from the config and sets the global variable.
function initialize_settings()
    local drone_missiles_count_from_config = tonumber(config_utils.get_feature_setting("AerialReconnaissanceDroneOptions", "DroneMissilesCount"))

    -- Ensure a default value if config setting is invalid.
    if not drone_missiles_count_from_config then
        drone_missiles_count_from_config = 5.0 -- Default missile count if config fails.
        print("Warning: DroneMissilesCount not found in config or invalid. Defaulting to 5.0.")
    end
    SetGlobalVariableValue("AerialReconnaissanceDroneMissilesCount", drone_missiles_count_from_config)
end

-- Define a dictionary with commands and their corresponding functions.
local commands = {
    ["aerial reconnaissance drone"] = aerial_reconnaissance_drone_command,
    ["ard"] = aerial_reconnaissance_drone_command, -- Alias command.
    ["set ard missiles count"] = set_aerial_reconnaissance_drone_missiles_count_command
}

-- Initialize the pseudo-random number generator based on the current time.
-- This ensures different results for math.random each time the script runs.
math.randomseed(os.time())

-- Initialize feature settings upon script load.
initialize_settings()

-- Loop for registering commands.
-- Iterates through all "command name" - "function" pairs in the 'commands' dictionary.
for command_name, command_function in pairs(commands) do
    -- Registers the command. 'BindCommand' is a custom function of your GCTV API.
    if not BindCommand(command_name, command_function) then
        -- Displays an error message if command registration failed.
        DisplayError(true, "Failed to register the command: " .. command_name)
    end
end

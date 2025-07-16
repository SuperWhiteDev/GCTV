-- Global variable to store the noclip speed, accessible by other scripts.
RegisterGlobalVariable("NoclipSpeed", 0.0)

-- Loading necessary utility modules.
local config_utils = require("config_utils") -- Module for configuration utilities.

--- Displays help information for the noclip feature.
-- Informs the user how to enable/disable noclip and change its speed.
function noclip_help_command()
    print("If you want to enable noclip, press F5 on the keyboard. Disabling noclip occurs by pressing the same button. You can also change the flight speed with the command \"set noclip speed\"")
end

--- Sets the noclip flight speed.
-- Prompts the user for a new speed value and updates the global variable.
function set_noclip_speed_command()
    if IsGlobalVariableExist("NoclipSpeed") then
        -- Prompt for new speed, displaying current speed.
        local speed_str = Input("Enter noclip speed (current speed is " .. GetGlobalVariable("NoclipSpeed") .. "): ", false)
        local speed = tonumber(speed_str)

        if speed then
            SetGlobalVariableValue("NoclipSpeed", speed)
            print("Noclip speed set to: " .. speed) -- Confirmation message
        else
            DisplayError(false, "Incorrect input: Please enter a valid number for speed.")
        end
    else
        DisplayError(false, "NoclipSpeed global variable does not exist. Noclip feature might not be initialized.")
    end
end

--- Initializes noclip settings from configuration.
-- Reads the default noclip speed from the config and sets the global variable.
function initialize_settings()
    local noclip_speed_from_config = tonumber(config_utils.get_feature_setting("NoclipOptions", "NoclipSpeed"))

    -- Ensure a default value if config setting is invalid.
    if not noclip_speed_from_config then
        noclip_speed_from_config = 1.0 -- Default speed if config fails
        print("Warning: NoclipSpeed not found in config or invalid. Defaulting to 1.0.")
    end
    SetGlobalVariableValue("NoclipSpeed", noclip_speed_from_config)
end

-- Define a dictionary with commands and their corresponding functions.
local commands = {
    ["noclip"] = noclip_help_command,
    ["set noclip speed"] = set_noclip_speed_command
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

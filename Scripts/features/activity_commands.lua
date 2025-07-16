-- This script defines commands related to various in-game activities.

--- Placeholder function for a test activity command.
-- This function is currently empty and can be extended for testing purposes.
function test_activitie_command()
    -- This function is a placeholder.
end

--- Command to start the "Military Convoy" activity.
-- Checks if the activity is already running and prompts the user for confirmation.
function military_convoy_command()
    -- Check if the "MilitaryConvoyActivityState" global variable exists and is active.
    if IsGlobalVariableExist("MilitaryConvoyActivityState") and GetGlobalVariable("MilitaryConvoyActivityState") == 1.0 then
        print("This activity has already been started.")
        return nil -- Exit if activity is already running.
    end

    -- Prompt the user for confirmation to start the activity.
    local start_activity_input = Input("Do you want to start the activity \"Military Convoy\"? [Y/n]: ", true)

    if start_activity_input == "y" then
        -- If the global variable doesn't exist, register it.
        if not IsGlobalVariableExist("MilitaryConvoyActivityState") then
            RegisterGlobalVariable("MilitaryConvoyActivityState", 1.0)
            printColoured("green", "Military Convoy activity state registered and set to active.")
        -- If it exists but is 0.0 (inactive), set it to 1.0 (active).
        elseif GetGlobalVariable("MilitaryConvoyActivityState") == 0.0 then
            SetGlobalVariableValue("MilitaryConvoyActivityState", 1.0)
            printColoured("green", "Military Convoy activity set to active.")
        end
    else
        print("Military Convoy activity start cancelled.")
    end
end

-- Define a dictionary with commands and their corresponding functions.
local commands = {
    ["test activitie"] = test_activitie_command,
    ["military convoy activity"] = military_convoy_command,
}

-- Initialize the pseudo-random number generator based on the current time.
-- This ensures different results for math.random each time the script runs.
math.randomseed(os.time())

-- Loop for registering commands.
-- Iterates through all "command name" - "function" pairs in the 'commands' dictionary.
for command_name, command_function in pairs(commands) do
    -- Registers the command. 'BindCommand' is a custom function of your GCTV API.
    if not BindCommand(command_name, command_function) then
        -- Displays an error message if command registration failed.
        DisplayError(true, "Failed to register the command: " .. command_name)
    end
end

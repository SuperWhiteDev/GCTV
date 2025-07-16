-- This script defines commands related to managing the player's game session.

--- Command to make the player leave the current online session.
-- This function calls a native GTA V network function to initiate leaving the session.
function leave_session_command()
    NETWORK.NETWORK_SESSION_LEAVE(0)
end

-- Note: NETWORK_PLAYER_GET_USERID - This native function retrieves the Rockstar ID of a network player.
-- Note: NETWORK_SEND_TEXT_MESSAGE - This native function is used to send text messages within the game network.

-- Define a dictionary with commands and their corresponding functions.
local commands = {
    ["leave session"] = leave_session_command
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

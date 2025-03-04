function LeaveSessionCommand()
    NETWORK.NETWORK_SESSION_LEAVE(0)
end

--NETWORK_PLAYER_GET_USERID its get rockstar ID
--NETWORK_SEND_TEXT_MESSAGE need to test

-- Define a dictionary with commands and their functions
local Commands = {
    ["leave session"] = LeaveSessionCommand
}

math.randomseed(os.time())

-- Loop for registering commands
for commandName, commandFunction in pairs(Commands) do
    if not BindCommand(commandName, commandFunction) then
        DisplayError(true, "Failed to register the command: " .. commandName)
    end
end
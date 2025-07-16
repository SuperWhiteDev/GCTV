function LeaveSessionCommand()
    NETWORK.NETWORK_SESSION_LEAVE(0)
end

--NETWORK_PLAYER_GET_USERID its get rockstar ID
--NETWORK_SEND_TEXT_MESSAGE need to test

-- Определим словарь с командами и их функциями
local Commands = {
    ["leave session"] = LeaveSessionCommand
}

math.randomseed(os.time())

-- Цикл для регистрации команд
for commandName, commandFunction in pairs(Commands) do
    if not BindCommand(commandName, commandFunction) then
        DisplayError(true, "Failed to register the command: " .. commandName)
    end
end
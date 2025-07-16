function TestActivitieCommand()
    
end

function MilitaryConvoyCommand()
    if IsGlobalVariableExist("MilitaryConvoyActivityState") and GetGlobalVariable("MilitaryConvoyActivityState") == 1.0 then
        print("This activity has already been started")
        return nil
    end

    io.write("Do you want to start the activity \"Military Convoy\"? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        if not IsGlobalVariableExist("MilitaryConvoyActivityState") then
            RegisterGlobalVariable("MilitaryConvoyActivityState", 1.0)
        elseif GetGlobalVariable("MilitaryConvoyActivityState") == 0.0 then
            SetGlobalVariableValue("MilitaryConvoyActivityState", 1.0)
        end
    end
end


-- Определим словарь с командами и их функциями
local Commands = {
    ["test activitie"] = TestActivitieCommand,
    ["military convoy activity"] = MilitaryConvoyCommand,
}

math.randomseed(os.time())

-- Цикл для регистрации команд
for commandName, commandFunction in pairs(Commands) do
    if not BindCommand(commandName, commandFunction) then
        DisplayError(true, "Failed to register the command: " .. commandName)
    end
end
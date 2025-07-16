RegisterGlobalVariableTable("EsplinePlayerTargets") -- Регистрируем таблицу
local MaxEsplinePlayersCount = 32


function DrawEspLineCommand()
    local options = { "Player", "Entity" }

    local option = InputFromList("Enter to whom you want to draw the esp line: ", options)

    if option == 0 then
        io.write("Enter player ID: ")
        local player = tonumber(io.read())
        
        if player and PLAYER.GET_PLAYER_PED(player) ~= 0.0 then
            local tableSize = #GetGlobalVariableTable("EsplinePlayerTargets")

            if tableSize < MaxEsplinePlayersCount then
                SetGlobalVariableTableValue("EsplinePlayerTargets", tableSize+1, player)

                if tableSize == 0 then
                    RunScript("C:\\Program Files\\GCTV\\Scripts\\features\\EspFeatures.lua")
                end
            else
                DisplayError(false, "You have exceeded the maximum number of esp lines for players")
            end
        end
    elseif option == 1 then
        
    end
end

function RemoveElementFromTable(tableName, elementToRemove)
    -- Получаем таблицу по имени
    local targets = GetGlobalVariableTable(tableName)
    
    if targets then
        local indexToRemove = nil
        
        -- Ищем индекс элемента, который нужно удалить
        for i = 1, #targets do
            if targets[i] == elementToRemove then
                indexToRemove = i
                break
            end
        end
        -- Если элемент найден, удаляем его
        if indexToRemove then
            if indexToRemove == #targets then
                SetGlobalVariableTableValue(tableName, indexToRemove, nil)
            else
                -- Сдвигаем элементы влево
                for i = indexToRemove, #targets - 1 do
                    targets[i] = targets[i + 1]
                end
            
                -- Удаляем последний элемент, поскольку он теперь дубликат
                targets[#targets] = nil

                -- Обновляем таблицу в глобальной памяти
                for i = 1, #targets+1 do
                    print(i, targets[i])
                    SetGlobalVariableTableValue(tableName, i, targets[i])
                end
            end
        else
            return false
        end
    else
        return false
    end

    return true
end

function DisableEspLine()
    local options = { "Player", "Entity" }

    local option = InputFromList("Enter to whom you want to draw the esp line: ", options)

    if option == 0 then
        local playerTargets = GetGlobalVariableTable("EsplinePlayerTargets")
        local players = { }
        
        if #playerTargets > 0 then
            for i = 1, #playerTargets, 1 do
                table.insert(players, NETWORK.NETWORK_PLAYER_GET_NAME(playerTargets[i]))
            end
    
            local player = InputFromList("Enter to whom you want to draw the esp line: ", players)
            if player then
                if not RemoveElementFromTable("EsplinePlayerTargets", playerTargets[player+1]) then
                    DisplayError(false, "Could not find the player in the list of targets")
                end
            end
        else
            DisplayError(false, "Esp lines are not drawn for any player")
        end
    elseif option == 1 then
        
    end
end

-- Определим словарь с командами и их функциями
local Commands = {
    ["draw esp line"] = DrawEspLineCommand,
    ["disable esp line"] = DisableEspLine
}

math.randomseed(os.time())

-- Цикл для регистрации команд
for commandName, commandFunction in pairs(Commands) do
    if not BindCommand(commandName, commandFunction) then
        DisplayError(true, "Failed to register the command: " .. commandName)
    end
end
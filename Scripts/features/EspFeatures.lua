local currentPlayer = 0

function StillHasTargets()
    local playerTargets = #GetGlobalVariableTable("EsplinePlayerTargets")

    if playerTargets > 0 then
        return true
    end

    return false
end

function DrawEspLine(entity)
    local localPlayerCoords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    local targetEntityCoords = ENTITY.GET_ENTITY_COORDS(entity, true)
        
    GRAPHICS.DRAW_LINE(localPlayerCoords.x, localPlayerCoords.y, localPlayerCoords.z, targetEntityCoords.x, targetEntityCoords.y, targetEntityCoords.z, 255, 0, 0, 255)
end

-- Получаем и выводим значения из таблицы
function OnTick()
    local playerTargets = GetGlobalVariableTable("EsplinePlayerTargets")
    for i = 1, #playerTargets do
        DrawEspLine(PLAYER.GET_PLAYER_PED(playerTargets[i]))
    end
end


while ScriptStillWorking and StillHasTargets() do
    OnTick()
end
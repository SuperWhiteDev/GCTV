local entityUtils = { }

function entityUtils.IsEntityAtCoords(entity, targetX, targetY, targetZ, radius)
    local coords = ENTITY.GET_ENTITY_COORDS(entity, true)
        
    -- Проверяем, находится ли сущность в пределах заданной области
    if math.abs(coords.x - targetX) <= radius and math.abs(coords.y - targetY) <= radius and math.abs(coords.z - targetZ) <= radius then
        return true  -- Сущность найдена в заданных координатах
    end
    
    return false  -- Сущность не найдена в заданных координатах
end

return entityUtils
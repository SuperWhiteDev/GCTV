local networkUtils = require("network_utils")

local waittime = 500
local dynamicNeonTransitionState = init_transition()
local dynamicColorTransitionState = init_transition()
local duration = 2000 -- Длительность перехода в миллисекундах
local steps = 100 -- Количество шагов

local vehicle = nil

function SetDynamicNeonColor(veh, R, G, B)
    VEHICLE.SET_VEHICLE_NEON_COLOUR(veh, R, G, B)
end

function SetDynamicVehicleColor(veh, R, G, B)
    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, R, G, B)
    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, R, G, B)
end

function init_transition()
    return {
        currentStep = 0,
        steps = nil,
        colorCycleIndex = 1, -- Индекс текущего цвета в цикле
        duration = nil,
        setColorFunction = nil
    }
end

function interpolate_color(startColor, endColor, t)
    local currentColor = {}
    for i = 1, 3 do
        currentColor[i] = math.floor(startColor[i] + (endColor[i] - startColor[i]) * t)
    end
    return currentColor
end

-- Функция для плавного перехода цвета, выполняющая одну итерацию
function smooth_rgb_transition(state, setColorFunction, vehicle, duration, steps)
    local colors = {
        {255, 0, 0},   -- Красный
        {0, 255, 0},   -- Зеленый
        {0, 0, 255},   -- Синий
    }

    -- Инициализация состояния при первом вызове
    if state.currentStep == 0 then
        state.setColorFunction = setColorFunction
        state.vehicle = vehicle
        state.duration = duration
        state.steps = steps
    end

    -- Если у нас закончился шаг, переходим к следующему цвету
    if state.currentStep >= state.steps then
        state.currentStep = 0
        state.colorCycleIndex = (state.colorCycleIndex % #colors) + 1 -- Увеличиваем индекс цвета
    end

    -- Определение начального и конечного цвета
    local startColor = colors[state.colorCycleIndex]
    local endColor = colors[(state.colorCycleIndex % #colors) + 1] -- Следующий цвет в цикле

    local t = state.currentStep / state.steps -- Нормализованный параметр (от 0 до 1)
    local currentColor = interpolate_color(startColor, endColor, t)

    state.setColorFunction(state.vehicle, currentColor[1], currentColor[2], currentColor[3])

    -- Увеличиваем текущий шаг
    state.currentStep = state.currentStep + 1
end

--[[
STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2")
while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_rcbarry2") do
    Wait(0) -- Ждем, пока эффект загрузится
end

print("PTFX succusfully loaded")
]]

while ScriptStillWorking do
    if IsGlobalVariableExist("DynamicNeonVehicle") and GetGlobalVariable("DynamicNeonVehicle") ~= 0.0 then
        local veh = GetGlobalVariable("DynamicNeonVehicle")
        networkUtils.RequestControlOf(veh)
        smooth_rgb_transition(dynamicNeonTransitionState, SetDynamicNeonColor, veh, duration, steps)
        waittime = 200
    end
    if IsGlobalVariableExist("DynamicColorVehicle") and GetGlobalVariable("DynamicColorVehicle") ~= 0.0 then
        local veh = GetGlobalVariable("DynamicColorVehicle")
        networkUtils.RequestControlOf(veh)
        smooth_rgb_transition(dynamicColorTransitionState, SetDynamicVehicleColor, veh, duration, steps)
        waittime = 200
    end

    --[[vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
    -- Проверяем, находится ли игрок в автомобиле
    if vehicle ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(vehicle) then
        local rearRightLightBone = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "taillight_r") -- Задний правый фонарь
        local rearLeftLightBone = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(vehicle, "taillight_l") -- Задний левый фонарь

        -- Получаем координаты для фонарей
        local rearRightLightPos = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(vehicle, rearRightLightBone)
        local rearLeftLightPos = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(vehicle, rearLeftLightBone)

        -- Запускаем эффект частиц
        GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry2")
        GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_clown_appears", rearRightLightPos.x, rearRightLightPos.y, rearRightLightPos.z + 0.5, 0.0, 0.0, 0.0, 0, 5.0, false, false, false)
        GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD("scr_clown_appears", rearLeftLightPos.x, rearLeftLightPos.y, rearLeftLightPos.z + 0.5, 0.0, 0.0, 0.0, 0, 5.0, false, false, false)
        waittime = 10
    end
    ]]
    Wait(waittime)
end

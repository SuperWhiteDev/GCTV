local networkUtils = require("network_utils")

local waittime = 500
local dynamicNeonTransitionState = init_transition()
local dynamicColorTransitionState = init_transition()
local duration = 2000 -- Transition duration in milliseconds
local steps = 100 -- Number of steps

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
        colorCycleIndex = 1, -- Index of the current color in the loop
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

-- Function for smooth color transition, performing one iteration
function smooth_rgb_transition(state, setColorFunction, vehicle, duration, steps)
    local colors = {
        {255, 0, 0},   -- Red
        {0, 255, 0},   -- Green
        {0, 0, 255},   -- Blue
    }

    -- Initializing state on first call
    if state.currentStep == 0 then
        state.setColorFunction = setColorFunction
        state.vehicle = vehicle
        state.duration = duration
        state.steps = steps
    end

    -- If we run out of a step, move on to the next color
    if state.currentStep >= state.steps then
        state.currentStep = 0
        state.colorCycleIndex = (state.colorCycleIndex % #colors) + 1 -- Увеличиваем индекс цвета
    end

    -- Defining the start and end colors
    local startColor = colors[state.colorCycleIndex]
    local endColor = colors[(state.colorCycleIndex % #colors) + 1] -- Next color in cycle

    local t = state.currentStep / state.steps -- Normalized parameter (0 to 1)
    local currentColor = interpolate_color(startColor, endColor, t)

    state.setColorFunction(state.vehicle, currentColor[1], currentColor[2], currentColor[3])

    -- Increase the current step
    state.currentStep = state.currentStep + 1
end

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

    Wait(waittime)
end

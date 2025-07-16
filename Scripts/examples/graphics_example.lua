local graphics_base = require("graphics_base")
local graphicsLib = require("graphics++")

local iteration = 0

while not graphics_base.IsGraphicsLibraryLoaded() do
    Wait(100)
end

local screenWidth, screenHeight = graphics_base.GetDisplaySize()

local iterationTextWidth = 300
local iterationTextHeight = 30
local iterationsText = graphicsLib.Text.DrawText("Iteration: " .. iteration, screenWidth-iterationTextWidth, 0, 255, 255, 255, 255, "", 20)
local entitiesText = graphicsLib.Text.DrawText("Entities: 0", screenWidth-iterationTextWidth, 30, 255, 255, 255, 255, "", 20)
local vehiclesText = graphicsLib.Text.DrawText("Vehicles: 0", screenWidth-iterationTextWidth, 60, 255, 255, 255, 255, "", 20)
local pedsText = graphicsLib.Text.DrawText("Peds: 0", screenWidth-iterationTextWidth, 90, 255, 255, 255, 255, "", 20)
local objsText = graphicsLib.Text.DrawText("Objs: 0", screenWidth-iterationTextWidth, 120, 255, 255, 255, 255, "", 20)

function DoesEntityExists(entity)
    return NativeCall(HashString("DOES_ENTITY_EXIST"), "boolean", {entity})
end

while ScriptStillWorking do
    
    local vehicles, vehsCount = GetAllVehicles()
    local peds, pedsCount = GetAllPeds()
    local objs, objsCount = GetAllObjects()
    local entities, entitysCount = {table.unpack(vehicles), table.unpack(peds), table.unpack(objs)}, pedsCount + vehsCount + objsCount

    entitiesText:SetLabel("Entities: " .. entitysCount)
    vehiclesText:SetLabel("Vehicles: " .. vehsCount)
    pedsText:SetLabel("Peds: " .. pedsCount)
    objsText:SetLabel("Objs: " .. objsCount)
    
    for _, veh in ipairs(vehicles) do
        --if ENTITY.GET_ENTITY_HEALTH(veh) > 0 then
        --    ENTITY.SET_ENTITY_HEALTH(veh, 0, PLAYER.PLAYER_PED_ID(), 0)
        --end
    end
    
    for _, ped in ipairs(peds) do
        --local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
        --local forwad = ENTITY.GET_ENTITY_FORWARD_VECTOR(PLAYER.PLAYER_PED_ID())

        --ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, coords.x-forwad.x, coords.y-forwad.y, coords.y+0.5, true, true, true)
        --if ENTITY.GET_ENTITY_HEALTH(ped) > 0 then
        --    ENTITY.SET_ENTITY_HEALTH(ped, 0, PLAYER.PLAYER_PED_ID(), 0)
        --end
    end

    for _, obj in ipairs(objs) do
    end
    
    iteration = iteration + 1
    iterationsText:SetLabel("Iteration: " .. iteration)

    Wait(200)
end

local teleportUtils = require("teleport_utils")
local mapUtils = require("map_utils")
local worldUtils = require("world_utils")


function TeleportLocalPlayer(coords)
    local entity = nil
    local veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    if PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), true) and veh ~= 0.0 then
        entity = veh
    else
        entity = PLAYER.PLAYER_PED_ID()
    end

    teleportUtils.TeleportEntity(entity, coords)
end

function TeleportCommand()
    local coords = nil

    local places = { "Waypoint", "North Yankton", "Micheal House", "Franklin House", "Trevor Trailer", "Airport Field", "Desert Airfield", "Military Base", "Maze Bank",
                     "Cayo Perico", "Underground garage", "Saved place", "Custom" }
    local place = InputFromList("Enter where you want to teleport to: ", places)

    if place == 0 then
        coords = mapUtils.GetWaypointCoords()
        if not coords then
            print("Please choose a waypoint first")
            return nil
        end
    elseif place == 1 then
        worldUtils.InitNorthYankton()
        
        coords = { x = 3360.19, y = -4849.67, z = 111.8 }
    elseif place == 2 then
        coords = { x = -852.4, y = 160.0, z = 65.6 }
    elseif place == 3 then
        coords = { x = 7.9, y = 548.1, z = 175.5 }
    elseif place == 4 then
        coords = { x = 1985.7, y = 3812.2, z = 32.2 }
    elseif place == 5 then
        coords = { x = -1336.0, y = -3044.0, z = 13.9 }
    elseif place == 6 then 
        coords = { x = 1747.0, y = 3273.7, z = 41.1 }
    elseif place == 7 then 
        coords = { x = -2047.4, y = 3132.1, z = 32.8 }
    elseif place == 8 then
        coords = { x = -75.015, y = -818.215, z = 326.176 }
    elseif place == 9 then
        worldUtils.InitCayoPerico()

        coords = { x = 4444.66, y = -4474.621, z = 20.229855 }
    elseif place == 10 then
        coords = { x = 404.760, y = -955.650, z = -99.685 }
    elseif place == 11 then
        local savedplaces = JsonReadList("teleports.json")

        if savedplaces ~= nil then
            local places = { }

            for i = 1, #savedplaces do
                local element = savedplaces[i]
                table.insert(places, element.name .. "(" .. element.zone .. ")")
            end

            local placeID = InputFromList("Enter where you want to teleport to: ", places)

            if placeID ~= -1 then
                local place = savedplaces[placeID+1]
                coords = { x = place.x, y = place.y, z = place.z }
            else
                return nil
            end
        else
            return nil
        end
    elseif place == 12 then
        io.write("Enter X coord: ")
        local CoordX = io.read()
        io.write("Enter Y coord: ")
        local CoordY = io.read()
        io.write("Enter Z coord: ")
        local CoordZ = io.read()
        coords = { x = CoordX, y = CoordY, z = CoordZ }

    else
        return nil
    end

    TeleportLocalPlayer(coords)
end

function SaveCurrentPlaceCommand()
    local savedplaces = JsonReadList("teleports.json")
    
    --[[for i = 1, #savedplaces do
        local element = savedplaces[i]
        print("Name:", element.name)
        print("Address:", element.address)
        print("Namespace:", element.namespace)
    end
    ]]

    io.write("Enter a name for the current location: ")
    local locatioName = io.read()

    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    table.insert(savedplaces, { name = locatioName, x = coords.x, y = coords.y, z = coords.z, zone = mapUtils.GetZoneName(coords.x, coords.y, coords.z) })
    
    JsonSaveList("teleports.json", savedplaces)
end


-- Определим словарь с командами и их функциями
local Commands = {
    ["teleport"] = TeleportCommand,
    ["save current place"] = SaveCurrentPlaceCommand
}

math.randomseed(os.time())

-- Цикл для регистрации команд
for commandName, commandFunction in pairs(Commands) do
    if not BindCommand(commandName, commandFunction) then
        DisplayError(true, "Failed to register the command: " .. commandName)
    end
end
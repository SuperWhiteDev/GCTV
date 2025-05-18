local spectateCamera = nil

local networkUtils = require("network_utils")
local mathUtils = require("math_utils")
local mapUtils = require("map_utils")

function GetWeaponName(weapon)
    local weapons = JsonReadList("weapons.json")

    if weapons ~= nil then
        for weapontype, weaponnames in pairs(weapons) do
            for weaponname, weaponhash in pairs(weaponnames) do
                if tonumber32(weaponhash) == weapon then
                    return weaponname
                end
            end
        end
    end
    return "Unarmed"
end

-- Функция для вывода таблицы
function printTable(tbl)
    -- Определим ширину колонок
    local columnWidths = {}
    for _, row in ipairs(tbl) do
        for colIndex, value in ipairs(row) do
            local strValue = tostring(value)
            columnWidths[colIndex] = math.max(columnWidths[colIndex] or 0, #strValue)
        end
    end

    -- Выводим таблицу
    for _, row in ipairs(tbl) do
        local rowStr = ""
        for colIndex, value in ipairs(row) do
            local strValue = tostring(value)
            rowStr = rowStr .. strValue .. string.rep(" ", columnWidths[colIndex] - #strValue + 1) -- добавляем пробелы
        end
        io.write_anonym(rowStr)
        io.write_anonym("\n")
    end
end

function PlayersCommand()
    local playerscount = PLAYER.GET_NUMBER_OF_PLAYERS() - 1

    print("Players count is " .. string.format("%d", playerscount))

    for i = 0, playerscount, 1 do
        print(i .. ". " .. PLAYER.GET_PLAYER_NAME(i))
    end
end

function PlayersInfoCommand()
    local playersinfo = {
        {"Player", "Health", "Armor", "Wanted Level", "In God", "In Veh", "In Interior", "Weapon", "Cash", "Distance", "Zone"}
    }
    local playerscount = PLAYER.GET_NUMBER_OF_PLAYERS() - 1
    local hostPlayer = NETWORK.NETWORK_GET_HOST_PLAYER_INDEX()
    local LocalPlayerCoords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)

    for i = 0, playerscount, 1 do
        local playerPed = PLAYER.GET_PLAYER_PED(i)
        local playerName = NETWORK.NETWORK_PLAYER_GET_NAME(i)
        if playerName ~= "**Invalid**" then
            local wantedLevel = PLAYER.GET_PLAYER_WANTED_LEVEL(i)
            local stars = ""
            local inGod = PLAYER.GET_PLAYER_INVINCIBLE(i)
            local inVeh = PED.GET_VEHICLE_PED_IS_IN(playerPed, true)
            local inInterior = INTERIOR.GET_INTERIOR_FROM_ENTITY(playerPed)

            local weaponp = New(4)
            WEAPON.GET_CURRENT_PED_WEAPON(playerPed, weaponp, true)
            local playerweapon = GetWeaponName(Game.ReadInt(weaponp))
            Delete(weaponp)

            local coords = ENTITY.GET_ENTITY_COORDS(playerPed, true)
            
            local distance = math.floor(mathUtils.GetDistanceBetweenCoords(coords, LocalPlayerCoords)) .. "m"
            local ZoneName = mapUtils.GetZoneName(coords.x, coords.y, coords.z)

            if i == hostPlayer then
                playerName = playerName .. "(HOST)"
            end

            if wantedLevel == 0.0 then
                stars = "No"
            else
                for i = 0, wantedLevel do
                    stars = stars .. "*"
                end
            end
     

            if inGod then
                inGod = "Yes"
            else
                inGod = "No"
            end
            if inVeh ~= 0.0 then
                inVeh = "Yes"
            else    
                inVeh = "No"
            end
            if inInterior ~= 0.0 then
                inInterior = "Yes"
            else
                inInterior = "No"
            end

            table.insert(playersinfo, {i .. "." .. playerName, ENTITY.GET_ENTITY_HEALTH(playerPed), PED.GET_PED_ARMOUR(playerPed), stars, inGod, inVeh, inInterior, playerweapon, PED.GET_PED_MONEY(playerPed), distance, ZoneName })
        end
    end

    print("Player information table: ")
    printTable(playersinfo)
end

function GetPlayerVehicleCommand()
    io.write("Enter player ID: ")
    local player = tonumber(io.read())

    if player then
        print("Player vehicle is " .. string.format("%d", PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(player))))
    else
        DisplayError(false, "Uncorrect input")
    end
end

function GetPlayerPositionCommand()
    io.write("Enter player ID: ")
    local player = tonumber(io.read())

    if player then
        local playerPed = PLAYER.GET_PLAYER_PED(player)
        local coords = ENTITY.GET_ENTITY_COORDS(playerPed, true)
        print("Player coords x = " .. coords.x .. " y = " .. coords.y .. " z = " .. coords.z)
        print("Player heading is " .. ENTITY.GET_ENTITY_HEADING(playerPed))

    else
        DisplayError(false, "Uncorrect input")
    end
end

function GetPlayerSpeedCommand()
    io.write("Enter player ID: ")
    local player = tonumber(io.read())

    if player then
        print("Player speed is " .. ENTITY.GET_ENTITY_SPEED(PLAYER.GET_PLAYER_PED(player)))
    else
        DisplayError(false, "Uncorrect input")
    end
end

function KickplayerCommand()
    io.write("Enter player ID(only works if you are host): ")
    local player = tonumber(io.read())

    if player then
        NETWORK.NETWORK_SESSION_KICK_PLAYER(player)
    else
        DisplayError(false, "Uncorrect input")
    end
end
function ExplodePlayerCommand()
    local Iters = 0
    io.write("Enter player ID: ")
    local player = tonumber(io.read())

    if player then
        local playerped = PLAYER.GET_PLAYER_PED(player)
        while not ENTITY.IS_ENTITY_DEAD(playerped) and Iters < 100 do
            local coords = ENTITY.GET_ENTITY_COORDS(playerped, true)
            FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 4, 10000.0, true, false, 100.0, false)
            Iters = Iters + 1
        end
    end
end

function FreezePlayerCommand()
    local Iters = 0
    io.write("Enter player ID: ")
    local player = tonumber(io.read())

    if player then
        local playerped = PLAYER.GET_PLAYER_PED(player)
        networkUtils.RequestControlOf(playerped)
        while Iters < 500 do
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(playerped)
            Iters = Iters + 1
        end
    end
end
function ShakePlayerCamCommand()
    local Iters = 0
    io.write("Enter player ID: ")
    local player = tonumber(io.read())

    if player then
        local playerped = PLAYER.GET_PLAYER_PED(player)

        io.write("Enter duration in ms: ")
        local duration = tonumber(io.read())/10

        while duration > 0.0 do
            local coords = ENTITY.GET_ENTITY_COORDS(playerped, true)
            FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 4, 0.0, false, true, 1000.0, true)
            duration = duration - 1
            Wait(1)
        end
    end
end

function SpectatePlayerCommand()
    if not spectateCamera then
        io.write("Enter player ID: ")
        local player = tonumber(io.read())

        if player then
            spectateCamera = CAM.CREATE_CAM("DEFAULT_SCRIPTED_CAMERA", true)
            CAM.ATTACH_CAM_TO_ENTITY(spectateCamera, PLAYER.GET_PLAYER_PED(player), 0.0, -1.0, 1.0, true)
            CAM.RENDER_SCRIPT_CAMS(true, true, 1000, true, true, 0)
            CAM.SET_CAM_ACTIVE(spectateCamera, true)
            STREAMING.SET_FOCUS_ENTITY(PLAYER.GET_PLAYER_PED(player))
        else
            DisplayError(false, "Uncorrect input")
        end
    else
        io.write("You want to detach the camera from the player? [Y/n]: ")
        local input = string.lower(io.read())

        if input == "y" then
            CAM.DETACH_CAM(spectateCamera)
            CAM.STOP_RENDERING_SCRIPT_CAMS_USING_CATCH_UP(false, 0.0, 0, 0)
            CAM.SET_CAM_ACTIVE(spectateCamera, false)
            CAM.DESTROY_CAM(spectateCamera, false)
            STREAMING.SET_FOCUS_ENTITY(PLAYER.PLAYER_PED_ID())
            spectateCamera = nil
        end
    end
end

-- Определим словарь с командами и их функциями
local Commands = {
    ["players"] = PlayersCommand,
    ["players info"] = PlayersInfoCommand,
    ["get player vehicle"] = GetPlayerVehicleCommand,
    ["get player position"] = GetPlayerPositionCommand,
    ["get player speed"] = GetPlayerSpeedCommand,
    ["kick player"] = KickplayerCommand,
    ["explode player"] = ExplodePlayerCommand,
    ["freeze player"] = FreezePlayerCommand,
    ["shake player cam"] = ShakePlayerCamCommand,
    ["spectate player"] = SpectatePlayerCommand
}

--Trap object tr_prop_tr_container_01a

math.randomseed(os.time())

-- Цикл для регистрации команд
for commandName, commandFunction in pairs(Commands) do
    if not BindCommand(commandName, commandFunction) then
        DisplayError(true, "Failed to register the command: " .. commandName)
    end
end
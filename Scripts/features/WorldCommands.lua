RegisterGlobalVariable("BombAreaCoordX", 0.0)
RegisterGlobalVariable("BombAreaCoordY", 0.0)
RegisterGlobalVariable("BombAreaCoordZ", 0.0)

RegisterGlobalVariable("BanditsTarget", 0.0)

local world_enum = require("world_enums")
local mapUtils = require("map_utils")
local networkUtils = require("network_utils")
local worldUtils = require("world_utils")

function SetTimeCommand()
    print("Current time is " .. math.floor(CLOCK.GET_CLOCK_HOURS()) .. ":" .. math.floor(CLOCK.GET_CLOCK_MINUTES()) .. ":" .. math.floor(CLOCK.GET_CLOCK_SECONDS()))

    io.write("Enter hours: ")
    local hours = tonumber(io.read())
    io.write("Enter minutes: ")
    local minutes = tonumber(io.read())
    io.write("Enter seconds: ")
    local seconds = tonumber(io.read())

    if hours and minutes and seconds then
        NETWORK.NETWORK_OVERRIDE_CLOCK_TIME(hours, minutes, seconds)
    else
        DisplayError(false, "Uncorrect input")
    end
end

function SetWeatherCommand()
    local weatherName = nil
    local weathers = { "Sunny", "Cloudy", "Smog", "Foggy", "Rain", "Thunder", "Snow", "Blizzard", "Halloween", "XMAS" }
    local weather = InputFromList("Enter what weather you want: ", weathers)

    if weather ~= -1 then
        if weather == 0 then
            weatherName = world_enum.WeatherType.ToString(world_enum.WeatherType.ExtraSunny)
        elseif weather == 1 then
            weatherName = world_enum.WeatherType.ToString(world_enum.WeatherType.Clouds)
        elseif weather == 2 then
            weatherName = world_enum.WeatherType.ToString(world_enum.WeatherType.Smog)
        elseif weather == 3 then
            weatherName = world_enum.WeatherType.ToString(world_enum.WeatherType.Foggy)
        elseif weather == 4 then
            weatherName = world_enum.WeatherType.ToString(world_enum.WeatherType.Rain)
        elseif weather == 5 then
            weatherName = world_enum.WeatherType.ToString(world_enum.WeatherType.Thunder)
        elseif weather == 6 then
            weatherName = world_enum.WeatherType.ToString(world_enum.WeatherType.Snow)
        elseif weather == 7 then
            weatherName = world_enum.WeatherType.ToString(world_enum.WeatherType.Blizzard)
        elseif weather == 8 then
            weatherName = world_enum.WeatherType.ToString(world_enum.WeatherType.SnowLight)
        elseif weather == 9 then
            weatherName = world_enum.WeatherType.ToString(world_enum.WeatherType.Halloween)
        end

        print(weatherName)
        
        MISC.CLEAR_OVERRIDE_WEATHER()
        MISC.SET_OVERRIDE_WEATHEREX(weatherName, true)

        --MISC.CLEAR_OVERRIDE_WEATHER() -- Works in story mod
        --MISC.SET_WEATHER_TYPE_NOW(weatherName) -- Works in story mod
    end
end

function SetWindSpeedCommand()
    print("The wind speed is now " .. MISC.GET_WIND_SPEED())
    io.write("Enter wind speed: ")
    local speed = tonumber(io.read())

    if speed then
        MISC.SET_WIND_SPEED(speed)
    else
        DisplayError(false, "Uncorrect input")
    end
end
function SetSnowCommand()
    io.write("You want to turn on the snow? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        GRAPHICS._FORCE_GROUND_SNOW_PASS(true)
        MISC.SET_SNOW(1.0)
    elseif input == "n" then
        GRAPHICS._FORCE_GROUND_SNOW_PASS(false)
        MISC.SET_SNOW(0.0)
    end  
end


function BombAreaCommand()
    local coords = nil

    local options = { "Waypoint", "Current Position", "Custom" }
    local option = InputFromList("Enter where you want to start the bombing: ", options)

    if option ~= -1 then
        if option == 0 then
            coords = mapUtils.GetWaypointCoords()
            if not coords then
                print("Please choose a waypoint first")
                return nil
            end

            local heights = { 100.0, 150.0, 50.0, 0.0, 200.0, 250.0, 300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0 }

            local coordZp = New(4)

            for i = 1, #heights, 1 do
                if MISC.GET_GROUND_Z_FOR_3D_COORD(coords.x, coords.y, heights[i], coordZp) then
                    if Game.ReadFloat(coordZp) ~= 0.0 then
                        coords.z = Game.ReadFloat(coordZp)
                        break
                    end
                end
            end

            if coords.z == 0.0 then
                coords.z = 200
            end

            Delete(coordZp)
        elseif option == 1 then
            coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        elseif option == 2 then
            io.write("Enter X coord: ")
            local CoordX = io.read()
            io.write("Enter Y coord: ")
            local CoordY = io.read()
            io.write("Enter Z coord: ")
            local CoordZ = io.read()

            coords = { x = CoordX, y = CoordY, z = CoordZ }
        end

        SetGlobalVariableValue("BombAreaCoordX", coords.x)
        SetGlobalVariableValue("BombAreaCoordY", coords.y)
        SetGlobalVariableValue("BombAreaCoordZ", coords.z)

        if not RunScript("C:\\Program Files\\GCTV\\Scripts\\features\\BombArea.lua") then
            DisplayError(true, "Failed to start bombing the area")
        end
    end
end

function AttackEntityCommand()
    local target = nil

    local options = { "Player", "Near ped", "Custom" }
    local option = InputFromList("Enter who you want the bandits to target: ", options)

    if option ~= -1 then
        if option == 0 then
            io.write("Enter player ID: ")
            local player = tonumber(io.read())

            if player then
                target = PLAYER.GET_PLAYER_PED(player)
                if target == 0.0 then
                    DisplayError(false, "Uncorrect input")
                    return nil
                end
            else
                DisplayError(false, "Uncorrect input")
                return nil
            end
        elseif option == 1 then
            target = worldUtils.GetNearestPedToEntity(PLAYER.PLAYER_PED_ID(), 30.0)

            if target == 0.0 then
                DisplayError(false, "Failed to find anyone nearby local player")
                return nil
            end
        elseif option == 2 then
            io.write("Enter ped handle: ")
            target = tonumber(io.read())
            if not ENTITY.IS_ENTITY_A_PED(target) then
                DisplayError(false, "Uncorrect input")
                return nil
            end
        end

        SetGlobalVariableValue("BanditsTarget", target)

        if not RunScript("C:\\Program Files\\GCTV\\Scripts\\features\\AttackEntity.lua") then
            DisplayError(true, "Failed to send the bandits after the entity")
        end
    end
end

-- Определим словарь с командами и их функциями
local Commands = {
    ["set time"] = SetTimeCommand,
    ["set weather"] = SetWeatherCommand,
    ["set wind speed"] = SetWindSpeedCommand,
    ["set snow"] = SetSnowCommand,
    ["bomb area"] = BombAreaCommand,
    ["attack entity"] = AttackEntityCommand,
}

math.randomseed(os.time())

-- Цикл для регистрации команд
for commandName, commandFunction in pairs(Commands) do
    if not BindCommand(commandName, commandFunction) then
        DisplayError(true, "Failed to register the command: " .. commandName)
    end
end

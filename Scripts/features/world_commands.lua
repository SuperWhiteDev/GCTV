-- These variables will be accessible to other scripts, allowing data transfer between them.
-- Registration of global variables used in 'bomb_area.lua' script.
RegisterGlobalVariable("BombAreaCoords", {0.0, 0.0, 0.0})

-- Registration of global variables used in 'attack_entity.lua' script.
RegisterGlobalVariable("EntityAttackTarget", 0.0)

-- Loading necessary modules (libraries) for working with the game world, map, network, and world utilities.
local world_enum = require("world_enums") -- Module for working with enumerations, e.g., weather types.
local map_utils = require("map_utils")     -- Module for map-related utilities (e.g., getting waypoint coordinates).
local network_utils = require("network_utils") -- Module for network utilities
local world_utils = require("world_utils") -- Module for general game world utilities (e.g., finding the nearest ped).

--- Sets the in-game time.
-- Prompts the user for hours, minutes, and seconds, then applies them to the game clock.
function set_time_command()
    -- Prints the current game time in H:M:S format.
    print("Current time is " .. math.floor(CLOCK.GET_CLOCK_HOURS()) .. ":" .. math.floor(CLOCK.GET_CLOCK_MINUTES()) .. ":" .. math.floor(CLOCK.GET_CLOCK_SECONDS()))
    
    -- Prompts for hours, minutes, and seconds input from the user. 'Input' is a custom function of your GCTV API.
    local hours = tonumber(Input("Enter hours: ", false))
    local minutes = tonumber(Input("Enter minutes: ", false))
    local seconds = tonumber(Input("Enter seconds: ", false))

    -- Checks that all entered values are valid numbers.
    if hours and minutes and seconds then
        -- Sets the game time using a GTAV native function.
        NETWORK.NETWORK_OVERRIDE_CLOCK_TIME(hours, minutes, seconds)
    else
        -- Displays an error message if the input is incorrect.
        DisplayError(false, "Uncorrect input")
    end
end

--- Sets the in-game weather.
-- Offers the user a list of predefined weather types and applies the selected one.
function set_weather_command()
    -- List of available weather types for user selection.
    local weathers = { "Sunny", "Cloudy", "Smog", "Foggy", "Rain", "Thunder", "Snow", "Blizzard", "Halloween", "XMAS" }
    -- Prompts for weather selection from the list. 'InputFromList' is a custom function of your GCTV API.
    local weather = InputFromList("Enter what weather you want: ", weathers)
    
    -- If the user made a selection (didn't cancel).
    if weather ~= -1 then
        -- Mapping the selected index from the list to the corresponding weather type from world_enum.WeatherType.
        -- There's a slight inaccuracy here: WeatherType.SnowLight is used for "Halloween", and "XMAS" has no direct
        -- correspondence, as XMAS is likely a separate weather state or uses an existing one.

        local weather_name = ""
        if weather == 0 then
            weather_name = world_enum.WeatherType.ToString(world_enum.WeatherType.EXTRASUNNY)
        elseif weather == 1 then
            weather_name = world_enum.WeatherType.ToString(world_enum.WeatherType.CLOUDS)
        elseif weather == 2 then
            weather_name = world_enum.WeatherType.ToString(world_enum.WeatherType.SMOG)
        elseif weather == 3 then
            weather_name = world_enum.WeatherType.ToString(world_enum.WeatherType.FOGGY)
        elseif weather == 4 then
            weather_name = world_enum.WeatherType.ToString(world_enum.WeatherType.RAIN)
        elseif weather == 5 then
            weather_name = world_enum.WeatherType.ToString(world_enum.WeatherType.THUNDER)
        elseif weather == 6 then
            weather_name = world_enum.WeatherType.ToString(world_enum.WeatherType.SNOW)
        elseif weather == 7 then
            weather_name = world_enum.WeatherType.ToString(world_enum.WeatherType.BLIZZARD)
        elseif weather == 8 then -- This should likely be XMAS, but SnowLight is used.
            weather_name = world_enum.WeatherType.ToString(world_enum.WeatherType.HALLOWEEN) -- Used for "Halloween"
        elseif weather == 9 then
            weather_name = world_enum.WeatherType.ToString(world_enum.WeatherType.SNOWLIGHT) -- Used for "XMAS"
        end
        -- Clears any previous weather overrides.
        MISC.CLEAR_OVERRIDE_WEATHER()
        -- Sets the new weather. 'SET_OVERRIDE_WEATHEREX' is a GTAV native function.
        MISC.SET_OVERRIDE_WEATHEREX(weather_name, true)
    end
end

--- Sets the wind speed in the game.
-- Prompts the user for a numerical value for wind speed.
function set_wind_speed_command()
    -- Prints the current wind speed.
    print("The wind speed is now " .. MISC.GET_WIND_SPEED())
    -- Prompts for wind speed input from the user.
    local speed = tonumber(Input("Enter wind speed: ", false))

    -- Checks that the entered value is a valid number.
    if speed then
        -- Sets the new wind speed. 'SET_WIND_SPEED' is a GTAV native function.
        MISC.SET_WIND_SPEED(speed)
    else
        -- Displays an error message if the input is incorrect.
        DisplayError(false, "Uncorrect input")
    end
end

--- Turns snow on or off on the ground.
-- Prompts the user for confirmation to enable/disable snow.
function set_snow_command()
    -- Prompts for "y" or "n" input and converts it to lowercase for easy comparison.
    local input = string.lower(Input("You want to turn on the snow? [Y/n]: ", false))

    -- Depending on the input, turns snow on or off.
    if input == "y" then
        -- 'GRAPHICS._FORCE_GROUND_SNOW_PASS' and 'MISC.SET_SNOW' are GTAV native functions for snow control.
        GRAPHICS._FORCE_GROUND_SNOW_PASS(true)
        MISC.SET_SNOW(1.0)
    elseif input == "n" then
        GRAPHICS._FORCE_GROUND_SNOW_PASS(false)
        MISC.SET_SNOW(0.0)
    end
end


--- Initiates bombing of a specified area.
-- The user can choose the bombing location: waypoint, current player position, or custom coordinates.
function bomb_area_command()
    local coords = nil

    -- Options for choosing the bombing location.
    local options = { "Waypoint", "Current Position", "Custom" }
    -- Prompts for option selection from the user.
    local option = InputFromList("Enter where you want to start the bombing: ", options)

    -- If the user made a selection.
    if option ~= -1 then
        if option == 0 then -- Waypoint bombing selected.
            -- Gets the waypoint coordinates. 'map_utils.get_waypoint_coords()' is a function from your module.
            coords = map_utils.get_waypoint_coords()
            if not coords then
                print("Please choose a waypoint first")
                return nil
            end

            -- List of heights to search for ground under the waypoint.
            local heights = { 100.0, 150.0, 50.0, 0.0, 200.0, 250.0, 300.0, 350.0, 400.0, 450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0 }

            -- 'New(4)' allocates 4 bytes of memory to store a float (Z-coordinate).
            local coord_z_p = New(4)

            -- Loop to find the ground Z-coordinate for the given X and Y.
            for i = 1, #heights, 1 do
                -- 'MISC.GET_GROUND_Z_FOR_3D_COORD' is a GTAV native function that tries to find the ground's Z-coordinate.
                if MISC.GET_GROUND_Z_FOR_3D_COORD(coords.x, coords.y, heights[i], coord_z_p, false, false) then
                    -- If a valid Z-coordinate (not 0.0) is found, set it and break the loop.
                    if Game.ReadFloat(coord_z_p) ~= 0.0 then
                        coords.z = Game.ReadFloat(coord_z_p)
                        break
                    end
                end
            end

            -- If the Z-coordinate was not found, default it to 200.
            if coords.z == 0.0 then
                coords.z = 200
            end

            -- Free the allocated memory.
            Delete(coord_z_p)
        elseif option == 1 then -- Current player position bombing selected.
            -- Gets the current coordinates of the player character. 'ENTITY.GET_ENTITY_COORDS' is a GTAV native function.
            coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        elseif option == 2 then -- Custom coordinates selected.
            -- Prompts for X, Y, Z coordinates from the user.
            local coord_x = tonumber(Input("Enter X coord: ", false))
            local coord_y = tonumber(Input("Enter Y coord: ", false))
            local coord_z = tonumber(Input("Enter Z coord: ", false))

            coords = { x = coord_x, y = coord_y, z = coord_z }
        end

        if coords ~= nil then
            -- Sets global variables to pass coordinates to the 'bomb_area.lua' script.
            SetGlobalVariableValue("BombAreaCoords", { coords.x, coords.y, coords.z } )
            
            -- Runs the 'bomb_area.lua' script. 'RunScript' is a custom function of your GCTV API.
            if RunScript("features\\bomb_area.lua") then
                return
            end
        end
        
        DisplayError(true, "Failed to start bombing the area")
    end
end

--- Initiates a bandit attack on a selected entity.
-- The user can choose the target: another player, a nearby ped, or an entity by handle.
function attack_entity_command()
    local target = nil

    -- Options for choosing the target.
    local options = { "Player", "Near ped", "Custom" }
    -- Prompts for target selection from the user.
    local option = InputFromList("Enter who you want the bandits to target: ", options)

    -- If the user made a selection.
    if option ~= -1 then
        if option == 0 then -- Target is another player.
            -- Prompts for player ID.
            local player = tonumber(Input("Enter player ID: ", false))

            if player then
                -- Gets the player ped handle by ID. 'PLAYER.GET_PLAYER_PED' is a GTAV native function.
                target = PLAYER.GET_PLAYER_PED(player)
                -- If the handle is 0.0, the player was not found or input is incorrect.
                if target == 0.0 then
                    DisplayError(false, "Uncorrect input")
                    return nil
                end
            else
                DisplayError(false, "Uncorrect input")
                return nil
            end
        elseif option == 1 then -- Target is the nearest ped.
            -- Finds the nearest ped to the current player within a 30.0 radius.
            -- 'world_utils.get_nearest_ped_to_entity' is a function from your module.
            target = world_utils.get_nearest_ped_to_entity(PLAYER.PLAYER_PED_ID(), 30.0)

            -- If no ped is found.
            if target == 0.0 then
                DisplayError(false, "Failed to find anyone nearby local player")
                return nil
            end
        elseif option == 2 then -- Target is an entity by handle.
            -- Prompts for the ped handle.
            target = tonumber(Input("Enter ped handle: ", false))
            -- Checks if the entered handle is a valid ped.
            if not ENTITY.IS_ENTITY_A_PED(target) then
                DisplayError(false, "Uncorrect input")
                return nil
            end
        end

        -- Sets a global variable to pass the target to the 'attack_entity.lua' script.
        SetGlobalVariableValue("EntityAttackTarget", target)

        -- Runs the 'attack_entity.lua' script.
        if not RunScript("features\\attack_entity.lua") then
            -- Displays an error message if the script failed to start.
            DisplayError(true, "Failed to send the bandits after the entity")
        end
    end
end

---
-- Define a dictionary with commands and their functions
-- A dictionary mapping command names to their functions.
local commands = {
    ["set time"] = set_time_command,
    ["set weather"] = set_weather_command,
    ["set wind speed"] = set_wind_speed_command,
    ["set snow"] = set_snow_command,
    ["bomb area"] = bomb_area_command,
    ["attack entity"] = attack_entity_command,
}

-- Initializes the pseudo-random number generator based on the current time.
-- This ensures different results for math.random each time the script runs.
math.randomseed(os.time())

-- Loop for registering commands.
-- Iterates through all "command name" - "function" pairs in the Commands dictionary.
for command_name, command_function in pairs(commands) do
    -- Registers the command. 'BindCommand' is a custom function of your GCTV API.
    if not BindCommand(command_name, command_function) then
        -- Displays an error message if command registration failed.
        DisplayError(true, "Failed to register the command: " .. command_function)
    end
end
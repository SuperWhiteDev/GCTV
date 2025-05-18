RegisterGlobalVariable("AutoFixCurrentVehicleState", 0.0)
RegisterGlobalVariable("DisableLockOnCurrentVehicleState", 0.0)
RegisterGlobalVariable("DynamicNeonVehicle", 0.0)
RegisterGlobalVariable("DynamicColorVehicle", 0.0)
RegisterGlobalVariable("RemoteControlVehicle", 0.0)

local vehicle_enum = require("vehicle_enums")
local blip_enums = require("blip_enums")
local radio_stations = require("radio_stations")

local inputUtils = require("input_utils")
local networkUtils = require("network_utils")
local mapUtils = require("map_utils")
local mathUtils = require("math_utils")
local vehicleUtils = require("vehicle_utils")
local missionUtils = require("mission_utils")
local configUtils = require("config_utils")

local ViewAllVehiclesNextKey = nil
local ViewAllVehiclesBackKey = nil
local ViewAllVehiclesSelectKey = nil


local createdvehiclesmodels = { }
local createdvehiclesID = { }
local modifyedvehiclesmodels = { }
local modifyedvehiclesData = { }
local modifyedvehiclesID = { }

--View all vehicles command variables
local viewAllVehiclesList = JsonReadList("vehicles.json")  -- Список доступных автомобилей
local viewAllVehiclesListVehicleIndex = 1
local viewAllVehiclesCurrentVehicle = nil
local StillViewingAllVehicles = false
local viewAllVehiclescamera = nil

--CreateTuningFX variables
local ptfx = 0.0

function CreateTuningFX(veh, scale)		
    STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2")

    if GRAPHICS.DOES_PARTICLE_FX_LOOPED_EXIST(ptfx) then
        GRAPHICS.REMOVE_PARTICLE_FX(ptfx, false)
    end

    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry2")
    ptfx = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY("scr_clown_appears", veh, 0.0, 0.0, -0.5, 0.0, 0.0, 0.0, scale, false, false, false, 1.0, 0.0, 0.0, 1.0)

    if ptfx == 0.0 then
        STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2")
        GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry2")
        ptfx = GRAPHICS.START_PARTICLE_FX_LOOPED_ON_ENTITY("scr_clown_appears", veh, 0.0, 0.0, -0.5, 0.0, 0.0, 0.0, scale, false, false, false)
    end

    --GRAPHICS.SET_PARTICLE_FX_LOOPED_EVOLUTION(ptfx, "flow", 1.0, false)
    --GRAPHICS.SET_PARTICLE_FX_LOOPED_EVOLUTION(ptfx, "damage", 1.0, false)
end

function MarkVehicleAsModed(vehicle)
    local founded = false

    for i = 1, #modifyedvehiclesID, 1 do
        if modifyedvehiclesID[i] == vehicle then
            founded = true
            break
        end
    end

    if not founded then
        table.insert(modifyedvehiclesmodels, vehicleUtils.GetVehicleModelName(ENTITY.GET_ENTITY_MODEL(vehicle)))
        modifyedvehiclesData[vehicle] = { }
        table.insert(modifyedvehiclesID, vehicle)
    end
end
function IsVehicleMarkedAsModed(vehicle)
    for i = 1, #modifyedvehiclesID, 1 do
        if modifyedvehiclesID[i] == vehicle then
            return true
        end
    end

    return false
end

function MakeVehicleMaxTuning(veh)
    CreateTuningFX(veh, 2.0)

    VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, math.random(0, 6))
    VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)

    for i = 0, 30, 1 do
        if i >= 17 and i <= 24 then

        else
            local modscount = VEHICLE.GET_NUM_VEHICLE_MODS(veh, i) - 1
            if modscount < 1 then
            
            else
            VEHICLE.SET_VEHICLE_MOD(veh, i, math.random(0, modscount), 0)
            end
        end
    end

    local vehmodscount = VEHICLE.GET_NUM_VEHICLE_MODS(veh, 48) - 1
    if vehmodscount > 1 then
        VEHICLE.SET_VEHICLE_MOD(veh, 48, math.random(0, vehmodscount), 0)
    end

    VEHICLE.TOGGLE_VEHICLE_MOD(veh, 20, true)
    VEHICLE.TOGGLE_VEHICLE_MOD(veh, 22, true)
    VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, false)
    VEHICLE.SET_VEHICLE_WHEELS_CAN_BREAK(veh, false)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(veh, "PRIVATE")
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, math.random(0, 5))
    
    VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 0, true)
    VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 1, true)
    VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 2, true)
    VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 3, true)
    VEHICLE.SET_VEHICLE_NEON_COLOUR(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
    VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
    VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(veh, math.random(0, 13))
end

function SaveVehicle(vehicle)
    io.write("Enter the name of the vehicle you want to save: ")
    local vehicleName = io.read()

    -- Получение данных о транспортном средстве
    local vehicleData = {}

    vehicleData["name"] = vehicleName
    vehicleData["model"] = tonumber32(ENTITY.GET_ENTITY_MODEL(vehicle))
    vehicleData["modelName"] = vehicleUtils.GetVehicleModelName(vehicleData["model"])

    networkUtils.RequestControlOf(vehicle)

    -- Получение модификаций
    for i = 0, 24 do
        local isToggleable = (i >= 17 and i <= 22)
        if isToggleable then
            vehicleData["mod" .. i] = VEHICLE.IS_TOGGLE_MOD_ON(vehicle, i) and 1 or 0
        else
            vehicleData["mod" .. i] = VEHICLE.GET_VEHICLE_MOD(vehicle, i)
        end
    end

    -- Корректная обработка цветов транспорта
    local primaryCol = New(4)
    local secondaryCol = New(4)
    VEHICLE.GET_VEHICLE_COLOURS(vehicle, primaryCol, secondaryCol)
    vehicleData["primaryColor"] = Game.ReadInt(primaryCol)
    vehicleData["secondaryColor"] = Game.ReadInt(secondaryCol)
    Delete(primaryCol)
    Delete(secondaryCol)

    local pearlCol = New(4)
    local wheelCol = New(4)
    VEHICLE.GET_VEHICLE_EXTRA_COLOURS(vehicle, pearlCol, wheelCol)
    vehicleData["pearlColor"] = Game.ReadInt(pearlCol)
    vehicleData["wheelColor"] = Game.ReadInt(wheelCol)
    Delete(pearlCol)
    Delete(wheelCol)

    -- Запись цветов модификаций как простые значения
    local modColor1A = New(4)
    local modColor1B = New(4)
    local modColor1C = New(4)
    VEHICLE.GET_VEHICLE_MOD_COLOR_1(vehicle, modColor1A, modColor1B, modColor1C)
    vehicleData["modColor1A"] = Game.ReadInt(modColor1A)
    vehicleData["modColor1B"] = Game.ReadInt(modColor1B)
    vehicleData["modColor1C"] = Game.ReadInt(modColor1C)
    Delete(modColor1A)
    Delete(modColor1B)
    Delete(modColor1C)

    local modColor2A = New(4)
    local modColor2B = New(4)
    VEHICLE.GET_VEHICLE_MOD_COLOR_2(vehicle, modColor2A, modColor2B)
    vehicleData["modColor2A"] = Game.ReadInt(modColor2A)
    vehicleData["modColor2B"] = Game.ReadInt(modColor2B)
    Delete(modColor2A)
    Delete(modColor2B)

    -- Цвета пользовательских цветов
    if VEHICLE.GET_IS_VEHICLE_PRIMARY_COLOUR_CUSTOM(vehicle) then
        local custR1 = New(4)
        local custG1 = New(4)
        local custB1 = New(4)
        VEHICLE.GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, custR1, custG1, custB1)
        vehicleData["customPrimaryR"] = Game.ReadInt(custR1)
        vehicleData["customPrimaryG"] = Game.ReadInt(custG1)
        vehicleData["customPrimaryB"] = Game.ReadInt(custB1)
        Delete(custR1)
        Delete(custG1)
        Delete(custB1)
    end

    if VEHICLE.GET_IS_VEHICLE_SECONDARY_COLOUR_CUSTOM(vehicle) then
        local custR2 = New(4)
        local custG2 = New(4)
        local custB2 = New(4)
        VEHICLE.GET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, custR2, custG2, custB2)
        vehicleData["customSecondaryR"] = Game.ReadInt(custR2)
        vehicleData["customSecondaryG"] = Game.ReadInt(custG2)
        vehicleData["customSecondaryB"] = Game.ReadInt(custB2)
        Delete(custR2)
        Delete(custG2)
        Delete(custB2)
    end

    vehicleData["livery"] = VEHICLE.GET_VEHICLE_MOD(vehicle, 48)
    vehicleData["livery2"] = VEHICLE.GET_VEHICLE_LIVERY2(vehicle)
    vehicleData["windowsTint"] = VEHICLE.GET_VEHICLE_WINDOW_TINT(vehicle)
    vehicleData["plateText"] = VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT(vehicle)
    vehicleData["plateTextIndex"] = VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle)
    vehicleData["dirtLevel"] = VEHICLE.GET_VEHICLE_DIRT_LEVEL(vehicle)
    vehicleData["paintFade"] = VEHICLE.GET_VEHICLE_ENVEFF_SCALE(vehicle)
    vehicleData["xenonColorIndex"] = VEHICLE.GET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle)
    vehicleData["bulletproofTyres"] = VEHICLE.GET_VEHICLE_TYRES_CAN_BURST(vehicle)

    -- Проверка включения неоновых светов
    vehicleData["neonEnabledLeft"] = VEHICLE.GET_VEHICLE_NEON_ENABLED(vehicle, 0)
    vehicleData["neonEnabledRight"] = VEHICLE.GET_VEHICLE_NEON_ENABLED(vehicle, 1)
    vehicleData["neonEnabledFront"] = VEHICLE.GET_VEHICLE_NEON_ENABLED(vehicle, 2)
    vehicleData["neonEnabledBack"] = VEHICLE.GET_VEHICLE_NEON_ENABLED(vehicle, 3)

    local neonRp = New(4)
    local neonGp = New(4)
    local neonBp = New(4)
    VEHICLE.GET_VEHICLE_NEON_COLOUR(vehicle, neonRp, neonGp, neonBp)
    vehicleData["neonR"] = Game.ReadInt(neonRp)
    vehicleData["neonG"] = Game.ReadInt(neonGp)
    vehicleData["neonB"] = Game.ReadInt(neonBp)
    Delete(neonRp)
    Delete(neonGp)
    Delete(neonBp)

    -- Получение цвета дымового шина
    local tyreSmokeR = New(4)
    local tyreSmokeG = New(4)
    local tyreSmokeB = New(4)
    VEHICLE.GET_VEHICLE_TYRE_SMOKE_COLOR(vehicle, tyreSmokeR, tyreSmokeG, tyreSmokeB)
    vehicleData["tyreSmokeR"] = Game.ReadInt(tyreSmokeR)
    vehicleData["tyreSmokeG"] = Game.ReadInt(tyreSmokeG)
    vehicleData["tyreSmokeB"] = Game.ReadInt(tyreSmokeB)
    Delete(tyreSmokeR)
    Delete(tyreSmokeG)
    Delete(tyreSmokeB)

    -- Состояние крыши для кабриолетов
    if VEHICLE.IS_VEHICLE_A_CONVERTIBLE(vehicle, false) then
        vehicleData["roofState"] = VEHICLE.GET_CONVERTIBLE_ROOF_STATE(vehicle)
    end

    -- Получение экстра и их состояния
    for i = 1, 10 do
        if VEHICLE.DOES_EXTRA_EXIST(vehicle, i) then
            vehicleData["extra" .. i] = VEHICLE.IS_VEHICLE_EXTRA_TURNED_ON(vehicle, i)
        end
    end

    if IsVehicleMarkedAsModed(vehicle) then
        vehicleData["isModed"] = true
        if modifyedvehiclesData[vehicle].EngineSound ~= nil then
            vehicleData["engineSound"] = modifyedvehiclesData[vehicle].EngineSound
        end
    else
        vehicleData["isModed"] = false
    end

    -- Сохранение данных в файл
    local vehiclesList = JsonReadList("saved_vehicles.json") or {}
    table.insert(vehiclesList, vehicleData)

    JsonSaveList("saved_vehicles.json", vehiclesList)

    printColoured("green", "The vehicle has been successfully saved.")
end

function SetVehicleEngineSound(vehicle, modelName)
    AUDIO.FORCE_USE_AUDIO_GAME_OBJECT(vehicle, modelName)

    MarkVehicleAsModed(vehicle)
    modifyedvehiclesData[vehicle]["EngineSound"] = modelName
end

function RemoteControlVehicle(vehicle)
    
    if ENTITY.DOES_ENTITY_EXIST(vehicle) and ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        io.write("Connecting to vehicle")

        for i = 1, 3, 1 do
            io.write_anonym(".")
            Wait(100)
        end
        io.write_anonym("\n")

        io.write("Establishing SSH tunnel")
        for i = 1, 3, 1 do
            io.write_anonym(".")
            Wait(50)
        end
        io.write_anonym("\n")

        io.write("Bypassing security protocols")
        for i = 1, 3, 1 do
            io.write_anonym(".")
            Wait(200)
        end
        io.write_anonym("\n")
        
        io.write("Identifying vulnerabilities")
        for i = 1, 3, 1 do
            io.write_anonym(".")
            Wait(50)
        end
        io.write_anonym("\n")
        if GetGlobalVariable("RemoteControlVehicle") == 0.0 then
            SetGlobalVariableValue("RemoteControlVehicle", vehicle)    
            if not RunScript("C:\\Program Files\\GCTV\\Scripts\\features\\RemoteControlVehicle.lua") then
                DisplayError(true, "Failed to initialise the remote control")
            end
        else
            SetGlobalVariableValue("RemoteControlVehicle", vehicle)
        end
    else
        DisplayError(false, "Invalid vehicle ID")
    end
end

function ControlVehicle(vehicle)
    local options = { "Engine", "Doors", "Roof", "Windows", "Lights", "Alarm", "Radio", "Remote control" }
    local option = InputFromList("Choose what you want to: ", options)
    
    if option == 0 then
        local engineState = VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(vehicle)
        if engineState then
            engineState = "running"
        else
            engineState = "not running"
        end
        
        print("Engine is " .. engineState)
    
        io.write("Do you want to start the engine? [Y/n]: ")
        input = string.lower(io.read())
    
        if input == "y" then
            networkUtils.RequestControlOf(vehicle)
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
        else 
            networkUtils.RequestControlOf(vehicle)
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, false, false, false)
        end
    elseif option == 1 then
        local options = { "Open", "Close", "Open all", "Close all" }
        local option = InputFromList("Choose what you want to: ", options)
    
        if option == 0 then
            io.write("Enter the door sequence number: ")
            local door = tonumber(io.read())

            networkUtils.RequestControlOf(vehicle)
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, door-1, false, false)
        elseif option == 1 then
            io.write("Enter the door sequence number: ")
            local door = tonumber(io.read())

            networkUtils.RequestControlOf(vehicle)
            VEHICLE.SET_VEHICLE_DOOR_SHUT(vehicle, door-1, false)
        elseif option == 2 then
            networkUtils.RequestControlOf(vehicle)
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 0, false, false)
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 1, false, false)
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 2, false, false)
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 3, false, false)
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 4, false, false)
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle, 5, false, false)
        elseif option == 3 then
            networkUtils.RequestControlOf(vehicle)
            VEHICLE.SET_VEHICLE_DOORS_SHUT(vehicle, false)
        end
    elseif option == 2 then
        if VEHICLE.IS_VEHICLE_A_CONVERTIBLE(vehicle, false) then
            local options = { "Open", "Close" }
            local option = InputFromList("Choose what you want to: ", options)
    
            if option == 0 then
                networkUtils.RequestControlOf(vehicle)
                VEHICLE.LOWER_CONVERTIBLE_ROOF(vehicle, false)
            elseif option == 1 then
                networkUtils.RequestControlOf(vehicle)
                VEHICLE.RAISE_CONVERTIBLE_ROOF(vehicle, false)
            end
        else
            DisplayError(false, "The chosen vehicle is not a convertible.")
        end
    elseif option == 3 then
        local options = { "Roll down", "Roll up", "Roll down all", "Roll up all" }
        local option = InputFromList("Choose what you want to: ", options)
    
        if option == 0 then
            io.write("Enter the window sequence number: ")
            local window = tonumber(io.read())

            networkUtils.RequestControlOf(vehicle)
            VEHICLE.ROLL_DOWN_WINDOW(vehicle, window-1)
        elseif option == 1 then
            io.write("Enter the window sequence number: ")
            local window = tonumber(io.read())

            networkUtils.RequestControlOf(vehicle)
            VEHICLE.ROLL_UP_WINDOW(vehicle, window-1)
        elseif option == 2 then
            networkUtils.RequestControlOf(vehicle)
            VEHICLE.ROLL_DOWN_WINDOWS(vehicle)
        elseif option == 3 then
            networkUtils.RequestControlOf(vehicle)
            for i = 0, 8, 1 do
                VEHICLE.ROLL_UP_WINDOW(vehicle, i)
            end
        end
    elseif option == 4 then  
        local lightstypes = { "Headlights", "Interior lights", "Indicator lights" }
        local lightstypes = InputFromList("Choose the lights type: ", lightstypes)

        if lightstypes == 0 then
            io.write("You want to switch on the car's headlights? [Y/n]: ")
            local input = string.lower(io.read())
        
            if input == "y" then
                VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 2)
                --VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(vehicle, 1.0)
            elseif input == "n" then
                VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 1)
                --VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(vehicle, 0.0)
            end
        elseif lightstypes == 1 then
            io.write("You want to switch on the interior lights? [Y/n]: ")
            local input = string.lower(io.read())
        
            if input == "y" then
                VEHICLE.SET_VEHICLE_INTERIORLIGHT(vehicle, true)
            elseif input == "n" then
                VEHICLE.SET_VEHICLE_INTERIORLIGHT(vehicle, false)
            end
        elseif lightstypes == 2 then
            local options = { "Toggle all", "Swith left", "Switch right" }
            local option = InputFromList("Choose the lights type: ", options)

            if option == 0 then
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 0, true)
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 1, true)
            elseif option == 1 then
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 0, false)
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 1, true)
            elseif option == 2 then
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 0, true)
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 1, false)
            end
        end
    elseif option == 5 then
        io.write("You want to activate the alarm system on the vehicle? [Y/n]: ")
        local input = string.lower(io.read())
        
        if input == "y" then
            VEHICLE.SET_VEHICLE_ALARM(vehicle, true)
            VEHICLE.START_VEHICLE_ALARM(vehicle)
        elseif input == "n" then
            VEHICLE.SET_VEHICLE_ALARM(vehicle, false)
        end     
    elseif option == 6 then
        local radiosStations = {  }
        local radiosStationNames = {  }

        for k, v in pairs(radio_stations.RadioStations) do
            radiosStations[#radiosStations + 1] = string.gsub(k, "_", " ")
            radiosStationNames[#radiosStationNames + 1] = v
        end
        
        local stationID = InputFromList("Choose a radio station from the list: ", radiosStations)

        if stationID ~= -1 then
            networkUtils.RequestControlOf(vehicle)
            AUDIO.SET_VEH_HAS_NORMAL_RADIO(vehicle)
            AUDIO.SET_VEHICLE_RADIO_ENABLED(vehicle, true)
            AUDIO.SET_VEH_RADIO_STATION(vehicle, radiosStationNames[stationID+1])
        end
    elseif option == 7 then
        RemoteControlVehicle(vehicle)
    end
end

function TuningVehicle(vehicle)
    local tunings = { "Livery", "Primary color", "Secondary color", "Neon lights", "Xenon color", "Tire smoke color", "Number plate", "Number plate type", "Windows tint",
                      "Spoiler", "Bumper", "Exhaust", "Frame", "Radiator grille", "Hood", "Roof", "Fender", "SideSkirt", "Horn", "Technical specifications", "Wheels", "Interior",
                      "Make max tuning", "Make stock"
    }
    local tuning = InputFromList("Choose what you want to tuning: ", tunings)

    if tuning == 0 then
        networkUtils.RequestControlOf(vehicle)
        local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, vehicle_enum.VehicleMod.Livery)
        if counts > 0.0 then
            io.write("Enter the livery identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
            local livery = tonumber(io.read())

            CreateTuningFX(vehicle, 2.0)
            VEHICLE.SET_VEHICLE_MOD(vehicle, vehicle_enum.VehicleMod.Livery, livery - 1, 0)
        else 
            print("The vehicle doesn't have any livery")
        end
    elseif tuning == 1 then
        local r, g, b = InputRGB()

        networkUtils.RequestControlOf(vehicle)
        CreateTuningFX(vehicle, 3.0)
        VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle, r, g, b)
    elseif tuning == 2 then
        local r, g, b = InputRGB()
    
        networkUtils.RequestControlOf(vehicle)
        CreateTuningFX(vehicle, 3.0)
        VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle, r, g, b)
    elseif tuning == 3 then
        local r, g, b = InputRGB()
    
        networkUtils.RequestControlOf(vehicle)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 0, 0)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 1, 0)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 2, 0)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 3, 0)
        Wait(10)
        VEHICLE.SET_VEHICLE_NEON_COLOUR(vehicle, r, g, b)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 0, 1)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 1, 1)
        Wait(500)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 2, 1)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 3, 1)
    elseif tuning == 4 then
        local colours = { "Xenon headlights", "White headlights", "Blue headlights", "Electric blue", "Mint green", "Lime", "Yellow headlights", "Golden rain", "Orange headlights", "Red headlights",
                              "Pink pony", "Bright pink headlights", "Purple headlights", "Black light"
                            }
        local colour = InputFromList("Enter the colour: ", colours)

        if colour ~= -1 then
            networkUtils.RequestControlOf(vehicle)
            VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle, colour-1)
        else
            DisplayError(false, "Uncorrect input")
        end
    elseif tuning == 5 then
        local r, g, b = InputRGB()

        networkUtils.RequestControlOf(vehicle)
        VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(vehicle, r, g, b)
    elseif tuning == 6 then
        io.write("Enter the text for the number plate(max. 8 characters): ")
        local text = io.read()

        networkUtils.RequestControlOf(vehicle)
        CreateTuningFX(vehicle, 2.0)
        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, text)
    elseif tuning == 7 then
        local plates = { "Blue/White", "Yellow/black", "Yellow/Blue", "Blue/White2", "Blue/White3", "Yankton", "eCola", "Sea", "Liberty city", "OCT",
                              "Panic", "Pounderd", "Sprunk"
                            }
        local plate = InputFromList("Enter the number plate type: ", plates)

        if plate ~= -1 then
            networkUtils.RequestControlOf(vehicle)
            CreateTuningFX(vehicle, 2.0)
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle, plate)

            io.write("Do you want to change the number plate holder? [Y/n]: ")
            local input = string.lower(io.read())
        
            if input == "y" then
                local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, vehicle_enum.VehicleMod.Plateholder)
                if counts > 0.0 then
                    local placeholders = { "Front and rear placeholder", "Front placeholder", "Rear placeholder", "None" }
                    local placeholder = InputFromList("Enter the windows tint: ", placeholders)

                    if placeholder ~= -1 then
                        CreateTuningFX(vehicle, 2.0)
                        VEHICLE.SET_VEHICLE_MOD(vehicle, vehicle_enum.VehicleMod.Plateholder, placeholder, 0)
                    else
                        DisplayError(false, "Uncorrect input")
                    end
                else 
                    print("The vehicle doesn't have any placeholder")
                end
            end
        else
            DisplayError(false, "Uncorrect input")
        end
    elseif tuning == 8 then
        local tints = { "No", "Light tinting", "Medium tinting", "Dark tint", "Limo tint", "Green tint" }
        local tint = InputFromList("Enter the windows tint: ", tints)

        if tint ~= -1 then

            if tint == 0 then
                tint = vehicle_enum.WindowTint.None
            elseif tint == 1 then
                tint = vehicle_enum.WindowTint.Light
            elseif tint == 2 then
                tint = vehicle_enum.WindowTint.Medium
            elseif tint == 3 then
                tint = vehicle_enum.WindowTint.Dark
            elseif tint == 4 then
                tint = vehicle_enum.WindowTint.Limo
            elseif tint == 5 then
                tint = vehicle_enum.WindowTint.Green
            end

            networkUtils.RequestControlOf(vehicle)
            CreateTuningFX(vehicle, 2.0)
            VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle, tint)
        else
            DisplayError(false, "Uncorrect input")
        end
    elseif tuning == 9 then
        networkUtils.RequestControlOf(vehicle)
        local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, vehicle_enum.VehicleMod.Spoiler)
        if counts > 0.0 then
            io.write("Enter the spoiler identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
            local spoiler = tonumber(io.read())

            CreateTuningFX(vehicle, 2.0)
            VEHICLE.SET_VEHICLE_MOD(vehicle, vehicle_enum.VehicleMod.Spoiler, spoiler, 0)
        else 
            print("The vehicle doesn't have any spoiler")
        end
    elseif tuning == 10 then
        local bumpers = { "Front", "Rear" }
        local bumper = InputFromList("Enter the type of bumper: ", bumpers)

        if bumper ~= -1 then
            local bumperMod = nil
            if bumper == 0 then
                bumperMod = vehicle_enum.VehicleMod.FrontBumper
            elseif bumper == 1 then
                bumperMod = vehicle_enum.VehicleMod.RearBumper
            end

            networkUtils.RequestControlOf(vehicle)
            local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, bumperMod)
            if counts > 0.0 then
                io.write("Enter the bumper identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
                local bumper = tonumber(io.read())

                CreateTuningFX(vehicle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle, bumperMod, bumper, 0)
            else 
                print("The vehicle does not have a bumper of this type")
            end
        else
            DisplayError(false, "Uncorrect input")
        end
    elseif tuning == 11 then
        networkUtils.RequestControlOf(vehicle)
        local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, vehicle_enum.VehicleMod.Exhaust)
        if counts > 0.0 then
            io.write("Enter the exhaust identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
            local exhaust = tonumber(io.read())

            CreateTuningFX(vehicle, 2.0)
            VEHICLE.SET_VEHICLE_MOD(vehicle, vehicle_enum.VehicleMod.Exhaust, exhaust, 0)
        else 
            print("The vehicle doesn't have any exhaust")
        end
    elseif tuning == 12 then
        networkUtils.RequestControlOf(vehicle)
        local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, vehicle_enum.VehicleMod.Frame)
        if counts > 0.0 then
            io.write("Enter the frame identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
            local frame = tonumber(io.read())

            CreateTuningFX(vehicle, 2.0)
            VEHICLE.SET_VEHICLE_MOD(vehicle, vehicle_enum.VehicleMod.Frame, frame, 0)
        else 
            print("The vehicle doesn't have any frame")
        end
    elseif tuning == 13 then
        networkUtils.RequestControlOf(vehicle)
        local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, vehicle_enum.VehicleMod.Grille)
        if counts > 0.0 then
            io.write("Enter the radiator grille identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
            local grille = tonumber(io.read())

            CreateTuningFX(vehicle, 2.0)
            VEHICLE.SET_VEHICLE_MOD(vehicle, vehicle_enum.VehicleMod.Grille, grille, 0)
        else 
            print("The vehicle doesn't have any radiator grille")
        end
    elseif tuning == 14 then
        networkUtils.RequestControlOf(vehicle)
        local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, vehicle_enum.VehicleMod.Hood)
        if counts > 0.0 then
            io.write("Enter the hood identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
            local hood = tonumber(io.read())

            CreateTuningFX(vehicle, 2.0)
            VEHICLE.SET_VEHICLE_MOD(vehicle, vehicle_enum.VehicleMod.Hood, hood, 0)
        else 
            print("The vehicle doesn't have any hood")
        end
    elseif tuning == 15 then
        networkUtils.RequestControlOf(vehicle)
        local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, vehicle_enum.VehicleMod.Roof)
        if counts > 0.0 then
            io.write("Enter the roof identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
            local roof = tonumber(io.read())

            CreateTuningFX(vehicle, 2.0)
            VEHICLE.SET_VEHICLE_MOD(vehicle, vehicle_enum.VehicleMod.Roof, roof, 0)
        else 
            print("The vehicle doesn't have any roof")
        end
    elseif tuning == 16 then
        local fenders = { "Left fender", "Right fender" }
        local fenderType = InputFromList("Enter the type of fender: ", fenders)

        if fenderType ~= -1 then
            local fenderMod = nil
            if fenderType == 0 then
                fenderMod = vehicle_enum.VehicleMod.Fender
            elseif fenderType == 1 then
                fenderMod = vehicle_enum.VehicleMod.RightFender
            end

            networkUtils.RequestControlOf(vehicle)
            local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, fenderMod)
            if counts > 0.0 then
                io.write("Enter the fender identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
                local fender = tonumber(io.read())

                CreateTuningFX(vehicle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle, fenderMod, fender, 0)
            else 
                print("The vehicle does not have a fender of this type")
            end
        else
            DisplayError(false, "Uncorrect input")
        end
    elseif tuning == 17 then
        networkUtils.RequestControlOf(vehicle)
        local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, vehicle_enum.VehicleMod.SideSkirt)
        if counts > 0.0 then
            io.write("Enter the side skirt identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
            local sideSkirt = tonumber(io.read())

            CreateTuningFX(vehicle, 2.0)
            VEHICLE.SET_VEHICLE_MOD(vehicle, vehicle_enum.VehicleMod.SideSkirt, sideSkirt, 0)
        else 
            print("The vehicle doesn't have any side skirt")
        end
    elseif tuning == 18 then
        networkUtils.RequestControlOf(vehicle)
        local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, vehicle_enum.VehicleMod.Horns)
        if counts > 0.0 then
            io.write("Enter the horn identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
            local horn = tonumber(io.read())

            CreateTuningFX(vehicle, 2.0)
            VEHICLE.SET_VEHICLE_MOD(vehicle, vehicle_enum.VehicleMod.Horns, horn, 0)
        else 
            print("The vehicle doesn't have any horn")
        end
    elseif tuning == 19 then
        local options = { "Engine", "Brakes", "Transmission", "Suspension", "Armor", "Turbo", "Hydraulics" }
        local option = InputFromList("Choose what you want to tuning: ", options)

        if option ~= -1 then
            local mod = nil

            if options == 0 then
                mod = vehicle_enum.VehicleMod.Engine
            elseif options == 1 then
                mod = vehicle_enum.VehicleMod.Brakes
            elseif options == 2 then
                mod = vehicle_enum.VehicleMod.Transmission
            elseif options == 3 then
                mod = vehicle_enum.VehicleMod.Suspension
            elseif options == 4 then
                mod = vehicle_enum.VehicleMod.Armor
            elseif options == 5 then
                mod = vehicle_enum.VehicleMod.Turbo
            elseif options == 6 then
                mod = vehicle_enum.VehicleMod.Hydraulics
            end

            networkUtils.RequestControlOf(vehicle)
            local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, mod)
            if counts > 0.0 then
                io.write("Enter the modification identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
                local modID = tonumber(io.read())

                CreateTuningFX(vehicle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle, mod, modID, 0)
            else 
                print("The vehicle doesn't have variations of this modification")
            end
        else
            DisplayError(false, "Uncorrect input")
        end
    elseif tuning == 20 then
        if VEHICLE.IS_THIS_MODEL_A_BIKE(ENTITY.GET_ENTITY_MODEL(vehicle)) then
            local options = { "Front wheel", "Back wheel" }
            local option = InputFromList("Choose which wheels you want to tune: ", options)

            local wheelsMod = nil

            if option == 0 then
                wheelsMod = vehicle_enum.VehicleMod.FrontWheels
            elseif option == 1 then
                wheelsMod = vehicle_enum.VehicleMod.BackWheels
            end

            networkUtils.RequestControlOf(vehicle)
            local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, wheelsMod)
            if counts > 0.0 then
                io.write("Enter the wheel identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
                local wheel = tonumber(io.read())

                CreateTuningFX(vehicle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle, wheelsMod, wheel, 0)
            else 
                print("The vehicle does not have a wheel of this type")
            end
        else
            networkUtils.RequestControlOf(vehicle)
            local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, vehicle_enum.VehicleMod.FrontWheels)
            if counts > 0.0 then
                io.write("Enter the wheel identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
                local wheel = tonumber(io.read())

                CreateTuningFX(vehicle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle, vehicle_enum.VehicleMod.FrontWheels, wheel, 0)
            else 
                print("The vehicle doesn't have any wheel")
            end
        end
    elseif tuning == 21 then
        local options = { "Dash", "Ornament", "Dial design", "Trim design", "Speakers door", "Leather seats", "Steering wheel", "Column shifter lever", "Plaque", "Speakers" }
        local option = InputFromList("Choose what you want to tuning: ", options)

        if option ~= -1 then
            local mod = nil

            if options == 0 then
                mod = vehicle_enum.VehicleMod.Dash
            elseif options == 1 then
                mod = vehicle_enum.VehicleMod.Ornament
            elseif options == 2 then
                mod = vehicle_enum.VehicleMod.DialDesign
            elseif options == 3 then
                mod = vehicle_enum.VehicleMod.TrimDesign
            elseif options == 4 then
                mod = vehicle_enum.VehicleMod.SpeakersDoor
            elseif options == 5 then
                mod = vehicle_enum.VehicleMod.LeatherSeats
            elseif options == 6 then
                mod = vehicle_enum.VehicleMod.SteeringWheel
            elseif options == 7 then
                mod = vehicle_enum.VehicleMod.ColumnShifterLever
            elseif options == 8 then
                mod = vehicle_enum.VehicleMod.Plaque
            elseif options == 9 then
                mod = vehicle_enum.VehicleMod.Speakers
            end

            networkUtils.RequestControlOf(vehicle)
            local counts = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, mod)
            if counts > 0.0 then
                io.write("Enter the modification identifier from " .. 1 .. " to " .. string.format("%d", counts) .. ": ")
                local modID = tonumber(io.read())

                CreateTuningFX(vehicle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle, mod, modID, 0)
            else 
                print("The vehicle doesn't have variations of this modification")
            end
        else
            DisplayError(false, "Uncorrect input")
        end
    elseif tuning == 22 then
        MakeVehicleMaxTuning(vehicle)
    elseif tuning == 23 then
        CreateTuningFX(vehicle, 2.0)

        VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle, 0)
        VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)

        for i = 0, 30, 1 do
            if i >= 17 and i <= 24 then

            else 
                VEHICLE.SET_VEHICLE_MOD(vehicle, i, 0, 0)
            end
        end

        VEHICLE.SET_VEHICLE_MOD(vehicle, 48, 0, 0)

        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, 20, false)
        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle, 22, false)
        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle, true)
        VEHICLE.SET_VEHICLE_WHEELS_CAN_BREAK(vehicle, true)
    
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 0, false)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 1, false)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 2, false)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle, 3, false)
        VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(vehicle, 0, 0, 0)
        VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle, 0)
    end
end

function ModifyVehicle(vehicle)
    local options = { "Dynamic neon", "Dynamic color", "Mute siren", "Set invincible", "Set lock on", "Set engine sound" }
    local option = InputFromList("Choose what you want to: ", options)

    if option == 0 then
        io.write("Enable dynamic neon lights? [Y/n]: ")
        local input = string.lower(io.read())
        
        if input == "y" then
            SetGlobalVariableValue("DynamicNeonVehicle", vehicle)
            MarkVehicleAsModed(vehicle)
        elseif input == "n" then
            SetGlobalVariableValue("DynamicNeonVehicle", 0.0)
        end 
    elseif option == 1 then
        io.write("Enable dynamic changing colour? [Y/n]: ")
        local input = string.lower(io.read())
            
        if input == "y" then
            SetGlobalVariableValue("DynamicColorVehicle", vehicle)
            MarkVehicleAsModed(vehicle)
        elseif input == "n" then
            SetGlobalVariableValue("DynamicColorVehicle", 0.0)
        end 
    elseif option == 2 then
        networkUtils.RequestControlOf(vehicle)

        io.write("Do you want to enable mute? [Y/n]: ")
        local input = string.lower(io.read())

        if input == "y" then
            VEHICLE.SET_VEHICLE_HAS_MUTED_SIRENS(vehicle, true)
            MarkVehicleAsModed(vehicle)
        elseif input == "n" then
            VEHICLE.SET_VEHICLE_HAS_MUTED_SIRENS(vehicle, false)
            MarkVehicleAsModed(vehicle)
        end
    elseif option == 3 then
        io.write("Set the invincibility of the selected vehicle? [Y/n]: ")
        local input = string.lower(io.read())

        if input == "y" then
            ENTITY.SET_ENTITY_INVINCIBLE(vehicle, true)
            MarkVehicleAsModed(vehicle)
        elseif input == "n" then
            ENTITY.SET_ENTITY_INVINCIBLE(vehicle, false)
        end 
    elseif option == 4 then
        io.write("Allow other players from locking on to the selected vehicle? [Y/n]: ")
        local input = string.lower(io.read())

        if input == "y" then
            VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON(vehicle, true, false)
            VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(vehicle, true, false)
        elseif input == "n" then
            VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON(vehicle, false, false)
            VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(vehicle, false, false)
            MarkVehicleAsModed(vehicle)
        end 
    elseif option == 5 then
        local enginesound = nil

        local options = { "Adder", "Interceptor", "Gang Burrito", "Itali RSX", "Buffalo EVX", "R88", "Custom" }
        local enginesounds = { "adder", "polgauntlet", "gburrito", "italirsx", "buffalo5", "formula2" }
        local option = InputFromList("Choose the engine sound you want to set: ", options)

        if option ~= -1 then
            if option == 6 then
                io.write("Enter the vehicle model name: ")
                enginesound = string.upper(io.read())
            else
                enginesound = enginesounds[option+1]
            end
            
            SetVehicleEngineSound(vehicle, enginesound)
        end
    end
end

function VehicleListCommand()
    if #createdvehiclesID ~= 0 then
        local vehID = InputFromList("Choose the vehicle you want to interact with: ", createdvehiclesmodels)
        if vehID ~= -1 then
            local veh = createdvehiclesID[vehID+1]
            print("The Vehicle ID of the selected vehicle is " .. veh)

            local options = { "Control vehicle", "Tuning vehicle", "Modify vehicle", "Delete" }
            local option = InputFromList("Choose what you want to: ", options)

            if option == 0 then
                ControlVehicle(veh)
            elseif option == 1 then
                TuningVehicle(veh)
            elseif option == 2 then
                ModifyVehicle(veh)
            elseif option == 3 then
                networkUtils.RequestControlOf(veh)
                DeleteVehicle(veh)

                table.remove(createdvehiclesID, vehID+1)
                table.remove(createdvehiclesmodels, vehID+1)
            end
        end
    else
        print("There are no vehicles on the vehicle list yet")
    end
end

function ModifiedVehiclesCommand()
    if #modifyedvehiclesID ~= 0 then
        local vehID = InputFromList("Choose the vehicle you want to interact with: ", modifyedvehiclesmodels)
        if vehID ~= -1 then
            local veh = modifyedvehiclesID[vehID+1]

            ModifyVehicle(veh)
        end
    else
        print("There are no vehicles on the modified vehicle list yet")
    end
end

function AddVehicleToListCommand()
    local veh = 0

    veh = inputUtils.InputVehicle()

    if not veh then
        DisplayError(false, "Uncorrect input")
        return nil
    end

    table.insert(createdvehiclesmodels, vehicleUtils.GetVehicleModelName(ENTITY.GET_ENTITY_MODEL(veh)))
    table.insert(createdvehiclesID, veh)
end

function CreateVehicleCommand()
    local hash = nil
    local Iters = 0
    local Tunning = false

    io.write("Enter vehicle model(https://forge.plebmasters.de/vehicles): ")
    local modelName = io.read()

    if modelName == "" then
        repeat
            modelName = vehicleUtils.GetRandomVehicleModelName()
            hash = MISC.GET_HASH_KEY(modelName)

            Iters = Iters + 1

            Wait(1)
        until not VEHICLE.IS_THIS_MODEL_A_CAR(hash) and not VEHICLE.IS_THIS_MODEL_A_BIKE(hash) and not VEHICLE.IS_THIS_MODEL_A_QUADBIKE(hash) and not VEHICLE.IS_THIS_MODEL_AN_AMPHIBIOUS_CAR(hash) and not VEHICLE.IS_THIS_MODEL_AN_AMPHIBIOUS_QUADBIKE(hash) and Iters < 50
    else
        hash = MISC.GET_HASH_KEY(modelName)
    end  

    local failed = false
    
    if STREAMING.IS_MODEL_VALID(hash) then
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) and not failed do
            if Iters > 50 then
                DisplayError(false, "Failed to load the model")
                failed = true
            end

            Wait(5)
            Iters = Iters + 1
        end
        
        if not failed then
            local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)

            io.write("Create an already tuned? [Y/n]: ")
            local input = string.lower(io.read())

            if input == "y" then
                Tunning = true
            end 

            local veh = VEHICLE.CREATE_VEHICLE(hash, coords.x + 3.5, coords.y + 3.0, coords.z + 0.5, 0.0, false, false, false)
            networkUtils.RegisterAsNetwork(veh)

            if veh ~= 0.0 then
                if Tunning then
                    MakeVehicleMaxTuning(veh)
                end
                
                --STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_indep_firework_sparkle_spawn")
                --GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY("scr_indep_firework_sparkle_spawn", veh, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0, 0, 0)

                VEHICLE.SET_VEHICLE_IS_WANTED(veh, false)
    
                local blip = HUD.ADD_BLIP_FOR_ENTITY(veh)

                HUD.SET_BLIP_AS_FRIENDLY(blip, true)
                HUD.SET_BLIP_SPRITE(blip, mapUtils.GetBlipFromEntityModel(hash))
                HUD.SET_BLIP_COLOUR(blip, blip_enums.BlipColour.Blue2)
                HUD.SET_BLIP_DISPLAY(blip, blip_enums.BlipDisplay.SelectableShowsOnBothMaps)
    
                printColoured("green", "Succesfully created new vehicle. Vehicle ID is " .. veh)

                table.insert(createdvehiclesmodels, modelName)
                table.insert(createdvehiclesID, veh)
                
                io.write("Do you want to get in? [Y/n]: ")
                input = string.lower(io.read())
    
                if input == "y" then
                    PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
                    CreateTuningFX(veh, 4.0)
                end
            end
        end
    end
end 

function DeleteVehicleCommand()
    local veh = 0

    veh = inputUtils.InputVehicle()

    if not veh then
        DisplayError(false, "Uncorrect input")
        return nil
    end

    networkUtils.RequestControlOf(veh)
    DeleteVehicle(veh)
end

function ExplodeVehicleCommand()
    local veh = 0

    veh = inputUtils..InputVehicle()

    if not veh then
        DisplayError(false, "Uncorrect input")
        return nil
    end

    if ENTITY.IS_ENTITY_A_VEHICLE(veh) then
        io.write("Connecting to vehicle")

        for i = 1, 3, 1 do
            io.write_anonym(".")
            Wait(100)
        end
        io.write_anonym("\n")

        io.write("Establishing SSH tunnel")
        for i = 1, 3, 1 do
            io.write_anonym(".")
            Wait(50)
        end
        io.write_anonym("\n")

        io.write("Bypassing security protocols")
        for i = 1, 3, 1 do
            io.write_anonym(".")
            Wait(200)
        end
        io.write_anonym("\n")
        
        io.write("Identifying vulnerabilities")
        for i = 1, 3, 1 do
            io.write_anonym(".")
            Wait(50)
        end
        io.write_anonym("\n")

        print("Access granted. Sending a self-destruct signal")

        for i = 1, 3, 1 do
            print("The vehicle will be destroyed in " .. 4 - i)
            Wait(1000)
        end

        networkUtils.RequestControlOf(veh)
        VEHICLE.EXPLODE_VEHICLE(veh, true, false)
        NETWORK.NETWORK_EXPLODE_VEHICLE(veh, true, false, NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(veh))
        local coords = ENTITY.GET_ENTITY_COORDS(veh, true)
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 4, 10000.0, true, false, 1.0, false)

        Wait(1000)

        if ENTITY.IS_ENTITY_DEAD(veh) then
            printColoured("green", "The vehicle has been destroyed")
        else
            DisplayError(false, "Failed to destroy a vehicle")
        end
    else
        DisplayError(false, "Uncorrect input")
    end
end

function FixVehicleCommand()
    local veh = 0

    veh = inputUtils.InputVehicle()

    if not veh then
        DisplayError(false, "Uncorrect input")
        return nil
    end

    VEHICLE.SET_VEHICLE_FIXED(veh)
end

function VehicleTuningCommand()
    local veh = 0

    veh = inputUtils.InputVehicle()

    if not veh then
        DisplayError(false, "Uncorrect input")
        return nil
    end

    TuningVehicle(veh)
end

function VehicleControlCommand()
    local veh = 0

    veh = inputUtils.InputVehicle()

    if not veh then
        DisplayError(false, "Uncorrect input")
        return nil
    end

    ControlVehicle(veh)
end

function VehicleModCommand()
    local veh = 0

    veh = inputUtils.InputVehicle()

    if not veh then
        DisplayError(false, "Uncorrect input")
        return nil
    end

    ModifyVehicle(veh)
end

function SetVehicleInvincible()
    local veh = 0

    veh = inputUtils.InputVehicle()

    if not veh then
        DisplayError(false, "Uncorrect input")
        return nil
    end

    io.write("Set the invincibility of the selected vehicle? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        ENTITY.SET_ENTITY_INVINCIBLE(veh, true)
    elseif input == "n" then
        ENTITY.SET_ENTITY_INVINCIBLE(veh, false)
    end 
end

function SetVehicleLockOn()
    local veh = 0

    veh = inputUtils.InputVehicle()

    if not veh then
        DisplayError(false, "Uncorrect input")
        return nil
    end

    io.write("Allow other players from locking on to the selected vehicle? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON(veh, false, false)
        VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(veh, false, false)
    elseif input == "n" then
        VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON(veh, true, false)
        VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(veh, true, false)
    end 
end

function SaveVehicleComamnd()
    local veh = nil
    
    veh = inputUtils.InputVehicle()
    
    if not veh or veh == 0.0 then
        DisplayError(false, "Failed to get current player vehicle")
        return nil
    end

    SaveVehicle(veh)
end
function CreateSavedVehicleCommand()
    local Iters = 0
    local savedVehicle = nil
    local vehiclesList = JsonReadList("saved_vehicles.json")

    local savedvehicles = { }

    for _, vehicle in ipairs(vehiclesList) do
        table.insert(savedvehicles, vehicle.name .. "\t" .. vehicle.modelName)
    end
    
    local vehicle = InputFromList("Enter which vehicle you want to create: ", savedvehicles)

    savedVehicle = vehiclesList[vehicle+1]

    -- Загрузка списка сохраненных транспортных средств

    -- Ищем транспортное средство с соответствующим именем


    if savedVehicle == nil then
        DisplayError(false, "Vehicle not found")
        return
    end

    local failed = false
    if STREAMING.IS_MODEL_VALID(savedVehicle["model"]) then
        STREAMING.REQUEST_MODEL(savedVehicle["model"])
        while not STREAMING.HAS_MODEL_LOADED(savedVehicle["model"]) and not failed do
            if Iters > 50 then
                DisplayError(false, "Failed to load the model")
                failed = true
            end

            Wait(5)
            Iters = Iters + 1
        end
        
        if not failed then
            -- Создаем транспортное средство рядом с игроком
            local playerPed = PLAYER.PLAYER_PED_ID()
            local coords = ENTITY.GET_ENTITY_COORDS(playerPed)

            -- Используйте вашу функцию CreateVehicleNearPlayer
            local veh = VEHICLE.CREATE_VEHICLE(savedVehicle["model"], coords.x + 3.5, coords.y + 3.0, coords.z + 0.5, 0.0, false, false, false)
            networkUtils.RegisterAsNetwork(veh)

            if veh ~= 0.0 then
                -- Устанавливаем модификации

                VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)

                for i = 0, 24 do
                    if savedVehicle["mod" .. i] ~= nil then
                        if i >= 17 and i <= 22 then
                            VEHICLE.TOGGLE_VEHICLE_MOD(veh, i, savedVehicle["mod" .. i] == 1)
                        else
                            VEHICLE.SET_VEHICLE_MOD(veh, i, savedVehicle["mod" .. i], true)
                        end
                    end
                end

                VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, savedVehicle["dirtLevel"])
                VEHICLE.SET_VEHICLE_ENVEFF_SCALE(veh, savedVehicle["paintFade"])

                
                VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(veh, savedVehicle["xenonColorIndex"])
                VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, not savedVehicle["bulletproofTyres"] == 1.0)


                VEHICLE.SET_VEHICLE_MOD(veh, 48, savedVehicle["livery"], 0)
                VEHICLE.SET_VEHICLE_LIVERY2(veh, savedVehicle["livery2"])
                VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(veh, savedVehicle["plateText"])
                VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, savedVehicle["plateTextIndex"])
                VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, savedVehicle["windowsTint"])
                
                -- Устанавливаем неоновые цвета и состояния
                VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 0, savedVehicle["neonEnabledLeft"] == 1.0)
                VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 1, savedVehicle["neonEnabledRight"] == 1.0)
                VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 2, savedVehicle["neonEnabledFront"] == 1.0)
                VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 3, savedVehicle["neonEnabledBack"] == 1.0)
                VEHICLE.SET_VEHICLE_NEON_COLOUR(veh, savedVehicle["neonR"], savedVehicle["neonG"], savedVehicle["neonB"])
                
                -- Устанавливаем цвета
                VEHICLE.SET_VEHICLE_COLOURS(veh, savedVehicle["primaryColor"], savedVehicle["secondaryColor"])
                VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, savedVehicle["pearlColor"], savedVehicle["wheelColor"])

                -- Устанавливаем пользовательские цвета, если они есть
                if savedVehicle["customPrimaryR"] then
                    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, savedVehicle["customPrimaryR"], savedVehicle["customPrimaryG"], savedVehicle["customPrimaryB"])
                end
                if savedVehicle["customSecondaryR"] then
                    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, savedVehicle["customSecondaryR"], savedVehicle["customSecondaryG"], savedVehicle["customSecondaryB"])
                end

                -- Устанавливаем состояние крыши для кабриолетов
                if VEHICLE.IS_VEHICLE_A_CONVERTIBLE(veh, 0) then
                    VEHICLE.RAISE_CONVERTIBLE_ROOF(veh, savedVehicle["roofState"] == 1.0)
                end

                -- Устанавливаем состояния экстра
                for i = 1, 10 do
                    if VEHICLE.DOES_EXTRA_EXIST(veh, i) then
                        VEHICLE.SET_VEHICLE_EXTRA(veh, i, savedVehicle["extra" .. i]  == 1.0)
                   end
                end

                VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(veh, savedVehicle["tyreSmokeR"], savedVehicle["tyreSmokeG"], savedVehicle["tyreSmokeB"])

                if savedVehicle["isModed"] then
                    if savedVehicle["engineSound"] then
                        SetVehicleEngineSound(veh, savedVehicle["engineSound"])
                    end
                end

                local blip = HUD.ADD_BLIP_FOR_ENTITY(veh)

                HUD.SET_BLIP_AS_FRIENDLY(blip, true)
                HUD.SET_BLIP_SPRITE(blip, mapUtils.GetBlipFromEntityModel(savedVehicle["model"]))
                HUD.SET_BLIP_COLOUR(blip, blip_enums.BlipColour.Blue2)
                HUD.SET_BLIP_DISPLAY(blip, blip_enums.BlipDisplay.SelectableShowsOnBothMaps)
            
                io.write("Do you want to get in? [Y/n]: ")
                input = string.lower(io.read())
    
                if input == "y" then
                    PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
                    CreateTuningFX(veh, 4.0)
                end
                
                printColoured("green", "The vehicle has been successfully created. Vehicle ID is " .. veh)

                table.insert(createdvehiclesmodels, savedVehicle["modelName"])
                table.insert(createdvehiclesID, veh)
            end
        end
    else
        DisplayError(false, "Failed to create vehicle.")
    end
end

function BreakViewAllVehicles()
    -- Удалить камеру
    if viewAllVehiclescamera then
        missionUtils.DeleteCamera(viewAllVehiclescamera)
        viewAllVehiclescamera = nil
    end

    -- Позволить игроку управлять персонажем снова
    PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), true, 0)
    STREAMING.SET_FOCUS_ENTITY(PLAYER.PLAYER_PED_ID())

    -- Удалить текущий транспорт
    if viewAllVehiclesCurrentVehicle then
        networkUtils.RequestControlOf(viewAllVehiclesCurrentVehicle)

        DeleteVehicle(viewAllVehiclesCurrentVehicle)
        if ENTITY.DOES_ENTITY_EXIST(viewAllVehiclesCurrentVehicle) then
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(viewAllVehiclesCurrentVehicle, -1000.0, 1000.0, 0.0, true, true, true)
            DeleteVehicle(viewAllVehiclesCurrentVehicle)
        end

        viewAllVehiclesCurrentVehicle = nil
    end

    StillViewingAllVehicles = false
    io.write_anonym("\n")
end

function SpawnVehicle(vehicleName, coords)
    local iters = 0
    -- Удаляем старый транспорт, если он существует
    if viewAllVehiclesCurrentVehicle then
        networkUtils.RequestControlOf(viewAllVehiclesCurrentVehicle)

        DeleteVehicle(viewAllVehiclesCurrentVehicle)
        if ENTITY.DOES_ENTITY_EXIST(viewAllVehiclesCurrentVehicle) then
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(viewAllVehiclesCurrentVehicle, 0.0, 0.0, 0.0, true, true, true)
            DeleteVehicle(viewAllVehiclesCurrentVehicle)
        end
    end
    
    -- Спавним новый транспорт
    local hash = MISC.GET_HASH_KEY(vehicleName)
    if STREAMING.IS_MODEL_VALID(hash) then
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) do
            if iters > 50 then
                io.write_anonym("\n")
                DisplayError(false, "Failed to load the ".. vehicleName .. " model")
                BreakViewAllVehicles()
                return nil
            end

            Wait(5)
            iters = iters + 1
        end
    else
        io.write_anonym("\n")
        DisplayError(false, "Unable to continue execution because the model ".. vehicleName .. " not valid")
        BreakViewAllVehicles()
        return nil
    end

    viewAllVehiclesCurrentVehicle = VEHICLE.CREATE_VEHICLE(hash, coords.x, coords.y, coords.z, 0.0, false, true, false)
    VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(viewAllVehiclesCurrentVehicle)
    STREAMING.SET_FOCUS_ENTITY(viewAllVehiclesCurrentVehicle)

    local vehiclep = NewVehicle(viewAllVehiclesCurrentVehicle)
    
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(vehiclep)
    Delete(vehiclep)

    ResetLineAndPrint(vehicleName)
end

function ChangeVehicle(direction)
    viewAllVehiclesListVehicleIndex = viewAllVehiclesListVehicleIndex + direction
    if viewAllVehiclesListVehicleIndex > #viewAllVehiclesList then
        viewAllVehiclesListVehicleIndex = 1
    elseif viewAllVehiclesListVehicleIndex < 1 then
        viewAllVehiclesListVehicleIndex = #viewAllVehiclesList
    end

    AUDIO.PLAY_SOUND_FRONTEND(-1, "SELECT", "HUD_LIQUOR_STORE_SOUNDSET", true)

    -- Спавнить новый транспорт
    SpawnVehicle(viewAllVehiclesList[viewAllVehiclesListVehicleIndex], {x = -482.3, y = -133.3, z = 37.6})
end

function ViewAllVehiclesCommand()
    StillViewingAllVehicles = true
    viewAllVehiclesListVehicleIndex = 1

    io.write_anonym("\n")
    -- Установить камеру на заданные координаты
    local cameraCoords = {x = -486.89999389648, y = -130.19999694824, z = 39.5}
    local heading = 234.0

    -- Создаем камеру
    viewAllVehiclescamera = missionUtils.CreateCamera(cameraCoords.x, cameraCoords.y, cameraCoords.z, heading, 0.0, 0.0, 0)

    -- Запретить управление игроком
    PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), false, 0)

    -- Спавнить первый автомобиль
    SpawnVehicle(viewAllVehiclesList[viewAllVehiclesListVehicleIndex], {x = -482.3, y = -133.3, z = 37.6})
    
    -- Вход в основной цикл
    while true do
        if not StillViewingAllVehicles then
            return nil
        end
        -- Обработка нажатия клавиш
        if IsPressedKey(ViewAllVehiclesNextKey) then
            ChangeVehicle(1)
        elseif IsPressedKey(ViewAllVehiclesBackKey) then
            ChangeVehicle(-1)
        elseif IsPressedKey(ViewAllVehiclesSelectKey) then
            local coords = CAM.GET_CAM_COORD(viewAllVehiclescamera)
            --print(coords.x, coords.y, coords.z) -- DEBUG
            BreakViewAllVehicles()
            break
        --[[

        --DEBUG

        elseif IsPressedKey(0x41) then
            cameraCoords.y = cameraCoords.y + 1.0
            CAM.SET_CAM_COORD(viewAllVehiclescamera, cameraCoords.x, cameraCoords.y, cameraCoords.z)
            Wait(100)
        elseif IsPressedKey(0x44) then
            cameraCoords.y = cameraCoords.y - 1.0
            CAM.SET_CAM_COORD(viewAllVehiclescamera, cameraCoords.x, cameraCoords.y, cameraCoords.z)
            Wait(100)
        elseif IsPressedKey(0x57) then
            cameraCoords.x = cameraCoords.x + 1.0
            CAM.SET_CAM_COORD(viewAllVehiclescamera, cameraCoords.x, cameraCoords.y, cameraCoords.z)
            Wait(100)
        elseif IsPressedKey(0x53) then
            cameraCoords.x = cameraCoords.x - 1.0
            CAM.SET_CAM_COORD(viewAllVehiclescamera, cameraCoords.x, cameraCoords.y, cameraCoords.z)
            Wait(100)
        elseif IsPressedKey(0x20) then
            cameraCoords.z = cameraCoords.z + 1.0
            CAM.SET_CAM_COORD(viewAllVehiclescamera, cameraCoords.x, cameraCoords.y, cameraCoords.z)
            Wait(100)
        elseif IsPressedKey(0x11) then
            cameraCoords.z = cameraCoords.z - 1.0
            CAM.SET_CAM_COORD(viewAllVehiclescamera, cameraCoords.x, cameraCoords.y, cameraCoords.z)
            Wait(100)
        ]]
        end

        Wait(10)
    end
end

function InitializeSettings()
    local AutoFixVehicle = mathUtils.BooleanToNumber(configUtils.GetFeatureSetting("VehicleOptions", "AutoFixVehicle"))
    local DisableLockOn = mathUtils.BooleanToNumber(configUtils.GetFeatureSetting("VehicleOptions", "DisableLockOn"))

    ViewAllVehiclesNextKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "ViewAllVehiclesNextKey"))
    ViewAllVehiclesBackKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "ViewAllVehiclesBackKey"))
    ViewAllVehiclesSelectKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "ViewAllVehiclesSelectKey"))

    SetGlobalVariableValue("AutoFixCurrentVehicleState", AutoFixVehicle)
    SetGlobalVariableValue("DisableLockOnCurrentVehicleState", DisableLockOn)
end

-- Определим словарь с командами и их функциями
local Commands = {
    ["vehicle list"] = VehicleListCommand,
    ["modified vehicles"] = ModifiedVehiclesCommand,
    ["add to vehicle list"] = AddVehicleToListCommand,
    ["create vehicle"] = CreateVehicleCommand,
    ["delete vehicle"] = DeleteVehicleCommand,
    ["explode vehicle"] = ExplodeVehicleCommand,
    ["fix vehicle"] = FixVehicleCommand,
    ["vehicle tuning"] = VehicleTuningCommand,
    ["vehicle control"] = VehicleControlCommand,
    ["vehicle mod"] = VehicleModCommand,
    ["set veh invincible"] = SetVehicleInvincible,
    ["set vehicle lock on"] = SetVehicleLockOn,
    ["save vehicle"] = SaveVehicleComamnd,
    ["create saved vehicle"] = CreateSavedVehicleCommand,
    ["view all vehicles"] = ViewAllVehiclesCommand
}

math.randomseed(os.time())

InitializeSettings()

-- Цикл для регистрации команд
for commandName, commandFunction in pairs(Commands) do
    if not BindCommand(commandName, commandFunction) then
        DisplayError(true, "Failed to register the command: " .. commandName)
    end
end

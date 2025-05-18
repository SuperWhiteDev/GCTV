RegisterGlobalVariable("AlwaysCleanLocalPlayerState", 0.0)
RegisterGlobalVariable("EveryoneIgnoreLocalPlayerState", 0.0)
RegisterGlobalVariable("NeverWantedLocalPlayerState", 0.0)
RegisterGlobalVariable("MobileRadioState", 0.0)
RegisterGlobalVariable("LockedRadioStationName", 0.0) --RegisterGlobalVariableString("LockedRadioStationName", 0.0)

local clothing = require("clothing_enum")
local inputUtils = require("input_utils")
local mathUtils = require("math_utils")
local configUtils = require("config_utils")

function SaveOutfit()
    local outfit = {}

    io.write("Enter the name of the outfit you want to save: ")
    local outfitName = io.read()


    outfit["name"] = outfitName

    for k, v in pairs(clothing.UniqueClothingComponents) do
        outfit[k] = { }
        outfit[k]["DrawableID"] = PED.GET_PED_DRAWABLE_VARIATION(PLAYER.PLAYER_PED_ID(), v)
        outfit[k]["TextureID"] = PED.GET_PED_TEXTURE_VARIATION(PLAYER.PLAYER_PED_ID(), v)
        outfit[k]["PaletteID"] = PED.GET_PED_PALETTE_VARIATION(PLAYER.PLAYER_PED_ID(), v)
    end

    local outfitList = JsonReadList("saved_outfits.json") or {}
    table.insert(outfitList, outfit)

    JsonSaveList("saved_outfits.json", outfitList)

    printColoured("green", "The outfit has been successfully saved.")
end

function PlayerCommand()
    print("1.Clone Player - ")
    print("2.Clean Player - ")
    print("3.Set Player Wanted - ")
    print("4.Set Player Invincible - ")
end
function OutfitCommand()
    local outfits = { "Santa", "Cop", "Saved outfit", "Custom" }

    local input = InputFromList("Enter the desired outfit or enter custom to create your own outfit: ", outfits)

    if input == 0 then
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.Hats, 22, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.Masks, 8, 0, 0) 
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.Tops, 19, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.Legs, 18, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.Shoes, 7, 0, 0)
    elseif input == 1 then 
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.Glasses, 0, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.Tops, 48, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.Torsos, 22, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.Undershirts, 35, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.Legs, 34, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.Shoes, 25, 0, 0)
    elseif input == 2 then
        local savedOutfit = nil
        local outfitList = JsonReadList("saved_outfits.json")

        local savedOutfitNames = { }

        for _, outfit in ipairs(outfitList) do
            table.insert(savedOutfitNames, outfit.name)
        end
    
        local outfitID = InputFromList("Enter which vehicle you want to create: ", savedOutfitNames)

        savedOutfit = outfitList[outfitID+1]

        if savedOutfit == nil then
            DisplayError(false, "Outfit not found")
            return nil
        end

        local clothingComponentsList = {}

        for k, v in pairs(clothing.ClothingComponents) do
            clothingComponentsList[k] = v
        end

        for k, v in pairs(savedOutfit) do
            PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothingComponentsList[k], savedOutfit[k]["DrawableID"], savedOutfit[k]["TextureID"], savedOutfit[k]["PaletteID"])
        end
    elseif input == 3 then
        local componentNames = { }
        local componentIDs = { }

        local componentID = nil
        local drawbleID = nil
        local textureID = nil

        for k, v in pairs(clothing.ClothingComponents) do
            componentNames[#componentNames + 1] = string.gsub(k, "_", " ")
            componentIDs[#componentIDs + 1] = v
        end

        local component = InputFromList("Enter the type of clothing: ", componentNames)

        componentID = componentIDs[component+1]

        io.write("Enter the drawable ID of the clothes(https://wiki.rage.mp/index.php?title=Clothes): ")
        drawbleID = tonumber(io.read())
        io.write("Enter the texture ID of the clothes(https://forge.plebmasters.de/clothes?p=4): ")
        textureID = tonumber(io.read())

        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), componentID, drawbleID, textureID, 0)
    end
end

function SaveOutfitCommand()
    if PLAYER.PLAYER_PED_ID() == 0.0 then
        DisplayError(false, "Failed to get current player handle")
        return nil
    end

    SaveOutfit()   
end

function ClonePlayerCommand()
    print("Cloned ped handle is " .. PED.CLONE_PED(PLAYER.PLAYER_PED_ID(), true, true, true))
end
function CleanPlayerCommand()
    PED.CLEAR_PED_BLOOD_DAMAGE(PLAYER.PLAYER_PED_ID())
    PED.CLEAR_PED_ENV_DIRT(PLAYER.PLAYER_PED_ID())
    PED.CLEAR_PED_WETNESS(PLAYER.PLAYER_PED_ID())
    PED.RESET_PED_VISIBLE_DAMAGE(PLAYER.PLAYER_PED_ID())
end
function SuicideCommand()
    ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), 0, PLAYER.PLAYER_PED_ID(), 0)
end
function NeverWantedCommand()
    io.write("Disable wanted for local player? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        PLAYER.CLEAR_PLAYER_WANTED_LEVEL(PLAYER.PLAYER_ID())
        PLAYER.SET_MAX_WANTED_LEVEL(0)
    elseif input == "n" then
        PLAYER.SET_MAX_WANTED_LEVEL(5)
    end 
    
end
function SetPlayerWantedLevelCommand()
    io.write("Enter the desired wanted level: ")
    local wantedLevel = tonumber(io.read())

    if wantedLevel then
        PLAYER.SET_PLAYER_WANTED_LEVEL(PLAYER.PLAYER_ID(), wantedLevel, 0)
        PLAYER.SET_PLAYER_WANTED_LEVEL_NOW(PLAYER.PLAYER_ID(), 0)
    else
        DisplayError(false, "Uncorrect input")
    end
end
function SetPlayerInvincible()
    io.write("Set local player invincible? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        ENTITY.SET_ENTITY_INVINCIBLE(PLAYER.PLAYER_PED_ID(), true)
    elseif input == "n" then
        ENTITY.SET_ENTITY_INVINCIBLE(PLAYER.PLAYER_PED_ID(), false)
    end 
end

function SetPlayerSeatBeltCommand()
    io.write("Do you want to disable the player being thrown out of the vehicles? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(PLAYER.PLAYER_PED_ID(), 1)
        PED.SET_PED_CONFIG_FLAG(PLAYER.PLAYER_PED_ID(), 32, false)
    elseif input == "n" then
        PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(PLAYER.PLAYER_PED_ID(), 0)
        PED.SET_PED_CONFIG_FLAG(PLAYER.PLAYER_PED_ID(), 32, true)
    end  
end

function EnterInVehCommand()
    local veh = inputUtils.InputVehicle()

    if veh then 
        local seats = { "Driver seat", "Available passenger seat", "Custom" }
        local seat = InputFromList("Choose where you want to seat the local player: ", seats)

        if seat == 0 then
            local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, true)
            PED.SET_PED_INTO_VEHICLE(driver, veh, -2)
            PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
            PED.SET_PED_INTO_VEHICLE(driver, veh, -2)
        elseif seat == 1 then
            PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -2)
        elseif seat == 2 then
            io.write("Enter the seat index: ")
            local seatIndex  = tonumber(io.read())
            
            if seatIndex then
                local passenger = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, seatIndex, true)
                PED.SET_PED_INTO_VEHICLE(passenger, veh, -2)
                PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, seatIndex)
                PED.SET_PED_INTO_VEHICLE(passenger, veh, -2)
            end
        end
    else
        DisplayError(false, "Uncorrect input")
    end
end

function MobileRadioCommand()
    io.write("Set local player invincible? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        AUDIO.SET_MOBILE_RADIO_ENABLED_DURING_GAMEPLAY(true)
        AUDIO.SET_MOBILE_PHONE_RADIO_STATE(true)
    elseif input == "n" then
        AUDIO.SET_MOBILE_RADIO_ENABLED_DURING_GAMEPLAY(false)
        AUDIO.SET_MOBILE_PHONE_RADIO_STATE(false)
    end  
end

function NextRadioTrackCommand()
    AUDIO.SKIP_RADIO_FORWARD()
end

function LockRadioStationCommand()
    
end

function SetRadioTrackCommand()
    AUDIO.SET_RADIO_TRACK()
    AUDIO.GET_CURRENT_TRACK_SOUND_NAME(radiostation)
end

function LockRadioTrackCommand()
    
end

function InitializeSettings()
    local AlwaysCleanPlayer = mathUtils.BooleanToNumber(configUtils.GetFeatureSetting("LocalPlayerOptions", "AlwaysCleanPlayer"))
    local EveryoneIgnore = mathUtils.BooleanToNumber(configUtils.GetFeatureSetting("LocalPlayerOptions", "EveryoneIgnore"))
    local NeverWanted = mathUtils.BooleanToNumber(configUtils.GetFeatureSetting("LocalPlayerOptions", "NeverWanted"))
    local MobileRadio = mathUtils.BooleanToNumber(configUtils.GetFeatureSetting("LocalPlayerOptions", "MobileRadio"))
    local LockedRadioStation = configUtils.GetFeatureSetting("LocalPlayerOptions", "LockedRadioStation")

    SetGlobalVariableValue("AlwaysCleanLocalPlayerState", AlwaysCleanPlayer)
    SetGlobalVariableValue("EveryoneIgnoreLocalPlayerState", EveryoneIgnore)
    SetGlobalVariableValue("NeverWantedLocalPlayerState", NeverWanted)
    SetGlobalVariableValue("MobileRadioState", MobileRadio)
    --SetGlobalVariableValue("LockedRadioStationName", LockedRadioStation)
end

-- Определим словарь с командами и их функциями
local Commands = {
    ["player"] = PlayerCommand,
    ["outfit"] = OutfitCommand,
    ["save outfit"] = SaveOutfitCommand,
    ["clone player"] = ClonePlayerCommand,
    ["clean player"] = CleanPlayerCommand,
    ["suicide"] = SuicideCommand,
    ["never wanted"] = NeverWantedCommand,
    ["set player wanted"] = SetPlayerWantedLevelCommand,
    ["set player invincible"] = SetPlayerInvincible,
    ["set player seatbelt"] = SetPlayerSeatBeltCommand,
    ["enter in veh"] = EnterInVehCommand,
    ["mobile radio"] = MobileRadioCommand,
    ["next radio track"] = NextRadioTrackCommand,
    ["lock radio station"] = LockRadioStationCommand,
    ["set radio track"] = SetRadioTrackCommand,
    ["lock radio track"] = LockRadioTrackCommand,
}

math.randomseed(os.time())

InitializeSettings()

-- Цикл для регистрации команд
for commandName, commandFunction in pairs(Commands) do
    if not BindCommand(commandName, commandFunction) then
        DisplayError(true, "Failed to register the command: " .. commandName)
    end
end
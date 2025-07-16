RegisterGlobalVariable("AerialReconnaissanceDroneState",  0.0)
RegisterGlobalVariable("AerialReconnaissanceDroneMissilesCount", 0.0)

local configUtils = require("config_utils")

function AerialReconnaissanceDroneCommand()
    if PLAYER.IS_PLAYER_CONTROL_ON(PLAYER.PLAYER_ID()) then
        if GetGlobalVariable("AerialReconnaissanceDroneState") == 0.0 then
            RunScript("C:\\Program Files\\GCTV\\Scripts\\features\\AerialReconnaissanceDrone.lua")
            printColoured("green", "Reconnaissance drone successfully launched")
            print("You can move the camera using the WASD keys and adjust the height with the mouse wheel. Additionally, you have the option to fire guided missiles by pressing the left mouse button. If desired, you can change the number of missiles with the command \"set ard missiles count\"")
        else
            DisplayError(false, "The reconnaissance drone has already been launched")
        end
    end
end

function SetAerialReconnaissanceDroneMissilesCountCommand()
    io.write("Enter the number of missiles for the aerial reconnaissance drone: ")
    local missilesCount = tonumber(io.read())

    if missilesCount then
        SetGlobalVariableValue("AerialReconnaissanceDroneMissilesCount", missilesCount)
    else
        DisplayError(false, "Uncorrect input")
    end
end

function InitializeSettings()
    local DroneMissilesCount = tonumber(configUtils.GetFeatureSetting("AerialReconnaissanceDroneOptions", "DroneMissilesCount"))

    SetGlobalVariableValue("AerialReconnaissanceDroneMissilesCount", DroneMissilesCount)
end

-- Определим словарь с командами и их функциями
local Commands = {
    ["aerial reconnaissance drone"] = AerialReconnaissanceDroneCommand,
    ["ard"] = AerialReconnaissanceDroneCommand,
    ["set ard missiles count"] = SetAerialReconnaissanceDroneMissilesCountCommand
}

math.randomseed(os.time())

InitializeSettings()

-- Цикл для регистрации команд
for commandName, commandFunction in pairs(Commands) do
    if not BindCommand(commandName, commandFunction) then
        DisplayError(true, "Failed to register the command: " .. commandName)
    end
end
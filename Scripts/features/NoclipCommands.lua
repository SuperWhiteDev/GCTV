RegisterGlobalVariable("NoclipSpeed", 0.0)

local configUtils = require("config_utils")

function NoclipHelpCommand()
    print("If you want to enable noclip, press F5 on the keyboard. Disabling noclip occurs by pressing the same button. You can also change the flight speed with the command \"set noclip speed\"")
end
function SetNoclipSpeed()
    if IsGlobalVariableExist("NoclipSpeed") then
        io.write("Enter noclip speed(current speed is " .. GetGlobalVariable("NoclipSpeed") .. "): ")
        local speed = tonumber(io.read())

        if speed then
            SetGlobalVariableValue("NoclipSpeed", speed)
        else
            DisplayError(false, "Uncorrect input")
        end
    end
end

function InitializeSettings()
    local NoclipSpeed = tonumber(configUtils.GetFeatureSetting("NoclipOptions", "NoclipSpeed"))

    SetGlobalVariableValue("NoclipSpeed", NoclipSpeed)
end

-- Определим словарь с командами и их функциями
local Commands = {
    ["noclip"] = NoclipHelpCommand,
    ["set noclip speed"] = SetNoclipSpeed
}

math.randomseed(os.time())

InitializeSettings()

-- Цикл для регистрации команд
for commandName, commandFunction in pairs(Commands) do
    if not BindCommand(commandName, commandFunction) then
        DisplayError(true, "Failed to register the command: " .. commandName)
    end
end
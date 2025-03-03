local scripts = {
    "C:\\Program Files\\GCTV\\Scripts\\features\\GameplayHotKeys.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\LocalPlayerCommands.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\LocalPlayerFeatures.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\NetworkCommands.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\VehicleCommand.lua", 
    "C:\\Program Files\\GCTV\\Scripts\\features\\ObjectCommands.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\PedCommands.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\TeleportCommands.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\WeaponCommands.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\WeaponFeatures.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\SessionCommands.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\VehicleFeatures.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\VehicleMods.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\NoclipCommands.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\Noclip.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\AerialReconnaissanceDroneCommands.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\Activities.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\ActivitieCommands.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\WorldCommands.lua",
    "C:\\Program Files\\GCTV\\Scripts\\features\\EspCommands.lua"
}

for _, script in ipairs(scripts) do
    if not RunScript(script) then
        DisplayError(true, "Failed to run the script: " .. script)
    end
end

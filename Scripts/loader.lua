local scripts = {
    "features\\gameplay_hotkeys.lua",
    "features\\local_player_commands.lua",
    "features\\local_player_features.lua",
    "features\\network_commands.lua",
    "features\\vehicle_commands.lua",
    "features\\object_commands.lua",
    "features\\ped_commands.lua",
    "features\\teleport_commands.lua",
    "features\\weapon_commands.lua",
    "features\\weapon_features.lua",
    "features\\session_commands.lua",
    "features\\vehicle_features.lua",
    "features\\vehicle_mods.lua",
    "features\\noclip_commands.lua",
    "features\\noclip.lua",
    "features\\aerial_reconnaissance_drone_commands.lua",
    "features\\activities.lua",
    "features\\activity_commands.lua",
    "features\\world_commands.lua",
    "features\\esp_commands.lua"
}                                                                  

for _, script in ipairs(scripts) do
    if not RunScript(script) then
        DisplayError(true, "Failed to run the script: " .. script)
    end
end

--[[
local entities, count = GetAllObjects()

print("Entities Count: " .. count)

local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
for i = 1, count, 1 do
    print("Teleporting entity " .. entities[i])

    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entities[i], coords.x, coords.y, coords.z + 2.0, false, false, true)
end
]]

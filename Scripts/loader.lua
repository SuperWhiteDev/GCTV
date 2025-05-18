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

--[[
local gamepad = Gamepad.Gamepad()

while ScriptStillWorking do
    local key = gamepad.GetPressedKey(gamepad)

    if key then
        print("Key", key)
    end

    local lss = gamepad.GetLeftStickState(gamepad)
    if lss then
        print("State", lss.ThumbLX, lss.ThumbLY)
    end
    Wait(1000)
end
]]

--[[
local entities, count = GetAllObjects()

print("Entities Count: " .. count)

local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
for i = 1, count, 1 do
    print("Teleporting entity " .. entities[i])

    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entities[i], coords.x, coords.y, coords.z + 2.0, false, false, true)
end
]]

--PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)

--[[
function drawText(text, x, y, scale, r, g, b, a)
    HUD.SET_TEXT_FONT(false)
    HUD.SET_TEXT_PROPORTIONAL(true)
    HUD.SET_TEXT_SCALE(scale, scale)
    HUD.SET_TEXT_COLOUR(r, g, b, a)
    HUD.SET_TEXT_DROPSHADOW(0, 0, 0, 0, 255)
    HUD.SET_TEXT_EDGE(1, 0, 0, 0, 255)
    HUD.SET_TEXT_DROP_SHADOW()
    HUD.SET_TEXT_OUTLINE()
    HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING")
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(text)
    HUD.END_TEXT_COMMAND_DISPLAY_TEXT(x, y, 1)
end

function DrawSprite(Streamedtexture, textureName, x, y, width, height, rotation, r, g, b, a)
    GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT(Streamedtexture, false)
    GRAPHICS.HAS_STREAMED_TEXTURE_DICT_LOADED(Streamedtexture)
    GRAPHICS.DRAW_SPRITE(Streamedtexture, textureName, x, y, width, height, rotation, r, g, b, a)
end
]]

--ShowMessage("Hello")
--for i = 1, 100, 1 do
--    HUD.SET_WARNING_MESSAGE("t20", 3, "terbyte", false, -1, 0, 0, true)
--    Wait(10)
--end

--[[
HUD.CLEAR_PRINTS()
HUD.CLEAR_BRIEF()
HUD.CLEAR_ALL_HELP_MESSAGES()
HUD.THEFEED_SET_VIBRATE_PARAMETER_FOR_NEXT_MESSAGE()

for i = 1, 100, 1 do
    HUD.BEGIN_TEXT_COMMAND_DISPLAY_HELP("STRING")
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME("Showing text")
    --HUD.ADD_TEXT_COMPONENT_FORMATTED_INTEGER(i, false)
    HUD.END_TEXT_COMMAND_DISPLAY_HELP(0, false, false, -1)
    Wait(10)
end
]]

--[[
    WEAPON::GET_CURRENT_PED_WEAPON_ENTITY_INDEX - its retunring ped weapoN as entity(object i think)
]]
RegisterGlobalVariable("InfinityAmmoLocalPlayerWeaponState", 0.0)
RegisterGlobalVariable("InfinityAmmoClipLocalPlayerWeaponState", 0.0)
RegisterGlobalVariable("AlwaysInvisibleLocalPlayerWeaponState", 0.0)

local mathUtils = require("math_utils")
local configUtils = require("config_utils")

function WeaponCommand()
    local weaponp = New(4)
    local weapon = nil

    WEAPON.GET_CURRENT_PED_WEAPON(PLAYER.PLAYER_PED_ID(), weaponp, true)
    weapon = Game.ReadInt(weaponp)


    print(WEAPON.GET_WEAPON_DAMAGE(weapon, 0))

    WEAPON._SET_WEAPON_PED_DAMAGE_MODIFIER(weapon, 100.0)
end

function GiveWeaponCommand()
    local modified = false
    local playerPed = PLAYER.PLAYER_PED_ID()
    io.write("Enter weapon model(https://forge.plebmasters.de/weapons): ")
    local modelName = io.read()

    local hash = MISC.GET_HASH_KEY(modelName)

    io.write("Give already the modified? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        modified = true
    end 

    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, hash, 1000, true)
    if modified then
        local tintcount = WEAPON.GET_WEAPON_TINT_COUNT(hash) - 1
        if tintcount then
            WEAPON.SET_PED_WEAPON_COMPONENT_TINT_INDEX(playerPed, hash, hash, math.random(0, tintcount))
        end
        print(tintcount)
    end
end
function GiveAllWeaponsCommand()
    local weapons = JsonReadList("weapons.json")
    local playerPed = PLAYER.PLAYER_PED_ID()

    if weapons ~= nil then
        for weapontype, weaponnames in pairs(weapons) do
            for weaponname, weaponhash in pairs(weaponnames) do
                WEAPON.GIVE_DELAYED_WEAPON_TO_PED(playerPed, tonumber32(weaponhash), 1000, false)
                local tintcount = WEAPON.GET_WEAPON_TINT_COUNT(tonumber32(weaponhash)) - 1
                if tintcount then
                    WEAPON.SET_PED_WEAPON_COMPONENT_TINT_INDEX(playerPed, tonumber32(weaponhash), tonumber32(weaponhash), math.random(0, tintcount))
                end
            end
        end
    end
end
function GiveMaxAmmoCommand()
    local weaponp = New(4)
    local weapon = nil
    local ammop = New(4)

    WEAPON.GET_CURRENT_PED_WEAPON(PLAYER.PLAYER_PED_ID(), weaponp, true)
    weapon = Game.ReadInt(weaponp)

    if WEAPON.GET_MAX_AMMO(PLAYER.PLAYER_PED_ID(), weapon, ammop) then
		WEAPON.SET_PED_AMMO(PLAYER.PLAYER_PED_ID(), weapon, Game.ReadInt(ammop))
    end

    Delete(weaponp)
    Delete(ammop)
end
function GiveAllAmmoCommand()
    local ammop = New(4)

    local weapons = JsonReadList("weapons.json")
    local playerPed = PLAYER.PLAYER_PED_ID()

    if weapons ~= nil then
        for weapontype, weaponnames in pairs(weapons) do
            for weaponname, weaponhash in pairs(weaponnames) do
                if WEAPON.GET_MAX_AMMO(PLAYER.PLAYER_PED_ID(), tonumber32(weaponhash), ammop) then
                    WEAPON.SET_PED_AMMO(PLAYER.PLAYER_PED_ID(), tonumber32(weaponhash), Game.ReadInt(ammop))
                end
            end
        end
    end
    
    Delete(ammop)
end

function SetInfinityAmmoCommand()
    local weaponp = New(4)

    WEAPON.GET_CURRENT_PED_WEAPON(PLAYER.PLAYER_PED_ID(), weaponp, true)

    io.write("Enable an infinite ammunition on weapon currently held by the player? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        WEAPON.SET_PED_INFINITE_AMMO(PLAYER.PLAYER_PED_ID(), true, Game.ReadInt(weaponp))
    elseif input == "n" then
        WEAPON.SET_PED_INFINITE_AMMO(PLAYER.PLAYER_PED_ID(), false, Game.ReadInt(weaponp))
    end 

    Delete(weaponp)
end
function SetInfinityClipCommand()
    io.write("Enable an infinite clip for the weapon currently held by the player? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.PLAYER_PED_ID(), true)
    elseif input == "n" then
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.PLAYER_PED_ID(), false)
    end 
end

function HideWeaponCommand()
    io.write("Do you want to hide the weapon currently held by the player? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        WEAPON.SET_PED_CURRENT_WEAPON_VISIBLE(PLAYER.PLAYER_PED_ID(), false, false, true, true)
    elseif input == "n" then
        WEAPON.SET_PED_CURRENT_WEAPON_VISIBLE(PLAYER.PLAYER_PED_ID(), true, false, true, true)
    end 
    
end

function GetEntityPlayerAimingForCommand()
    local iters = 20
    local entityp = NewPed(0)

    io.write("Enter player ID: ")
    local player = tonumber(io.read())
    

    if player then
        for i = 0, iters, 1 do
            PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(player, entityp)
            if Game.ReadInt(entityp) ~= 0.0 then
                printColoured("green", "The player is aiming at entity " .. Game.ReadInt(entityp))
                Delete(entityp)
                return nil
            end
            Wait(100)
        end

        print("The player is not aiming at anyone")
    end
end

function CreateAirDefenseCommand()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    local airdefense = WEAPON.CREATE_AIR_DEFENCE_SPHERE(coords.x, coords.y, coords.z, 1000.0, 1.0, 1.0, 1.0, 3473446624)
    WEAPON.SET_PLAYER_TARGETTABLE_FOR_AIR_DEFENCE_SPHERE(PLAYER.PLAYER_ID(), airdefense, true)
end

function InitializeSettings()
    local InfinityAmmoWeapon = mathUtils.BooleanToNumber(configUtils.GetFeatureSetting("WeaponOptions", "InfinityAmmoWeapon"))
    local InfinityAmmoClipWeapon = mathUtils.BooleanToNumber(configUtils.GetFeatureSetting("WeaponOptions", "InfinityAmmoClipWeapon"))
    local AlwaysInvisibleWeapon = mathUtils.BooleanToNumber(configUtils.GetFeatureSetting("WeaponOptions", "AlwaysInvisibleWeapon"))

    SetGlobalVariableValue("InfinityAmmoLocalPlayerWeaponState", InfinityAmmoWeapon)
    SetGlobalVariableValue("InfinityAmmoClipLocalPlayerWeaponState", InfinityAmmoClipWeapon)
    SetGlobalVariableValue("AlwaysInvisibleLocalPlayerWeaponState", AlwaysInvisibleWeapon)
end


-- Определим словарь с командами и их функциями
local Commands = {
    ["weapon"] = WeaponCommand,
    ["give weapon"] = GiveWeaponCommand,
    ["give all weapons"] = GiveAllWeaponsCommand,
    ["give max ammo"] = GiveMaxAmmoCommand,
    ["give all ammo"] = GiveAllAmmoCommand,
    ["set infinity ammo"] = SetInfinityAmmoCommand,
    ["set infinity clip"] = SetInfinityClipCommand,
    ["hide weapon"] = HideWeaponCommand,
    ["get entity player aiming for"] = GetEntityPlayerAimingForCommand,
    ["create air defense"] = CreateAirDefenseCommand
}

math.randomseed(os.time())

InitializeSettings()

-- Цикл для регистрации команд
for commandName, commandFunction in pairs(Commands) do
    if not BindCommand(commandName, commandFunction) then
        DisplayError(true, "Failed to register the command: " .. commandName)
    end
end
-- This script defines commands related to weapon management for the player.

-- Global variables accessible to other scripts, used for persistent weapon states.
-- These states are typically loaded from configuration and control features like infinite ammo.
RegisterGlobalVariable("InfinityAmmoLocalPlayerWeaponState", 0.0)
RegisterGlobalVariable("InfinityAmmoClipLocalPlayerWeaponState", 0.0)
RegisterGlobalVariable("AlwaysInvisibleLocalPlayerWeaponState", 0.0)

-- Loading necessary utility modules.
local math_utils = require("math_utils")     -- Module for mathematical utilities.
local config_utils = require("config_utils") -- Module for configuration utilities.

function weapon_command()
end

--- Gives a specified weapon to the player.
-- Prompts the user for a weapon model name and whether to give a modified version.
function give_weapon_command()
    local give_modified = false
    local player_ped = PLAYER.PLAYER_PED_ID()

    -- Prompt for weapon model name.
    local model_name = Input("Enter weapon model(https://forge.plebmasters.de/weapons): ", false)

    -- Get the hash key for the weapon model.
    local weapon_hash = MISC.GET_HASH_KEY(model_name)

    -- Prompt to ask if the weapon should be given in a modified state.
    local input_modified = Input("Give already the modified? [Y/n]: ", true) -- Input(..., true) handles lowercasing

    if input_modified == "y" then
        give_modified = true
    end 

    -- Give the weapon to the player ped.
    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(player_ped, weapon_hash, 1000, true)
    
    -- If modified is requested, apply a random tint.
    if give_modified then
        local tint_count = WEAPON.GET_WEAPON_TINT_COUNT(weapon_hash) - 1
        if tint_count and tint_count >= 0 then -- Ensure tint_count is valid
            WEAPON.SET_PED_WEAPON_COMPONENT_TINT_INDEX(player_ped, weapon_hash, weapon_hash, math.random(0, tint_count))
            
        end
    end
end

--- Gives all weapons defined in "weapons.json" to the player.
-- Iterates through weapon types and names, giving each weapon with a random tint.
function give_all_weapons_command()
    local weapons_data = JsonReadList("weapons.json")
    local player_ped = PLAYER.PLAYER_PED_ID()

    if weapons_data ~= nil then
        for weapon_type, weapon_names in pairs(weapons_data) do
            for weapon_name, weapon_hash_str in pairs(weapon_names) do
                local weapon_hash = tonumber32(weapon_hash_str) -- Convert hash string to number
                WEAPON.GIVE_DELAYED_WEAPON_TO_PED(player_ped, weapon_hash, 1000, false)
                
                local tint_count = WEAPON.GET_WEAPON_TINT_COUNT(weapon_hash) - 1
                if tint_count and tint_count >= 0 then -- Ensure tint_count is valid
                    WEAPON.SET_PED_WEAPON_COMPONENT_TINT_INDEX(player_ped, weapon_hash, weapon_hash, math.random(0, tint_count))
                end
            end
        end
    end
end

--- Gives the maximum possible ammo for the weapon currently held by the player.
function give_max_ammo_command()
    local weapon_ptr = New(4) -- Allocate memory for weapon handle
    local current_weapon_hash = nil
    local ammo_ptr = New(4)   -- Allocate memory for max ammo value

    -- Get the current weapon held by the player.
    WEAPON.GET_CURRENT_PED_WEAPON(PLAYER.PLAYER_PED_ID(), weapon_ptr, true)
    current_weapon_hash = Game.ReadInt(weapon_ptr)

    -- Check if max ammo can be retrieved for the current weapon.
    if WEAPON.GET_MAX_AMMO(PLAYER.PLAYER_PED_ID(), current_weapon_hash, ammo_ptr) then
        -- Set the player's ammo to the maximum amount.
        WEAPON.SET_PED_AMMO(PLAYER.PLAYER_PED_ID(), current_weapon_hash, Game.ReadInt(ammo_ptr))
    end

    -- Free allocated memory.
    Delete(weapon_ptr)
    Delete(ammo_ptr)
end

--- Gives maximum ammo for all weapons defined in "weapons.json" to the player.
function give_all_ammo_command()
    local ammo_ptr = New(4) -- Allocate memory for max ammo value

    local weapons_data = JsonReadList("weapons.json")
    local player_ped = PLAYER.PLAYER_PED_ID()

    if weapons_data ~= nil then
        for weapon_type, weapon_names in pairs(weapons_data) do
            for weapon_name, weapon_hash_str in pairs(weapon_names) do
                local weapon_hash = tonumber32(weapon_hash_str) -- Convert hash string to number
                -- Check if max ammo can be retrieved for the current weapon.
                if WEAPON.GET_MAX_AMMO(player_ped, weapon_hash, ammo_ptr) then
                    -- Set the player's ammo to the maximum amount.
                    WEAPON.SET_PED_AMMO(player_ped, weapon_hash, Game.ReadInt(ammo_ptr))
                end
            end
        end
    end
    
    -- Free allocated memory.
    Delete(ammo_ptr)
end

--- Toggles infinite ammunition for the weapon currently held by the player.
function set_infinity_ammo_command()
    local weapon_ptr = New(4) -- Allocate memory for weapon handle

    if weapon_ptr ~= nil then
       -- Get the current weapon held by the player.
        WEAPON.GET_CURRENT_PED_WEAPON(PLAYER.PLAYER_PED_ID(), weapon_ptr, true)

        -- Prompt for user input to enable or disable infinite ammo.
        local input_toggle = Input("Enable an infinite ammunition on weapon currently held by the player? [Y/n]: ", true)

        if input_toggle == "y" then
            WEAPON.SET_PED_INFINITE_AMMO(PLAYER.PLAYER_PED_ID(), true, Game.ReadInt(weapon_ptr))
        elseif input_toggle == "n" then
            WEAPON.SET_PED_INFINITE_AMMO(PLAYER.PLAYER_PED_ID(), false, Game.ReadInt(weapon_ptr))
        end 

        -- Free allocated memory.
        Delete(weapon_ptr)
    else
        DisplayError(false, "Failed to allocate memory!")
    end
end

--- Toggles infinite clip for the weapon currently held by the player.
function set_infinity_clip_command()
    -- Prompt for user input to enable or disable infinite clip.
    local input_toggle = Input("Enable an infinite clip for the weapon currently held by the player? [Y/n]: ", true)

    if input_toggle == "y" then
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.PLAYER_PED_ID(), true)
    elseif input_toggle == "n" then
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.PLAYER_PED_ID(), false)
    end 
end

--- Toggles visibility of the weapon currently held by the player.
function hide_weapon_command()
    -- Prompt for user input to hide or show the weapon.
    local input_toggle = Input("Do you want to hide the weapon currently held by the player? [Y/n]: ", true)

    if input_toggle == "y" then
        WEAPON.SET_PED_CURRENT_WEAPON_VISIBLE(PLAYER.PLAYER_PED_ID(), false, false, true, true)
    elseif input_toggle == "n" then
        WEAPON.SET_PED_CURRENT_WEAPON_VISIBLE(PLAYER.PLAYER_PED_ID(), true, false, true, true)
    end 
end

--- Gets the entity that the player is currently aiming at.
-- It attempts to find the target multiple times over a short duration.
function get_entity_player_aiming_for_command()
    local iterations = 20
    local entity_ptr = NewPed(0) -- Allocate memory for entity handle, initialized to 0

    -- Prompt for player ID.
    local player_id_input = Input("Enter player ID: ", false)
    local player_id = tonumber(player_id_input)

    if player_id then
        for i = 0, iterations, 1 do
            -- Get the entity the player is aiming at.
            PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(player_id, entity_ptr)
            
            -- If an entity is found (handle is not 0.0).
            if Game.ReadInt(entity_ptr) ~= 0.0 then
                printColoured("green", "The player is aiming at entity " .. Game.ReadInt(entity_ptr))
                Delete(entity_ptr) -- Free memory
                return nil -- Exit function
            end
            Wait(100) -- Wait for 100ms before next iteration
        end

        print("The player is not aiming at anyone")
    else
        DisplayError(false, "Incorrect player ID input.")
    end
    
    -- Ensure memory is freed even if no entity is found or input is incorrect.
    Delete(entity_ptr) 
end

--- Creates an air defense sphere around the player's current coordinates.
function create_air_defense_command()
    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    -- Create the air defense sphere.
    local air_defense = WEAPON.CREATE_AIR_DEFENCE_SPHERE(coords.x, coords.y, coords.z, 1000.0, 1.0, 1.0, 1.0, 3473446624)
    -- Set the player as targetable by the air defense sphere.
    WEAPON.SET_PLAYER_TARGETTABLE_FOR_AIR_DEFENCE_SPHERE(PLAYER.PLAYER_ID(), air_defense, true)
end

--- Initializes weapon-related settings from configuration.
-- This function reads settings from "WeaponOptions" in the config and sets global variables.
function initialize_settings()
    local infinity_ammo_weapon = math_utils.boolean_to_number(config_utils.get_feature_setting("WeaponOptions", "InfinityAmmoWeapon"))
    local infinity_ammo_clip_weapon = math_utils.boolean_to_number(config_utils.get_feature_setting("WeaponOptions", "InfinityAmmoClipWeapon"))
    local always_invisible_weapon = math_utils.boolean_to_number(config_utils.get_feature_setting("WeaponOptions", "AlwaysInvisibleWeapon"))

    SetGlobalVariableValue("InfinityAmmoLocalPlayerWeaponState", infinity_ammo_weapon)
    SetGlobalVariableValue("InfinityAmmoClipLocalPlayerWeaponState", infinity_ammo_clip_weapon)
    SetGlobalVariableValue("AlwaysInvisibleLocalPlayerWeaponState", always_invisible_weapon)
end


-- Define a dictionary with commands and their functions.
local commands = {
    ["weapon"] = weapon_command,
    ["give weapon"] = give_weapon_command,
    ["give all weapons"] = give_all_weapons_command,
    ["give max ammo"] = give_max_ammo_command,
    ["give all ammo"] = give_all_ammo_command,
    ["set infinity ammo"] = set_infinity_ammo_command,
    ["set infinity clip"] = set_infinity_clip_command,
    ["hide weapon"] = hide_weapon_command,
    ["get entity player aiming for"] = get_entity_player_aiming_for_command,
    ["create air defense"] = create_air_defense_command
}

-- Initialize the pseudo-random number generator based on the current time.
-- This ensures different results for math.random each time the script runs.
math.randomseed(os.time())

-- Initialize feature settings upon script load.
initialize_settings()

-- Loop for registering commands.
-- Iterates through all "command name" - "function" pairs in the Commands dictionary.
for command_name, command_function in pairs(commands) do
    -- Registers the command. 'BindCommand' is a custom function of your GCTV API.
    if not BindCommand(command_name, command_function) then
        -- Displays an error message if command registration failed.
        DisplayError(true, "Failed to register the command: " .. command_name)
    end
end

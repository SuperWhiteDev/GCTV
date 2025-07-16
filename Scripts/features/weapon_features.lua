-- This script continuously applies selected weapon features based on global variable states.
-- It runs in a loop as long as the script is active.

-- Main loop for applying weapon features.
while ScriptStillWorking do
    -- Check if "Infinity Ammo" feature is enabled via global variable.
    if IsGlobalVariableExist("InfinityAmmoLocalPlayerWeaponState") and GetGlobalVariable("InfinityAmmoLocalPlayerWeaponState") ~= 0.0 then
        local weapon_ptr = New(4) -- Allocate memory for the current weapon handle

        -- Get the current weapon held by the player.
        WEAPON.GET_CURRENT_PED_WEAPON(PLAYER.PLAYER_PED_ID(), weapon_ptr, true)

        -- Set infinite ammo for the current weapon.
        WEAPON.SET_PED_INFINITE_AMMO(PLAYER.PLAYER_PED_ID(), true, Game.ReadInt(weapon_ptr))

        Delete(weapon_ptr) -- Free allocated memory
    end

    -- Check if "Infinity Clip" feature is enabled via global variable.
    if IsGlobalVariableExist("InfinityAmmoClipLocalPlayerWeaponState") and GetGlobalVariable("InfinityAmmoClipLocalPlayerWeaponState") ~= 0.0 then
        -- Set infinite clip for the player's current weapon.
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.PLAYER_PED_ID(), true)
    end

    -- Check if "Always Invisible Weapon" feature is enabled via global variable.
    if IsGlobalVariableExist("AlwaysInvisibleLocalPlayerWeaponState") and GetGlobalVariable("AlwaysInvisibleLocalPlayerWeaponState") ~= 0.0 then
        -- Make the player's current weapon invisible.
        WEAPON.SET_PED_CURRENT_WEAPON_VISIBLE(PLAYER.PLAYER_PED_ID(), false, false, true, true)
    end

    Wait(500) -- Pause script execution for 500 milliseconds to reduce CPU usage.
end

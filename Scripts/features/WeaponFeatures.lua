while ScriptStillWorking do
    if IsGlobalVariableExist("InfinityAmmoLocalPlayerWeaponState") and GetGlobalVariable("InfinityAmmoLocalPlayerWeaponState") ~= 0.0 then
        local weaponp = New(4)

        WEAPON.GET_CURRENT_PED_WEAPON(PLAYER.PLAYER_PED_ID(), weaponp, true)

        WEAPON.SET_PED_INFINITE_AMMO(PLAYER.PLAYER_PED_ID(), true, Game.ReadInt(weaponp))

        Delete(weaponp)
    end
    if IsGlobalVariableExist("InfinityAmmoClipLocalPlayerWeaponState") and GetGlobalVariable("InfinityAmmoClipLocalPlayerWeaponState") ~= 0.0 then
        WEAPON.SET_PED_INFINITE_AMMO_CLIP(PLAYER.PLAYER_PED_ID(), true)
    end
    if IsGlobalVariableExist("AlwaysInvisibleLocalPlayerWeaponState") and GetGlobalVariable("AlwaysInvisibleLocalPlayerWeaponState") ~= 0.0 then
        WEAPON.SET_PED_CURRENT_WEAPON_VISIBLE(PLAYER.PLAYER_PED_ID(), false, false, true, true)
    end

    Wait(500)
end
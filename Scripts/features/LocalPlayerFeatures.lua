while ScriptStillWorking do
    if IsGlobalVariableExist("AlwaysCleanLocalPlayerState") and GetGlobalVariable("AlwaysCleanLocalPlayerState") ~= 0.0 then
        PED.CLEAR_PED_BLOOD_DAMAGE(PLAYER.PLAYER_PED_ID())
        PED.CLEAR_PED_ENV_DIRT(PLAYER.PLAYER_PED_ID())
        PED.CLEAR_PED_WETNESS(PLAYER.PLAYER_PED_ID())
        PED.RESET_PED_VISIBLE_DAMAGE(PLAYER.PLAYER_PED_ID())
    end
    if IsGlobalVariableExist("EveryoneIgnoreLocalPlayerState") and GetGlobalVariable("EveryoneIgnoreLocalPlayerState") ~= 0.0 then
        PLAYER.SET_EVERYONE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), true)
        PLAYER.CLEAR_PLAYER_WANTED_LEVEL(PLAYER.PLAYER_ID())
        PLAYER.SET_MAX_WANTED_LEVEL(0)
    end
    if IsGlobalVariableExist("NeverWantedLocalPlayerState") and GetGlobalVariable("NeverWantedLocalPlayerState") ~= 0.0 then
        PLAYER.CLEAR_PLAYER_WANTED_LEVEL(PLAYER.PLAYER_ID())
        PLAYER.SET_MAX_WANTED_LEVEL(0)
    end
    if IsGlobalVariableExist("MobileRadioState") and GetGlobalVariable("MobileRadioState") ~= 0.0 then
        AUDIO.SET_MOBILE_RADIO_ENABLED_DURING_GAMEPLAY(true)
        AUDIO.SET_MOBILE_PHONE_RADIO_STATE(true)
    end

    Wait(1000)
end
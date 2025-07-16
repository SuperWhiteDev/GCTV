-- This script continuously applies various features to the local player
-- based on the state of global variables. It runs in a loop as long as the script is active.

-- Main loop for applying local player features.
while ScriptStillWorking do
    -- Feature: Always Clean Player
    -- If "AlwaysCleanLocalPlayerState" global variable exists and is not 0.0,
    -- it continuously cleans the player character from blood, dirt, wetness, and resets visible damage.
    if IsGlobalVariableExist("AlwaysCleanLocalPlayerState") and GetGlobalVariable("AlwaysCleanLocalPlayerState") ~= 0.0 then
        PED.CLEAR_PED_BLOOD_DAMAGE(PLAYER.PLAYER_PED_ID())
        PED.CLEAR_PED_ENV_DIRT(PLAYER.PLAYER_PED_ID())
        PED.CLEAR_PED_WETNESS(PLAYER.PLAYER_PED_ID())
        PED.RESET_PED_VISIBLE_DAMAGE(PLAYER.PLAYER_PED_ID())
    end

    -- Feature: Everyone Ignore Local Player
    -- If "EveryoneIgnoreLocalPlayerState" global variable exists and is not 0.0,
    -- it makes all NPCs ignore the player and clears the player's wanted level.
    if IsGlobalVariableExist("EveryoneIgnoreLocalPlayerState") and GetGlobalVariable("EveryoneIgnoreLocalPlayerState") ~= 0.0 then
        PLAYER.SET_EVERYONE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), true)
        PLAYER.CLEAR_PLAYER_WANTED_LEVEL(PLAYER.PLAYER_ID())
        PLAYER.SET_MAX_WANTED_LEVEL(0) -- Ensures max wanted level is 0.
    end

    -- Feature: Never Wanted
    -- If "NeverWantedLocalPlayerState" global variable exists and is not 0.0,
    -- it continuously clears the player's wanted level and sets the maximum wanted level to 0.
    -- Note: This feature has overlapping functionality with "EveryoneIgnoreLocalPlayerState" regarding wanted level.
    if IsGlobalVariableExist("NeverWantedLocalPlayerState") and GetGlobalVariable("NeverWantedLocalPlayerState") ~= 0.0 then
        PLAYER.CLEAR_PLAYER_WANTED_LEVEL(PLAYER.PLAYER_ID())
        PLAYER.SET_MAX_WANTED_LEVEL(0)
    end

    -- Feature: Mobile Radio
    -- If "MobileRadioState" global variable exists and is not 0.0,
    -- it enables the mobile radio, allowing the player to listen to radio stations via their phone.
    if IsGlobalVariableExist("MobileRadioState") and GetGlobalVariable("MobileRadioState") ~= 0.0 then
        AUDIO.SET_MOBILE_RADIO_ENABLED_DURING_GAMEPLAY(true)
        AUDIO.SET_MOBILE_PHONE_RADIO_STATE(true)
    end

    Wait(1000) -- Pause script execution for 1000 milliseconds (1 second) to reduce CPU usage.
end

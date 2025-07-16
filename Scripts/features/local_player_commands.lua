-- This script defines commands for controlling various aspects of the local player character.

-- Global variables accessible to other scripts, used for persistent player states.
RegisterGlobalVariable("AlwaysCleanLocalPlayerState", 0.0)
RegisterGlobalVariable("EveryoneIgnoreLocalPlayerState", 0.0)
RegisterGlobalVariable("NeverWantedLocalPlayerState", 0.0)
RegisterGlobalVariable("MobileRadioState", 0.0)
RegisterGlobalVariable("LockedRadioStationName", 0.0) -- Original: RegisterGlobalVariableString("LockedRadioStationName", 0.0) - Assuming 0.0 is a placeholder for string.

-- Loading necessary utility modules.
local clothing = require("clothing_enum")   -- Module for clothing enumerations.
local input_utils = require("input_utils") -- Module for input utilities (e.g., InputVehicle).
local math_utils = require("math_utils")   -- Module for mathematical utilities.
local config_utils = require("config_utils") -- Module for configuration utilities.

--- Saves the player's current outfit to a JSON file.
-- Prompts the user for an outfit name and stores all clothing components.
function save_outfit()
    local outfit_data = {}

    -- Prompt for the outfit name.
    local outfit_name = Input("Enter the name of the outfit you want to save: ", false)

    outfit_data["name"] = outfit_name

    -- Iterate through unique clothing components and save their current variations.
    for component_name, component_id in pairs(clothing.UniqueClothingComponents) do
        outfit_data[component_name] = {}
        outfit_data[component_name]["DrawableID"] = PED.GET_PED_DRAWABLE_VARIATION(PLAYER.PLAYER_PED_ID(), component_id)
        outfit_data[component_name]["TextureID"] = PED.GET_PED_TEXTURE_VARIATION(PLAYER.PLAYER_PED_ID(), component_id)
        outfit_data[component_name]["PaletteID"] = PED.GET_PED_PALETTE_VARIATION(PLAYER.PLAYER_PED_ID(), component_id)
    end

    -- Read existing outfits, or initialize an empty table if file doesn't exist.
    local outfit_list = JsonReadList("saved_outfits.json") or {}
    table.insert(outfit_list, outfit_data) -- Add the new outfit.

    JsonSaveList("saved_outfits.json", outfit_list) -- Save the updated list.

    printColoured("green", "The outfit has been successfully saved.")
end

--- Displays a help menu for player-related commands.
function player_command()
    print("1. Outfit - Can be used to modify the player's current clothes or select ready-made outfits.")
    print("2. Save Outfit - Save the player's current outfit.")
    print("3. Clone Player - Creates a clone of the current player.")
    print("4. Clean Player - Cleans the current player of dirt.")
    print("5. Suicide - Instantly kills the local player.")
    print("6. Never Wanted - Disables getting wanted stars for the player.")
    print("7. Set Player Wanted - Sets the current wanted level for the player.")
    print("8. Set Player Invincible - Makes the player invincible.")
    print("9. Set Player Seatbelt - Prevents falling out of glass and falling out of motorbikes for the player.")
    print("10. Enter in Veh - Instantly moves the player into a specified vehicle.")
    print("11. Mobile Radio - Allows you to turn on the radio in the local player character's phone.")
    print("12. Next Radio Track - Allows you to switch to the next radio track.")
    print("13. Lock Radio Station - Blocks any change in the car radio and mobile radio.")
    print("14. Set Radio Track - Allows you to switch on a specific radio track.")
    print("15. Lock Radio Track - Allows you to block playback changes to another track.")
end

--- Applies a predefined or custom outfit to the local player.
-- Options include "Santa", "Cop", "Saved outfit", or "Custom" (for individual components).
function outfit_command()
    local outfit_options = { "Santa", "Cop", "Saved outfit", "Custom" }

    local selected_option_index = InputFromList("Enter the desired outfit or enter custom to create your own outfit: ", outfit_options)

    if selected_option_index == 0 then -- Santa outfit
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.HATS, 22, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.MASKS, 8, 0, 0) 
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.TOPS, 19, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.LEGS, 18, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.SHOES, 7, 0, 0)
    elseif selected_option_index == 1 then -- Cop outfit
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.GLASSES, 0, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.TOPS, 48, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.TORSOS, 22, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.UNDERSHIRTS, 35, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.LEGS, 34, 0, 0)
        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), clothing.ClothingComponents.SHOES, 25, 0, 0)
    elseif selected_option_index == 2 then -- Saved outfit
        local loaded_outfit = nil
        local outfit_list = JsonReadList("saved_outfits.json")

        if not outfit_list or #outfit_list == 0 then
            print("No saved outfits found.")
            return nil
        end

        local saved_outfit_names = {}
        for _, outfit in ipairs(outfit_list) do
            table.insert(saved_outfit_names, outfit.name)
        end
        
        local selected_outfit_id = InputFromList("Enter which outfit you want to apply: ", saved_outfit_names)

        if selected_outfit_id ~= -1 then
            loaded_outfit = outfit_list[selected_outfit_id + 1] -- +1 for Lua 1-indexing
        else
            return nil -- User cancelled
        end

        if loaded_outfit == nil then
            DisplayError(false, "Outfit not found.")
            return nil
        end

        -- Create a mapping from string names to numeric component IDs.
        local clothing_components_map = {}
        for k, v in pairs(clothing.ClothingComponents) do
            clothing_components_map[k] = v
        end

        -- Apply each component from the saved outfit.
        for component_name_key, component_data in pairs(loaded_outfit) do
            -- Skip the 'name' field.
            if component_name_key ~= "name" then
                local component_id = clothing_components_map[component_name_key]
                if component_id then
                    PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), component_id, component_data["DrawableID"], component_data["TextureID"], component_data["PaletteID"])
                else
                    print("Warning: Unknown clothing component in saved outfit: " .. component_name_key)
                end
            end
        end
        printColoured("green", "Outfit '" .. loaded_outfit.name .. "' applied successfully.")
    elseif selected_option_index == 3 then -- Custom outfit (individual components)
        local component_display_names = {}
        local component_ids_list = {}

        -- Populate lists for InputFromList.
        for component_name_key, component_id_val in pairs(clothing.ClothingComponents) do
            -- Replace underscores with spaces for display.
            component_display_names[#component_display_names + 1] = string.gsub(component_name_key, "_", " ")
            component_ids_list[#component_ids_list + 1] = component_id_val
        end

        local selected_component_index = InputFromList("Enter the type of clothing: ", component_display_names)
        if selected_component_index == -1 then return nil end -- User cancelled

        local component_id_to_set = component_ids_list[selected_component_index + 1]

        local drawable_id_str = Input("Enter the drawable ID of the clothes (https://wiki.rage.mp/index.php?title=Clothes): ", false)
        local drawable_id = tonumber(drawable_id_str)
        if not drawable_id then DisplayError(false, "Incorrect drawable ID input."); return nil end

        local texture_id_str = Input("Enter the texture ID of the clothes (https://forge.plebmasters.de/clothes?p=4): ", false)
        local texture_id = tonumber(texture_id_str)
        if not texture_id then DisplayError(false, "Incorrect texture ID input."); return nil end

        PED.SET_PED_COMPONENT_VARIATION(PLAYER.PLAYER_PED_ID(), component_id_to_set, drawable_id, texture_id, 0)
        printColoured("green", "Clothing component updated.")
    end
end

--- Command to save the player's current outfit.
-- Calls the `save_outfit` function.
function save_outfit_command()
    if PLAYER.PLAYER_PED_ID() == 0.0 then
        DisplayError(false, "Failed to get current player handle.")
        return nil
    end
    save_outfit()
end

--- Command to create a clone of the local player.
function clone_player_command()
    local cloned_ped = PED.CLONE_PED(PLAYER.PLAYER_PED_ID(), true, true, true)
    if cloned_ped ~= 0.0 then
        print("Cloned ped handle is " .. cloned_ped)
    else
        DisplayError(false, "Failed to clone player.")
    end
end

--- Command to clean the local player character (remove blood, dirt, wetness).
function clean_player_command()
    PED.CLEAR_PED_BLOOD_DAMAGE(PLAYER.PLAYER_PED_ID())
    PED.CLEAR_PED_ENV_DIRT(PLAYER.PLAYER_PED_ID())
    PED.CLEAR_PED_WETNESS(PLAYER.PLAYER_PED_ID())
    PED.RESET_PED_VISIBLE_DAMAGE(PLAYER.PLAYER_PED_ID())
    print("Player character cleaned.")
end

--- Command to instantly kill the local player.
function suicide_command()
    ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), 0, PLAYER.PLAYER_PED_ID(), 0)
    print("Suicide executed.")
end

--- Toggles the "Never Wanted" status for the local player.
-- Prevents the player from gaining wanted stars.
function never_wanted_command()
    local input_toggle = Input("Disable wanted for local player? [Y/n]: ", true)

    if input_toggle == "y" then
        PLAYER.CLEAR_PLAYER_WANTED_LEVEL(PLAYER.PLAYER_ID())
        PLAYER.SET_MAX_WANTED_LEVEL(0)
        print("Never Wanted mode enabled.")
    elseif input_toggle == "n" then
        PLAYER.SET_MAX_WANTED_LEVEL(5) -- Restore max wanted level to 5.
        print("Never Wanted mode disabled.")
    end 
end

--- Sets the wanted level for the local player.
-- Prompts for a desired wanted level (0-5).
function set_player_wanted_level_command()
    local wanted_level_str = Input("Enter the desired wanted level (0-5): ", false)
    local wanted_level = tonumber(wanted_level_str)

    if wanted_level and wanted_level >= 0 and wanted_level <= 5 then -- Validate input range
        PLAYER.SET_PLAYER_WANTED_LEVEL(PLAYER.PLAYER_ID(), wanted_level, false)
        PLAYER.SET_PLAYER_WANTED_LEVEL_NOW(PLAYER.PLAYER_ID(), false) -- Apply immediately.
        print("Wanted level set to: " .. wanted_level)
    else
        DisplayError(false, "Incorrect input: Please enter a number between 0 and 5.")
    end
end

--- Toggles invincibility for the local player.
function set_player_invincible_command()
    local input_toggle = Input("Set local player invincible? [Y/n]: ", true)

    if input_toggle == "y" then
        ENTITY.SET_ENTITY_INVINCIBLE(PLAYER.PLAYER_PED_ID(), true)
        print("Player is now invincible.")
    elseif input_toggle == "n" then
        ENTITY.SET_ENTITY_INVINCIBLE(PLAYER.PLAYER_PED_ID(), false)
        print("Player is no longer invincible.")
    end 
end

--- Toggles the player's seatbelt status.
-- Prevents the player from being thrown out of vehicles (including motorbikes).
function set_player_seat_belt_command()
    local input_toggle = Input("Do you want to disable the player being thrown out of the vehicles? [Y/n]: ", true)

    if input_toggle == "y" then
        PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(PLAYER.PLAYER_PED_ID(), 1) -- 1 means "never be knocked off"
        PED.SET_PED_CONFIG_FLAG(PLAYER.PLAYER_PED_ID(), 32, false) -- Flag 32 is "CanBeDraggedOutOfVehicle"
        print("Player seatbelt enabled (cannot be thrown out).")
    elseif input_toggle == "n" then
        PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(PLAYER.PLAYER_PED_ID(), 0) -- 0 means "can be knocked off normally"
        PED.SET_PED_CONFIG_FLAG(PLAYER.PLAYER_PED_ID(), 32, true) -- Re-enable "CanBeDraggedOutOfVehicle"
        print("Player seatbelt disabled (can be thrown out).")
    end
end

--- Instantly moves the local player into a specified vehicle and seat.
-- Prompts for a vehicle handle and a desired seat.
function enter_in_veh_command()
    local target_vehicle = input_utils.input_vehicle() -- Assuming InputVehicle prompts for handle and returns it.

    if target_vehicle and target_vehicle ~= 0.0 then -- Validate vehicle handle
        local seat_options = { "Driver seat", "Available passenger seat", "Custom" }
        local selected_seat_index = InputFromList("Choose where you want to seat the local player: ", seat_options)

        if selected_seat_index == 0 then -- Driver seat
            local current_driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(target_vehicle, -1, true)
            if current_driver ~= 0.0 then
                PED.SET_PED_INTO_VEHICLE(current_driver, target_vehicle, -2) -- Move current driver to passenger.
            end
            PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), target_vehicle, -1) -- Move player to driver seat.
        elseif selected_seat_index == 1 then -- Available passenger seat
            PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), target_vehicle, -2) -- -2 means first available passenger seat.
        elseif selected_seat_index == 2 then -- Custom seat
            local seat_index_str = Input("Enter the seat index: ", false)
            local seat_index = tonumber(seat_index_str)
            
            if seat_index then
                local current_passenger = VEHICLE.GET_PED_IN_VEHICLE_SEAT(target_vehicle, seat_index, true)
                if current_passenger ~= 0.0 then
                    PED.SET_PED_INTO_VEHICLE(current_passenger, target_vehicle, -2) -- Move current passenger to another seat.
                end
                PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), target_vehicle, seat_index)
            else
                DisplayError(false, "Incorrect seat index input.")
            end
        end
        print("Player entered vehicle " .. target_vehicle .. ".")
    else
        DisplayError(false, "Invalid vehicle input or vehicle not found.")
    end
end

--- Toggles the mobile radio for the local player.
-- Allows playing radio stations through the player's phone.
function mobile_radio_command()
    local input_toggle = Input("Enable mobile radio? [Y/n]: ", true)

    if input_toggle == "y" then
        AUDIO.SET_MOBILE_RADIO_ENABLED_DURING_GAMEPLAY(true)
        AUDIO.SET_MOBILE_PHONE_RADIO_STATE(true)
        print("Mobile radio enabled.")
    elseif input_toggle == "n" then
        AUDIO.SET_MOBILE_RADIO_ENABLED_DURING_GAMEPLAY(false)
        AUDIO.SET_MOBILE_PHONE_RADIO_STATE(false)
        print("Mobile radio disabled.")
    end
end

--- Switches to the next radio track.
function next_radio_track_command()
    AUDIO.SKIP_RADIO_FORWARD()
    print("Skipped to next radio track.")
end

--- Placeholder function for locking the radio station.
-- This function is currently empty and needs implementation.
function lock_radio_station_command()
    -- TODO: Implement logic to lock the current radio station, preventing changes.
    print("Lock radio station command - Not yet implemented.")
end

--- Placeholder function for setting a specific radio track.
-- This function is currently incomplete and needs implementation.
-- It attempts to use AUDIO.SET_RADIO_TRACK() and AUDIO.GET_CURRENT_TRACK_SOUND_NAME().
function set_radio_track_command()
    -- AUDIO.SET_RADIO_TRACK() -- This function call is incomplete, requires parameters.
    -- AUDIO.GET_CURRENT_TRACK_SOUND_NAME(radiostation) -- 'radiostation' variable is undefined.
    -- TODO: Implement logic to select and set a specific radio track.
    print("Set radio track command - Not yet fully implemented.")
end

--- Placeholder function for locking the radio track playback.
-- This function is currently empty and needs implementation.
function lock_radio_track_command()
    -- TODO: Implement logic to prevent the current radio track from changing.
    print("Lock radio track command - Not yet implemented.")
end

--- Initializes local player settings from configuration.
-- Reads settings like AlwaysClean, EveryoneIgnore, NeverWanted, MobileRadio, and LockedRadioStation.
function initialize_settings()
    local always_clean_player = math_utils.boolean_to_number(config_utils.get_feature_setting("LocalPlayerOptions", "AlwaysCleanPlayer"))
    local everyone_ignore = math_utils.boolean_to_number(config_utils.get_feature_setting("LocalPlayerOptions", "EveryoneIgnore"))
    local never_wanted = math_utils.boolean_to_number(config_utils.get_feature_setting("LocalPlayerOptions", "NeverWanted"))
    local mobile_radio = math_utils.boolean_to_number(config_utils.get_feature_setting("LocalPlayerOptions", "MobileRadio"))
    local locked_radio_station = config_utils.get_feature_setting("LocalPlayerOptions", "LockedRadioStation") -- This is a string.

    SetGlobalVariableValue("AlwaysCleanLocalPlayerState", always_clean_player)
    SetGlobalVariableValue("EveryoneIgnoreLocalPlayerState", everyone_ignore)
    SetGlobalVariableValue("NeverWantedLocalPlayerState", never_wanted)
    SetGlobalVariableValue("MobileRadioState", mobile_radio)
    -- Original: SetGlobalVariableValue("LockedRadioStationName", LockedRadioStation)
    -- This line was commented out in the original. If "LockedRadioStationName" is intended to be a string,
    -- it should be registered with RegisterGlobalVariableString and then set here.
    -- If it's a number (0.0), then it's currently unused.
    -- Assuming it's meant to be a string for a station name.
    -- If you want to use it, ensure it's registered as a string global.
end

-- Define a dictionary with commands and their corresponding functions.
local commands = {
    ["player"] = player_command,
    ["outfit"] = outfit_command,
    ["save outfit"] = save_outfit_command,
    ["clone player"] = clone_player_command,
    ["clean player"] = clean_player_command,
    ["suicide"] = suicide_command,
    ["never wanted"] = never_wanted_command,
    ["set player wanted"] = set_player_wanted_level_command,
    ["set player invincible"] = set_player_invincible_command,
    ["set player seatbelt"] = set_player_seat_belt_command,
    ["enter in veh"] = enter_in_veh_command,
    ["mobile radio"] = mobile_radio_command,
    ["next radio track"] = next_radio_track_command,
    ["lock radio station"] = lock_radio_station_command,
    ["set radio track"] = set_radio_track_command,
    ["lock radio track"] = lock_radio_track_command,
}

-- Initialize the pseudo-random number generator based on the current time.
-- This ensures different results for math.random each time the script runs.
math.randomseed(os.time())

-- Initialize feature settings upon script load.
initialize_settings()

-- Loop for registering commands.
-- Iterates through all "command name" - "function" pairs in the 'commands' dictionary.
for command_name, command_function in pairs(commands) do
    -- Registers the command. 'BindCommand' is a custom function of your GCTV API.
    if not BindCommand(command_name, command_function) then
        -- Displays an error message if command registration failed.
        DisplayError(true, "Failed to register the command: " .. command_name)
    end
end

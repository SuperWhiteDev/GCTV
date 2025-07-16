-- This script defines a comprehensive set of commands for interacting with and modifying vehicles in GTA V.
-- It includes features for vehicle spawning, tuning, saving/loading, remote control, and various other utilities.

-- Global variables accessible to other scripts, used for persistent vehicle states.
RegisterGlobalVariable("AutoFixCurrentVehicleState", 0.0)      -- 0.0 for inactive, 1.0 for active.
RegisterGlobalVariable("DisableLockOnCurrentVehicleState", 0.0) -- 0.0 for inactive, 1.0 for active.
RegisterGlobalVariable("DynamicNeonVehicle", 0.0)               -- Stores vehicle handle for dynamic neon (0.0 if inactive).
RegisterGlobalVariable("DynamicColorVehicle", 0.0)              -- Stores vehicle handle for dynamic paint color (0.0 if inactive).
RegisterGlobalVariable("RemoteControlVehicle", 0.0)             -- Stores vehicle handle for remote control (0.0 if inactive).

-- Loading necessary utility and enumeration modules.
local vehicle_enums = require("vehicle_enums")     -- Enumerations for vehicle models.
local blip_enums = require("blip_enums")           -- Enumerations for blip sprites and colors.
local radio_stations = require("radio_stations")   -- Enumerations for radio station hashes.

local input_utils = require("input_utils")         -- Module for input utilities (e.g., InputFromList, InputVehicle).
local network_utils = require("network_utils")     -- Module for network utilities (e.g., request_control_of).
local map_utils = require("map_utils")             -- Module for map-related utilities.
local math_utils = require("math_utils")           -- Module for mathematical utilities.
local vehicle_utils = require("vehicle_utils")     -- Module for vehicle-specific utilities.
local mission_utils = require("mission_utils")     -- Module for mission-related utilities.
local config_utils = require("config_utils")       -- Module for configuration utilities.

-- Hotkey variables for "View All Vehicles" command, initialized later from config.
local view_all_vehicles_next_key = nil
local view_all_vehicles_back_key = nil
local view_all_vehicles_select_key = nil

-- Tables to manage created and modified vehicles.
local created_vehicle_models = {} -- Stores model names of created vehicles.
local created_vehicle_ids = {}    -- Stores entity IDs of created vehicles.
local modified_vehicle_models = {} -- Stores model names of vehicles marked as modified.
local modified_vehicle_data = {}   -- Stores custom data for modified vehicles (e.g., engine sound).
local modified_vehicle_ids = {}    -- Stores entity IDs of vehicles marked as modified.

-- Variables for the "View All Vehicles" command's internal state.
local view_all_vehicles_list = JsonReadList("vehicles.json") or {} -- List of available vehicles from JSON.
local view_all_vehicles_list_vehicle_index = 1 -- Current index in the list for viewing.
local view_all_vehicles_current_vehicle = nil  -- Handle of the vehicle currently being viewed.
local is_viewing_all_vehicles = false          -- Flag indicating if the viewing mode is active.
local view_all_vehicles_camera = nil           -- Camera object used for viewing vehicles.

-- Variable for particle effects (e.g., for tuning visual feedback).
local particle_fx_handle = 0.0 -- Handle for a looped particle effect.

--- Creates a particle effect visual feedback for vehicle tuning.
-- This effect is typically displayed when a vehicle is being modified.
-- @param vehicle_handle number The handle of the vehicle to attach the effect to.
-- @param scale_factor number The scale of the particle effect.
function create_tuning_fx(vehicle_handle, scale_factor)
    -- Request the particle effect asset.
    STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2")

    -- If a previous looped particle effect exists, stop and remove it.
    if GRAPHICS.DOES_PARTICLE_FX_LOOPED_EXIST(particle_fx_handle) then
        GRAPHICS.STOP_PARTICLE_FX_LOOPED(particle_fx_handle, false)
        -- Note: REMOVE_PARTICLE_FX is for non-looped effects. STOP_PARTICLE_FX_LOOPED is correct for looped.
    end

    -- Use the loaded particle effect asset.
    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry2")

    -- Start a networked looped particle effect attached to the vehicle.
    -- This ensures other players see the effect in multiplayer.
    particle_fx_handle = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY("scr_clown_appears", vehicle_handle, 0.0, 0.0, -0.5, 0.0, 0.0, 0.0, scale_factor, false, false, false, 1.0, 0.0, 0.0, 1.0)

    -- Fallback to a local (non-networked) particle effect if the networked one fails.
    if particle_fx_handle == 0.0 then
        -- Re-request and use asset in case it was unloaded.
        STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2")
        GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry2")
        particle_fx_handle = GRAPHICS.START_PARTICLE_FX_LOOPED_ON_ENTITY("scr_clown_appears", vehicle_handle, 0.0, 0.0, -0.5, 0.0, 0.0, 0.0, scale_factor, false, false, false)
    end

    -- Original commented out lines for setting particle evolution (kept as is).
    -- GRAPHICS.SET_PARTICLE_FX_LOOPED_EVOLUTION(particle_fx_handle, "flow", 1.0, false)
    -- GRAPHICS.SET_PARTICLE_FX_LOOPED_EVOLUTION(particle_fx_handle, "damage", 1.0, false)
end

--- Marks a vehicle as "modified" in internal tracking tables.
-- This is used to store and retrieve custom modifications like engine sounds.
-- @param vehicle_handle number The handle of the vehicle to mark.
function mark_vehicle_as_modified(vehicle_handle)
    local found_in_list = false

    -- Check if the vehicle is already marked as modified.
    for i = 1, #modified_vehicle_ids do
        if modified_vehicle_ids[i] == vehicle_handle then
            found_in_list = true
            break
        end
    end

    -- If not already marked, add it to the tracking tables.
    if not found_in_list then
        table.insert(modified_vehicle_models, vehicle_utils.get_vehicle_model_name(ENTITY.GET_ENTITY_MODEL(vehicle_handle)))
        modified_vehicle_data[vehicle_handle] = {} -- Initialize data table for this vehicle.
        table.insert(modified_vehicle_ids, vehicle_handle)
    end
end

--- Checks if a vehicle is currently marked as modified.
-- @param vehicle_handle number The handle of the vehicle to check.
-- @returns boolean True if the vehicle is marked, false otherwise.
function is_vehicle_marked_as_modified(vehicle_handle)
    for i = 1, #modified_vehicle_ids do
        if modified_vehicle_ids[i] == vehicle_handle then
            return true
        end
    end
    return false
end

--- Applies maximum tuning to a specified vehicle.
-- This includes setting random window tint, applying all available mods,
-- setting bulletproof tires, custom license plate, and random neon/tire smoke colors.
-- @param vehicle_handle number The handle of the vehicle to tune.
function apply_vehicle_max_tuning(vehicle_handle)
    create_tuning_fx(vehicle_handle, 2.0) -- Show a visual effect during tuning.

    VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle_handle, math.random(0, 6)) -- Random window tint.
    VEHICLE.SET_VEHICLE_MOD_KIT(vehicle_handle, 0) -- Apply default mod kit.

    -- Iterate through common mod types (0 to 30) to apply random mods.
    for i = 0, 30 do
        -- Skip specific mod types (17 to 24) as per original logic.
        if not (i >= 17 and i <= 24) then
            local mods_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, i) - 1 -- Get max index for mods.
            if mods_count >= 0 then -- Check if there are any mods available for this type.
                VEHICLE.SET_VEHICLE_MOD(vehicle_handle, i, math.random(0, mods_count), 0)
            end
        end
    end

    -- Apply livery mod (type 48).
    local livery_mods_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, 48) - 1
    if livery_mods_count >= 0 then -- Check if liveries are available.
        VEHICLE.SET_VEHICLE_MOD(vehicle_handle, 48, math.random(0, livery_mods_count), 0)
    end

    -- Toggle specific vehicle mods (e.g., custom tires, armor).
    VEHICLE.TOGGLE_VEHICLE_MOD(vehicle_handle, 20, true) -- Toggle mod type 20 (likely custom tires).
    VEHICLE.TOGGLE_VEHICLE_MOD(vehicle_handle, 22, true) -- Toggle mod type 22 (likely armor).

    -- Set bulletproof tires and unbreakable wheels.
    VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle_handle, false)
    VEHICLE.SET_VEHICLE_WHEELS_CAN_BREAK(vehicle_handle, false)

    -- Set custom license plate.
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle_handle, "PRIVATE")
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle_handle, math.random(0, 5)) -- Random plate style.
    
    -- Enable all neon lights and set a random color.
    VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 0, true) -- Left
    VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 1, true) -- Right
    VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 2, true) -- Front
    VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 3, true) -- Back
    VEHICLE.SET_VEHICLE_NEON_COLOUR(vehicle_handle, math.random(0, 255), math.random(0, 255), math.random(0, 255))

    -- Set a random tire smoke color.
    VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(vehicle_handle, math.random(0, 255), math.random(0, 255), math.random(0, 255))

    -- Set a random xenon light color.
    VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle_handle, math.random(0, 13))
end

--- Saves the current state and modifications of a vehicle to a JSON file.
-- Prompts the user for a vehicle name.
-- @param vehicle_handle number The handle of the vehicle to save.
function save_vehicle(vehicle_handle)
    local vehicle_name = Input("Enter the name of the vehicle you want to save: ", false)

    local vehicle_data = {} -- Table to store all vehicle data.

    vehicle_data["name"] = vehicle_name
    vehicle_data["model"] = tonumber32(ENTITY.GET_ENTITY_MODEL(vehicle_handle)) -- Save model hash.
    vehicle_data["modelName"] = vehicle_utils.get_vehicle_model_name(vehicle_data["model"]) -- Save readable model name.

    network_utils.request_control_of(vehicle_handle) -- Request network control to ensure data consistency.

    -- Retrieve and save vehicle modifications (mods).
    for i = 0, 24 do -- Iterate through common mod types.
        local is_toggleable_mod = (i >= 17 and i <= 22) -- Check if it's a toggleable mod.
        if is_toggleable_mod then
            vehicle_data["mod" .. i] = VEHICLE.IS_TOGGLE_MOD_ON(vehicle_handle, i) and 1 or 0 -- Save 1 for on, 0 for off.
        else
            vehicle_data["mod" .. i] = VEHICLE.GET_VEHICLE_MOD(vehicle_handle, i) -- Save mod index.
        end
    end

    -- Retrieve and save vehicle colors.
    local primary_color_ptr = New(4)   -- Pointer for primary color.
    local secondary_color_ptr = New(4) -- Pointer for secondary color.
    VEHICLE.GET_VEHICLE_COLOURS(vehicle_handle, primary_color_ptr, secondary_color_ptr)
    vehicle_data["primaryColor"] = Game.ReadInt(primary_color_ptr)
    vehicle_data["secondaryColor"] = Game.ReadInt(secondary_color_ptr)
    Delete(primary_color_ptr)
    Delete(secondary_color_ptr)

    local pearl_color_ptr = New(4) -- Pointer for pearl color.
    local wheel_color_ptr = New(4) -- Pointer for wheel color.
    VEHICLE.GET_VEHICLE_EXTRA_COLOURS(vehicle_handle, pearl_color_ptr, wheel_color_ptr)
    vehicle_data["pearlColor"] = Game.ReadInt(pearl_color_ptr)
    vehicle_data["wheelColor"] = Game.ReadInt(wheel_color_ptr)
    Delete(pearl_color_ptr)
    Delete(wheel_color_ptr)

    -- Retrieve and save mod colors (color 1 and color 2).
    local mod_color1_a_ptr = New(4)
    local mod_color1_b_ptr = New(4)
    local mod_color1_c_ptr = New(4)
    VEHICLE.GET_VEHICLE_MOD_COLOR_1(vehicle_handle, mod_color1_a_ptr, mod_color1_b_ptr, mod_color1_c_ptr)
    vehicle_data["modColor1A"] = Game.ReadInt(mod_color1_a_ptr)
    vehicle_data["modColor1B"] = Game.ReadInt(mod_color1_b_ptr)
    vehicle_data["modColor1C"] = Game.ReadInt(mod_color1_c_ptr)
    Delete(mod_color1_a_ptr)
    Delete(mod_color1_b_ptr)
    Delete(mod_color1_c_ptr)

    local mod_color2_a_ptr = New(4)
    local mod_color2_b_ptr = New(4)
    VEHICLE.GET_VEHICLE_MOD_COLOR_2(vehicle_handle, mod_color2_a_ptr, mod_color2_b_ptr)
    vehicle_data["modColor2A"] = Game.ReadInt(mod_color2_a_ptr)
    vehicle_data["modColor2B"] = Game.ReadInt(mod_color2_b_ptr)
    Delete(mod_color2_a_ptr)
    Delete(mod_color2_b_ptr)

    -- Save custom RGB primary color if it's set.
    if VEHICLE.GET_IS_VEHICLE_PRIMARY_COLOUR_CUSTOM(vehicle_handle) then
        local custom_primary_r_ptr = New(4)
        local custom_primary_g_ptr = New(4)
        local custom_primary_b_ptr = New(4)
        VEHICLE.GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle_handle, custom_primary_r_ptr, custom_primary_g_ptr, custom_primary_b_ptr)
        vehicle_data["customPrimaryR"] = Game.ReadInt(custom_primary_r_ptr)
        vehicle_data["customPrimaryG"] = Game.ReadInt(custom_primary_g_ptr)
        vehicle_data["customPrimaryB"] = Game.ReadInt(custom_primary_b_ptr)
        Delete(custom_primary_r_ptr)
        Delete(custom_primary_g_ptr)
        Delete(custom_primary_b_ptr)
    end

    -- Save custom RGB secondary color if it's set.
    if VEHICLE.GET_IS_VEHICLE_SECONDARY_COLOUR_CUSTOM(vehicle_handle) then
        local custom_secondary_r_ptr = New(4)
        local custom_secondary_g_ptr = New(4)
        local custom_secondary_b_ptr = New(4)
        VEHICLE.GET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle_handle, custom_secondary_r_ptr, custom_secondary_g_ptr, custom_secondary_b_ptr)
        vehicle_data["customSecondaryR"] = Game.ReadInt(custom_secondary_r_ptr)
        vehicle_data["customSecondaryG"] = Game.ReadInt(custom_secondary_g_ptr)
        vehicle_data["customSecondaryB"] = Game.ReadInt(custom_secondary_b_ptr)
        Delete(custom_secondary_r_ptr)
        Delete(custom_secondary_g_ptr)
        Delete(custom_secondary_b_ptr)
    end

    -- Save various other vehicle properties.
    vehicle_data["livery"] = VEHICLE.GET_VEHICLE_MOD(vehicle_handle, 48) -- Livery mod index.
    vehicle_data["livery2"] = VEHICLE.GET_VEHICLE_LIVERY2(vehicle_handle) -- Secondary livery.
    vehicle_data["windowsTint"] = VEHICLE.GET_VEHICLE_WINDOW_TINT(vehicle_handle)
    vehicle_data["plateText"] = VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT(vehicle_handle)
    vehicle_data["plateTextIndex"] = VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle_handle)
    vehicle_data["dirtLevel"] = VEHICLE.GET_VEHICLE_DIRT_LEVEL(vehicle_handle)
    vehicle_data["paintFade"] = VEHICLE.GET_VEHICLE_ENVEFF_SCALE(vehicle_handle)
    vehicle_data["xenonColorIndex"] = VEHICLE.GET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle_handle)
    vehicle_data["bulletproofTyres"] = not VEHICLE.GET_VEHICLE_TYRES_CAN_BURST(vehicle_handle) -- Invert: true if cannot burst.

    -- Retrieve and save neon light enabled states and color.
    vehicle_data["neonEnabledLeft"] = VEHICLE.GET_VEHICLE_NEON_ENABLED(vehicle_handle, 0)
    vehicle_data["neonEnabledRight"] = VEHICLE.GET_VEHICLE_NEON_ENABLED(vehicle_handle, 1)
    vehicle_data["neonEnabledFront"] = VEHICLE.GET_VEHICLE_NEON_ENABLED(vehicle_handle, 2)
    vehicle_data["neonEnabledBack"] = VEHICLE.GET_VEHICLE_NEON_ENABLED(vehicle_handle, 3)

    local neon_r_ptr = New(4)
    local neon_g_ptr = New(4)
    local neon_b_ptr = New(4)
    VEHICLE.GET_VEHICLE_NEON_COLOUR(vehicle_handle, neon_r_ptr, neon_g_ptr, neon_b_ptr)
    vehicle_data["neonR"] = Game.ReadInt(neon_r_ptr)
    vehicle_data["neonG"] = Game.ReadInt(neon_g_ptr)
    vehicle_data["neonB"] = Game.ReadInt(neon_b_ptr)
    Delete(neon_r_ptr)
    Delete(neon_g_ptr)
    Delete(neon_b_ptr)

    -- Retrieve and save tire smoke color.
    local tyre_smoke_r_ptr = New(4)
    local tyre_smoke_g_ptr = New(4)
    local tyre_smoke_b_ptr = New(4)
    VEHICLE.GET_VEHICLE_TYRE_SMOKE_COLOR(vehicle_handle, tyre_smoke_r_ptr, tyre_smoke_g_ptr, tyre_smoke_b_ptr)
    vehicle_data["tyreSmokeR"] = Game.ReadInt(tyre_smoke_r_ptr)
    vehicle_data["tyreSmokeG"] = Game.ReadInt(tyre_smoke_g_ptr)
    vehicle_data["tyreSmokeB"] = Game.ReadInt(tyre_smoke_b_ptr)
    Delete(tyre_smoke_r_ptr)
    Delete(tyre_smoke_g_ptr)
    Delete(tyre_smoke_b_ptr)

    -- Save roof state for convertibles.
    if VEHICLE.IS_VEHICLE_A_CONVERTIBLE(vehicle_handle, false) then
        vehicle_data["roofState"] = VEHICLE.GET_CONVERTIBLE_ROOF_STATE(vehicle_handle)
    end

    -- Retrieve and save extra parts and their states.
    for i = 1, 10 do -- Extras typically range from 1 to 10.
        if VEHICLE.DOES_EXTRA_EXIST(vehicle_handle, i) then
            vehicle_data["extra" .. i] = VEHICLE.IS_VEHICLE_EXTRA_TURNED_ON(vehicle_handle, i)
        end
    end

    -- Save custom engine sound if the vehicle was marked as modified.
    if is_vehicle_marked_as_modified(vehicle_handle) then
        vehicle_data["isModed"] = true
        if modified_vehicle_data[vehicle_handle] and modified_vehicle_data[vehicle_handle].EngineSound ~= nil then
            vehicle_data["engineSound"] = modified_vehicle_data[vehicle_handle].EngineSound
        end
    else
        vehicle_data["isModed"] = false
    end

    -- Load existing saved vehicles list, add the new vehicle, and save back to file.
    local saved_vehicles_list = JsonReadList("saved_vehicles.json") or {}
    table.insert(saved_vehicles_list, vehicle_data)
    JsonSaveList("saved_vehicles.json", saved_vehicles_list)

    printColoured("green", "The vehicle has been successfully saved.")
end

--- Sets a custom engine sound for a vehicle.
-- Also marks the vehicle as modified to store this custom data.
-- @param vehicle_handle number The handle of the vehicle.
-- @param engine_sound_name string The name of the audio game object for the engine sound.
function set_vehicle_engine_sound(vehicle_handle, engine_sound_name)
    AUDIO.FORCE_USE_AUDIO_GAME_OBJECT(vehicle_handle, engine_sound_name)

    mark_vehicle_as_modified(vehicle_handle) -- Mark the vehicle to store custom data.
    modified_vehicle_data[vehicle_handle].EngineSound = engine_sound_name -- Store the engine sound name.
    print("Engine sound set to: " .. engine_sound_name .. " for vehicle " .. vehicle_handle .. ".")
end

--- Initiates remote control of a specified vehicle.
-- Displays a series of "hacking" messages and then starts the remote control script.
-- @param vehicle_handle number The handle of the vehicle to control.
function remote_control_vehicle(vehicle_handle)
    if ENTITY.DOES_ENTITY_EXIST(vehicle_handle) and ENTITY.IS_ENTITY_A_VEHICLE(vehicle_handle) then
        print("Connecting to vehicle...")
        Wait(300) -- Combined waits for cleaner output.

        print("Establishing SSH tunnel...")
        Wait(150)

        print("Bypassing security protocols...")
        Wait(600)
        
        print("Identifying vulnerabilities...")
        Wait(150)

        -- If no vehicle is currently under remote control, or if a new vehicle is selected.
        if GetGlobalVariable("RemoteControlVehicle") == 0.0 or GetGlobalVariable("RemoteControlVehicle") ~= vehicle_handle then
            SetGlobalVariableValue("RemoteControlVehicle", vehicle_handle) -- Set the new remote control target.
            -- Run the separate remote control script.
            -- Using relative path for RunScript as per your instruction.
            if not RunScript("features\\remote_control_vehicle.lua") then
                DisplayError(true, "Failed to initialize the remote control script.")
            else
                printColoured("green", "Remote control established for vehicle " .. vehicle_handle .. ".")
            end
        else
            print("Vehicle " .. vehicle_handle .. " is already under remote control.")
        end
    else
        DisplayError(false, "Invalid vehicle ID or entity is not a vehicle.")
    end
end

--- Provides a menu for controlling various aspects of a vehicle (engine, doors, lights, etc.).
-- @param vehicle_handle number The handle of the vehicle to control.
function control_vehicle(vehicle_handle)
    local control_options = { "Engine", "Doors", "Roof", "Windows", "Lights", "Alarm", "Radio", "Remote control" }
    local selected_option_index = InputFromList("Choose what you want to control: ", control_options)
    
    if selected_option_index == 0 then -- Engine control
        local engine_is_running = VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(vehicle_handle)
        local engine_state_text = engine_is_running and "running" or "not running"
        print("Engine is " .. engine_state_text .. ".")
    
        local user_input = Input("Do you want to start the engine? [Y/n]: ", true)
    
        if user_input == "y" then
            network_utils.request_control_of(vehicle_handle)
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle_handle, true, true, false)
            print("Engine started.")
        elseif user_input == "n" then 
            network_utils.request_control_of(vehicle_handle)
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle_handle, false, false, false)
            print("Engine stopped.")
        end
    elseif selected_option_index == 1 then -- Doors control
        local door_options = { "Open specific", "Close specific", "Open all", "Close all" }
        local selected_door_option = InputFromList("Choose what you want to do with doors: ", door_options)
    
        if selected_door_option == 0 then -- Open specific door
            local door_index_str = Input("Enter the door sequence number (0-5, e.g., 0 for front left): ", false)
            local door_index = tonumber(door_index_str)
            if door_index and door_index >= 0 and door_index <= 5 then -- Validate common door indices.
                network_utils.request_control_of(vehicle_handle)
                VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle_handle, door_index, false, false)
                print("Door " .. door_index .. " opened.")
            else
                DisplayError(false, "Incorrect input: Please enter a valid door index (0-5).")
            end
        elseif selected_door_option == 1 then -- Close specific door
            local door_index_str = Input("Enter the door sequence number (0-5): ", false)
            local door_index = tonumber(door_index_str)
            if door_index and door_index >= 0 and door_index <= 5 then
                network_utils.request_control_of(vehicle_handle)
                VEHICLE.SET_VEHICLE_DOOR_SHUT(vehicle_handle, door_index, false)
                print("Door " .. door_index .. " closed.")
            else
                DisplayError(false, "Incorrect input: Please enter a valid door index (0-5).")
            end
        elseif selected_door_option == 2 then -- Open all doors
            network_utils.request_control_of(vehicle_handle)
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle_handle, 0, false, false) -- Front Left
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle_handle, 1, false, false) -- Front Right
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle_handle, 2, false, false) -- Rear Left
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle_handle, 3, false, false) -- Rear Right
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle_handle, 4, false, false) -- Hood
            VEHICLE.SET_VEHICLE_DOOR_OPEN(vehicle_handle, 5, false, false) -- Trunk
            print("All doors opened.")
        elseif selected_door_option == 3 then -- Close all doors
            network_utils.request_control_of(vehicle_handle)
            VEHICLE.SET_VEHICLE_DOORS_SHUT(vehicle_handle, false)
            print("All doors closed.")
        end
    elseif selected_option_index == 2 then -- Roof control (for convertibles)
        if VEHICLE.IS_VEHICLE_A_CONVERTIBLE(vehicle_handle, false) then
            local roof_options = { "Open", "Close" }
            local selected_roof_option = InputFromList("Choose what you want to do with the roof: ", roof_options)
        
            if selected_roof_option == 0 then
                network_utils.request_control_of(vehicle_handle)
                VEHICLE.LOWER_CONVERTIBLE_ROOF(vehicle_handle, false)
                print("Convertible roof lowered.")
            elseif selected_roof_option == 1 then
                network_utils.request_control_of(vehicle_handle)
                VEHICLE.RAISE_CONVERTIBLE_ROOF(vehicle_handle, false)
                print("Convertible roof raised.")
            end
        else
            DisplayError(false, "The chosen vehicle is not a convertible.")
        end
    elseif selected_option_index == 3 then -- Windows control
        local window_options = { "Roll down specific", "Roll up specific", "Roll down all", "Roll up all" }
        local selected_window_option = InputFromList("Choose what you want to do with windows: ", window_options)
    
        if selected_window_option == 0 then -- Roll down specific window
            local window_index_str = Input("Enter the window sequence number (0-7, e.g., 0 for front left): ", false)
            local window_index = tonumber(window_index_str)
            if window_index and window_index >= 0 and window_index <= 7 then -- Validate common window indices.
                network_utils.request_control_of(vehicle_handle)
                VEHICLE.ROLL_DOWN_WINDOW(vehicle_handle, window_index)
                print("Window " .. window_index .. " rolled down.")
            else
                DisplayError(false, "Incorrect input: Please enter a valid window index (0-7).")
            end
        elseif selected_window_option == 1 then -- Roll up specific window
            local window_index_str = Input("Enter the window sequence number (0-7): ", false)
            local window_index = tonumber(window_index_str)
            if window_index and window_index >= 0 and window_index <= 7 then
                network_utils.request_control_of(vehicle_handle)
                VEHICLE.ROLL_UP_WINDOW(vehicle_handle, window_index)
                print("Window " .. window_index .. " rolled up.")
            else
                DisplayError(false, "Incorrect input: Please enter a valid window index (0-7).")
            end
        elseif selected_window_option == 2 then -- Roll down all windows
            network_utils.request_control_of(vehicle_handle)
            VEHICLE.ROLL_DOWN_WINDOWS(vehicle_handle)
            print("All windows rolled down.")
        elseif selected_window_option == 3 then -- Roll up all windows
            network_utils.request_control_of(vehicle_handle)
            for i = 0, 8 do -- Iterate through possible window indices.
                VEHICLE.ROLL_UP_WINDOW(vehicle_handle, i)
            end
            print("All windows rolled up.")
        end
    elseif selected_option_index == 4 then -- Lights control
        local light_type_options = { "Headlights", "Interior lights", "Indicator lights" }
        local selected_light_type = InputFromList("Choose the lights type: ", light_type_options)

        if selected_light_type == 0 then -- Headlights
            local user_input = Input("You want to switch on the car's headlights? [Y/n]: ", true)
            if user_input == "y" then
                VEHICLE.SET_VEHICLE_LIGHTS(vehicle_handle, 2) -- Lights On (2 means 'on', 1 means 'off')
                print("Headlights switched on.")
            elseif user_input == "n" then
                VEHICLE.SET_VEHICLE_LIGHTS(vehicle_handle, 1) -- Lights Off
                print("Headlights switched off.")
            end
        elseif selected_light_type == 1 then -- Interior lights
            local user_input = Input("You want to switch on the interior lights? [Y/n]: ", true)
            if user_input == "y" then
                VEHICLE.SET_VEHICLE_INTERIORLIGHT(vehicle_handle, true)
                print("Interior lights switched on.")
            elseif user_input == "n" then
                VEHICLE.SET_VEHICLE_INTERIORLIGHT(vehicle_handle, false)
                print("Interior lights switched off.")
            end
        elseif selected_light_type == 2 then -- Indicator lights
            local indicator_options = { "Toggle all", "Switch left", "Switch right" }
            local selected_indicator_option = InputFromList("Choose the indicator action: ", indicator_options)

            if selected_indicator_option == 0 then -- Toggle all (hazard lights)
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle_handle, 0, true) -- Right
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle_handle, 1, true) -- Left
                print("Hazard lights toggled on.")
            elseif selected_indicator_option == 1 then -- Switch left
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle_handle, 0, false) -- Right off
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle_handle, 1, true)  -- Left on
                print("Left indicator switched on.")
            elseif selected_indicator_option == 2 then -- Switch right
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle_handle, 0, true)  -- Right on
                VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle_handle, 1, false) -- Left off
                print("Right indicator switched on.")
            end
        end
    elseif selected_option_index == 5 then -- Alarm control
        local user_input = Input("You want to activate the alarm system on the vehicle? [Y/n]: ", true)
        
        if user_input == "y" then
            VEHICLE.SET_VEHICLE_ALARM(vehicle_handle, true)
            VEHICLE.START_VEHICLE_ALARM(vehicle_handle)
            print("Vehicle alarm activated.")
        elseif user_input == "n" then
            VEHICLE.SET_VEHICLE_ALARM(vehicle_handle, false)
            print("Vehicle alarm deactivated.")
        end
    elseif selected_option_index == 6 then -- Radio control
        local radio_station_display_names = {}
        local radio_station_hashes = {}

        -- Populate lists for InputFromList.
        for station_name, station_hash in pairs(radio_stations.RadioStations) do
            radio_station_display_names[#radio_station_display_names + 1] = string.gsub(station_name, "_", " ")
            radio_station_hashes[#radio_station_hashes + 1] = station_hash
        end
        
        local selected_station_index = InputFromList("Choose a radio station from the list: ", radio_station_display_names)

        if selected_station_index ~= -1 then -- Check if user made a selection.
            network_utils.request_control_of(vehicle_handle)
            AUDIO.SET_VEH_HAS_NORMAL_RADIO(vehicle_handle) -- Ensure vehicle has a normal radio.
            AUDIO.SET_VEHICLE_RADIO_ENABLED(vehicle_handle, true)
            AUDIO.SET_VEH_RADIO_STATION(vehicle_handle, radio_station_hashes[selected_station_index + 1]) -- Apply selected station.
            print("Radio station set to: " .. radio_station_display_names[selected_station_index + 1] .. ".")
        else
            print("Radio station selection cancelled.")
        end
    elseif selected_option_index == 7 then -- Remote control
        remote_control_vehicle(vehicle_handle)
    end
end

--- Provides a menu for applying various tuning modifications to a vehicle.
-- @param vehicle_handle number The handle of the vehicle to tune.
function tune_vehicle(vehicle_handle)
    local tuning_options = {
        "Livery", "Primary color", "Secondary color", "Neon lights", "Xenon color", "Tire smoke color",
        "Number plate text", "Number plate type", "Windows tint", "Spoiler", "Bumpers", "Exhaust",
        "Frame", "Radiator grille", "Hood", "Roof", "Fender", "Side Skirt", "Horn",
        "Technical specifications", "Wheels", "Interior", "Make max tuning", "Make stock"
    }
    local selected_tuning_index = InputFromList("Choose what you want to tune: ", tuning_options)

    if selected_tuning_index == 0 then -- Livery
        network_utils.request_control_of(vehicle_handle)
        local livery_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, vehicle_enums.VehicleMod.LIVERY)
        if livery_count > 0 then
            local livery_id_str = Input("Enter the livery identifier from -1 to " .. (livery_count - 1) .. ": ", false)
            local livery_id = tonumber(livery_id_str)
            if livery_id and livery_id >= -1 and livery_id < livery_count then
                create_tuning_fx(vehicle_handle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle_handle, vehicle_enums.VehicleMod.LIVERY, livery_id, 0)
                print("Livery set to ID: " .. livery_id .. ".")
            else
                DisplayError(false, "Incorrect input: Please enter a valid livery identifier.")
            end
        else 
            print("The vehicle doesn't have any livery.")
        end
    elseif selected_tuning_index == 1 then -- Primary color
        local r, g, b = InputRGB()
        network_utils.request_control_of(vehicle_handle)
        create_tuning_fx(vehicle_handle, 3.0)
        VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(vehicle_handle, r, g, b)
        print("Primary color set to RGB(" .. r .. ", " .. g .. ", " .. b .. ").")
    elseif selected_tuning_index == 2 then -- Secondary color
        local r, g, b = InputRGB()
        network_utils.request_control_of(vehicle_handle)
        create_tuning_fx(vehicle_handle, 3.0)
        VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(vehicle_handle, r, g, b)
        print("Secondary color set to RGB(" .. r .. ", " .. g .. ", " .. b .. ").")
    elseif selected_tuning_index == 3 then -- Neon lights
        local r, g, b = InputRGB()
        network_utils.request_control_of(vehicle_handle)
        -- Temporarily disable all neons to ensure a clean application of new color.
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 0, false)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 1, false)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 2, false)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 3, false)
        Wait(10) -- Short wait for changes to apply.
        VEHICLE.SET_VEHICLE_NEON_COLOUR(vehicle_handle, r, g, b)
        -- Enable left and right neons immediately, then front and back with a slight delay.
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 0, true)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 1, true)
        Wait(500)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 2, true)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 3, true)
        print("Neon lights color set and enabled.")
    elseif selected_tuning_index == 4 then -- Xenon color
        local xenon_colors = {
            "Xenon headlights", "White headlights", "Blue headlights", "Electric blue", "Mint green",
            "Lime", "Yellow headlights", "Golden rain", "Orange headlights", "Red headlights",
            "Pink pony", "Bright pink headlights", "Purple headlights", "Black light"
        }
        local selected_color_index = InputFromList("Enter the color: ", xenon_colors)

        if selected_color_index ~= -1 then
            network_utils.request_control_of(vehicle_handle)
            -- SET_VEHICLE_XENON_LIGHT_COLOR_INDEX expects a 0-based index.
            VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle_handle, selected_color_index)
            print("Xenon lights color set to: " .. xenon_colors[selected_color_index + 1] .. ".")
        else
            DisplayError(false, "Incorrect input or selection cancelled.")
        end
    elseif selected_tuning_index == 5 then -- Tire smoke color
        local r, g, b = InputRGB()
        network_utils.request_control_of(vehicle_handle)
        VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(vehicle_handle, r, g, b)
        print("Tire smoke color set to RGB(" .. r .. ", " .. g .. ", " .. b .. ").")
    elseif selected_tuning_index == 6 then -- Number plate text
        local plate_text = Input("Enter the text for the number plate (max. 8 characters): ", false)
        if #plate_text <= 8 then
            network_utils.request_control_of(vehicle_handle)
            create_tuning_fx(vehicle_handle, 2.0)
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle_handle, plate_text)
            print("Number plate text set to: '" .. plate_text .. "'.")
        else
            DisplayError(false, "Number plate text exceeds 8 characters.")
        end
    elseif selected_tuning_index == 7 then -- Number plate type
        local plate_types = {
            "Blue/White", "Yellow/black", "Yellow/Blue", "Blue/White2", "Blue/White3", "Yankton",
            "eCola", "Sea", "Liberty city", "OCT", "Panic", "Pounderd", "Sprunk"
        }
        local selected_plate_type_index = InputFromList("Enter the number plate type: ", plate_types)

        if selected_plate_type_index ~= -1 then
            network_utils.request_control_of(vehicle_handle)
            create_tuning_fx(vehicle_handle, 2.0)
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(vehicle_handle, selected_plate_type_index)
            print("Number plate type set to: " .. plate_types[selected_plate_type_index + 1] .. ".")

            -- Prompt to change number plate holder.
            local change_holder_input = Input("Do you want to change the number plate holder? [Y/n]: ", true)
            if change_holder_input == "y" then
                local holder_mods_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, vehicle_enums.VehicleMod.PLATEHOLDER)
                if holder_mods_count > 0 then
                    local placeholder_options = { "Front and rear placeholder", "Front placeholder", "Rear placeholder", "None" }
                    local selected_placeholder_index = InputFromList("Enter the placeholder type: ", placeholder_options)

                    if selected_placeholder_index ~= -1 then
                        create_tuning_fx(vehicle_handle, 2.0)
                        VEHICLE.SET_VEHICLE_MOD(vehicle_handle, vehicle_enums.VehicleMod.PLATEHOLDER, selected_placeholder_index, 0)
                        print("Number plate holder set.")
                    else
                        DisplayError(false, "Incorrect input or selection cancelled.")
                    end
                else 
                    print("The vehicle doesn't have any plate holder modifications.")
                end
            end
        else
            DisplayError(false, "Incorrect input or selection cancelled.")
        end
    elseif selected_tuning_index == 8 then -- Windows tint
        local tint_options = { "No", "Light tinting", "Medium tinting", "Dark tint", "Limo tint", "Green tint" }
        local selected_tint_index = InputFromList("Enter the windows tint: ", tint_options)

        if selected_tint_index ~= -1 then
            local tint_value = vehicle_enums.WindowTint.NONE -- Default to None.
            if selected_tint_index == 0 then tint_value = vehicle_enums.WindowTint.NONE
            elseif selected_tint_index == 1 then tint_value = vehicle_enums.WindowTint.LIGHT
            elseif selected_tint_index == 2 then tint_value = vehicle_enums.WindowTint.MEDIUM
            elseif selected_tint_index == 3 then tint_value = vehicle_enums.WindowTint.DARK
            elseif selected_tint_index == 4 then tint_value = vehicle_enums.WindowTint.LIMO
            elseif selected_tint_index == 5 then tint_value = vehicle_enums.WindowTint.GREEN
            end

            network_utils.request_control_of(vehicle_handle)
            create_tuning_fx(vehicle_handle, 2.0)
            VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle_handle, tint_value)
            print("Window tint set to: " .. tint_options[selected_tint_index + 1] .. ".")
        else
            DisplayError(false, "Incorrect input or selection cancelled.")
        end
    elseif selected_tuning_index == 9 then -- Spoiler
        network_utils.request_control_of(vehicle_handle)
        local spoiler_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, vehicle_enums.VehicleMod.SPOILER)
        if spoiler_count > 0 then
            local spoiler_id_str = Input("Enter the spoiler identifier from 0 to " .. (spoiler_count - 1) .. ": ", false)
            local spoiler_id = tonumber(spoiler_id_str)
            if spoiler_id and spoiler_id >= 0 and spoiler_id < spoiler_count then
                create_tuning_fx(vehicle_handle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle_handle, vehicle_enums.VehicleMod.SPOILER, spoiler_id, 0)
                print("Spoiler set to ID: " .. spoiler_id .. ".")
            else
                DisplayError(false, "Incorrect input: Please enter a valid spoiler identifier.")
            end
        else 
            print("The vehicle doesn't have any spoiler modifications.")
        end
    elseif selected_tuning_index == 10 then -- Bumpers
        local bumper_types = { "Front", "Rear" }
        local selected_bumper_type_index = InputFromList("Enter the type of bumper: ", bumper_types)

        if selected_bumper_type_index ~= -1 then
            local bumper_mod_type = nil
            if selected_bumper_type_index == 0 then
                bumper_mod_type = vehicle_enums.VehicleMod.FRONT_BUMPER
            elseif selected_bumper_type_index == 1 then
                bumper_mod_type = vehicle_enums.VehicleMod.REAR_BUMPER
            end

            network_utils.request_control_of(vehicle_handle)
            local bumper_mod_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, bumper_mod_type)
            if bumper_mod_count > 0 then
                local bumper_id_str = Input("Enter the bumper identifier from 0 to " .. (bumper_mod_count - 1) .. ": ", false)
                local bumper_id = tonumber(bumper_id_str)
                if bumper_id and bumper_id >= 0 and bumper_id < bumper_mod_count then
                    create_tuning_fx(vehicle_handle, 2.0)
                    VEHICLE.SET_VEHICLE_MOD(vehicle_handle, bumper_mod_type, bumper_id, 0)
                    print(bumper_types[selected_bumper_type_index + 1] .. " bumper set to ID: " .. bumper_id .. ".")
                else
                    DisplayError(false, "Incorrect input: Please enter a valid bumper identifier.")
                end
            else 
                print("The vehicle does not have a bumper of this type.")
            end
        else
            DisplayError(false, "Incorrect input or selection cancelled.")
        end
    elseif selected_tuning_index == 11 then -- Exhaust
        network_utils.request_control_of(vehicle_handle)
        local exhaust_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, vehicle_enums.VehicleMod.EXHAUST)
        if exhaust_count > 0 then
            local exhaust_id_str = Input("Enter the exhaust identifier from 0 to " .. (exhaust_count - 1) .. ": ", false)
            local exhaust_id = tonumber(exhaust_id_str)
            if exhaust_id and exhaust_id >= 0 and exhaust_id < exhaust_count then
                create_tuning_fx(vehicle_handle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle_handle, vehicle_enums.VehicleMod.EXHAUST, exhaust_id, 0)
                print("Exhaust set to ID: " .. exhaust_id .. ".")
            else
                DisplayError(false, "Incorrect input: Please enter a valid exhaust identifier.")
            end
        else 
            print("The vehicle doesn't have any exhaust modifications.")
        end
    elseif selected_tuning_index == 12 then -- Frame
        network_utils.request_control_of(vehicle_handle)
        local frame_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, vehicle_enums.VehicleMod.FRAME)
        if frame_count > 0 then
            local frame_id_str = Input("Enter the frame identifier from 0 to " .. (frame_count - 1) .. ": ", false)
            local frame_id = tonumber(frame_id_str)
            if frame_id and frame_id >= 0 and frame_id < frame_count then
                create_tuning_fx(vehicle_handle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle_handle, vehicle_enums.VehicleMod.FRAME, frame_id, 0)
                print("Frame set to ID: " .. frame_id .. ".")
            else
                DisplayError(false, "Incorrect input: Please enter a valid frame identifier.")
            end
        else 
            print("The vehicle doesn't have any frame modifications.")
        end
    elseif selected_tuning_index == 13 then -- Radiator grille
        network_utils.request_control_of(vehicle_handle)
        local grille_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, vehicle_enums.VehicleMod.GRILLE)
        if grille_count > 0 then
            local grille_id_str = Input("Enter the radiator grille identifier from 0 to " .. (grille_count - 1) .. ": ", false)
            local grille_id = tonumber(grille_id_str)
            if grille_id and grille_id >= 0 and grille_id < grille_count then
                create_tuning_fx(vehicle_handle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle_handle, vehicle_enums.VehicleMod.GRILLE, grille_id, 0)
                print("Radiator grille set to ID: " .. grille_id .. ".")
            else
                DisplayError(false, "Incorrect input: Please enter a valid grille identifier.")
            end
        else 
            print("The vehicle doesn't have any radiator grille modifications.")
        end
    elseif selected_tuning_index == 14 then -- Hood
        network_utils.request_control_of(vehicle_handle)
        local hood_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, vehicle_enums.VehicleMod.HOOD)
        if hood_count > 0 then
            local hood_id_str = Input("Enter the hood identifier from 0 to " .. (hood_count - 1) .. ": ", false)
            local hood_id = tonumber(hood_id_str)
            if hood_id and hood_id >= 0 and hood_id < hood_count then
                create_tuning_fx(vehicle_handle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle_handle, vehicle_enums.VehicleMod.HOOD, hood_id, 0)
                print("Hood set to ID: " .. hood_id .. ".")
            else
                DisplayError(false, "Incorrect input: Please enter a valid hood identifier.")
            end
        else 
            print("The vehicle doesn't have any hood modifications.")
        end
    elseif selected_tuning_index == 15 then -- Roof
        network_utils.request_control_of(vehicle_handle)
        local roof_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, vehicle_enums.VehicleMod.ROOF)
        if roof_count > 0 then
            local roof_id_str = Input("Enter the roof identifier from 0 to " .. (roof_count - 1) .. ": ", false)
            local roof_id = tonumber(roof_id_str)
            if roof_id and roof_id >= 0 and roof_id < roof_count then
                create_tuning_fx(vehicle_handle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle_handle, vehicle_enums.VehicleMod.ROOF, roof_id, 0)
                print("Roof set to ID: " .. roof_id .. ".")
            else
                DisplayError(false, "Incorrect input: Please enter a valid roof identifier.")
            end
        else 
            print("The vehicle doesn't have any roof modifications.")
        end
    elseif selected_tuning_index == 16 then -- Fender
        local fender_types = { "Left fender", "Right fender" }
        local selected_fender_type_index = InputFromList("Enter the type of fender: ", fender_types)

        if selected_fender_type_index ~= -1 then
            local fender_mod_type = nil
            if selected_fender_type_index == 0 then
                fender_mod_type = vehicle_enums.VehicleMod.FENDER -- Left Fender
            elseif selected_fender_type_index == 1 then
                fender_mod_type = vehicle_enums.VehicleMod.RIGHT_FENDER -- Right Fender
            end

            network_utils.request_control_of(vehicle_handle)
            local fender_mod_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, fender_mod_type)
            if fender_mod_count > 0 then
                local fender_id_str = Input("Enter the fender identifier from 0 to " .. (fender_mod_count - 1) .. ": ", false)
                local fender_id = tonumber(fender_id_str)
                if fender_id and fender_id >= 0 and fender_id < fender_mod_count then
                    create_tuning_fx(vehicle_handle, 2.0)
                    VEHICLE.SET_VEHICLE_MOD(vehicle_handle, fender_mod_type, fender_id, 0)
                    print(fender_types[selected_fender_type_index + 1] .. " set to ID: " .. fender_id .. ".")
                else
                    DisplayError(false, "Incorrect input: Please enter a valid fender identifier.")
                end
            else 
                print("The vehicle does not have a fender of this type.")
            end
        else
            DisplayError(false, "Incorrect input or selection cancelled.")
        end
    elseif selected_tuning_index == 17 then -- Side Skirt
        network_utils.request_control_of(vehicle_handle)
        local side_skirt_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, vehicle_enums.VehicleMod.SIDE_SKIRT)
        if side_skirt_count > 0 then
            local side_skirt_id_str = Input("Enter the side skirt identifier from 0 to " .. (side_skirt_count - 1) .. ": ", false)
            local side_skirt_id = tonumber(side_skirt_id_str)
            if side_skirt_id and side_skirt_id >= 0 and side_skirt_id < side_skirt_count then
                create_tuning_fx(vehicle_handle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle_handle, vehicle_enums.VehicleMod.SIDE_SKIRT, side_skirt_id, 0)
                print("Side skirt set to ID: " .. side_skirt_id .. ".")
            else
                DisplayError(false, "Incorrect input: Please enter a valid side skirt identifier.")
            end
        else 
            print("The vehicle doesn't have any side skirt modifications.")
        end
    elseif selected_tuning_index == 18 then -- Horn
        network_utils.request_control_of(vehicle_handle)
        local horn_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, vehicle_enums.VehicleMod.HORNS)
        if horn_count > 0 then
            local horn_id_str = Input("Enter the horn identifier from 0 to " .. (horn_count - 1) .. ": ", false)
            local horn_id = tonumber(horn_id_str)
            if horn_id and horn_id >= 0 and horn_id < horn_count then
                create_tuning_fx(vehicle_handle, 2.0)
                VEHICLE.SET_VEHICLE_MOD(vehicle_handle, vehicle_enums.VehicleMod.HORNS, horn_id, 0)
                print("Horn set to ID: " .. horn_id .. ".")
            else
                DisplayError(false, "Incorrect input: Please enter a valid horn identifier.")
            end
        else 
            print("The vehicle doesn't have any horn modifications.")
        end
    elseif selected_tuning_index == 19 then -- Technical specifications (Engine, Brakes, etc.)
        local tech_spec_options = { "Engine", "Brakes", "Transmission", "Suspension", "Armor", "Turbo", "Hydraulics" }
        local selected_tech_spec_index = InputFromList("Choose what you want to tune: ", tech_spec_options)

        if selected_tech_spec_index ~= -1 then
            local mod_type = nil
            if selected_tech_spec_index == 0 then mod_type = vehicle_enums.VehicleMod.ENGINE
            elseif selected_tech_spec_index == 1 then mod_type = vehicle_enums.VehicleMod.BRAKES
            elseif selected_tech_spec_index == 2 then mod_type = vehicle_enums.VehicleMod.TRANSMISSION
            elseif selected_tech_spec_index == 3 then mod_type = vehicle_enums.VehicleMod.SUSPENSION
            elseif selected_tech_spec_index == 4 then mod_type = vehicle_enums.VehicleMod.ARMOR
            elseif selected_tech_spec_index == 5 then mod_type = vehicle_enums.VehicleMod.TURBO
            elseif selected_tech_spec_index == 6 then mod_type = vehicle_enums.VehicleMod.HYDRAULICS
            end

            network_utils.request_control_of(vehicle_handle)
            local mod_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, mod_type)
            if mod_count > 0 then
                local mod_id_str = Input("Enter the modification identifier from 0 to " .. (mod_count - 1) .. ": ", false)
                local mod_id = tonumber(mod_id_str)
                if mod_id and mod_id >= 0 and mod_id < mod_count then
                    create_tuning_fx(vehicle_handle, 2.0)
                    VEHICLE.SET_VEHICLE_MOD(vehicle_handle, mod_type, mod_id, 0)
                    print(tech_spec_options[selected_tech_spec_index + 1] .. " modification set to ID: " .. mod_id .. ".")
                else
                    DisplayError(false, "Incorrect input: Please enter a valid modification identifier.")
                end
            else 
                print("The vehicle doesn't have variations of this modification type.")
            end
        else
            DisplayError(false, "Incorrect input or selection cancelled.")
        end
    elseif selected_tuning_index == 20 then -- Wheels
        local vehicle_model_hash = ENTITY.GET_ENTITY_MODEL(vehicle_handle)
        if VEHICLE.IS_THIS_MODEL_A_BIKE(vehicle_model_hash) then
            local wheel_options = { "Front wheel", "Back wheel" }
            local selected_wheel_option_index = InputFromList("Choose which wheels you want to tune: ", wheel_options)

            local wheels_mod_type = nil
            if selected_wheel_option_index == 0 then
                wheels_mod_type = vehicle_enums.VehicleMod.FRONT_WHEELS
            elseif selected_wheel_option_index == 1 then
                wheels_mod_type = vehicle_enums.VehicleMod.BACK_WHEELS
            end

            network_utils.request_control_of(vehicle_handle)
            local wheel_mod_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, wheels_mod_type)
            if wheel_mod_count > 0 then
                local wheel_id_str = Input("Enter the wheel identifier from 0 to " .. (wheel_mod_count - 1) .. ": ", false)
                local wheel_id = tonumber(wheel_id_str)
                if wheel_id and wheel_id >= 0 and wheel_id < wheel_mod_count then
                    create_tuning_fx(vehicle_handle, 2.0)
                    VEHICLE.SET_VEHICLE_MOD(vehicle_handle, wheels_mod_type, wheel_id, 0)
                    print(wheel_options[selected_wheel_option_index + 1] .. " set to ID: " .. wheel_id .. ".")
                else
                    DisplayError(false, "Incorrect input: Please enter a valid wheel identifier.")
                end
            else 
                print("The vehicle does not have a wheel of this type.")
            end
        else -- For cars and other vehicles, assume only FrontWheels mod type for all wheels.
            network_utils.request_control_of(vehicle_handle)
            local wheel_mod_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, vehicle_enums.VehicleMod.FRONT_WHEELS)
            if wheel_mod_count > 0 then
                local wheel_id_str = Input("Enter the wheel identifier from 0 to " .. (wheel_mod_count - 1) .. ": ", false)
                local wheel_id = tonumber(wheel_id_str)
                if wheel_id and wheel_id >= 0 and wheel_id < wheel_mod_count then
                    create_tuning_fx(vehicle_handle, 2.0)
                    VEHICLE.SET_VEHICLE_MOD(vehicle_handle, vehicle_enums.VehicleMod.FRONT_WHEELS, wheel_id, 0)
                    print("Wheels set to ID: " .. wheel_id .. ".")
                else
                    DisplayError(false, "Incorrect input: Please enter a valid wheel identifier.")
                end
            else 
                print("The vehicle doesn't have any wheel modifications.")
            end
        end
    elseif selected_tuning_index == 21 then -- Interior
        local interior_options = {
            "Dash", "Ornament", "Dial design", "Trim design", "Speakers door", "Leather seats",
            "Steering wheel", "Column shifter lever", "Plaque", "Speakers"
        }
        local selected_interior_option_index = InputFromList("Choose what you want to tune: ", interior_options)

        if selected_interior_option_index ~= -1 then
            local mod_type = nil
            if selected_interior_option_index == 0 then mod_type = vehicle_enums.VehicleMod.DASH
            elseif selected_interior_option_index == 1 then mod_type = vehicle_enums.VehicleMod.ORNAMENT
            elseif selected_interior_option_index == 2 then mod_type = vehicle_enums.VehicleMod.DIAL_DESIGN
            elseif selected_interior_option_index == 3 then mod_type = vehicle_enums.VehicleMod.TRIM_DESIGN
            elseif selected_interior_option_index == 4 then mod_type = vehicle_enums.VehicleMod.SPEAKERS_DOOR
            elseif selected_interior_option_index == 5 then mod_type = vehicle_enums.VehicleMod.LEATHER_SEATS
            elseif selected_interior_option_index == 6 then mod_type = vehicle_enums.VehicleMod.STEERING_WHEEL
            elseif selected_interior_option_index == 7 then mod_type = vehicle_enums.VehicleMod.COLUMN_SHIFTER_LEVER
            elseif selected_interior_option_index == 8 then mod_type = vehicle_enums.VehicleMod.PLAQUE
            elseif selected_interior_option_index == 9 then mod_type = vehicle_enums.VehicleMod.SPEAKERS
            end

            network_utils.request_control_of(vehicle_handle)
            local mod_count = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle_handle, mod_type)
            if mod_count > 0 then
                local mod_id_str = Input("Enter the modification identifier from 0 to " .. (mod_count - 1) .. ": ", false)
                local mod_id = tonumber(mod_id_str)
                if mod_id and mod_id >= 0 and mod_id < mod_count then
                    create_tuning_fx(vehicle_handle, 2.0)
                    VEHICLE.SET_VEHICLE_MOD(vehicle_handle, mod_type, mod_id, 0)
                    print(interior_options[selected_interior_option_index + 1] .. " modification set to ID: " .. mod_id .. ".")
                else
                    DisplayError(false, "Incorrect input: Please enter a valid modification identifier.")
                end
            else 
                print("The vehicle doesn't have variations of this interior modification.")
            end
        else
            DisplayError(false, "Incorrect input or selection cancelled.")
        end
    elseif selected_tuning_index == 22 then -- Make max tuning
        apply_vehicle_max_tuning(vehicle_handle)
        printColoured("green", "Vehicle tuned to max specifications.")
    elseif selected_tuning_index == 23 then -- Make stock
        create_tuning_fx(vehicle_handle, 2.0) -- Show a visual effect.

        VEHICLE.SET_VEHICLE_WINDOW_TINT(vehicle_handle, 0) -- Reset window tint to none.
        VEHICLE.SET_VEHICLE_MOD_KIT(vehicle_handle, 0)     -- Apply default mod kit.

        -- Reset all common mods to stock (index 0).
        for i = 0, 30 do
            -- Skip specific mod types (17 to 24) as per original logic, though setting to 0 is generally safe.
            if not (i >= 17 and i <= 24) then 
                VEHICLE.SET_VEHICLE_MOD(vehicle_handle, i, 0, 0)
            end
        end

        VEHICLE.SET_VEHICLE_MOD(vehicle_handle, 48, 0, 0) -- Reset livery to stock.

        -- Disable specific toggleable mods.
        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle_handle, 20, false) -- Custom tires.
        VEHICLE.TOGGLE_VEHICLE_MOD(vehicle_handle, 22, false) -- Armor.

        -- Re-enable tire bursting and wheel breaking.
        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(vehicle_handle, true)
        VEHICLE.SET_VEHICLE_WHEELS_CAN_BREAK(vehicle_handle, true)
        
        -- Disable all neon lights and reset colors.
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 0, false)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 1, false)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 2, false)
        VEHICLE.SET_VEHICLE_NEON_ENABLED(vehicle_handle, 3, false)
        VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(vehicle_handle, 0, 0, 0) -- Black smoke.
        VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(vehicle_handle, 0) -- White/stock xenon.
        printColoured("green", "Vehicle reset to stock specifications.")
    end
end

--- Provides a menu for applying various non-tuning modifications to a vehicle.
-- These include dynamic neon/color, siren mute, invincibility, lock-on settings, and engine sound.
-- @param vehicle_handle number The handle of the vehicle to modify.
function modify_vehicle_properties(vehicle_handle)
    local modification_options = { "Dynamic neon", "Dynamic color", "Mute siren", "Set invincible", "Set lock on", "Set engine sound" }
    local selected_option_index = InputFromList("Choose what you want to modify: ", modification_options)

    if selected_option_index == 0 then -- Dynamic neon
        local enable_dynamic_neon_input = Input("Enable dynamic neon lights? [Y/n]: ", true)
        
        if enable_dynamic_neon_input == "y" then
            SetGlobalVariableValue("DynamicNeonVehicle", vehicle_handle)
            mark_vehicle_as_modified(vehicle_handle)
            print("Dynamic neon lights enabled for vehicle " .. vehicle_handle .. ".")
        elseif enable_dynamic_neon_input == "n" then
            SetGlobalVariableValue("DynamicNeonVehicle", 0.0) -- Disable dynamic neon.
            -- Note: Original code doesn't unmark vehicle here, which might be desired.
            print("Dynamic neon lights disabled for vehicle " .. vehicle_handle .. ".")
        end 
    elseif selected_option_index == 1 then -- Dynamic color
        local enable_dynamic_color_input = Input("Enable dynamic changing colour? [Y/n]: ", true)
            
        if enable_dynamic_color_input == "y" then
            SetGlobalVariableValue("DynamicColorVehicle", vehicle_handle)
            mark_vehicle_as_modified(vehicle_handle)
            print("Dynamic vehicle color enabled for vehicle " .. vehicle_handle .. ".")
        elseif enable_dynamic_color_input == "n" then
            SetGlobalVariableValue("DynamicColorVehicle", 0.0) -- Disable dynamic color.
            -- Note: Original code doesn't unmark vehicle here.
            print("Dynamic vehicle color disabled for vehicle " .. vehicle_handle .. ".")
        end 
    elseif selected_option_index == 2 then -- Mute siren
        network_utils.request_control_of(vehicle_handle)
        local mute_siren_input = Input("Do you want to enable mute for siren? [Y/n]: ", true)

        if mute_siren_input == "y" then
            VEHICLE.SET_VEHICLE_HAS_MUTED_SIRENS(vehicle_handle, true)
            mark_vehicle_as_modified(vehicle_handle) -- Mark as modified to remember state.
            print("Siren muted for vehicle " .. vehicle_handle .. ".")
        elseif mute_siren_input == "n" then
            VEHICLE.SET_VEHICLE_HAS_MUTED_SIRENS(vehicle_handle, false)
            mark_vehicle_as_modified(vehicle_handle) -- Mark as modified.
            print("Siren unmuted for vehicle " .. vehicle_handle .. ".")
        end
    elseif selected_option_index == 3 then -- Set invincible
        local set_invincible_input = Input("Set the invincibility of the selected vehicle? [Y/n]: ", true)

        if set_invincible_input == "y" then
            ENTITY.SET_ENTITY_INVINCIBLE(vehicle_handle, true)
            mark_vehicle_as_modified(vehicle_handle) -- Mark as modified to remember state.
            print("Vehicle " .. vehicle_handle .. " is now invincible.")
        elseif set_invincible_input == "n" then
            ENTITY.SET_ENTITY_INVINCIBLE(vehicle_handle, false)
            print("Vehicle " .. vehicle_handle .. " is no longer invincible.")
        end 
    elseif selected_option_index == 4 then -- Set lock on (allow/disallow homing missile lock-on)
        local allow_lock_on_input = Input("Allow other players from locking on to the selected vehicle? [Y/n]: ", true)

        if allow_lock_on_input == "y" then
            VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON(vehicle_handle, true, false)
            VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(vehicle_handle, true, false)
            print("Homing missile lock-on allowed for vehicle " .. vehicle_handle .. ".")
        elseif allow_lock_on_input == "n" then
            VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON(vehicle_handle, false, false)
            VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(vehicle_handle, false, false)
            mark_vehicle_as_modified(vehicle_handle) -- Mark as modified to remember state.
            print("Homing missile lock-on disabled for vehicle " .. vehicle_handle .. ".")
        end 
    elseif selected_option_index == 5 then -- Set engine sound
        local engine_sound_name_to_set = nil
        local engine_sound_options = { "Adder", "Interceptor", "Gang Burrito", "Itali RSX", "Buffalo EVX", "R88", "Custom" }
        local engine_sound_hashes = { "adder", "polgauntlet", "gburrito", "italirsx", "buffalo5", "formula2" } -- Mapped to options.
        local selected_engine_sound_index = InputFromList("Choose the engine sound you want to set: ", engine_sound_options)

        if selected_engine_sound_index ~= -1 then
            if selected_engine_sound_index == 6 then -- "Custom" option
                engine_sound_name_to_set = string.upper(Input("Enter the vehicle model name for custom sound: ", false))
            else
                engine_sound_name_to_set = engine_sound_hashes[selected_engine_sound_index + 1]
            end
            
            set_vehicle_engine_sound(vehicle_handle, engine_sound_name_to_set)
        else
            print("Engine sound selection cancelled.")
        end
    end
end

--- Manages a list of created vehicles, allowing interaction or deletion.
function manage_created_vehicles()
    if #created_vehicle_ids ~= 0 then
        local selected_vehicle_index = InputFromList("Choose the vehicle you want to interact with: ", created_vehicle_models)
        if selected_vehicle_index ~= -1 then
            local selected_vehicle_handle = created_vehicle_ids[selected_vehicle_index + 1] -- +1 for Lua 1-indexing.
            
            -- Ensure the vehicle still exists before proceeding.
            if not ENTITY.DOES_ENTITY_EXIST(selected_vehicle_handle) then
                print("Selected vehicle no longer exists. Removing from list.")
                table.remove(created_vehicle_ids, selected_vehicle_index + 1)
                table.remove(created_vehicle_models, selected_vehicle_index + 1)
                return nil
            end

            print("The Vehicle ID of the selected vehicle is " .. selected_vehicle_handle .. ".")

            local interaction_options = { "Control vehicle", "Tuning vehicle", "Modify vehicle", "Delete" }
            local selected_interaction_index = InputFromList("Choose what you want to do: ", interaction_options)

            if selected_interaction_index == 0 then -- Control vehicle
                control_vehicle(selected_vehicle_handle)
            elseif selected_interaction_index == 1 then -- Tuning vehicle
                tune_vehicle(selected_vehicle_handle)
            elseif selected_interaction_index == 2 then -- Modify vehicle
                modify_vehicle_properties(selected_vehicle_handle)
            elseif selected_interaction_index == 3 then -- Delete vehicle
                network_utils.request_control_of(selected_vehicle_handle)
                DeleteVehicle(selected_vehicle_handle) -- Delete the vehicle entity.

                -- Remove from tracking lists.
                table.remove(created_vehicle_ids, selected_vehicle_index + 1)
                table.remove(created_vehicle_models, selected_vehicle_index + 1)
                -- Also remove from modified vehicles list if it was there.
                local modified_idx = -1
                for i, v_id in ipairs(modified_vehicle_ids) do
                    if v_id == selected_vehicle_handle then
                        modified_idx = i
                        break
                    end
                end
                if modified_idx ~= -1 then
                    table.remove(modified_vehicle_ids, modified_idx)
                    table.remove(modified_vehicle_models, modified_idx)
                    modified_vehicle_data[selected_vehicle_handle] = nil -- Clear custom data.
                end
                printColoured("green", "Vehicle " .. selected_vehicle_handle .. " deleted and removed from list.")
            end
        else
            print("Vehicle selection cancelled.")
        end
    else
        print("There are no vehicles on the created vehicle list yet.")
    end
end

--- Manages a list of modified vehicles, allowing direct access to modification options.
function manage_modified_vehicles()
    if #modified_vehicle_ids ~= 0 then
        local selected_vehicle_index = InputFromList("Choose the modified vehicle you want to interact with: ", modified_vehicle_models)
        if selected_vehicle_index ~= -1 then
            local selected_vehicle_handle = modified_vehicle_ids[selected_vehicle_index + 1] -- +1 for Lua 1-indexing.

            -- Ensure the vehicle still exists before proceeding.
            if not ENTITY.DOES_ENTITY_EXIST(selected_vehicle_handle) then
                print("Selected modified vehicle no longer exists. Removing from list.")
                table.remove(modified_vehicle_ids, selected_vehicle_index + 1)
                table.remove(modified_vehicle_models, selected_vehicle_index + 1)
                modified_vehicle_data[selected_vehicle_handle] = nil -- Clear custom data.
                return nil
            end

            modify_vehicle_properties(selected_vehicle_handle) -- Directly open modification menu.
        else
            print("Modified vehicle selection cancelled.")
        end
    else
        print("There are no vehicles on the modified vehicle list yet.")
    end
end

--- Adds a vehicle chosen by the user (via target/closest vehicle) to the internal created vehicles list.
function add_vehicle_to_list_command()
    local vehicle_to_add = input_utils.input_vehicle() -- Prompts user to select a vehicle.

    if not vehicle_to_add or vehicle_to_add == 0.0 then
        DisplayError(false, "Invalid input or no vehicle selected.")
        return nil
    end

    -- Check if vehicle is already in the list to prevent duplicates.
    for _, v_id in ipairs(created_vehicle_ids) do
        if v_id == vehicle_to_add then
            print("Vehicle " .. vehicle_to_add .. " is already in the created vehicles list.")
            return nil
        end
    end

    table.insert(created_vehicle_models, vehicle_utils.get_vehicle_model_name(ENTITY.GET_ENTITY_MODEL(vehicle_to_add)))
    table.insert(created_vehicle_ids, vehicle_to_add)
    printColoured("green", "Vehicle " .. vehicle_to_add .. " added to the created vehicles list.")
end

--- Creates a new vehicle in the game world.
-- Allows user to specify model or create a random one, and apply max tuning.
function create_vehicle_command()
    local vehicle_model_hash = nil
    local iterations = 0
    local apply_tuning = false

    local model_name_input = Input("Enter vehicle model (https://forge.plebmasters.de/vehicles) or leave empty for random: ", false)

    if model_name_input == "" then
        -- Attempt to get a random vehicle model that is NOT a car, bike, quad, or amphibious.
        -- This logic seems counter-intuitive if the goal is to spawn a common vehicle type.
        -- If the intent is to get a *random vehicle* (any type), the `not VEHICLE.IS_THIS_MODEL_A_...` conditions should be removed.
        -- Keeping original logic for fidelity.
        repeat
            model_name_input = vehicle_utils.get_random_vehicle_model_name()
            vehicle_model_hash = MISC.GET_HASH_KEY(model_name_input)
            iterations = iterations + 1
            Wait(1)
        until not VEHICLE.IS_THIS_MODEL_A_CAR(vehicle_model_hash) and
              not VEHICLE.IS_THIS_MODEL_A_BIKE(vehicle_model_hash) and
              not VEHICLE.IS_THIS_MODEL_A_QUADBIKE(vehicle_model_hash) and
              not VEHICLE.IS_THIS_MODEL_AN_AMPHIBIOUS_CAR(vehicle_model_hash) and
              not VEHICLE.IS_THIS_MODEL_AN_AMPHIBIOUS_QUADBIKE(vehicle_model_hash) and
              iterations < 50
        
        if iterations >= 50 then
            DisplayError(false, "Failed to find a suitable random vehicle model after many attempts.")
            return nil
        end
        print("Selected random vehicle model: " .. model_name_input .. ".")
    else
        vehicle_model_hash = MISC.GET_HASH_KEY(model_name_input)
    end

    local failed_to_load = false
    
    -- Validate and request the vehicle model.
    if STREAMING.IS_MODEL_VALID(vehicle_model_hash) then
        STREAMING.REQUEST_MODEL(vehicle_model_hash)
        iterations = 0 -- Reset iterations for model loading.
        while not STREAMING.HAS_MODEL_LOADED(vehicle_model_hash) and not failed_to_load do
            if iterations > 50 then
                DisplayError(false, "Failed to load the vehicle model: " .. model_name_input .. ".")
                failed_to_load = true
            end
            Wait(5)
            iterations = iterations + 1
        end
        
        if not failed_to_load then
            local player_coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)

            local tuning_input = Input("Create an already tuned vehicle? [Y/n]: ", true)
            if tuning_input == "y" then
                apply_tuning = true
            end 

            -- Create the vehicle slightly in front and above the player.
            local created_vehicle_handle = VEHICLE.CREATE_VEHICLE(vehicle_model_hash, player_coords.x + 3.5, player_coords.y + 3.0, player_coords.z + 0.5, 0.0, false, false, false)
            network_utils.register_as_network(created_vehicle_handle) -- Register for network synchronization.

            if created_vehicle_handle ~= 0.0 then
                -- ENTITY.GET_ENTITY_TYPE(created_vehicle_handle) -- Original line, return value unused.
                
                if apply_tuning then
                    apply_vehicle_max_tuning(created_vehicle_handle)
                end

                -- Set various vehicle properties.
                VEHICLE.SET_VEHICLE_IS_CONSIDERED_BY_PLAYER(created_vehicle_handle, true)
                VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(created_vehicle_handle, true)
                VEHICLE.SET_VEHICLE_CAN_BE_TARGETTED(created_vehicle_handle, true)
                VEHICLE.SET_VEHICLE_IS_WANTED(created_vehicle_handle, false) -- Ensure vehicle is not wanted.
                
                -- Add a blip (map icon) for the created vehicle.
                local blip_handle = HUD.ADD_BLIP_FOR_ENTITY(created_vehicle_handle)
                HUD.SET_BLIP_AS_FRIENDLY(blip_handle, true)
                HUD.SET_BLIP_SPRITE(blip_handle, map_utils.get_blip_from_entity_model(vehicle_model_hash))
                HUD.SET_BLIP_COLOUR(blip_handle, blip_enums.BlipColour.BLUE_2)
                HUD.SET_BLIP_DISPLAY(blip_handle, blip_enums.BlipDisplay.SELECTABLE_SHOWS_ON_BOTH_MAPS)
                
                printColoured("green", "Successfully created new vehicle. Vehicle ID is " .. created_vehicle_handle .. ".")

                -- Add to internal tracking lists.
                table.insert(created_vehicle_models, model_name_input)
                table.insert(created_vehicle_ids, created_vehicle_handle)
                
                -- Prompt to get into the vehicle.
                local get_in_input = Input("Do you want to get in? [Y/n]: ", true)
                if get_in_input == "y" then
                    PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), created_vehicle_handle, -1) -- Put player in driver seat.
                    create_tuning_fx(created_vehicle_handle, 4.0) -- Show a larger tuning FX.
                end
            else
                DisplayError(false, "Failed to create vehicle entity.")
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicle_model_hash) -- Release model.
        end
    else
        DisplayError(false, "Invalid vehicle model hash or model not found: " .. model_name_input .. ".")
    end
end

--- Command to delete a vehicle selected by the user.
function delete_vehicle_command()
    local vehicle_to_delete = input_utils.input_vehicle()

    if not vehicle_to_delete or vehicle_to_delete == 0.0 or not ENTITY.DOES_ENTITY_EXIST(vehicle_to_delete) then
        DisplayError(false, "Invalid input or no vehicle selected.")
        return nil
    end

    network_utils.request_control_of(vehicle_to_delete)
    DeleteVehicle(vehicle_to_delete)
    printColoured("green", "Vehicle " .. vehicle_to_delete .. " deleted.")
end

--- Command to explode a vehicle selected by the user.
-- Includes a "hacking" sequence before explosion.
function explode_vehicle_command()
    local vehicle_to_explode = input_utils.input_vehicle()

    if not vehicle_to_explode or vehicle_to_explode == 0.0 or not ENTITY.DOES_ENTITY_EXIST(vehicle_to_explode) then
        DisplayError(false, "Invalid input or no vehicle selected.")
        return nil
    end

    if ENTITY.IS_ENTITY_A_VEHICLE(vehicle_to_explode) then
        print("Connecting to vehicle...")
        Wait(300)

        print("Establishing SSH tunnel...")
        Wait(150)

        print("Bypassing security protocols...")
        Wait(600)
        
        print("Identifying vulnerabilities...")
        Wait(150)

        print("Access granted. Sending a self-destruct signal...")

        for i = 1, 3 do
            print("The vehicle will be destroyed in " .. (4 - i) .. "...")
            Wait(1000)
        end

        network_utils.request_control_of(vehicle_to_explode)
        VEHICLE.EXPLODE_VEHICLE(vehicle_to_explode, true, false) -- Explode locally.
        -- NETWORK.NETWORK_EXPLODE_VEHICLE is often used for synced explosions in multiplayer.
        NETWORK.NETWORK_EXPLODE_VEHICLE(vehicle_to_explode, true, false, NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(vehicle_to_explode))
        
        local explosion_coords = ENTITY.GET_ENTITY_COORDS(vehicle_to_explode, true)
        FIRE.ADD_EXPLOSION(explosion_coords.x, explosion_coords.y, explosion_coords.z, 4, 10000.0, true, false, 1.0, false) -- Add a larger explosion effect.

        Wait(1000)

        if not ENTITY.DOES_ENTITY_EXIST(vehicle_to_explode) or ENTITY.IS_ENTITY_DEAD(vehicle_to_explode) then
            printColoured("green", "The vehicle has been successfully destroyed.")
        else
            DisplayError(false, "Failed to destroy the vehicle.")
        end
    else
        DisplayError(false, "Selected entity is not a vehicle.")
    end
end

--- Command to fully fix a vehicle selected by the user.
function fix_vehicle_command()
    local vehicle_to_fix = input_utils.input_vehicle()

    if not vehicle_to_fix or vehicle_to_fix == 0.0 or not ENTITY.DOES_ENTITY_EXIST(vehicle_to_fix) then
        DisplayError(false, "Invalid input or no vehicle selected.")
        return nil
    end

    network_utils.request_control_of(vehicle_to_fix)
    VEHICLE.SET_VEHICLE_FIXED(vehicle_to_fix) -- Fixes visual damage.
    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(vehicle_to_fix, 1000.0) -- Restore engine health.
    VEHICLE.SET_VEHICLE_BODY_HEALTH(vehicle_to_fix, 1000.0)   -- Restore body health.
    printColoured("green", "Vehicle " .. vehicle_to_fix .. " has been fixed.")
end

--- Command to open the tuning menu for a vehicle selected by the user.
function vehicle_tuning_command()
    local vehicle_to_tune = input_utils.input_vehicle()

    if not vehicle_to_tune or vehicle_to_tune == 0.0 or not ENTITY.DOES_ENTITY_EXIST(vehicle_to_tune) then
        DisplayError(false, "Invalid input or no vehicle selected.")
        return nil
    end

    tune_vehicle(vehicle_to_tune)
end

--- Command to open the control menu for a vehicle selected by the user.
function vehicle_control_command()
    local vehicle_to_control = input_utils.input_vehicle()

    if not vehicle_to_control or vehicle_to_control == 0.0 or not ENTITY.DOES_ENTITY_EXIST(vehicle_to_control) then
        DisplayError(false, "Invalid input or no vehicle selected.")
        return nil
    end

    control_vehicle(vehicle_to_control)
end

--- Command to open the modification menu for a vehicle selected by the user.
function vehicle_mod_command()
    local vehicle_to_modify = input_utils.input_vehicle()

    if not vehicle_to_modify or vehicle_to_modify == 0.0 or not ENTITY.DOES_ENTITY_EXIST(vehicle_to_modify) then
        DisplayError(false, "Invalid input or no vehicle selected.")
        return nil
    end

    modify_vehicle_properties(vehicle_to_modify)
end

--- Command to set the invincibility state of a vehicle selected by the user.
function set_vehicle_invincible_command()
    local vehicle_to_modify = input_utils.input_vehicle()

    if not vehicle_to_modify or vehicle_to_modify == 0.0 or not ENTITY.DOES_ENTITY_EXIST(vehicle_to_modify) then
        DisplayError(false, "Invalid input or no vehicle selected.")
        return nil
    end

    local user_input = Input("Set the invincibility of the selected vehicle? [Y/n]: ", true)

    if user_input == "y" then
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle_to_modify, true)
        printColoured("green", "Vehicle " .. vehicle_to_modify .. " is now invincible.")
    elseif user_input == "n" then
        ENTITY.SET_ENTITY_INVINCIBLE(vehicle_to_modify, false)
        print("Vehicle " .. vehicle_to_modify .. " is no longer invincible.")
    end 
end

--- Command to set the homing missile lock-on state for a vehicle selected by the user.
function set_vehicle_lock_on_command()
    local vehicle_to_modify = input_utils.input_vehicle()

    if not vehicle_to_modify or vehicle_to_modify == 0.0 or not ENTITY.DOES_ENTITY_EXIST(vehicle_to_modify) then
        DisplayError(false, "Invalid input or no vehicle selected.")
        return nil
    end

    local user_input = Input("Allow other players from locking on to the selected vehicle? [Y/n]: ", true)

    if user_input == "y" then
        -- Original logic had true/false inverted for this command compared to ModifyVehicle's option 4.
        -- Assuming "y" means "allow lock-on", so setting to true.
        VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON(vehicle_to_modify, true, false)
        VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(vehicle_to_modify, true, false)
        printColoured("green", "Homing missile lock-on allowed for vehicle " .. vehicle_to_modify .. ".")
    elseif user_input == "n" then
        VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON(vehicle_to_modify, false, false)
        VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(vehicle_to_modify, false, false)
        print("Homing missile lock-on disabled for vehicle " .. vehicle_to_modify .. ".")
    end 
end

--- Command to save the player's current vehicle (or a selected one) to a file.
function save_vehicle_command()
    local vehicle_to_save = input_utils.input_vehicle()
    
    if not vehicle_to_save or vehicle_to_save == 0.0 or not ENTITY.DOES_ENTITY_EXIST(vehicle_to_save) then
        DisplayError(false, "Failed to get a valid vehicle to save.")
        return nil
    end

    save_vehicle(vehicle_to_save)
end

--- Command to create a vehicle from a previously saved configuration.
function create_saved_vehicle_command()
    local iterations = 0
    local saved_vehicle_data = nil
    local vehicles_list = JsonReadList("saved_vehicles.json") or {} -- Ensure list is not nil.

    local saved_vehicle_display_names = {}
    for _, vehicle_entry in ipairs(vehicles_list) do
        table.insert(saved_vehicle_display_names, vehicle_entry.name .. "\t" .. vehicle_entry.modelName)
    end
    
    local selected_index = InputFromList("Enter which vehicle you want to create: ", saved_vehicle_display_names)

    if selected_index == -1 then
        print("Vehicle creation cancelled.")
        return nil
    end

    saved_vehicle_data = vehicles_list[selected_index + 1] -- +1 for Lua 1-indexing.

    if saved_vehicle_data == nil then
        DisplayError(false, "Vehicle data not found for selected entry.")
        return
    end

    local failed_to_load = false
    local model_hash = saved_vehicle_data["model"]

    if STREAMING.IS_MODEL_VALID(model_hash) then
        STREAMING.REQUEST_MODEL(model_hash)
        while not STREAMING.HAS_MODEL_LOADED(model_hash) and not failed_to_load do
            if iterations > 50 then
                DisplayError(false, "Failed to load the model: " .. saved_vehicle_data.modelName .. ".")
                failed_to_load = true
            end
            Wait(5)
            iterations = iterations + 1
        end
        
        if not failed_to_load then
            local player_ped = PLAYER.PLAYER_PED_ID()
            local player_coords = ENTITY.GET_ENTITY_COORDS(player_ped, true)

            -- Create the vehicle near the player.
            local created_vehicle_handle = VEHICLE.CREATE_VEHICLE(model_hash, player_coords.x + 3.5, player_coords.y + 3.0, player_coords.z + 0.5, 0.0, false, false, false)
            network_utils.register_as_network(created_vehicle_handle)

            if created_vehicle_handle ~= 0.0 then
                VEHICLE.SET_VEHICLE_MOD_KIT(created_vehicle_handle, 0) -- Apply default mod kit first.

                -- Apply saved modifications.
                for i = 0, 24 do
                    if saved_vehicle_data["mod" .. i] ~= nil then
                        if i >= 17 and i <= 22 then -- Toggleable mods
                            VEHICLE.TOGGLE_VEHICLE_MOD(created_vehicle_handle, i, saved_vehicle_data["mod" .. i] == 1)
                        else -- Standard mods
                            VEHICLE.SET_VEHICLE_MOD(created_vehicle_handle, i, saved_vehicle_data["mod" .. i], true)
                        end
                    end
                end

                VEHICLE.SET_VEHICLE_DIRT_LEVEL(created_vehicle_handle, saved_vehicle_data["dirtLevel"])
                VEHICLE.SET_VEHICLE_ENVEFF_SCALE(created_vehicle_handle, saved_vehicle_data["paintFade"])
                
                VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(created_vehicle_handle, saved_vehicle_data["xenonColorIndex"])
                -- `bulletproofTyres` in saved data is `true` if bulletproof, `GET_VEHICLE_TYRES_CAN_BURST` is `true` if can burst.
                -- So, if `bulletproofTyres` is true (1.0), `SET_VEHICLE_TYRES_CAN_BURST` needs `false`.
                VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(created_vehicle_handle, not (saved_vehicle_data["bulletproofTyres"] == 1.0))

                VEHICLE.SET_VEHICLE_MOD(created_vehicle_handle, 48, saved_vehicle_data["livery"], 0) -- Livery
                VEHICLE.SET_VEHICLE_LIVERY2(created_vehicle_handle, saved_vehicle_data["livery2"]) -- Secondary livery
                VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(created_vehicle_handle, saved_vehicle_data["plateText"])
                VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(created_vehicle_handle, saved_vehicle_data["plateTextIndex"])
                VEHICLE.SET_VEHICLE_WINDOW_TINT(created_vehicle_handle, saved_vehicle_data["windowsTint"])
                
                -- Apply neon colors and states.
                VEHICLE.SET_VEHICLE_NEON_ENABLED(created_vehicle_handle, 0, saved_vehicle_data["neonEnabledLeft"] == 1.0)
                VEHICLE.SET_VEHICLE_NEON_ENABLED(created_vehicle_handle, 1, saved_vehicle_data["neonEnabledRight"] == 1.0)
                VEHICLE.SET_VEHICLE_NEON_ENABLED(created_vehicle_handle, 2, saved_vehicle_data["neonEnabledFront"] == 1.0)
                VEHICLE.SET_VEHICLE_NEON_ENABLED(created_vehicle_handle, 3, saved_vehicle_data["neonEnabledBack"] == 1.0)
                VEHICLE.SET_VEHICLE_NEON_COLOUR(created_vehicle_handle, saved_vehicle_data["neonR"], saved_vehicle_data["neonG"], saved_vehicle_data["neonB"])
                
                -- Apply main vehicle colors.
                VEHICLE.SET_VEHICLE_COLOURS(created_vehicle_handle, saved_vehicle_data["primaryColor"], saved_vehicle_data["secondaryColor"])
                VEHICLE.SET_VEHICLE_EXTRA_COLOURS(created_vehicle_handle, saved_vehicle_data["pearlColor"], saved_vehicle_data["wheelColor"])

                -- Apply custom colors if they exist in saved data.
                if saved_vehicle_data["customPrimaryR"] then
                    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(created_vehicle_handle, saved_vehicle_data["customPrimaryR"], saved_vehicle_data["customPrimaryG"], saved_vehicle_data["customPrimaryB"])
                end
                if saved_vehicle_data["customSecondaryR"] then
                    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(created_vehicle_handle, saved_vehicle_data["customSecondaryR"], saved_vehicle_data["customSecondaryG"], saved_vehicle_data["customSecondaryB"])
                end

                -- Apply roof state for convertibles.
                if VEHICLE.IS_VEHICLE_A_CONVERTIBLE(created_vehicle_handle, false) then
                    -- Original logic `RAISE_CONVERTIBLE_ROOF(veh, savedVehicle["roofState"] == 1.0)`
                    -- This function actually toggles, so if state is 1 (raised), it would try to raise it again.
                    -- A better approach would be to check current state and then raise/lower if different.
                    -- For simplicity, keeping original logic's intent of setting state directly.
                    if saved_vehicle_data["roofState"] == 0 then -- 0 is lowered, 1 is raised
                        VEHICLE.LOWER_CONVERTIBLE_ROOF(created_vehicle_handle, false)
                    elseif saved_vehicle_data["roofState"] == 1 then
                        VEHICLE.RAISE_CONVERTIBLE_ROOF(created_vehicle_handle, false)
                    end
                end

                -- Apply extra parts states.
                for i = 1, 10 do
                    if VEHICLE.DOES_EXTRA_EXIST(created_vehicle_handle, i) then
                        -- Check if the extra key exists in saved data, then apply its boolean value.
                        if saved_vehicle_data["extra" .. i] ~= nil then
                            VEHICLE.SET_VEHICLE_EXTRA(created_vehicle_handle, i, saved_vehicle_data["extra" .. i] == true)
                        end
                    end
                end

                VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(created_vehicle_handle, saved_vehicle_data["tyreSmokeR"], saved_vehicle_data["tyreSmokeG"], saved_vehicle_data["tyreSmokeB"])

                if saved_vehicle_data["isModed"] then
                    if saved_vehicle_data["engineSound"] then
                        set_vehicle_engine_sound(created_vehicle_handle, saved_vehicle_data["engineSound"])
                    end
                end

                -- Add a blip for the newly created vehicle.
                local blip_handle = HUD.ADD_BLIP_FOR_ENTITY(created_vehicle_handle)
                HUD.SET_BLIP_AS_FRIENDLY(blip_handle, true)
                HUD.SET_BLIP_SPRITE(blip_handle, map_utils.get_blip_from_entity_model(model_hash))
                HUD.SET_BLIP_COLOUR(blip_handle, blip_enums.BlipColour.BLUE_2)
                HUD.SET_BLIP_DISPLAY(blip_handle, blip_enums.BlipDisplay.SELECTABLE_SHOWS_ON_BOTH_MAPS)
                
                -- Prompt to get into the vehicle.
                local get_in_input = Input("Do you want to get in? [Y/n]: ", true)
                if get_in_input == "y" then
                    PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), created_vehicle_handle, -1)
                    create_tuning_fx(created_vehicle_handle, 4.0)
                end
                
                printColoured("green", "The vehicle has been successfully created. Vehicle ID is " .. created_vehicle_handle .. ".")

                -- Add to internal tracking lists.
                table.insert(created_vehicle_models, saved_vehicle_data["modelName"])
                table.insert(created_vehicle_ids, created_vehicle_handle)
            else
                DisplayError(false, "Failed to create vehicle entity from saved data.")
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash) -- Release model.
        end
    else
        DisplayError(false, "Failed to load vehicle model from saved data. Model hash invalid.")
    end
end

--- Breaks out of the "View All Vehicles" mode, cleaning up resources.
function break_view_all_vehicles()
    -- Delete the camera.
    if view_all_vehicles_camera then
        mission_utils.delete_camera(view_all_vehicles_camera)
        view_all_vehicles_camera = nil
    end

    -- Allow the player to control their character again.
    PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), true, 0)
    STREAMING.SET_FOCUS_ENTITY(PLAYER.PLAYER_PED_ID())

    -- Delete the currently viewed vehicle.
    if view_all_vehicles_current_vehicle and ENTITY.DOES_ENTITY_EXIST(view_all_vehicles_current_vehicle) then
        network_utils.request_control_of(view_all_vehicles_current_vehicle)
        DeleteVehicle(view_all_vehicles_current_vehicle)
        -- Redundant check and deletion, but kept for fidelity if DeleteVehicle is not immediate.
        if ENTITY.DOES_ENTITY_EXIST(view_all_vehicles_current_vehicle) then
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(view_all_vehicles_current_vehicle, -1000.0, 1000.0, 0.0, true, true, true)
            DeleteVehicle(view_all_vehicles_current_vehicle)
        end
        view_all_vehicles_current_vehicle = nil
    end

    is_viewing_all_vehicles = false -- Set flag to inactive.
    print("") -- Newline for cleaner console output.
    printColoured("green", "Exited 'View All Vehicles' mode.")
end

--- Spawns a vehicle for the "View All Vehicles" mode.
-- Handles loading the model and cleaning up the previous vehicle.
-- @param vehicle_model_name string The model name of the vehicle to spawn.
-- @param spawn_coords table A table with x, y, z coordinates for spawning.
-- @returns number The handle of the spawned vehicle, or nil if failed.
function spawn_vehicle_for_viewer(vehicle_model_name, spawn_coords)
    local iterations = 0
    -- Delete the old vehicle if it exists.
    if view_all_vehicles_current_vehicle and ENTITY.DOES_ENTITY_EXIST(view_all_vehicles_current_vehicle) then
        network_utils.request_control_of(view_all_vehicles_current_vehicle)
        DeleteVehicle(view_all_vehicles_current_vehicle)
        -- Redundant check and deletion, but kept for fidelity if DeleteVehicle is not immediate.
        if ENTITY.DOES_ENTITY_EXIST(view_all_vehicles_current_vehicle) then
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(view_all_vehicles_current_vehicle, 0.0, 0.0, 0.0, true, true, true)
            DeleteVehicle(view_all_vehicles_current_vehicle)
        end
        view_all_vehicles_current_vehicle = nil
    end
    
    -- Spawn the new vehicle.
    local model_hash = MISC.GET_HASH_KEY(vehicle_model_name)
    if STREAMING.IS_MODEL_VALID(model_hash) then
        STREAMING.REQUEST_MODEL(model_hash)
        while not STREAMING.HAS_MODEL_LOADED(model_hash) do
            if iterations > 50 then
                print("") -- Newline for error message.
                DisplayError(false, "Failed to load the model: " .. vehicle_model_name .. ".")
                break_view_all_vehicles()
                return nil
            end
            Wait(5)
            iterations = iterations + 1
        end
    else
        print("") -- Newline for error message.
        DisplayError(false, "Unable to continue execution because the model '" .. vehicle_model_name .. "' is not valid.")
        break_view_all_vehicles()
        return nil
    end

    -- Create the vehicle.
    view_all_vehicles_current_vehicle = VEHICLE.CREATE_VEHICLE(model_hash, spawn_coords.x, spawn_coords.y, spawn_coords.z, 0.0, false, true, false)

    VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(view_all_vehicles_current_vehicle, 0)
    STREAMING.SET_FOCUS_ENTITY(view_all_vehicles_current_vehicle) -- Focus camera on the new vehicle.
    -- Release model and mark entity as no longer needed (for cleanup by game engine).
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash)
    --ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(view_all_vehicles_current_vehicle) -- Direct handle, no need for NewVehicle/Delete.

    ResetLineAndPrint(vehicle_model_name) -- Print model name on the same line.
    return view_all_vehicles_current_vehicle
end

--- Changes the currently displayed vehicle in "View All Vehicles" mode.
-- @param direction number The direction to change (1 for next, -1 for previous).
function change_viewed_vehicle(direction)
    view_all_vehicles_list_vehicle_index = view_all_vehicles_list_vehicle_index + direction
    if view_all_vehicles_list_vehicle_index > #view_all_vehicles_list then
        view_all_vehicles_list_vehicle_index = 1 -- Loop back to start.
    elseif view_all_vehicles_list_vehicle_index < 1 then
        view_all_vehicles_list_vehicle_index = #view_all_vehicles_list -- Loop to end.
    end

    AUDIO.PLAY_SOUND_FRONTEND(-1, "SELECT", "HUD_LIQUOR_STORE_SOUNDSET", true) -- Play a sound effect.

    -- Spawn the new vehicle.
    spawn_vehicle_for_viewer(view_all_vehicles_list[view_all_vehicles_list_vehicle_index], {x = -482.3, y = -133.3, z = 37.6})
end

--- Initiates the "View All Vehicles" command, allowing the player to browse available vehicle models.
function view_all_vehicles_command()
    if #view_all_vehicles_list == 0 then
        DisplayError(false, "No vehicles found in 'vehicles.json'. Please ensure the file exists and is populated.")
        return nil
    end

    is_viewing_all_vehicles = true
    view_all_vehicles_list_vehicle_index = 1

    print("") -- Newline for cleaner console output.
    -- Set up the camera at predefined coordinates.
    local camera_coords = {x = -486.89999389648, y = -130.19999694824, z = 39.5}
    local camera_heading = 234.0

    -- Create and activate the camera.
    view_all_vehicles_camera = mission_utils.create_camera(camera_coords.x, camera_coords.y, camera_coords.z, camera_heading, 0.0, 0.0, 0)

    -- Disable player control.
    PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), false, 0)

    -- Spawn the first vehicle in the list.
    spawn_vehicle_for_viewer(view_all_vehicles_list[view_all_vehicles_list_vehicle_index], {x = -482.3, y = -133.3, z = 37.6})
    
    -- Main loop for viewing vehicles.
    while true do
        if not is_viewing_all_vehicles then
            return nil -- Exit if the viewing mode is no longer active.
        end
        
        -- Handle key presses for navigation and selection.
        if IsPressedKey(view_all_vehicles_next_key) then
            change_viewed_vehicle(1)
        elseif IsPressedKey(view_all_vehicles_back_key) then
            change_viewed_vehicle(-1)
        elseif IsPressedKey(view_all_vehicles_select_key) then
            -- When select key is pressed, break the loop and exit.
            -- local current_camera_coords = CAM.GET_CAM_COORD(view_all_vehicles_camera) -- DEBUG line.
            -- print(current_camera_coords.x, current_camera_coords.y, current_camera_coords.z) -- DEBUG line.
            break_view_all_vehicles()
            break -- Exit the while loop.
        --[[
        -- DEBUG camera movement (original commented out, kept for fidelity).
        elseif IsPressedKey(0x41) then -- A key
            camera_coords.y = camera_coords.y + 1.0
            CAM.SET_CAM_COORD(view_all_vehicles_camera, camera_coords.x, camera_coords.y, camera_coords.z)
            Wait(100)
        elseif IsPressedKey(0x44) then -- D key
            camera_coords.y = camera_coords.y - 1.0
            CAM.SET_CAM_COORD(view_all_vehicles_camera, camera_coords.x, camera_coords.y, camera_coords.z)
            Wait(100)
        elseif IsPressedKey(0x57) then -- W key
            camera_coords.x = camera_coords.x + 1.0
            CAM.SET_CAM_COORD(view_all_vehicles_camera, camera_coords.x, camera_coords.y, camera_coords.z)
            Wait(100)
        elseif IsPressedKey(0x53) then -- S key
            camera_coords.x = camera_coords.x - 1.0
            CAM.SET_CAM_COORD(view_all_vehicles_camera, camera_coords.x, camera_coords.y, camera_coords.z)
            Wait(100)
        elseif IsPressedKey(0x20) then -- Space key
            camera_coords.z = camera_coords.z + 1.0
            CAM.SET_CAM_COORD(view_all_vehicles_camera, camera_coords.x, camera_coords.y, camera_coords.z)
            Wait(100)
        elseif IsPressedKey(0x11) then -- Ctrl key
            camera_coords.z = camera_coords.z - 1.0
            CAM.SET_CAM_COORD(view_all_vehicles_camera, camera_coords.x, camera_coords.y, camera_coords.z)
            Wait(100)
        ]]
        end

        Wait(10) -- Small delay to prevent high CPU usage.
    end
end

--- Initializes various script settings, primarily hotkeys and global variable states from configuration.
function initialize_script_settings()
    -- Read initial states for global variables from config and convert booleans to numbers (0.0 or 1.0).
    local auto_fix_vehicle_enabled = math_utils.boolean_to_number(config_utils.get_feature_setting("VehicleOptions", "AutoFixVehicle"))
    local disable_lock_on_enabled = math_utils.boolean_to_number(config_utils.get_feature_setting("VehicleOptions", "DisableLockOn"))

    -- Convert hotkey strings from config to key codes.
    view_all_vehicles_next_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "ViewAllVehiclesNextKey"))
    view_all_vehicles_back_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "ViewAllVehiclesBackKey"))
    view_all_vehicles_select_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "ViewAllVehiclesSelectKey"))

    -- Set initial global variable values.
    SetGlobalVariableValue("AutoFixCurrentVehicleState", auto_fix_vehicle_enabled)
    SetGlobalVariableValue("DisableLockOnCurrentVehicleState", disable_lock_on_enabled)
end

-- Define a dictionary with commands and their corresponding functions.
-- These commands will be bound to the game's command system.
local commands_to_register = {
    ["vehicle list"] = manage_created_vehicles,
    ["modified vehicles"] = manage_modified_vehicles,
    ["add to vehicle list"] = add_vehicle_to_list_command,
    ["create vehicle"] = create_vehicle_command,
    ["delete vehicle"] = delete_vehicle_command,
    ["explode vehicle"] = explode_vehicle_command,
    ["fix vehicle"] = fix_vehicle_command,
    ["vehicle tuning"] = vehicle_tuning_command,
    ["vehicle control"] = vehicle_control_command,
    ["vehicle mod"] = vehicle_mod_command,
    ["set veh invincible"] = set_vehicle_invincible_command,
    ["set vehicle lock on"] = set_vehicle_lock_on_command,
    ["save vehicle"] = save_vehicle_command,
    ["create saved vehicle"] = create_saved_vehicle_command,
    ["view all vehicles"] = view_all_vehicles_command
}

-- Seed the random number generator using the current time.
math.randomseed(os.time())

-- Initialize script settings (hotkeys, global states).
initialize_script_settings()

-- Loop to register all defined commands.
for command_name, command_function in pairs(commands_to_register) do
    if not BindCommand(command_name, command_function) then
        DisplayError(true, "Failed to register the command: " .. command_name)
    end
end

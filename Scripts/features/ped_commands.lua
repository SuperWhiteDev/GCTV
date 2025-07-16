-- This script defines commands related to managing peds in the game,
-- including creating, controlling, and viewing them.

-- Loading necessary utility modules.
local network_utils = require("network_utils") -- Module for network utilities (e.g., requesting control).
local map_utils = require("map_utils")       -- Module for map-related utilities (e.g., waypoints, blips).
local vehicle_utils = require("vehicle_utils") -- Module for vehicle-related utilities.
local math_utils = require("math_utils")   -- Module for mathematical utilities.
local ped_utils = require("ped_utils")         -- Module for ped-related utilities (e.g., random ped models).
local mission_utils = require("mission_utils") -- Module for mission-related utilities (e.g., cameras).
local config_utils = require("config_utils")   -- Module for configuration utilities.

local blip_enums = require("blip_enums")           -- Enumerations for blip sprites and colors.

-- Hotkey variables for the "View All Peds" command, initialized from configuration.
local view_all_peds_next_key = nil
local view_all_peds_back_key = nil
local view_all_peds_select_key = nil

-- Lists to keep track of created peds by the script.
local created_peds_models = {} -- Stores model names of created peds.
local created_peds_ids = {}    -- Stores entity IDs (handles) of created peds.

-- Variables for the "View All Peds" command functionality.
local view_all_peds_list = JsonReadList("peds.json") -- List of available ped models from peds.json.
local view_all_peds_list_index = 1                   -- Current index in the ped list (1-based).
local view_all_peds_animations = { "WORLD_HUMAN_AA_COFFEE", "WORLD_HUMAN_SMOKING_POT" } -- Sample animations.
local view_all_peds_current_ped = nil                -- The ped entity currently being viewed.
local still_viewing_all_peds = false                 -- Flag to control the viewing loop.
local view_all_peds_camera = nil                     -- Camera used for viewing peds.

--- Gives one or two specified weapons to a given ped.
-- @param ped number The ped entity ID to give weapons to.
function give_weapons_to_ped(ped)
    -- Prompt for the first weapon model name.
    local first_weapon_name = Input("Enter weapon (https://forge.plebmasters.de/weapons): ", false)
    local first_weapon_hash = MISC.GET_HASH_KEY(first_weapon_name)
    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(ped, first_weapon_hash, 1000, true)

    -- Prompt to ask if a second weapon should be given.
    local give_second_weapon_input = Input("You want to give ped a second weapon? [Y/n]: ", true)

    if give_second_weapon_input == "y" then
        -- Prompt for the second weapon model name.
        local second_weapon_name = Input("Enter weapon (https://forge.plebmasters.de/weapons): ", false)
        local second_weapon_hash = MISC.GET_HASH_KEY(second_weapon_name)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(ped, second_weapon_hash, 1000, true)
    end
end

--- Makes a specified ped a bodyguard for another ped.
-- Configures the bodyguard's behavior, combat, and optionally gives them weapons.
-- @param player_ped number The ped entity ID of the player/target to guard.
-- @param bodyguard_ped number The ped entity ID to make a bodyguard.
function make_ped_bodyguard_for_ped(player_ped, bodyguard_ped)
    TASK.CLEAR_PED_TASKS(bodyguard_ped)
    TASK.CLEAR_PED_SECONDARY_TASK(bodyguard_ped)
    
    -- Add bodyguard to the player's group.
    local player_ped_group = PED.GET_PED_GROUP_INDEX(player_ped)
    PED.SET_PED_AS_GROUP_MEMBER(bodyguard_ped, player_ped_group)

    -- Prompt to ask if the bodyguard should be invincible.
    local make_invincible_input = Input("Make the bodyguard invincible? [Y/n]: ", true)
    if make_invincible_input == "y" then
        ENTITY.SET_ENTITY_INVINCIBLE(bodyguard_ped, true)
    end 

    -- Configure bodyguard's combat behavior.
    PED.SET_PED_CAN_RAGDOLL(bodyguard_ped, false)
    PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(bodyguard_ped, false)
    PED.SET_PED_COMBAT_RANGE(bodyguard_ped, 500)
    PED.SET_PED_ALERTNESS(bodyguard_ped, 100)
    PED.SET_PED_ACCURACY(bodyguard_ped, 100)
    PED.SET_PED_CAN_SWITCH_WEAPON(bodyguard_ped, true) -- Allows switching weapons.
    PED.SET_PED_SHOOT_RATE(bodyguard_ped, 200)
    PED.SET_PED_KEEP_TASK(bodyguard_ped, true)
    TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(bodyguard_ped, 5000, 0)

    -- Prompt to ask if the bodyguard should be given a weapon.
    local give_weapon_input = Input("You want to give bodyguard the weapon? [Y/n]: ", true)

    if give_weapon_input == "y" then
        local weapon_options = { "Random", "Custom" }
        local selected_weapon_option_index = InputFromList("Enter the weapon you want to give to the bodyguard: ", weapon_options)

        if selected_weapon_option_index == 0 then -- Random weapons
            local first_weapons = { "WEAPON_BATTLERIFLE", "Carbine Rifle", "WEAPON_TACTICALRIFLE", "WEAPON_COMBATMG_MK2", "WEAPON_CARBINERIFLE_MK2", "Military Rifle" }
            local second_weapons = { "WEAPON_TECPISTOL", "Heavy Pistol", "WEAPON_PISTOLXM3", "WEAPON_PISTOL_MK2", "WEAPON_REVOLVER_MK2" }
            local grenades = { "WEAPON_GRENADE", "Tear Gas", "Molotov" }
            
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(bodyguard_ped, MISC.GET_HASH_KEY(first_weapons[math.random(1, #first_weapons)]), 1000, true)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(bodyguard_ped, MISC.GET_HASH_KEY(second_weapons[math.random(1, #second_weapons)]), 1000, true)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(bodyguard_ped, MISC.GET_HASH_KEY(grenades[math.random(1, #grenades)]), 1000, true)
        elseif selected_weapon_option_index == 1 then -- Custom weapons
            give_weapons_to_ped(bodyguard_ped)
        end
    end 

    PED.SET_PED_CAN_SWITCH_WEAPON(bodyguard_ped, true)
    PED.SET_PED_KEEP_TASK(bodyguard_ped, true)
    PED.SET_PED_GENERATES_DEAD_BODY_EVENTS(bodyguard_ped, true)
end

--- Provides a menu to control a specific ped.
-- Offers various actions like movement, combat behavior, animations, and status changes.
-- @param ped number The ped entity ID to control.
function control_ped(ped)
    local control_options = {
        "Go to", "Drive to", "Stop driving", "Make angry", "Make friendly",
        "Make come to vehicle", "Make bodyguard", "Freeze ped", "Set action",
        "Play animation", "Set invincible", "Seat to", "Heal", "Fill armor", "Kill"
    }
    local selected_option_index = InputFromList("Choose what you want to: ", control_options)

    network_utils.request_control_of(ped) -- Request network control of the ped.

    if selected_option_index == 0 then -- Go to
        local go_to_options = { "Waypoint", "Current position", "Custom" }
        local selected_go_to_option = InputFromList("Choose where you want the ped to go: ", go_to_options)

        if selected_go_to_option == 0 then -- Waypoint
            local coords = map_utils.get_waypoint_coords()
            if not coords then
                print("Please choose a waypoint first")
                return nil
            end
            TASK.TASK_FLUSH_ROUTE()
            TASK.TASK_EXTEND_ROUTE(coords.x, coords.y, coords.z)
            TASK.TASK_FOLLOW_POINT_ROUTE(ped, 1.0, 0)
        elseif selected_go_to_option == 1 then -- Current player position
            local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            TASK.TASK_FLUSH_ROUTE()
            TASK.TASK_EXTEND_ROUTE(coords.x, coords.y, coords.z)
            TASK.TASK_FOLLOW_POINT_ROUTE(ped, 1.0, 0)
        elseif selected_go_to_option == 2 then -- Custom coordinates
            local coord_x_str = Input("Enter X coord: ", false)
            local coord_y_str = Input("Enter Y coord: ", false)
            local coord_z_str = Input("Enter Z coord: ", false)

            local coord_x = tonumber(coord_x_str)
            local coord_y = tonumber(coord_y_str)
            local coord_z = tonumber(coord_z_str)

            if coord_x and coord_y and coord_z then
                TASK.TASK_FLUSH_ROUTE()
                TASK.TASK_EXTEND_ROUTE(coord_x, coord_y, coord_z)
                TASK.TASK_FOLLOW_POINT_ROUTE(ped, 1.0, 0)
            else
                DisplayError(false, "Incorrect coordinate input.")
            end
        end
    elseif selected_option_index == 1 then -- Drive to
        local driving_style = nil
        local drive_speed = nil

        local drive_fast_input = Input("You want the ped to drive fast? [Y/n]: ", true)
        if drive_fast_input == "y" then
            driving_style = 262204 -- Aggressive driving style
        elseif drive_fast_input == "n" then
            driving_style = 399 -- Normal driving style
        end

        local drive_to_options = { "Waypoint", "Local player position", "Custom" }
        local selected_drive_to_option = InputFromList("Choose where you want the ped to go: ", drive_to_options)

        local destination_coords = nil
        if selected_drive_to_option == 0 then -- Waypoint
            destination_coords = map_utils.get_waypoint_coords()
            if not destination_coords then
                print("Please choose a waypoint first")
                return nil
            end
        elseif selected_drive_to_option == 1 then -- Local player position
            destination_coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        elseif selected_drive_to_option == 2 then -- Custom
            local coord_x_str = Input("Enter X coord: ", false)
            local coord_y_str = Input("Enter Y coord: ", false)
            local coord_z_str = Input("Enter Z coord: ", false)
            
            local coord_x = tonumber(coord_x_str)
            local coord_y = tonumber(coord_y_str)
            local coord_z = tonumber(coord_z_str)

            if coord_x and coord_y and coord_z then
                destination_coords = { x = coord_x, y = coord_y, z = coord_z }
            else
                DisplayError(false, "Incorrect coordinate input.")
                return nil
            end
        end

        if destination_coords then
            local ped_vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, true)
            if ped_vehicle ~= 0.0 then
                local vehicle_model = ENTITY.GET_ENTITY_MODEL(ped_vehicle)
                drive_speed = VEHICLE.GET_VEHICLE_MODEL_ESTIMATED_MAX_SPEED(vehicle_model)
                if drive_speed < 40.0 then -- Ensure minimum speed
                    drive_speed = 40.0
                end
                
                local vehicle_coords = ENTITY.GET_ENTITY_COORDS(ped_vehicle, true)

                -- Choose between long-range or short-range drive task based on distance.
                if math_utils.get_distance_between_coords(vehicle_coords, destination_coords) >= 1000.0 then
                    TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(ped, ped_vehicle, destination_coords.x, destination_coords.y, destination_coords.z, drive_speed, driving_style, 25.0)
                else
                    TASK.TASK_VEHICLE_DRIVE_TO_COORD(ped, ped_vehicle, destination_coords.x, destination_coords.y, destination_coords.z, drive_speed, 1, vehicle_model, driving_style, 6, -1)
                end
            else
                print("Ped is not in a vehicle.") -- Added message for clarity
            end
        end
    elseif selected_option_index == 2 then -- Stop driving
        local ped_vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, true)

        local park_vehicle_input = Input("You want the ped to park the vehicle? [Y/n]: ", true)

        if park_vehicle_input == "y" then
            local vehicle_coords = ENTITY.GET_ENTITY_COORDS(ped_vehicle, true)
            TASK.TASK_VEHICLE_PARK(ped, ped_vehicle, vehicle_coords.x, vehicle_coords.y, vehicle_coords.z, 0.0, 1, 20.0, false)
        elseif park_vehicle_input == "n" then
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(ped_vehicle, 0.0)
            VEHICLE.SET_VEHICLE_ENGINE_ON(ped_vehicle, false, true, false)
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
            PED.SET_PED_INTO_VEHICLE(ped, ped_vehicle, -1) -- Keep ped in vehicle
        end
    elseif selected_option_index == 3 then -- Make angry
        PED.SET_PED_AS_ENEMY(ped, true)
        TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(ped, 10000.0, 0)
        PED.SET_PED_KEEP_TASK(ped, true)
    elseif selected_option_index == 4 then -- Make friendly
        local player_ped_group = PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID())
        PED.SET_PED_AS_GROUP_MEMBER(ped, player_ped_group)
    elseif selected_option_index == 5 then -- Make come to vehicle
        local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        if player_vehicle ~= 0.0 then
            TASK.TASK_ENTER_VEHICLE(ped, player_vehicle, 10000, 0, 1.0, 1, 0, 0)
        else
            print("Player is not in a vehicle.") -- Added message for clarity
        end 
        PED.SET_PED_KEEP_TASK(ped, true)
    elseif selected_option_index == 6 then -- Make bodyguard
        local target_player_id_str = Input("Enter player ID: ", false)
        local target_player_id = tonumber(target_player_id_str)

        if target_player_id then
            local target_player_ped = PLAYER.GET_PLAYER_PED(target_player_id)
            make_ped_bodyguard_for_ped(target_player_ped, ped)
        else
            DisplayError(false, "Incorrect player ID input.")
        end
    elseif selected_option_index == 7 then -- Freeze ped
        local freeze_input = Input("You want to freeze the ped? [Y/n]: ", true)

        if freeze_input == "y" then
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
            ENTITY.FREEZE_ENTITY_POSITION(ped, true)
        elseif freeze_input == "n" then
            ENTITY.FREEZE_ENTITY_POSITION(ped, false)
        end
    elseif selected_option_index == 8 then -- Set action (scenario)
        local actions = {
            "Drilling", "Cop", "Chin Ups", "Binoculars", "Hammering", "420", "Leaf Blower",
            "Musician", "Drinking Coffee", "Jogging", "Fishing", "Push Ups", "Sit Ups", "Yoga",
            "Gym Lad", "Stop action"
        }
        local action_names = {
            "WORLD_HUMAN_CONST_DRILL", "CODE_HUMAN_POLICE_INVESTIGATE", "PROP_HUMAN_MUSCLE_CHIN_UPS",
            "WORLD_HUMAN_BINOCULARS", "WORLD_HUMAN_HAMMERING", "WORLD_HUMAN_SMOKING_POT",
            "WORLD_HUMAN_GARDENER_LEAF_BLOWER", "WORLD_HUMAN_MUSICIAN", "WORLD_HUMAN_AA_COFFEE",
            "WORLD_HUMAN_JOG_STANDING", "WORLD_HUMAN_STAND_FISHING", "WORLD_HUMAN_PUSH_UPS",
            "WORLD_HUMAN_SIT_UPS", "WORLD_HUMAN_YOGA", "WORLD_HUMAN_MUSCLE_FREE_WEIGHTS"
        }
        local selected_action_index = InputFromList("Choose an action for the ped: ", actions)

        if selected_action_index == 15 then -- "Stop action"
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
        else
            TASK.TASK_START_SCENARIO_IN_PLACE(ped, action_names[selected_action_index + 1], 0, true)
        end
    elseif selected_option_index == 9 then -- Play animation
        local iterations = 0
        local animations = {
            "Pole Dance 1", "Pole Dance 2", "Pole Dance 3", "Stunned", "Situps", "Pushups", "Wave Arms",
            "Suicide", "On The Can", "On Fire", "Cower", "Private Dance", "BJ", "Stungun", "Air Fuck",
            "Air Fuck 2", "Stop animation"
        }
        local animation_names = {
            "pd_dance_01", "pd_dance_02", "pd_dance_03", "electrocute", "base", "base", "waving",
            "pistol_fp", "trevonlav_struggleloop", "on_fire", "kneeling_arrest_idle", "priv_dance_p1",
            "bj_loop_prostitute", "Damage", "shag_loop_a", "shag_loop_poppy"
        }
        local animation_dicts = {
            "mini@strip_club@pole_dance@pole_dance1", "mini@strip_club@pole_dance@pole_dance2",
            "mini@strip_club@pole_dance@pole_dance3", "ragdoll@human", "amb@world_human_sit_ups@male@base",
            "amb@world_human_push_ups@male@base", "random@car_thief@waving_ig_1", "mp_suicide",
            "timetable@trevor@on_the_toilet", "ragdoll@human", "random@arrests",
            "mini@strip_club@private_dance@part1", "mini@prostitutes@sexnorm_veh", "stungun@standing",
            "rcmpaparazzo_2", "rcmpaparazzo_2"
        }
        local selected_animation_index = InputFromList("Choose an animation for the ped: ", animations)

        if selected_animation_index == 16 then -- "Stop animation"
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
            TASK.CLEAR_PED_SECONDARY_TASK(ped)
        else
            STREAMING.REQUEST_ANIM_SET(animation_names[selected_animation_index + 1])
            STREAMING.REQUEST_ANIM_DICT(animation_dicts[selected_animation_index + 1])
            
            -- Wait for animation dictionary to load or timeout.
            while not STREAMING.HAS_ANIM_DICT_LOADED(animation_dicts[selected_animation_index + 1]) and iterations < 50 do
                iterations = iterations + 1
                Wait(1)
            end
            
            -- Play the animation if loaded.
            if STREAMING.HAS_ANIM_DICT_LOADED(animation_dicts[selected_animation_index + 1]) then
                TASK.TASK_PLAY_ANIM(ped, animation_dicts[selected_animation_index + 1], animation_names[selected_animation_index + 1], 1.0, 1.0, -1, 127, 0.0, false, false, false)
            else
                DisplayError(false, "Failed to load animation dictionary.")
            end
        end
    elseif selected_option_index == 10 then -- Set invincible
        local invincible_input = Input("Set the ped invincible? [Y/n]: ", true)

        if invincible_input == "y" then
            ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
        elseif invincible_input == "n" then
            ENTITY.SET_ENTITY_INVINCIBLE(ped, false)
        end
    elseif selected_option_index == 11 then -- Seat to (in vehicle)
        local ped_vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, true)
        if ped_vehicle ~= 0.0 then
            local seat_options = { "Driver seat", "Available passenger seat", "Custom" }
            local selected_seat_index = InputFromList("Choose where you want to seat the ped in the ped vehicle: ", seat_options)

            if selected_seat_index == 0 then -- Driver seat
                local current_driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ped_vehicle, -1, true)
                if current_driver ~= 0.0 then
                    PED.SET_PED_INTO_VEHICLE(current_driver, ped_vehicle, -2) -- Move current driver to passenger
                end
                PED.SET_PED_INTO_VEHICLE(ped, ped_vehicle, -1) -- Move target ped to driver seat
            elseif selected_seat_index == 1 then -- Available passenger seat
                PED.SET_PED_INTO_VEHICLE(ped, ped_vehicle, -2) -- -2 usually means first available passenger seat
            elseif selected_seat_index == 2 then -- Custom seat
                local seat_index_str = Input("Enter the seat index: ", false)
                local seat_index = tonumber(seat_index_str)
                
                if seat_index then
                    local current_passenger = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ped_vehicle, seat_index, true)
                    if current_passenger ~= 0.0 then
                        PED.SET_PED_INTO_VEHICLE(current_passenger, ped_vehicle, -2) -- Move current passenger to another seat
                    end
                    PED.SET_PED_INTO_VEHICLE(ped, ped_vehicle, seat_index)
                else
                    DisplayError(false, "Incorrect seat index input.")
                end
            end
        else
            print("Ped is not in a vehicle.") -- Added message for clarity
        end
    elseif selected_option_index == 12 then -- Heal
        ENTITY.SET_ENTITY_HEALTH(ped, PED.GET_PED_MAX_HEALTH(ped), 0, 0)
    elseif selected_option_index == 13 then -- Fill armor
        PED.SET_PED_ARMOUR(ped, 100)
    elseif selected_option_index == 14 then -- Kill
        ENTITY.SET_ENTITY_HEALTH(ped, 0, PLAYER.PLAYER_PED_ID(), 0)
    end
end

--- Command to manage created peds.
-- Allows controlling or deleting peds from the script's internal list.
function peds_list_command()
    if #created_peds_ids ~= 0 then
        local selected_ped_index = InputFromList("Choose the ped you want to interact with: ", created_peds_models)
        if selected_ped_index ~= -1 then
            local selected_ped_handle = created_peds_ids[selected_ped_index + 1] -- +1 for Lua 1-indexing

            local action_options = { "Control ped", "Delete" }
            local selected_action_index = InputFromList("Choose what you want to: ", action_options)

            if selected_action_index == 0 then -- Control ped
                control_ped(selected_ped_handle)
            elseif selected_action_index == 1 then -- Delete
                network_utils.request_control_of(selected_ped_handle)
                DeletePed(selected_ped_handle) -- Assuming DeletePed is a global GCTV function

                table.remove(created_peds_ids, selected_ped_index + 1)
                table.remove(created_peds_models, selected_ped_index + 1)
                print("Ped deleted successfully.") -- Confirmation message
            end
        end
    else
        print("There are no peds on the peds list yet.")
    end
end

--- Command to create a new ped in the game world.
-- Prompts for a ped model and type, then spawns and configures the ped.
function create_ped_command()
    local ped_model_hash = nil

    -- Prompt for ped model name.
    local model_name = Input("Enter ped model (https://forge.plebmasters.de/peds): ", false)

    -- If no model name entered, get a random one.
    if model_name == "" then
        model_name = ped_utils.get_random_ped_model_name()
    end

    ped_model_hash = MISC.GET_HASH_KEY(model_name)

    local failed_to_load = false
    local iterations = 0
    if STREAMING.IS_MODEL_VALID(ped_model_hash) then
        STREAMING.REQUEST_MODEL(ped_model_hash)
        -- Wait for model to load or timeout.
        while not STREAMING.HAS_MODEL_LOADED(ped_model_hash) and not failed_to_load do
            if iterations > 50 then
                DisplayError(false, "Failed to load the model: " .. model_name)
                failed_to_load = true
            end
            Wait(5)
            iterations = iterations + 1
        end
        
        if not failed_to_load then
            local spawn_coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)

            -- Prompt for ped type.
            local ped_type_str = Input("Enter ped type (https://alloc8or.re/gta5/doc/enums/ePedType.txt): ", false)
            local ped_type = tonumber(ped_type_str)

            if not ped_type then
                DisplayError(false, "Incorrect ped type input.")
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ped_model_hash)
                return nil
            end

            -- Create the ped.
            local created_ped = PED.CREATE_PED(ped_type, ped_model_hash, spawn_coords.x + 1.5, spawn_coords.y + 1.0, spawn_coords.z + 0.2, 0.0, false, true)

            if created_ped then
                network_utils.register_as_network(created_ped) -- Register ped for network synchronization.

                local ped_blip = HUD.ADD_BLIP_FOR_ENTITY(created_ped)
                HUD.SET_BLIP_AS_FRIENDLY(ped_blip, true)
                HUD.SET_BLIP_SPRITE(ped_blip, map_utils.get_blip_from_entity_model(ped_model_hash))
                HUD.SET_BLIP_COLOUR(ped_blip, 68) -- Green color
                HUD.SET_BLIP_DISPLAY(ped_blip, 6) -- Display on both maps

                TASK.TASK_LOOK_AT_ENTITY(created_ped, PLAYER.PLAYER_PED_ID(), 0, 1, 10)
                -- If player is in a vehicle, make the ped enter it.
                if PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), true) then
                    TASK.TASK_ENTER_VEHICLE(created_ped, PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false), 10000, 0, 1.0, 1, 0, 0)
                end 
                PED.SET_PED_KEEP_TASK(created_ped, true) -- Keep ped's task.

                -- Prompt to ask if the ped should be given a weapon.
                local give_weapon_input = Input("You want to give ped the weapon? [Y/n]: ", true)

                if give_weapon_input == "y" then
                    give_weapons_to_ped(created_ped)
                end

                printColoured("green", "Successfully created new ped. Ped ID is " .. created_ped)
                table.insert(created_peds_models, model_name)
                table.insert(created_peds_ids, created_ped)
            else
                DisplayError(false, "Failed to create ped entity.")
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ped_model_hash) -- Release model
        end
    else
        DisplayError(false, "Unable to continue execution because the model '" .. model_name .. "' is not valid.")
    end
end

--- Command to delete a ped by its handle.
-- @param ped_handle_input string The string input of the ped's handle.
function delete_ped_command()
    local ped_handle_str = Input("Enter ped handle: ", false)
    local ped_handle = tonumber(ped_handle_str)
    if ped_handle then
        network_utils.request_control_of(ped_handle)
        DeletePed(ped_handle) -- Assuming DeletePed is a global GCTV function
        print("Ped " .. ped_handle .. " deleted successfully.") -- Confirmation message
    else
        DisplayError(false, "Incorrect input: Please enter a valid ped handle.")
    end
end

--- Command to control a ped by its handle.
-- Prompts for a ped handle and then opens the control menu for that ped.
function ped_control_command()
    local ped_handle_str = Input("Enter ped handle: ", false)
    local ped_handle = tonumber(ped_handle_str)
    if ped_handle then
        control_ped(ped_handle)
    else
        DisplayError(false, "Incorrect input: Please enter a valid ped handle.")
    end
end

--- Command to create a bodyguard for the player or another player.
-- Prompts for target and bodyguard model, then spawns and configures the bodyguard.
function create_bodyguard_command()
    local target_player_ped = nil
    local bodyguard_model_name = nil

    local target_options = { "Me", "Player" }
    local selected_target_option_index = InputFromList("Enter who you want to create a bodyguard for: ", target_options)

    if selected_target_option_index == 0 then -- For current player
        target_player_ped = PLAYER.PLAYER_PED_ID()
    elseif selected_target_option_index == 1 then -- For another player
        local player_id_str = Input("Enter player ID: ", false)
        local player_id = tonumber(player_id_str)
    
        if player_id then
            target_player_ped = PLAYER.GET_PLAYER_PED(player_id)
            if target_player_ped == 0.0 then
                DisplayError(false, "Player with ID " .. player_id .. " not found.")
                return nil
            end
        else
            DisplayError(false, "Incorrect player ID input.")
            return nil
        end
    else
        return nil -- User cancelled
    end

    local bodyguard_models_options = {
        "Mexicano guard", "Gang guard", "Elite guard", "SecuroServ guard",
        "Merryweather guard", "Police guard", "Custom"
    }
    local selected_model_index = InputFromList("Enter a model for the bodyguard: ", bodyguard_models_options)

    if selected_model_index == 0 then
        local mexicano_guard_models = { "G_M_M_CartelGuards_02", "G_M_M_CartelGuards_01" }
        bodyguard_model_name = mexicano_guard_models[math.random(1, #mexicano_guard_models)]
    elseif selected_model_index == 1 then
        local gang_guard_models = { "G_M_M_CartelGoons_01", "G_M_M_Goons_01", "G_M_ImportExport_01", "MP_M_BogdanGoon" }
        bodyguard_model_name = gang_guard_models[math.random(1, #gang_guard_models)]
    elseif selected_model_index == 2 then
        local elite_guard_models = { "IG_Security_A", "S_M_M_HighSec_04", "S_M_M_HighSec_01", "S_M_Y_DevinSec_01" }
        bodyguard_model_name = elite_guard_models[math.random(1, #elite_guard_models)]
    elseif selected_model_index == 3 then
        local securo_serv_guard_models = { "MP_M_SecuroGuard_01", "S_M_M_Security_01" }
        bodyguard_model_name = securo_serv_guard_models[math.random(1, #securo_serv_guard_models)]
    elseif selected_model_index == 4 then
        local merryweather_guard_models = { "S_M_Y_BlackOps_03", "S_M_Y_BlackOps_01" }
        bodyguard_model_name = merryweather_guard_models[math.random(1, #merryweather_guard_models)]
    elseif selected_model_index == 5 then
        local police_guard_models = { "S_M_M_FIBSec_01", "S_M_M_CIASec_01", "S_M_Y_Swat_01" }
        bodyguard_model_name = police_guard_models[math.random(1, #police_guard_models)]
    elseif selected_model_index == 6 then -- Custom model
        bodyguard_model_name = Input("Enter ped model (https://forge.plebmasters.de/peds): ", false)
    else
        return nil -- User cancelled
    end

    local model_hash = MISC.GET_HASH_KEY(bodyguard_model_name)

    local failed_to_load = false
    local iterations = 0
    if STREAMING.IS_MODEL_VALID(model_hash) then
        STREAMING.REQUEST_MODEL(model_hash)
        -- Wait for model to load or timeout.
        while not STREAMING.HAS_MODEL_LOADED(model_hash) and not failed_to_load do
            if iterations > 50 then
                DisplayError(false, "Failed to load the model: " .. bodyguard_model_name)
                failed_to_load = true
            end
            Wait(5)
            iterations = iterations + 1
        end
        
        if not failed_to_load then
            local spawn_coords = ENTITY.GET_ENTITY_COORDS(target_player_ped, false)

            -- Create the bodyguard ped slightly offset from the target player.
            local created_bodyguard = PED.CREATE_PED(1, model_hash, spawn_coords.x, spawn_coords.y + 4.0, spawn_coords.z, ENTITY.GET_ENTITY_HEADING(target_player_ped), false, true)

            if created_bodyguard then
                network_utils.register_as_network(created_bodyguard) -- Register for network synchronization.
                make_ped_bodyguard_for_ped(target_player_ped, created_bodyguard) -- Configure as bodyguard.

                printColoured("green", "Successfully created bodyguard. Ped ID is " .. created_bodyguard)
                table.insert(created_peds_models, bodyguard_model_name)
                table.insert(created_peds_ids, created_bodyguard)
            else
                DisplayError(false, "Failed to create bodyguard ped entity.")
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash) -- Release model
        end
    else
        DisplayError(false, "Unable to continue execution because the model '" .. bodyguard_model_name .. "' is not valid.")
    end
end

--- Command to create a ped inside a spawned vehicle.
-- Prompts for vehicle and ped models, then spawns both and places the ped inside.
function create_ped_in_veh_command()
    local iterations = 0
    local failed_to_load = false
    local apply_tuning = false
    local vehicle_hash = nil
    local ped_hash = nil
    local created_ped = nil
    local created_vehicle = nil

    -- Prompt for vehicle model name.
    local vehicle_model_name = Input("Enter vehicle model (https://forge.plebmasters.de/vehicles): ", false)
    
    -- If no vehicle model entered, get a random one.
    if vehicle_model_name == "" then
        iterations = 0
        repeat -- Loop until a valid car model is found or timeout.
            vehicle_model_name = vehicle_utils.get_random_vehicle_model_name()
            vehicle_hash = MISC.GET_HASH_KEY(vehicle_model_name)
            iterations = iterations + 1
            Wait(1)
        until (VEHICLE.IS_THIS_MODEL_A_CAR(vehicle_hash) or VEHICLE.IS_THIS_MODEL_A_BIKE(vehicle_hash) or VEHICLE.IS_THIS_MODEL_A_QUADBIKE(vehicle_hash) or VEHICLE.IS_THIS_MODEL_AN_AMPHIBIOUS_CAR(vehicle_hash) or VEHICLE.IS_THIS_MODEL_AN_AMPHIBIOUS_QUADBIKE(vehicle_hash)) or iterations >= 50
        
        if iterations >= 50 then
            DisplayError(false, "Failed to find a valid random vehicle model.")
            return nil
        end
    else
        vehicle_hash = MISC.GET_HASH_KEY(vehicle_model_name)
    end 
    
    iterations = 0
    if STREAMING.IS_MODEL_VALID(vehicle_hash) then
        STREAMING.REQUEST_MODEL(vehicle_hash)
        -- Wait for vehicle model to load or timeout.
        while not STREAMING.HAS_MODEL_LOADED(vehicle_hash) and not failed_to_load do
            if iterations > 50 then
                DisplayError(false, "Failed to load the vehicle model: " .. vehicle_model_name)
                failed_to_load = true
            end
            Wait(5)
            iterations = iterations + 1
        end
        
        if not failed_to_load then
            local spawn_coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)

            -- Prompt to ask if the vehicle should be tuned.
            local tuning_input = Input("Create an already tuned? [Y/n]: ", true)
            if tuning_input == "y" then
                apply_tuning = true
            end 

            -- Create the vehicle.
            created_vehicle = VEHICLE.CREATE_VEHICLE(vehicle_hash, spawn_coords.x + 10.5, spawn_coords.y + 9.0, spawn_coords.z + 0.5, 0.0, false, false, false)
            network_utils.register_as_network(created_vehicle) -- Register for network synchronization.
            
            if created_vehicle ~= 0.0 then
                VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(created_vehicle, 5.0)
                if apply_tuning then
                    -- This function was removed as it was marked for deletion.
                    -- If you still need vehicle tuning, you'll need to re-implement or call an external utility.
                    -- MakeVehicleMaxTuning(created_vehicle) 
                    print("Note: Vehicle tuning function (MakeVehicleMaxTuning) was removed.")
                end
                
                VEHICLE.SET_VEHICLE_IS_WANTED(created_vehicle, false)
    
                local vehicle_blip = HUD.ADD_BLIP_FOR_ENTITY(created_vehicle)
                HUD.SET_BLIP_AS_FRIENDLY(vehicle_blip, true)
                HUD.SET_BLIP_SPRITE(vehicle_blip, map_utils.get_blip_from_entity_model(vehicle_hash))
                HUD.SET_BLIP_COLOUR(vehicle_blip, blip_enums.BlipColour.BLUE_2)
                HUD.SET_BLIP_DISPLAY(vehicle_blip, blip_enums.BlipDisplay.SELECTABLE_SHOWS_ON_BOTH_MAPS)
            else
                DisplayError(false, "Failed to create vehicle entity.")
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicle_hash)
                return nil
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicle_hash) -- Release vehicle model.
        else
            DisplayError(false, "Vehicle model '" .. vehicle_model_name .. "' is not valid or failed to load.")
            return nil
        end

        -- Now, handle ped creation for the vehicle.
        local ped_model_name = Input("Enter ped model (https://forge.plebmasters.de/peds): ", false)
        local spawn_coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true) -- Re-get player coords for ped spawn offset

        if ped_model_name == "" then
            created_ped = PED.CREATE_RANDOM_PED_AS_DRIVER(created_vehicle, true)
            if created_ped == 0.0 then
                ped_model_name = ped_utils.get_random_ped_model_name() -- Fallback if random driver creation fails
            end
        end

        if not created_ped or created_ped == 0.0 then -- If no ped created yet or random failed
            ped_hash = MISC.GET_HASH_KEY(ped_model_name)

            iterations = 0
            if STREAMING.IS_MODEL_VALID(ped_hash) then
                STREAMING.REQUEST_MODEL(ped_hash)
                -- Wait for ped model to load or timeout.
                while not STREAMING.HAS_MODEL_LOADED(ped_hash) and not failed_to_load do
                    if iterations > 50 then
                        DisplayError(false, "Failed to load the ped model: " .. ped_model_name)
                        failed_to_load = true
                    end
                    Wait(5)
                    iterations = iterations + 1
                end
                
                if not failed_to_load then
                    -- Create the ped slightly offset from the player.
                    created_ped = PED.CREATE_PED(2, ped_hash, spawn_coords.x + 3.5, spawn_coords.y + 3.0, spawn_coords.z + 0.2, 0.0, false, true)
                else
                    DisplayError(false, "Ped model '" .. ped_model_name .. "' is not valid or failed to load.")
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ped_hash)
                    return nil
                end
            else
                DisplayError(false, "Ped model '" .. ped_model_name .. "' is not valid.")
                return nil
            end
        end

        if created_ped and created_ped ~= 0.0 then
            network_utils.register_as_network(created_ped) -- Register ped for network synchronization.
            PED.SET_PED_INTO_VEHICLE(created_ped, created_vehicle, -1) -- Place ped into driver seat.

            -- Task the ped to drive the vehicle to player's current coords (or nearby).
            TASK.TASK_VEHICLE_DRIVE_TO_COORD(created_ped, created_vehicle, spawn_coords.x, spawn_coords.y, spawn_coords.z, 40.0, 1, vehicle_hash, 399, 6, -1)

            printColoured("green", "Successfully created ped (ID: " .. created_ped .. ") and vehicle (ID: " .. created_vehicle .. ").")

            table.insert(created_peds_models, ped_model_name)
            table.insert(created_peds_ids, created_ped)
        else
            DisplayError(false, "Failed to create ped entity for vehicle.")
        end
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ped_hash) -- Release ped model.
    else
        DisplayError(false, "No vehicle was created. Cannot create ped in vehicle.")
    end
end


--- Breaks out of the "View All Peds" mode.
-- Resets camera, returns player control, and cleans up the spawned ped.
function break_view_all_peds()
    -- Delete the camera.
    if view_all_peds_camera then
        mission_utils.delete_camera(view_all_peds_camera)
        view_all_peds_camera = nil
    end

    -- Allow player to control character again.
    PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), true, 0)
    STREAMING.SET_FOCUS_ENTITY(PLAYER.PLAYER_PED_ID())

    -- Delete the current ped being viewed.
    if view_all_peds_current_ped then
        network_utils.request_control_of(view_all_peds_current_ped)
        DeletePed(view_all_peds_current_ped) -- Assuming DeletePed is a global GCTV function
        if ENTITY.DOES_ENTITY_EXIST(view_all_peds_current_ped) then
            -- If still exists after DeletePed, move far away and try deleting again.
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(view_all_peds_current_ped, -1000.0, 1000.0, 0.0, true, true, true)
            DeletePed(view_all_peds_current_ped)
        end
        view_all_peds_current_ped = nil
    end

    still_viewing_all_peds = false
    io.write_anonym("\n") -- Assuming io.write_anonym is a custom GCTV function for console output.
end

--- Spawns a ped for the "View All Peds" mode.
-- Handles loading the model, creating the ped, and setting its initial state.
-- @param ped_name string The model name of the ped to spawn.
-- @param coords table A table with 'x', 'y', 'z' keys for spawn coordinates.
function spawn_ped(ped_name, coords)
    local iterations = 0
    -- Delete old ped if it exists.
    if view_all_peds_current_ped then
        network_utils.request_control_of(view_all_peds_current_ped)
        DeletePed(view_all_peds_current_ped)
        if ENTITY.DOES_ENTITY_EXIST(view_all_peds_current_ped) then
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(view_all_peds_current_ped, 0.0, 0.0, 0.0, true, true, true)
            DeletePed(view_all_peds_current_ped)
        end
    end
    
    -- Spawn the new ped.
    local model_hash = MISC.GET_HASH_KEY(ped_name)
    if STREAMING.IS_MODEL_VALID(model_hash) then
        STREAMING.REQUEST_MODEL(model_hash)
        -- Wait for model to load or timeout.
        while not STREAMING.HAS_MODEL_LOADED(model_hash) do
            if iterations > 50 then
                io.write_anonym("\n")
                DisplayError(false, "Failed to load the " .. ped_name .. " model.")
                break_view_all_peds()
                return nil
            end
            Wait(5)
            iterations = iterations + 1
        end
    else
        io.write_anonym("\n")
        DisplayError(false, "Unable to continue execution because the model '" .. ped_name .. "' is not valid.")
        break_view_all_peds()
        return nil
    end

    view_all_peds_current_ped = PED.CREATE_PED(1, model_hash, coords.x, coords.y, coords.z, -294.0, false, true)
    STREAMING.SET_FOCUS_ENTITY(view_all_peds_current_ped)

    local action_index = math.random(1, #view_all_peds_animations + 1) -- +1 for "no action" option

    -- Apply a random animation if the ped is human and an animation is selected.
    if action_index <= #view_all_peds_animations and PED.IS_PED_HUMAN(view_all_peds_current_ped) then -- Changed from viewAllPedsAnimations to view_all_peds_current_ped
        -- TASK.TASK_START_SCENARIO_IN_PLACE(view_all_peds_current_ped, view_all_peds_animations[action_index], 0, true)
        -- The above line is commented out in original, keeping it commented.
    end

    ENTITY.FREEZE_ENTITY_POSITION(view_all_peds_current_ped, true) -- Freeze ped in place.

    local ped_ptr = NewPed(view_all_peds_current_ped) -- Create a pointer for the ped.
    
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash) -- Release model hash.
    ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(ped_ptr) -- Mark entity as no longer needed (for cleanup by game).
    Delete(ped_ptr) -- Delete the allocated pointer.

    ResetLineAndPrint(ped_name) -- Debug print for current ped name.
end

--- Changes the currently viewed ped in "View All Peds" mode.
-- Cycles through the list of ped models based on direction.
-- @param direction number The direction to change (e.g., 1 for next, -1 for previous).
function change_ped(direction)
    view_all_peds_list_index = view_all_peds_list_index + direction
    if view_all_peds_list_index > #view_all_peds_list then
        view_all_peds_list_index = 1
    elseif view_all_peds_list_index < 1 then
        view_all_peds_list_index = #view_all_peds_list
    end

    AUDIO.PLAY_SOUND_FRONTEND(-1, "SELECT", "HUD_LIQUOR_STORE_SOUNDSET", true) -- Play selection sound.

    -- Spawn the new ped.
    spawn_ped(view_all_peds_list[view_all_peds_list_index], {x = -482.3, y = -133.3, z = 38.0})
end

--- Command to enter "View All Peds" mode.
-- Sets up camera, disables player control, and initiates ped cycling.
function view_all_peds_command()
    still_viewing_all_peds = true
    view_all_peds_list_index = 1

    io.write_anonym("\n") -- Assuming io.write_anonym is a custom GCTV function.
    
    -- Set camera to fixed coordinates for viewing peds.
    local camera_coords = {x = -485.89999389648, y = -131.19999694824, z = 39.5}
    local camera_heading = 234.0

    -- Create the camera.
    view_all_peds_camera = mission_utils.create_camera(camera_coords.x, camera_coords.y, camera_coords.z, camera_heading, 0.0, 0.0, 0)

    -- Disable player control.
    PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), false, 0)

    -- Spawn the first ped to view.
    spawn_ped(view_all_peds_list[view_all_peds_list_index], {x = -482.3, y = -133.3, z = 38.0})
    
    -- Enter the main viewing loop.
    while true do
        if not still_viewing_all_peds then
            return nil -- Exit loop if viewing is stopped.
        end
        -- Handle key presses for navigating peds.
        if IsPressedKey(view_all_peds_next_key) then
            change_ped(1)
            Wait(100) -- Small delay to prevent rapid changes.
        end
        if IsPressedKey(view_all_peds_back_key) then
            change_ped(-1)
            Wait(100) -- Small delay to prevent rapid changes.
        end
        if IsPressedKey(view_all_peds_select_key) then
            -- Select key: exit viewing mode and spawn the selected ped at player's location.
            local selected_ped_model_name = view_all_peds_list[view_all_peds_list_index]
            local player_coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
            
            -- Create the selected ped at player's location.
            local ped_hash = MISC.GET_HASH_KEY(selected_ped_model_name)
            if STREAMING.IS_MODEL_VALID(ped_hash) then
                STREAMING.REQUEST_MODEL(ped_hash)
                local iterations = 0
                while not STREAMING.HAS_MODEL_LOADED(ped_hash) and iterations < 50 do
                    Wait(1)
                    iterations = iterations + 1
                end
                if STREAMING.HAS_MODEL_LOADED(ped_hash) then
                    local spawned_ped = PED.CREATE_PED(1, ped_hash, player_coords.x, player_coords.y, player_coords.z, ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID()), false, true)
                    if spawned_ped ~= 0.0 then
                        network_utils.register_as_network(spawned_ped)
                        table.insert(created_peds_models, selected_ped_model_name)
                        table.insert(created_peds_ids, spawned_ped)
                        printColoured("green", "Spawned selected ped: " .. selected_ped_model_name .. " (ID: " .. spawned_ped .. ")")
                    else
                        DisplayError(false, "Failed to spawn selected ped.")
                    end
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ped_hash)
                else
                    DisplayError(false, "Failed to load model for selected ped.")
                end
            else
                DisplayError(false, "Selected ped model is not valid.")
            end
            
            break_view_all_peds() -- Exit viewing mode.
            return nil
        end
        -- Exit key for viewing mode (e.g., ESC)
        if IsPressedKey(MISC.GET_HASH_KEY("KEY_ESC")) then -- Assuming ESC key hash is available or manually defined
            break_view_all_peds()
            return nil
        end

        Wait(0) -- Yield control to other scripts/game engine.
    end
end

--- Initializes hotkey settings from configuration for ped commands.
-- Reads key codes for "View All Peds" navigation.
function initialize_settings()
    view_all_peds_next_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "ViewAllPedsNextKey"))
    view_all_peds_back_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "ViewAllPedsBackKey"))
    view_all_peds_select_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "ViewAllPedsSelectKey"))
end

-- Define a dictionary with commands and their corresponding functions.
local commands = {
    ["peds list"] = peds_list_command,
    ["create ped"] = create_ped_command,
    ["delete ped"] = delete_ped_command,
    ["ped control"] = ped_control_command,
    ["create bodyguard"] = create_bodyguard_command,
    ["create ped in veh"] = create_ped_in_veh_command,
    ["view all peds"] = view_all_peds_command,
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

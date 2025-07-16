-- This script defines commands for interacting with players and network features in GTA V.

-- Global variable for the spectate camera.
local spectate_camera = nil

-- Loading necessary utility modules.
local network_utils = require("network_utils") -- Module for network-related utilities.
local math_utils = require("math_utils")     -- Module for mathematical utilities.
local map_utils = require("map_utils")       -- Module for map-related utilities.

--- Retrieves the readable name of a weapon from its hash.
-- Reads from the "weapons.json" file.
-- @param weapon_hash number The hash of the weapon.
-- @returns string The name of the weapon, or "Unarmed" if not found.
function get_weapon_name(weapon_hash)
    local weapons_data = JsonReadList("weapons.json")

    if weapons_data ~= nil then
        for weapon_type, weapon_names in pairs(weapons_data) do
            for weapon_name, stored_hash_str in pairs(weapon_names) do
                if tonumber32(stored_hash_str) == weapon_hash then
                    return weapon_name
                end
            end
        end
    end
    return "Unarmed"
end

--- Prints a table to the console with formatted columns.
-- Dynamically calculates column widths for alignment.
-- @param tbl table A table of tables, where each inner table represents a row.
function print_table(tbl)
    -- Determine column widths.
    local column_widths = {}
    for _, row in ipairs(tbl) do
        for col_index, value in ipairs(row) do
            local str_value = tostring(value)
            column_widths[col_index] = math.max(column_widths[col_index] or 0, #str_value)
        end
    end

    -- Print the table.
    for _, row in ipairs(tbl) do
        local row_string = ""
        for col_index, value in ipairs(row) do
            local str_value = tostring(value)
            -- Add value and padding spaces for alignment.
            row_string = row_string .. str_value .. string.rep(" ", column_widths[col_index] - #str_value + 1)
        end
        io.write_anonym(row_string)
        io.write_anonym("\n")
    end
end

--- Command to display the list of all connected players.
-- Shows player IDs and their names.
function players_command()
    local players_count = PLAYER.GET_NUMBER_OF_PLAYERS() - 1 -- Subtract 1 if local player is included in count.

    print("Players count is " .. string.format("%d", players_count))

    for i = 0, players_count, 1 do
        print(i .. ". " .. PLAYER.GET_PLAYER_NAME(i))
    end
end

--- Command to display detailed information about all connected players.
-- Includes health, armor, wanted level, god mode, vehicle status, interior status, weapon, cash, distance, and zone.
function players_info_command()
    local players_info_table = {
        {"Player", "Health", "Armor", "Wanted Level", "In God", "In Veh", "In Interior", "Weapon", "Cash", "Distance", "Zone"}
    }
    local players_count = PLAYER.GET_NUMBER_OF_PLAYERS() - 1
    local host_player_id = NETWORK.NETWORK_GET_HOST_PLAYER_INDEX()
    local local_player_coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)

    for i = 0, players_count, 1 do
        local current_player_ped = PLAYER.GET_PLAYER_PED(i)
        local player_name = NETWORK.NETWORK_PLAYER_GET_NAME(i)
        
        -- Only process valid player names (not "**Invalid**").
        if player_name ~= "**Invalid**" then
            local wanted_level = PLAYER.GET_PLAYER_WANTED_LEVEL(i)
            local stars_display = ""
            local in_god_mode = PLAYER.GET_PLAYER_INVINCIBLE(i)
            local in_vehicle_handle = PED.GET_VEHICLE_PED_IS_IN(current_player_ped, true)
            local in_interior_handle = INTERIOR.GET_INTERIOR_FROM_ENTITY(current_player_ped)

            local weapon_ptr = New(4) -- Allocate memory for weapon hash.
            WEAPON.GET_CURRENT_PED_WEAPON(current_player_ped, weapon_ptr, true)
            local player_weapon_name = get_weapon_name(Game.ReadInt(weapon_ptr))
            Delete(weapon_ptr) -- Free allocated memory.

            local player_coords = ENTITY.GET_ENTITY_COORDS(current_player_ped, true)
            
            local distance_to_local = math.floor(math_utils.get_distance_between_coords(player_coords, local_player_coords)) .. "m"
            local zone_name = map_utils.get_zone_name(player_coords.x, player_coords.y, player_coords.z)

            -- Mark host player.
            if i == host_player_id then
                player_name = player_name .. "(HOST)"
            end

            -- Format wanted level stars.
            if wanted_level == 0.0 then
                stars_display = "No"
            else
                for star_count = 1, wanted_level do -- Loop from 1 to wantedLevel
                    stars_display = stars_display .. "*"
                end
            end
            
            -- Format boolean/handle values to "Yes"/"No".
            local in_god_display = in_god_mode and "Yes" or "No"
            local in_vehicle_display = in_vehicle_handle ~= 0.0 and "Yes" or "No"
            local in_interior_display = in_interior_handle ~= 0.0 and "Yes" or "No"

            table.insert(players_info_table, {
                i .. "." .. player_name,
                ENTITY.GET_ENTITY_HEALTH(current_player_ped),
                PED.GET_PED_ARMOUR(current_player_ped),
                stars_display,
                in_god_display,
                in_vehicle_display,
                in_interior_display,
                player_weapon_name,
                PED.GET_PED_MONEY(current_player_ped),
                distance_to_local,
                zone_name
            })
        end
    end

    print("Player information table:")
    print_table(players_info_table)
end

--- Command to get the vehicle handle of a specified player.
-- @param player_id_input string The string input of the player's ID.
function get_player_vehicle_command()
    local player_id_str = Input("Enter player ID: ", false)
    local player_id = tonumber(player_id_str)

    if player_id and PLAYER.GET_PLAYER_PED(player_id) ~= 0.0 then -- Validate player ID and existence
        print("Player vehicle is " .. string.format("%d", PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(player_id), true)))
    else
        DisplayError(false, "Incorrect input or player not found. Please enter a valid player ID.")
    end
end

--- Command to get the position (coordinates and heading) of a specified player.
-- @param player_id_input string The string input of the player's ID.
function get_player_position_command()
    local player_id_str = Input("Enter player ID: ", false)
    local player_id = tonumber(player_id_str)

    if player_id and PLAYER.GET_PLAYER_PED(player_id) ~= 0.0 then -- Validate player ID and existence
        local target_player_ped = PLAYER.GET_PLAYER_PED(player_id)
        local coords = ENTITY.GET_ENTITY_COORDS(target_player_ped, true)
        print("Player coords x = " .. coords.x .. " y = " .. coords.y .. " z = " .. coords.z)
        print("Player heading is " .. ENTITY.GET_ENTITY_HEADING(target_player_ped))
    else
        DisplayError(false, "Incorrect input or player not found. Please enter a valid player ID.")
    end
end

--- Command to get the current speed of a specified player.
-- @param player_id_input string The string input of the player's ID.
function get_player_speed_command()
    local player_id_str = Input("Enter player ID: ", false)
    local player_id = tonumber(player_id_str)

    if player_id and PLAYER.GET_PLAYER_PED(player_id) ~= 0.0 then -- Validate player ID and existence
        print("Player speed is " .. ENTITY.GET_ENTITY_SPEED(PLAYER.GET_PLAYER_PED(player_id)))
    else
        DisplayError(false, "Incorrect input or player not found. Please enter a valid player ID.")
    end
end

--- Command to kick a specified player from the session.
-- Only works if the local player is the host.
-- @param player_id_input string The string input of the player's ID to kick.
function kick_player_command()
    local player_id_str = Input("Enter player ID (only works if you are host): ", false)
    local player_id = tonumber(player_id_str)

    if player_id then
        NETWORK.NETWORK_SESSION_KICK_PLAYER(player_id)
        print("Attempted to kick player " .. player_id .. ".") -- Confirmation message
    else
        DisplayError(false, "Incorrect input. Please enter a valid player ID.")
    end
end

--- Command to repeatedly explode a specified player until they are dead or a timeout occurs.
-- @param player_id_input string The string input of the player's ID to explode.
function explode_player_command()
    local iterations = 0
    local player_id_str = Input("Enter player ID: ", false)
    local player_id = tonumber(player_id_str)

    if player_id and PLAYER.GET_PLAYER_PED(player_id) ~= 0.0 then -- Validate player ID and existence
        local target_player_ped = PLAYER.GET_PLAYER_PED(player_id)
        while not ENTITY.IS_ENTITY_DEAD(target_player_ped, true) and iterations < 100 do
            local coords = ENTITY.GET_ENTITY_COORDS(target_player_ped, true)
            FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 4, 10000.0, true, false, 100.0, false) -- Explosion type 4 (grenade), large radius.
            iterations = iterations + 1
            Wait(10) -- Small delay between explosions.
        end
        print("Explosion sequence for player " .. player_id .. " completed.")
    else
        DisplayError(false, "Incorrect input or player not found. Please enter a valid player ID.")
    end
end

--- Command to freeze a specified player by clearing their tasks repeatedly.
-- @param player_id_input string The string input of the player's ID to freeze.
function freeze_player_command()
    local iterations = 0
    local player_id_str = Input("Enter player ID: ", false)
    local player_id = tonumber(player_id_str)

    if player_id and PLAYER.GET_PLAYER_PED(player_id) ~= 0.0 then -- Validate player ID and existence
        local target_player_ped = PLAYER.GET_PLAYER_PED(player_id)
        network_utils.request_control_of(target_player_ped) -- Request control to clear tasks.
        while iterations < 500 do -- Repeat clearing tasks for a duration.
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(target_player_ped)
            iterations = iterations + 1
            Wait(1) -- Small delay.
        end
        print("Player " .. player_id .. " has been frozen (tasks cleared).")
    else
        DisplayError(false, "Incorrect input or player not found. Please enter a valid player ID.")
    end
end

--- Command to shake the camera of a specified player using a series of small explosions.
-- @param player_id_input string The string input of the player's ID.
function shake_player_cam_command()
    local iterations = 0
    local player_id_str = Input("Enter player ID: ", false)
    local player_id = tonumber(player_id_str)

    if player_id and PLAYER.GET_PLAYER_PED(player_id) ~= 0.0 then -- Validate player ID and existence
        local target_player_ped = PLAYER.GET_PLAYER_PED(player_id)

        local duration_ms_str = Input("Enter duration in ms: ", false)
        local duration_ms = tonumber(duration_ms_str)
        local duration_ticks = 0

        if duration_ms then
            duration_ticks = math.floor(duration_ms / 10) -- Convert ms to ticks (approx 10ms per tick)
        else
            DisplayError(false, "Incorrect duration input.")
            return nil
        end

        while duration_ticks > 0 do
            local coords = ENTITY.GET_ENTITY_COORDS(target_player_ped, true)
            -- Add a small, non-damaging explosion to shake camera.
            FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 4, 0.0, false, true, 1000.0, true)
            duration_ticks = duration_ticks - 1
            Wait(1) -- Wait for 1 tick.
        end
        print("Camera shake for player " .. player_id .. " completed.")
    else
        DisplayError(false, "Incorrect input or player not found. Please enter a valid player ID.")
    end
end

--- Command to spectate a specified player using a script camera.
-- Toggles spectate mode on/off.
-- @param player_id_input string The string input of the player's ID to spectate.
function spectate_player_command()
    if not spectate_camera then -- If not currently spectating, start spectating.
        local player_id_str = Input("Enter player ID: ", false)
        local player_id = tonumber(player_id_str)

        if player_id and PLAYER.GET_PLAYER_PED(player_id) ~= 0.0 then -- Validate player ID and existence
            local target_player_ped = PLAYER.GET_PLAYER_PED(player_id)
            spectate_camera = CAM.CREATE_CAM("DEFAULT_SCRIPTED_CAMERA", true)
            CAM.ATTACH_CAM_TO_ENTITY(spectate_camera, target_player_ped, 0.0, -1.0, 1.0, true) -- Attach behind player.
            CAM.RENDER_SCRIPT_CAMS(true, true, 1000, true, true, 0) -- Render script camera.
            CAM.SET_CAM_ACTIVE(spectate_camera, true)
            STREAMING.SET_FOCUS_ENTITY(target_player_ped) -- Focus game on spectated player.
            print("Spectating player " .. player_id .. ".")
        else
            DisplayError(false, "Incorrect input or player not found. Please enter a valid player ID.")
        end
    else -- If currently spectating, ask to detach.
        local detach_input = Input("You want to detach the camera from the player? [Y/n]: ", true)

        if detach_input == "y" then
            CAM.DETACH_CAM(spectate_camera)
            CAM.STOP_RENDERING_SCRIPT_CAMS_USING_CATCH_UP(false, 0.0, 0, 0)
            CAM.SET_CAM_ACTIVE(spectate_camera, false)
            CAM.DESTROY_CAM(spectate_camera, false) -- Destroy the camera object.
            STREAMING.SET_FOCUS_ENTITY(PLAYER.PLAYER_PED_ID()) -- Return focus to local player.
            spectate_camera = nil -- Clear camera handle.
            print("Spectate mode deactivated.")
        end
    end
end

-- Define a dictionary with commands and their corresponding functions.
local commands = {
    ["players"] = players_command,
    ["players info"] = players_info_command,
    ["get player vehicle"] = get_player_vehicle_command,
    ["get player position"] = get_player_position_command,
    ["get player speed"] = get_player_speed_command,
    ["kick player"] = kick_player_command,
    ["explode player"] = explode_player_command,
    ["freeze player"] = freeze_player_command,
    ["shake player cam"] = shake_player_cam_command,
    ["spectate player"] = spectate_player_command
}

-- Note: "Trap object tr_prop_tr_container_01a" - This seems like a comment for a potential future feature.

-- Initialize the pseudo-random number generator based on the current time.
-- This ensures different results for math.random each time the script runs.
math.randomseed(os.time())

-- Loop for registering commands.
-- Iterates through all "command name" - "function" pairs in the 'commands' dictionary.
for command_name, command_function in pairs(commands) do
    -- Registers the command. 'BindCommand' is a custom function of your GCTV API.
    if not BindCommand(command_name, command_function) then
        -- Displays an error message if command registration failed.
        DisplayError(true, "Failed to register the command: " .. command_name)
    end
end

-- This script defines commands related to player teleportation and saving/loading locations.

-- Loading necessary utility modules.
local teleport_utils = require("teleport_utils") -- Module for general teleportation logic.
local map_utils = require("map_utils")           -- Module for map-related utilities (e.g., waypoint, zone names).
local world_utils = require("world_utils")       -- Module for world initialization (e.g., North Yankton, Cayo Perico).

--- Teleports the local player (or their vehicle if inside one) to specified coordinates.
-- @param coords table A table with 'x', 'y', 'z' keys representing the destination coordinates.
function teleport_local_player(coords)
    local entity_to_teleport = nil
    local vehicle_in_use = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
    
    -- Determine whether to teleport the player or their vehicle.
    if PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), true) and vehicle_in_use ~= 0.0 then
        entity_to_teleport = vehicle_in_use
    else
        entity_to_teleport = PLAYER.PLAYER_PED_ID()
    end

    teleport_utils.teleport_entity(entity_to_teleport, coords)
end

--- Command to teleport the player to various predefined or custom locations.
-- Prompts the user to select a destination from a list.
function teleport_command()
    local destination_coords = nil

    -- List of available teleport destinations.
    local places_options = {
        "Waypoint", "North Yankton", "Michael House", "Franklin House", "Trevor Trailer",
        "Airport Field", "Desert Airfield", "Military Base", "Maze Bank", "Cayo Perico",
        "Underground garage", "Saved place", "Custom"
    }
    -- Prompts for destination selection from the list.
    local selected_place_index = InputFromList("Enter where you want to teleport to: ", places_options)

    -- If the user made a valid selection (didn't cancel).
    if selected_place_index ~= -1 then
        if selected_place_index == 0 then -- Waypoint
            destination_coords = map_utils.get_waypoint_coords()
            if not destination_coords then
                print("Please choose a waypoint first")
                return nil
            end
        elseif selected_place_index == 1 then -- North Yankton
            world_utils.init_north_yankton()
            destination_coords = { x = 3360.19, y = -4849.67, z = 111.8 }
        elseif selected_place_index == 2 then -- Michael House
            destination_coords = { x = -852.4, y = 160.0, z = 65.6 }
        elseif selected_place_index == 3 then -- Franklin House
            destination_coords = { x = 7.9, y = 548.1, z = 175.5 }
        elseif selected_place_index == 4 then -- Trevor Trailer
            destination_coords = { x = 1985.7, y = 3812.2, z = 32.2 }
        elseif selected_place_index == 5 then -- Airport Field
            destination_coords = { x = -1336.0, y = -3044.0, z = 13.9 }
        elseif selected_place_index == 6 then -- Desert Airfield
            destination_coords = { x = 1747.0, y = 3273.7, z = 41.1 }
        elseif selected_place_index == 7 then -- Military Base
            destination_coords = { x = -2047.4, y = 3132.1, z = 32.8 }
        elseif selected_place_index == 8 then -- Maze Bank
            destination_coords = { x = -75.015, y = -818.215, z = 326.176 }
        elseif selected_place_index == 9 then -- Cayo Perico
            world_utils.init_cayo_perico()
            destination_coords = { x = 4444.66, y = -4474.621, z = 20.229855 }
        elseif selected_place_index == 10 then -- Underground garage
            destination_coords = { x = 404.760, y = -955.650, z = -99.685 }
        elseif selected_place_index == 11 then -- Saved place (from file)
            local saved_places_data = JsonReadList("teleports.json")

            if saved_places_data ~= nil then
                local display_places = {}
                for i = 1, #saved_places_data do
                    local element = saved_places_data[i]
                    table.insert(display_places, element.name .. "(" .. element.zone .. ")")
                end

                local selected_place_id = InputFromList("Enter where you want to teleport to: ", display_places)

                if selected_place_id ~= -1 then
                    local place_info = saved_places_data[selected_place_id + 1] -- +1 because Lua arrays are 1-indexed
                    destination_coords = { x = place_info.x, y = place_info.y, z = place_info.z }
                else
                    return nil -- User cancelled
                end
            else
                print("No saved places found.") -- Added a message for clarity
                return nil
            end
        elseif selected_place_index == 12 then -- Custom coordinates
            local coord_x_str = Input("Enter X coord: ", false)
            local coord_y_str = Input("Enter Y coord: ", false)
            local coord_z_str = Input("Enter Z coord: ", false)
            
            local coord_x = tonumber(coord_x_str)
            local coord_y = tonumber(coord_y_str)
            local coord_z = tonumber(coord_z_str)

            if coord_x and coord_y and coord_z then -- Validate input
                destination_coords = { x = coord_x, y = coord_y, z = coord_z }
            else
                DisplayError(false, "Incorrect coordinate input.")
                return nil
            end
        end

        -- If coordinates were successfully determined, perform teleport.
        if destination_coords then
            teleport_local_player(destination_coords)
        end
    else
        return nil -- User cancelled the initial selection
    end
end

--- Command to save the player's current location to a file.
-- Prompts the user for a name for the saved location.
function save_current_place_command()
    local saved_places_data = JsonReadList("teleports.json")
    
    -- If no saved places exist, initialize an empty table.
    if saved_places_data == nil then
        saved_places_data = {}
    end

    -- Prompt for a name for the current location.
    local location_name = Input("Enter a name for the current location: ", false)

    -- Get current player coordinates.
    local current_coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    
    -- Insert the new place into the saved places table.
    table.insert(saved_places_data, {
        name = location_name,
        x = current_coords.x,
        y = current_coords.y,
        z = current_coords.z,
        zone = map_utils.get_zone_name(current_coords.x, current_coords.y, current_coords.z)
    })
    
    -- Save the updated list of places to the JSON file.
    JsonSaveList("teleports.json", saved_places_data)
    print("Location '" .. location_name .. "' saved successfully!") -- Confirmation message
end


-- Define a dictionary with commands and their functions.
local commands = {
    ["teleport"] = teleport_command,
    ["save current place"] = save_current_place_command
}

-- Initialize the pseudo-random number generator based on the current time.
-- This ensures different results for math.random each time the script runs.
math.randomseed(os.time())

-- Loop for registering commands.
-- Iterates through all "command name" - "function" pairs in the Commands dictionary.
for command_name, command_function in pairs(commands) do
    -- Registers the command. 'BindCommand' is a custom function of your GCTV API.
    if not BindCommand(command_name, command_function) then
        -- Displays an error message if command registration failed.
        DisplayError(true, "Failed to register the command: " .. command_name)
    end
end

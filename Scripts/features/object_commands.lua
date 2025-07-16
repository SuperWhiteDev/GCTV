-- This script defines commands related to managing objects in the game,
-- including creating, listing, controlling, and deleting them.

-- Loading necessary utility modules.
local network_utils = require("network_utils") -- Module for network utilities (e.g., requesting control).
local map_utils = require("map_utils")       -- Module for map-related utilities (e.g., blips).

-- Lists to keep track of created objects by the script.
local created_objects_models = {} -- Stores model names (hashes) of created objects.
local created_objects_ids = {}    -- Stores entity IDs (handles) of created objects.

--- Placeholder function for controlling a specific object.
-- This function can be extended to include various actions for object manipulation.
-- @param object_handle number The entity ID of the object to control.
function control_object(object_handle)
    -- Current implementation is empty.
end

--- Command to list and interact with objects created by this script.
-- Allows the user to select an object to either control or delete.
function object_list_command()
    if #created_objects_ids ~= 0 then
        -- Prompt user to select an object from the list.
        local selected_object_index = InputFromList("Choose the object you want to interact with: ", created_objects_models)
        if selected_object_index ~= -1 then
            local selected_object_handle = created_objects_ids[selected_object_index + 1] -- +1 for Lua 1-indexing
            print("The object ID of the selected object is " .. selected_object_handle)

            -- Prompt user to choose an action for the selected object.
            local action_options = { "Control object", "Delete" }
            local selected_action_index = InputFromList("Choose what you want to: ", action_options)

            if selected_action_index == 0 then -- Control object
                control_object(selected_object_handle)
            elseif selected_action_index == 1 then -- Delete object
                network_utils.request_control_of(selected_object_handle)
                DeleteObject(selected_object_handle) -- Assuming DeleteObject is a global GCTV function

                -- Remove the object from the internal lists.
                table.remove(created_objects_ids, selected_object_index + 1)
                table.remove(created_objects_models, selected_object_index + 1)
                print("Object deleted successfully.") -- Confirmation message
            end
        end
    else
        print("There are no objects on the object list yet.")
    end
end

--- Command to add an existing object (by its handle) to the script's internal list.
-- This allows managing objects not created by this script.
function add_to_object_list_command()
    -- Prompt for object handle.
    local object_handle_str = Input("Enter object handle: ", false)
    local object_handle = tonumber(object_handle_str)
    
    if not object_handle or not ENTITY.DOES_ENTITY_EXIST(object_handle) then -- Validate input and existence
        DisplayError(false, "Incorrect input or object does not exist. Please enter a valid object handle.")
        return nil
    end
    
    -- Add object's model hash and handle to the internal lists.
    table.insert(created_objects_models, ENTITY.GET_ENTITY_MODEL(object_handle))
    table.insert(created_objects_ids, object_handle)
    print("Object " .. object_handle .. " added to list.") -- Confirmation message
end

--- Creates a new object in the game world.
-- Handles model loading, object creation, and initial configuration.
-- @param model_name string The model name (hash) of the object to create.
-- @param coords table A table with 'x', 'y', 'z' keys for spawn coordinates.
-- @param right_on_coords boolean If true, object is spawned exactly at coords; otherwise, an offset is calculated.
function create_object(model_name, coords, right_on_coords)
    local failed_to_load = false
    local iterations = 0

    local model_hash = MISC.GET_HASH_KEY(model_name)

    if STREAMING.IS_MODEL_VALID(model_hash) then
        STREAMING.REQUEST_MODEL(model_hash)
        -- Wait for model to load or timeout.
        while not STREAMING.HAS_MODEL_LOADED(model_hash) and not failed_to_load do
            if iterations > 50 then
                DisplayError(false, "Failed to load the model: " .. model_name)
                failed_to_load = true
            end
            Wait(5)
            iterations = iterations + 1
        end
        
        if not failed_to_load then
            local offset_y = 0.0
            if not right_on_coords then
                -- Calculate offset based on model dimensions to prevent spawning inside player.
                local dimensions = { x = 0.0, y = 0.0, z = 0.0 }
    
                local min_dimension_vec_ptr = NewVector3(dimensions)
                local max_dimension_vec_ptr = NewVector3(dimensions)
                local min_dimension_vec_mem_address = NewPointer(min_dimension_vec_ptr)
                local max_dimension_vec_mem_address = NewPointer(max_dimension_vec_ptr)

                MISC.GET_MODEL_DIMENSIONS(model_hash, min_dimension_vec_mem_address, max_dimension_vec_mem_address)

                local min_dimension = Game.ReadVector3(min_dimension_vec_mem_address)
                local max_dimension = Game.ReadVector3(max_dimension_vec_mem_address)

                DeleteVector3(min_dimension_vec_ptr)
                DeleteVector3(max_dimension_vec_ptr)
                Delete(min_dimension_vec_mem_address)
                Delete(max_dimension_vec_mem_address)

                offset_y = math.max(1.0, 1.3 * math.max(math.abs(max_dimension.x-min_dimension.x), math.abs(max_dimension.y-min_dimension.y)))
                print(offset_y) -- Debug print for calculated offset.
            end
            
            -- Create the object with calculated offset or directly at coordinates.
            local created_object = OBJECT.CREATE_OBJECT_NO_OFFSET(model_hash, coords.x + 0.0, coords.y + offset_y, coords.z, false, false, true, 0)
            
            if created_object ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(created_object) then
                network_utils.register_as_network(created_object) -- Register for network synchronization.
                ENTITY.SET_ENTITY_VELOCITY(created_object, 0.0, 0.0, 0.0) -- Stop initial movement.
                ENTITY.SET_ENTITY_ROTATION(created_object, 0, 0, 0, 0, false) -- Reset rotation.
                ENTITY.SET_ENTITY_COLLISION(created_object, true, false) -- Enable collision.
                OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(created_object) -- Place on ground.
                ENTITY.SET_ENTITY_VISIBLE(created_object, true, false) -- Ensure visibility.
                printColoured("green", "Successfully created new object. Object ID is " .. created_object)

                table.insert(created_objects_models, model_name) -- Store model name (string)
                table.insert(created_objects_ids, created_object) -- Store object handle (number)
            else
                DisplayError(false, "Failed to create object entity.")
            end
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_hash) -- Release model.
        end
    else
        DisplayError(false, "Unable to continue execution because the model '" .. model_name .. "' is not valid.")
    end
end

--- Command to create an object at the player's current position.
-- Prompts the user for an object model name.
function create_object_command()
    -- Prompt for object model name.
    local model_name = Input("Enter object model (https://gtahash.ru/): ", false)
    local player_coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    create_object(model_name, player_coords, false) -- Create object with offset.
end

--- Command to create an object at a specified location (waypoint or custom coordinates).
-- Prompts the user for an object model name and destination.
function create_object_at_command()
    local destination_coords = nil
    -- Prompt for object model name.
    local model_name = Input("Enter object model (https://gtahash.ru/): ", false)

    local place_options = { "Waypoint", "Custom" }
    local selected_place_index = InputFromList("Enter where you want to create object: ", place_options)

    if selected_place_index == 0 then -- Waypoint
        destination_coords = map_utils.get_waypoint_coords()
        if not destination_coords then
            print("Please choose a waypoint first.")
            return nil
        end
    elseif selected_place_index == 1 then -- Custom coordinates
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
    else
        return nil -- User cancelled
    end

    if destination_coords then
        create_object(model_name, destination_coords, true) -- Create object directly at coords.
    end
end

--- Command to delete an object by its handle.
-- @param object_handle_input string The string input of the object's handle.
function delete_object_command()
    -- Prompt for object handle.
    local object_handle_str = Input("Enter object handle: ", false)
    local object_handle = tonumber(object_handle_str)
    
    if object_handle and ENTITY.DOES_ENTITY_EXIST(object_handle) then -- Validate input and existence
        network_utils.request_control_of(object_handle)
        DeleteObject(object_handle) -- Assuming DeleteObject is a global GCTV function
        print("Object " .. object_handle .. " deleted successfully.") -- Confirmation message
    else
        DisplayError(false, "Incorrect input or object does not exist. Please enter a valid object handle.")
    end
end

--- Command to open the control menu for a specific object.
-- Prompts for an object handle and then calls the control function.
function object_control_command()
    -- Prompt for object handle.
    local object_handle_str = Input("Enter object handle: ", false)
    local object_handle = tonumber(object_handle_str)
    
    if object_handle and ENTITY.DOES_ENTITY_EXIST(object_handle) then -- Validate input and existence
        control_object(object_handle)
    else
        DisplayError(false, "Incorrect input or object does not exist. Please enter a valid object handle.")
    end
end


-- Define a dictionary with commands and their corresponding functions.
local commands = {
    ["object list"] = object_list_command,
    ["add to object list"] = add_to_object_list_command,
    ["create object"] = create_object_command,
    ["create object at"] = create_object_at_command,
    ["delete object"] = delete_object_command,
    ["object control"] = object_control_command
}

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

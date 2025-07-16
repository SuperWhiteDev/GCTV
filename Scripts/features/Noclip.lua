-- This script implements the noclip (free camera movement) feature for the player,
-- both on foot and while in a vehicle.

-- Loading necessary utility modules.
local math_utils = require("math_utils")     -- Module for mathematical utilities (e.g., vector operations).
local world_utils = require("world_utils")   -- Module for world-related utilities (e.g., nearest vehicle).
local config_utils = require("config_utils") -- Module for configuration utilities.

-- Hotkey variables for noclip movement, initialized from configuration settings.
local noclip_move_forward_key = nil
local noclip_move_backward_key = nil
local noclip_move_left_key = nil
local noclip_move_right_key = nil
local noclip_move_up_key = nil
local noclip_move_down_key = nil
local noclip_sprint_key = nil
local noclip_enter_exit_vehicle_key = nil

-- State variables for noclip.
local wait_time = 100             -- Default wait time for the main loop, reduced when noclip is active.
local previous_position = {x = 0.0, y = 0.0, z = 0.0} -- Stores player's position before noclip (unused in current logic).
local player_alpha = 0            -- Stores player's original alpha (transparency) before noclip.
local player_proofs = nil         -- Stores player's original damage proofs before noclip.
local noclip_active = false       -- True if noclip is currently enabled.
local noclip_initialized = false  -- True if noclip system has been initialized (proofs, visibility).
local is_noclip_vehicle = false   -- True if noclip is active for a vehicle.
local noclip_speed = nil          -- Current noclip movement speed.
local speed_multiplier = 1.0      -- Multiplier for sprint key.

--[[
-- Original GetEntityRightVector function (commented out in original, kept as is).
-- This function calculates the right-hand vector relative to an entity's forward vector.
function GetEntityRightVector(playerPed)
    local forward = ENTITY.GET_ENTITY_FORWARD_VECTOR(playerPed)
    return {
        x = -forward.y,
        y = forward.x,
        z = 0
    }
end 
]]

--- Enables noclip mode for the player on foot.
-- Makes the player invisible, sets damage proofs, and retrieves noclip speed.
function enable_noclip()
    local player_ped = PLAYER.PLAYER_PED_ID()
    player_alpha = ENTITY.GET_ENTITY_ALPHA(player_ped) -- Store current alpha.

    -- Make player invisible and fully transparent.
    ENTITY.SET_ENTITY_VISIBLE(player_ped, false, false)
    ENTITY.SET_ENTITY_ALPHA(player_ped, 0, false)

    -- Allocate memory to retrieve current entity proofs.
    local bullet_proof_ptr = New(4)
    local fire_proof_ptr = New(4)
    local explosion_proof_ptr = New(4)
    local collision_proof_ptr = New(4)
    local melee_proof_ptr = New(4)
    local steam_proof_ptr = New(4)
    local p7_ptr = New(4) -- Unused in original logic, but captured.
    local drown_proof_ptr = New(4)
    
    -- Get current entity proofs.
    ENTITY.GET_ENTITY_PROOFS(player_ped, bullet_proof_ptr, fire_proof_ptr, explosion_proof_ptr, collision_proof_ptr, melee_proof_ptr, steam_proof_ptr, p7_ptr, drown_proof_ptr)

    -- Store original proof states.
    player_proofs = {
        Game.ReadBool(bullet_proof_ptr),
        Game.ReadBool(fire_proof_ptr),
        Game.ReadBool(explosion_proof_ptr),
        Game.ReadBool(collision_proof_ptr),
        Game.ReadBool(melee_proof_ptr),
        Game.ReadBool(steam_proof_ptr),
        Game.ReadBool(p7_ptr),
        Game.ReadBool(drown_proof_ptr)
    }

    -- Free allocated memory for proof pointers.
    Delete(bullet_proof_ptr)
    Delete(fire_proof_ptr)
    Delete(explosion_proof_ptr)
    Delete(collision_proof_ptr)
    Delete(melee_proof_ptr)
    Delete(steam_proof_ptr)
    Delete(p7_ptr)
    Delete(drown_proof_ptr)

    -- Set new proofs: bulletproof, explosionproof, collisionproof to true.
    -- Other proofs are restored from original state.
    ENTITY.SET_ENTITY_PROOFS(player_ped, true, player_proofs[2], true, true, player_proofs[5], player_proofs[6], player_proofs[7], player_proofs[8])

    -- Retrieve noclip speed from global variable, default to 1.0 if not found.
    if IsGlobalVariableExist("NoclipSpeed") then
        noclip_speed = GetGlobalVariable("NoclipSpeed")
    else
        noclip_speed = 1.0
    end

    -- ShowNotification("Game Command Terminal", "Noclip activated", "CHAR_SOCIAL_CLUB", 7) -- Original commented out.

    noclip_initialized = true -- Mark noclip as initialized.
end

--- Enables noclip mode for the player's current vehicle.
-- Disables collision for the vehicle and retrieves noclip speed.
function enable_vehicle_noclip()
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)

    ENTITY.SET_ENTITY_COLLISION(player_vehicle, false, false) -- Disable collision for the vehicle.

    -- Retrieve noclip speed from global variable, default to 2.0 if not found or 1.0.
    if IsGlobalVariableExist("NoclipSpeed") then
        noclip_speed = GetGlobalVariable("NoclipSpeed")
        if noclip_speed == 1.0 then -- If default speed is 1.0, increase for vehicles.
            noclip_speed = 2.0
        end
    else
        noclip_speed = 2.0 -- Default speed for vehicle noclip.
    end

    -- ShowNotification("Game Command Terminal", "Noclip activated", "CHAR_SOCIAL_CLUB", 7) -- Original commented out.
    is_noclip_vehicle = true    -- Mark noclip as active for a vehicle.
    noclip_initialized = true   -- Mark noclip as initialized.
end

--- Disables noclip mode for the player on foot.
-- Restores player visibility, alpha, and original damage proofs.
function disable_noclip()
    local player_ped = PLAYER.PLAYER_PED_ID()

    -- Restore player visibility and original alpha.
    ENTITY.SET_ENTITY_VISIBLE(player_ped, true, false)
    ENTITY.SET_ENTITY_ALPHA(player_ped, player_alpha, false)

    -- Restore original damage proofs.
    if player_proofs then -- Only restore if proofs were captured.
        ENTITY.SET_ENTITY_PROOFS(player_ped, player_proofs[1], player_proofs[2], player_proofs[3], player_proofs[4], player_proofs[5], player_proofs[6], player_proofs[7], player_proofs[8])
    end
    player_proofs = nil -- Clear stored proofs.

    -- ShowNotification("Game Command Terminal", "Noclip deactivated", "CHAR_SOCIAL_CLUB", 7) -- Original commented out.

    noclip_initialized = false -- Mark noclip as uninitialized.
end

--- Disables noclip mode for the player's current vehicle.
-- Re-enables collision for the vehicle.
function disable_vehicle_noclip()
    local player_vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)

    ENTITY.SET_ENTITY_COLLISION(player_vehicle, true, true) -- Re-enable collision for the vehicle.
    
    is_noclip_vehicle = false   -- Mark noclip as inactive for vehicle.
    noclip_initialized = false  -- Mark noclip as uninitialized.

    SetGlobalVariableValue("NoclipActive", 0.0) -- Update global variable to reflect noclip is off.
end

--- Main update loop for noclip movement logic.
-- This function is called repeatedly when noclip is active.
function on_tick()
    local player_ped = PLAYER.PLAYER_PED_ID()

    if noclip_active then
        if is_noclip_vehicle then
            local current_vehicle = nil
            -- Check if player is still in a vehicle. If not, disable vehicle noclip.
            if PED.IS_PED_IN_ANY_VEHICLE(player_ped, false) then
                current_vehicle = PED.GET_VEHICLE_PED_IS_IN(player_ped, true)
            else
                disable_vehicle_noclip()
                return -- Exit on_tick as noclip is now disabled for vehicle.
            end

            local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(2) -- Get current camera rotation.
            local current_coords = ENTITY.GET_ENTITY_COORDS(player_ped, true) -- Get current player coordinates.
            
            -- Convert rotation angles to radians for trigonometric calculations.
            local heading_rad = math.rad(cam_rot.z)
            local pitch_rad = math.rad(cam_rot.x) -- Pitch angle (up/down).

            -- Calculate forward vector based on camera heading and pitch.
            local forward_vector = {
                x = -math.sin(heading_rad) * math.cos(pitch_rad), -- Adjust X by pitch
                y = math.cos(heading_rad) * math.cos(pitch_rad),  -- Adjust Y by pitch
                z = math.sin(pitch_rad)                           -- Z component based on pitch
            }

            -- Normalize the forward vector to ensure consistent speed.
            local forward_magnitude = math.sqrt(forward_vector.x^2 + forward_vector.y^2 + forward_vector.z^2)
            if forward_magnitude ~= 0 then -- Avoid division by zero
                forward_vector.x = forward_vector.x / forward_magnitude
                forward_vector.y = forward_vector.y / forward_magnitude
                forward_vector.z = forward_vector.z / forward_magnitude
            end
            
            local move_vector = { x = 0.0, y = 0.0, z = 0.0 } -- Vector to accumulate movement.

            -- Apply speed multiplier if sprint key is pressed.
            if IsPressedKey(noclip_sprint_key) then -- Shift
                speed_multiplier = 3.0
            else
                speed_multiplier = 1.0 -- Reset if not pressed
            end

            -- Calculate movement based on pressed keys.
            if IsPressedKey(noclip_move_forward_key) then
                move_vector = math_utils.sum_vectors(move_vector, math_utils.mult_vector(forward_vector, noclip_speed * speed_multiplier))
            end
            if IsPressedKey(noclip_move_left_key) then
                local left_vector = { x = -forward_vector.y, y = forward_vector.x, z = 0.0 } -- Left vector (perpendicular to forward on X-Y plane)
                -- Normalize left vector (optional, but good practice if not always unit length)
                local left_magnitude = math.sqrt(left_vector.x^2 + left_vector.y^2 + left_vector.z^2)
                if left_magnitude ~= 0 then
                    left_vector.x = left_vector.x / left_magnitude
                    left_vector.y = left_vector.y / left_magnitude
                    left_vector.z = left_vector.z / left_magnitude
                end
                move_vector = math_utils.sum_vectors(move_vector, math_utils.mult_vector(left_vector, noclip_speed * speed_multiplier))
            end
            if IsPressedKey(noclip_move_backward_key) then
                -- This original logic for backward movement is a bit unusual.
                -- It sums forward vector multiplied by a speed, then subtracts the result from itself.
                -- This will effectively cancel out the movement or result in zero.
                -- A more standard approach would be:
                -- move_vector = math_utils.subtract_vectors(move_vector, math_utils.mult_vector(forward_vector, noclip_speed * speed_multiplier))
                -- Keeping original logic for now as requested:
                
                local backward_temp_vector = math_utils.mult_vector(forward_vector, (noclip_speed * 1.5) * speed_multiplier)
                --move_vector = math_utils.sum_vectors(move_vector, backward_temp_vector)
                move_vector = math_utils.subtract_vectors(move_vector, backward_temp_vector) -- This effectively makes it 0 if only backward is pressed.
                                                                                           -- If combined with forward, it will reduce forward movement.
            end
            if IsPressedKey(noclip_move_right_key) then
                local right_vector = { x = forward_vector.y, y = -forward_vector.x, z = 0.0 } -- Right vector
                -- Normalize right vector (optional)
                local right_magnitude = math.sqrt(right_vector.x^2 + right_vector.y^2 + right_vector.z^2)
                if right_magnitude ~= 0 then
                    right_vector.x = right_vector.x / right_magnitude
                    right_vector.y = right_vector.y / right_magnitude
                    right_vector.z = right_vector.z / right_magnitude
                end
                move_vector = math_utils.sum_vectors(move_vector, math_utils.mult_vector(right_vector, noclip_speed * speed_multiplier))
            end
            if IsPressedKey(noclip_move_up_key) then
                move_vector.z = move_vector.z + (noclip_speed * speed_multiplier / 2.0)
            end
            if IsPressedKey(noclip_move_down_key) then
                move_vector.z = move_vector.z - (noclip_speed * speed_multiplier / 2.0)
            end

            -- Handle entering/exiting vehicle while in vehicle noclip.
            if IsPressedKey(noclip_enter_exit_vehicle_key) then -- F
                disable_vehicle_noclip() -- Disable vehicle noclip.
                TASK.CLEAR_PED_TASKS(player_ped) -- Clear player ped tasks.
                SetGlobalVariableValue("NoclipActive", 1.0) -- Re-enable regular noclip.
                enable_noclip() -- Re-enable regular noclip (redundant due to line above, but matches original flow).
                return -- Exit on_tick to prevent further movement in this frame.
            end
            
            -- Update vehicle coordinates.
            current_coords = math_utils.sum_vectors(current_coords, move_vector)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(current_vehicle, current_coords.x, current_coords.y, current_coords.z, true, true, true)
            ENTITY.SET_ENTITY_ROTATION(current_vehicle, cam_rot.x, cam_rot.y, cam_rot.z, 2, true) -- Rotate vehicle with camera.
        else -- Noclip for player on foot.
            local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(2) -- Get current camera rotation.
            local current_coords = ENTITY.GET_ENTITY_COORDS(player_ped, true) -- Get current player coordinates.
            
            -- Convert rotation angles to radians.
            local heading_rad = math.rad(cam_rot.z)
            local pitch_rad = math.rad(cam_rot.x) -- Pitch angle (up/down).

            -- Calculate forward vector based on camera heading and pitch.
            local forward_vector = {
                x = -math.sin(heading_rad) * math.cos(pitch_rad),
                y = math.cos(heading_rad) * math.cos(pitch_rad),
                z = math.sin(pitch_rad)
            }

            -- Normalize the forward vector.
            local forward_magnitude = math.sqrt(forward_vector.x^2 + forward_vector.y^2 + forward_vector.z^2)
            if forward_magnitude ~= 0 then
                forward_vector.x = forward_vector.x / forward_magnitude
                forward_vector.y = forward_vector.y / forward_magnitude
                forward_vector.z = forward_vector.z / forward_magnitude
            end
            
            local move_vector = { x = 0.0, y = 0.0, z = 0.0 } -- Vector to accumulate movement.

            -- Apply speed multiplier if sprint key is pressed.
            if IsPressedKey(noclip_sprint_key) then -- Shift
                speed_multiplier = 3.0
            else
                speed_multiplier = 1.0 -- Reset if not pressed
            end

            -- Calculate movement based on pressed keys.
            if IsPressedKey(noclip_move_forward_key) then
                move_vector = math_utils.sum_vectors(move_vector, math_utils.mult_vector(forward_vector, noclip_speed * speed_multiplier))
            end
            if IsPressedKey(noclip_move_left_key) then
                local left_vector = { x = -forward_vector.y, y = forward_vector.x, z = 0.0 } -- Left vector
                local left_magnitude = math.sqrt(left_vector.x^2 + left_vector.y^2 + left_vector.z^2)
                if left_magnitude ~= 0 then
                    left_vector.x = left_vector.x / left_magnitude
                    left_vector.y = left_vector.y / left_magnitude
                    left_vector.z = left_vector.z / left_magnitude
                end
                move_vector = math_utils.sum_vectors(move_vector, math_utils.mult_vector(left_vector, noclip_speed * speed_multiplier))
            end
            if IsPressedKey(noclip_move_backward_key) then
                -- Original backward movement logic (as noted above).
                local backward_temp_vector = math_utils.mult_vector(forward_vector, (noclip_speed * 1.5) * speed_multiplier)
                move_vector = math_utils.sum_vectors(move_vector, backward_temp_vector)
                move_vector = math_utils.subtract_vectors(move_vector, backward_temp_vector)
            end
            if IsPressedKey(noclip_move_right_key) then
                local right_vector = { x = forward_vector.y, y = -forward_vector.x, z = 0.0 } -- Right vector
                local right_magnitude = math.sqrt(right_vector.x^2 + right_vector.y^2 + right_vector.z^2)
                if right_magnitude ~= 0 then
                    right_vector.x = right_vector.x / right_magnitude
                    right_vector.y = right_vector.y / right_magnitude
                    right_vector.z = right_vector.z / right_magnitude
                end
                move_vector = math_utils.sum_vectors(move_vector, math_utils.mult_vector(right_vector, noclip_speed * speed_multiplier))
            end
            if IsPressedKey(noclip_move_up_key) then
                move_vector.z = move_vector.z + (noclip_speed * speed_multiplier / 2.0)
            end
            if IsPressedKey(noclip_move_down_key) then
                move_vector.z = move_vector.z - (noclip_speed * speed_multiplier / 2.0)
            end
            
            -- Handle entering nearest vehicle while in on-foot noclip.
            if IsPressedKey(noclip_enter_exit_vehicle_key) then
                local nearest_vehicle = world_utils.get_nearest_vehicle_to_entity(player_ped, 5.0)
                if nearest_vehicle ~= 0.0 then
                    disable_noclip() -- Disable on-foot noclip.
                    SetGlobalVariableValue("NoclipActive", 0.0) -- Update global variable.
                    
                    -- Try to enter driver seat, if occupied, try passenger.
                    if VEHICLE.IS_VEHICLE_SEAT_FREE(nearest_vehicle, -1, true) then 
                        PED.SET_PED_INTO_VEHICLE(player_ped, nearest_vehicle, -1)
                    else
                        PED.SET_PED_INTO_VEHICLE(player_ped, nearest_vehicle, -2)
                    end
                    return nil -- Exit on_tick to prevent further movement in this frame.
                end
            end
            
            -- Update player coordinates.
            current_coords = math_utils.sum_vectors(current_coords, move_vector)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(player_ped, current_coords.x, current_coords.y, current_coords.z, true, true, true)
            ENTITY.SET_ENTITY_VISIBLE(player_ped, false, false) -- Ensure player remains invisible.
        end
    end
    speed_multiplier = 1.0 -- Reset speed multiplier for next tick.
end

--- Initializes noclip hotkey settings from configuration.
-- Reads key codes for noclip movement and toggling.
function initialize_settings()
    noclip_move_forward_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "NoclipMoveForwardKey"))
    noclip_move_backward_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "NoclipMoveBackwardKey"))
    noclip_move_left_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "NoclipMoveLeftKey"))
    noclip_move_right_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "NoclipMoveRightKey"))
    noclip_move_up_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "NoclipMoveUpKey"))
    noclip_move_down_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "NoclipMoveDownKey"))
    noclip_sprint_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "NoclipSprintKey"))
    noclip_enter_exit_vehicle_key = ConvertStringToKeyCode(config_utils.get_feature_setting("Hotkeys", "NoclipEnterExitVehicleKey"))
end

-- Initialize settings when the script starts.
initialize_settings()

-- Main script loop.
while ScriptStillWorking do
    -- Check if the "NoclipActive" global variable exists.
    if IsGlobalVariableExist("NoclipActive") then
        -- Determine if noclip is active based on the global variable's value (1.0 for active).
        noclip_active = GetGlobalVariable("NoclipActive") == 1.0

        -- State machine for enabling/disabling noclip.
        if noclip_active and not noclip_initialized then
            -- If noclip is active but not initialized, check if player is in a vehicle.
            if PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), false) then
                enable_vehicle_noclip()
            else
                enable_noclip()
            end
            wait_time = 0 -- Reduce wait time for active noclip loop.
        elseif not noclip_active and noclip_initialized then
            -- If noclip is inactive but initialized, disable it.
            if is_noclip_vehicle then
                disable_vehicle_noclip()
            else
                disable_noclip()
            end
            wait_time = 100 -- Restore default wait time when noclip is inactive.
        end

        -- If noclip is active, run the main tick logic.
        if noclip_active then
            on_tick()
        end
    else
        -- If global variable doesn't exist, ensure default wait time.
        wait_time = 100
    end
    Wait(wait_time) -- Pause script execution.
end

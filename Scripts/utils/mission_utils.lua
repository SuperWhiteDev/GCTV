local missionUtils = { }

function missionUtils.CreateMissionVehicle(model, x, y, z, heading)
    local hash = MISC.GET_HASH_KEY(model)

    if STREAMING.IS_MODEL_VALID(hash) then
        if not STREAMING.HAS_MODEL_LOADED(hash) then
            STREAMING.REQUEST_MODEL(hash)
        end

        local veh = VEHICLE.CREATE_VEHICLE(hash, x, y, z, heading, false, false, false)
        
        if veh ~= 0.0 then
            RegisterAsNetwork(veh)

            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, true)

            return veh
        else
            return missionUtils.CreateMissionVehicle(model, x+0.15, y+0.15, z+0.05, heading)
        end
    end

    return nil
end

function missionUtils.CreateMissionPed(model, pedtype, x, y, z, heading)
    local hash = MISC.GET_HASH_KEY(model)

    if STREAMING.IS_MODEL_VALID(hash) then
        if not STREAMING.HAS_MODEL_LOADED(hash) then
            STREAMING.REQUEST_MODEL(hash)
        end

        local ped = PED.CREATE_PED(pedtype, hash, x, y, z, 0.0, false, true)
        
        if ped ~= 0.0 then
            RegisterAsNetwork(ped)

            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ped, true, true)

            return ped
        else
            return missionUtils.CreateMissionPed(model, pedtype, x+0.01, y+0.01, z, heading)
        end
    end

    return nil
end

function missionUtils.CreateMissionPedInVehicle(vehicle, seat, model, pedtype, x, y, z, heading)
    local ped = missionUtils.CreateMissionPed(model, pedtype, x, y, z, heading)

    if ped then
        PED.SET_PED_INTO_VEHICLE(ped, vehicle, seat)
    end

    return ped
end

function missionUtils.CreateCamera(x, y, z, headingX, headingY, headingZ, transitionTime)
    local cam = CAM.CREATE_CAM("DEFAULT_SCRIPTED_CAMERA", true)
    CAM.SET_CAM_COORD(cam, x, y, z)
    CAM.SET_CAM_ROT(cam, headingZ, headingY, headingX, 2)
    CAM.RENDER_SCRIPT_CAMS(true, true, transitionTime, true, true)

    return cam
end

function missionUtils.CreateFlyCamera(x, y, z, headingX, headingY, headingZ, maxHeight, transitionTime)
    local cam = CAM.CREATE_CAM("DEFAULT_SCRIPTED_FLY_CAMERA", true)
    CAM.SET_CAM_COORD(cam, x, y, z)
    CAM.SET_CAM_ROT(cam, headingZ, headingY, headingX, 2)
    CAM.SET_FLY_CAM_MAX_HEIGHT(cam, maxHeight)
    CAM.RENDER_SCRIPT_CAMS(true, true, transitionTime, false, false, false) -- Render the camera
end

function missionUtils.DeleteCamera(camera)
    CAM.RENDER_SCRIPT_CAMS(false, false, 0, true, true)
    CAM.DESTROY_CAM(camera, false)
end

return missionUtils
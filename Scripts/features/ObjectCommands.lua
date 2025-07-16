local networkUtils = require("network_utils")
local mapUtils = require("map_utils")

local createdobjectsmodels = { }
local createdobjectsID = { }

function ControlObject(object)
    
end

function ObjectListCommand()
    if #createdobjectsID ~= 0 then
        local objectID = InputFromList("Choose the object you want to interact with: ", createdobjectsmodels)
        if objectID ~= -1 then
            local object = createdobjectsID[objectID+1]
            print("The object ID of the selected object is " .. object)

            local options = { "Control object", "Delete" }
            local option = InputFromList("Choose what you want to: ", options)

            if option == 0 then
                ControlObject(object)
            elseif option == 1 then
                networkUtils.RequestControlOf(object)
                DeleteObject(object)

                table.remove(createdobjectsID, objectID+1)
                table.remove(createdobjectsmodels, objectID+1)
            end
        end
    else
        print("There are no objects on the object list yet")
    end
end

function AddToObjectListCommand()
    local object = 0
    
    io.write("Enter object handle: ")
    local object = tonumber(io.read())
    
    if not object then
        DisplayError(false, "Uncorrect input")
        return nil
    end
    
    table.insert(createdobjectsmodels, ENTITY.GET_ENTITY_MODEL(object))
    table.insert(createdobjectsID, object)
end

function CreateObject(modelName, coords, rightoncoords)
    local failed = false
    local Iters = 0

    local hash = MISC.GET_HASH_KEY(modelName)

    if STREAMING.IS_MODEL_VALID(hash) then
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) and not failed do
            if Iters > 50 then
                DisplayError(false, "Failed to load the model")
                failed = true
            end

            Wait(5)
            Iters = Iters + 1
        end
        
        if not failed then
            local offsetY = 0.0
            if not rightoncoords then
                local dimensions = { x = 0.0, y = 0.0, z = 0.0 }
    
                local minDimensionvec = NewVector3(dimensions)
                local maxDimensionvec = NewVector3(dimensions)
                local minDimensionvecp = NewPointer(minDimensionvec)
                local maxDimensionvecp = NewPointer(maxDimensionvec)

                MISC.GET_MODEL_DIMENSIONS(hash, minDimensionvecp, maxDimensionvecp)

                local minDimension = Game.ReadVector3(minDimensionvecp)
                local maxDimension = Game.ReadVector3(maxDimensionvecp)

                DeleteVector3(minDimensionvec)
                DeleteVector3(maxDimensionvec)
                Delete(minDimensionvecp)
                Delete(maxDimensionvecp)

                offsetY = math.max(1.0, 1.3 * math.max(math.abs(maxDimension.x-minDimension.x), math.abs(maxDimension.y-minDimension.y)))
                print(offsetY)
            end
            local obj = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, coords.x+0.0, coords.y+offsetY, coords.z, false, false, true, 0)
            
            if obj ~= 0.0 and ENTITY.DOES_ENTITY_EXIST(obj) then
                networkUtils.RegisterAsNetwork(obj)
                ENTITY.SET_ENTITY_VELOCITY(obj, 0.0, 0.0, 0.0)
                ENTITY.SET_ENTITY_ROTATION(obj, 0, 0, 0, 0, false)
	            ENTITY.SET_ENTITY_COLLISION(obj, true, false)
                OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(obj)
                ENTITY.SET_ENTITY_VISIBLE(obj, true)
                printColoured("green", "Succesfully created new object. Object ID is " .. obj)

                table.insert(createdobjectsmodels, modelName)
                table.insert(createdobjectsID, obj)
            end

            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
        end
    end
end


function CreateObjectCommand()
    io.write("Enter object model(https://gtahash.ru/): ")
    local modelName = io.read()

    local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)

    CreateObject(modelName, coords, false)
end

function CreateObjectAtCommand()
    local coords = nil
    io.write("Enter object model(https://gtahash.ru/): ")
    local modelName = io.read()

    local places = { "Waypoint", "Custom" }
    local place = InputFromList("Enter where you want to create object: ", places)

    if place == 0 then
        coords = mapUtils.GetWaypointCoords()
        if not coords then
            print("Please choose a waypoint first")
            return nil
        end
    elseif place == 1 then
        io.write("Enter X coord: ")
        local CoordX = io.read()
        io.write("Enter Y coord: ")
        local CoordY = io.read()
        io.write("Enter Z coord: ")
        local CoordZ = io.read()

        coords = { x = CoordX, y = CoordY, z = CoordZ }
    end

    CreateObject(modelName, coords, true)
end

function DeleteObjectCommand()
    io.write("Enter object handle: ")
    local obj = tonumber(io.read())
    
    if obj then
        networkUtils.RequestControlOf(obj)
        DeleteObject(obj)
    else
        DisplayError(false, "Uncorrect input")
    end
end

function ObjectControlCommand()
    io.write("Enter object handle: ")
    local object = tonumber(io.read())
    
    if object then
        ControlObject(object)
    else
        DisplayError(false, "Uncorrect input")
    end
end


-- Определим словарь с командами и их функциями
local Commands = {
    ["object list"] = ObjectListCommand,
    ["add to object list"] = AddToObjectListCommand,
    ["create object"] = CreateObjectCommand,
    ["create object at"] = CreateObjectAtCommand,
    ["delete object"] = DeleteObjectCommand,
    ["object control"] = ObjectControlCommand
}

math.randomseed(os.time())

-- Цикл для регистрации команд
for commandName, commandFunction in pairs(Commands) do
    if not BindCommand(commandName, commandFunction) then
        DisplayError(true, "Failed to register the command: " .. commandName)
    end
end


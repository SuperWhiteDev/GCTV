--[[ DRIVING STYLES

00000000000000000000000000000001 - 1 - останавливаться перед транспортными средствами
00000000000000000000000000000010 - 2 - останавливаться перед пешеходами
00000000000000000000000000000100 - 4 - избегать транспортных средств
0000000000000000000000000001000 - 8 - избегать пустых транспортных средств
00000000000000000000000000010000 - 16 - избегать peds
000000000000000000000000000100000 - 32 - избегать объектов
0000000000000000000000000010000000 - 128 - останавливаться на светофоре
000000000000000000000100000000 - 256 - включать поворотники
0000000000000000000001000000000 - 512 - разрешать движение в неправильном направлении ( только если правильная полоса заполнена, попытается вернуться на правильную полосу как можно скорее )
00000000000000000000010000000000 - 1024 - ехать задним ходом ( назад ) 
00000000000001000000000000000000 - 262144 - Выбрать кратчайший путь ( снимает большинство ограничений на выбор пути , водитель едет даже по грунтовым дорогам )
000000000000100000000000000000000 - 524288 - Вероятно, избежите бездорожья
00000000010000000000000000000000 - 4194304 - Игнорировать дороги ( Использует локальный поиск путей , работает только в радиусе 200 ~ метров вокруг игрока )
000000010000000000000000000000000 - 16777216 - Игнорировать все пути ( идти прямо к месту назначения )
0010000000000000000000000000000000 - 536870912 - по возможности избегать автомагистралей ( будет использовать автомагистраль , если нет другого способа добраться до места назначения ) 

]]

local networkUtils = require("network_utils")
local mapUtils = require("map_utils")
local vehicleUtils = require("vehicle_utils")
local PedUtils = require("ped_utils")
local missionUtils = require("mission_utils")
local configUtils = require("config_utils")


local ViewAllPedsNextKey = nil
local ViewAllPedsBackKey = nil
local ViewAllPedsSelectKey = nil

local createdpedsmodels = { }
local createdpedsID = { }

--View all peds command variables
local viewAllPedsList = JsonReadList("peds.json")  -- Список доступных педов
local viewAllPedsListIndex = 1
local viewAllPedsAnimations = { "WORLD_HUMAN_AA_COFFEE", "WORLD_HUMAN_SMOKING_POT" }
local viewAllPedsCurrentPed = nil
local StillViewingAllPeds = false
local viewAllPedscamera = nil

--DELETE
function MakeVehicleMaxTuning(veh)
    VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, math.random(0, 6))
    VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)

    for i = 0, 30, 1 do
        if i >= 17 and i <= 24 then

        else
            local modscount = VEHICLE.GET_NUM_VEHICLE_MODS(veh, i) - 1
            if modscount < 1 then
            
            else
            VEHICLE.SET_VEHICLE_MOD(veh, i, math.random(0, modscount), 0)
            end
        end
    end

    local vehmodscount = VEHICLE.GET_NUM_VEHICLE_MODS(veh, 48) - 1
    if vehmodscount > 1 then
        VEHICLE.SET_VEHICLE_MOD(veh, 48, math.random(0, vehmodscount), 0)
    end

    VEHICLE.TOGGLE_VEHICLE_MOD(veh, 20, true)
    VEHICLE.TOGGLE_VEHICLE_MOD(veh, 22, true)
    VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, false)
    VEHICLE.SET_VEHICLE_WHEELS_CAN_BREAK(veh, false)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(veh, "PRIVATE")
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, math.random(0, 5))
    
    VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 0, true)
    VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 1, true)
    VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 2, true)
    VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 3, true)
    VEHICLE.SET_VEHICLE_NEON_COLOUR(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
    VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))
    VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(veh, math.random(0, 13))
end
--DELETE

function GiveWeaponsToPed(ped)
    io.write("Enter weapon(https://forge.plebmasters.de/weapons): ")
    local firstweapon = io.read()

    local hash = MISC.GET_HASH_KEY(firstweapon)

    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(ped, hash, 1000, true)

    io.write("You want to give ped a second weapon? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        io.write("Enter weapon(https://forge.plebmasters.de/weapons): ")
        local secondweapon = io.read()

        hash = MISC.GET_HASH_KEY(secondweapon)

        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(ped, hash, 1000, true)
    end
end

function MakePedBodyGuardForPed(playerPed, bodyguard)
    local makeInvinsible = false

    TASK.CLEAR_PED_TASKS(bodyguard)
    TASK.CLEAR_PED_SECONDARY_TASK(bodyguard)
    local playerPedGroup = PED.GET_PED_GROUP_INDEX(playerPed)
    PED.SET_PED_AS_GROUP_MEMBER(bodyguard, playerPedGroup)

    io.write("Make the bodyguard invincible? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        ENTITY.SET_ENTITY_INVINCIBLE(bodyguard, true)
    end 

    PED.SET_PED_CAN_RAGDOLL(bodyguard, false)
	PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(bodyguard, false)
	PED.SET_PED_COMBAT_RANGE(bodyguard, 500)
	PED.SET_PED_ALERTNESS(bodyguard, 100)
	PED.SET_PED_ACCURACY(bodyguard, 100)
	PED.SET_PED_CAN_SWITCH_WEAPON(bodyguard, 1)
	PED.SET_PED_SHOOT_RATE(bodyguard, 200)
	PED.SET_PED_KEEP_TASK(bodyguard, true)
	TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(bodyguard, 5000, 0)

    io.write("You want to give bodyguard the weapon? [Y/n]: ")
    local input = string.lower(io.read())

    if input == "y" then
        local options = { "Random", "Custom" }
        local option = InputFromList("Enter the weapon you want to give to the bodyguard: ", options)

        if option == 0 then
            local firstweapons = { "WEAPON_BATTLERIFLE", "Carbine Rifle", "WEAPON_TACTICALRIFLE", "WEAPON_COMBATMG_MK2", "WEAPON_CARBINERIFLE_MK2", "Military Rifle" }
            local secondweapons = { "WEAPON_TECPISTOL", "Heavy Pistol", "WEAPON_PISTOLXM3", "WEAPON_PISTOL_MK2", "WEAPON_REVOLVER_MK2" }
            local grenades = { "WEAPON_GRENADE", "Tear Gas", "Molotov" }
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(bodyguard, MISC.GET_HASH_KEY(firstweapons[math.random(1, #firstweapons)]), 1000, true)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(bodyguard, MISC.GET_HASH_KEY(secondweapons[math.random(1, #secondweapons)]), 1000, true)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(bodyguard, MISC.GET_HASH_KEY(grenades[math.random(1, #grenades)]), 1000, true)
        elseif option == 1 then
            GiveWeaponsToPed(bodyguard)
        end
    end 

	PED.SET_PED_CAN_SWITCH_WEAPON(bodyguard, true)
	PED.SET_PED_KEEP_TASK(bodyguard, true)
	PED.SET_PED_GENERATES_DEAD_BODY_EVENTS(bodyguard, true)
end

function ControlPed(ped)
    local options = { "Go to", "Drive to", "Stop driving", "Make angry", "Make friendly", "Make come to vehicle", "Make bodyguard", "Freeze ped", "Set action", "Play animation", "Set invincible", "Seat to", "Heal", "Fill armor", "Kill" }
    local option = InputFromList("Choose what you want to: ", options)

    networkUtils.RequestControlOf(ped)
    if option == 0 then
        local options = { "Waypoint", "Current position", "Custom" }
        local option = InputFromList("Choose where you want the ped to go: ", options)

        if option == 0 then
            local coords = GetWaypointCoords()
            if not coords then
                print("Please choose a waypoint first")
                return nil
            end
            TASK.TASK_FLUSH_ROUTE()
            TASK.TASK_EXTEND_ROUTE(coords.x, coords.y, coords.z)
            TASK.TASK_FOLLOW_POINT_ROUTE(ped, 1.0, 0)
        elseif option == 1 then
            local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)

            TASK.TASK_FLUSH_ROUTE()
            TASK.TASK_EXTEND_ROUTE(coords.x, coords.y, coords.z)
            TASK.TASK_FOLLOW_POINT_ROUTE(ped, 1.0, 0)
        elseif option == 2 then
            io.write("Enter X coord: ")
            local CoordX = io.read()
            io.write("Enter Y coord: ")
            local CoordY = io.read()
            io.write("Enter Z coord: ")
            local CoordZ = io.read()

            TASK.TASK_FLUSH_ROUTE()
            TASK.TASK_EXTEND_ROUTE(CoordX, CoordY, CoordZ)
            TASK.TASK_FOLLOW_POINT_ROUTE(ped, 1.0, 0)
        end
    elseif option == 1 then
        local drivingStyle = nil
        local speed = nil

        io.write("You want the ped to drive fast? [Y/n]: ")
        local input = string.lower(io.read())

        if input == "y" then
            drivingStyle = 262204--262157
        elseif input == "n" then
            drivingStyle = 399
        end

        local options = { "Waypoint", "Local player position", "Custom" }
        local option = InputFromList("Choose where you want the ped to go: ", options)

        if option == 0 then
            local coords = GetWaypointCoords()
            if not coords then
                print("Please choose a waypoint first")
                return nil
            end

            local veh = PED.GET_VEHICLE_PED_IS_IN(ped, true)
            local vehModel = ENTITY.GET_ENTITY_MODEL(veh)
            speed = VEHICLE.GET_VEHICLE_MODEL_ESTIMATED_MAX_SPEED(vehModel)
            if speed < 40.0 then
                speed = 40.0
            end

            if veh ~= 0.0 then
                local vehicleCoords = ENTITY.GET_ENTITY_COORDS(veh, true)

                if GetDistanceBetweenCoords(vehicleCoords, coords) >= 1000.0 then
	                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(ped, veh, coords.x, coords.y, coords.z, speed, drivingStyle, 25.0)
                else
                    TASK.TASK_VEHICLE_DRIVE_TO_COORD(ped, veh, coords.x, coords.y, coords.z, speed, 1, vehModel, drivingStyle, 6, -1)
                end
            end
        elseif option == 1 then
            local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)

            local veh = PED.GET_VEHICLE_PED_IS_IN(ped, true)
            local vehModel = ENTITY.GET_ENTITY_MODEL(veh)
            speed = VEHICLE.GET_VEHICLE_MODEL_ESTIMATED_MAX_SPEED(vehModel)
            if speed < 40.0 then
                speed = 40.0
            end
            local vehicleCoords = ENTITY.GET_ENTITY_COORDS(veh, true)

            if veh ~= 0.0 then
                if GetDistanceBetweenCoords(vehicleCoords, coords) >= 1000.0 then
	                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(ped, veh, coords.x, coords.y, coords.z, speed, drivingStyle, 25.0);
                else
                    TASK.TASK_VEHICLE_DRIVE_TO_COORD(ped, veh, coords.x, coords.y, coords.z, speed, 1, vehModel, drivingStyle, 6, -1)
                end
            end
        elseif option == 2 then
            io.write("Enter X coord: ")
            local CoordX = io.read()
            io.write("Enter Y coord: ")
            local CoordY = io.read()
            io.write("Enter Z coord: ")
            local CoordZ = io.read()
            local coords = { x = CoordX, y = CoordY, z = CoordZ }

            local veh = PED.GET_VEHICLE_PED_IS_IN(ped, true)
            local vehModel = ENTITY.GET_ENTITY_MODEL(veh)
            speed = VEHICLE.GET_VEHICLE_MODEL_ESTIMATED_MAX_SPEED(vehModel)
            if speed < 40.0 then
                speed = 40.0
            end
            local vehicleCoords = ENTITY.GET_ENTITY_COORDS(veh, true)

            if veh ~= 0.0 then
                if GetDistanceBetweenCoords(vehicleCoords, coords) >= 1000.0 then
	                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(ped, veh, coords.x, coords.y, coords.z, speed, drivingStyle, 25.0);
                else
                    TASK.TASK_VEHICLE_DRIVE_TO_COORD(ped, veh, coords.x, coords.y, coords.z, speed, 1, vehModel, drivingStyle, 6, -1)
                end
            end
        end
    elseif option == 2 then
        local veh = PED.GET_VEHICLE_PED_IS_IN(ped, true)

        io.write("You want the ped to park the vehicle? [Y/n]: ")
        local input = string.lower(io.read())

        if input == "y" then
            local coords = ENTITY.GET_ENTITY_COORDS(veh, true)
            TASK.TASK_VEHICLE_PARK(ped, veh, coords.x, coords.y, coords.z, 0.0, 1, 20.0, false)
        elseif input == "n" then
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 0.0)
            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, false, true)
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
            PED.SET_PED_INTO_VEHICLE(ped, veh, -1)
        end
    elseif option == 3 then
        PED.SET_PED_AS_ENEMY(ped, true)
        TASK.TASK_COMBAT_HATED_TARGETS_AROUND_PED(ped, 10000.0, 0)
        PED.SET_PED_KEEP_TASK(ped, true)
    elseif option == 4 then
        local playerPedGroup = PED.GET_PED_GROUP_INDEX(PLAYER.PLAYER_PED_ID())
        PED.SET_PED_AS_GROUP_MEMBER(ped, playerPedGroup)
    elseif option == 5 then
        local veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        if veh ~= 0.0 then
            TASK.TASK_ENTER_VEHICLE(ped, veh, 10000, 0, 1.0, 1, 0, 0)
        end 
        PED.SET_PED_KEEP_TASK(ped, true)
    elseif option == 6 then
        io.write("Enter player ID: ")
        local player = tonumber(io.read())

        if player then
            local playerPed = PLAYER.GET_PLAYER_PED(player)
            MakePedBodyGuardForPed(playerPed, ped)
        end
    elseif option == 7 then
        io.write("You want to freeze the ped? [Y/n]: ")
        local input = string.lower(io.read())

        if input == "y" then
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
            ENTITY.FREEZE_ENTITY_POSITION(ped, true)
        elseif input == "n" then
            ENTITY.FREEZE_ENTITY_POSITION(ped, false)
        end
    elseif option == 8 then
        local actions = { "Drilling", "Cop", "Chin Ups", "Binoculars", "Hammering", "420", "Leaf Blower", "Musician", "Drinking Coffee", "Jogging", "Fishing", "Push Ups",
                          "Sit Ups", "Yoga", "Gym Lad", "Stop action" }
        local actionNames = { "WORLD_HUMAN_CONST_DRILL", "CODE_HUMAN_POLICE_INVESTIGATE", "PROP_HUMAN_MUSCLE_CHIN_UPS", "WORLD_HUMAN_BINOCULARS", "WORLD_HUMAN_HAMMERING",
                              "WORLD_HUMAN_SMOKING_POT", "WORLD_HUMAN_GARDENER_LEAF_BLOWER", "WORLD_HUMAN_MUSICIAN", "WORLD_HUMAN_AA_COFFEE", "WORLD_HUMAN_JOG_STANDING",
                              "WORLD_HUMAN_STAND_FISHING", "WORLD_HUMAN_PUSH_UPS", "WORLD_HUMAN_SIT_UPS", "WORLD_HUMAN_YOGA", "WORLD_HUMAN_MUSCLE_FREE_WEIGHTS" }
        local action = InputFromList("Choose an action for the ped: ", actions)

        if action == 15 then
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
        else
            TASK.TASK_START_SCENARIO_IN_PLACE(ped, actionNames[action+1], 0, true)
        end
    elseif option == 9 then
        local iters = 0
        local animations = { "Pole Dance 1", "Pole Dance 2", "Pole Dance 3", "Stunned", "Situps", "Pushups", "Wave Arms", "Suicide", "On The Can", "On Fire", "Cower", "Private Dance",
                          "BJ", "Stungun", "Air Fuck", "Air Fuck 2", "Stop animation" }
        local animationNames = { "pd_dance_01", "pd_dance_02", "pd_dance_03", "electrocute", "base", "base", "waving", "pistol_fp", "trevonlav_struggleloop", "on_fire",
                                 "kneeling_arrest_idle", "priv_dance_p1", "bj_loop_prostitute", "Damage", "shag_loop_a", "shag_loop_poppy" }
        local animationDicts = { "mini@strip_club@pole_dance@pole_dance1", "mini@strip_club@pole_dance@pole_dance2", "mini@strip_club@pole_dance@pole_dance3", "ragdoll@human",
                                 "amb@world_human_sit_ups@male@base", "amb@world_human_push_ups@male@base", "random@car_thief@waving_ig_1", "mp_suicide",
                                 "timetable@trevor@on_the_toilet", "ragdoll@human", "random@arrests", "mini@strip_club@private_dance@part1", "mini@prostitutes@sexnorm_veh",
                                 "stungun@standing", "rcmpaparazzo_2", "rcmpaparazzo_2" }
        local animation = InputFromList("Choose an animation for the ped: ", animations)

        if animation == 16 then
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
            TASK.CLEAR_PED_SECONDARY_TASK(ped)
        else
            STREAMING.REQUEST_ANIM_SET(animationNames[animation+1])
            STREAMING.REQUEST_ANIM_DICT(animationDicts[animation+1])
            while not STREAMING.HAS_ANIM_DICT_LOADED(animationDicts[animation+1]) and iters < 50 do
                iters = iters + 1
                Wait(1)
            end
    
            TASK.TASK_PLAY_ANIM(ped, animationDicts[animation+1], animationNames[animation+1], 1.0, 1.0, -1, 127, 0.0, false, false, false)
        end
    elseif option == 10 then
        io.write("Set the ped invincible? [Y/n]: ")
        local input = string.lower(io.read())

        if input == "y" then
            ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
        elseif input == "n" then
            ENTITY.SET_ENTITY_INVINCIBLE(ped, false)
        end
    elseif option == 11 then
        local veh = PED.GET_VEHICLE_PED_IS_IN(ped, true)
        if veh ~= 0.0 then
            local seats = { "Driver seat", "Available passenger seat", "Custom" }
            local seat = InputFromList("Choose where you want to seat the ped in the ped vehicle: ", seats)

            if seat == 0 then
                local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, true)
                PED.SET_PED_INTO_VEHICLE(driver, veh, -2)
                PED.SET_PED_INTO_VEHICLE(ped, veh, -1)
                PED.SET_PED_INTO_VEHICLE(driver, veh, -2)
            elseif seat == 1 then
                PED.SET_PED_INTO_VEHICLE(ped, veh, -2)
            elseif seat == 2 then
                io.write("Enter the seat index: ")
                local seatIndex  = tonumber(io.read())
            
                if seatIndex then
                    local passenger = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, seatIndex, true)
                    PED.SET_PED_INTO_VEHICLE(passenger, veh, -2)
                    PED.SET_PED_INTO_VEHICLE(ped, veh, seatIndex)
                    PED.SET_PED_INTO_VEHICLE(passenger, veh, -2)
                end
            end
        end
    elseif option == 12 then
        ENTITY.SET_ENTITY_HEALTH(ped, PED.GET_PED_MAX_HEALTH(ped), 0, 0)
    elseif option == 13 then
        PED.SET_PED_ARMOUR(ped, 100)
    elseif option == 14 then
        ENTITY.SET_ENTITY_HEALTH(ped, 0, PLAYER.PLAYER_PED_ID(), 0)
    end
end

function PedsListCommand()
    if #createdpedsID ~= 0 then
        local pedID = InputFromList("Choose the ped you want to interact with: ", createdpedsmodels)
        if pedID ~= -1 then
            local ped = createdpedsID[pedID+1]

            local options = { "Control ped", "Delete" }
            local option = InputFromList("Choose what you want to: ", options)

            if option == 0 then
                ControlPed(ped)
            elseif option == 1 then
                networkUtils.RequestControlOf(ped)
                DeletePed(ped)

                table.remove(createdpedsID, pedID+1)
                table.remove(createdpedsmodels, pedID+1)
            end
        end
    else
        print("There are no peds on the peds list yet")
    end
end

function CreatePedCommand()
    local hash = nil

    io.write("Enter ped model(https://forge.plebmasters.de/peds): ")
    local modelName = io.read()

    if modelName == "" then
        modelName = PedUtils.GetRandomPedModelName()
    end

    hash = MISC.GET_HASH_KEY(modelName)

    local failed = false
    local Iters = 0
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
            local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)

            io.write("Enter ped type(https://alloc8or.re/gta5/doc/enums/ePedType.txt): ")
            local pedtype = tonumber(io.read())

            local ped = PED.CREATE_PED(pedtype, hash, coords.x + 1.5, coords.y + 1.0, coords.z + 0.2, 0.0, false, true)

            if ped then
                networkUtils.RegisterAsNetwork(ped)

                local blip = HUD.ADD_BLIP_FOR_ENTITY(ped)
                HUD.SET_BLIP_AS_FRIENDLY(blip, true)
                HUD.SET_BLIP_SPRITE(blip, mapUtils.GetBlipFromEntityModel(hash))
                HUD.SET_BLIP_COLOUR(blip, 68)
                HUD.SET_BLIP_DISPLAY(blip, 6)

                TASK.TASK_LOOK_AT_ENTITY(ped, PLAYER.PLAYER_PED_ID(), 0, 1, 10)
                if PED.IS_PED_IN_ANY_VEHICLE(PLAYER.PLAYER_PED_ID(), true) then
                    TASK.TASK_ENTER_VEHICLE(ped, PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false), 10000, 0, 1.0, 1, 0, 0)
                end 
                PED.SET_PED_KEEP_TASK(ped, true)

                io.write("You want to give ped the weapon? [Y/n]: ")
                local input = string.lower(io.read())

                if input == "y" then
                    GiveWeaponsToPed(ped)
                end

                printColoured("green", "Succesfully created new ped. Ped ID is " .. ped)
                table.insert(createdpedsmodels, modelName)
                table.insert(createdpedsID, ped)
            end
        end    
    end
end
function DeletePedCommand()
    io.write("Enter ped handle: ")
    local ped = tonumber(io.read())
    if ped then
        networkUtils.RequestControlOf(ped)
        DeletePed(ped)
    else
        DisplayError(false, "Uncorrect input")
    end
end

function PedControlCommand()
    io.write("Enter ped handle: ")
    local ped = tonumber(io.read())
    if ped then
        ControlPed(ped)
    else
        DisplayError(false, "Uncorrect input")
    end
end

function CreateBodyguardCommand()
    local playerPed = nil
    local modelName = nil

    local options = { "Me", "Player" }
    local option = InputFromList("Enter who you want to create a bodyguard for: ", options)

    if option == 0 then
        playerPed = PLAYER.PLAYER_PED_ID()
    elseif option == 1 then
        io.write("Enter player ID: ")
        local player = tonumber(io.read())
    
        if player then
            playerPed = PLAYER.GET_PLAYER_PED(player)
        end
    else
        return nil
    end

    local models = { "Mexicano guard", "Gang guard", "Elite guard", "SecuroServ guard", "Merryweather guard", "Police guard", "Custom" }
    local model = InputFromList("Enter a model for the bodyguard: ", models)

    if model == 0 then
        local MexicanoGuardModels = { "G_M_M_CartelGuards_02", "G_M_M_CartelGuards_01" }
        modelName = MexicanoGuardModels[math.random(1, #MexicanoGuardModels)]
    elseif model == 1 then
        local GangGuardModels = { "G_M_M_CartelGoons_01", "G_M_M_Goons_01", "G_M_ImportExport_01", "MP_M_BogdanGoon" }
        modelName = GangGuardModels[math.random(1, #GangGuardModels)]
    elseif model == 2 then
        local EliteGuardModels = { "IG_Security_A", "S_M_M_HighSec_04", "S_M_M_HighSec_01", "S_M_Y_DevinSec_01" }
        modelName = EliteGuardModels[math.random(1, #EliteGuardModels)]
    elseif model == 3 then
        local SecuroServGuardModels = { "MP_M_SecuroGuard_01", "S_M_M_Security_01" }
        modelName = SecuroServGuardModels[math.random(1, #SecuroServGuardModels)]
    elseif model == 4 then
        local MerryweatherGuardModels = { "S_M_Y_BlackOps_03", "S_M_Y_BlackOps_01" }
        modelName = MerryweatherGuardModels[math.random(1, #MerryweatherGuardModels)]
    elseif model == 5 then
        local GangGuardModels = { "S_M_M_FIBSec_01", "S_M_M_CIASec_01", "S_M_Y_Swat_01" }
        modelName = GangGuardModels[math.random(1, #GangGuardModels)]
    elseif model == 6 then
        io.write("Enter ped model(https://forge.plebmasters.de/peds): ")
        modelName = io.read()
    else
        return nil
    end

    local hash = MISC.GET_HASH_KEY(modelName)

    local failed = false
    local Iters = 0
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
            local coords = ENTITY.GET_ENTITY_COORDS(playerPed, false)

	        local bodyguard = PED.CREATE_PED(1, hash, coords.x, coords.y + 4.0, coords.z, ENTITY.GET_ENTITY_HEADING(playerPed), false, true)

            if bodyguard then
                networkUtils.RegisterAsNetwork(bodyguard)

                MakePedBodyGuardForPed(playerPed, bodyguard)

                printColoured("green", "Succesfully created bodyguard. Ped ID is " .. bodyguard)
                table.insert(createdpedsmodels, modelName)
                table.insert(createdpedsID, bodyguard)
            end
	        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
        end
    end
end
function CreatePedInVehCommand()
    local Iters = 0
    local failed = false
    local Tunning = false
    local vehhash = nil
    local pedhash = nil
    local ped = nil
    local veh = nil

    io.write("Enter vehicle model(https://forge.plebmasters.de/vehicles): ")
    local vehmodelName = io.read()
    if vehmodelName == "" then
        vehmodelName = vehicleUtils.GetRandomVehicleModelName()
        vehhash = MISC.GET_HASH_KEY(vehmodelName)

        repeat
            vehmodelName = vehicleUtils.GetRandomVehicleModelName()
            vehhash = MISC.GET_HASH_KEY(vehmodelName)

            Iters = Iters + 1

            Wait(1)
        until not VEHICLE.IS_THIS_MODEL_A_CAR(vehhash) and not VEHICLE.IS_THIS_MODEL_A_BIKE(vehhash) and not VEHICLE.IS_THIS_MODEL_A_QUADBIKE(vehhash) and not VEHICLE.IS_THIS_MODEL_AN_AMPHIBIOUS_CAR(vehhash) and not VEHICLE.IS_THIS_MODEL_AN_AMPHIBIOUS_QUADBIKE(vehhash) and Iters < 50
    else
        vehhash = MISC.GET_HASH_KEY(vehmodelName)
    end 
    
    Iters = 0
    if STREAMING.IS_MODEL_VALID(vehhash) then
        STREAMING.REQUEST_MODEL(vehhash)
        while not STREAMING.HAS_MODEL_LOADED(vehhash) and not failed do
            if Iters > 50 then
                DisplayError(false, "Failed to load the model")
                failed = true
            end

            Wait(5)
            Iters = Iters + 1
        end
        
        if not failed then
            local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)

            io.write("Create an already tuned? [Y/n]: ")
            local input = string.lower(io.read())

            if input == "y" then
                Tunning = true
            end 

            veh = VEHICLE.CREATE_VEHICLE(vehhash, coords.x + 10.5, coords.y + 9.0, coords.z + 0.5, 0.0, false, false, false)
            networkUtils.RegisterAsNetwork(veh)
            

            if veh ~= 0.0 then
                VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh, 5.0)
                if Tunning then
                    MakeVehicleMaxTuning(veh)
                end
                
                VEHICLE.SET_VEHICLE_IS_WANTED(veh, false)
    
                local blip = HUD.ADD_BLIP_FOR_ENTITY(veh)

                HUD.SET_BLIP_AS_FRIENDLY(blip, true)
                HUD.SET_BLIP_SPRITE(blip, mapUtils.GetBlipFromEntityModel(vehhash))
                HUD.SET_BLIP_COLOUR(blip, blip_enums.BlipColour.Blue2)
                HUD.SET_BLIP_DISPLAY(blip, blip_enums.BlipDisplay.SelectableShowsOnBothMaps)
            end

            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehhash)
        end

        io.write("Enter ped model(https://forge.plebmasters.de/peds): ")
        local pedmodelName = io.read()
        local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)

        if pedmodelName == "" then
            ped = PED.CREATE_RANDOM_PED_AS_DRIVER(veh, true)
            if ped == 0.0 then
                pedmodelName = PedUtils.GetRandomPedModelName()
            end
        end
        if not ped or ped == 0.0 then
            pedhash = MISC.GET_HASH_KEY(pedmodelName)

            Iters = 0
            if STREAMING.IS_MODEL_VALID(pedhash) then
                STREAMING.REQUEST_MODEL(pedhash)
                while not STREAMING.HAS_MODEL_LOADED(pedhash) and not failed do
                    if Iters > 50 then
                        DisplayError(false, "Failed to load the model")
                        failed = true
                    end
        
                    Wait(5)
                    Iters = Iters + 1
                end
                
                if not failed then
                    ped = PED.CREATE_PED(2, pedhash, coords.x + 3.5, coords.y + 3.0, coords.z + 0.2, 0.0, false, true)
                end
            end
        end

        if ped then
            networkUtils.RegisterAsNetwork(ped)
            PED.SET_PED_INTO_VEHICLE(ped, veh, -1)

            TASK.TASK_VEHICLE_DRIVE_TO_COORD(ped, veh, coords.x, coords.y, coords.z, 40.0, 1, vehmodelName, 399, 6, -1)

            printColoured("green", "Succesfully created ped and vehicle. Ped ID is " .. ped .. ". Vehicle ID is " .. veh)

            table.insert(createdpedsmodels, pedmodelName)
            table.insert(createdpedsID, ped)
        end
    end
end


function BreakViewAllPeds()
    -- Удалить камеру
    if viewAllPedscamera then
        missionUtils.DeleteCamera(viewAllPedscamera)
        viewAllPedscamera = nil
    end

    -- Позволить игроку управлять персонажем снова
    PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), true, 0)
    STREAMING.SET_FOCUS_ENTITY(PLAYER.PLAYER_PED_ID())

    -- Удалить текущий транспорт
    if viewAllPedsCurrentPed then
        networkUtils.RequestControlOf(viewAllPedsCurrentPed)

        DeleteVehicle(viewAllPedsCurrentPed)
        if ENTITY.DOES_ENTITY_EXIST(viewAllPedsCurrentPed) then
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(viewAllPedsCurrentPed, -1000.0, 1000.0, 0.0, true, true, true)
            DeletePed(viewAllPedsCurrentPed)
        end

        viewAllPedsCurrentPed = nil
    end

    StillViewingAllPeds = false
    io.write_anonym("\n")
end

function SpawnPed(PedName, coords)
    local iters = 0
    -- Удаляем старый транспорт, если он существует
    if viewAllPedsCurrentPed then
        networkUtils.RequestControlOf(viewAllPedsCurrentPed)

        DeletePed(viewAllPedsCurrentPed)
        if ENTITY.DOES_ENTITY_EXIST(viewAllPedsCurrentPed) then
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(viewAllPedsCurrentPed, 0.0, 0.0, 0.0, true, true, true)
            DeletePed(viewAllPedsCurrentPed)
        end
    end
    
    -- Спавним новый транспорт
    local hash = MISC.GET_HASH_KEY(PedName)
    if STREAMING.IS_MODEL_VALID(hash) then
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) do
            if iters > 50 then
                io.write_anonym("\n")
                DisplayError(false, "Failed to load the ".. PedName .. " model")
                BreakViewAllPeds()
                return nil
            end

            Wait(5)
            iters = iters + 1
        end
    else
        io.write_anonym("\n")
        DisplayError(false, "Unable to continue execution because the model ".. PedName .. " not valid")
        BreakViewAllPeds()
        return nil
    end

    viewAllPedsCurrentPed = PED.CREATE_PED(1, hash, coords.x, coords.y, coords.z, -294.0, false, true)
    STREAMING.SET_FOCUS_ENTITY(viewAllPedsCurrentPed)

    local action = math.random(1, #viewAllPedsAnimations+1)  

    if action <= #viewAllPedsAnimations and PED.IS_PED_HUMAN(viewAllPedsAnimations) then
        --TASK.TASK_START_SCENARIO_IN_PLACE(viewAllPedsCurrentPed, viewAllPedsAnimations[action], 0, true)
    end    

    ENTITY.FREEZE_ENTITY_POSITION(viewAllPedsCurrentPed, true)

    local pedp = NewPed(viewAllPedsCurrentPed)
    
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
    ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(pedp)
    Delete(pedp)

    ResetLineAndPrint(PedName)
end

function ChangePed(direction)
    viewAllPedsListIndex = viewAllPedsListIndex + direction
    if viewAllPedsListIndex > #viewAllPedsList then
        viewAllPedsListIndex = 1
    elseif viewAllPedsListIndex < 1 then
        viewAllPedsListIndex = #viewAllPedsList
    end

    AUDIO.PLAY_SOUND_FRONTEND(-1, "SELECT", "HUD_LIQUOR_STORE_SOUNDSET", true)

    -- Спавнить новый транспорт
    SpawnPed(viewAllPedsList[viewAllPedsListIndex], {x = -482.3, y = -133.3, z = 38.0})
end

function ViewAllPedsCommand()
    StillViewingAllPeds = true
    viewAllPedsListIndex = 1

    io.write_anonym("\n")
    -- Установить камеру на заданные координаты
    local cameraCoords = {x = -485.89999389648, y = -131.19999694824, z = 39.5}
    local heading = 234.0

    -- Создаем камеру
    viewAllPedscamera = missionUtils.CreateCamera(cameraCoords.x, cameraCoords.y, cameraCoords.z, heading, 0.0, 0.0, 0)

    -- Запретить управление игроком
    PLAYER.SET_PLAYER_CONTROL(PLAYER.PLAYER_ID(), false, 0)

    -- Спавнить первый автомобиль
    SpawnPed(viewAllPedsList[viewAllPedsListIndex], {x = -482.3, y = -133.3, z = 38.0})
    
    -- Вход в основной цикл
    while true do
        if not StillViewingAllPeds then
            return nil
        end
        -- Обработка нажатия клавиш
        if IsPressedKey(ViewAllPedsNextKey) then
            ChangePed(1)
        elseif IsPressedKey(ViewAllPedsBackKey) then
            ChangePed(-1)
        elseif IsPressedKey(ViewAllPedsSelectKey) then
            local coords = CAM.GET_CAM_COORD(viewAllPedscamera)
            --print(coords.x, coords.y, coords.z) -- DEBUG
            BreakViewAllPeds()
            break
        --[[

        --DEBUG

        elseif IsPressedKey(0x41) then
            cameraCoords.y = cameraCoords.y + 1.0
            CAM.SET_CAM_COORD(viewAllPedscamera, cameraCoords.x, cameraCoords.y, cameraCoords.z)
            print(cameraCoords.x, cameraCoords.y, cameraCoords.z)
            Wait(100)
        elseif IsPressedKey(0x44) then
            cameraCoords.y = cameraCoords.y - 1.0
            CAM.SET_CAM_COORD(viewAllPedscamera, cameraCoords.x, cameraCoords.y, cameraCoords.z)
            print(cameraCoords.x, cameraCoords.y, cameraCoords.z)
            Wait(100)
        elseif IsPressedKey(0x57) then
            cameraCoords.x = cameraCoords.x + 1.0
            CAM.SET_CAM_COORD(viewAllPedscamera, cameraCoords.x, cameraCoords.y, cameraCoords.z)
            print(cameraCoords.x, cameraCoords.y, cameraCoords.z)
            Wait(100)
        elseif IsPressedKey(0x53) then
            cameraCoords.x = cameraCoords.x - 1.0
            CAM.SET_CAM_COORD(viewAllPedscamera, cameraCoords.x, cameraCoords.y, cameraCoords.z)
            print(cameraCoords.x, cameraCoords.y, cameraCoords.z)
            Wait(100)
        elseif IsPressedKey(0x20) then
            cameraCoords.z = cameraCoords.z + 1.0
            CAM.SET_CAM_COORD(viewAllPedscamera, cameraCoords.x, cameraCoords.y, cameraCoords.z)
            print(cameraCoords.x, cameraCoords.y, cameraCoords.z)
            Wait(100)
        elseif IsPressedKey(0x11) then
            cameraCoords.z = cameraCoords.z - 1.0
            CAM.SET_CAM_COORD(viewAllPedscamera, cameraCoords.x, cameraCoords.y, cameraCoords.z)
            print(cameraCoords.x, cameraCoords.y, cameraCoords.z)
            Wait(100)
        ]]
        end

        Wait(10)
    end
end

function InitializeSettings()
    ViewAllPedsNextKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "ViewAllPedsNextKey"))
    ViewAllPedsBackKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "ViewAllPedsBackKey"))
    ViewAllPedsSelectKey = ConvertStringToKeyCode(configUtils.GetFeatureSetting("Hotkeys", "ViewAllPedsSelectKey"))
end

-- Определим словарь с командами и их функциями
local Commands = {
    ["ped list"] = PedsListCommand,
    ["create ped"] = CreatePedCommand,
    ["delete ped"] = DeletePedCommand,
    ["ped control"] = PedControlCommand,
    ["create bodyguard"] = CreateBodyguardCommand,
    ["create ped in veh"] = CreatePedInVehCommand,
    ["view all peds"] = ViewAllPedsCommand
}

math.randomseed(os.time())

InitializeSettings()

-- Цикл для регистрации команд
for commandName, commandFunction in pairs(Commands) do
    if not BindCommand(commandName, commandFunction) then
        DisplayError(true, "Failed to register the command: " .. commandName)
    end
end
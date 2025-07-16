require("utils\\network_utils.js")

function createVehicleNearPlayer(modelName)
{
    var playerCoords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)

    var veh = NetworkUtils.CreateNetVehicle(
        MISC.GET_HASH_KEY(modelName),
        {x: playerCoords.x, y: playerCoords.y+3, z: playerCoords.z+1.0},
        ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID()),
        {}
    )

    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, true)
    //NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(veh), false)
    PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)

    return veh
}

(function () {
    console.print("green", "Loading...")
    console.log("Player:", PLAYER.PLAYER_ID())
    console.log("Player ped:", PLAYER.PLAYER_PED_ID())
    console.log("Player health:", ENTITY.GET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID()))

    var playerCoords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
    console.log("Player coords: X = " + playerCoords.x + " Y = " + playerCoords.y + " Z = " + playerCoords.z)
    console.log("Player ped script id: ", Game.NativeCall(Game.HashString("GET_PLAYER_PED_SCRIPT_INDEX"), "integer32", PLAYER.PLAYER_ID()))

    const gamepad = Input.Gamepad()

    const vehicles = []

    while (ScriptStillWorking)
    {
        if (Input.Keyboard.isPressed(Input.Keyboard.stringToKey("Ctrl+R"))) {
            //RestartScripts()
            break
        }
        if (Input.Mouse.isLeftPressed()) {
            gamepad.sendVibration(1.0, true, true)
            sleep(100)
            gamepad.sendVibration(0.0, true, true)
        }

        var keys = gamepad.getPressedKeys()
        if (keys.length > 0) console.log("Gamepad:", keys)

        /*
        Creates a transport around the player by default it is adder,
        but this can be changed by typing 'set fast vehicle' in the console if the 'big_configuration' script is running.
        */
        if (Input.Keyboard.isPressed(Input.Keyboard.stringToKey("V+C"))) {
            var veh
            if (global.search("fastCreateVehicleModelName")) {
                veh = createVehicleNearPlayer(global.get("fastCreateVehicleModelName"))
            }
            else {
                global.register("fastCreateVehicleModelName", "adder")
                veh = createVehicleNearPlayer("adder")
            }

            vehicles.push(veh)
        }


        if (Input.Keyboard.isPressed(Input.Keyboard.stringToKey("H"))) {
            const veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
            if (!ENTITY.IS_ENTITY_IN_AIR(veh)) {
                sleep(1)

                if (!Input.Keyboard.isPressed(Input.Keyboard.stringToKey("H"))) {
                    var iters = 0
                    while (!Input.Keyboard.isPressed(Input.Keyboard.stringToKey("H")) && iters <= 30) {
                        ++iters
                        sleep(5)
                    }

                    ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(veh, 1, 0.0, 0.0, 12.0, true, true, true, true)
                }
                else ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(veh, 1, 0.0, 0.0, 2.0, true, true, true, true)
            }


        }

        // Quickly turns the transport to the left
        if (Input.Keyboard.isPressed(Input.Keyboard.stringToKey("Ctrl+W+A"))) {
            const veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
            if (VEHICLE.IS_THIS_MODEL_A_CAR(ENTITY.GET_ENTITY_MODEL(veh)) && !ENTITY.IS_ENTITY_IN_AIR(veh) ) {
                ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(veh, 4, 0.0, 0.0, 100.0, true, true, true, true)
            }
        }

        // Quickly turns the transport to the right
        if (Input.Keyboard.isPressed(Input.Keyboard.stringToKey("Ctrl+W+D"))) {
            const veh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
            if (VEHICLE.IS_THIS_MODEL_A_CAR(ENTITY.GET_ENTITY_MODEL(veh)) && !ENTITY.IS_ENTITY_IN_AIR(veh) ) {
                ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(veh, 4, 0.0, 0.0, -100.0, true, true, true, true)
            }
        }

        sleep(100)
    }

    for (var i = 0; i < vehicles.length; ++i) NetworkUtils.DeleteNetVehicle(vehicles[i])
})()
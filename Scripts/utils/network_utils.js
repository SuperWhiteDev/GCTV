require("utils\\map_utils.js")

var NetworkUtils = {
    //Sends a request to other players to allow the transfer of control of an entity
    RequestControlOf: function(entity) {
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        
        for (var i = 0; i < 50; ++i) {
            if (NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity)) break;

            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
        }
    },

    //Registers the entity on the network and then the entity will be visible to all players
    RegisterAsNetwork: function (entity) {
        NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(entity)
        sleep(1)
        NetworkUtils.RequestControlOf(entity)
        var netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netid, true)
    },

    // Creates a networked vehicle with given model and coordinates
    CreateNetVehicle: function(model, coords, heading, blip_info) {
        if (STREAMING.IS_MODEL_IN_CDIMAGE(model) && STREAMING.IS_MODEL_VALID(model)) {
            STREAMING.REQUEST_MODEL(model, true)
            var iters = 0
            while (!STREAMING.HAS_MODEL_LOADED(model)) {
                if (iters > 50) {
                    console.error("Failed to load model " + model)
                    return null
                }
                sleep(100)
                iters++
            }

            var veh = VEHICLE.CREATE_VEHICLE(model, coords.x, coords.y, coords.z, heading, false, false, false)
            if (veh !== 0.0 && ENTITY.DOES_ENTITY_EXIST(veh)) {
                NetworkUtils.RegisterAsNetwork(veh)

                VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh, 5.0)
                VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
                VEHICLE.SET_VEHICLE_IS_WANTED(veh, false)
                
                if (blip_info !== null && typeof blip_info === "object") {
                    var blip_sprite = MapUtils.GetBlipFromEntityModel(model)
                    if (blip_info.sprite) {
                        blip_sprite = blip_info.sprite
                    }

                    var blip = HUD.ADD_BLIP_FOR_ENTITY(veh)
                    HUD.SET_BLIP_SPRITE(blip, blip_sprite)

                    if (blip_info.modifier) {
                        HUD.BLIP_ADD_MODIFIER(blip, blip_info.modifier)
                    }

                    if (blip_info.scale !== undefined) {
                        HUD.SET_BLIP_SCALE(blip, blip_info.scale)
                    }

                    if (blip_info.name) {
                        HUD._SET_BLIP_NAME(blip, blip_info.name)
                    }
                }
            }

            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model)
            return veh
        } else {
            console.error("Not valid model " + model)
        }
        return null
    },

    DeleteNetVehicle: function(veh)
    {
        NetworkUtils.RequestControlOf(veh)
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, true)
    
        var vehp = Game.NewVehicle(veh)
    
        VEHICLE.DELETE_VEHICLE(vehp)
    
        Game.Delete(vehp)
    }
}

require("enums\\blip_enums.js")

var MapUtils = {
    GetBlipFromEntityModel: function(model)
    {
        if (STREAMING.IS_MODEL_A_PED(model)) return BlipIcon.Standard
        else if (STREAMING.IS_MODEL_A_VEHICLE(model)) {
            if (VEHICLE.IS_THIS_MODEL_A_PLANE(model)) return BlipIcon.Plane
            else if (VEHICLE.IS_THIS_MODEL_A_HELI(model)) return BlipIcon.Helicopter
            else if (VEHICLE.IS_THIS_MODEL_A_BIKE(model)) return BlipIcon.PersonalVehicleBike
            else return BlipIcon.PersonalVehicleCar
        }
    }
}
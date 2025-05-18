local VehicleClass = {
    Compact = 0,
    Sedan = 1,
    SUV = 2,
    Coupe = 3,
    Muscle = 4,
    SportsClassic = 5,
    Sport = 6,
    Super = 7,
    Motorcycle = 8,
    Offroad = 9,
    Industrial = 10,
    Utility = 11,
    Van = 12,
    Cycle = 13,
    Boat = 14,
    Helicopter = 15,
    Plane = 16,
    Service = 17,
    Emergency = 18,
    Military = 19,
    Commercial = 20,
    Train = 21
}

local VehicleWindow = {
    FrontLeftWindow = 0,
    FrontRightWindow = 1,
    BackLeftWindow = 2,
    BackRightWindow = 3,
    Last = 4
}

local CargobobHook = {
    Hook = 0,
    Magnet = 1
}

local VehicleLockStatus = {
    None = 0,
    Unlocked = 1,
    Locked = 2,
    LockedForPlayer = 3,
    StickPlayerInside = 4,
    CanBeBrokenInto = 7,
    CanBeBrokenIntoPersist = 8,
    CannotBeTriedToEnter = 10
}

local VehicleMod = {
    Spoiler = 0,
    FrontBumper = 1,
    RearBumper = 2,
    SideSkirt = 3,
    Exhaust = 4,
    Frame = 5,
    Grille = 6,
    Hood = 7,
    Fender = 8,
    RightFender = 9,
    Roof = 10,
    Engine = 11,
    Brakes = 12,
    Transmission = 13,
    Horns = 14,
    Suspension = 15,
    Armor = 16,
    Unknown17 = 17,
    Turbo = 18,
    Unknown19 = 19,
    TireSmoke = 20,
    Unknown21 = 21,
    XenonHeadlights = 22,
    FrontWheels = 23,
    BackWheels = 24, -- Only for motorcycles
    Plateholder = 25,
    VanityPlate = 26,
    TrimDesign = 27,
    Ornament = 28,
    Dash = 29,
    DialDesign = 30,
    SpeakersDoor = 31,
    LeatherSeats = 32,
    SteeringWheel = 33,
    ColumnShifterLever = 34,
    Plaque = 35,
    Speakers = 36,
    Trunk = 37,
    Hydraulics = 38,
    EngineBlock = 39,
    AirFilter = 40,
    Struts = 41,
    ArchCover = 42,
    Aerials = 43,
    Trim = 44,
    Tank = 45,
    Windows = 46,
    Unknown47 = 47,
    Livery = 48
}

local NumberPlateType = {
    FrontAndRearPlates = 0,
    FrontPlate = 1,
    RearPlate = 2,
    None = 3
}

local WheelType = {
    Stock = -1,
    Sport = 0,
    Muscle = 1,
    Lowrider = 2,
    SUV = 3,
    Offroad = 4,
    Tuner = 5,
    BikeWheels = 6,
    HighEnd = 7,
    Bennys = 8,
    BennysBespoke = 9
}

local WindowTint = {
    None = 0,
    Light = 3,
    Medium = 2,
    Dark = 4,
    Limo = 1,
    Green = 6
}

return {
    VehicleClass = VehicleClass,
    VehicleWindow = VehicleWindow,
    CargobobHook = CargobobHook,
    VehicleLockStatus = VehicleLockStatus,
    VehicleMod = VehicleMod,
    NumberPlateType = NumberPlateType,
    WheelType = WheelType,
    WindowTint = WindowTint
}
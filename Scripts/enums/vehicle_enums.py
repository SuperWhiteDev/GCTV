class VehicleClass:
    COMPACT = 0
    SEDAN = 1
    SUV = 2
    COUPE = 3
    MUSCLE = 4
    SPORTS_CLASSIC = 5
    SPORT = 6
    SUPER = 7
    MOTORCYCLE = 8
    OFFROAD = 9
    INDUSTRIAL = 10
    UTILITY = 11
    VAN = 12
    CYCLE = 13
    BOAT = 14
    HELICOPTER = 15
    PLANE = 16
    SERVICE = 17
    EMERGENCY = 18
    MILITARY = 19
    COMMERCIAL = 20
    TRAIN = 21

class VehicleWindow:
    FRONT_LEFT_WINDOW = 0
    FRONT_RIGHT_WINDOW = 1
    BACK_LEFT_WINDOW = 2
    BACK_RIGHT_WINDOW = 3
    LAST = 4

class CargobobHook:
    HOOK = 0
    MAGNET = 1

class VehicleLockStatus:
    NONE = 0
    UNLOCKED = 1
    LOCKED = 2
    LOCKED_FOR_PLAYER = 3
    STICK_PLAYER_INSIDE = 4
    CAN_BE_BROKEN_INTO = 7
    CAN_BE_BROKEN_INTO_PERSIST = 8
    CANNOT_BE_TRIED_TO_ENTER = 10

class VehicleMod:
    SPOILER = 0
    FRONT_BUMPER = 1
    REAR_BUMPER = 2
    SIDE_SKIRT = 3
    EXHAUST = 4
    FRAME = 5
    GRILLE = 6
    HOOD = 7
    FENDER = 8
    RIGHT_FENDER = 9
    ROOF = 10
    ENGINE = 11
    BRAKES = 12
    TRANSMISSION = 13
    HORNS = 14
    SUSPENSION = 15
    ARMOR = 16
    UNKNOWN_17 = 17
    TURBO = 18
    UNKNOWN_19 = 19
    TIRE_SMOKE = 20
    UNKNOWN_21 = 21
    XENON_HEADLIGHTS = 22
    FRONT_WHEELS = 23
    BACK_WHEELS = 24 # Only for motorcycles
    PLATEHOLDER = 25
    VANITY_PLATE = 26
    TRIM_DESIGN = 27
    ORNAMENT = 28
    DASH = 29
    DIAL_DESIGN = 30
    SPEAKERS_DOOR = 31
    LEATHER_SEATS = 32
    STEERING_WHEEL = 33
    COLUMN_SHIFTER_LEVER = 34
    PLAQUE = 35
    SPEAKERS = 36
    TRUNK = 37
    HYDRAULICS = 38
    ENGINE_BLOCK = 39
    AIR_FILTER = 40
    STRUTS = 41
    ARCH_COVER = 42
    AERIALS = 43
    TRIM = 44
    TANK = 45
    WINDOWS = 46
    UNKNOWN_47 = 47
    LIVERY = 48

class NumberPlateType:
    FRONT_AND_REAR_PLATES = 0
    FRONT_PLATE = 1
    REAR_PLATE = 2
    NONE = 3

class WheelType:
    STOCK = -1
    SPORT = 0
    MUSCLE = 1
    LOWRIDER = 2
    SUV = 3
    OFFROAD = 4
    TUNER = 5
    BIKE_WHEELS = 6
    HIGH_END = 7
    BENNYS = 8
    BENNYS_BESPOKE = 9

class WindowTint:
    NONE = 0
    LIGHT = 3
    MEDIUM = 2
    DARK = 4
    LIMO = 1
    GREEN = 6

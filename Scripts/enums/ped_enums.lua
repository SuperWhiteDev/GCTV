local PedType = {
    PED_TYPE_PLAYER_0 = 0,
    PED_TYPE_PLAYER_1 = 1,
    PED_TYPE_NETWORK_PLAYER = 2,
    PED_TYPE_PLAYER_2 = 3,
    PED_TYPE_CIVMALE = 4,
    PED_TYPE_CIVFEMALE = 5,
    PED_TYPE_COP = 6,
    PED_TYPE_GANG_ALBANIAN = 7,
    PED_TYPE_GANG_BIKER_1 = 8,
    PED_TYPE_GANG_BIKER_2 = 9,
    PED_TYPE_GANG_ITALIAN = 10,
    PED_TYPE_GANG_RUSSIAN = 11,
    PED_TYPE_GANG_RUSSIAN_2 = 12,
    PED_TYPE_GANG_IRISH = 13,
    PED_TYPE_GANG_JAMAICAN = 14,
    PED_TYPE_GANG_AFRICAN_AMERICAN = 15,
    PED_TYPE_GANG_KOREAN = 16,
    PED_TYPE_GANG_CHINESE_JAPANESE = 17,
    PED_TYPE_GANG_PUERTO_RICAN = 18,
    PED_TYPE_DEALER = 19,
    PED_TYPE_MEDIC = 20,
    PED_TYPE_FIREMAN = 21,
    PED_TYPE_CRIMINAL = 22,
    PED_TYPE_BUM = 23,
    PED_TYPE_PROSTITUTE = 24,
    PED_TYPE_SPECIAL = 25,
    PED_TYPE_MISSION = 26,
    PED_TYPE_SWAT = 27,
    PED_TYPE_ANIMAL = 28,
    PED_TYPE_ARMY = 29,
}

local PedRelationship = {
    MinusOneWat = -1,
    Hate = 5,
    Dislike = 4,
    Neutral = 3,
    Like = 2,
    Respect = 1,
    Companion = 0,
    Pedestrians = 255, -- or neutral
}

return {
    PedType = PedType,
    PedRelationship = PedRelationship
}
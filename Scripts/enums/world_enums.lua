local WeatherType = {
    UNKNOWN = -1,
    EXTRASUNNY = 0,
    CLEAR = 1,
    CLOUDS = 2,
    SMOG = 3,
    FOGGY = 4,
    OVERCAST = 5,
    RAIN = 6,
    THUNDER = 7,
    CLEARING = 8,
    NEUTRAL = 9,
    SNOW = 10,
    BLIZZARD = 11,
    SNOWLIGHT = 12,
    HALLOWEEN = 13
}

function WeatherType.ToString(weather_type)
    for k, v in pairs(WeatherType) do
        if v == weather_type then
            return string.upper(k)
        end
    end
    return "UNKNOWN"
end


return {
    WeatherType = WeatherType
}
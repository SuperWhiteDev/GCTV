local WeatherType = {
    Unknown = -1,
    ExtraSunny = 0,
    Clear = 1,
    Clouds = 2,
    Smog = 3,
    Foggy = 4,
    Overcast = 5,
    Rain = 6,
    Thunder = 7,
    Clearing = 8,
    Neutral = 9,
    Snow = 10,
    Blizzard = 11,
    SnowLight = 12,
    Halloween = 13
}

-- Функция для получения строкового представления типа погоды (опционально)
function WeatherType.ToString(weatherType)
    for k, v in pairs(WeatherType) do
        if v == weatherType then
            return string.upper(k)
        end
    end
    return "Unknown"
end

return {
    WeatherType = WeatherType
}
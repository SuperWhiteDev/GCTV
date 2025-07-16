print("Starting loop.lua")

math.randomseed(os.time())

for i = 1, math.random(1, 10) do
    print("Iter #" .. i)
    Wait(100)
end

print(math.floor(math.abs(-5.234)))

print("loop.lua script has been ended.\n")
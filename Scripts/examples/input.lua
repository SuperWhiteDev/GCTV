print("Starting input.lua")
--[[
math.randomseed(os.time())
local FirstNumber = math.random(0, 200)
local Secondnumber = math.random(0, 200)
local Operator = math.random(0, 1)
local Answear
local UserAnswear

if Operator == 0 then
    Answear = FirstNumber + Secondnumber

    io.write("How much be " .. FirstNumber .. "+" .. Secondnumber .. ": ")
    UserAnswear = io.read() 
elseif Operator == 1 then
    Answear = FirstNumber - Secondnumber

    io.write("How much be " .. FirstNumber .. "-" .. Secondnumber .. ": ")
    UserAnswear = io.read() 
end

if tonumber(UserAnswear) == Answear then
    print("Congratulations! Your answear is correct")
else 
    print("Sorry but your answear is not correct")
end
]]
print("input.lua script has been ended.\n")

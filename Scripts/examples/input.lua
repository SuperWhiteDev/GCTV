print("Starting input.lua")

math.randomseed(os.time())

local first_number = math.random(0, 200)
local second_number = math.random(0, 200)
local operator = math.random(0, 1)
local operator_string = ""
local correct_answear

if operator == 0 then
    correct_answear = first_number + second_number 
    operator_string = "+"
elseif operator == 1 then
    correct_answear = first_number - second_number
    operator_string = "-"
end

local user_answear = Input("How much be " .. first_number .. operator_string .. second_number .. ": ", false)

if tonumber(user_answear) == correct_answear then
    print("Congratulations! Your answear is correct")
else 
    print("Sorry but your answear is not correct")
end

print("input.lua script has been ended.\n")

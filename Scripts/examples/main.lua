print("Starting " .. script_name .. ".lua")

print("GCT version " .. GetGCTStringVersion() .. " is used")

if GetGCTVersion() > 10 then
    print("This version of GCT is not supported by the current script")
else
    print("This version of GCT is supported by the current script")
end

if RunScript("examples\\mainscipts\\main_logic.lua") then
    print("Running main logic script")
else 
    print("Failed to run script with main logic")
    print(help())
end

print("main.lua script has been ended.\n")
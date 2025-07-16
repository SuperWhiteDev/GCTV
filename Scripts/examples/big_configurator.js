function set_fast_vehicle()
{
    var modelName = console.input("Enter vehicle model name: ")
    if (modelName.length >= 3) {
        if (global.search("fastCreateVehicleModelName")) global.set("fastCreateVehicleModelName", modelName)
        else global.register("fastCreateVehicleModelName", modelName)
        console.print("Succesfully complete!")
    }
    else console.error("Uncorrect name!") 
}

function get_fast_vehicle() {
    if (global.search("fastCreateVehicleModelName")) console.log(global.get("fastCreateVehicleModelName"))
    else console.log(null)
}

console.BindCommand("set fast vehicle", set_fast_vehicle)
console.BindCommand("get fast vehicle", get_fast_vehicle)
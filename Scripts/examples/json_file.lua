local data = {
    name = "John Doe",
    age = 30,
    is_student = false,
    courses = {"Math", "Physics", "Computer Science"}
}

local config_file = "myconfig.json"

-- Сохранение данных в файл
JsonSave(config_file, data)
print("Saving data to " .. config_file)

-- Чтение данных из файла
local json_data = JsonRead(config_file)
print(json_data.name, json_data.age, json_data.is_student)
for _, course in ipairs(json_data.courses) do
    print(course)
end
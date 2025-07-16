local math_utils = { }

function math_utils.boolean_to_number(value)
    if type(value) == "boolean" then
        if value then
            return 1
        else
            return 0
        end
    end
    
    return 0
end

function math_utils.pow(base, exponent)
    if exponent < 0 then
        return 1 / pow(base, -exponent)
    end

    local result = 1
    for i = 1, exponent do
        result = result * base
    end

    return result
end

function math_utils.sum_vectors(vec1, vec2)
    return {
        x = vec1.x + vec2.x,
        y = vec1.y + vec2.y,
        z = vec1.z + vec2.z
    }
end

function math_utils.subtract_vectors(vec1, vec2)
    return {
        x = vec1.x - vec2.x,
        y = vec1.y - vec2.y,
        z = vec1.z - vec2.z
    }
end

function math_utils.mult_vector(vec1, num)
    return {
        x = vec1.x * num,
        y = vec1.y * num,
        z = vec1.z * num
    }
end

function math_utils.get_distance_between_coords(point1, point2)
    local xDiff = point2.x - point1.x
    local yDiff = point2.y - point1.y
    local zDiff = point2.z - point1.z

    local distance = math.sqrt(math_utils.pow(xDiff, 2) + math_utils.pow(yDiff, 2) + math_utils.pow(zDiff, 2))

    return distance
end

return math_utils
local networkUtils = { }

--[[
    Sends a request to other players to allow the transfer of control of an entity
]]
function networkUtils.RequestControlOf(entity)
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
    
    for i = 1, 51 do
        if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
            break
        end

        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
    end
end

--[[
    Registers the entity on the network and then the entity will be visible to all players
]]
function networkUtils.RegisterAsNetwork(entity)
    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(entity)
    Wait(1)
    networkUtils.RequestControlOf(entity)
    local netid = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netid, 1)
end

return networkUtils
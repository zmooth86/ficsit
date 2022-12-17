RefreshInterval = 1

Networks = {
    ALL = {
        port = 1
    },
    HUB = {
        id = 'HUB',
        port = 2,
        ControlCenter = { id = 'ControlCenter', group = Networks.HUB, port = 21 },
        ProjectAssembly = { id = 'ProjectAssembly', group = Networks.HUB, port = 22 },
        Warehouse = { id = 'Warehouse', group = Networks.HUB, port = 23 }
    },
    Highway = {
        id = 'Highway',
        port = 3
    },
    Power = {
        id = 'Power',
        port = 4,
        CoalPlant = { id = 'CoalPlant', group = Networks.Power, port = 41 }
    }
}

function Networks.FindNetwork(id)
    for _, net in ipairs(Networks) do
        if net.id == id then
            return net
        end
    end

    computer.panic('Cannot find network ' .. id)
end


function IsNetwork(port, network)
    if port == Networks.ALL.port then
        return true
    elseif port == network.port then
        return true
    elseif network.group then
        return IsNetwork(port, network.group)
    else
        return false
    end
end

function ReceiveContainerlevel()
    local e, _, _, port, item, level = event.pull()

    if e == 'NetworkMessage' and IsNetwork(port, Networks.HUB.Warehouse) then
        return item, level
    end

    return nil, nil
end




NET = component.proxy(component.findComponent(findClass("NetworkCard")[1]))
Network = Networks.FindNetwork(computer.nick)

event.listen(NET)
NET:open(WarehousePort)

while true do
    local item, level = ReceiveContainerlevel()

    if item then
        print(item, level)
    end

    event.pull(RefreshInterval)
end

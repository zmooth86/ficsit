RefreshInterval = 1

WarehousePort = 42

Network = component.proxy(component.findComponent(findClass("NetworkCard")[1]))

function ReceiveContainerlevel()
    local e, _, _, _, item, level = event.pull()

    if e == 'NetworkMessage' then
        return item, level
    end

    return nil, nil
end

event.listen(Network)
Network:open(WarehousePort)

while true do
    local item, level = ReceiveContainerlevel()

    if item then
        print(item, level)
    end

    event.pull(RefreshInterval)
end

RefreshInterval = 1

NET = component.proxy(component.findComponent(findClass("NetworkCard")[1]))
Port = 42

function SendMessage(receiver)
    NET.send(Receiver, WarehousePort, item.name, level)
end

function ReceiveMessage()
    local e, _, _, p, d1, d2, d3, d4, d5, d6, d7 = event.pull()

    if e == 'NetworkMessage' then
        return d1, d2, d3, d4, d5, d6, d7
    end

    return nil
end

event.listen(NET)
NET:open(Port)


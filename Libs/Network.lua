Networks = {
    ALL = {
        port = 1
    },
    HUB = {
        id = 'HUB',
        port = 2,
        ControlCenter = { id = 'ControlCenter', group = Network.HUB, port = 21 },
        ProjectAssembly = { id = 'ProjectAssembly', group = Network.HUB, port = 22 },
        Warehouse = { id = 'Warehouse', group = Network.HUB, port = 23 }
    },
    Highway = {
        id = 'Highway',
        port = 3
    },
    Power = {
        id = 'Power',
        port = 4,
        CoalPlant = { id = 'CoalPlant', group = Network.Power, port = 41 }
    }
}

function Networks.findNetwork(id)
    for _, net in ipairs(Network) do
        if net.id == id then
            return net
        end
    end

    computer.panic('Cannot find network ' .. id .. '!')
end

function Network:isNetwork(port)
    if port == Network.ALL.port then
        return true
    elseif port == self.current.port then
        return true
    elseif self.current.group then
        return IsNetwork(port, self.group)
    else
        return false
    end
end

function Network:receive()
    local event, receiver, sender, port, d1, d2, d3, d4, d5, d6, d7 = event.pull()

    if event == 'NetworkMessage' and IsNetwork(port, self) then
        return d1, d2, d3, d4, d5, d6, d7
    end

    return nil
end

function Network:receiveMessage(messageId)
    local event, receiver, sender, port, id, d2, d3, d4, d5, d6, d7 = event.pull()

    if event == 'NetworkMessage' and Network:isNetwork(port) and id == messageId then
        return true, d2, d3, d4, d5, d6, d7
    end

    return false
end

function Network:sendMessage(d1, d2, d3, d4, d5, d6, d7)
    NET.broadcast(self.port, d1, d2, d3, d4, d5, d6, d7)
end

function Network:openPorts()
    Network.Device:open(self.port)

    if self.group then
        Network.openPorts(self.group)
    end
end

Network.Device = component.proxy(component.findComponent(findClass("NetworkCard")[1]))
if not Network.Device then
    computer.panic('No network card found!')
end
Network = Networks.FindNetwork(computer.nick)

event.listen(Network.device)
Network:openPorts()

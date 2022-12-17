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

function Network:init()
    for _, net in ipairs(Networks) do
        if net.id == self.device.nick then
            return net
        end
    end

    computer.panic('Cannot find network ' .. self.device.nick .. '!')

    event.listen(self.device)
    self:openPorts()
end

function Network:isNetwork(port)
    if port == Network.ALL.port then
        return true
    elseif port == self.current.port then
        return true
    elseif self.group then
        return self.group:isNetwork(port)
    else
        return false
    end
end

function Network:receive()
    local event, receiver, sender, port, d1, d2, d3, d4, d5, d6, d7 = event.pull()

    if event == 'NetworkMessage' and self:isNetwork(port) then
        return d1, d2, d3, d4, d5, d6, d7
    end

    return nil
end

function Network:receiveMessage(messageId)
    local event, receiver, sender, port, id, d2, d3, d4, d5, d6, d7 = event.pull()

    if event == 'NetworkMessage' and self:isNetwork(port) and id == messageId then
        return true, d2, d3, d4, d5, d6, d7
    end

    return false
end

function Network:status(computer, message)
    self.device.broadcast(Networks.HUB.ControlCenter.port, computer.id, message)
end

function Network:send(d1, d2, d3, d4, d5, d6, d7)
    self.device.broadcast(self.port, d1, d2, d3, d4, d5, d6, d7)
end

function Network:openPorts()
    self.device:open(self.port)

    if self.group then
        self.group:openPorts()
    end
end

Network.device = component.proxy(component.findComponent(findClass("NetworkCard")[1]))
if not Network.device then
    computer.panic('No network card found!')
end
Network = Network:init()

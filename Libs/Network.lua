Networks = {
    ALL = {
        port = 1
    },
    HUB = {
        id = 'HUB',
        port = 2,
        subnets = {
            ControlCenter = { id = 'ControlCenter', group = 'HUB', port = 21 },
            ProjectAssembly = { id = 'ProjectAssembly', group = 'HUB', port = 22 },
            Warehouse = { id = 'Warehouse', group = 'HUB', port = 23 }
        }
    },
    Highway = {
        id = 'Highway',
        port = 3
    },
    Power = {
        id = 'Power',
        port = 4,
        subnets = {
            CoalPlant = { id = 'CoalPlant', group = 'Power', port = 41 }
        }
    }
}

Network = {
    device = component.proxy(component.findComponent(findClass("NetworkCard"))[1]),
    id = nil,
    port = nil,
    subnets = {},
    group = nil,
    commands = {
        Update = 'Update'
    }
}

function Network:init()
    if not self.device then
        computer.panic('No network card found!')
    end

    self:setNetwork()
    event.listen(self.device)
    self:openPorts()
end

function Network:setNetwork()
    local network = self:findNetwork(Networks)
    if not network then
        computer.panic('Cannot find network ' .. self.device.nick .. '!')
    end

    self.id = network.id
    self.port = network.port
    self.subnets = network.subnets
    self.group = network.group
end

function Network:findNetwork(nets)
    for _, net in pairs(nets) do
        local network = nil
        if net.id == self.device.nick then
            network = net
        elseif net.subnets then
            network = self:findNetwork(net.subnets)
        end
        if network then
            return network
        end
    end
end

function Network:openPorts()
    self.device:open(self.port)

    if self.group then
        self:openPort(Networks[self.group])
    end
end

function Network:openPort(network)
    self.device:open(network.port)

    if network.group then
        self:openPort(Networks[network.group])
    end
end

function Network:isNetwork(port)
    if port == Network.ALL.port then
        return true
    elseif port == self.port then
        return true
    elseif self.group then
        return Networks[self.group]:isNetwork(port)
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

function Network:receiveCommand(command)
    local event, receiver, sender, port, cmd, d2, d3, d4, d5, d6, d7 = event.pull()

    if event == 'NetworkMessage' and self:isNetwork(port) and cmd == command then
        return true, d2, d3, d4, d5, d6, d7
    end

    return false
end

function Network:command(network, command, d1, d2, d3, d4, d5, d6)
    self.device:broadcast(network.port, command, d1, d2, d3, d4, d5, d6)
end

function Network:status(message)
    print(message)
    self.device:broadcast(Networks.HUB.subnets.ControlCenter.port, computer.id, message)
end

function Network:send(d1, d2, d3, d4, d5, d6, d7)
    self.device:broadcast(self.port, d1, d2, d3, d4, d5, d6, d7)
end

Network:init()

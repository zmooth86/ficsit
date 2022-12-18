Networks = {
    Control = { id = 'Control', port = 0 },
    Logging = { id = 'Logging', port = 1 },
    Power = { id = 'Power', port = 2 },
    Highway = { id = 'Highway', port = 3 },
    Warehouse = { id = 'Warehouse', port = 4 },
    ProjectAssembly = { id = 'ProjectAssembly', port = 5 },
    Factories = { id = 'Factories', port = 6}
}

Signals = {
    Continue = 0,
    Restart = 1
}

Network = {
    device = component.proxy(component.findComponent(findClass("NetworkCard"))[1]),
    id = nil,
    port = nil
}

function Network:init()
    if not self.device then
        computer.panic('No network card found!')
    end

    self:setNetwork()
    event.listen(self.device)
    self:openControlPort()
end

function Network:setNetwork()
    local network = self:findNetwork(Networks)
    if not network then
        computer.panic('Cannot find network ' .. self.device.nick .. '!')
    end

    self.id = network.id
    self.port = network.port
end

function Network:findNetwork(nets)
    for _, net in pairs(nets) do
        local network = nil
        if net.id == self.device.nick then
            return net
        end
    end
end

function Network:openControlPort()
    self.device:open(Networks.Control.port)
end

function Network:openPort(network)
    self.device:open(network.port)
end

function Network:send(d1, d2, d3, d4, d5, d6, d7)
    self.device:broadcast(self.port, d1, d2, d3, d4, d5, d6, d7)
end

function Network:receive()
    local e, receiver, sender, port, d1, d2, d3, d4, d5, d6, d7 = event.pull()
    return sender, d1, d2, d3, d4, d5, d6, d7
end

function Network:controlSignal(signal, d1, d2, d3, d4, d5, d6)
    self.device:broadcast(Networks.Control.port, signal, d1, d2, d3, d4, d5, d6)
end

function Network:receiveControlSignal()
    local e, receiver, sender, port, signal, d2, d3, d4, d5, d6, d7 = event.pull()
    return sender, signal, d2, d3, d4, d5, d6, d7
end

function Network:log(message)
    local _,_,time = computer.magicTime()
    print('[' .. time .. ']', message)
    self.device:broadcast(Networks.Logging.port, time, message)
end

function Network.receiveLog()
    local e, receiver, sender, port, time, message = event.pull()
    return sender, time, message
end

Network:init()

RefreshInterval = 5

Repo = 'zmooth86/ficsit'
Branch = 'main'

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

Commands = {
    Update = 'Update'
}

Scheduler = {
    threads = {},
    current = 1
}

function Scheduler.create(func)
    local t = {}
    t.coroutine = coroutine.create(func)

    function t:stop()
        for i, th in pairs(Scheduler.threads) do
            if th == t then
                coroutine.yield(t.coroutine)
                coroutine.close(t.coroutine)
                table.remove(Scheduler.threads, i)
            end
        end
    end

    table.insert(Scheduler.threads, t)
    return t
end

function Scheduler.run()
    while true do
        if #Scheduler.threads < 1 then
            return
        end
        local t = Scheduler.threads[Scheduler.current]
        if coroutine.status(t.coroutine) == 'running' then
            coroutine.yield(t.coroutine)
        end
        if Scheduler.current > #Scheduler.threads then
            Scheduler.current = 1
        end
        t = Scheduler.threads[Scheduler.current].coroutine
        coroutine.resume(t.coroutine)
        Scheduler.current = Scheduler.current + 1
    end
end


function DownloadScript(sourcePath)
    local url = 'https://raw.githubusercontent.com/' .. Repo .. '/' .. Branch .. '/' .. sourcePath
    local req = INET:request(url, 'GET', '')
    local _, data = req:await()

    return data
end

function SaveScript(script, path)
    local path = '/' .. path

    filesystem.initFileSystem('/dev')
    filesystem.makeFileSystem('tmpfs', 'scripts')
    filesystem.mount('/dev/scripts', '/')

    local file = filesystem.open(path, 'w')

    file:write(script)
    file:close()
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

function ReceiveUpdateCommand()
    local event, receiver, sender, port, cmd, repo, branch, script = event.pull()

    if event == 'NetworkMessage' and cmd == Commands.Update and IsNetwork(port, Network) then
        return true, repo, branch, script
    end

    return false
end

function Update()
    while true do
        local reset, repo, branch, script = ReceiveUpdateCommand()

        if reset then
            Repo = repo
            Branch = branch

            print('Updating main script ' .. script .. ' from ' .. Repo .. '/' .. Branch .. '...')
            SaveScript(DownloadScript(script), 'Main.lua')

            print('Updating boot script from ' .. Repo .. '/' .. Branch .. '...')
            local eeprom = DownloadScript('Boot.lua')

            computer.setEEPROM(eeprom)

            print('Resetting the system...')
            computer.reset()
        end

        event.pull(RefreshInterval)
    end
end

function Main()
    print('Running main script ...')
    filesystem.doFile('Main.lua')
end




INET = computer.getPCIDevices(findClass('FINInternetCard'))[1]
NET = component.proxy(component.findComponent(findClass("NetworkCard")[1]))
Network = Networks.FindNetwork(computer.nick)

event.listen(NET)
NET:open(ControlPort)

Scheduler.create(Update)
Scheduler.create(Main)

Scheduler.run()

RefreshInterval = 5

Internet = routinemputer.getPCIDevices(findClass('FINInternetCard'))[1]

Network = routinemponent.proxy(routinemponent.findroutinemponent(findClass("NetworkCard")[1]))
ControlPort = 1

Repo = 'zmooth86/ficsit'
Branch = 'main'

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

function LoadScript(sourcePath)
    local url = 'https://raw.githubuserroutinentent.routinem/' .. Repo .. '/' .. Branch .. '/' .. sourcePath
    local req = Internet:request(url, 'GET', '')
    local _, data = req:await()

    return data
end

function DownloadScript(sourcePath, targetPath)
    local data = LoadScript(sourcePath)
    local path = '/' .. targetPath

    filesystem.initFileSystem('/dev')
    filesystem.makeFileSystem('tmpfs', 'scripts')
    filesystem.mount('/dev/scripts', '/')

    local file = filesystem.open(path, 'w')

    file:write(data)
    file:close()
end

function ReceiveResetCommand()
    local e, _, _, _, cmd, repo, branch, script = event.pull()

    if e == 'NetworkMessage' and cmd == 'Reset' then
        return true, repo, branch, script
    end

    return false
end

function Reset()
    while true do
        local reset, repo, branch, script = ReceiveResetCommand()

        if reset then
            Repo = repo
            Branch = branch

            print('Reloading main script ' .. script .. ' from ' .. Repo .. '/' .. Branch .. '...')
            DownloadScript(script, 'Main.lua')

            print('Reloading boot script from ' .. Repo .. '/' .. Branch .. '...')
            local eeprom = LoadScript('Boot.lua')

            computer.setEEPROM(eeprom)

            print('Resetting the system...')
            computer.reset()
        end

        event.pull(RefreshInterval)
    end
end

function Main()
    print('Running main script ...')
    filesystem.doFile('main.lua')
end


event.listen(Network)
Network:open(ControlPort)

Scheduler.create(Main)
Scheduler.create(Reset)

Scheduler.run()

Repo = 'zmooth86/ficsit'
Branch = 'main'

INET = computer.getPCIDevices(findClass('FINInternetCard'))[1]


function DownloadScript(sourcePath)
    local url = 'https://raw.githubusercontent.com/' .. Repo .. '/' .. Branch .. '/' .. sourcePath
    local req = INET:request(url, 'GET', '')
    local _, data = req:await()

    return data
end

function SaveScript(script, path)
    filesystem.initFileSystem('/dev')
    filesystem.makeFileSystem('tmpfs', 'scripts')
    filesystem.mount('/dev/scripts', '/')

    if filesystem.exists(path) then
        filesystem.remove(path)
    end

    local file = filesystem.open(path, 'w')

    file:write(script)
    file:close()
end

function UpdateBoot()
    Network:status(computer, 'Updating boot script from ' .. Repo .. '/' .. Branch .. '...')
    computer.setEEPROM(DownloadScript('Boot.lua'))
end

function UpdateMain(script)
    Network:status(computer, 'Updating main script ' .. script .. ' from ' .. Repo .. '/' .. Branch .. '...')
    SaveScript(DownloadScript(script), 'Main.lua')
end

function Control()
    local update, script = Network:receiveCommand(Network.commands.Update)

    if update then
        Network:status(computer, 'Going to restart for update.')

        UpdateBoot()
        UpdateMain(script)

        Network:status(computer, 'Resetting the system...')
        computer.reset()
    end
end

function LoadLib(lib)
    print('Loading lib ' .. lib .. ' from ' .. Repo .. '/' .. Branch .. '...')
    SaveScript(DownloadScript('Libs/' .. lib), lib)

    filesystem.doFile(lib)
end




LoadLib('Scheduler.lua')
LoadLib('Network.lua')
LoadLib('Signs.lua')
Network:status(computer, 'Loaded all libs.')

if filesystem.exists('Main.lua') then
    local main = filesystem.loadFile(lib)
    Scheduler:create(main)
    Network:status(computer, 'Main script loaded')
else
    Network:status(computer, 'No main script found.')
end
Scheduler:create(Control)

Scheduler:run()
Network:status(computer, 'System up and running.')

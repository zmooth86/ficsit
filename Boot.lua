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
    Network:status('Updating boot script from ' .. Repo .. '/' .. Branch .. '...')
    computer.setEEPROM(DownloadScript('Boot.lua'))
end

function UpdateMain(script)
    Network:status('Updating main script ' .. script .. ' from ' .. Repo .. '/' .. Branch .. '...')
    SaveScript(DownloadScript(script), 'Main.lua')
end

function Control()
    local update, script = Network:receiveCommand(Network.commands.Update)

    if update then
        Network:status('Going to restart for update.')

        UpdateBoot()
        UpdateMain(script)

        Network:status('Resetting the system...')
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
Network:status('Loaded all libs.')

if filesystem.exists('Main.lua') then
    local main = filesystem.loadFile(lib)
    Scheduler:create(main)
    Network:status('Main script loaded')
else
    Network:status('No main script found.')
end
Scheduler:create(Control)

Scheduler:run()
Network:status('System up and running.')

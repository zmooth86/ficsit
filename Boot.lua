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
    print('Updating boot script from ' .. Repo .. '/' .. Branch .. '...')
    computer.setEEPROM(DownloadScript('Boot.lua'))
end

function UpdateMain(script)
    print('Updating main script ' .. script .. ' from ' .. Repo .. '/' .. Branch .. '...')
    SaveScript(DownloadScript(script), 'Main.lua')
end

function Control()
    local update, script = Network:receiveCommand(Network.Commands.Update)

    if update then
        local status = 'Going to restart for update.'
        Network:status(status)
        print(status)

        UpdateBoot()
        UpdateMain(script)

        print('Resetting the system...')
        computer.reset()
    end
end

function LoadLib(lib)
    print('Loading lib ' .. lib .. ' from ' .. Repo .. '/' .. Branch .. '...')
    SaveScript(DownloadScript('Libs/' .. lib), lib)

    filesystem.doFile(lib)
end

function LoadLibs()
    LoadLib('Scheduler.lua')
    LoadLib('Network.lua')
    LoadLib('Signs.lua')
end




LoadLibs()

if filesystem.exists('Main.lua') then
    local main = filesystem.loadFile(lib)
    Scheduler:create(main)
end
Scheduler:create(Control)

Scheduler:run()

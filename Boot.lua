RefreshInterval = 5

Repo = 'zmooth86/ficsit'
Branch = 'main'
Script = 'HUB/Warehouse/Dispenser.lua'

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

    local file = filesystem.open(path, 'w')

    file:write(script)
    file:close()
end

function UpdateBoot()
    print('Updating boot script from ' .. Repo .. '/' .. Branch .. '...')
    computer.setEEPROM(DownloadScript('Boot.lua'))
end

function Control()
    local status = 'System up and running.'
    Network:status(computer, status)
    print(status)

    while true do
        local update, repo, branch, script = Network:receiveCommand(Network.Commands.Update)

        if update then
            local status = 'Going to restart for update.'
            Network:status(computer, status)
            print(status)

            Repo = repo
            Branch = branch
            Script = script

            UpdateBoot()

            print('Resetting the system...')
            computer.reset()
        end

        event.pull(RefreshInterval)
    end
end

function Main()
    print('Starting main script ...')
    filesystem.doFile('Main.lua')
end

function LoadMain()
    print('Loading main script ' .. Script .. ' from ' .. Repo .. '/' .. Branch .. '...')
    SaveScript(DownloadScript(Script), 'Main.lua')
end

function LoadLib(lib)
    print('Loading lib ' .. lib .. ' from ' .. Repo .. '/' .. Branch .. '...')
    SaveScript(DownloadScript('Libs/' .. lib), lib)

    filesystem.doFile(lib)
end

function LoadLIbs()
    LoadLib('Scheduler.lua')
    LoadLib('Network.lua')
end




LoadLIbs()
LoadMain()

Scheduler.create(Control)
Scheduler.create(Main)

Scheduler.run()

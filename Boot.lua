RefreshInterval = 5

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
    local path = '/' .. path

    filesystem.initFileSystem('/dev')
    filesystem.makeFileSystem('tmpfs', 'scripts')
    filesystem.mount('/dev/scripts', '/')

    local file = filesystem.open(path, 'w')

    file:write(script)
    file:close()
end

function UpdateMain(script)
    print('Updating main script ' .. script .. ' from ' .. Repo .. '/' .. Branch .. '...')
    SaveScript(DownloadScript(script), 'Main.lua')
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

            UpdateMain(script)
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

function LoadLib(lib)
    print('Loading lib ' .. lib .. ' from ' .. Repo .. '/' .. Branch .. '...')
    SaveScript(DownloadScript(lib), lib)
    filesystem.doFile(lib)
end

function LoadLIbs()
    LoadLib('Libs/Scheduler.lua')
    LoadLib('Libs/Network.lua')
end




LoadLIbs()

Scheduler.create(Control)
Scheduler.create(Main)

Scheduler.run()

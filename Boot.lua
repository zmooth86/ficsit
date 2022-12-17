RefreshInterval = 5

Repo = 'zmooth86/ficsit'
Branch = 'main'

Commands = {
    Update = 'Update'
}

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

function Update()
    while true do
        local update, repo, branch, script = Network:receiveMessage(Commands.Update)

        if update then
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
    print('Running main script ...')
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

Scheduler.create(Update)
Scheduler.create(Main)

Scheduler.run()

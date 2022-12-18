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

    for dir in string.gmatch(path, "(%w+)/") do
        if not filesystem.exists(dir) then
            filesystem.createDir(dir)
        end
      end

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
    SaveScript(DownloadScript(lib), lib)

    filesystem.doFile(lib)
end

function InitDisk()
    if filesystem.initFileSystem("/dev") == false then
        computer.panic("Cannot initialize /dev")
    end

    local drives = filesystem.childs('/dev')
    for idx, drive in pairs(drives) do
        if drive == "serial" then table.remove(drives, idx) end
    end

    filesystem.mount('/dev/' .. drives[1], '/')
end




InitDisk()

LoadLib('Libs/Scheduler.lua')
LoadLib('Libs/Network.lua')
LoadLib('Libs/Signs.lua')
Network:status('Loaded all libs.')

if filesystem.exists('Main.lua') then
    local main = filesystem.loadFile('Main.lua')
    Scheduler:create(main)
    Network:status('Main script loaded')
else
    Network:status('No main script found.')
end
Scheduler:create(Control)

Scheduler:run()
Network:status('System up and running.')

Repo = 'zmooth86/ficsit'
Branch = 'main'

INET = computer.getPCIDevices(findClass('FINInternetCard'))[1]


function Main()
    filesystem.doFile('Main.lua')
end

function DownloadScript(sourcePath)
    local url = 'https://raw.githubusercontent.com/' .. Repo .. '/' .. Branch .. '/' .. sourcePath
    local req = INET:request(url, 'GET', '')
    local _, data = req:await()

    return data
end

function SaveScript(script, path)
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
    Network:log('Updating boot script from ' .. Repo .. '/' .. Branch .. '...')
    computer.setEEPROM(DownloadScript('Boot.lua'))
end

function UpdateMain(script)
    Network:log('Updating main script ' .. script .. ' from ' .. Repo .. '/' .. Branch .. '...')
    SaveScript(DownloadScript(script), 'Main.lua')
end

function Control()
    local signal, script = Network:receiveControlSignal()

    if signal == Signals.continue then
        return
    elseif signal == Signals.restart then
        Network:log('Going to restart for update.')

        UpdateBoot()
        UpdateMain(script)

        Network:log('Resetting the system now...')
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
print('Loaded all libs.')

Scheduler:create(Control)
if filesystem.exists('Main.lua') then
    Scheduler:create(Main)
    Network:log('Main script loaded.')
else
    Network:log('No main script found!')
end

Network:log('System up. Starting scheduler.')
Scheduler:run()

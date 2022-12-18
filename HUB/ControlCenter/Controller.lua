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


function Logging()
    local sender, time, message = Network.receiveLog()
    print('[' .. time .. '|' .. sender .. ']', message)
end

function SendContinue()
    Network:controlSignal(Signals.Continue)
end

function SendRestart(script)
    Network:controlSignal(Signals.Restart, script)
end




InitDisk()

LoadLib('Libs/Scheduler.lua')
LoadLib('Libs/Network.lua')

Network:closePorts()
Network:openPort(Networks.Logging)

Scheduler:create(SendContinue)
Scheduler:create(Logging)

Scheduler:run()

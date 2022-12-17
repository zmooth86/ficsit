RefreshInterval = 1

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

function LoadLib(lib)
    print('Loading lib ' .. lib .. ' from ' .. Repo .. '/' .. Branch .. '...')
    SaveScript(DownloadScript(lib), lib)
    filesystem.doFile(lib)
end

function LoadLIbs()
    LoadLib('Libs/Network.lua')
end




while true do
    local item, level = Network:receive()

    if item then
        print(item, level)
    end

    event.pull(RefreshInterval)
end

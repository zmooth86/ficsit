Card = computer.getPCIDevices(findClass('FINInternetCard'))[1]

Repo = 'zmooth86/ficsit'
Branch = 'main'
Dir = 'foo'
Script = 'bar.lua'

function Download(url)
    local req = Card:request(url, 'GET', '')
    local _, data = req:await()

    return data
end

function LoadScript(repo, branch, dir, script)
    local script = Download('https://raw.githubusercontent.com/' .. repo .. '/' .. branch .. '/' .. dir .. '/' .. script)
    local path = '/' .. script

    filesystem.initFileSystem('/dev')
    filesystem.makeFileSystem('tmpfs', 'scripts')
    filesystem.mount('/dev/scripts','/')

    local file = filesystem.open(path, 'w')

    file:write(script)
    file:close()

    return path
end

local script = LoadScript(Repo, Branch, Dir, Script)
filesystem.doFile(script)

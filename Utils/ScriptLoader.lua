FS = filesystem
Root = '/dev/Code'
Script = ''
-- Initialize /dev
if FS.initFileSystem("/dev") == false then
    computer.panic("Cannot initialize /dev")
end

Drives = FS.childs("/dev")

-- Filtering out "serial"
for i, drive in pairs(Drives) do
    if drive == "serial" then table.remove(Drives, i) end
end

Scripts = {}

for _, drive in pairs(Drives) do
    print(drive)
    FS.mount('/dev/' .. drive , Root)
    for _, file in pairs(FS.childs('/dev')) do
        print(file)
    end
end

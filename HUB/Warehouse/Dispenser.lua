RefreshInterval = 1

Colors = {
    ok = { r = 0, g = 17, b = 0, a = 0.01 },
    warning = { r = 17, g = 17, b = 0, a = 0.01 },
    error = { r = 17, g = 0, b = 0, a = 0.01 }
}

StorageItems = {
    -- Infrastructure
    I1 = { item = findItem('Cable'), icon = 208 },
    I2 = { item = findItem('Circuit Board'), icon = 243 },
    I3 = { item = findItem('Computer'), icon = 271 },
    I4 = { item = findItem('Concrete'), icon = 211 },
    I5 = { item = findItem('Copper Sheet'), icon = 220 },
    I6 = { item = findItem('Encased Industrial Beam'), icon = 221 },
    I7 = { item = findItem('Heavy Modular Frame'), icon = 225 },
    I8 = { item = findItem('Iron Plate'), icon = 195 },
    I9 = { item = findItem('Iron Rod'), icon = 196 },
    I10 = { item = findItem('Motor'), icon = 223 },
    I11 = { item = findItem('Plastic'), icon = 224 },
    I12 = { item = findItem('Quartz Crystal'), icon = 218 },
    I13 = { item = findItem('Reinforced Iron Plate'), icon = 207 },
    I14 = { item = findItem('Rotor'), icon = 232 },
    I15 = { item = findItem('Silica'), icon = 275 },
    I16 = { item = findItem('Steel Beam'), icon = 219 },
    I17 = { item = findItem('Steel Pipe'), icon = 256 },
    I18 = { item = findItem('Wire'), icon = 209 },
    -- Facilities
    F1 = { item = findItem('AI Limiter'), icon = 230 },
    F2 = { item = findItem('Alclad Aluminium Sheet'), icon = 227 },
    F3 = { item = findItem('Aluminium Casing'), icon = 228 },
    F4 = { item = findItem('Cooling System'), icon = 259 },
    F5 = { item = findItem('Crystal Oscillator'), icon = 270 },
    F6 = { item = findItem('Electromagnetic Control Rod'), icon = 260 },
    F7 = { item = findItem('Fused Modular Frame'), icon = 265 },
    F8 = { item = findItem('High-Speed Connector'), icon = 226 },
    F9 = { item = findItem('Modular Frame'), icon = 233 },
    F10 = { item = findItem('Quickwire'), icon = 274 },
    F11 = { item = findItem('Radio Control Unit'), icon = 229 },
    F12 = { item = findItem('Rubber'), icon = 222 },
    F13 = { item = findItem('Stator'), icon = 247 },
    F14 = { item = findItem('Supercomputer'), icon = 267 },
    F15 = { item = findItem('Turbo Motor'), icon = 273 },
}

function GetSign(name)
    return component.proxy(component.findComponent(name)[1])
end

function GetSigns(group)
    signs = {}
    for _, comp in ipairs(component.findComponent(group)) do
        table.insert(signs, component.proxy(comp))
    end
    return signs
end

function SetSignIcon(sign, index)
    signData = sign:getPrefabSignData()
    signData:setIconElement('icon', index)
    sign:setPrefabSignData(signData)
    event.pull(0.01)
end

function SetSignColor(sign, color)
    signData = sign:getPrefabSignData()
    signColor = signData.background
    signColor.r = color.r
    signColor.g = color.g
    signColor.b = color.b
    signColor.a = color.a
    signData.background = signColor
    sign:setPrefabSignData(signData)
    event.pull(0.01)
end

function GetColor(level)
    if level < 0.01 then
        return Colors.error
    elseif level < 0.5 then
        return Colors.warning
    end

    return Colors.ok
end

function ContainerLevel(container, storageItem)
    if storageItem then
        local inventory = container:getInventories()[1]
        local count = 0
        local max = inventory.size * storageItem['item'].max

        for i = 0, inventory.size - 1, 1 do
            local stack = inventory:getStack(i)
            count = count + stack.count
        end

        return count / max
    else
        return 0
    end
end

function UpdateLevelDisplay(container, storageItem)
    local displayComps = component.findComponent("LevelDisplays")
    local color = GetColor(ContainerLevel(container, storageItem))

    for _, display in ipairs(GetSigns('LevelDisplays')) do
        SetSignColor(display, color)
    end
end

function AssignItem(container, storageItem)
    if storageItem then
        local signComps = component.findComponent("Signs")

        for _, sign in ipairs(GetSigns('Signs')) do
            SetSignIcon(sign, storageItem['icon'])
            -- TODO Set splitter
        end
    else
        print('Unknown item ' .. container.nick)
    end
end

while true do
    local container = component.proxy(component.findComponent(findClass("FGBuildableStorage"))[1])
    local storageItem = StorageItems[container.nick]

    AssignItem(container, storageItem)
    UpdateLevelDisplay(container, storageItem)

    event.pull(RefreshInterval)
end

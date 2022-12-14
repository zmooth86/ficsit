Colors = {
    ok = { r = 0, g = 7, b = 0, a = 0.01 },
    warning = { r = 7, g = 7, b = 0, a = 0.01 },
    error = { r = 7, g = 0, b = 0, a = 0.01 }
}

WarehouseItems = {
    None = { item = nil, icon = 341 },
    -- Infrastructure
    Cable = { item = findItem('Cable'), icon = 208 },
    CircuitBoard = { item = findItem('Circuit Board'), icon = 243 },
    Computer = { item = findItem('Computer'), icon = 271 },
    Concrete = { item = findItem('Concrete'), icon = 211 },
    CopperSheet = { item = findItem('Copper Sheet'), icon = 220 },
    EncasedIndustrialBeam = { item = findItem('Encased Industrial Beam'), icon = 221 },
    HeavyModularFrame = { item = findItem('Heavy Modular Frame'), icon = 225 },
    IronPlate = { item = findItem('Iron Plate'), icon = 195 },
    IronRod = { item = findItem('Iron Rod'), icon = 196 },
    Motor = { item = findItem('Motor'), icon = 223 },
    Plastic = { item = findItem('Plastic'), icon = 224 },
    QuartzCrystal = { item = findItem('Quartz Crystal'), icon = 218 },
    ReinforcedIronPlate = { item = findItem('Reinforced Iron Plate'), icon = 207 },
    Rotor = { item = findItem('Rotor'), icon = 232 },
    Silica = { item = findItem('Silica'), icon = 275 },
    SteelBeam = { item = findItem('Steel Beam'), icon = 219 },
    SteelPipe = { item = findItem('Steel Pipe'), icon = 256 },
    Wire = { item = findItem('Wire'), icon = 209 },
    -- Facilities
    AILimiter = { item = findItem('AI Limiter'), icon = 230 },
    AlcladAluminiumSheet = { item = findItem('Alclad Aluminium Sheet'), icon = 227 },
    AluminiumCasing = { item = findItem('Aluminium Casing'), icon = 228 },
    CoolingSystem = { item = findItem('Cooling System'), icon = 259 },
    CrystalOscillator = { item = findItem('Crystal Oscillator'), icon = 270 },
    ElectromagneticControlRod = { item = findItem('Electromagnetic Control Rod'), icon = 260 },
    FusedModularFrame = { item = findItem('Fused Modular Frame'), icon = 265 },
    HighSpeedConnector = { item = findItem('High-Speed Connector'), icon = 226 },
    ModularFrame = { item = findItem('Modular Frame'), icon = 233 },
    Quickwire = { item = findItem('Quickwire'), icon = 274 },
    RadioControlUnit = { item = findItem('Radio Control Unit'), icon = 229 },
    Rubber = { item = findItem('Rubber'), icon = 222 },
    Stator = { item = findItem('Stator'), icon = 247 },
    Supercomputer = { item = findItem('Supercomputer'), icon = 267 },
    TurboMotor = { item = findItem('Turbo Motor'), icon = 273 }
}

function GetColor(level)
    if level < 0.1 then
        return Colors.error
    elseif level < 0.5 then
        return Colors.warning
    end

    return Colors.ok
end

function GetContainerLevel(container, item)
    local inventory = container:getInventories()[1]
    local max = inventory.size * item.max
    local count = 0

    for i = 0, inventory.size - 1, 1 do
        local stack = inventory:getStack(i)
        count = count + stack.count
    end

    return count / max
end

function GetItemLevel(warehouseItem, container)
    local level = 0

    if warehouseItem.item then
        for _, c in pairs(container) do
            level = level + GetContainerLevel(c, warehouseItem.item)
        end
    end

    return level / #container
end

function UpdateItemLevel(warehouseItem, container)
    local level = GetItemLevel(warehouseItem, container)
    local color = GetColor(level)

    for _, display in ipairs(Signs.getSigns('Build_StandaloneWidgetSign_Square_Small_C')) do
        Signs.setSignColor(display, color)
    end

    Network:send(warehouseItem.item.name, level)
end

function AssignItem(warehouseItem, container)
    if warehouseItem then
        for _, sign in ipairs(Signs.getSigns('Build_StandaloneWidgetSign_Square_C')) do
            Signs.setSignIcon(sign, warehouseItem['icon'])
        end
    else
        print('Unknown item ' .. container.nick)
    end
end

function GetItem(container)
    local item = WarehouseItems.None

    for _, c in pairs(container) do
        local inventory = c:getInventories()[1]
        local stack = inventory:getStack(0)

        if stack.count > 0 then
            local itemId = string.gsub(stack.item.type.name, '( |-)', '')
            return WarehouseItems[itemId]
        end
    end

    return item
end

function GetContainer()
    local container = {}

    for _, c in pairs(component.findComponent(findClass("FGBuildableStorage"))) do
        table.insert(container, component.proxy(c))
    end

    return container
end




local container = GetContainer()
local warehouseItem = #container and GetItem(container) or WarehouseItems.None

AssignItem(warehouseItem, container)
UpdateItemLevel(warehouseItem, container)

Width, Height = 110,20
RefreshInterval = 1

BGColors = {
    default = { r = 0, g = 0, b = 0, a = 0.0 },
    ok = { r = 0, g = 255, b = 0, a = 0.5 },
    warning = { r = 255, g = 255, b = 0, a = 0.75 },
    error = { r = 255, g = 0, b = 0, a = 0.75 },
    none = { r = 147, g = 149, b = 151, a = 0.5 }
}

FGColors = {
    default = { r = 255, g = 255, b = 255, a = 1.0}
}

-- Debug Screen connected?
Screen = computer.getPCIDevices(findClass("FINComputerScreen"))[1]
-- If not, connect to stats screen
if not Screen then
    Screen = component.proxy(component.findComponent("StatsScreen"))
end
if not Screen then
  computer.panic("No output screen found!")
end 

GPU = computer.getPCIDevices(findClass("GPUT1"))[1]
if not GPU then
  computer.panic("No GPU found!")
end

GPU:bindScreen(screen)
event.listen(GPU)

GPU:setSize(Width, Height)

function SetFColor(color)
    GPU:setForeground(color.r, color.g, color.b, color.a)
end

function SetBGColor(color)
    GPU:setBackground(color.r, color.g, color.b, color.a)
end

function SetDefaultColors()
    SetBGColor(BGColors.default)
    SetFColor(FGColors.default)
end

function ClearScreen()
    SetDefaultColors()

    GPU:fill(0 ,0 , Width, Height, " ")
end

function DrawBar(label, value, y, fgColor, bgColor)
    local barLabel = string.format("- %s", label)
    local barLabelStart = 4

    local percentLabel = "---%"
    local percentLabelStart = Width - #percentLabel

    local barStart = 25
    local barLength = percentLabelStart - barStart

    if not(value ~= 0 and value ~= value) then
        percentLabel = string.format("%3d%%", math.floor(value * 100))
        percentLabelStart = Width - #percentLabel
        barLength = math.floor(value * (percentLabelStart - barStart))
    else
        fgColor = BGColors.none
        bgColor = BGColors.default
    end

    SetDefaultColors()
    GPU:setText(barLabelStart, y, barLabel)

    SetBGColor(bgColor)
    GPU:setText(barStart, y, string.rep(" ", percentLabelStart))

    SetBGColor(fgColor)
    GPU:setText(barStart, y, string.rep(" ", barLength))

    SetDefaultColors()
    SetFColor(fgColor)
    GPU:setText(percentLabelStart, y, percentLabel)
end

function GetHeader(stats)
    local headerLabel = string.format("%s:", stats.name)
    local headerStats = nil

    if stats.backup.hasBatteries then
        headerStats = string.format("%.2f MW capacity (%d MWh stored)", stats.capacity, stats.backup.stored)
    else
        headerStats = string.format("%.2f MW capacity", stats.capacity)
    end

    return string.format("%s%s%s", stats.name, string.rep(" ", Width - #headerLabel - #headerStats), headerStats)
end

function GetPoleStats(pole)
    local connector = pole:getPowerConnectors()[1]
    local circuit = connector:getCircuit()

    return {
        name = pole.nick,
        capacity = circuit.capacity,
        production = circuit.production / circuit.capacity,
        maxConsumption = circuit.maxPowerConsumption / circuit.production,
        consumption = circuit.consumption / circuit.production,
        backup = { hasBatteries = circuit.hasBatteries, stored = circuit.batteryStore, charge = circuit.batteryStorePercent, discharge = circuit.batteryOut / circuit.batteryCapacity }
    }
end

function DrawBackuoDischarge(stats, row)
    local fgColor = BGColors.ok
    local bgColor = BGColors.ok
    if stats.backup.discharge > 0.0 then
        fgColor = BGColors.warning
        bgColor = BGColors.none
    end
    DrawBar("Backup Discharge", stats.backup.discharge, row, fgColor, bgColor)
end

function DrawBackupCharge(stats, row)
    local fgColor = BGColors.ok
    local bgColor = BGColors.warning
    if stats.backup.charge < 0.1 then
        bgColor = BGColors.error
    end
    DrawBar("Backup Charge", stats.backup.charge, row, fgColor, bgColor)
end

function DrawConsumption(stats, row)
    local fgColor = BGColors.ok
    local bgColor = BGColors.none
    if stats.consumption > 0.8 then
        fgColor = BGColors.warning
    elseif stats.consumption > 0.99 then
        fgColor = BGColors.error
    end
    DrawBar("Consumption", stats.consumption, row, fgColor, bgColor)
end

function DrawMaxConsumption(stats, row)
    local fgColor = BGColors.ok
    local bgColor = BGColors.none
    if stats.maxConsumption > 0.8 then
        fgColor = BGColors.warning
    elseif stats.maxConsumption > 0.99 then
        fgColor = BGColors.error
    end
    DrawBar("Max. Consumption", stats.maxConsumption, row, fgColor, bgColor)
end

function DrawProduction(stats, row)
    local fgColor = BGColors.ok
    local bgColor = BGColors.error
    if stats.production < 1.0 then
        fgColor = BGColors.warning
    elseif stats.production < 0.9 then
        fgColor = BGColors.error
    end
    DrawBar("Production", stats.production, row, fgColor, bgColor)
end

function DrawStats(row, pole)
    local stats = GetPoleStats(pole)
    local fgColor = BGColors.ok
    local bgColor = BGColors.none

    SetDefaultColors()

    GPU:setText(0, row, GetHeader(stats))

    row = row + 1
    DrawProduction(stats, row)
    row = row + 1
    DrawMaxConsumption(stats, row)
    row = row + 1
    DrawConsumption(stats, row)
    if stats.backup.hasBatteries then
        row = row + 1
        DrawBackupCharge(stats, row)
        row = row + 1
        DrawBackuoDischarge(stats, row)
    else
        row = row + 2
    end

    return row + 1
end


while true do
    local row = 0

    ClearScreen()

    row = DrawStats(row, component.proxy(component.findComponent("Backup")[1]))
    row = row + 1
    row = DrawStats(row, component.proxy(component.findComponent("Generators")[1]))
    row = row + 1
    row = DrawStats(row, component.proxy(component.findComponent("Grid")[1]))

    GPU:flush()
    event.pull(RefreshInterval)
end

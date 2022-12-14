RefreshInterval = 1

function Printfuel()
    local fuelStation = component.proxy(component.findComponent("FuelStation")[1])
    local fuelDisplay = component.proxy(component.findComponent("FuelDisplay")[1])

    local fuel = fuelStation:getFuelInv().itemCount
    local signData = fuelDisplay:getPrefabSignData()

    if fuel == 0 then
        signData:setTextElement('Other_1', '----')
    else
        signData:setTextElement('Other_1', tostring(fuel))
    end

    fuelDisplay:setPrefabSignData(signData)
end

function RequestFuel()
    local dronePort = component.proxy(component.findComponent("DronePort")[1])
    local fuel = dronePort:getInventories()[2].itemCount

    if fuel <= 200 then
        dronePort.standby = false
    else
        dronePort.standby = true
    end
end


while true do
    Printfuel()
    RequestFuel()

    event.pull(RefreshInterval)
end

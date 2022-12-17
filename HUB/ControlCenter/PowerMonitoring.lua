IndicatorModules = 30

Colors = {
    default = { r = 0, g = 0, b = 0, a = 0.0 },
    ok = { r = 0, g = 17, b = 0, a = 0.01 },
    warning = { r = 17, g = 17, b = 0, a = 0.01 },
    error = { r = 17, g = 0, b = 0, a = 0.01 },
}

function SetModuleColor(module, color)
    module:setColor(color.r, color.g, color.b, color.a)
end

function SetIndicatorColor(indicator, color, from, to)
    for i = from, to, 1 do
        SetModuleColor(indicator:getModule(i), color)
    end
end

function GetWorkloadColor(workload)
    if workload > 0.99 then
        return Colors.error
    elseif workload > 0.8 then
        return Colors.warning
    end

    return Colors.ok
end

function IndicateWorkload(pole)
    local connector = pole:getPowerConnectors()[1]
    local circuit = connector:getCircuit()
    local workload = circuit.consumption / circuit.production

    for _, comp in ipairs(component.findComponent(findClass('ModularIndicatorPole'))) do
        local indicator = component.proxy(comp)

        SetIndicatorColor(indicator, Colors.default, 0, IndicatorModules)

        if not(workload ~= 0 and workload ~= workload) then
            local module = math.floor(workload * IndicatorModules)

            SetIndicatorColor(indicator, GetWorkloadColor(workload), 0, module)
        end
    end
end




IndicateWorkload(component.proxy(component.findComponent(findClass('FGBuildablePowerPole'))[1]))

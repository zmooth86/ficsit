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

function SetSignText(sign, text)
    signData = sign:getPrefabSignData()
    signData:setTextElement('name', text)
    sign:setPrefabSignData(signData)
    event.pull(0.01)
end

function SetSignIcon(sign, index)
    signData = sign:getPrefabSignData()
    signData:setIconElement('icon', index)
    sign:setPrefabSignData(signData)
    event.pull(0.0)
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
    event.pull(0.0)
end

function GetSignText(sign)
    signData = sign:getPrefabSignData()
    textElements = signData:getTextElements()
    text = signData:getTextElement(textElements[1])
    label = signData:getTextElement(textElements[2])
    return text, label
end

function GetSignIcon(sign)
    signData = sign:getPrefabSignData()
    iconElements = signData:getIconElements()
    return signData:getIconElement(iconElements[1])
end

function GetSignBackground(sign)
    signData = sign:getPrefabSignData()
    iconElements = signData:getIconElements()
    return signData:getIconElement(iconElements[2])
end

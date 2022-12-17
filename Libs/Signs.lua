Signs = {}

function Signs.getSign(name)
    return component.proxy(component.findComponent(name)[1])
end

function Signs.getSigns(group)
    signs = {}
    for _, comp in ipairs(component.findComponent(group)) do
        table.insert(signs, component.proxy(comp))
    end
    return signs
end

function Signs.setSignText(sign, text)
    signData = sign:getPrefabSignData()
    signData:setTextElement('name', text)
    sign:setPrefabSignData(signData)
    event.pull(0.01)
end

function Signs.setSignIcon(sign, index)
    signData = sign:getPrefabSignData()
    signData:setIconElement('icon', index)
    sign:setPrefabSignData(signData)
    event.pull(0.0)
end

function Signs.setSignColor(sign, color)
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

function Signs.getSignText(sign)
    signData = sign:getPrefabSignData()
    textElements = signData:getTextElements()
    text = signData:getTextElement(textElements[1])
    label = signData:getTextElement(textElements[2])
    return text, label
end

function Signs.getSignIcon(sign)
    signData = sign:getPrefabSignData()
    iconElements = signData:getIconElements()
    return signData:getIconElement(iconElements[1])
end

function Signs.getSignBackground(sign)
    signData = sign:getPrefabSignData()
    iconElements = signData:getIconElements()
    return signData:getIconElement(iconElements[2])
end

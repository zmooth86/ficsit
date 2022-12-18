local item, level = Network:receive()

if item then
    print(item, level)
end

Card = computer.getPCIDevices(findClass("FINInternetCard"))[1]

function Download(url)
    local req = card:request(url, "GET", "")
    local _, data = req:await()
    return data
end



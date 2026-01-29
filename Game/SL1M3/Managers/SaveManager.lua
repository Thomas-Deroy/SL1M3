local SaveManager = {}

SaveManager.filePath = "SL1M3/Assets/player_data.json"

function SaveManager.getDefaults()
    return {
        points = 0,
        equippedSkin = 1,
        unlockedSkins = { [1] = true } -- always own the default skin
    }
end

function SaveManager.save(points, equippedSkin, unlockedSkins)
    local file = io.open(SaveManager.filePath, "w+")
    
    if file then
        file:write("{\n")
        
        -- Save points
        file:write('  "points": ' .. math.floor(points) .. ",\n")
        
        -- Save equipped skin
        file:write('  "equippedSkin": ' .. math.floor(equippedSkin) .. ",\n")
        
        -- Save unlocked skins as a list
        file:write('  "unlockedSkins": [')
        local idList = {}
        for id, owned in pairs(unlockedSkins) do
            if owned then table.insert(idList, id) end
        end
        for i, id in ipairs(idList) do
            file:write(id)
            if i < #idList then file:write(", ") end
        end
        file:write("]\n")
        file:write("}")
        file:close()
    end
end

function SaveManager.load()
    local file = io.open(SaveManager.filePath, "r")
    if not file then 
        return SaveManager.getDefaults() -- return defaults if no file
    end

    local content = file:read("*all")
    file:close()

    local data = SaveManager.getDefaults()

    -- Parse points
    local p = string.match(content, '"points":%s*(%d+)')
    if p then data.points = tonumber(p) end

    -- Parse equipped skin
    local e = string.match(content, '"equippedSkin":%s*(%d+)')
    if e then data.equippedSkin = tonumber(e) end

    -- Parse unlocked skins list
    local listStr = string.match(content, '"unlockedSkins":%s*%[(.-)%]')
    if listStr then
        data.unlockedSkins = {} -- clear default
        for num in string.gmatch(listStr, "(%d+)") do
            data[tonumber(num)] = true
            data.unlockedSkins[tonumber(num)] = true
        end
    end
    
    -- Always ensure default skin is owned
    data.unlockedSkins[1] = true

    return data
end

return SaveManager

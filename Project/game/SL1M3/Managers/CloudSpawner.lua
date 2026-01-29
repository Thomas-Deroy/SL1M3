-- Components
local CloudMover = require("SL1M3/Components/CloudMover")
local SpriteComponent = require("SL1M3/Components/SpriteComponent")

local CloudSpawner = {}
CloudSpawner.__index = CloudSpawner

function CloudSpawner.new(gameObjects, camera, imageList)
    local self = setmetatable({}, CloudSpawner)
    
    local cloudCount = 20  
    
    for i = 1, cloudCount do
        -- Random start positions 
        local startX = math.random(-200, 2000)
        local startY = math.random(0, 1440)
        
        local cloud = GameObject.new(startX, startY)
        
        -- Add movement component
        cloud:addComponent("cloud", CloudMover.new(camera, imageList))
        
        -- Add visual component
        local randomImg = imageList[math.random(1, #imageList)]
        local sprite = cloud:addComponent("renderer", SpriteComponent.new(randomImg, 1, 1))
        sprite:setScale(math.random(5, 15) / 10.0)  -- Random scale for variety
        
        table.insert(gameObjects, cloud)
    end
    
    return self
end

function CloudSpawner:update(dt)
end

return CloudSpawner

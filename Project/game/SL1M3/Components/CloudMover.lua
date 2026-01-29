-- Components
local SpriteComponent = require("SL1M3/Components/SpriteComponent")

local CloudMover = {}
CloudMover.__index = CloudMover

function CloudMover.new(camera, imageList)
    local self = setmetatable({}, CloudMover)
    self.camera = camera
    self.images = imageList -- Possible cloud sprites
    self.speed = math.random(5, 15)
    return self
end

function CloudMover:update(dt)
    local go = self.gameObject

    -- Drift left
    go.x = go.x - (self.speed * dt)

    -- Respawn if off-screen
    if go.x < (self.camera.x - 300) then
        self:respawn()
    end
end

function CloudMover:respawn()
    local go = self.gameObject

    -- Move to the right of the camera
    go.x = self.camera.x + 1280 + math.random(50, 500)
    go.y = math.random(0, 300)

    -- New speed
    self.speed = math.random(5, 25)

    -- Pick a random sprite
    local randomImg = self.images[math.random(1, #self.images)]
    local sprite = go:addComponent("renderer", SpriteComponent.new(randomImg, 1, 1))

    -- Random size for variety
    local scale = math.random(5, 15) / 10.0
    sprite:setScale(scale)
end

return CloudMover

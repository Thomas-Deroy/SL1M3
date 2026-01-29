local Camera = {}
Camera.__index = Camera 

function Camera.new(levelWidth, levelHeight, screenWidth, screenHeight)
    local self = setmetatable({}, Camera)

    -- Camera position
    self.x = 0
    self.y = 0

    -- World boundaries
    self.levelWidth = levelWidth or 1280
    self.levelHeight = levelHeight or 720

    -- Viewport size
    self.screenWidth = screenWidth or 1280
    self.screenHeight = screenHeight or 720

    return self
end

-- Center camera on target while clamping level bounds
function Camera:follow(targetX, targetY)
    -- Center camera on target
    local camX = targetX - (self.screenWidth / 2)
    local camY = targetY - (self.screenHeight / 2)

    -- Clamp to top-left
    if camX < 0 then camX = 0 end
    if camY < 0 then camY = 0 end

    -- Clamp to bottom-right
    if camX > self.levelWidth - self.screenWidth then
        camX = self.levelWidth - self.screenWidth
    end
    if camY > self.levelHeight - self.screenHeight then
        camY = self.levelHeight - self.screenHeight
    end

    self.x = camX
    self.y = camY
end

return Camera

local TrailComponent = {}
TrailComponent.__index = TrailComponent

function TrailComponent.new(spawnInterval, lifetime, startAlpha, scaleX, scaleY)
    local self = setmetatable({}, TrailComponent)
    
    self.spawnInterval = spawnInterval or 0.05
    self.lifetime = lifetime or 0.3
    self.startAlpha = startAlpha or 100 

    -- Custom scale & offset
    self.customScaleX = scaleX or 1.0
    self.customScaleY = scaleY or 1.0
    self.customOffsetX = 0
    self.customOffsetY = 0
    
    self.timer = 0
    self.ghosts = {} 
    return self
end

function TrailComponent:update(dt)
    local go = self.gameObject
    
    -- Update existing ghosts
    for i = #self.ghosts, 1, -1 do
        local ghost = self.ghosts[i]
        ghost.life = ghost.life - dt
        local lifePercent = ghost.life / self.lifetime
        ghost.alpha = math.floor(self.startAlpha * lifePercent)
        if ghost.life <= 0 then table.remove(self.ghosts, i) end
    end

    -- Spawn new ghost
    self.timer = self.timer + dt
    if self.timer >= self.spawnInterval then
        self.timer = 0
        local renderer = go:getComponent("renderer")
        if renderer and renderer.sprite then
            local finalScaleX = (renderer.scaleX or 1) * self.customScaleX
            local finalScaleY = (renderer.scaleY or 1) * self.customScaleY

            local ghost = {
                x = go.x,
                y = go.y,
                bitmap = renderer.sprite.bitmap,
                frameX = renderer.sprite.currentFrame * renderer.sprite.frameWidth,
                frameY = renderer.sprite.currentRow * renderer.sprite.frameHeight,
                frameW = renderer.sprite.frameWidth,
                frameH = renderer.sprite.frameHeight,
                scaleX = finalScaleX,
                scaleY = finalScaleY,
                offX = renderer.offX + self.customOffsetX,
                offY = renderer.offY + self.customOffsetY,
                life = self.lifetime,
                alpha = self.startAlpha
            }

            table.insert(self.ghosts, ghost)
        end
    end
end

function TrailComponent:draw(camera)
    for _, ghost in ipairs(self.ghosts) do
        if ghost.bitmap then
            local camX = camera and camera.x or 0
            local camY = camera and camera.y or 0
            local drawX = math.floor((ghost.x + ghost.offX) - camX)
            local drawY = math.floor((ghost.y + ghost.offY) - camY)
            local destW = math.floor(ghost.frameW * ghost.scaleX)
            local destH = math.floor(ghost.frameH * ghost.scaleY)

            -- Apply transparency
            ghost.bitmap:SetOpacity(ghost.alpha) 

            -- Draw ghost
            Engine.DrawBitmapRect(
                ghost.bitmap, drawX, drawY,
                math.floor(ghost.frameX), math.floor(ghost.frameY),
                math.floor(ghost.frameW), math.floor(ghost.frameH),
                destW, destH
            )

            -- Reset opacity
            ghost.bitmap:SetOpacity(255) 
        end
    end
end

return TrailComponent

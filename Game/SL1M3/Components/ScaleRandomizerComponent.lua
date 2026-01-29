local ScaleRandomizerComponent = {}
ScaleRandomizerComponent.__index = ScaleRandomizerComponent

function ScaleRandomizerComponent.new(duration)
    local self = setmetatable({}, ScaleRandomizerComponent)
    
    self.duration = duration or 1.0
    self.timer = 0
    self.active = true
    
    self.minScale = 1.0
    self.maxScale = 3.5  
    self.changeInterval = 0.15 
    self.changeTimer = 0
    
    -- Store original values 
    self.originalScaleX = nil
    self.originalScaleY = nil
    self.originalOffX = nil
    self.originalOffY = nil
    
    return self
end

function ScaleRandomizerComponent:update(dt)
    if not self.active then return end
    
    local go = self.gameObject
    local renderer = go:getComponent("renderer")
    local body = go:getComponent("body")
    if not renderer then return end

    -- Capture original scale/offset on first frame
    if self.originalScaleX == nil then
        self.originalScaleX = renderer.scaleX or 2
        self.originalScaleY = renderer.scaleY or 2
        self.originalOffX = renderer.offX or 0
        self.originalOffY = renderer.offY or 0
    end

    self.timer = self.timer + dt
    self.changeTimer = self.changeTimer + dt

    if self.timer < self.duration then
        -- Only update scale every interval
        if self.changeTimer >= self.changeInterval then
            self.changeTimer = 0
            local randomScale = self.minScale + math.random() * (self.maxScale - self.minScale)
            
            -- Apply random scale
            if renderer.setScale then
                renderer:setScale(randomScale)
            else
                renderer.scaleX = randomScale
                renderer.scaleY = randomScale
            end
            
            -- Center sprite on hitbox if physics exists
            if body and renderer.sprite then
                local spriteW = renderer.sprite.frameWidth * randomScale
                local spriteH = renderer.sprite.frameHeight * randomScale
                renderer.offX = (body.width - spriteW) / 2
                renderer.offY = (body.height - spriteH)
            end
        end
    else
        -- Restore original scale 
        self:restore()
    end
end

function ScaleRandomizerComponent:restore()
    if not self.active then return end
    self.active = false
    
    local go = self.gameObject
    if not go then return end
    
    local renderer = go:getComponent("renderer")
    
    -- Reset scale & offsets
    if renderer and self.originalScaleX then
        if renderer.setScale then
            renderer:setScale(self.originalScaleX)
        else
            renderer.scaleX = self.originalScaleX
            renderer.scaleY = self.originalScaleY
        end
        renderer.offX = self.originalOffX
        renderer.offY = self.originalOffY
    end
end

return ScaleRandomizerComponent

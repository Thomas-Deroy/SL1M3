local SineMoveComponent = {}
SineMoveComponent.__index = SineMoveComponent

function SineMoveComponent.new(amplitude, speed)
    local self = setmetatable({}, SineMoveComponent)
    self.amplitude = amplitude or 50  -- Movement range
    self.speed = speed or 2           
    self.timer = 0
    self.startY = nil                 -- Initial Y position
    return self
end

function SineMoveComponent:update(dt)
    local go = self.gameObject

    if not self.startY then 
        self.startY = go.y 
    end

    self.timer = self.timer + dt
    
    -- Calculate sine offset
    local offset = math.sin(self.timer * self.speed) * self.amplitude
    
    go.y = self.startY + offset
    
    -- Update physics if present
    local body = go:getComponent("body")
    if body and body.registered then
        body.world:update(go, go.x, go.y)
    end
end

return SineMoveComponent

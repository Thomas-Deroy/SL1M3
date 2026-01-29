local FloatingComponent = {}
FloatingComponent.__index = FloatingComponent

function FloatingComponent.new(amplitude, speed, sinkDepth, playerRef)
    local self = setmetatable({}, FloatingComponent)

    -- Idle float
    self.amplitude = amplitude or 5
    self.speed = speed or 2
    self.timer = math.random(0, 100)

    -- Bounce physics
    self.sinkDepth = sinkDepth or 10
    self.currentWeightY = 0
    self.velocity = 0
    self.stiffness = 120
    self.damping = 8

    self.startY = nil
    self.player = playerRef
    self.wasPlayerOn = false

    return self
end

function FloatingComponent:update(dt)
    local go = self.gameObject
    local player = self.player

    if not self.startY then self.startY = go.y end

    -- Is player on the platform
    local isPlayerOn = (player and player.groundObject == go)

    -- Detect landing impact
    if isPlayerOn and not self.wasPlayerOn then
        local impact = math.abs(player.dy or 0) * 0.5
        if impact > 200 then impact = 200 end
        self.velocity = self.velocity + impact
    end
    self.wasPlayerOn = isPlayerOn

    -- Float + spring math
    self.timer = self.timer + dt
    local sineOffset = math.sin(self.timer * self.speed) * self.amplitude

    local targetY = isPlayerOn and self.sinkDepth or 0
    local displacement = self.currentWeightY - targetY
    local force = (-self.stiffness * displacement) - (self.damping * self.velocity)

    self.velocity = self.velocity + force * dt
    self.currentWeightY = self.currentWeightY + self.velocity * dt

    -- Apply movement
    local oldY = go.y
    local newY = self.startY + sineOffset + self.currentWeightY
    local diffY = newY - oldY
    go.y = newY

    -- Sync physics + stick player to platform
    local body = go:getComponent("body")
    if body and body.registered then
        body.world:update(go, go.x + body.offsetX, go.y + body.offsetY)

        if isPlayerOn then
            player.y = player.y + diffY
            local pBody = player:getComponent("body")
            if pBody then
                pBody.world:update(player, player.x + pBody.offsetX, player.y + pBody.offsetY)
            end
        end
    end
end

return FloatingComponent

local GlitchPlatformComponent = {}
GlitchPlatformComponent.__index = GlitchPlatformComponent

function GlitchPlatformComponent.new(stableTime, glitchTime)
    local self = setmetatable({}, GlitchPlatformComponent)

    self.glitchTime = glitchTime or 1.5
    self.timer = 0
    self.state = "IDLE" -- IDLE -> GLITCHING -> GONE

    return self
end

function GlitchPlatformComponent:trigger()
    if self.state == "IDLE" then
        self.state = "GLITCHING"
        self.timer = 0
    end
end

function GlitchPlatformComponent:update(dt)
    local go = self.gameObject
    local renderer = go:getComponent("renderer")
    local body = go:getComponent("body")

    if self.state == "IDLE" then
        -- Safe
        if renderer then renderer:setAnimation(0, true, false) end

    elseif self.state == "GLITCHING" then
        self.timer = self.timer + dt

        -- Warning
        if renderer then renderer:setAnimation(1, true, false) end

        -- Vanish after timer
        if self.timer > self.glitchTime then
            self.state = "GONE"
            if body then body:setEnabled(false) end
        end

    elseif self.state == "GONE" then
        -- Gone
        if renderer then renderer:setAnimation(2, true, false) end
    end
end

return GlitchPlatformComponent

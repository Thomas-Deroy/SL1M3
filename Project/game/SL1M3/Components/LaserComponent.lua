-- Components
local SpriteComponent = require("SL1M3/Components/SpriteComponent")

local LaserComponent = {}
LaserComponent.__index = LaserComponent

function LaserComponent.new(warningDuration, fireDuration, isHorizontal)
    local self = setmetatable({}, LaserComponent)

    self.warningDuration = warningDuration
    self.fireDuration = fireDuration
    self.timer = 0
    self.state = "WARNING"

    self.isHorizontal = isHorizontal

    -- animation toggle
    self.animTimer = 0
    self.currentRow = 0

    return self
end

function LaserComponent:update(dt)
    local go = self.gameObject
    self.timer = self.timer + dt

    -- Warning animation flicker
    self.animTimer = self.animTimer + dt
    if self.animTimer > 0.1 then
        self.animTimer = 0
        self.currentRow = (self.currentRow + 1) % 2
        local renderer = go:getComponent("renderer")
        if renderer then
            renderer:setAnimation(self.currentRow, false, false)
        end
    end

    -- State machine
    if self.state == "WARNING" then
        if self.timer >= self.warningDuration then
            self.state = "FIRING"
            self.timer = 0

            -- Laser deadly
            go.tags["death"] = true

            local sprite
            if self.isHorizontal then
                sprite = SpriteComponent.new("SL1M3/Assets/laser_hit_horizontal.png", 1, 2)
            else
                sprite = SpriteComponent.new("SL1M3/Assets/laser_hit_vertical.png", 1, 2)
            end

            sprite:setScale(2.0)
            go:addComponent("renderer", sprite)
        end

    elseif self.state == "FIRING" then
        if self.timer >= self.fireDuration then
            -- Disable laser
            self.state = "DONE"
            go.tags["death"] = false
            go.isVisible = false

            local body = go:getComponent("body")
            if body then body:setEnabled(false) end
        end
    end
end

return LaserComponent

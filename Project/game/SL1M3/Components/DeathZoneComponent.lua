-- Components
local PhysicsComponent = require("SL1M3/Components/PhysicsComponent")

local DeathZoneComponent = {}
DeathZoneComponent.__index = DeathZoneComponent

function DeathZoneComponent.new(world, w, h)
    local self = setmetatable({}, DeathZoneComponent)
    self.world = world
    self.width = w
    self.height = h
    return self
end

function DeathZoneComponent:update(dt)
    local go = self.gameObject

    -- Mark as deadly
    go.tags["death"] = true

    -- Ensure a static collider exists
    if not go:getComponent("body") then
        go:addComponent("body", PhysicsComponent.new(self.world, self.width, self.height, "static"))
    end
end

function DeathZoneComponent:draw()
    -- Debug box
    local go = self.gameObject
    Engine.SetColor(255, 0, 0)
    Engine.DrawRect(math.floor(go.x), math.floor(go.y), self.width, self.height)
end

return DeathZoneComponent

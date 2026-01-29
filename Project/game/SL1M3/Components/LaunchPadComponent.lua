-- Components
local PhysicsComponent = require("SL1M3/Components/PhysicsComponent")

local LaunchPadComponent = {}
LaunchPadComponent.__index = LaunchPadComponent

function LaunchPadComponent.new(world, w, h, force)
    local self = setmetatable({}, LaunchPadComponent)
    self.world = world
    self.width = w
    self.height = h
    self.force = force or 20 -- Bounce strength
    return self
end

function LaunchPadComponent:update(dt)
    local go = self.gameObject

    -- Mark launch pad
    go.tags["bounce"] = true

    -- Ensure static body exists
    if not go:getComponent("body") then
        go:addComponent("body", PhysicsComponent.new(self.world, self.width, self.height, "static"))
    end
end

function LaunchPadComponent:draw()
    -- Debug box if no sprite
    local go = self.gameObject
    local body = go:getComponent("body")
    if body and not go:getComponent("renderer") then
        Engine.SetColor(255, 255, 0)
        Engine.DrawRect(math.floor(go.x), math.floor(go.y), self.width, self.height)
    end
end

return LaunchPadComponent

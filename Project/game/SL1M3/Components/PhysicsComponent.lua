-- Core game
local GameState     = require("SL1M3/GameState")

-- Manager
local SceneManager  = require("SL1M3/Managers/SceneManager")
local ScoreManager  = require("SL1M3/Managers/ScoreManager")
local EffectManager = require("SL1M3/Managers/EffectManager")

local PhysicsComponent = {}
PhysicsComponent.__index = PhysicsComponent

function PhysicsComponent.new(world, w, h, bodyType, offsetX, offsetY)
    local self = setmetatable({}, PhysicsComponent)
    self.world = world
    self.width = w
    self.height = h
    self.bodyType = bodyType or "dynamic"
    self.registered = false
    self.gravity = 10

    self.offsetX = offsetX or 0
    self.offsetY = offsetY or 0

    self.isEnabled = true
    self.isSensor = false -- Triggers only, no blocking

    return self
end

function PhysicsComponent:setEnabled(enabled)
    self.isEnabled = enabled

    -- Add / remove from physics world
    if not enabled and self.registered then
        self.world:remove(self.gameObject)
        self.registered = false
    elseif enabled and not self.registered then
        local go = self.gameObject
        self.world:add(go, go.x + self.offsetX, go.y + self.offsetY, self.width, self.height)
        self.registered = true
    end
end

function PhysicsComponent:update(dt)
    if not self.isEnabled then return end

    local go = self.gameObject
    go.groundObject = nil

    -- Register once
    if not self.registered then
        self.world:add(go, go.x + self.offsetX, go.y + self.offsetY, self.width, self.height)
        self.registered = true
    end

    if self.bodyType == "static" then return end

    -- Gravity
    if not go.ignoreGravity then
        go.dy = go.dy + (self.gravity * dt)
    end

    -- Movement target
    local goalX = go.x + self.offsetX + go.dx
    local goalY = go.y + self.offsetY + go.dy

    -- Sensors pass through
    local filter = function(item, other)
        if other.tags and (other.tags["death"] or other.tags["portal"] or other.tags["rift"] or other.tags["laser"]) then
            return "cross"
        end
        return "slide"
    end

    local actualX, actualY, cols, len = self.world:move(go, goalX, goalY, filter)

    go.x = actualX - self.offsetX
    go.y = actualY - self.offsetY

    -- Reset collision flags
    go.isGrounded = false
    go.touchingLeft = false
    go.touchingRight = false

    for i = 1, len do
        local col = cols[i]
        local other = col.other

        -- Detect sensors
        local isSensor = false
        local otherBody = other:getComponent("body")
        if otherBody and otherBody.isSensor then isSensor = true end
        if other.tags and (other.tags["laser"] or other.tags["rift"] or other.tags["portal"]) then
            isSensor = true
        end

        -- Death
        if other.tags and other.tags["death"] then
            if go:getComponent("input") then
                go.dx = 0; go.dy = 0
                self.bodyType = "static"
                if go.removeComponent then go:removeComponent("input") end

                GameState.bankPoints()
                ScoreManager.saveScore(GameState.score)
                GameState.reset()
                SceneManager.loadScene("SL1M3/Scenes/StartScreen")
                return
            else
                go:respawn()
                return
            end
        end

        -- Rift trigger
        if other.tags and other.tags["rift"] then
            go.dx = 0; go.dy = 0
            self.bodyType = "static"
            if go.removeComponent then go:removeComponent("input") end

            local rift = other:getComponent("rift")
            if rift then rift:onEnter() end
        end

        -- Portal trigger
        if other.tags and other.tags["portal"] then
            local portal = other:getComponent("portal")
            if portal then portal:onCollision(go) end
        end

        -- Launch pad
        local didBounce = false
        if other.tags and other.tags["bounce"] and col.normal.y == -1 then
            local launcher = other:getComponent("launchpad")
            local force = launcher and launcher.force or 20
            go.dy = -force
            EffectManager.trigger("trail", 2.5)
            didBounce = true
        end

        -- Solid collision response
        if not isSensor and not didBounce then
            if col.normal.y == -1 then
                go.isGrounded = true
                go.groundObject = other
                go.dy = 0
            elseif col.normal.y == 1 then
                go.dy = 0
            end

            if col.normal.x == -1 then go.touchingRight = true; go.dx = 0 end
            if col.normal.x ==  1 then go.touchingLeft  = true; go.dx = 0 end
        end
    end
end

function PhysicsComponent:teleport(x, y)
    -- Instant move
    self.gameObject.x = x
    self.gameObject.y = y
    if self.registered then
        self.world:update(self.gameObject, x + self.offsetX, y + self.offsetY)
    end
end

return PhysicsComponent

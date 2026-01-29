-- Components
local SpriteComponent = require("SL1M3/Components/SpriteComponent")
local EffectManager = require("SL1M3/Managers/EffectManager")

local PortalComponent = {}
PortalComponent.__index = PortalComponent

local ROW_TRANSITION = 0
local ROW_OPEN_IDLE  = 1

function PortalComponent.new(activationDist)
    local self = setmetatable({}, PortalComponent)

    self.linkedPortal = nil
    self.cooldown = 0
    self.cooldownDuration = 1.0
    self.activationDistance = activationDist or 150
    self.playerRef = nil
    self.state = "CLOSED"

    -- Prompt sprite (Press E)
    local dummy = SpriteComponent.new("SL1M3/Assets/label_press_e.png", 1, 1)
    dummy:setScale(0.5)
    self.promptSprite = dummy.sprite

    self.animTimer = 0
    self.promptOpacity = 0
    self.isPlayerInside = false

    return self
end

function PortalComponent:setLink(otherPortal)
    self.linkedPortal = otherPortal
end

function PortalComponent:setPlayer(player)
    self.playerRef = player
end

function PortalComponent:update(dt)
    local go = self.gameObject
    local renderer = go:getComponent("renderer")

    -- Mark portal
    go.tags["portal"] = true

    -- Timers
    if self.cooldown > 0 then self.cooldown = self.cooldown - dt end
    self.animTimer = self.animTimer + dt

    -- Input: teleport
    if self.isPlayerInside and Engine.IsKeyDown(69) and self.cooldown <= 0 and self.state == "OPEN" then
        self:teleportPlayer()
    end

    -- Distance check
    local isPlayerClose = false
    if self.playerRef then
        local dx = self.playerRef.x - go.x
        local dy = self.playerRef.y - go.y
        isPlayerClose = (math.sqrt(dx*dx + dy*dy) < self.activationDistance)
    end

    -- Fade prompt
    local targetOpacity = (isPlayerClose and (self.state == "OPEN" or self.state == "OPENING")) and 100 or 0
    local fadeSpeed = 300

    if self.promptOpacity < targetOpacity then
        self.promptOpacity = math.min(self.promptOpacity + fadeSpeed * dt, 100)
    elseif self.promptOpacity > targetOpacity then
        self.promptOpacity = math.max(self.promptOpacity - fadeSpeed * dt, 0)
    end

    -- State machine
    if renderer then
        if self.state == "CLOSED" then
            go.isVisible = false
            if isPlayerClose then
                self.state = "OPENING"
                go.isVisible = true
                renderer:setAnimation(ROW_TRANSITION, false, false)
            end

        elseif self.state == "OPENING" then
            if renderer:isFinished() then
                self.state = "OPEN"
                renderer:setAnimation(ROW_OPEN_IDLE, true, false)
            end

        elseif self.state == "OPEN" then
            if not isPlayerClose then
                self.state = "CLOSING"
                renderer:setAnimation(ROW_TRANSITION, false, true)
            end

        elseif self.state == "CLOSING" then
            if renderer:isFinished() then
                self.state = "CLOSED"
                go.isVisible = false
            end
        end
    end

    self.isPlayerInside = false
end

function PortalComponent:draw(camera)
    if self.promptOpacity <= 0 then return end

    local go = self.gameObject
    local camX = camera and camera.x or 0
    local camY = camera and camera.y or 0

    -- Apply opacity
    if self.promptSprite.bitmap.SetOpacity then
        self.promptSprite.bitmap:SetOpacity(math.floor(self.promptOpacity))
    end

    -- Bobbing
    local bob = math.sin(self.animTimer * 5) * 5

    self.promptSprite:draw((go.x + 10) - camX, (go.y - 30 + bob) - camY)

    -- Reset opacity
    if self.promptSprite.bitmap.SetOpacity then
        self.promptSprite.bitmap:SetOpacity(100)
    end
end

function PortalComponent:teleportPlayer()
    if not self.playerRef or not self.linkedPortal then return end

    local body = self.playerRef:getComponent("body")
    if body then body:teleport(self.linkedPortal.x, self.linkedPortal.y) end

    EffectManager.trigger("scaler", 2.5)

    -- Sync cooldowns
    self.cooldown = self.cooldownDuration
    local other = self.linkedPortal:getComponent("portal")
    if other then other.cooldown = self.cooldownDuration end
end

function PortalComponent:onCollision(player)
    self.isPlayerInside = true
end

return PortalComponent

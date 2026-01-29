-- Core game
local GameState     = require("SL1M3/GameState")

-- Manager
local SceneManager  = require("SL1M3/Managers/SceneManager")

local RiftComponent = {}
RiftComponent.__index = RiftComponent

-- Animation rows
local ROW_TRANSITION = 0
local ROW_OPEN_IDLE  = 1

function RiftComponent.new(activationDist)
    local self = setmetatable({}, RiftComponent)

    self.activationDistance = activationDist or 150
    self.playerRef = nil
    self.state = "CLOSED"
    self.hasTriggered = false

    -- Possible next levels
    self.levels = {
        "SL1M3/Scenes/TemplateLevel1",
        "SL1M3/Scenes/TemplateLevel2",
        "SL1M3/Scenes/TemplateLevel3"
    }
    return self
end

function RiftComponent:setPlayer(player)
    self.playerRef = player
end

function RiftComponent:update(dt)
    local go = self.gameObject
    local renderer = go:getComponent("renderer")

    -- Mark as rift for collisions
    go.tags["rift"] = true

    -- Check player distance
    local isPlayerClose = false
    if self.playerRef then
        local dx = self.playerRef.x - go.x
        local dy = self.playerRef.y - go.y
        isPlayerClose = (math.sqrt(dx*dx + dy*dy) < self.activationDistance)
    end

    -- Animation state machine
    if renderer then
        if self.state == "CLOSED" then
            go.isVisible = false
            renderer:setAnimation(ROW_TRANSITION, false, false)
            if isPlayerClose then
                self.state = "OPENING"
                go.isVisible = true
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
end

function RiftComponent:onEnter()
    -- Only trigger once and when open
    if self.state ~= "OPEN" or self.hasTriggered then return end
    self.hasTriggered = true

    GameState.addScore(10)
    GameState.advanceLevel()

    -- Pick a new level (avoid current)
    local nextLevel = self.levels[math.random(#self.levels)]
    local current = SceneManager.currentSceneName
    while nextLevel == current do
        nextLevel = self.levels[math.random(#self.levels)]
    end

    SceneManager.loadScene(nextLevel)
end

return RiftComponent

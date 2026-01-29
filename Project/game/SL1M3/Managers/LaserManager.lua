-- Core game
local GameObject = require("SL1M3/GameObject")
local GameState = require("SL1M3/GameState")

-- Componentr
local PhysicsComponent = require("SL1M3/Components/PhysicsComponent")
local LaserComponent = require("SL1M3/Components/LaserComponent")
local SpriteComponent = require("SL1M3/Components/SpriteComponent") 

local LaserManager = {}
LaserManager.__index = LaserManager

function LaserManager.new(world, gameObjects, player)
    local self = setmetatable({}, LaserManager)
    self.world = world
    self.gameObjects = gameObjects
    self.player = player
    
    self.timer = 4.0
    self.baseInterval = 8.0  
    self.range = 350          
    return self
end

function LaserManager:update(dt)
    if not self.player then return end
    
    self.timer = self.timer - dt
    
    if self.timer <= 0 then
        local currentInterval = self.baseInterval * GameState.difficultyMultiplier
        self.timer = currentInterval  
        self:spawnLaser()             
    end
end

function LaserManager:spawnLaser()
    -- Random orientation
    local isHorizontal = math.random() > 0.5
    
    local spawnX, spawnY
    local w, h
    local sprite
    
    if isHorizontal then
        -- Horizontal laser
        local offset = math.random(-200, 200)
        spawnX = -1000
        spawnY = self.player.y + offset
        w, h = 3000, 24
        sprite = SpriteComponent.new("SL1M3/Assets/laser_warning_horizontal.png", 1, 2)
    else
        -- Vertical laser
        local offset = math.random(-self.range, self.range)
        spawnX = self.player.x + offset
        spawnY = -1000
        w, h = 24, 3000
        sprite = SpriteComponent.new("SL1M3/Assets/laser_warning_vertical.png", 1, 2)
    end

    -- Create laser object
    local laser = GameObject.new(spawnX, spawnY)
    laser.isVisible = true
    laser.tags["laser"] = true
    
    -- Sprite
    sprite:setScale(2.0)
    laser:addComponent("renderer", sprite)
    
    -- Physics (sensor for damage)
    local body = PhysicsComponent.new(self.world, w, h, "static")
    body.isSensor = true
    laser:addComponent("body", body)
    
    -- Laser logic component
    laser:addComponent("laser", LaserComponent.new(1.5, 0.5, isHorizontal))
    
    table.insert(self.gameObjects, laser)
end

return LaserManager

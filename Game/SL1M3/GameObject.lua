GameObject = {}
GameObject.__index = GameObject

function GameObject.new(x, y)
    local self = setmetatable({}, GameObject)
    self.x = x or 0
    self.y = y or 0

    self.spawnX = x or 0
    self.spawnY = y or 0

    -- Respawn / flicker
    self.respawnTimer = 0        
    self.respawnDuration = 1.0   
    self.flickerInterval = 0.05  
    self.flickerClock = 0        
    self.isVisible = true        

    self.isUI = false

    self.dx = 0
    self.dy = 0
    self.components = {}  -- All attached components
    self.tags = {}        -- For identifying objects
    return self
end

function GameObject:setSpawn(x, y)
    self.spawnX = x
    self.spawnY = y
end

function GameObject:respawn()
    self.x = self.spawnX
    self.y = self.spawnY
    self.dx = 0
    self.dy = 0

    -- Start flicker
    self.respawnTimer = self.respawnDuration
    self.isVisible = true

    -- Reset physics hitbox
    local body = self:getComponent("body")
    if body and body.registered then
        body.world:update(self, self.x + body.offsetX, self.y + body.offsetY)
    end

    -- Reset stamina if present
    local stamina = self:getComponent("stamina")
    if stamina then stamina.currentStamina = stamina.maxStamina end
end

function GameObject:addComponent(name, component)
    self.components[name] = component
    component.gameObject = self 
    return component
end

function GameObject:removeComponent(name)
    self.components[name] = nil
end

function GameObject:getComponent(name)
    return self.components[name]
end

function GameObject:update(dt)
    -- Flicker effect during respawn
    if self.respawnTimer > 0 then
        self.respawnTimer = self.respawnTimer - dt
        self.flickerClock = self.flickerClock + dt

        if self.flickerClock >= self.flickerInterval then
            self.flickerClock = 0
            self.isVisible = not self.isVisible
        end

        if self.respawnTimer <= 0 then
            self.isVisible = true
        end
    end

    -- Update all components
    for _, comp in pairs(self.components) do
        if comp.update then comp:update(dt) end
    end
end

function GameObject:draw()
    if not self.isVisible then return end

    -- Draw all components
    for _, comp in pairs(self.components) do
        if comp.draw then comp:draw() end
    end
end

return GameObject

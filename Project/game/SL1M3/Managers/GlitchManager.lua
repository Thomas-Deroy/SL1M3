-- Core game
local GameState = require("SL1M3/GameState") 

local GlitchManager = {}
GlitchManager.__index = GlitchManager

function GlitchManager.new(baseInterval)
    local self = setmetatable({}, GlitchManager)
    
    self.platforms = {}       
    self.timer = 0            
    self.baseInterval = baseInterval or 2.0 
    self.currentIndex = 1     
    return self
end

function GlitchManager:addPlatform(platformObj)
    table.insert(self.platforms, platformObj)
end

function GlitchManager:update(dt)
    if self.currentIndex > #self.platforms then return end
    
    self.timer = self.timer + dt
    
    -- Adjust interval by difficulty
    local realInterval = self.baseInterval * GameState.difficultyMultiplier
    
    if self.timer > realInterval then
        self.timer = 0
        self:destroyNext()
    end
end

function GlitchManager:destroyNext()
    local platform = self.platforms[self.currentIndex]
    
    if platform then
        local glitchComp = platform:getComponent("glitch")
        if glitchComp then
            glitchComp:trigger() -- Activate glitch
        end
    end
    
    self.currentIndex = self.currentIndex + 1
end

return GlitchManager

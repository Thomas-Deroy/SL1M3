-- Sprite 
local Sprite = {}
Sprite.__index = Sprite

function Sprite.new(filename, cols, rows)
    local self = setmetatable({}, Sprite)
    self.bitmap = Bitmap.new(filename)
    if not self.bitmap then error("Failed to load: " .. filename) end

    self.cols = cols or 1
    self.rows = rows or 1
    self.frameWidth  = self.bitmap:GetWidth()  / self.cols
    self.frameHeight = self.bitmap:GetHeight() / self.rows

    self.scaleX = 1.0; self.scaleY = 1.0
    self.currentRow = 0
    self.currentFrame = 0
    self.timer = 0
    self.animSpeed = 0.1

    self.loop = true
    self.reverse = false
    self.finished = false
    return self
end

-- Start a new animation
function Sprite:setAnimation(row, loop, reverse)
    if self.currentRow ~= row or self.loop ~= loop or self.reverse ~= reverse then
        self.currentRow = row
        self.loop = (loop == nil) and true or loop
        self.reverse = reverse or false
        self.finished = false
        self.currentFrame = self.reverse and (self.cols - 1) or 0
    end
end

-- Update frame based on timer
function Sprite:update(dt)
    if self.finished then return end
    self.timer = self.timer + dt
    if self.timer >= self.animSpeed then
        self.timer = 0

        if self.reverse then
            if self.currentFrame > 0 then
                self.currentFrame = self.currentFrame - 1
            else
                if self.loop then self.currentFrame = self.cols - 1
                else self.finished = true end
            end
        else
            if self.currentFrame < self.cols - 1 then
                self.currentFrame = self.currentFrame + 1
            else
                if self.loop then self.currentFrame = 0
                else self.finished = true end
            end
        end
    end
end

-- Draw current frame
function Sprite:draw(x, y)
    local srcX = self.currentFrame * self.frameWidth
    local srcY = self.currentRow * self.frameHeight
    local destW = math.abs(self.frameWidth  * self.scaleX)
    local destH = math.abs(self.frameHeight * self.scaleY)

    Engine.DrawBitmapRect(
        self.bitmap,
        math.floor(x), math.floor(y),
        math.floor(srcX), math.floor(srcY),
        math.floor(self.frameWidth), math.floor(self.frameHeight),
        math.floor(destW), math.floor(destH)
    )
end


-- SpriteComponent
local SpriteComponent = {}
SpriteComponent.__index = SpriteComponent

function SpriteComponent.new(filename, cols, rows)
    local self = setmetatable({}, SpriteComponent)
    self.sprite = Sprite.new(filename, cols, rows)
    self.scale = 1.0
    self.offX = 0; self.offY = 0
    return self
end

function SpriteComponent:update(dt)
    self.sprite:update(dt)
end

function SpriteComponent:draw(camera)
    local camX = camera and camera.x or 0
    local camY = camera and camera.y or 0

    local drawX = (self.gameObject.x + self.offX) - camX
    local drawY = (self.gameObject.y + self.offY) - camY

    self.sprite:draw(drawX, drawY)
end

-- Animation helpers
function SpriteComponent:setScale(s)
    self.scale = s
    self.sprite.scaleX = s
    self.sprite.scaleY = s
end

function SpriteComponent:setAnimation(row, loop, reverse)
    self.sprite:setAnimation(row, loop, reverse)
end

function SpriteComponent:isFinished()
    return self.sprite.finished
end

function SpriteComponent:setAnimationSpeed(speed)
    self.sprite.animSpeed = speed
end

return SpriteComponent

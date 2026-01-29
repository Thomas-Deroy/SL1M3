local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent

function ButtonComponent.new(w, h, callback)
    local self = setmetatable({}, ButtonComponent)
    self.width = w
    self.height = h
    self.callback = callback
    self.isHovered = false
    return self
end

function ButtonComponent:update(dt)
    local go = self.gameObject
    local renderer = go:getComponent("renderer")

    -- Mouse position (global)
    local mx, my = Mouse.x, Mouse.y

    -- Button bounds
    local left   = go.x
    local right  = go.x + self.width
    local top    = go.y
    local bottom = go.y + self.height

    -- Is the mouse inside
    local inside = (mx >= left and mx <= right and my >= top and my <= bottom)

    if inside then
        self.isHovered = true

        -- Hover visuals
        if renderer then renderer:setAnimation(1, true, false) end

        -- Click check
        if Mouse.wasPressed then
            if self.callback then self.callback() end
        end
    else
        self.isHovered = false

        -- Idle visuals
        if renderer then renderer:setAnimation(0, true, false) end
    end
end

-- Debug box when no sprite is used
function ButtonComponent:draw()
    if not self.gameObject:getComponent("renderer") then
        local go = self.gameObject

        if self.isHovered then
            Engine.SetColor(255, 255, 0) -- Hover
        else
            Engine.SetColor(100, 100, 100) -- Idle
        end

        Engine.DrawRect(go.x, go.y, self.width, self.height)
    end
end

return ButtonComponent

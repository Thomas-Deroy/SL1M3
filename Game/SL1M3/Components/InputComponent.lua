local InputComponent = {}
InputComponent.__index = InputComponent

local runningSFX = Audio.new("SL1M3/Assets/Sound_Slime_Running.wav")
local hitGroundSFX = Audio.new("SL1M3/Assets/Sound_Slime_HittingObject.wav")

function InputComponent.new(maxSpeed, jumpForce)
    local self = setmetatable({}, InputComponent)

    -- Movement
    self.maxSpeed = maxSpeed or 3
    self.acceleration = 15
    self.friction = 12
    self.jumpForce = jumpForce or 5

    -- Wall movement
    self.wallSlideSpeed = 1
    self.climbSpeed = 2
    self.wallJumpKick = 5

    -- Fly mode
    self.isFlying = false
    self.flySpeed = 20
    self.toggleCooldown = 0

    self.facingRight = true
    self.state = "IDLE"

    -- Previous frame checks
    self.wasGrounded = false
    self.wasOnWall = false

    return self
end

function InputComponent:update(dt)
    -- Key codes
    local A, D, W, S, SPACE, U = 65, 68, 87, 83, 32, 85

    local go = self.gameObject
    local renderer = go:getComponent("renderer")

    runningSFX:Tick()
    hitGroundSFX:Tick()

    -- Fly mode toggle
    self.toggleCooldown = self.toggleCooldown - dt
    if Engine.IsKeyDown(U) and self.toggleCooldown <= 0 then
        self.isFlying = not self.isFlying
        self.toggleCooldown = 0.5
        go.dx = 0; go.dy = 0
        go.ignoreGravity = self.isFlying
        if self.isFlying then go.y = go.y - 10 end
    end

    -- Read input
    local inputX, inputY = 0, 0
    local jumpPressed = Engine.IsKeyDown(SPACE)
    local upPressed = Engine.IsKeyDown(W)

    if Engine.IsKeyDown(D) then inputX = 1; self.facingRight = true end
    if Engine.IsKeyDown(A) then inputX = -1; self.facingRight = false end
    if Engine.IsKeyDown(W) then inputY = -1 end
    if Engine.IsKeyDown(S) then inputY = 1 end

    -- Fly mode logic
    if self.isFlying then
        self.state = "FLY"
        go.ignoreGravity = true
        go.dx = inputX * self.flySpeed
        go.dy = inputY * self.flySpeed
        if renderer then renderer:setAnimation(0, true, false) end
        return
    end

    -- Landing / wall hit sounds
    if not self.wasGrounded and go.isGrounded then
        hitGroundSFX:Stop()
        hitGroundSFX:Play()
    end

    local isOnWall = (go.touchingLeft or go.touchingRight) and not go.isGrounded
    if not self.wasOnWall and isOnWall then
        hitGroundSFX:Stop()
        hitGroundSFX:Play()
    end

    self.wasGrounded = go.isGrounded
    self.wasOnWall = isOnWall

    -- State selection
    local canStick = false
    if not go.isGrounded then
        if go.touchingRight and inputX == 1 then canStick = true end
        if go.touchingLeft and inputX == -1 then canStick = true end
    end

    if canStick then self.state = "WALL"
    elseif not go.isGrounded then self.state = "AIR"
    elseif inputX ~= 0 or math.abs(go.dx) > 0.1 then self.state = "RUN"
    else self.state = "IDLE" end

    -- Wall movement
    if self.state == "WALL" then
        go.ignoreGravity = true
        go.dx = 0

        if upPressed then go.dy = -self.climbSpeed
        else go.dy = self.wallSlideSpeed end

        if go.touchingRight then go.x = go.x + 1; self.facingRight = true
        elseif go.touchingLeft then go.x = go.x - 1; self.facingRight = false end

        if jumpPressed then
            go.ignoreGravity = false
            go.dy = -self.jumpForce
            if upPressed then
                go.dx = go.touchingRight and -1 or 1
            else
                go.dx = go.touchingRight and -self.wallJumpKick or self.wallJumpKick
                self.facingRight = not self.facingRight
            end
        end

        if renderer then
            local row = go.touchingRight and 4 or 5
            renderer:setAnimationSpeed(0.15)
            renderer:setAnimation(row, true, false)
        end

    else
        -- Ground / air movement
        go.ignoreGravity = false

        if inputX ~= 0 then
            go.dx = go.dx + (inputX * self.acceleration * dt)
            go.dx = math.max(-self.maxSpeed, math.min(self.maxSpeed, go.dx))
        else
            local friction = self.friction * dt
            if math.abs(go.dx) < friction then go.dx = 0
            else go.dx = go.dx - friction * (go.dx > 0 and 1 or -1) end
        end

        if jumpPressed and go.isGrounded then
            go.dy = -self.jumpForce
            go.isGrounded = false
        end

        -- Animations
        if renderer then
            if not go.isGrounded then
                runningSFX:Stop()
                local row = self.facingRight and 6 or 7
                renderer:setAnimationSpeed(0.05)
                renderer:setAnimation(row, false, false)

            elseif self.state == "RUN" then
                if not runningSFX:IsPlaying() then runningSFX:Play() end
                renderer:setAnimationSpeed(0.1)
                renderer:setAnimation(self.facingRight and 2 or 3, true, false)

            else
                runningSFX:Stop()
                renderer:setAnimationSpeed(0.2)
                renderer:setAnimation(self.facingRight and 0 or 1, true, false)
            end
        end
    end
end

return InputComponent

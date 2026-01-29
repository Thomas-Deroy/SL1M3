

-- Required Components
require("SL1M3/GameObject")
local SpriteComponent  = require("SL1M3/Components/SpriteComponent")
local PhysicsComponent = require("SL1M3/Components/PhysicsComponent")
local LaunchPadComponent = require("SL1M3/Components/LaunchPadComponent")
local PortalComponent = require("SL1M3/Components/PortalComponent")
local FloatingComponent = require("SL1M3/Components/FloatingComponent")
local RiftComponent = require("SL1M3/Components/RiftComponent")
local GlitchPlatformComponent = require("SL1M3/Components/GlitchPlatformComponent")

local LevelBuilder = {}

function LevelBuilder.createPlatform(world, gameObjects, pendingPortals, player, x, y, type, props)
    local go = GameObject.new(x, y)
    props = props or {}

    -- Default visual & physics properties
    local spriteName = "SL1M3/Assets/platform1_spritesheet.png"
    local w, h = 220, 30
    local offY = 5
    local bodyType = "static"
    
    -- Platform Types 
    if type == 0 or type == 1 then
        go:addComponent("glitch", GlitchPlatformComponent.new(3.0, 5.0))
        spriteName = "SL1M3/Assets/platform1_spritesheet.png"
        w, h = 220, 30

    elseif type == 2 then
        go:addComponent("glitch", GlitchPlatformComponent.new(3.0, 5.0))
        spriteName = "SL1M3/Assets/platform2_spritesheet.png"
        w, h = 200, 30

    elseif type == 3 then
        go:addComponent("glitch", GlitchPlatformComponent.new(3.0, 5.0))
        spriteName = "SL1M3/Assets/platform3_spritesheet.png"
        w, h = 130, 175

    elseif type == 4 then
        -- Platform with Rift (level end)
        spriteName = "SL1M3/Assets/platform4_spritesheet.png"
        w, h = 170, 30
        offY = 100

        local riftObj = GameObject.new(x + (w/2) - 22, y)
        riftObj:addComponent("body", PhysicsComponent.new(world, 40, 60, "static"))
        local rComp = riftObj:addComponent("rift", RiftComponent.new(150))
        local sprite = riftObj:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/rift_spritesheet.png", 4, 2))
        sprite:setScale(1.5)

        if player then rComp:setPlayer(player) end

        table.insert(gameObjects, riftObj)

    elseif type == 5 then
        -- Launch Pad Platform
        go:addComponent("glitch", GlitchPlatformComponent.new(3.0, 5.0))
        spriteName = "SL1M3/Assets/platform5_spritesheet.png"
        w, h = 170, 30
        offY = 100

        local padW, padH = 40, 10
        local padX = x + (w - padW) / 2
        local padY = (y + offY) - padH
        
        local bouncer = GameObject.new(padX, padY)
        bouncer:addComponent("launchpad", LaunchPadComponent.new(world, padW, padH, 10))
        table.insert(gameObjects, bouncer)

    elseif type == 6 then
        -- Portal Platform
        go:addComponent("glitch", GlitchPlatformComponent.new(3.0, 5.0))
        spriteName = "SL1M3/Assets/platform6_spritesheet.png"
        w, h = 170, 30
        offY = 100

        local portalObj = GameObject.new(x + (w/2) - 16, y + 20)
        portalObj:addComponent("body", PhysicsComponent.new(world, 40, 60, "static"))
        portalObj:addComponent("portal", PortalComponent.new(150))
        portalObj:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/rift_spritesheet.png", 4, 2))

        table.insert(gameObjects, portalObj)
        table.insert(pendingPortals, portalObj)
    end

    -- Add main solid platform physics & sprite
    go:addComponent("body", PhysicsComponent.new(world, w, h, bodyType, 0, offY))
    local sprites = go:addComponent("renderer", SpriteComponent.new(spriteName, 4, 3))
    sprites:setAnimationSpeed(0.5)

    -- floating platform
    if props.isFloating then
        go:addComponent("floating", FloatingComponent.new(5, 2, 15, player))
    end
    
    table.insert(gameObjects, go)
    return go
end

return LevelBuilder

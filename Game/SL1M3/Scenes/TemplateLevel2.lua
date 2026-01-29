-- External libs
local bump = require "SL1M3/External Libraries/bump"

-- Core game
require("SL1M3/GameObject")
local GameState = require("SL1M3/GameState")

-- Managers
local LevelBuilder   = require("SL1M3/Managers/LevelBuilder")
local Camera         = require("SL1M3/Managers/CameraManager")
local CloudSpawner   = require("SL1M3/Managers/CloudSpawner")
local GlitchManager  = require("SL1M3/Managers/GlitchManager")
local SceneManager   = require("SL1M3/Managers/SceneManager") 
local LaserManager   = require("SL1M3/Managers/LaserManager")
local ScoreManager   = require("SL1M3/Managers/ScoreManager")
local EffectManager  = require("SL1M3/Managers/EffectManager")

-- Components
local SpriteComponent    = require("SL1M3/Components/SpriteComponent")
local PhysicsComponent   = require("SL1M3/Components/PhysicsComponent")
local InputComponent     = require("SL1M3/Components/InputComponent")
local DeathZoneComponent = require("SL1M3/Components/DeathZoneComponent")
local ButtonComponent    = require("SL1M3/Components/ButtonComponent")

local TemplateLevel2 = {}

-- Variables
local world = nil
local gameObjects = {}
local pendingPortals = {}
local camera = nil
local player = nil
local uiFont = nil
local uiCamera = { x = 0, y = 0 }
local laserManager = nil

-- Pause state 
local isPaused = false
local pauseOverlayAlpha = 0
local escPressed = false

-- UI Elements
local pauseIconBtn = nil
local pauseMenuButtons = {} 

-- Helper to Toggle Pause
local function togglePause()
    isPaused = not isPaused
    
    -- Show/Hide Menu Buttons
    for _, btn in pairs(pauseMenuButtons) do
        btn.isVisible = isPaused
        local bComp = btn:getComponent("button")
        if bComp then bComp.isDown = false end
    end
    
    -- Hide top-left button when menu is open
    if pauseIconBtn then
        pauseIconBtn.isVisible = not isPaused
    end
end

function TemplateLevel2.load()
    -- Physics world
    world = bump.newWorld(64)
    gameObjects = {}
    pendingPortals = {}

    -- Cloud assets
    local myCloudPNGs = {
        "SL1M3/Assets/cloud1.png", "SL1M3/Assets/cloud2.png",
        "SL1M3/Assets/cloud3.png", "SL1M3/Assets/cloud4.png",
        "SL1M3/Assets/cloud5.png", "SL1M3/Assets/cloud6.png"
    }

    -- Music
    GameState.setVolumeMusic(5)
    GameState.playMusic("SL1M3/Assets/Sound_GameStarted.wav")

    -- Reset on fresh start
    if GameState.level == 1 and GameState.score == 0 then
        GameState.reset()
    end
    
    -- UI font
    Font.LoadFile("SL1M3/Assets/PixelEmulator-xq08.ttf")
    uiFont = Font.new("Pixel Emulator", true, false, false, 40)

    -- Glitch effects
    glitchManager = GlitchManager.new(5.0)

    -- Camera setup
    camera = Camera.new(2560, 1440, 1280, 720)



    -- Background 
    local background = GameObject.new(0, 0)
    background:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/background_level2.png", 1, 1))
    table.insert(gameObjects, background)

    -- Clouds
    local skyManager = GameObject.new(0,0)
    skyManager:addComponent("spawner", CloudSpawner.new(gameObjects, camera, myCloudPNGs))
    table.insert(gameObjects, skyManager)

    -- Foreground
    local foreground = GameObject.new(0, 0)
    foreground:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/foreground_level2.png", 1, 1))
    table.insert(gameObjects, foreground)


    -- Player
    player = GameObject.new(220, 1200)

    local skinId = GameState.equippedSkin
    local skinConfig = GameState.skins[skinId]

    local spriteComp = player:addComponent("renderer", SpriteComponent.new(skinConfig.file, 4, 10))
    spriteComp:setScale(2.0)

    -- Physics body
    local hitW, hitH = 42, 46
    player:addComponent("body", PhysicsComponent.new(world, hitW, hitH, "dynamic"))

    local spriteW = spriteComp.sprite.frameWidth  * 2.0
    local spriteH = spriteComp.sprite.frameHeight * 2.0
    spriteComp.offX = (hitW - spriteW) / 2
    spriteComp.offY = (hitH - spriteH)

    player:addComponent("input", InputComponent.new(5, 6))
    table.insert(gameObjects, player)


    -- Effect init
    EffectManager.init(player)
    -- Laser init
    laserManager = LaserManager.new(world, gameObjects, player)

    -- Helper to spawn glitchy platforms
    local function CreatePlatform(x, y, type, props)
        local p = LevelBuilder.createPlatform(world, gameObjects, pendingPortals, player, x, y, type, props)
        glitchManager:addPlatform(p)
        return p
    end

    -- Level Layout
    CreatePlatform(125, 1270, 1)
    CreatePlatform(420, 1300, 1, { isFloating = true })
    CreatePlatform(690, 1110, 6)
    CreatePlatform(2300, 1180, 6)
    CreatePlatform(900, 960, 3)
    CreatePlatform(2040, 1000, 3)
    CreatePlatform(590, 850, 3)
    CreatePlatform(1780, 820, 5)
    CreatePlatform(2070, 560, 3)
    CreatePlatform(1770, 500, 2, { isFloating = true })
    CreatePlatform(2300, 380, 6)
    CreatePlatform(130, 140, 6)
    CreatePlatform(250, 730, 5)
    CreatePlatform(550, 510, 2, { isFloating = true })
    CreatePlatform(1540, 430, 1)
    CreatePlatform(960, 550, 1)

    -- Exit platform
    LevelBuilder.createPlatform(world, gameObjects, pendingPortals, player, 1280, 640, 4)

    -- Link portal pairs
    for i = 1, #pendingPortals, 2 do
        local p1 = pendingPortals[i]
        local p2 = pendingPortals[i + 1]
        if p1 and p2 then
            local c1 = p1:getComponent("portal")
            local c2 = p2:getComponent("portal")
            c1:setLink(p2); c2:setLink(p1)
            c1:setPlayer(player); c2:setPlayer(player)
        end
    end

    -- Kill zone
    local void = GameObject.new(-300, 1400)
    void:addComponent("death", DeathZoneComponent.new(world, 2700, 50))
    table.insert(gameObjects, void)


    -- UI overlay
    local ui = GameObject.new(0, 0)
    ui:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/UI.png", 1, 1))
    ui.isUI = true
    table.insert(gameObjects, ui)

    
    -- Pauze Button
    pauseIconBtn = GameObject.new(20, 20)
    pauseIconBtn.isUI = true
    pauseIconBtn:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/button_escape.png", 1, 2))
    pauseIconBtn:addComponent("button", ButtonComponent.new(50, 50, function() togglePause() end))
    table.insert(gameObjects, pauseIconBtn)

    -- Resume
    local resumeObj = GameObject.new(510, 250)
    resumeObj.isUI = true; resumeObj.isVisible = false
    resumeObj:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/button_resume.png", 1, 2))
    resumeObj:addComponent("button", ButtonComponent.new(200, 60, function() togglePause() end))
    
    -- Menu
    local menuObj = GameObject.new(535, 330)
    menuObj.isUI = true; menuObj.isVisible = false
    menuObj:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/button_menu.png", 1, 2))
    menuObj:addComponent("button", ButtonComponent.new(200, 60, function() 
            GameState.bankPoints() 
            ScoreManager.saveScore(GameState.score)
            GameState.reset()
        SceneManager.loadScene("SL1M3/Scenes/Menu") 
    end))
    
    -- Quit
    local quitObj = GameObject.new(535, 410)
    quitObj.isUI = true; quitObj.isVisible = false
    quitObj:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/button_quit.png", 1, 2))
    quitObj:addComponent("button", ButtonComponent.new(200, 60, function() 
            GameState.bankPoints() 
            ScoreManager.saveScore(GameState.score)
            GameState.reset()
        Engine.Quit() 
    end))

    table.insert(pauseMenuButtons, resumeObj)
    table.insert(pauseMenuButtons, menuObj)
    table.insert(pauseMenuButtons, quitObj)
end

function TemplateLevel2.unload()
    EffectManager.clear()
end

function TemplateLevel2.update(dt)
    -- Sync music state
    GameState.tickMusic()

    -- Toggle Pause Input
    if Engine.IsKeyDown(27) then 
        if not escPressed then
            togglePause()
            escPressed = true
        end
    else
        escPressed = false
    end

    if isPaused then
        -- Update pauze stuff
        if pauseIconBtn then pauseIconBtn:update(dt) end
        for _, btn in pairs(pauseMenuButtons) do
            btn:update(dt)
        end
        
        -- Smooth fade
        if pauseOverlayAlpha < 128 then 
            pauseOverlayAlpha = pauseOverlayAlpha + (500 * dt) 
        end
        
    else
        pauseOverlayAlpha = 0
    
        -- Update all objects
        for _, go in pairs(gameObjects) do
            go:update(dt) 
        end

        EffectManager.update(dt)
        if glitchManager then glitchManager:update(dt) end
        if laserManager then laserManager:update(dt) end
        if player then camera:follow(player.x + 16, player.y + 24) end

        GameState.addScore(1 * dt)
    end
end

function TemplateLevel2.draw()
    -- Draw objects
    for _, go in pairs(gameObjects) do
        if go.isVisible then
            local trail = go:getComponent("trail")
            if trail then trail:draw(camera) end

            local renderer = go:getComponent("renderer")
            if renderer then
                if go.isUI then renderer:draw(uiCamera)
                else renderer:draw(camera) end
            end

            local portal = go:getComponent("portal")
            if portal then portal:draw(camera) end

            local btn = go:getComponent("button")
            if btn then btn:draw() end

            local body = go:getComponent("body")
            if false then
                local drawX = math.floor((go.x + body.offsetX) - camera.x)
                local drawY = math.floor((go.y + body.offsetY) - camera.y)

                if go.tags["death"] then
                    Engine.SetColor(255, 0, 0) -- Red (Danger)
                elseif body.isSensor then
                    Engine.SetColor(255, 255, 0) -- Yellow (Trigger)
                elseif body.bodyType == "static" then
                    Engine.SetColor(34, 139, 34) -- Green (Platform)
                else
                    Engine.SetColor(0, 0, 255)   -- Blue (Dynamic)
                end

                -- Draw the outline
                Engine.DrawRect(drawX, drawY, body.width, body.height)
            end
        end
    end
    
    -- Draw UI Score
    if Engine.DrawString and uiFont then
        Engine.SetFont(uiFont)
        Engine.SetColor(255, 255, 255)
        
        local scoreText = "" .. math.floor(GameState.score)
        
        local charWidth = 26
        local textWidth = #scoreText * charWidth
        local drawX = math.floor(642 - (textWidth / 2))
        
        Engine.DrawString(scoreText, drawX, 650)
    end

    -- Pause overlay + buttons
    if isPaused then
        if Engine.FillRectAlpha then
            Engine.SetColor(0,0,0)
            Engine.FillRectAlpha(0, 0, 1280, 720, math.floor(pauseOverlayAlpha))
        end
        
        for _, btn in pairs(pauseMenuButtons) do
            if btn.isVisible then
                local renderer = btn:getComponent("renderer")
                if renderer then renderer:draw(uiCamera) end
                
                local bComp = btn:getComponent("button")
                if bComp then bComp:draw() end
            end
        end
    end
end

return TemplateLevel2
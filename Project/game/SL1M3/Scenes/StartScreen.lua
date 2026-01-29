-- External libs
local bump = require "SL1M3/External Libraries/bump" 

-- Core game
require("SL1M3/GameObject")
local GameState = require("SL1M3/GameState") 

-- Managers
local SceneManager = require("SL1M3/Managers/SceneManager")
local Camera       = require("SL1M3/Managers/CameraManager")
local CloudSpawner = require("SL1M3/Managers/CloudSpawner")
local ScoreManager = require("SL1M3/Managers/ScoreManager")

-- Components
local SpriteComponent    = require("SL1M3/Components/SpriteComponent")
local PhysicsComponent   = require("SL1M3/Components/PhysicsComponent")
local InputComponent     = require("SL1M3/Components/InputComponent")
local SineMoveComponent  = require("SL1M3/Components/SineMoveComponent")
local DeathZoneComponent = require("SL1M3/Components/DeathZoneComponent")
local RiftComponent      = require("SL1M3/Components/RiftComponent")
local ButtonComponent    = require("SL1M3/Components/ButtonComponent")

local StartScreen = {}

-- Variables
local world = nil
local gameObjects = {}
local camera = nil
local player = nil
local uiFont = nil
local uiCamera = { x = 0, y = 0 }
local highScores = {}

-- Pause state
local isPaused = false
local pauseOverlayAlpha = 0
local escPressed = false

-- Pause UI
local pauseIconBtn = nil
local pauseMenuButtons = {}

local function togglePause()
    isPaused = not isPaused

    -- Show / hide pause buttons
    for _, btn in pairs(pauseMenuButtons) do
        btn.isVisible = isPaused
        local bComp = btn:getComponent("button")
        if bComp then bComp.isDown = false end
    end

    -- Hide corner button while paused
    if pauseIconBtn then
        pauseIconBtn.isVisible = not isPaused
    end
end

function StartScreen.load()
    -- Physics & camera
    world = bump.newWorld(64)
    gameObjects = {}
    camera = Camera.new(1280, 720, 1280, 720)

    -- Cloud assets
    local myCloudPNGs = {
        "SL1M3/Assets/cloud1.png",
        "SL1M3/Assets/cloud2.png",
        "SL1M3/Assets/cloud3.png",
        "SL1M3/Assets/cloud4.png"
    }

    -- UI font
    Font.LoadFile("SL1M3/Assets/PixelEmulator-xq08.ttf")
    uiFont = Font.new("Pixel Emulator", true, false, false, 40)

    -- High scores
    highScores = ScoreManager.loadScores()
    GameState.highScores = highScores

    -- Music
    GameState.stopMusic()


    -- Background
    local background = GameObject.new(0, 0)
    background:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/background_startscreen.png", 1, 1))
    table.insert(gameObjects, background)

    -- Moving clouds
    local skyManager = GameObject.new(0, 0)
    skyManager:addComponent("spawner", CloudSpawner.new(gameObjects, camera, myCloudPNGs))
    table.insert(gameObjects, skyManager)

    -- Foreground layer
    local foreground = GameObject.new(0, 0)
    foreground:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/foreground_startscreen.png", 1, 1))
    table.insert(gameObjects, foreground)


    -- Player 
    player = GameObject.new(100, 500)

    local skinConfig = GameState.skins[GameState.equippedSkin]
    local spriteComp = player:addComponent("renderer", SpriteComponent.new(skinConfig.file, 4, 10))
    spriteComp:setScale(2.0)

    -- Physics body
    local hitW, hitH = 42, 46
    player:addComponent("body", PhysicsComponent.new(world, hitW, hitH, "dynamic"))

    -- Align sprite to hitbox
    local spriteW = spriteComp.sprite.frameWidth * 2.0
    local spriteH = spriteComp.sprite.frameHeight * 2.0
    spriteComp.offX = (hitW - spriteW) / 2
    spriteComp.offY = (hitH - spriteH)

    player:addComponent("input", InputComponent.new(5, 5))
    table.insert(gameObjects, player)


    -- Floating title
    local title = GameObject.new(0, 0)
    title:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/title.png", 1, 1))
    title:addComponent("sine", SineMoveComponent.new(20, 3))
    table.insert(gameObjects, title)

    -- Floors
    local floor1 = GameObject.new(0, 620)
    floor1:addComponent("body", PhysicsComponent.new(world, 460, 50, "static"))
    table.insert(gameObjects, floor1)

    local floor2 = GameObject.new(825, 620)
    floor2:addComponent("body", PhysicsComponent.new(world, 500, 50, "static"))
    table.insert(gameObjects, floor2)

    -- Center platform
    local plat1 = GameObject.new(530, 590)
    plat1:addComponent("body", PhysicsComponent.new(world, 220, 30, "static"))
    table.insert(gameObjects, plat1)

    -- Rift (start trigger)
    local rift = GameObject.new(615, 510)
    rift:addComponent("body", PhysicsComponent.new(world, 40, 60, "static"))
    rift:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/rift_spritesheet.png", 4, 2))

    local riftComp = rift:addComponent("rift", RiftComponent.new(150))
    riftComp:setPlayer(player)
    table.insert(gameObjects, rift)

    -- Kill zone below screen
    local void = GameObject.new(-300, 700)
    void:addComponent("death", DeathZoneComponent.new(world, 1880, 50))
    table.insert(gameObjects, void)


    -- UI frame
    local ui = GameObject.new(0, 0)
    ui:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/UI.png", 1, 1))
    ui.isUI = true
    table.insert(gameObjects, ui)


    -- Pause icon
    pauseIconBtn = GameObject.new(20, 20)
    pauseIconBtn.isUI = true
    pauseIconBtn:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/button_escape.png", 1, 2))
    pauseIconBtn:addComponent("button", ButtonComponent.new(50, 50, function() togglePause() end))
    table.insert(gameObjects, pauseIconBtn)

    -- Pause menu buttons
    local resumeObj = GameObject.new(510, 250)
    resumeObj.isUI = true; resumeObj.isVisible = false
    resumeObj:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/button_resume.png", 1, 2))
    resumeObj:addComponent("button", ButtonComponent.new(200, 60, function() togglePause() end))

    local menuObj = GameObject.new(535, 330)
    menuObj.isUI = true; menuObj.isVisible = false
    menuObj:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/button_menu.png", 1, 2))
    menuObj:addComponent("button", ButtonComponent.new(200, 60, function()
        SceneManager.loadScene("SL1M3/Scenes/Menu")
    end))

    local quitObj = GameObject.new(535, 410)
    quitObj.isUI = true; quitObj.isVisible = false
    quitObj:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/button_quit.png", 1, 2))
    quitObj:addComponent("button", ButtonComponent.new(200, 60, function() Engine.Quit() end))

    table.insert(pauseMenuButtons, resumeObj)
    table.insert(pauseMenuButtons, menuObj)
    table.insert(pauseMenuButtons, quitObj)
end

function StartScreen.update(dt)
    -- ESC toggle 
    if Engine.IsKeyDown(27) then
        if not escPressed then
            togglePause()
            escPressed = true
        end
    else
        escPressed = false
    end

    if isPaused then
        -- Update pause UI only
        if pauseIconBtn then pauseIconBtn:update(dt) end
        for _, btn in pairs(pauseMenuButtons) do
            btn:update(dt)
        end

        -- Fade overlay
        if pauseOverlayAlpha < 128 then
            pauseOverlayAlpha = pauseOverlayAlpha + (500 * dt)
        end
    else
        pauseOverlayAlpha = 0

        -- Normal update
        for _, go in pairs(gameObjects) do
            go:update(dt)
        end

        -- Camera follow
        if player then
            camera:follow(player.x + 16, player.y + 24)
        end
    end
end

function StartScreen.draw()

    -- Draw Objects
    for _, go in pairs(gameObjects) do
        if go.isVisible then
            local trail = go:getComponent("trail")
            if trail then trail:draw(camera) end

            local renderer = go:getComponent("renderer")
            if renderer then
                renderer:draw(go.isUI and uiCamera or camera)
            end
        end
    end

    -- High score UI
    if Engine.DrawString and uiFont then
        Engine.SetFont(uiFont)

        local charWidth = 22
        local offX, offY = 3, 3

        -- Score Title
        local title = "- Top Score - "
        local tX = math.floor(620 - (#title * charWidth) / 2)
        local tY = 220

        Engine.SetColor(0, 0, 0)
        Engine.DrawString(title, tX + offX, tY + offY)
        Engine.SetColor(255, 255, 255)
        Engine.DrawString(title, tX, tY)

        -- Score list
        local y = 260
        for i = 1, math.min(#highScores, 3) do
            local text = "" .. highScores[i]
            local x = math.floor(630 - (#text * charWidth) / 2)

            Engine.SetColor(0, 0, 0)
            Engine.DrawString(text, x + offX, y + offY)
            Engine.SetColor(255, 255, 255)
            Engine.DrawString(text, x, y)

            y = y + 50
        end
    end

    -- Pause overlay + buttons
    if isPaused and Engine.FillRectAlpha then
        Engine.SetColor(0, 0, 0)
        Engine.FillRectAlpha(0, 0, 1280, 720, math.floor(pauseOverlayAlpha))

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

return StartScreen

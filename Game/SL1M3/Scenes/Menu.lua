-- External libs
local bump = require "SL1M3/External Libraries/bump" 

-- Core game
require("SL1M3/GameObject")
GameState = require("SL1M3/GameState") 

-- Managers
local SceneManager = require("SL1M3/Managers/SceneManager")
local Camera       = require("SL1M3/Managers/CameraManager")
local LevelBuilder = require("SL1M3/Managers/LevelBuilder")
local CloudSpawner = require("SL1M3/Managers/CloudSpawner")

-- Components
local SpriteComponent   = require("SL1M3/Components/SpriteComponent")
local PhysicsComponent  = require("SL1M3/Components/PhysicsComponent")
local InputComponent    = require("SL1M3/Components/InputComponent")
local SineMoveComponent = require("SL1M3/Components/SineMoveComponent")
local ButtonComponent   = require("SL1M3/Components/ButtonComponent")

local Menu = {}

-- Variables
local world = nil          
local gameObjects = {}    
local camera = nil
local player = nil
local pendingPortals = {}  

function Menu.load()
    -- Physics & camera
    world = bump.newWorld(64)
    gameObjects = {}
    camera = Camera.new(1280, 720, 1280, 720)

    -- Start menu music
    GameState.setVolumeMusic(0)
    GameState.playMusic("SL1M3/Assets/Sound_Theme.wav")

    -- Cloud texture pool
    local myCloudPNGs = {
        "SL1M3/Assets/cloud1.png", "SL1M3/Assets/cloud2.png",
        "SL1M3/Assets/cloud3.png", "SL1M3/Assets/cloud4.png",
        "SL1M3/Assets/cloud5.png", "SL1M3/Assets/cloud6.png"
    }

    -- Static background
    local bg = GameObject.new(0, 0)
    bg:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/background_menu.png", 1, 1))
    table.insert(gameObjects, bg)

    -- Cloud spawner 
    local skyManager = GameObject.new(0, 0)
    skyManager:addComponent("spawner", CloudSpawner.new(gameObjects, camera, myCloudPNGs))
    table.insert(gameObjects, skyManager)

    -- Title 
    local title = GameObject.new(0, 0)
    title:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/title.png", 1, 1))
    title:addComponent("sine", SineMoveComponent.new(20, 3))
    table.insert(gameObjects, title)

    -- Play button
    local playBtn = GameObject.new(520, 250)
    playBtn:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/button_start.png", 1, 2))
    playBtn:addComponent("button", ButtonComponent.new(200, 80, function()
        SceneManager.loadScene("SL1M3/Scenes/StartScreen")
    end))
    table.insert(gameObjects, playBtn)

    -- Shop button
    local shopBtn = GameObject.new(534, 325)
    shopBtn:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/button_shop.png", 1, 2))
    shopBtn:addComponent("button", ButtonComponent.new(200, 80, function()
        SceneManager.loadScene("SL1M3/Scenes/Shop")
    end))
    table.insert(gameObjects, shopBtn)

    -- Quit button
    local quitBtn = GameObject.new(530, 400)
    quitBtn:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/button_quit.png", 1, 2))
    quitBtn:addComponent("button", ButtonComponent.new(200, 80, function()
        Engine.Quit()
    end))
    table.insert(gameObjects, quitBtn)

    -- Music toggle button
    local toggleBtn = GameObject.new(20, 650)

    -- Updates icon depending on music state (helper)
    local function updateSprite()
        local file = GameState.enableMusic
            and "SL1M3/Assets/button_sound_on.png"
            or  "SL1M3/Assets/button_sound_off.png"

        toggleBtn:addComponent("renderer", SpriteComponent.new(file, 1, 2))
    end

    updateSprite()

    -- Toggle music on click
    toggleBtn:addComponent("button", ButtonComponent.new(100, 50, function()
        GameState.setMusicToggle(not GameState.enableMusic)
        updateSprite()
    end))
    table.insert(gameObjects, toggleBtn)

    -- Player preview character
    player = GameObject.new(620, 500)

    local skin = GameState.skins[GameState.equippedSkin]
    local spriteComp = player:addComponent("renderer", SpriteComponent.new(skin.file, 4, 10))
    spriteComp:setScale(2.0)

    -- Physics hitbox
    local hitW, hitH = 42, 46
    player:addComponent("body", PhysicsComponent.new(world, hitW, hitH, "dynamic"))

    -- Align sprite visually with hitbox
    spriteComp.offX = (hitW - spriteComp.sprite.frameWidth * 2) / 2
    spriteComp.offY = (hitH - spriteComp.sprite.frameHeight * 2)

    -- Simple idle movement
    player:addComponent("input", InputComponent.new(0, 5))
    table.insert(gameObjects, player)

    -- Floating platform under player
    LevelBuilder.createPlatform(world, gameObjects, pendingPortals, player, 530, 590, 1, {
        isFloating = true
    })
end

function Menu.unload()
    -- Unload
end

function Menu.update(dt)
    -- Sync music state
    GameState.tickMusic()

    -- Update all objects
    for _, go in pairs(gameObjects) do
        go:update(dt)
    end

    -- Camera tracks player preview
    if player then
        camera:follow(player.x + 16, player.y + 24)
    end
end

function Menu.draw()
    for _, go in pairs(gameObjects) do
        -- Draw sprites
        if go.isVisible then
            local renderer = go:getComponent("renderer")
            if renderer then
                renderer:draw(camera)
            end
        end

        -- Debug collision boxes
        local body = go:getComponent("body")
        if false then
            local x = math.floor(go.x + body.offsetX - camera.x)
            local y = math.floor(go.y + body.offsetY - camera.y)

            Engine.SetColor(
                body.bodyType == "static" and 34 or 255,
                body.bodyType == "static" and 139 or 0,
                body.bodyType == "static" and 34 or 0
            )

            Engine.DrawRect(x, y, body.width, body.height)
        end
    end
end

return Menu

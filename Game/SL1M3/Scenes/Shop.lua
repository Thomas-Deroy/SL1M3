-- External Libraries
local bump = require "SL1M3/External Libraries/bump" 

-- Core game
require("SL1M3/GameObject")
local GameState = require("SL1M3/GameState") 

-- Managers
local SceneManager = require("SL1M3/Managers/SceneManager")
local LevelBuilder = require("SL1M3/Managers/LevelBuilder")

-- Components
local SpriteComponent  = require("SL1M3/Components/SpriteComponent")
local PhysicsComponent = require("SL1M3/Components/PhysicsComponent")
local InputComponent   = require("SL1M3/Components/InputComponent")
local ButtonComponent  = require("SL1M3/Components/ButtonComponent")

local Shop = {}

-- Variables
local world = nil
local gameObjects = {}
local uiFont = nil
local player = nil
local equippedIndicator = nil 

function Shop.load()
    -- Physics
    world = bump.newWorld(64)
    gameObjects = {}
    local pendingPortals = {}

    -- UI font
    Font.LoadFile("SL1M3/Assets/PixelEmulator-xq08.ttf")
    uiFont = Font.new("Pixel Emulator", true, false, false, 40)

    -- Music
    GameState.playMusic("SL1M3/Assets/Sound_Theme.wav")

    -- Background
    local bg = GameObject.new(0, 0)
    bg:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/background_menu.png", 1, 1))
    table.insert(gameObjects, bg)

    -- Return button
    local backBtn = GameObject.new(20, 20)
    backBtn:addComponent("renderer", SpriteComponent.new("SL1M3/Assets/button_escape.png", 1, 2))
    backBtn:addComponent("button", ButtonComponent.new(100, 50, function()
        SceneManager.loadScene("SL1M3/Scenes/Menu")
    end))
    table.insert(gameObjects, backBtn)

    -- Skin grid layout
    local startX, startY = 440, 180
    local spacingX, spacingY = 150, 150

    for i, data in ipairs(GameState.skins) do
        -- Grid positioning
        local col = (i - 1) % 3
        local row = math.floor((i - 1) / 3)
        local x = startX + col * spacingX
        local y = startY + row * spacingY

        -- Skin button
        local btnObj = GameObject.new(x, y)
        local sprite = btnObj:addComponent("renderer", SpriteComponent.new(data.icon, 1, 2))
        sprite:setScale(2)

        -- Buy / equip logic
        btnObj:addComponent("button", ButtonComponent.new(200, 100, function()
            if GameState.unlockedSkins[data.id] then
                -- Owned -> equip
                GameState.equippedSkin = data.id
                Shop.updatePlayerSprite()
                Shop.moveIndicator(data.id)
                GameState.saveGame()
            else
                -- Not owned -> try to buy
                if GameState.points >= data.price then
                    GameState.points = GameState.points - data.price
                    GameState.unlockedSkins[data.id] = true
                    GameState.equippedSkin = data.id

                    Shop.updatePlayerSprite()
                    Shop.moveIndicator(data.id)
                    GameState.saveGame()

                    -- Reload to remove price tag
                    SceneManager.loadScene("SL1M3/Scenes/Shop", true)
                end
            end
        end))
        table.insert(gameObjects, btnObj)

        -- Price tag for locked skins
        if not GameState.unlockedSkins[data.id] then
            local offsetX = data.priceOffX or 10
            local offsetY = data.priceOffY or 80

            local priceObj = GameObject.new(x + offsetX, y + offsetY)
            priceObj:addComponent("renderer", SpriteComponent.new(data.price_image, 1, 1))
            table.insert(gameObjects, priceObj)
        end
    end

    -- Equipped skin indicator
    equippedIndicator = GameObject.new(0, 0)
    local indSprite = equippedIndicator:addComponent(
        "renderer",
        SpriteComponent.new("SL1M3/Assets/icon_equipped.png", 1, 1)
    )
    indSprite:setScale(2.0)
    table.insert(gameObjects, equippedIndicator)

    Shop.moveIndicator(GameState.equippedSkin)

    -- Player preview
    player = GameObject.new(620, 500)
    local skinData = GameState.skins[GameState.equippedSkin]

    local spriteComp = player:addComponent("renderer", SpriteComponent.new(skinData.file, 4, 10))
    spriteComp:setScale(3.0)

    -- Physics body
    local hitW, hitH = 42, 46
    player:addComponent("body", PhysicsComponent.new(world, hitW, hitH, "dynamic"))

    -- Align sprite to hitbox
    local spriteW = spriteComp.sprite.frameWidth * 3.0
    local spriteH = spriteComp.sprite.frameHeight * 3.0
    spriteComp.offX = (hitW - spriteW) / 2
    spriteComp.offY = (hitH - spriteH)

    -- Idle movement
    player:addComponent("input", InputComponent.new(0, 5))
    table.insert(gameObjects, player)

    -- Floating platform
    LevelBuilder.createPlatform(world, gameObjects, pendingPortals, player, 530, 590, 1, {
        isFloating = true
    })
end

function Shop.unload()
    -- Unload
end

function Shop.moveIndicator(id)
    if not equippedIndicator then return end

    local startX, startY = 436, 176
    local spacingX, spacingY = 150, 150

    local col = (id - 1) % 3
    local row = math.floor((id - 1) / 3)

    equippedIndicator.x = startX + col * spacingX
    equippedIndicator.y = startY + row * spacingY
end

function Shop.updatePlayerSprite()
    if not player then return end

    local skinData = GameState.skins[GameState.equippedSkin]
    local newSprite = SpriteComponent.new(skinData.file, 4, 10)
    newSprite:setScale(3.0)

    local body = player:getComponent("body")
    if body then
        local spriteW = newSprite.sprite.frameWidth * 3.0
        local spriteH = newSprite.sprite.frameHeight * 3.0
        newSprite.offX = (body.width - spriteW) / 2
        newSprite.offY = (body.height - spriteH)
    end

    player:addComponent("renderer", newSprite)
end

function Shop.update(dt)
    -- Sync music state
    GameState.tickMusic()

    -- Update all objects
    for _, go in pairs(gameObjects) do
        go:update(dt)
    end
end

function Shop.draw()
    -- Draw UI elements
    for _, go in pairs(gameObjects) do
        local renderer = go:getComponent("renderer")
        if renderer then renderer:draw() end

        local btn = go:getComponent("button")
        if btn then btn:draw() end
    end

    -- Points display
    if Engine.DrawString and uiFont then
        Engine.SetFont(uiFont)
        Engine.SetColor(255, 255, 255)
        Engine.DrawString("POINTS: " .. GameState.points, 900, 30)
    end
end

return Shop

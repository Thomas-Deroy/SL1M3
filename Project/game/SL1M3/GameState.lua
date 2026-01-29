-- Managers
local SaveManager = require("SL1M3/Managers/SaveManager")

local GameState = {}

-- Core Progression 
GameState.level = 1
GameState.difficultyMultiplier = 1.0
GameState.speedIncreasePerLevel = 0.85

-- Music State 
GameState.bgMusic = nil
GameState.currentTrack = ""
GameState.enableMusic = true

-- Skins / Shop Data 
GameState.skins = {
    { id = 1, name = "Classic Slime",       price = 0,   price_image = "SL1M3/Assets/price_free.png",  priceOffX = 13, file = "SL1M3/Assets/player_spritesheet_classic_blue.png",  icon = "SL1M3/Assets/button_color_classic_blue.png" },
    { id = 2, name = "Red Slime",           price = 50,  price_image = "SL1M3/Assets/price_50.png",    priceOffX = 25, file = "SL1M3/Assets/player_spritesheet_red.png",           icon = "SL1M3/Assets/button_color_red.png" },
    { id = 3, name = "Plant Slime",         price = 100, price_image = "SL1M3/Assets/price_100.png",   priceOffX = 13, file = "SL1M3/Assets/player_spritesheet_plant.png",         icon = "SL1M3/Assets/button_color_plant.png" },
    { id = 4, name = "Pink Slime",          price = 100, price_image = "SL1M3/Assets/price_100.png",   priceOffX = 13, file = "SL1M3/Assets/player_spritesheet_pink.png",          icon = "SL1M3/Assets/button_color_pink.png" },
    { id = 5, name = "Shiny Classic Slime", price = 200, price_image = "SL1M3/Assets/price_200.png",   priceOffX = 13, file = "SL1M3/Assets/player_spritesheet_shiny_blue.png",    icon = "SL1M3/Assets/button_color_shiny_blue.png" },
    { id = 6, name = "Golden Slime",        price = 500, price_image = "SL1M3/Assets/price_500.png",   priceOffX = 13, file = "SL1M3/Assets/player_spritesheet_gold.png",          icon = "SL1M3/Assets/button_color_gold.png" }
}

-- Runtime Score 
GameState.score = 0
GameState.highScores = { 0, 0, 0 }

-- Persistent Player Data 
GameState.points = 0
GameState.unlockedSkins = { [1] = true }
GameState.equippedSkin = 1

function GameState.reset()
    GameState.level = 1
    GameState.score = 0
    GameState.difficultyMultiplier = 1.0
end

function GameState.addScore(amount)
    if GameState.level > 1 then -- ignore Level 1 
        GameState.score = GameState.score + amount
    end
end

function GameState.advanceLevel()
    GameState.level = GameState.level + 1
    GameState.difficultyMultiplier = GameState.difficultyMultiplier * GameState.speedIncreasePerLevel
end

-- Start or switch background music
function GameState.playMusic(trackFile)
    if GameState.bgMusic and GameState.currentTrack == trackFile and GameState.enableMusic then
        if GameState.bgMusic.IsPlaying and not GameState.bgMusic:IsPlaying() then
            GameState.bgMusic:Play()
        end
        return
    end

    -- Stop previous track
    if GameState.bgMusic and GameState.enableMusic then
        GameState.bgMusic:Stop()
        GameState.bgMusic:Tick()
    end

    -- Load and play new track
    GameState.bgMusic = Audio.new(trackFile)
    GameState.currentTrack = trackFile

    if GameState.bgMusic and GameState.enableMusic then
        GameState.bgMusic:SetVolume(20)
        GameState.bgMusic:SetRepeat(true)
        GameState.bgMusic:Play()

        -- Flush audio commands
        GameState.bgMusic:Tick()
        GameState.bgMusic:Tick()
        GameState.bgMusic:Tick()
    end
end

function GameState.tickMusic()
    if GameState.bgMusic and GameState.enableMusic then
        GameState.bgMusic:Tick()
    end
end

function GameState.stopMusic()
    if GameState.bgMusic and GameState.enableMusic then
        GameState.bgMusic:Stop()
        GameState.bgMusic:Tick()
        GameState.bgMusic:Tick()
        GameState.bgMusic:Tick()
    end
end

function GameState.setVolumeMusic(volume)
    if GameState.bgMusic and GameState.enableMusic then
        GameState.bgMusic:SetVolume(volume)
        GameState.bgMusic:Tick()
        GameState.bgMusic:Tick()
        GameState.bgMusic:Tick()
    end
end

function GameState.setMusicToggle(toggle)
    GameState.enableMusic = toggle
    if GameState.bgMusic then
        if toggle then
            GameState.bgMusic:Play()
        else
            GameState.bgMusic:Stop()
        end
        GameState.bgMusic:Tick()
        GameState.bgMusic:Tick()
        GameState.bgMusic:Tick()
    end
end

function GameState.bankPoints()
    local earned = math.floor(GameState.score)
    GameState.points = GameState.points + earned

    GameState.saveGame()
end

function GameState.saveGame()
    SaveManager.save(GameState.points, GameState.equippedSkin, GameState.unlockedSkins)
end

-- Load saved data
local savedData = SaveManager.load()
if savedData then
    GameState.points = savedData.points
    GameState.equippedSkin = savedData.equippedSkin
    GameState.unlockedSkins = savedData.unlockedSkins
end

return GameState

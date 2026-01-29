-- Managers
local SceneManager = require("SL1M3/Managers/SceneManager")

-- Global Mouse State 
Mouse = {
    x = 0,          
    y = 0,          
    isDown = false, 
    wasPressed = false 
}

function Initialize()
    Engine.SetTitle("SL1M3 - Original Game")
    Engine.SetWidth(1280)
    Engine.SetHeight(720)
    
    -- Set starting scene
    SceneManager.setStartScene("SL1M3/Scenes/Menu")
end

function Tick(dt)
    local deltaTime = dt or 0.016
    
    -- Update current scene
    if SceneManager.currentScene and SceneManager.currentScene.update then
        SceneManager.currentScene.update(deltaTime)
    end
    
    -- Update scene transitions 
    SceneManager.update(deltaTime)
    
    -- Reset per-frame mouse press
    Mouse.wasPressed = false
end

function Paint()
    -- Draw the active scene
    if SceneManager.currentScene and SceneManager.currentScene.draw then
        SceneManager.currentScene.draw()
    end

    -- Draw transition overlays last (fade in/out)
    SceneManager.drawTransition()
end

function OnMouseMove(x, y)
    Mouse.x = x
    Mouse.y = y
end

function OnMouseButton(isLeft, isDown, x, y)
    if isLeft then
        Mouse.isDown = isDown
        if isDown then
            Mouse.wasPressed = true
        end
    end

    -- Always update mouse position on click
    Mouse.x = x
    Mouse.y = y
end

local SceneManager = {}

SceneManager.currentScene = nil
SceneManager.nextSceneName = nil
SceneManager.state = "IDLE"   
SceneManager.opacity = 0       
SceneManager.fadeSpeed = 600   

function SceneManager.loadScene(sceneName, isInstant)
    if isInstant then
        SceneManager.nextSceneName = sceneName
        SceneManager.switchScene(true) -- Skip fade-in
        return
    end

    -- Normal fade-out transition
    if SceneManager.state ~= "IDLE" then return end  -- Ignore if already fading
    SceneManager.nextSceneName = sceneName
    SceneManager.state = "FADE_OUT"
end

function SceneManager.update(dt)
    if SceneManager.state == "FADE_OUT" then
        SceneManager.opacity = SceneManager.opacity + (SceneManager.fadeSpeed * dt)
        if SceneManager.opacity >= 255 then
            SceneManager.opacity = 255
            SceneManager.switchScene(false) -- Normal fade-in after switch
        end

    elseif SceneManager.state == "FADE_IN" then
        SceneManager.opacity = SceneManager.opacity - (SceneManager.fadeSpeed * dt)
        if SceneManager.opacity <= 0 then
            SceneManager.opacity = 0
            SceneManager.state = "IDLE"
        end
    end
end

function SceneManager.setStartScene(sceneName)
    package.loaded[sceneName] = nil          -- Clear require cache
    SceneManager.currentScene = require(sceneName)
    if SceneManager.currentScene and SceneManager.currentScene.load then
        SceneManager.currentScene.load()
    end
end

function SceneManager.switchScene(isInstant)
    -- Unload previous scene
    if SceneManager.currentScene and SceneManager.currentScene.unload then
        SceneManager.currentScene.unload()
    end

    -- Load new scene
    package.loaded[SceneManager.nextSceneName] = nil
    SceneManager.currentScene = require(SceneManager.nextSceneName)
    if SceneManager.currentScene and SceneManager.currentScene.load then
        SceneManager.currentScene.load()
    end

    if isInstant then
        SceneManager.state = "IDLE"
        SceneManager.opacity = 0
    else
        SceneManager.state = "FADE_IN"
    end
end

function SceneManager.drawTransition()
    if SceneManager.opacity > 0 then
        Engine.SetColor(0, 0, 0)
        if Engine.FillRectAlpha then
            Engine.FillRectAlpha(0, 0, 1280, 720, math.floor(SceneManager.opacity))
        else
            -- Fallback if alpha not supported
            if SceneManager.opacity > 128 then
                Engine.FillRect(0, 0, 1280, 720)
            end
        end
    end
end

return SceneManager

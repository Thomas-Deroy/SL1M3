
-- Components
local TrailComponent = require("SL1M3/Components/TrailComponent")
local ScaleRandomizerComponent = require("SL1M3/Components/ScaleRandomizerComponent")

local EffectManager = {}

-- Variables
local targetPlayer = nil     
local activeEffects = {}      

function EffectManager.init(player)
    targetPlayer = player
    activeEffects = {}
end

function EffectManager.trigger(effectName, duration, props)
    if not targetPlayer then 
        return 
    end
    props = props or {}

    -- Trail effect
    if effectName == "trail" then
        local existing = targetPlayer:getComponent("trail")
        
        targetPlayer:getComponent("input").maxSpeed = 7 -- Boost speed for trail
        
        if not existing then
            local tComp = TrailComponent.new(
                props.interval or 0.05, 
                props.lifetime or 0.2, 
                props.alpha or 150,
                props.scaleX or 2.0,
                props.scaleY or 2.0
            )
            targetPlayer:addComponent("trail", tComp)
        end
        activeEffects["trail"] = duration

    -- Scalar effect
    elseif effectName == "scaler" then
        local existing = targetPlayer:getComponent("scaler")
        
        targetPlayer:getComponent("input").maxSpeed = 3 -- Slow down while scaling
        
        if not existing then
            local sComp = ScaleRandomizerComponent.new(duration)
            targetPlayer:addComponent("scaler", sComp)
        else
            -- Extend or reactivate existing effect
            existing.duration = existing.duration + duration
            existing.timer = 0
            existing.active = true
        end
        
        activeEffects["scaler"] = duration
    end
end

function EffectManager.update(dt)
    for name, timer in pairs(activeEffects) do
        activeEffects[name] = timer - dt
        if activeEffects[name] <= 0 then
            EffectManager.removeEffect(name)
        end
    end
end

function EffectManager.removeEffect(name)
    if not targetPlayer then 
        activeEffects[name] = nil
        return 
    end

    if name == "trail" then
        local input = targetPlayer:getComponent("input")
        if input then 
            input.maxSpeed = 5 
        end
        
        if targetPlayer.removeComponent then targetPlayer:removeComponent("trail") end
        
    elseif name == "scaler" then
        local input = targetPlayer:getComponent("input")
        if input then 
            input.maxSpeed = 5 
        end

        local comp = targetPlayer:getComponent("scaler")
        if comp and comp.restore then comp:restore() end
        if targetPlayer.removeComponent then targetPlayer:removeComponent("scaler") end
    end

    activeEffects[name] = nil -- Clear from active list
end

function EffectManager.clear()
    targetPlayer = nil
    activeEffects = {}
end

return EffectManager

local ScoreManager = {}

ScoreManager.filePath = "SL1M3/Assets/highscores.json"

function ScoreManager.loadScores()
    local file = io.open(ScoreManager.filePath, "r")
    if not file then return {} end  -- File missing -> return empty list

    local content = file:read("*all")
    file:close()
    
    local scores = {}
    for num in string.gmatch(content, "(%d+)") do
        table.insert(scores, tonumber(num))
    end
    
    return scores
end

function ScoreManager.saveScore(newScore)
    local scores = ScoreManager.loadScores()
    
    -- Add the new score (rounded down)
    table.insert(scores, math.floor(newScore))
    
    -- Sort descending (highest first)
    table.sort(scores, function(a, b) return a > b end)
    
    -- Keep only top 3
    while #scores > 3 do
        table.remove(scores)
    end
    
    -- Write to file in JSON-like format
    local file = io.open(ScoreManager.filePath, "w+")
    if file then
        file:write("[\n")
        for i, s in ipairs(scores) do
            if i < #scores then
                file:write("  " .. s .. ",\n")
            else
                file:write("  " .. s .. "\n")
            end
        end
        file:write("]")
        file:close()
    end
end

return ScoreManager

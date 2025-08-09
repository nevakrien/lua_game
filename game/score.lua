score = 0  -- global integer score

local font = love.graphics.newFont(32)
local SAVE_FILE = "score.txt"

function add_score(points)
    score = math.floor(score + points) -- ensure integer increments
end

function reset_score()
    score = 0
end

function draw_score()
    love.graphics.setFont(font)

    -- Draw shadow for readability
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.print("Score: " .. score, 12, 12)

    -- Draw main text
    love.graphics.setColor(1, 1, 0.87)
    love.graphics.print("Score: " .. score, 10, 10)
end

-- Save current score to disk (returns ok, err)
function save_score(filename)
    filename = filename or SAVE_FILE
    return love.filesystem.write(filename, tostring(score))
end

-- Load score from disk (returns ok, err)
function load_score(filename)
    filename = filename or SAVE_FILE
    if not love.filesystem.getInfo(filename) then
        return false, "no save"
    end
    local contents, err = love.filesystem.read(filename)
    if not contents then return false, err end
    local n = tonumber(contents)
    if not n then return false, "corrupt save" end
    score = math.floor(n)
    return true
end
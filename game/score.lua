score = 0  -- global integer score

local font = love.graphics.newFont(32)

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

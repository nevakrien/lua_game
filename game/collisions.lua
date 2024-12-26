collisions = {}

local colLifetime = 0.2
dummy_texture = love.graphics.newCanvas(1, 1)

function beginContact(a, b, coll)
    local x, y = coll:getPositions()
    table.insert(collisions, {x = x, y = y,time=love.timer.getTime()})
end


function update_collisions()
    local currentTime = love.timer.getTime()
    for i = #collisions, 1, -1 do
        if currentTime - collisions[i].time > colLifetime then -- 2 seconds lifetime
            table.remove(collisions, i)
        end
    end
end

function render_collisions()
    love.graphics.setShader(collisionShader)
    
    for _, point in ipairs(collisions) do
        -- Draw a rectangle with the shader
        local size = 24 -- Adjust size for the circle
        
        -- Send t to the shader
        local elapsedTime = love.timer.getTime() - point.time
        local t = math.min(elapsedTime / colLifetime, 1.0) -- Clamp t between 0 and 1
        collisionShader:send("t", t)

        -- Draw
        love.graphics.push()
        love.graphics.translate(point.x, point.y)
        love.graphics.draw(dummy_texture, -size / 2, -size / 2, 0, size, size)
        love.graphics.pop()
    end

    love.graphics.setShader() -- Reset shader
end

collisions = {}

local colLifetime = 0.2
dummy_texture = love.graphics.newCanvas(1, 1)

function beginContact(a, b, coll)
    local x, y = coll:getPositions()
    
    -- Get velocities of both bodies
    local vx1, vy1 = a:getBody():getLinearVelocity()
    local vx2, vy2 = b:getBody():getLinearVelocity()
    
    -- Calculate relative velocity
    local relVx = vx2 - vx1
    local relVy = vy2 - vy1
    
    -- Get collision normal
    local nx, ny = coll:getNormal()
    
    -- Project relative velocity onto the collision normal
    local strength = math.abs(relVx * nx + relVy * ny)
    
    -- Store collision data
    table.insert(collisions, {x = x, y = y, time = love.timer.getTime(), strength = strength})
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
    
    for _, col in ipairs(collisions) do
        -- Draw a rectangle with the shader
        local size = 5+(14/100)*math.min(100,col.strength);
        
        -- Send t to the shader
        local elapsedTime = love.timer.getTime() - col.time
        local t = math.min(elapsedTime / colLifetime, 1.0) -- Clamp t between 0 and 1
        collisionShader:send("t", t)

        -- Draw
        love.graphics.push()
        love.graphics.translate(col.x, col.y)
        love.graphics.draw(dummy_texture, -size / 2, -size / 2, 0, size, size)
        love.graphics.pop()
    end

    love.graphics.setShader() -- Reset shader
end

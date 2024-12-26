collisions = {}
StartCol = {}

local colLifetime = 0.2--10--0.2
dummy_texture = love.graphics.newCanvas(1, 1)


function get_key(a,b)
    return tostring(a) .. "-" .. tostring(b)
end

function beginContact(a, b, coll)
    StartCol[get_key(a,b)] = true
end

function postSolve(a, b, contact, normalImpulse1, tangentImpulse1, normalImpulse2, tangentImpulse2)
    if not StartCol[get_key(a,b)] then 
        -- If this pair didn't contact this frame, ignore it
        return
    end

    -- Combine the impulses from the two contact points (if they exist)
    local totalNormalImpulse = (normalImpulse1 or 0) + (normalImpulse2 or 0)
    local totalTangentImpulse = (tangentImpulse1 or 0) + (tangentImpulse2 or 0)

    -- Calculate the total collision strength
    -- local strength = math.sqrt(totalNormalImpulse^2 + totalTangentImpulse^2)
    local strength = math.sqrt(totalNormalImpulse^2)

    -- Get the collision position (if needed for debugging or visualization)
    local x, y = contact:getPositions()
    local seed = math.random()

    -- Store the collision data with strength
    table.insert(collisions, {x = x, y = y, time = love.timer.getTime(), strength = strength,seed=seed})
end




function update_collisions()
    StartCol = {}
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
        local size = 5+0.14*col.strength;

        -- size = size*2
        -- local size = 5+(14/100)*math.min(100,col.strength);
        
        -- Send t to the shader
        local elapsedTime = love.timer.getTime() - col.time
        local t = math.min(elapsedTime / colLifetime, 1.0) -- Clamp t between 0 and 1
        local strength = math.min(0.14*col.strength,1)
        
        collisionShader:send("t", t)
        collisionShader:send("seed", col.seed)
        collisionShader:send("strength", col.seed)
        -- collisionShader:send("strength", col.strength)

        -- Draw
        love.graphics.push()
        love.graphics.translate(col.x, col.y)
        love.graphics.draw(dummy_texture, -size / 2, -size / 2, 0, size, size)
        love.graphics.pop()
    end

    love.graphics.setShader() -- Reset shader
end

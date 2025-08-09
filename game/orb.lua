allOrbs = {}

function clear_world()
    clear_collisions()
    allOrbs = {}
    if world then
        world.destroy(world)
    end

    love.physics.setMeter(30)
    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact, nil, nil, postSolve)
    add_walls(world)
    
end

function make_world()
    love.physics.setMeter(30)
    world = love.physics.newWorld(0, 0, true)
    -- world:setCallbacks(beginContact)
    world:setCallbacks(beginContact, nil, nil, postSolve)

    add_walls(world)


    add_basic_orb(world,100,100)
    add_basic_orb(world,0,10)

    add_rectangle_orb(world, 40*aspectRatio,43, 33,  11)
    add_triangle_orb(world,100,0,30)
    add_triangle_orb(world,100,0,7)
    add_triangle_orb(world,100,0,7)
    add_triangle_orb(world,100,0,7)
end

function add_walls(world)
    -- Thickness of the walls
    local wallThickness = 1000

    -- Add bounding box rectangles (static physics objects)
    -- Bottom wall
    add_static_wall(world, worldWidth / 2, worldHeight + wallThickness / 2, worldWidth + 2 * wallThickness, wallThickness)

    -- Top wall
    add_static_wall(world, worldWidth / 2, -wallThickness / 2, worldWidth + 2 * wallThickness, wallThickness)

    -- Left wall
    add_static_wall(world, -wallThickness / 2, worldHeight / 2, wallThickness, worldHeight)

    -- Right wall
    add_static_wall(world, worldWidth + wallThickness / 2, worldHeight / 2, wallThickness, worldHeight)
end

function add_static_wall(world, x, y, width, height)
    -- Create a static physics body and shape
    local body = love.physics.newBody(world, x, y, "static")
    local shape = love.physics.newRectangleShape(width, height)
    local fixture = love.physics.newFixture(body, shape, 1)

    -- Optionally set other properties, such as friction or restitution, if needed
    fixture:setRestitution(0.0) -- No bounce
end

function add_basic_orb(world,x,y)
	local radius = 5

    -- Correcting the orb table definition
    local orb = {
        type = "orb",
    }

    -- Create physics body and shape
    orb.body = love.physics.newBody(world, x, y, "dynamic")
    orb.shape = love.physics.newCircleShape(radius)
    orb.fixture = love.physics.newFixture(orb.body, orb.shape, 1)
    orb.fixture:setRestitution(0.93)
    --orb.fixture:setFriction(1.0)
    orb.body:setBullet(true)


    -- Define the render closure
    orb.render = function(orb)
        love.graphics.setColor({0.3, 1.0, 0.3}) -- Set the orb's color
        love.graphics.circle("fill", 0 , 0 ,radius)
    end

    -- Assign the orb as user data to the body
    orb.body:setUserData(orb)
    table.insert(allOrbs, orb)
end

function add_rectangle_orb(world, x, y, width, height)
    local orb = {
        type = "rectangle_orb",
        height=height,
        width=width,
    }

    -- Create physics body and shape
    orb.body = love.physics.newBody(world, x, y, "dynamic") -- Static for simplicity
    orb.shape = love.physics.newRectangleShape(width, height)
    orb.fixture = love.physics.newFixture(orb.body, orb.shape, 1)
    orb.fixture:setRestitution(0.8)
    --orb.fixture:setFriction(1.0)

    orb.body:setBullet(true)


    -- Define the render closure
    orb.render = function(orb)
        love.graphics.setColor(1.0, 0.3, 0.3) -- Set the orb's color
        -- Draw the rectangle at its position and angle

        love.graphics.rectangle("fill", -width / 2, -height / 2, width, height)
    end

    -- Assign the orb as user data to the body
    orb.body:setUserData(orb)
    table.insert(allOrbs, orb)
end

function add_triangle_orb(world, x, y, side_length)
    local orb = {
        type = "triangle_orb",
        side_length=side_length,
    }

    -- Calculate the vertices of the equilateral triangle
    local height = (math.sqrt(3) / 2) * side_length
    local vertices = {
        0, -height *2/ 3,              -- Top vertex
        -side_length / 2, height / 3,  -- Bottom left vertex
        side_length / 2, height  / 3    -- Bottom right vertex
    }

    -- Create physics body and shape
    orb.body = love.physics.newBody(world, x, y, "dynamic")
    orb.shape = love.physics.newPolygonShape(vertices)
    orb.fixture = love.physics.newFixture(orb.body, orb.shape, 1)
    orb.fixture:setRestitution(0.8)
    --orb.fixture:setFriction(1.0)
    
    orb.body:setBullet(true)

    -- Define the render closure
    orb.render = function(orb)
        love.graphics.setColor(0.1, 0.2, 0.8) -- Set the orb's color (darkish blue)
        
        -- Draw the triangle at its position and angle
        love.graphics.polygon("fill", vertices)
    end

    -- Assign the orb as user data to the body
    orb.body:setUserData(orb)
    table.insert(allOrbs, orb)
end



function render_orbs(orbs)
	for _, orb in ipairs(orbs) do
        love.graphics.push()
            local x, y = orb.body:getPosition()
            local angle = orb.body:getAngle()
            love.graphics.translate(x, y)
            love.graphics.rotate(angle)
            
            orb.render(orb)
        love.graphics.pop()

	end
end

function queryOne(world, x1, y1, x2, y2)
    local ans = nil

    local function callback(fixture)
    	ans = fixture:getBody():getUserData()
        return ans == nil --look until ans!=nil
    end

    world:queryBoundingBox(x1, y1, x2, y2, callback)

    return ans
end

function debug_orb(orb)
    if not orb or not orb.body then
        print("Error: Orb or its body is nil.")
        return
    end

    local body = orb.body
    local orbX, orbY = body:getPosition() -- Get current position
    local velocityX, velocityY = body:getLinearVelocity() -- Get current velocity
    local speed = math.sqrt(velocityX^2 + velocityY^2) -- Calculate speed

    -- Debug Information
    print("=== Orb Debug Info ===")
    print(string.format("Position: (%.2f, %.2f)", orbX, orbY))
    print(string.format("Velocity: (%.2f, %.2f)", velocityX, velocityY))
    print(string.format("Speed: %.2f", speed))
    print(string.format("Body Type: %s", body:getType()))
    print("======================")
end


function select_orb(orb)
	if orb ~=nil then 
		orb.body:setType("dynamic")
    	orb.body:setLinearDamping(100) -- Apply damping for friction/decay
    	-- orb.fixture:setFriction(100) -- Apply damping for friction/decay
	end
end

function unselect_orb(orb)
	if orb ~=nil then 
		orb.body:setType("dynamic")
		orb.body:setLinearDamping(0) -- Apply damping for friction/decay
    	-- orb.fixture:setFriction(0) -- Apply damping for friction/decay
	end
end

-- Function to drag the orb toward a target (x, y)
function drag_orb(world, orb, x, y,dt)
    local body = orb.body
    local orbX, orbY = body:getPosition() -- Get current position

    -- Calculate direction vector to the target
    local dx = x - orbX
    local dy = y - orbY
    local distance = math.sqrt(dx * dx + dy * dy)

    local mass = body:getMass()
    local impulse = dt*700*(mass+0.7)
    body:applyLinearImpulse(dx * impulse, dy * impulse)

    -- debug_orb(orb)
end

function delete_orb(orb)
    if orb then
        if selectedOrb == orb then
            selectedOrb = nil
        end
        -- Remove the orb from the world
        if orb.body then
            orb.body:destroy()  -- Destroy the physics body and its fixtures
        end
        
        -- Remove the orb from the allOrbs table
        for i, existingOrb in ipairs(allOrbs) do
            if existingOrb == orb then
                table.remove(allOrbs, i)
                break
            end
        end
    end
end

-- Save the state of all orbs to a file (includes angular velocity)
function save_world(filename)
    local file = love.filesystem.newFile(filename)
    local ok, err = file:open("w")
    if not ok then
        print("Failed to open file for saving:", err)
        return
    end

    for _, orb in ipairs(allOrbs) do
        local x, y = orb.body:getPosition()
        local vx, vy = orb.body:getLinearVelocity()
        local angle  = orb.body:getAngle()
        local av     = orb.body:getAngularVelocity()
        local t      = orb.type

        local line
        if t == "orb" then
            -- type,x,y,vx,vy,angle,angvel
            line = string.format("%s,%f,%f,%f,%f,%f,%f\n", t, x, y, vx, vy, angle, av)
        elseif t == "rectangle_orb" then
            -- type,x,y,vx,vy,angle,angvel,width,height
            line = string.format("%s,%f,%f,%f,%f,%f,%f,%f,%f\n", t, x, y, vx, vy, angle, av, orb.width, orb.height)
        elseif t == "triangle_orb" then
            -- type,x,y,vx,vy,angle,angvel,side_length
            line = string.format("%s,%f,%f,%f,%f,%f,%f,%f\n", t, x, y, vx, vy, angle, av, orb.side_length)
        end

        if line then file:write(line) end
    end

    file:close()
    print("Orb state saved successfully!")
end


-- Load the orb state from a file, with fallback to make_world() on failure
function load_world(filename)
    local info = love.filesystem.getInfo(filename)
    if not info then
        print("No saved orb state found.")
        return false
    end

    local file = love.filesystem.newFile(filename)
    local ok, err = file:open("r")
    if not ok then
        print("Failed to open file for loading:", err)
        return false
    end

    -- start fresh
    clear_world()

    function error_out()
        clear_world()
        return false
    end

    local loaded = 0

    local function split_csv(line)
        local t = {}
        for part in line:gmatch("([^,]+)") do t[#t+1] = part end
        return t
    end

    for line in file:lines() do
        local p = split_csv(line)
        local typ = p[1]

        if typ == "orb" then
            -- type,x,y,vx,vy,angle,angvel
            if #p ~= 7 then file:close(); return error_out() end
            local x  = tonumber(p[2]); local y  = tonumber(p[3])
            local vx = tonumber(p[4]); local vy = tonumber(p[5])
            local ang = tonumber(p[6]); local angvel = tonumber(p[7])
            if not (x and y and vx and vy and ang and angvel) then file:close(); return error_out() end

            add_basic_orb(world, x, y)
            local orb = allOrbs[#allOrbs]; if not orb then file:close(); return error_out() end
            orb.body:setPosition(x, y)
            orb.body:setLinearVelocity(vx, vy)
            orb.body:setAngle(ang)
            orb.body:setAngularVelocity(angvel)
            orb.body:setAwake(true)
            loaded = loaded + 1

        elseif typ == "rectangle_orb" then
            -- type,x,y,vx,vy,angle,angvel,width,height
            if #p ~= 9 then file:close(); return error_out() end
            local x  = tonumber(p[2]); local y  = tonumber(p[3])
            local vx = tonumber(p[4]); local vy = tonumber(p[5])
            local ang = tonumber(p[6]); local angvel = tonumber(p[7])
            local w  = tonumber(p[8]); local h  = tonumber(p[9])
            if not (x and y and vx and vy and ang and angvel and w and h) then file:close(); return error_out() end

            add_rectangle_orb(world, x, y, w, h)
            local orb = allOrbs[#allOrbs]; if not orb then file:close(); return error_out() end
            orb.body:setPosition(x, y)
            orb.body:setLinearVelocity(vx, vy)
            orb.body:setAngle(ang)
            orb.body:setAngularVelocity(angvel)
            orb.body:setAwake(true)
            loaded = loaded + 1

        elseif typ == "triangle_orb" then
            -- type,x,y,vx,vy,angle,angvel,side_length
            if #p ~= 8 then file:close(); return error_out() end
            local x  = tonumber(p[2]); local y  = tonumber(p[3])
            local vx = tonumber(p[4]); local vy = tonumber(p[5])
            local ang = tonumber(p[6]); local angvel = tonumber(p[7])
            local side = tonumber(p[8])
            if not (x and y and vx and vy and ang and angvel and side) then file:close(); return error_out() end

            add_triangle_orb(world, x, y, side)
            local orb = allOrbs[#allOrbs]; if not orb then file:close(); return error_out() end
            orb.body:setPosition(x, y)
            orb.body:setLinearVelocity(vx, vy)
            orb.body:setAngle(ang)
            orb.body:setAngularVelocity(angvel)
            orb.body:setAwake(true)
            loaded = loaded + 1

        else
            -- unknown type in new format
            file:close(); return error_out()
        end
    end

    file:close()
    if loaded == 0 then return error_out() end

    print("Orb state loaded successfully!", loaded, "orbs")
    return true
end
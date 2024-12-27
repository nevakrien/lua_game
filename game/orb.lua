local collisions_mod = require("collisions")
local trail_mod = require("trail")

allOrbs = {}

function make_world()
    love.physics.setMeter(30)
    local world = love.physics.newWorld(0, 0, true)
    -- world:setCallbacks(beginContact)
    world:setCallbacks(beginContact, nil, nil, postSolve)

    add_walls(world)


    add_basic_orb(world,100,100)
    add_basic_orb(world,0,10)

    add_rectangle_orb(world, 40*aspectRatio,43, 30,  10)
    add_triangle_orb(world,100,0,30)


    return world
end

function add_walls(world)
    -- Thickness of the walls
    local wallThickness = 10

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
    orb.fixture:setRestitution(0.8)
    orb.body:setBullet(true)

    orb.mesh =create_circle_mesh(2*radius, 100)


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
    }

    -- Create physics body and shape
    orb.body = love.physics.newBody(world, x, y, "dynamic") -- Static for simplicity
    orb.shape = love.physics.newRectangleShape(width, height)
    orb.fixture = love.physics.newFixture(orb.body, orb.shape, 1)
    orb.fixture:setRestitution(0.8)
    orb.body:setBullet(true)

    local big = math.max(width,height)
    orb.mesh = create_rectangle_mesh(width+big, height+big)


    -- Define the render closure
    orb.render = function(orb)
        love.graphics.setColor(1.0, 0.3, 0.3)
        love.graphics.rectangle("fill", -width / 2, -height / 2, width, height)
    end

    -- Assign the orb as user data to the body
    orb.body:setUserData(orb)
    table.insert(allOrbs, orb)
end

function add_triangle_orb(world, x, y, side_length)
    local orb = {
        type = "triangle_orb",
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
    orb.body:setBullet(true)

    
    -- orb.mesh = create_triangle_mesh(2*side_length)
    orb.mesh = create_circle_mesh(side_length,100)

    -- Define the render closure
    orb.render = function(orb)
        love.graphics.setColor(0.1, 0.2, 0.8) 
        love.graphics.polygon("fill", vertices)
    end

    -- Assign the orb as user data to the body
    orb.body:setUserData(orb)
    table.insert(allOrbs, orb)
end



function render_orbs(orbs)
    local t = love.timer.getTime() - startTime

	for i, orb in ipairs(orbs) do
        love.graphics.push()
        
        local x, y = orb.body:getPosition() -- Get the current position of the orb
        local angle = orb.body:getAngle()  -- Get the current rotation of the orb
        love.graphics.translate(x, y)
        love.graphics.rotate(angle)
	    
        orb.render(orb)
        -- love.graphics.setColor({1.0, 1.0, 1.0,0.5})
        love.graphics.setShader(speedShader)
        local vx,vy = orb.body:getLinearVelocity()
        speedShader:send("speed", {vx,vy})
        speedShader:send("angular", orb.body:getAngularVelocity())
        speedShader:send("t", t)
        speedShader:send("seed", math.abs(math.sin(100*i)))


        love.graphics.draw(orb.mesh)
        love.graphics.setShader()

        
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
    local impulse = dt*700*(mass+0.4)
    body:applyLinearImpulse(dx * impulse, dy * impulse)

    -- debug_orb(orb)
end
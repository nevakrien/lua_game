allOrbs = {}

function make_world()
    local world = love.physics.newWorld(0, 0, true)
    add_basic_orb(world,100,100)
    add_basic_orb(world,0,10)
    

    -- print(allOrbs[1]["type"])

    return world
end

function add_basic_orb(world,x,y)
	local radius = 5

    -- Correcting the orb table definition
    local orb = {
        type = "orb",
    }

    -- Create physics body and shape
    orb.body = love.physics.newBody(world, x, y, "static")
    orb.shape = love.physics.newCircleShape(radius)
    orb.fixture = love.physics.newFixture(orb.body, orb.shape, 1)



    -- Define the render closure
    orb.render = function(orb)
        local x, y = orb.body:getPosition() -- Get current position of the orb
        love.graphics.setColor({0.3, 1.0, 0.3}) -- Set the orb's color
        love.graphics.circle("fill", x , y ,radius)
    end

    -- Assign the orb as user data to the body
    orb.body:setUserData(orb)
    table.insert(allOrbs, orb)
end

function render_orbs(orbs)
	for _, orb in ipairs(orbs) do
	    orb.render(orb)
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
    	orb.fixture:setFriction(100) -- Apply damping for friction/decay
	end
end

function unselect_orb(orb)
	if orb ~=nil then 
		orb.body:setType("static")
		orb.body:setLinearDamping(0) -- Apply damping for friction/decay
    	orb.fixture:setFriction(0) -- Apply damping for friction/decay
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

    local impulse = dt*750
    body:applyLinearImpulse(dx * impulse, dy * impulse)

    debug_orb(orb)
end
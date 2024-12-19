allOrbs = {}

function make_world()
    world = love.physics.newWorld(0, 0, true)

    local radius = 5

    -- Correcting the orb table definition
    local orb = {
        type = "orb",
    }

    -- Create physics body and shape
    orb.body = love.physics.newBody(world, 100, 100, "static")
    orb.shape = love.physics.newCircleShape(radius)
    orb.fixture = love.physics.newFixture(orb.body, orb.shape, 1)

    -- Define the render closure
    orb.render = function()
        local x, y = orb.body:getPosition() -- Get current position of the orb
        love.graphics.setColor({0.3, 1.0, 0.3}) -- Set the orb's color
        love.graphics.circle("fill", x , y ,radius)
    end

    -- Assign the orb as user data to the body
    orb.body:setUserData(orb)
    table.insert(allOrbs, orb)

    -- print(allOrbs[1]["type"])

    return world
end

function render_orbs(orbs)
	for _, orb in ipairs(orbs) do
	    orb.render()
	end
end

function queryOne(world, x1, y1, x2, y2)
    local ans = nil

    local function callback(fixture)
    	ans = fixture:getBody():getUserData()
        return ans == nil
    end

    world:queryBoundingBox(x1, y1, x2, y2, callback)

    return ans
end
function create_rectangle_mesh(width, height)
    return love.graphics.newMesh({
        {-width / 2, -height / 2}, -- Top-left
        { width / 2, -height / 2}, -- Top-right
        { width / 2,  height / 2}, -- Bottom-right
        {-width / 2,  height / 2}, -- Bottom-left
    }, "fan")
end

function create_triangle_mesh(side_length)
    local height = (math.sqrt(3) / 2) * side_length
    return love.graphics.newMesh({
        {0, -height * 2 / 3},                -- Top vertex
        {-side_length / 2, height / 3},     -- Bottom-left
        { side_length / 2, height / 3},     -- Bottom-right
    }, "fan")
end


function create_circle_mesh(radius, segments)
    local vertices = {}
    for i = 0, segments do
        local angle = (i / segments) * math.pi * 2
        local x = math.cos(angle) * radius
        local y = math.sin(angle) * radius
        table.insert(vertices, {x, y})
    end
    return love.graphics.newMesh(vertices, "fan")
end


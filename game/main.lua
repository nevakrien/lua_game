-- love2d_scale_setup/main.lua

local rectWidth, rectHeight = 0.125, 0.0625 -- Dimensions of the rectangle as fractions of height
local aspectRatio = 4 / 3 -- Default aspect ratio (can be changed dynamically)

function love.load()
    love.window.setTitle("Love2D Window Resize with Aspect Ratio")
    love.window.setMode(800, 600, {resizable = true, minwidth = 400, minheight = 300})
    love.graphics.setBackgroundColor(0.0, 0.0, 0.0)
    love.mouse.setVisible(false) -- Hide the default cursor
end

-- function love.resize(w, h)
--     print("Window resized to:", w, h)
-- end
function main_render()
    -- Draw a rectangle centered at the normalized coordinates
    love.graphics.translate(0.5 * aspectRatio, 0.5) -- Center relative to normalized coordinate space (0-aspectRatio, 0-1)
    love.graphics.setColor(0.8, 0.3, 0.3)
    love.graphics.rectangle("fill", -rectWidth / 2, -rectHeight / 2, rectWidth, rectHeight)
end

function love.draw()
    local windowWidth, windowHeight = love.graphics.getDimensions()

    -- Calculate the scale factor based on the smaller dimension to maintain aspect ratio
    local scaleFactor = math.min(windowWidth / aspectRatio, windowHeight)
    local targetWidth = scaleFactor * aspectRatio
    local targetHeight = scaleFactor

    -- Center the content in the window
    local offsetX = (windowWidth - targetWidth) / 2
    local offsetY = (windowHeight - targetHeight) / 2

    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scaleFactor, scaleFactor)
    
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, 4/3, 1)

    main_render()
    

    love.graphics.pop()

    -- Draw a custom cursor (blue circle) that respects scaling
    local mouseX, mouseY = love.mouse.getPosition()
    local normalizedMouseX = (mouseX - offsetX) / scaleFactor
    local normalizedMouseY = (mouseY - offsetY) / scaleFactor

    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scaleFactor, scaleFactor)
    love.graphics.setColor(0.2, 0.4, 0.8)
    love.graphics.circle("fill", normalizedMouseX, normalizedMouseY, 0.02) -- Circle size as fraction of height
    love.graphics.pop()

    -- Draw instructions
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Resize the window to see scaling with constant aspect ratio", 10, 10)
end

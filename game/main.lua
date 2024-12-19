-- love2d_scale_setup/main.lua
-- Determine if the platform is mobile
isMobile = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
dragX,dragY = -1,-1

local input = require("input")
aspectRatio = 16 / 9 -- Default aspect ratio (can be changed dynamically)
canvas = nil


function love.load()
    love.window.setTitle("Love2D Window Resize with Aspect Ratio")
    if isMobile then
        _ = love.window.setFullscreen(true)
    else
        love.window.setMode(800, 450, {resizable = true, minwidth = 16 * 40, minheight = 9 * 40})
    end
    love.graphics.setBackgroundColor(0.0, 0.0, 0.0)
    love.mouse.setVisible(false) -- Hide the default cursor

    remake_canvas()
end

function remake_canvas() 
    windowWidth, windowHeight = love.graphics.getDimensions()

    -- Calculate the scale factor based on the smaller dimension to maintain aspect ratio
    scaleFactor = math.min(windowWidth / aspectRatio, windowHeight)
    targetWidth = scaleFactor * aspectRatio
    targetHeight = scaleFactor

    canvas = love.graphics.newCanvas(targetWidth, targetHeight)

    offsetX = (windowWidth - targetWidth) / 2
    offsetY = (windowHeight - targetHeight) / 2

    dragX = (screenDragX - offsetX) / scaleFactor
    dragY = (screenDragY - offsetY) / scaleFactor
end

function love.resize(w, h)
    print("Window resized to width: " .. w .. " and height: " .. h)
    remake_canvas()
end


function love.update(dt)
    -- Regularly "poke" the system to prevent sleep
    love.event.pump()
end

function main_render()

    -- Draw a rectangle centered at the normalized coordinates
    love.graphics.setColor(0.8, 0.3, 0.3)
    love.graphics.rectangle("fill", 0.4*aspectRatio,0.43, 0.3,  0.1)


    -- love.graphics.setColor(0.7, 0.4, 0.3)
    -- love.graphics.rectangle("fill", 0.5, 0.5, aspectRatio,0.3)


    love.graphics.setColor(0.3, 1.0, 0.3)
    love.graphics.circle("fill", dragX, dragY, 0.05) -- Circle size as fraction of height

end

function love.draw()
    -- Dynamically create a canvas matching the current screen size
    -- local canvas = love.graphics.newCanvas(targetWidth, targetHeight)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.1, 0.1, 0.1, 1)

    -- Draw content to the canvas with proper scaling
    love.graphics.push()
    love.graphics.scale(scaleFactor, scaleFactor) -- Scale canvas contents to its normalized size (0-aspectRatio, 0-1)
    love.graphics.push()
    
    main_render()
    love.graphics.pop()
    love.graphics.pop()

    -- Unset the canvas
    love.graphics.setCanvas()
    love.graphics.setColor(1.0,1.0,1.0)


    -- Center the canvas on the screen
    love.graphics.draw(canvas, offsetX, offsetY)

    if not isMobile then
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
    end
end


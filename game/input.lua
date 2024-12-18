isDragging = false
screenDragX, screenDragY = 0, 0


function drag_start(x, y)
    screenDragX, screenDragY = x, y

    --could be more delibrate here
    isDragging = true
    -- print("Drag started at:", x, y)
end


-- Function to handle dragging (update position)
function drag_handle(x, y)
    screenDragX, screenDragY = x, y
end

-- Function to handle releasing a drag
function drag_release(x, y)
    screenDragX, screenDragY = x, y

    if isDragging then
        isDragging = false
        -- print("Drag released at:", x, y)
    end
end

-- Input functions
function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        drag_start(x, y)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        drag_release(x, y)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if isDragging then
        drag_handle(x, y)
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    drag_start(x, y)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    drag_release(x, y)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if isDragging then
        drag_handle(x, y)
    end
end

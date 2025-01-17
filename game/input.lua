isPressing = false
screenDragX, screenDragY = 0, 0

selectedOrb = nil

if isMobile then
    touches = {}
end

function drag_start(world,x, y)
    update_drag(x, y)


    --could be more delibrate here
    isPressing = true
    selectedOrb = queryOne(world,dragX-0.01,dragY-0.01,dragX+0.01,dragY+0.01)
    select_orb(selectedOrb)
    
    print("selected orb", selectedOrb)

    drag_handle(world,x,y)
end

-- Function to handle dragging (update position)
function update_drag(x, y)
    screenDragX, screenDragY = x, y

    dragX = (screenDragX - offsetX) / scaleFactor
    dragY = (screenDragY - offsetY) / scaleFactor
end

-- Function to handle dragging (update position)
function drag_handle(world,x, y)
    update_drag(x, y)
end

-- Function to handle releasing a drag
function drag_release(world,x, y)
    update_drag(x, y)
    unselect_orb(selectedOrb)

    selectedOrb = nil 
    isPressing = false
end

-- Input functions
function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        drag_start(world,x, y)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        drag_release(world,x, y)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if isPressing then
        drag_handle(world,x, y)
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    drag_start(world,x, y)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    drag_release(world,x, y)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if isPressing then
        drag_handle(world,x, y)
    end
end

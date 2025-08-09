local menu = {}

-- Menu state variables
local options = pauseOptions  -- Default to pauseOptions
local selectedOption = 1
local hoverOption = 1
local optionHeight = 40
local undoStack = {}  -- Stack to store the history of active menus

local cols = require("collisions")

local explosionsOptions = {
    {name = "Small", action = function() ColstrenghMul=1 end},
    {name = "Normal", action = function() ColstrenghMul=2 end},
    {name = "Big", action = function() ColstrenghMul=3 end},
    {name = "Absurd", action = function() ColstrenghMul=10 end},
    {name = "Back", action = function() menu.toggle() end},
}

function set_explosionsOptions()
    menu.pushMenu(explosionsOptions)
    if ColstrenghMul == 2 then selectedOption=2 end
    if ColstrenghMul == 3 then selectedOption=3 end
    if ColstrenghMul == 10 then selectedOption=4 end

    hoverOption = selectedOption
    --print("found ",selectedOption)

end
-- Settings menu options (submenu)
local settingsOptions = {
    {name = "Explosions", action = set_explosionsOptions},
    {name = "Explosions", action = set_explosionsOptions},
    {name = "Explosions", action = set_explosionsOptions},
    {name = "Back", action = function() menu.toggle() end},  -- Back option to go back to previous menu
}

-- Default pause options
local pauseOptions = {
    {name = "Resume", action = function() menu.toggle() end},
    {name = "Settings", action = function() menu.pushMenu(settingsOptions) end},  -- Added Settings menu option
    {name = "Restart", action = function() restart(); menu.toggle() end},
    {name = "Quit", action = function() love.event.quit() end},
}

-- Set custom options or revert to default
function menu.setOptions(newOptions)
    --print("setting options")
    if newOptions then
        options = newOptions
    else
        options = pauseOptions
    end
    selectedOption = 1
    hoverOption = 1
end

-- Push a new menu onto the undo stack
function menu.pushMenu(newOptions)
    --print("pushing menu")

    table.insert(undoStack, options)
    options = newOptions
    selectedOption = 1
end

-- Toggle pause menu
function menu.toggle()
    if paused then
        if #undoStack > 0 then
            options = table.remove(undoStack)
        else
            paused = false
            options = pauseOptions
        end
    else
        paused = true
        options = pauseOptions
    end
    selectedOption = 1
end

-- Select an option
function menu.select()
    local option = options[selectedOption]
    if option and option.action then
        option.action()
    end
end

-- Detect click on menu option
function menu.checkClick(x, y)
    local startY = love.graphics.getHeight() / 4 + 40
    for i, option in ipairs(options) do
        local optionY = startY + (i - 1) * optionHeight
        if y >= optionY and y <= optionY + optionHeight then
            --print("click")
            selectedOption = i
            menu.select()
            return
        end
    end
end

-- Detect hover over menu options
function menu.checkHover(x, y)
    local startY = love.graphics.getHeight() / 4 + 40
    for i, option in ipairs(options) do
        local optionY = startY + (i - 1) * optionHeight
        if y >= optionY and y <= optionY + optionHeight then
            hoverOption = i
            -- print("hover")
            break
        end
    end
end

-- Draw the menu
function menu.draw()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Game Menu", 0, love.graphics.getHeight() / 4 - 40, love.graphics.getWidth(), "center")
    
    local startY = love.graphics.getHeight() / 4 + 40
    for i, option in ipairs(options) do
        local color = {1, 1, 1}
        if i == hoverOption then
            color = {0.8, 0.3, 0.3}
        elseif i == selectedOption then
            color = {0.5, 0.5, 0.5}
        end
        love.graphics.setColor(color)
        love.graphics.printf(option.name, 0, startY + (i - 1) * optionHeight, love.graphics.getWidth(), "center")
    end
end

return menu

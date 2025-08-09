local menu = {}

function load_settings()
    load_explotion()
end

-- Menu state variables
local options = pauseOptions  -- Default to pauseOptions
local selectedOption = 1
local hoverOption = 1
local optionHeight = 40
local undoStack = {}  -- Stack to store the history of active menus

local cols = require("collisions")

------------explotion stuff--------------------------
local ExplosionTypes = {
    SMALL = "SMALL",
    NORMAL = "NORMAL",
    BIG = "BIG",
    ABSURD = "ABSURD"
}

local selectedExplotion = ExplosionTypes.NORMAL


local explosionMultipliers = {
    [ExplosionTypes.SMALL] = 1,
    [ExplosionTypes.NORMAL] = 2,
    [ExplosionTypes.BIG] = 3,
    [ExplosionTypes.ABSURD] = 10
}

local EXPLOTION_FILE = "explotion_mul.txt"

function setExplotion(type)
    selectedExplotion = type
    ColstrenghMul = explosionMultipliers[type]
    love.filesystem.write(EXPLOTION_FILE, type)
end

function load_explotion()
    local contents, err = love.filesystem.read(EXPLOTION_FILE)
    if not contents then return false, err end
    if ExplosionTypes[contents] then
        setExplotion(contents)
    end
end
---------------------------------------------------------------

local explosionsOptions = {
    {name = "Small", action = function() setExplotion(ExplosionTypes.SMALL) end},
    {name = "Normal", action = function() setExplotion(ExplosionTypes.NORMAL) end},
    {name = "Big", action = function() setExplotion(ExplosionTypes.BIG) end},
    {name = "Absurd", action = function() setExplotion(ExplosionTypes.ABSURD) end},
    {name = "Back", action = function() menu.toggle() end},
}

function set_explosionsOptions()
    menu.pushMenu(explosionsOptions)
    if selectedExplotion == ExplosionTypes.SMALL then selectedOption=1 end
    if selectedExplotion == ExplosionTypes.NORMAL then selectedOption=2 end
    if selectedExplotion == ExplosionTypes.BIG then selectedOption=3 end
    if selectedExplotion == ExplosionTypes.ABSURD then selectedOption=4 end

    hoverOption = selectedOption
    --print("found ",selectedOption)

end
-- Settings menu options (submenu)
local settingsOptions = {
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

local menu = {}

-- Menu states
local options = {"Resume", "Restart", "Quit"}
local selectedOption = 1
local hoverOption = 1 -- Option that is currently being hovered
local optionHeight = 40  -- Height for each option, used for click detection

-- Function to toggle the menu visibility
function menu.toggle()
    paused = not paused
    selectedOption = 1 -- Reset to the first option when the menu is opened
end

-- Function to navigate through the options (for keyboard control, if needed)
function menu.navigate(direction)
    selectedOption = selectedOption + direction
    if selectedOption < 1 then
        selectedOption = #options
    elseif selectedOption > #options then
        selectedOption = 1
    end
end

-- Function to select an option
function menu.select()
    if options[selectedOption] == "Resume" then
        menu.toggle() -- Close the menu
    elseif options[selectedOption] == "Restart" then
        restart()
        menu.toggle() -- Close the menu
    elseif options[selectedOption] == "Quit" then
        love.event.quit() -- Exit the game
    end
end

-- Function to detect which menu option is clicked
function menu.checkClick(x, y)
    local startY = love.graphics.getHeight() / 4 + 40  -- Starting Y position for options
    for i, option in ipairs(options) do
        local optionY = startY + (i - 1) * optionHeight
        if y >= optionY and y <= optionY + optionHeight then
            selectedOption = i
            menu.select()
            break
        end
    end
end

-- Function to detect hover over menu options
function menu.checkHover(x, y)
    local startY = love.graphics.getHeight() / 4 + 40  -- Starting Y position for options
    for i, option in ipairs(options) do
        local optionY = startY + (i - 1) * optionHeight
        if y >= optionY and y <= optionY + optionHeight then
            hoverOption = i
            break
        end
    end
end

-- Function to draw the menu
function menu.draw()
    if paused then
        love.graphics.setColor(0, 0, 0, 0.7) -- Dark background
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        
        love.graphics.setColor(1, 1, 1) -- White text
        love.graphics.printf("Game Menu", 0, love.graphics.getHeight() / 4 - 40, love.graphics.getWidth(), "center")
        
        -- Draw options
        local startY = love.graphics.getHeight() / 4 + 40  -- Starting Y position for options
        for i, option in ipairs(options) do
            -- Highlight hover and selection
            local color = {1, 1, 1} -- Default color
            if i == hoverOption then
                color = {0.8, 0.3, 0.3} -- Hover effect
            elseif i == selectedOption then
                color = {0.5, 0.5, 0.5} -- Selected option color
            end
            love.graphics.setColor(color)
            love.graphics.printf(option, 0, startY + (i - 1) * optionHeight, love.graphics.getWidth(), "center")
        end
    end
end

return menu

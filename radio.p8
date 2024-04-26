pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- wave class
-- type: sawtooth, sine, square, triangle
-- size: determined however. right now it's defaulted at 8
Wave = {
    type = "",
    size = 0,
    color = 0 --default black color, no type, no size
}

-- wave constructor
function Wave:create(type, size)
    local newWave = {} --hehe, new wave
    setmetatable(newWave, Wave)
    newWave.type = type
    newWave.size = size
    newWave.color = 2 --maroon-ish
    newWave.lineList = {} --for storing individual lines
    -- types: sawtooth, square, sine, triangle
    if(type == "sawtooth") then
        newWave.color = 12 --slightly jarring blue
    elseif(type == "square") then
        newWave.color = 3 --a pleasant green
    elseif(type == "sine") then
        newWave.color = 2 --maroon-ish
    end
    return newWave
end

-- array of wave objects
local waveArray = {}

-- list for storing lines
local lineList = {}

-- barriers for movement
local line2height = 89

-- player1 control detection
local playerInput = {
    up = false,
    down = false,
    left = false,
    right = false,
    cooldown = 0
}

-- player one (wave sender) info
local playerOne = {
    x = 56,
    y = 0,
    speed = 3,
    size = 15,
    minX = 2,
    maxX = 125,
    minY = 2,
    maxY = 0
}

-- player two (wave receiver) info
local playerTwo = {
    x = 56,
    y = 110,
    speed = 3,
    size = 15,
    minX = 2,
    maxX = 125,
    minY = line2height+2,
    maxY = 125
}

function updatePlayerPos()
    if playerInput.cooldown == 0 then
        --move player one
        -- left key
        if btn(0) then 
            if not playerInput.left then
                playerInput.left = true
                -- fire sawtooth wave
                newWave = Wave:create("sawtooth", 8)
                add(waveArray, newWave)
                lines = createLine("sawtooth") --contains two lines for the full wavelength
                for i=1, #lines do
                    add(newWave.lineList, lines[i])
                end
            else
                --add to current wave - last wave in the array
                lines = createLine("sawtooth")
                for i=1, #lines do
                    add(waveArray[#waveArray].lineList, lines[i])
                end
            end
            playerInput.cooldown = 10

        -- right key
        elseif btn(1) then 
            if not playerInput.right then
                playerInput.right = true
                -- fire square wave
                newWave = Wave:create("square", 8)
                add(waveArray, newWave)
                lines = createLine("square")
                for i=1, #lines do
                    add(newWave.lineList, lines[i])
                end
            else
                --add to current wave - last wave in the array
                lines = createLine("square")
                --square wave is made up of four lines, not two
                for i=1, #lines do
                    add(waveArray[#waveArray].lineList, lines[i])
                end
            end
            playerInput.cooldown = 10

        -- up key
        elseif btn(2) then 
            if not playerInput.up then
                playerInput.up = true
                -- fire sine wave
                newWave = Wave:create("sine", 8)
                add(waveArray, newWave)
                lines = createLine("sine") --contains two lines for the full wavelength
                for i=1, #lines do
                    add(newWave.lineList, lines[i])
                end
            else
                --add to current wave - last wave in the array
                lines = createLine("sine")
                for i=1, #lines do
                    add(waveArray[#waveArray].lineList, lines[i])
                end
            end
            
            playerInput.cooldown = 10

        -- down key
        elseif btn(3) then 
            -- fire triangle wave
            if not playerInput.down then
                -- start a new wave
                playerInput.down = true
                newWave = Wave:create("triangle", 8)
                add(waveArray, newWave)
                lines = createLine("triangle") --contains two lines for the full wavelength
                for i=1, #lines do
                    add(newWave.lineList, lines[i])
                end
            else
                --add to current wave - last wave in the array
                lines = createLine("triangle")
                for i=1, #lines do
                    add(waveArray[#waveArray].lineList, lines[i])
                end
            end
            playerInput.cooldown = 10
        end

        --end waves
        if not btn(0) then
            if playerInput.left then
                playerInput.cooldown = 10
            end
            playerInput.left = false
        end
        if not btn(1) then
            if playerInput.right then
                playerInput.cooldown = 10
            end
            playerInput.right = false
        end
        if not btn(2) then
            if playerInput.up then
                playerInput.cooldown = 10
            end
            playerInput.up = false
        end
        if not btn(3) then
            if playerInput.down then
                playerInput.cooldown = 10
            end
            playerInput.down = false
        end
    end

    --move player two
    if btn(0, 1) and playerTwo.x > playerTwo.minX then 
        -- move player two (wave-receiver) to the left
        playerTwo.x -= playerTwo.speed 
    end
    if btn(1, 1) and playerTwo.x < playerTwo.maxX - playerTwo.size then 
        -- move player two to the right
        playerTwo.x += playerTwo.speed 
    end
    if btn(2, 1) and playerTwo.y > playerTwo.minY then 
        -- move player two upwards
        playerTwo.y -= playerTwo.speed 
    end
    if btn(3, 1) and playerTwo.y < playerTwo.maxY - playerTwo.size then 
        -- move player two downwards
        playerTwo.y += playerTwo.speed 
    end

    --reduce cooldown
    if playerInput.cooldown > 0 then
        playerInput.cooldown -= 1
    end
end

function drawPlayer()
    rectfill(playerOne.x, playerOne.y, playerOne.x + playerOne.size, playerOne.y + playerOne.size, 8)
    rectfill(playerTwo.x, playerTwo.y, playerTwo.x + playerTwo.size, playerTwo.y + playerTwo.size, 9)
end

function drawBorders()
    rect(0, 0, 127, 127, 1)
    --draw bottom line
    line(1, line2height, 126, line2height, 14)
end

function createLine(type) -- draw a red box that gts added to the lineList
    newLines = {}
    -- generate a different line based on type
    if (type == "sawtooth") then 
        -- draw a sawtooth wave - jagged
        local x1 = playerOne.x - 12
        local x2 = playerOne.x + 20
        local y1 = playerOne.y - 20
        local y2 = playerOne.y - 20
        local y3 = playerOne.y
        -- draw two lines. crossing the screen, and back
        local line1 = {
            x1 = x1,
            x2 = x2,
            y1 = y1,
            y2 = y2
        }
        local line2 = {
            x1 = x2,
            x2 = x1,
            y1 = y2,
            y2 = y3
        }
        add(newLines, line1)
        add(newLines, line2)
    elseif (type == "sine") then
        -- draw a sine wave - curving
        --how the fuck do i do this?
    elseif (type == "square") then
        -- draw a square wave - blocky
        --made up of four lines, not two! we need five points
        -- point one: x1, y1
        -- point two: x1, y2
        -- point three: x2, y2
        -- point four: x2, y3
        -- point five: x1, y3
        local x1 = playerOne.x - 12
        local x2 = playerOne.x + 20
        local y1 = playerOne.y - 20
        local y2 = playerOne.y - 10
        local y3 = playerOne.y
        --draw four lines: down, right, down, left
        local line1 = {
            x1 = x1,
            x2 = x1,
            y1 = y1,
            y2 = y2
        }
        local line2 = {
            x1 = x1,
            x2 = x2,
            y1 = y2,
            y2 = y2
        }
        local line3 = {
            x1 = x2,
            x2 = x2,
            y1 = y2,
            y2 = y3
        }
        local line4 = {
            x1 = x2,
            x2 = x1,
            y1 = y3,
            y2 = y3
        }
        add(newLines, line1)
        add(newLines, line2)
        add(newLines, line3)
        add(newLines, line4)
    elseif (type == "triangle") then
        -- draw a triangle wave - simple
        local x1 = playerOne.x - 12
        local x2 = playerOne.x + 20
        local y1 = playerOne.y - 20
        local y2 = playerOne.y - 10
        local y3 = playerOne.y
        -- draw two lines. crossing the screen, and back
        local line1 = {
            x1 = x1,
            x2 = x2,
            y1 = y1,
            y2 = y2
        }
        local line2 = {
            x1 = x2,
            x2 = x1,
            y1 = y2,
            y2 = y3
        }
        add(newLines, line1)
        add(newLines, line2)
    end
    return newLines
end

function updateLinePos()
    for i = 1, #waveArray do
        for j=1, #(waveArray[i].lineList) do
            waveArray[i].lineList[j].y1 += 2
            waveArray[i].lineList[j].y2 += 2 --wave move speed
            --printh("linelist index " .. i .. " x: " .. lineList[i].x .. " y: " .. lineList[i].y)
        end
    end
end

function drawLines()
    for i = 1, #waveArray do
        for j=1, #(waveArray[i].lineList) do
            line(waveArray[i].lineList[j].x1, waveArray[i].lineList[j].y1, waveArray[i].lineList[j].x2, waveArray[i].lineList[j].y2)
            -- rectfill(waveArray[i].lineList[j].x, waveArray[i].lineList[j].y, waveArray[i].lineList[j].x + waveArray[i].lineList[j].size, waveArray[i].lineList[j].y + waveArray[i].lineList[j].size, 8)
        end
    end
end

function drawControls()
    -- key width: 5, height: 10
    -- draw up key in maroon
    rectfill(15, 5, 20, 15, 2)
    -- down key
    rectfill(15, 20, 20, 30, 2)
    -- left key
    rectfill(5, 15, 15, 20, 2)
    -- right key
    rectfill(20, 15, 30, 20, 2)
end

function _update()
    updatePlayerPos()
    -- createLine()
    updateLinePos()
end

function _draw()
    cls()
    drawControls()
    drawBorders()
    drawPlayer()
    drawLines()
end

__gfx__
000000000000000015555551111a1111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000150000511a111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000060060015055051116116a1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000006006001505505111611611000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000001500005111555511000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700660000661555555111500511000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666601171171111500511000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001171171111555511000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

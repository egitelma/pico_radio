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
    --move player one
    if btn(0) then 
        -- fire sawtooth wave
        newWave = Wave:create("sawtooth", 8)
        add(waveArray, newWave)
    elseif btn(1) then 
        -- fire square wave
        newWave = Wave:create("square", 8)
        add(waveArray, newWave)
    elseif btn(2) then 
        -- fire sine wave
        newWave = Wave:create("sine", 8)
        add(waveArray, newWave)
    elseif btn(3) then 
        -- fire triangle wave
        newWave = Wave:create("triangle", 8)
        add(waveArray, newWave)
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
    -- generate a different line based on type
    
    if btn(4) then
        local line = {
            x = playerOne.x + playerOne.size / 2,
            y = playerOne.y,
            size = 3
        }
        add(lineList, line)
    end
end

function updateLinePos()
    for i = 1, #lineList do
        lineList[i].y += 4 --wave move speed
        --printh("linelist index " .. i .. " x: " .. lineList[i].x .. " y: " .. lineList[i].y)
    end
end

function drawLines()
    for i = 1, #lineList do
        rectfill(lineList[i].x, lineList[i].y, lineList[i].x + lineList[i].size, lineList[i].y + lineList[i].size, 8)
    end
end

function drawControls()
    -- key width: 5, height: 10
    -- draw up key in maroon
    if(btn(2)) then
        rectfill(15, 5, 20, 15, 8)
    else
        rectfill(15, 5, 20, 15, 2)
    end
    -- down key
    if(btn(3)) then
        rectfill(15, 20, 20, 30, 8)
    else
        rectfill(15, 20, 20, 30, 2)
    end
    -- left key
    if(btn(0)) then
        rectfill(5, 15, 15, 20, 8)
    else
        rectfill(5, 15, 15, 20, 2)
    end
    -- right key
    if(btn(1)) then
        rectfill(20, 15, 30, 20, 8)
    else
        rectfill(20, 15, 30, 20, 2)
    end
end

function _update()
    updatePlayerPos()
    createLine()
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

pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- wave class
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

-- barriers for movement
local line1height = 30
local line2height = 90

-- player one (wave sender) info
local playerOne = {
    x = 56,
    y = 0,
    speed = 3,
    size = 15,
    minX = 2,
    maxX = 125,
    minY = 2,
    maxY = line1height-3
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

local lineList = {}

function updatePlayerPos()
    --move player one
    if btn(0) then 
        -- fire sawtooth wave
        newWave = Wave:create("sawtooth", 8)
        -- table.insert(waveArray, newWave)
    elseif btn(1) then 
        -- fire square wave
        newWave = Wave:create("square", 8)
        -- newWave.insert(waveArray, newWave)
    elseif btn(2) then 
        -- fire sine wave
        newWave = Wave:create("sine", 8)
        -- newWave.insert(waveArray, newWave)
    elseif btn(3) then 
        -- fire triangle wave
        newWave = Wave:create("triangle", 8)
        -- newWave.insert(waveArray, newWave)
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
    line(1, line1height, 126, line1height, 14)
    line(1, line2height, 126, line2height, 14)
end

function createLine() -- draw a red box that gts added to the lineList
    if btn(4) then
        local line = {
            x = playerOne.x + playerOne.size / 2,
            y = playerOne.y,
            size = 3
        }
        add(lineList, line)
        --printh("lineList size: " .. #lineList)
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

function _update()
    updatePlayerPos()
    createLine()
    updateLinePos()
end

function _draw()
    cls()
    drawBorders()
    drawPlayer()
    drawLines()
end

__gfx__
000000000000000015555551000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000150000510a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000060060015055051006006a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000006006001505505100600600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000001500005100555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700660000661555555100500500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666601171171100500500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000001171171100555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

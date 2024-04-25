pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

local playerOne = {
    x = 56,
    y = 20,
    speed = 3,
    size = 15,
    minX = 1,
    maxX = 127,
    minY = 1,
    maxY = 127
}

local playerTwo = {
    x = 56,
    y = 100,
    speed = 3,
    size = 15,
    minX = 1,
    maxX = 127,
    minY = 1,
    maxY = 127
}

local lineList = {}

function updatePlayerPos()
    if btn(0) and playerOne.x > playerOne.minX then playerOne.x -= playerOne.speed end
    if btn(1) and playerOne.x < playerOne.maxX - playerOne.size then playerOne.x += playerOne.speed end
    if btn(2) and playerOne.y > playerOne.minY then playerOne.y -= playerOne.speed end
    if btn(3) and playerOne.y < playerOne.maxY - playerOne.size then playerOne.y += playerOne.speed end
    if btn(0, 1) and playerTwo.x > playerTwo.minX then playerTwo.x -= playerTwo.speed end
    if btn(1, 1) and playerTwo.x < playerTwo.maxX - playerTwo.size then playerTwo.x += playerTwo.speed end
    if btn(2, 1) and playerTwo.y > playerTwo.minY then playerTwo.y -= playerTwo.speed end
    if btn(3, 1) and playerTwo.y < playerTwo.maxY - playerTwo.size then playerTwo.y += playerTwo.speed end
    --printh("playerOne x: " .. playerOne.x .. " y: " .. playerOne.y)
    --printh("playerTwo x: " .. playerTwo.x .. " y: " .. playerTwo.y)
end

function drawPlayer()
    rectfill(playerOne.x, playerOne.y, playerOne.x + playerOne.size, playerOne.y + playerOne.size, 8)
    rectfill(playerTwo.x, playerTwo.y, playerTwo.x + playerTwo.size, playerTwo.y + playerTwo.size, 9)
end

function drawBorders()
    rect(0, 0, 127, 127, 8)
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700006006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000006006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700660000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

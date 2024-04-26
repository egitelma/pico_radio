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
local line1height = 30
local line2height = 90

-- management stuff
local receivingPlayer = 1
local timeRemaining = 30

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
    maxY = line1height-3,
    score = 0
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
    maxY = 125,
    score = 0
}

function updatePlayerPos()
    -- assigning buttons based on current player
    btn0 = (btn(0) and receivingPlayer == 1) or (btn(0, 1) and receivingPlayer == 0)
    btn1 = (btn(1) and receivingPlayer == 1) or (btn(1, 1) and receivingPlayer == 0)
    btn2 = (btn(2) and receivingPlayer == 1) or (btn(2, 1) and receivingPlayer == 0)
    btn3 = (btn(3) and receivingPlayer == 1) or (btn(3, 1) and receivingPlayer == 0)
    btn0p = (btn(0) and receivingPlayer == 0) or (btn(0, 1) and receivingPlayer == 1)
    btn1p = (btn(1) and receivingPlayer == 0) or (btn(1, 1) and receivingPlayer == 1)
    btn2p = (btn(2) and receivingPlayer == 0) or (btn(2, 1) and receivingPlayer == 1)
    btn3p = (btn(3) and receivingPlayer == 0) or (btn(3, 1) and receivingPlayer == 1)

    if(receivingPlayer == 1) then
        p1 = playerOne
        p2 = playerTwo
    else
        p1 = playerTwo
        p2 = playerOne
    end


    if playerInput.cooldown == 0 then
        --move player one
        -- left key
        if btn0 then 
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
        elseif btn1 then 
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
        elseif btn2 then 
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
        elseif btn3 then 
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
        if not btn0 then
            if playerInput.left then
                playerInput.cooldown = 10
            end
            playerInput.left = false
        end
        if not btn1 then
            if playerInput.right then
                playerInput.cooldown = 10
            end
            playerInput.right = false
        end
        if not btn2 then
            if playerInput.up then
                playerInput.cooldown = 10
            end
            playerInput.up = false
        end
        if not btn3 then
            if playerInput.down then
                playerInput.cooldown = 10
            end
            playerInput.down = false
        end
    end

    --move player two
    if btn0p and p2.x > p2.minX then 
        -- move player two (wave-receiver) to the left
        p2.x -= p2.speed 
    end
    if btn1p and p2.x < p2.maxX - p2.size then 
        -- move player two to the right
        p2.x += p2.speed 
    end
    if btn2p and p2.y > p2.minY then 
        -- move player two upwards
        p2.y -= p2.speed 
    end
    if btn3p and p2.y < p2.maxY - p2.size then 
        -- move player two downwards
        p2.y += p2.speed 
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
    if(receivingPlayer == 1) then
        p1 = playerOne
    else
        p1 = playerTwo
    end

    newLines = {}
    -- generate a different line based on type
    if (type == "sawtooth") then 
        -- draw a sawtooth wave - jagged
        local x1 = p1.x - 12
        local x2 = p1.x + 20
        local y1 = p1.y - 20
        local y2 = p1.y - 20
        local y3 = p1.y
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
        local x1 = p1.x - 12
        local x2 = p1.x + 20
        local y1 = p1.y - 20
        local y2 = p1.y - 10
        local y3 = p1.y
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
        local x1 = p1.x - 12
        local x2 = p1.x + 20
        local y1 = p1.y - 20
        local y2 = p1.y - 10
        local y3 = p1.y
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
    --original code
    -- for item in all(lineList) do
    --     item.y += 4
    --     if(receivingPlayer == 1 and item.y + item.size >= playerTwo.y and item.y <= playerTwo.y + playerTwo.size and item.x + item.size >= playerTwo.x and item.x <= playerTwo.x + playerTwo.size) then
    --         playerTwo.score += 1
    --         del(lineList, item)
    --     end
    --     if(receivingPlayer == 0 and item.y + item.size >= playerOne.y and item.y <= playerOne.y + playerOne.size and item.x + item.size >= playerOne.x and item.x <= playerOne.x + playerOne.size) then
    --         playerOne.score += 1
    --         del(lineList, item)
    --     end
    --     if(item.y > 127) then
    --         del(lineList, item)
    --     end
    -- end
    
    --new code
    for item in all(waveArray) do
        for jtem in all(item.lineList) do
            jtem.y1 += 2
            jtem.y2 += 2
            -- if(receivingPlayer == 1 and jtem.y2 >= playerTwo.y and jtem.y1 <= playerTwo.y + playerTwo.size and jtem.x2 >= playerTwo.x and jtem.x1 <= playerTwo.x + playerTwo.size) then
            --     playerTwo.score += 1
            --     del(item.lineList, jtem)
            -- end
            -- if(receivingPlayer == 0 and jtem.y2 >= playerOne.y and jtem.y1 <= playerOne.y + playerOne.size and jtem.x2 >= playerOne.x and jtem.x1 <= playerOne.x + playerOne.size) then
            --     playerOne.score += 1
            --     del(item.lineList, jtem)
            -- end
            -- if(jtem.y2 > 127) then
            --     del(item.lineList, jtem)
            -- end
        end
    end

    -- for i = 1, #waveArray do
    --     for j=1, #(waveArray[i].lineList) do
    --         waveArray[i].lineList[j].y1 += 2
    --         waveArray[i].lineList[j].y2 += 2 --wave move speed
    --         --printh("linelist index " .. i .. " x: " .. lineList[i].x .. " y: " .. lineList[i].y)
    --     end
    -- end
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
    btn0 = btn(0) and receivingPlayer == 1 or btn(0, 1) and receivingPlayer == 0
    btn1 = btn(1) and receivingPlayer == 1 or btn(1, 1) and receivingPlayer == 0
    btn2 = btn(2) and receivingPlayer == 1 or btn(2, 1) and receivingPlayer == 0
    btn3 = btn(3) and receivingPlayer == 1 or btn(3, 1) and receivingPlayer == 0
    if(btn2) then
        rectfill(15, 5, 20, 15, 8)
    else
        rectfill(15, 5, 20, 15, 2)
    end
    -- down key
    if(btn3) then
        rectfill(15, 20, 20, 30, 8)
    else
        rectfill(15, 20, 20, 30, 2)
    end
    -- left key
    if(btn0) then
        rectfill(5, 15, 15, 20, 8)
    else
        rectfill(5, 15, 15, 20, 2)
    end
    -- right key
    if(btn1) then
        rectfill(20, 15, 30, 20, 8)
    else
        rectfill(20, 15, 30, 20, 2)
    end
end

function drawScore()
    print("Timer: " .. timeRemaining, 80, 3, 7)
    print("Player 1: " .. playerOne.score, 75, 10, 7)
    print("Player 2: " .. playerTwo.score, 75, 17, 7)
end

function updateTimer()
    oldTimeRemaining = timeRemaining
    timeRemaining = ceil(30 - t() % 30)
    if(timeRemaining > oldTimeRemaining) then
        switchPlayers()
    end
end

function switchPlayers()
    receivingPlayer = 1 - receivingPlayer -- switches players
    if(receivingPlayer == 1) then
        playerOne.x = 56
        playerOne.y = 0
        playerOne.minY = 2
        playerOne.maxY = line1height-3
        playerTwo.x = 56
        playerTwo.y = 110
        playerTwo.minY = line2height+2
        playerTwo.maxY = 125
    else
        playerTwo.x = 56
        playerTwo.y = 0
        playerTwo.minY = 2
        playerTwo.maxY = line1height-3
        playerOne.x = 56
        playerOne.y = 110
        playerOne.minY = line2height+2
        playerOne.maxY = 125
    end
end

function _update()
    updatePlayerPos()
    -- createLine()
    updateLinePos()
    updateTimer()
end

function _draw()
    cls()
    drawControls();
    drawPlayer()
    drawLines()
    drawBorders()
    drawScore()
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
__sfx__
011000000015000100001000010000150001000010000100001500010000100001000015000100001000010004150001000010000100041500010000100001000215000100001000010002150001000010000100
011000000075100751007010070100751007510070100701007510075100701007010075100751007010070104751047510070100701047510475100701007010275102751007010070102751007010000000000
0110000007150001000010004150001500010000150001000010000100001000b1500015000100001500010004150001000010002150041500010004150001000215000100001000000002150000000615000000
011000000015000000041500000000000041500000000000001500000007150000000000007150000000000004150000000715000000000000715000000061500215000000021500000002150000000215000000
911000000c3551035513355173550c3551035513355173550c3551035513355173550c3551035513355173551035513355173550e3551035513355173550e3550e35512355153550e3550e35512355153550e355
011000001075110751107511075110751107511075110751107511075110751107511075110751107511075110751107511075110751107511075110751107510e7510e7510e7510e7510e7510e7510e7510e751
011000001375113751137511375113751137511375113751137511375113751137511375113751137511375113751137511375113751137511375113751137511275112751127511275112751127511275112751
011000000c7510c7510c7510c7510c7510c7510c7510c7510c7510c7510c7510c7510c7510c7510c7510c7510b7510b7510b7510b7510b7510b7510b7510b7510975109751097510975109751097510975109751
31100000235500050023550005002155000500005001c5001e5001c5001c5501e5501f550005001f5001f5501c550005001c5001f5001f5001c5501f5501c5001e5501c5001a5501e55021550005002155000500
011000002b7502b7502b7502b7502f75000700007002b7502f75000700007000070000700007000070000700287502875028750287502b75000700007002b7502a75000700007000070000700007000070000700
011000002b55500005000052a5550000500005285550000528555000050000524505245050000528555000052855528505000052b55500005000052b555000052a5550000500005000052a555000052a55500005
011000002b5512b5512b5052b5512b5512b50128551285512b5512b5512b5002b5002b5052b5012b5512b55128551285512f505000002f505000002f505285002a5512a5512a505287012a5512a5512a5512a551
91100000006510000700007000072b657000070000700007000070000700007000072b657000070000700007006510000700007000072b65700007000070000700007000072b651000072b657000070000700007
911000002f65500000000002b65500000000002b655000002f65500000000002b65500000000002b655000002f65500000000002b65500000000002b655000002f65500000000002b65500000000002b65500000
911000002f655000002f6000000000000000002f6512f6012f655000000000000000000000000000000000002f65500000000002f65500000000002f6512f6012f6550000000000000002f655000000000000000
911000002f6052f6550000000000000002f6550000000000000002f6550000000000000002f6550000000000000002f6550000000000000002f6550000000000000002f6550000000000000002f6550000000000
__music__
00 01454647
00 01454647
00 010d4648
00 010e4648
00 06070504
00 06070504
00 06070804
00 06070504
00 06070904
00 06070504
00 06070a04
00 06070504
00 46470b44
00 030b0d06
00 030b0d07
00 430b0d08
00 070b0d08
00 070b0e08
00 41454647
00 41454647


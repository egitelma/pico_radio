pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- title screen stuff
cloudtime = 3
speed = .03

cloud1x = 0
cloud2x = 30
cloud3x = 15

scene = "title"
start = 0

-- wave class
-- type: sawtooth, sine, square, triangle
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
    newWave.color = 2 --maroon-ish, as a baseline
    newWave.lineList = {} --for storing individual lines
    -- types: sawtooth, square, sine, triangle
    if(type == "sawtooth") then
        newWave.color = 12 --slightly jarring blue
    elseif(type == "square") then
        newWave.color = 3 --a pleasant green
    elseif(type == "sine") then
        newWave.color = 2 --maroon-ish
    elseif(type == "triangle") then
        newWave.color = 14 --nice pink
    end
    return newWave
end

local currentSong = {0, 4, 9, 14}
local base = {0, 1, 2, 3}
local harm = {4, 5, 6, 7}
local melody = {8, 9,10, 11}
local drum = {12,13, 14, 15}

function addBase()
    local randIndex = flr(rnd(#base)) + 1  -- Get a random index
    local valueToRemove = base[randIndex]  -- Get the value at that random index
    add(currentSong, valueToRemove)  -- Add that value to the currentSong
    del(base, valueToRemove)  -- Remove the value from base

    -- If base is empty, reset it
    if #base == 0 then
        base = {0, 1, 2, 3}
    end

    -- Assuming you want to manage the size of currentSong to a max of 4 items
    del(currentSong, currentSong[1])  -- Remove the oldest added item from currentSong
end

function addHarm()
    local randIndex = flr(rnd(#harm)) + 1
    local valueToRemove = harm[randIndex]
    add(currentSong, valueToRemove)
    del(harm, valueToRemove)
    
    harm = {4, 5, 6, 7}


    del(currentSong, currentSong[1])
end

function addMelody()
    local randIndex = flr(rnd(#melody)) + 1
    local valueToRemove = melody[randIndex]
    add(currentSong, valueToRemove)
    del(melody, valueToRemove)
    
    if #melody == 0 then
        melody = {8, 9, 10, 11}
    end

    del(currentSong, currentSong[1])

end

function addDrum()
    local randIndex = flr(rnd(#drum)) + 1
    local valueToRemove = drum[randIndex]
    add(currentSong, valueToRemove)
    del(drum, valueToRemove)
    
    if #drum == 0 then
        drum = {12, 13, 14, 15}
    end

    del(currentSong, currentSong[1])
end

-- array of wave objects
local waveArray = {}

-- barriers for movement
local line1height = 30
local line2height = 90

-- management stuff
local receivingPlayer = 1
local timeRemaining = 30
local playersSwitched = false

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
function get_two_different_random_numbers()
    local num1 = flr(rnd(4))  -- Generate the first random number and floor it
    local num2
    repeat
        num2 = flr(rnd(4))  -- Generate the second random number and floor it
    until num2 ~= num1      -- Ensure it is not the same as the first

    return num1, num2
end

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
        -- left key: sawtooth
        if btn0 then
            addDrum()
            -- local number1, number2 = get_two_different_random_numbers()
            -- currentSong[3]= 12 + number1
            -- currentSong[4]= 12 + number2
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

        -- right key: square
        elseif btn1 then
            addBase()
            -- local number1, number2 = get_two_different_random_numbers()
            -- currentSong[1]= number1
            -- currentSong[2]= number2  
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

        -- up key: sine
        elseif btn2 then
            addHarm()
            -- local number1, number2 = get_two_different_random_numbers()
            -- currentSong[1]= 4 + number1
            -- currentSong[2]= 4 + number2 
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
            
            playerInput.cooldown = 13

        -- down key: triangle
        elseif btn3 then 
            addMelody()
            -- local number1, number2 = get_two_different_random_numbers()
            -- currentSong[2]= 8+number1
            -- currentSong[3]= 8+number2  
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
    sspr(24,0,8,7, playerOne.x, playerOne.y,playerOne.size,playerOne.size)
    --rectfill(playerOne.x, playerOne.y, playerOne.x + playerOne.size, playerOne.y + playerOne.size, 8)
    sspr(24,16,8,8, playerTwo.x, playerTwo.y,playerTwo.size,playerTwo.size)
    --rectfill(playerTwo.x, playerTwo.y, playerTwo.x + playerTwo.size, playerTwo.y + playerTwo.size, 9)
end

function drawBorders()
    rect(0, 0, 127, 127, 1)
    --draw bottom line
    line(1, line2height, 126, line2height, 14)
end

function createLine(type) -- draw waves coming from the player
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
        -- local line1 = {
        --     x1 = x1,
        --     x2 = x2,
        --     y1 = y1,
        --     y2 = y2
        -- }
        local i
        for i=0, 15, 1 do
            local newLine = {
                x1 = x1 + i*2,
                x2 = x1 + 2 + i*2,
                y1 = y2,
                y2 = y2
            }
            add(newLines, newLine)
        end
        -- for i=0, 10, 1 do
        --     local newLine = {
        --         x1 = x1 + i*2,
        --         x2 = x1 + 2 + i*2,
        --         y1 = y1 + i*2,
        --         y2 = y1 + 2 + i*2
        --     }
        --     add(newLines, newLine)
        -- end
        local line2 = {
            x1 = x2,
            x2 = x1,
            y1 = y2,
            y2 = y3
        }
        -- add(newLines, line1)
        add(newLines, line2)
    elseif (type == "sine") then
        -- draw a sine wave - curving
        --sine wave code based from https://www.reddit.com/r/pico8/comments/f3drmd/creating_a_basic_sine_wave/
        local samples = 64
        local amp = 16
        local freq = 5
        local center = 64
        
        local i_f = 128/freq
        local dx = 128/samples

        local yBase;

        if receivingPlayer == 0 then
            yBase = playerTwo.y
        else
            yBase = playerOne.y
        end

        for y=yBase+6, yBase+30, dx do 
            local newline = {
                x1 = center+sin(y/i_f)*amp-4,
                y1 = y-29,
                x2 = center+sin((y+dx)/i_f)*amp-4,
                y2 = y+dx-29
            }
            add(newLines, newline)
        end
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
        local i
        for i=0, 15, 1 do
            local newLine = {
                x1 = x1 + i*2,
                x2 = x1 + 2 + i*2,
                y1 = y2,
                y2 = y2
            }
            add(newLines, newLine)
        end
        -- local line2 = {
        --     x1 = x1,
        --     x2 = x2,
        --     y1 = y2,
        --     y2 = y2
        -- }
        local line3 = {
            x1 = x2,
            x2 = x2,
            y1 = y2,
            y2 = y3
        }
        -- local line4 = {
        --     x1 = x2,
        --     x2 = x1,
        --     y1 = y3,
        --     y2 = y3
        -- }
        for i=0, 15, 1 do
            local newLine = {
                x1 = x1 + i*2,
                x2 = x1 + 2 + i*2,
                y1 = y3,
                y2 = y3
            }
            add(newLines, newLine)
        end
        add(newLines, line1)
        -- add(newLines, line2)
        add(newLines, line3)
        -- add(newLines, line4)
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
    for item in all(waveArray) do
        for jtem in all(item.lineList) do
            jtem.y1 += 2
            jtem.y2 += 2
            if(receivingPlayer == 1 and jtem.y2 >= playerTwo.y and jtem.y1 <= playerTwo.y + playerTwo.size and jtem.x2 >= playerTwo.x and jtem.x1 <= playerTwo.x + playerTwo.size) then
                playerTwo.score += 1
                del(item.lineList, jtem)
            end
            if(receivingPlayer == 0 and jtem.y2 >= playerOne.y and jtem.y1 <= playerOne.y + playerOne.size and jtem.x2 >= playerOne.x and jtem.x1 <= playerOne.x + playerOne.size) then
                playerOne.score += 1
                del(item.lineList, jtem)
            end
            if(jtem.y2 > 133) then
                del(item.lineList, jtem)
            end
        end
    end
end

function drawLines() --draws the actual waves themselves
    for i = 1, #waveArray do
        for j=1, #(waveArray[i].lineList) do
            line(waveArray[i].lineList[j].x1, waveArray[i].lineList[j].y1, waveArray[i].lineList[j].x2, waveArray[i].lineList[j].y2, waveArray[i].color)
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
    -- up key
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

    -- draw symbols in white on top
    -- up key: sine
    line(16, 7, 19, 9, 7)
    line(19, 9, 16, 11, 7)
    line(16, 11, 19, 13, 7)
    -- line(16, 8, 19, )
    -- down key: triangle (shockingly the most annoying)
    line(16, 21, 18, 23, 7)
    line(18, 23, 16, 25, 7)
    line(16, 25, 18, 27, 7)
    -- left key: sawtooth
    line(7, 19, 10, 16, 7)
    line(10, 16, 10, 19, 7)
    line(10, 19, 13, 16, 7)
    line(13, 16, 13, 19, 7)
    -- right key: square
    line(23, 19, 23, 16, 7)
    line(23, 16, 25, 16, 7)
    line(25, 16, 25, 19, 7)
    line(25, 19, 27, 19, 7)
    line(27, 19, 27, 16, 7)

end

--draw score during play
function drawScore()
    print("Timer: " .. timeRemaining, 80, 3, 7)
    print("Player 1: " .. playerOne.score, 75, 10, 7)
    print("Player 2: " .. playerTwo.score, 75, 17, 7)
end

--end screen
function drawPoints()
    --draw out text
    print("\^t\^wEND", 50, 50, 10)
    print("PLAYER 1 SCORE: " .. playerOne.score, 24, 64, 7)
    print("PLAYER 2 SCORE: " .. playerTwo.score, 24, 70, 7)
    if playerOne.score > playerTwo.score then
        print("\^t\^wPLAYER ONE WINS!", 2, 80, 14)
    elseif playerTwo.score > playerOne.score then
        print("\^t\^wPLAYER TWO WINS!", 2, 80, 14)
    else 
        print("\^t\^wTIE", 50, 80, 14)
    end
    print("press x to return to title", 12, 96, 7)

    --check player input
    if btn(5) then
        resetVariables()
        cls()
    end
end

function updateTimer()
    oldTimeRemaining = timeRemaining
    timeRemaining = ceil(30 - (t() - start) % 30)
    if(timeRemaining > oldTimeRemaining) then
        if playersSwitched == false then
            playersSwitched = true
            switchPlayers()
        else
            scene = "end"
        end
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

isPlaying = false
local delayFrames = 118  -- number of frames to wait
local toggleFrame = true
local frameCounter = 0
local isPlaying = false
function playSong()
    if not isPlaying then
        isPlaying = true
        -- Assuming currentSong contains up to 4 sound effects
        for i, sound in ipairs(currentSong) do
            sfx(sound, i-1)  -- Play each sound effect on a different channel, channels start at 0
        end
        frameCounter = delayFrames
    end
end

function _update()
    if ( scene == "play") then
        if (start == 0 ) then 
            start = t()
        end
        updatePlayerPos()
        updateLinePos()
        updateTimer()

        if frameCounter > 0 then
            frameCounter -= 1  -- decrement the frame counter
        else
            isPlaying = false  -- reset the playing flag when time is up
        end
        playSong();
    end
end

--set transparent color
palt(1, true)

function _draw()
    if (scene == "title") then
        draw_title()

    elseif  (scene == "play") then 
        cls()
        drawControls();
        drawPlayer()
        drawLines()
        drawBorders()
        drawScore()

    elseif(scene == "end") then
        cls()
        drawPoints()
    end
end

--reset all relevant variables for game restart
function resetVariables()
    --player variables
    playerOne = {
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
    playerTwo = {
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
    playersSwitched = false
    receivingPlayer = 1
    timeRemaining = 30
    waveArray = {}
    scene = "title"
end

-- title screen stuff

function draw_title()

    -- if "a" pressed
    if btn(4) then 
        -- Toggle scenes when button pressed
        scene = "play"
        start = t()
    end

	cloudtime+=speed
	if ( cloudtime >=.8) then
		title_background()
		title_foreground()
		--title_text()
		cloudtime = 0
	end

    rectfill(62,78, 126, 84, 3)
    print( "press c to play", 65,79, 10 )

end


function title_background()
	--sky
	rectfill(0,0,128,128,12)
	--clouds
	cloudtime+=speed
	cloud1x = (cloud1x+1)
	cloud2x = (cloud2x+2)
	cloud3x = (cloud3x+5)
	
	sspr(99,11,26,13,cloud1x%130,10)
	sspr(105,28,20,11,(cloud2x + 20)%130,30)
    sspr(97,44,15,11,(cloud3x + 50)%130,45)
	
	
	-- mountains
	sspr(32,0,63,63,0,0,128,126)
	
	--front cloud
	
	-- bottom of tower
	sspr(0,0,22,42,10,20,46,94)
	-- clouds + dither !!
	dither(75,120,0,128,3,7)
	--tower+satelite
	sspr(0,0,22,42,10,20,46,94)
	sspr(24,8,5,5,29,18,10,10)
end

function title_foreground()
	-- floor
	rectfill(0,108,128,128,9)
	for i=0,8 do
		line(0,108,128,108-i,9)
	end
	for i=0,8 do
		line(0,108+ (8*i)+i,128,99+6*i+i,4)
	end
	
	-- gate
	local gcolor = 1
	line(0,101,128,93,gcolor)
	line(0,102,128,92,gcolor)
	for i=0,12 do
		rect((10*i)+5,101-i*4/7,(10*i)+5,109-i*1/2,gcolor)
	end
	
	sspr ( 24,0,8,7,100,100,16,14)
		-- the actual title
	sspr(5,73,46,44,80,35)
end

-- spent like 2 or 3 hours on this then
-- just asked chatgpt
function dither(top, bot, left, right, background, overlay)
	for i = top, bot do
  for j = left, right do
   -- calculate pixel brightness
   local brightness = (i - top) / (bot - top)
   -- compare brightness with random value
   if brightness > rnd() then
    pset(j, i, overlay)
   end
  end
	end
end


__gfx__
00000000000000000000000056666665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000005dd55dd5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000060000000000005dd55dd5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009990000000000055555555000000000000000000000000000000000000000000000000000000000033330000000000000000000000000000000000
00000000099999000000000000600600000000000000000000000000000000000000000000000000000000003333333000000000000000000000000000000000
00000000090909000000000006600660000000000000000000000000000000000000000000000000000000033333333300000000000000000000000000000000
00000000090909000000000000000000000000000000000000000000000000000000000000000000000000333333333300000000000000000000000000000000
00000000606660600000000066666000000000000000000000000000000000000000000000000000000003333333333300000000000000000000000000000000
00000000606660600000000066656000000000000000000000000000000000000000000000000000000033333333333300000000000000000000000000000000
00000000660606600000000066566000000000000000000000000000000000000000000000000000000333333333333300000000000000000000000000000000
00000000660606600000000066666000000000000000000000000000000000000000000000000000003333333333333300000000007777777770000000000000
00000000660606600000000066666000000000000000000000000000000000000000000000000000333333333333333300000000077777777777700000000000
00000009900900990000000000000000000000000000000000000000000000000000000000000000333333333333333300000007777777777777777000000000
00000009090909090000000000000000000000000000000000000000000000000000000000000033333333333333333300000777777776677777777777770000
00000009009990090000000000000000000000000000000000000000000000000000000000003333333333333333333300007777777666777777777777777000
00000060660606606000000000000100000000000000000000000000000000000000000000333333333333333333333300076666666677777777777777777700
00000066000600066000000060555106000000000000000000000000000000000000000333333333333333333333333300077777777777777777777777777700
000000606006006060000000605dd506000000000000000000000000000000000033333333333333333333333333333300077777777777777777777777766700
000009000666660009000000665dd566000000000000000000000000000000000333333333333333333333333333333300077777777777777766667666667700
00000900009990000900000000555500000000000000000000000000000000003333333333333333333333333333333300077777777777777777766677777700
00000900090909000900000066516566000000000000000333333330000000033333333333333333333333333333333300077777777777777777777777777000
00009009900900990090000060561506000000000000000333333333330003333333333333333333333333333333333300077777777777777777777777700000
00009990000900009990000060516506000000000000003333333333333333333333333333333333333333333333333300000007777777777777777770000000
00006600000900000660000000000000000000000000033333333333333333333333333333333333333333333333333300000000007777777777000000000000
00060060000600006009000000000000000000000000333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00060006000600060009000000000000000000000003333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00060000660606600009000000000000000000000333333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00060000006660000009000000000000000000003333333333333333333333333333333333333333333333333333333300000000000000000000007770000000
00900000006660000000900000000000000000333333333333333333333333333333333333333333333333333333333300000000000000000000777777770000
00900009990909990000900000000000000033333333333333333333333333333333333333333333333333333333333300000000000000077777777777777000
00909990000900009990900000000000033333333333333333333333333333333333333333333333333333333333333300000000000077777777777777777000
00660000000900000006600000000000333333333333333333333333333333333333333333333333333333333333333300000000007777777777777777777700
00606000000900000060600000000000333333333333333333333333333333333333333333333333333333333333333300000000077777667777777777777700
06000600000900000600060000000000333333333333333333333333333333333333333333333333333333333333333300000000077777766777777777777700
06000066000900066000060000000000333333333333333333333333333333333333333333333333333333333333333300000000077777776667777777777000
06000000600900600000060000000000333333333333333333333333333333333333333333333333333333333333333300000000077777777766667777770000
60000000060906000000006000000000333333333333333333333333333333333333333333333333333333333333333300000000077777777777770000000000
60000000006660000000006000000000333333333333333333333333333333333333333333333333333333333333333300000000000777777777000000000000
00000000000600000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000000000777000000000000000
00000000000600000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00000000000600000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00000000000600000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300000777777700000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300007777777770000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300777777777777000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300777777777777000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333307666677777777770000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333307777777777776670000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333307777777666666777000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300777777776677777000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300077777777777777000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300007777777777777000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000777770000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000333333333333333333333333333333333333333333333333333333333333333300000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa00000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa000000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa000000aa000aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa00000aaa000aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000000000000000aaaaa0000aaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa000000000000000aaaaaaa000aaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000000000aa000aaa0aaa00aaa0aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000000000aa00aaa000aa00aaa000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000000000aa00aaa0000000aa0000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000000000aa00aa00000000aa0000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000000000aa00aa00000000aa0000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000000000aa00aa00000000aa000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000000000aa00aaa00aaa00aa00aaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000000000aa00aaaaaaaa00aaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000000000aa000aaaaaa000aaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000aaa000000000000000000000aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000aaa000000000000000000000aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa00000aa000000000000000000000aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa00000aa000000000000000000000aa00aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa00000aa00000000000000000000aaa00aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa00aaaaa00000000000000000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aaaaaaaaa00000aaa000000000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aaaaaa0000000aaaaaa00000aaaaaaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0aaaa00000aaaaaaa00000aaaaaaa000aa0000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa00aaaa000aaaa00aaa000aaa000aa000aa000aaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa000aaa000aaa000aaa000aaa00aaa000aa00aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000aaa00aa000aaaaa00aa000aaa000aa00aaa00aaa00000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa0000aaaa0aa000aaaaa00aaa0aaaa000aa00aa0000aa00000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa00000aaa0aaaaaaa0aa00aaaaaaaa000aa00aaa00aaa00000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa000000aa0aaaaaaa0aa000aaaaaaa000aa00aaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000aaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010f00000015000100001000010000150001000010000100001500010000100001000015000100001000010004150001000010000100041500010000100001000215000100001000010002150001000010000100
010f00000075100751007010070100751007510070100701007510075100701007010075100751007010070104751047510070100701047510475100701007010275102751007010070102751007010000000000
010f000007150001000010004150001500010000150001000010000100001000b1500015000100001500010004150001000010002150041500010004150001000215000100001000000002150000000615000000
010f00000015000000041500000000000041500000000000001500000007150000000000007150000000000004150000000715000000000000715000000061500215000000021500000002150000000215000000
910f00000c3551035513355173550c3551035513355173550c3551035513355173550c3551035513355173551035513355173550e3551035513355173550e3550e35512355153550e3550e35512355153550e355
010f00001075110751107511075110751107511075110751107511075110751107511075110751107511075110751107511075110751107511075110751107510e7510e7510e7510e7510e7510e7510e7510e751
010f00001375113751137511375113751137511375113751137511375113751137511375113751137511375113751137511375113751137511375113751137511275112751127511275112751127511275112751
010f00000c7510c7510c7510c7510c7510c7510c7510c7510c7510c7510c7510c7510c7510c7510c7510c7510b7510b7510b7510b7510b7510b7510b7510b7510975109751097510975109751097510975109751
310f0000235500050023550005002155000500005001c5001e5001c5001c5501e5501f550005001f5001f5501c550005001c5001f5001f5001c5501f5501c5001e5501c5001a5501e55021550005002155000500
010f00002b7502b7502b7502b7502f75000700007002b7502f75000700007000070000700007000070000700287502875028750287502b75000700007002b7502a75000700007000070000700007000070000700
010f00002b55500005000052a5550000500005285550000528555000050000524505245050000528555000052855528505000052b55500005000052b555000052a5550000500005000052a555000052a55500005
010f00002b5512b5512b5052b5512b5512b50128551285512b5512b5512b5002b5002b5052b5012b5512b55128551285512f505000002f505000002f505285002a5512a5512a505287012a5512a5512a5512a551
010f0000006540060400604006042b654006040060400604006040060400604006042b654006040060400604006540060400604006042b65400604006040060400604006042b654006042b654006040060400604
910f00002f65500000000002b65500000000002b655000002f65500000000002b65500000000002b655000002f65500000000002b65500000000002b655000002f65500000000002b65500000000002b65500000
910f00002f655000002f6000000000000000002f6512f6012f655000000000000000000000000000000000002f65500000000002f65500000000002f6512f6012f6550000000000000002f655000000000000000
910f00002f6550000000000000002f6550000000000000002f6550000000000000002f6550000000000000002f6550000000000000002f6550000000000000002f6550000000000000002f655000000000000000
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


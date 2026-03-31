tw, th = term.getSize()

levsize = vector.new(tw, th-1)

function RandPos()
    p = vector.new(math.random(3, tw-2), math.random(3, th-2))
    return p
end

prog = true
game = "live"
touchcontrols = false

fruitcol = colors.red

scol = colors.green
sheadcol = colors.lime

deadcol = colors.red

s = RandPos()
sp = vector.new(0, 0)
seg = {}
f = RandPos()
dir = "stop"

hardmode = false


score = 0
sleeptime = 0.15

function ClearScreen()
    tw, th = term.getSize()
    term.clear()
end
function ResetDraw()
    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.black)
end
function DrawFrame()
    paintutils.drawBox(1, 1, tw, th, colors.brown)
    ResetDraw()
end
function DrawSnake()
    paintutils.drawPixel( s.x, s.y, sheadcol)
    ResetDraw()
end
function DrawBody()
    if #seg > 0 then
        for i=1, #seg do
            paintutils.drawPixel(seg[i].x, seg[i].y, scol)
        end
    end
    ResetDraw()
end
function DrawFruit()
    paintutils.drawPixel(f.x, f.y, fruitcol)
    ResetDraw()
end
function DrawTouchGuide()
    n = 20
    paintutils.drawLine(s.x-n, s.y-n, s.x+n, s.y+n, colors.gray)
    paintutils.drawLine(s.x+n, s.y-n, s.x-n, s.y+n, colors.gray)
    ResetDraw()
end

function Move()
    sp.x = s.x
    sp.y = s.y
    if dir == "up" and s.y > 1 then
        s.y = s.y - 1
    end
    if dir == "down" and s.y < th then
        s.y = s.y + 1
    end
    if dir == "left" and s.x > 1 then
        s.x = s.x - 1
    end
    if dir == "right" and s.x < tw then
        s.x = s.x + 1
    end
end
function MoveBody()
    if #seg > 0 then
        table.remove(seg, 1)
        AddSeg()
    end
end

function CheckEat()
    if s == f then
        f = RandPos()
        score = score + 1
        if hardmode then
            sleeptime = 0.15 - (score/500)
        end
        AddSeg()
        AddSeg()
    end
end

function CheckCollide()
    for i=1,#seg do
        if s == seg[i] then
            Kill()
        end
    end
    if game == "live" then
        if s.x == 1 or s.x == tw or s.y == 1 or s.y == th then
         Kill()
        end
    end
end

function Kill()
    sheadcol = deadcol
    scol = deadcol
    game = "fail"
    sleeptime = 0.1
end

function AddSeg()
    seg[#seg+1] = vector.new(sp.x, sp.y)
end

function PrintScore()
    term.setCursorPos(2, th-1)
    print("SCORE: " .. score)
    if game == "fail" then
        term.setCursorPos((tw/2)-4, th/2)
        print("GAME OVER!") 
        term.setCursorPos((tw/2)-10, th/2+1)
        print("Press any key to exit.")
    end
    ResetDraw()
end

function BetAng(n, u, l)
    -- n = angle
    -- u = upper angle
    -- l = lower angle
    b = false
    if l > u then
       if BetAng(n, 180, l) or BetAng(n, u, -180) then
           b = true
       end
    else
       if n >= l and n <= u then
           b = true
       end  
    end
    return b
end

function GameRunner()
    while true do
        sleep(sleeptime)
        if game == "live" then
            Move()
            MoveBody()
            CheckEat()
            CheckCollide()
        else 
            table.remove(seg, 1) 
            if #seg <= 0 then
                prog = false
            end
        end
        ClearScreen()
        PrintScore()
        if touchcontrols == true then
            DrawTouchGuide()
        end
        DrawFrame()
        DrawBody()
        DrawSnake()
        DrawFruit()
        
    end
end

function TakeInput()
    while prog == true do
        local _, key, held = os.pullEvent("key")
        touchcontrols = false
        if key == keys.up and dir ~= "down" then
            dir = "up"
        end
        if key == keys.down and dir ~= "up" then
            dir = "down"
        end
        if key == keys.left and dir ~= "right" then
            dir = "left"
        end
        if key == keys.right and dir ~= "left" then
            dir = "right"
        end
    end
end

function TakeTouch()
    while prog == true do
        local e, b, x, y = os.pullEvent("monitor_touch")
        touchcontrols = true
        a = math.atan2(y-s.y , x-s.x)
        term.setCursorPos(1, 1)
        
        a = a * ( 180 / math.pi )
        
        --print( a )
        
        if BetAng(a, -45, -135)  and dir ~= "down" then
            dir = "up"
        elseif BetAng(a, 135, 45) and dir ~= "up" then
            dir = "down"
        elseif BetAng(a, -135, 135) and dir ~= "right" then
            dir = "left"
        elseif BetAng(a, 45, -45) and dir ~= "left" then
            dir = "right"
        end
    end
end

parallel.waitForAny(GameRunner, TakeInput, TakeTouch)


function init()
    scr = vector.new(term.getSize())
    workdir = fs.getDir(shell.getRunningProgram())
    prog = true
    slp = 0.033
    --fields and code here
    shapepop = 3
    shapes = {}
    pointpop = shapepop*3
    points = {}
    pointsdata = {}
    pointspool = {}
    
	col = {"7","8","0"}
	
    for i=1, pointpop do
        points[i] = vector.new(0, 0, ((math.pi*2)/pointpop) * i )
        pointsdata[i] = math.random(5, 10)/100
        pointspool[i] = i
    end
	
    for i=1, shapepop do
		shapes[i] = vector.new()
		t = {}
		
		for x=1, 3 do
			t[x] = x + (3*(i-1))
		end
		shapes[i].x = t[1]
		shapes[i].y = t[2]
		shapes[i].z = t[3]
    end
    
end
init()

function main()
    while prog == true do
        sleep(slp)
        scr.x, scr.y = term.getSize()
        --main loop here
        for i=1, pointpop do
            points[i].z = points[i].z + pointsdata[i]
            
            points[i].x = (scr.x/2) + math.cos(points[i].z)*(scr.x/2.5)
            points[i].y = (scr.y/2) + math.sin(points[i].z)*(scr.y/2.5)
        end
        draw()
    end
end

function draw()
    term.setBackgroundColor(colors.black)
    term.clear()
    for i=1, pointpop do
        --paintutils.drawPixel(points[i].x, points[i].y, colors.white)
    end
    
    for i=1, shapepop do
		c = col[i]
	--print(points[i])
	--print(shapes[i])
        paintutils.drawLine(points[shapes[i].x].x, points[shapes[i].x].y, points[shapes[i].y].x, points[shapes[i].y].y, colors.fromBlit(c))
		paintutils.drawLine(points[shapes[i].y].x, points[shapes[i].y].y, points[shapes[i].z].x, points[shapes[i].z].y, colors.fromBlit(c))
		paintutils.drawLine(points[shapes[i].z].x, points[shapes[i].z].y, points[shapes[i].x].x, points[shapes[i].x].y, colors.fromBlit(c))
    end
end

function input()
    while prog == true do
        sleep(slp)
        local event, key, held = os.pullEvent("key")
         --inputs here
    end
end

parallel.waitForAny(main, input)

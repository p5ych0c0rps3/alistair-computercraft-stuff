function init()
    scr = vector.new(term.getSize())
    workdir = fs.getDir(shell.getRunningProgram())
    prog = true
    --fields and code here
	col_theme = {}
	
	if fs.exists(workdir.."/nbstudio_theme") == true then
		col_theme = paintutils.loadImage(workdir.."/nbstudio_theme")
	end
	
	col_theme = { colors.white, colors.lightGray, colors.gray, colors.black, colors.green }
	
	if fs.exists(workdir.."/bg3.nfp") == true then
		ast_background = paintutils.loadImage(workdir.."/bg3.nfp")
	end
	margin = vector.new(2, 3)
	scroll = vector.new(0, 0)
	octave = 1
	showguide = false
	guide = vector.new()
	
	--note
	active = 1
	monitor = peripheral.find("monitor")
	speaker = peripheral.find("speaker")
	note = { "F#", "G ", "G#", "A ", "A#", "B ", "C ", "C#", "D ", "D#", "E ", "F " }
	inst = { "harp", "basedrum", "snare", "hat", "bass", "flute", "bell", "guitar", "chime", "xylophone", "iron_xylophone", "cow_bell", "didgeridoo", "bit", "banjo", "pling" }
	instname = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G" }

end
init()

function pianorollDrawRow(i, x, o)
	local _color
	if string.find(note[i], "#") ~= nil then
		_color = colors.black
	else	
		_color = colors.white
	end
	paintutils.drawLine(margin.x+x, margin.y, margin.x+x, scr.y, _color)
	term.setCursorPos(1, 1)
	--write("PROG. ")
	for i=1, #inst  do
		if i == active then
			term.setTextColor(colors.black)
			term.setBackgroundColor(colors.white)
		else
			term.setTextColor(colors.white)
			term.setBackgroundColor(colors.black)
		end
		--term.setCursorPos(1 + ( 3 * (i-1) ), 1)
		write(instname[i])
	end
	term.setBackgroundColor(colors.gray)
	term.setCursorPos(1, 2)
	write("PROG.")
end

function pianorollDraw()
	if pause == false then
		paintutils.drawLine(margin.x+songpos+scroll.x, margin.y+1, margin.x+songpos+scroll.x, margin.y+25+scroll.y, col_theme[5])
	end
	term.setBackgroundColor(col_theme[4])
	for o=1, 2 do
		for i=1, #note do
			pianorollDrawRow(i, i+(#note*(o-1)), o)
		end
	end
	pianorollDrawRow(1, #note*2+1, 3)
	--pianorollDrawNotes()
end

function notePlayNote(sound, volume, note)
	if note ~= nill and speaker ~= nil then
			speaker.playNote(inst[sound], volume, note-1)
	end
end

function main()
    while prog == true do
        sleep(0.1)
		term.setBackgroundColor(colors.gray)
		monitor.clear()
        --main loop here
		pianorollDraw()
    end
end

function input()
    while prog == true do
        sleep(0.1)
        local _event, _side, _x, _y = os.pullEvent("monitor_touch")
         --inputs here
		if _y >= margin.y and _x > margin.x and _x <= 25+margin.x then
			if _y <= margin.y then
				v = 0.25
			elseif _y == margin.y+1 then
				v = 0.5
			elseif _y == margin.y+2 then
				v = 0.75
			elseif _y >= margin.y+3 then
				v = 0.1
			end
			notePlayNote(active, v , _x-margin.x)
		elseif _y == 1 then
			active = _x
		end
    end
end

function inputMouseClick()
    while prog == true do
        sleep(dt)
        local _event, _b, _x, _y = os.pullEvent("mouse_click")
         --inputs here
		if _y >= margin.y and _x > margin.x and _x <= 25+margin.x then
			if _y <= margin.y then
				v = 0.25
			elseif _y == margin.y+1 then
				v = 0.5
			elseif _y == margin.y+2 then
				v = 0.75
			elseif _y >= margin.y+3 then
				v = 0.1
			end
			notePlayNote(active, v , _x-margin.x)
		elseif _y == 1 then
			active = _x
		end
    end
end
term.redirect(monitor)
parallel.waitForAny(main, input, inputMouseClick)

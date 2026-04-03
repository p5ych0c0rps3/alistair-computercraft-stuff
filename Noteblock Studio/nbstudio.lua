function init()
	dt = 0
	scrprev = vector.new()
    scr = vector.new(term.getSize())
    workdir = fs.getDir(shell.getRunningProgram())
    prog = true
	--os.loadAPI(workdir.."/note.lua")
	--os.loadAPI(workdir.."/pianoroll.lua")
	--os.loadAPI(workdir.."/player.lua")
	--player.setWorkdir(workdir)
    --fields and code here
	
	--input
	shift = false
	
	--editing
	activeTrack = 1
	hit = {}
	drawhit = false
	tempdir = (workdir.."/nbstudio_temp")
	
	--pianoroll
	col_theme = {}
	
	if fs.exists(workdir.."/nbstudio_theme") == true then
		col_theme = paintutils.loadImage(workdir.."/nbstudio_theme")
	end
	
	col_theme = { colors.white, colors.lightGray, colors.gray, colors.black, colors.green }
	
	if fs.exists(workdir.."/bg3.nfp") == true then
		ast_background = paintutils.loadImage(workdir.."/bg3.nfp")
	end
	margin = vector.new(17, 3)
	scroll = vector.new(0, 0)
	octave = 1
	showguide = false
	guide = vector.new()
	
	--player
	songdata = {}
	rate = 0.1
	pause = true
	songpos = 1
	bpm = 120
	activevol = 1.0
	
	--note
	speaker = peripheral.find("speaker")
	note = { "F#", "G ", "G#", "A ", "A#", "B ", "C ", "C#", "D ", "D#", "E ", "F " }
	inst = { "harp", "basedrum", "snare", "hat", "bass", "flute", "bell", "guitar", "chime", "xylophone", "iron_xylophone", "cow_bell", "didgeridoo", "bit", "banjo", "pling" }
	instname = { "Harp", "Kick", "Snare", "Hat", "Bass", "Flute", "Bell", "Guitar", "Chime", "Xylo", "Xylo2", "Cow Bell", "Didgeridoo", "Square", "Banjo", "Pling" }

end
init()

--Pianoroll
function pianorollScroll(_x, _y)
	if scroll.x-_x <= 0 then scroll.x = scroll.x - _x end
	if scroll.y-_y <= 0 and scroll.y-_y >= (-28+scr.y) then scroll.y = scroll.y - _y end
end

function pianorollDrawRow(i, y, o)
	local _color
	local _tcolor
	if string.find(note[i], "#") ~= nil then
		_color = colors.black
		_tcolor = colors.white
	else	
		_color = colors.white
		_tcolor = colors.black
	end
	for a=1,2 do
		if a == 1 then
			paintutils.drawPixel((margin.x-2)+a, margin.y+y+scroll.y, _color)
		else
			paintutils.drawPixel((margin.x-2)+a, margin.y+y+scroll.y, colors.white)
		end
	end
	term.setCursorPos((margin.x-4), margin.y+y+scroll.y)
	term.setBackgroundColor(col_theme[4])
	term.setTextColor(col_theme[1])
	write(note[i]..o)
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

function pianorollDrawNotes()
	term.setCursorPos(1, 1)
	for t=1, #songdata[activeTrack] do
		for c=1, #songdata[activeTrack][t] do
			if songdata[activeTrack][t][c][1] ~= nil then
				paintutils.drawPixel(margin.x+t+scroll.x, margin.y+songdata[activeTrack][t][c][1]+scroll.y, col_theme[1])
			end
		end
	end
end

function drawBackground()
	if ast_background ~= nil then
		for i=1, math.ceil(scr.x/16) do
		paintutils.drawImage(ast_background, margin.x+(16*(i-1))+1, margin.y+1)
		end
	end
end

function writeBarVals()
	for i=1, math.ceil(scr.x/4) do
		term.setCursorPos(margin.x+(16*(i-1))+1, margin.y)
		write( ((math.abs(scroll.x)+(16*(i-1))) / 16)+1 )
	end
end

function drawGuide()
	paintutils.drawPixel(guide.x, guide.y, col_theme[1])
end
	
function pianorollAddNote(_x, _y, _inst)
	local _scrpos = vector.new(_x-scroll.x-margin.x, _y-scroll.y-margin.y)
	if _scrpos.x > 0 and _scrpos.y > 0 and _scrpos.y <=25 then
	
		local _track = songdata[activeTrack]
		if #_track < _scrpos.x then
			for i=1+#_track, _scrpos.x do
				songdata[activeTrack][i] = {} 
			end
		end
		
		local _chord = _track[_scrpos.x]
		if #_chord == 0 then songdata[activeTrack][_scrpos.x][1] = {} end
		
		local _note = {_scrpos.y, activevol}
		
		songdata[activeTrack][_scrpos.x][#_chord+1] = _note

	end
	draw()
	playerSaveSong(tempdir)
end

function pianorollRemoveNote(_x, _y)
	local _scrpos = vector.new(_x-scroll.x-margin.x, _y-scroll.y-margin.y)
	if _scrpos.x > 0 and _scrpos.y > 0 and _scrpos.y <=25 then
	
	
		--local _track = songdata[activeTrack]
		--if #_track < _scrpos.x then
		--	for i=1+#_track, _scrpos.x do
		--		songdata[activeTrack][i] = {} 
		--	end
		--end
		
		local _note = {_scrpos.y, 1}
		local _chord = songdata[activeTrack][_scrpos.x]
		local _toremove = 0
		if _chord ~= nil then
			for i=1, #_chord do
				if _note[1] == _chord[i][1] then
					_toremove = i
				end
			end
			if _toremove > 0 then
				table.remove(songdata[activeTrack][_scrpos.x], _toremove)
			end
		end
		--term.setBackgroundColor(colors.black)
		--print(_chord)
	end
	playerSaveSong(tempdir)
end

--Player
function playerLoadSong(filepath)
	if fs.exists(filepath) then
		--songdata = lUtils.asset.load(filepath)
		local file = fs.open(filepath, "r")
		local _data = file.readAll()
		if _data ~= nil then
			playerLoadSongTable(textutils.unserialise(_data))
		else
			playerNewSong()
		end
		--play()
	end
end

function playerLoadSongTable(data)
	songdata = data
	bpm = songdata[17]
	rate = ((60000/songdata[17])/10000)/0.5
	songpos = 1
	changeActiveTrack(1)
	--play()
end

function playerNewSong()
	local _data = { {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, 120 }
	playerLoadSongTable(_data)
end

function playerSaveSong(path)
	local file = fs.open(path, "w+")
	file.write(textutils.serialise(songdata))
end

function playerPlay()
	songpos = 1
	pause = false
	while pause == false do
		sleep(rate)
		local _done = true
		--Instrument ring
		for t=1,#songdata-1 do
			local _track = songdata[t]
			local _chord = _track[songpos]
			if _chord ~= nil then
				_done = false
				for c=1, #_chord do
					local _unit = _chord[c]
					if _unit ~= nil then
						notePlayNote(t, _unit[2], _unit[1])
					end
				end
			end
		end
		songpos = songpos + 1
		if _done == true then
			--songpos = 1
			--break
		end
		draw()
	end
end

--Note
function notePlayNote(sound, volume, note)
	if note ~= nill and note > 0 and note <= 25 then
		if note > -1 then
			speaker.playNote(inst[sound], volume, note-1)
			drawhit = true
			hit[#hit+1] = note
		end
	end
end


--Main
function changeActiveTrack(totrack)
	--if songdata[totrack] == nil then
	--	songdata[totrack+1] = {}
	--end
	if totrack <= #inst then
		activeTrack = totrack
		notePlayNote(activeTrack, 1, 7)
	end
end

function drawOverUi()
	--x margin box
	paintutils.drawFilledBox(1, 1, margin.x-5, scr.y, col_theme[3])
	--y margin box
	paintutils.drawFilledBox(1, 1, scr.x, margin.y, col_theme[3])
	paintutils.drawLine(margin.x+2, margin.y, scr.x, margin.y, col_theme[4])
	writeEx("Noteblock Studio v1", 1, 1, col_theme[3], col_theme[1])
	writeEx("BPM", 1, 2, col_theme[3], col_theme[1])
	writeEx("<"..require "cc.strings".ensure_width(tostring(bpm), 3)..">", 5, 2, col_theme[4], col_theme[1])
	writeEx("VOL", 11, 2, col_theme[3], col_theme[1])
	writeEx("<"..require "cc.strings".ensure_width(tostring(activevol), 3)..">", 15, 2, col_theme[4], col_theme[1])
end

function writeEx(_string, _x, _y, _bgcol, _tcol)
	local _tbgcol = term.getBackgroundColor()
	local _ttcol = term.getTextColor()
	
	term.setCursorPos(_x, _y)
	term.setBackgroundColor(_bgcol)
	term.setTextColor(_tcol)
	write(_string)
	
	term.setBackgroundColor(_tbgcol)
	term.setTextColor(_ttcol)
end

function updateBPM(_v)
	if bpm > 20 and bpm < 255 then
		bpm = bpm + _v
		rate = ((60000/bpm)/10000)/0.5
		songdata[17] = bpm
		playerSaveSong(tempdir)
	end
end

function updateVol(_v)
	if activevol+_v >= 0 and activevol+_v <= 1 then
		activevol = activevol + _v
	end
end

function resetDraw()
	term.setBackgroundColor(col_theme[4])
	term.clear()
end

function main()
	draw()
    while prog == true do
        sleep(dt)
		scrprev.x = scr.x
		scrprev.y = scr.y
		scr.x, scr.y = term.getSize()
		if scrprev ~= scr then
			scroll.x = 0
			scroll.y = 0
			draw()
		end
		if showguide == true then
			drawGuide()
		end
		if pause == false then
			playerPlay()
		end
	
		
        --main loop here
		--pianoroll.scr = scr
		
		--draw()
    end
end

function listInst()
	for i=1, #inst do
		if i == activeTrack then
			writeEx(require "cc.strings".ensure_width(instname[i], 12), 1, margin.y+i, col_theme[1], col_theme[4])
		else
			writeEx(require "cc.strings".ensure_width(instname[i], 12), 1, margin.y+i, col_theme[4], col_theme[1])
		end
	end
end

function draw()
	resetDraw()
	drawBackground()
	while drawhit do
		for i=1, #hit do
			paintutils.drawLine(margin.x+1, margin.y+hit[i]+scroll.y, scr.x, margin.y+hit[i]+scroll.y, col_theme[3])
		end
		drawhit = false
		hit = {}
	end
	pianorollDrawNotes()
	pianorollDraw()
	drawOverUi()
	writeBarVals()
	listInst()
	
end

function inputKey()
    while prog == true do
        sleep(dt)
        local event, key, held = os.pullEvent("key")
         --inputs here
		if key == keys.space then
			pause = not pause	
			hit = {}
		elseif key == keys.up then
			pianorollScroll(0, -1)
		elseif key == keys.down then
			pianorollScroll(0, 1)
		elseif key == keys.left then
			pianorollScroll(-16, 0)
		elseif key == keys.right then
			pianorollScroll(16, 0)
			
		elseif key == keys.leftShift then
			shift = true
		elseif key == keys.a then
			notePlayNote(activeTrack, 1, 1)
		elseif key == keys.z then
			notePlayNote(activeTrack, 1, 2)
		elseif key == keys.s then
			notePlayNote(activeTrack, 1, 3)
		elseif key == keys.x then
			notePlayNote(activeTrack, 1, 4)
		elseif key == keys.d then
			notePlayNote(activeTrack, 1, 5)
		elseif key == keys.c then
			notePlayNote(activeTrack, 1, 6)
		elseif key == keys.v then
			notePlayNote(activeTrack, 1, 7)
		elseif key == keys.g then
			notePlayNote(activeTrack, 1, 8)
		elseif key == keys.b then
			notePlayNote(activeTrack, 1, 9)
		elseif key == keys.h then
			notePlayNote(activeTrack, 1, 10)
		elseif key == keys.n then
			notePlayNote(activeTrack, 1, 11)
		elseif key == keys.m then
			notePlayNote(activeTrack, 1, 12)
		elseif key == keys.one then
			notePlayNote(activeTrack, 1, 13)
		elseif key == keys.q then
			notePlayNote(activeTrack, 1, 14)
		elseif key == keys.two then
			notePlayNote(activeTrack, 1, 15)
		elseif key == keys.w then
			notePlayNote(activeTrack, 1, 16)
		elseif key == keys.three then
			notePlayNote(activeTrack, 1, 17)
		elseif key == keys.e then
			notePlayNote(activeTrack, 1, 18)
		elseif key == keys.r then
			notePlayNote(activeTrack, 1, 19)
		elseif key == keys.five then
			notePlayNote(activeTrack, 1, 20)
		elseif key == keys.t then
			notePlayNote(activeTrack, 1, 21)
		elseif key == keys.six then
			notePlayNote(activeTrack, 1, 22)
		elseif key == keys.y then
			notePlayNote(activeTrack, 1, 23)
		elseif key == keys.u then
			notePlayNote(activeTrack, 1, 24)
		elseif key == keys.eight then
			notePlayNote(activeTrack, 1, 25)
		end
		draw()
    end
end

function inputKeyUp()
    while prog == true do
        sleep(dt)
        local event, key = os.pullEvent("key_up")
         --inputs here
		if key == keys.leftShift then
			shift = false
		end
		draw()
    end
end

function inputMouseWheel()
    while prog == true do
        sleep(dt)
        local _event, _dir, _x, _y = os.pullEvent("mouse_scroll")
		
		if shift == false then
			pianorollScroll(0, _dir)
		else
			pianorollScroll(_dir*16, 0)
		end
		draw()
    end
end

function inputMouseUp()
    while prog == true do
        sleep(dt)
		
        local _event, _b, _x, _y = os.pullEvent("mouse_up")
         --inputs here
		if _b == 1 then
			if _x > margin.x and _y > margin.y then
				pianorollAddNote(_x, _y, 1)
			elseif _x < margin.x-4 and _y > margin.y then
				changeActiveTrack(_y-margin.y)
			end
		elseif _b == 2 then
			if _x > margin.x and _y > margin.y then
				pianorollRemoveNote(_x, _y, 1)
			end
		end
		showguide = false
		draw()
    end
end

function inputMouseClick()
    while prog == true do
        sleep(dt)
		
        local _event, _b, _x, _y = os.pullEvent("mouse_click")
         --inputs here
		if _x > margin.x and _y > margin.y then
			if _b == 1 then
				showguide = true
				guide.x = _x
				guide.y = _y
				notePlayNote(activeTrack, 1, _y-scroll.y-margin.y)
			end
		elseif _x > margin.x and _y == margin.y then
			if _b == 1 then
				scroll.x = (16*((_x - margin.x)-1))*-1
			end
		elseif _x == 9 and _y == 2 then
			updateBPM(1)
		elseif _x == 5 and _y == 2 then
			updateBPM(-1)
		elseif _x == 15 and _y == 2 then
			updateVol(-0.1)
		elseif _x == 19 and _y == 2 then
			updateVol(0.1)
		end
		draw()
    end
end

function inputMouseDrag()
    while prog == true do
        sleep(dt)
		
        local _event, _b, _x, _y = os.pullEvent("mouse_drag")
         --inputs here
		if _x > margin.x and _y > margin.y then
			
			if _b == 1 then
				guide.x = _x
				guide.y = _y
				notePlayNote(activeTrack, 1, _y-scroll.y-margin.y)
			end
		elseif _x > margin.x and _y == margin.y then
			if _b == 1 then
				scroll.x = (16*((_x - margin.x)-1))*-1
			end
		end
		
		if _b == 2 then
			if _x > margin.x and _y > margin.y then
				pianorollRemoveNote(_x, _y, 1)
			end
		end
		draw()
    end
end

if fs.exists(tempdir) then
	playerLoadSong(tempdir)
else
	playerNewSong()
end
parallel.waitForAny(main, inputKey, inputKeyUp, inputMouseWheel, inputMouseUp, inputMouseClick, inputMouseDrag)

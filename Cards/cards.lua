local func = {}

func.suit = { {"", colors.red} , {"", colors.red} , {"", colors.black} , {"", colors.black} }
func.value = {{"A",10},{2, 2},{3, 3},{4, 4},{5, 5},{6, 6},{7, 7},{8, 8},{9, 9},{10, 10},{"J", 10},{"Q", 10},{"K", 10}}
--card = {}

local scr = vector.new(term.getSize())

local suit_layout = {
	{
		{" "," "," "},
		{" ","s"," "},
		{" "," "," "},
		{" "," "," "},
	},
	{

		{" ","s"," "},
		{" "," "," "},
		{" ","s"," "},
		{" "," "," "},
	},
	{
		{" ","s"," "},
		{" ","s"," "},
		{" ","s"," "},
		{" "," "," "},

	},
	{
		{"s"," ","s"},
		{" "," "," "},
		{" "," "," "},
		{"s"," ","s"},
	},
	{
		{"s"," ","s"},
		{" ","s"," "},
		{" "," "," "},
		{"s"," ","s"},
	},
	{
		{"s"," ","s"},
		{"s"," ","s"},
		{"s"," ","s"},
		{" "," "," "},
	},
	{
		{"s"," ","s"},
		{"s","s","s"},
		{" "," "," "},
		{"s"," ","s"},
	},
	{
		{"s"," ","s"},
		{"s"," ","s"},
		{"s"," ","s"},
		{"s"," ","s"},
	},
	{
		{"s"," ","s"},
		{"s","s","s"},
		{"s"," ","s"},
		{"s"," ","s"},
	},
	{
		{"s"," ","s"},
		{"s","s","s"},
		{"s","s","s"},
		{"s"," ","s"},
	},
	{
		{" ","","|"},
		{"/","","/"},
		{"/","","/"},
		{"|",""," "},
	},
	{
		{" ","",""},
		{"/","#","/"},
		{"/","#","/"},
		{"",""," "},
	},
	{
		{" ","","|"},
		{"/","#","/"},
		{"/","#","/"},
		{"|",""," "},
	},
}		

local card_color = colors.white

local card_size_small = vector.new(3, 4)
local card_size_big =	vector.new(5, 6)

local card_suitpos_small = { vector.new(1, 1) , vector.new(card_size_small.x , card_size_small.y) }
local card_suitpos_big = { vector.new(1, 1) , vector.new(card_size_big.x , card_size_big.y) }

local card_valuepos_small = vector.new(2, 2)
local card_valuepos_big = vector.new(card_size_big.x/2, card_size_big.y/2)

local card_small = true

func.create = function(_suit, _value)
	local _card = {}
	_card.suitString = func.suit[_suit][1]
	_card.suitColor	= func.suit[_suit][2]
	_card.valueString = func.value[_value][1]
	_card.valueScore = func.value[_value][2]
	_card.suitID = _suit
	_card.valueID = _value
	_card.pos = vector.new(1, 1)
	return _card
end

local function cardWrite(_string, _x, _y)
	local scr = vector.new(term.getSize())
	if _x <= scr.x and _y <= scr.y then
		term.setCursorPos(_x, _y)
		write(_string)
	end
end

func.drawSmall = function(_card)
	scr = vector.new(term.getSize())
	paintutils.drawFilledBox(_card.pos.x, _card.pos.y, card_size_small.x + (_card.pos.x-1), card_size_small.y + (_card.pos.y-1), card_color)
	for i=1,#card_suitpos_small do
	
		local _pos = vector.new(card_suitpos_small[i].x + (_card.pos.x-1) , card_suitpos_small[i].y + (_card.pos.y-1))
		
		term.setTextColor(_card.suitColor)
		cardWrite(_card.suitString, _pos.x, _pos.y)
	end
	term.setCursorPos(card_valuepos_small.x + (_card.pos.x-1) , card_valuepos_small.y + (_card.pos.y-1))
	write(_card.valueString)
end

func.drawBig = function(_card)
	scr = vector.new(term.getSize())
	paintutils.drawFilledBox(_card.pos.x, _card.pos.y, card_size_big.x + (_card.pos.x-1), card_size_big.y + (_card.pos.y-1), card_color)
	for i=1,#card_suitpos_big do
		term.setTextColor(_card.suitColor)
		if card_suitpos_big[i].x==card_size_big.x and _card.valueString==10 then
			local _pos = vector.new(card_suitpos_big[i].x-1 + (_card.pos.x-1) , card_suitpos_big[i].y + (_card.pos.y-1))
			
			cardWrite(_card.valueString, _pos.x, _pos.y)
		else
			local _pos = vector.new(card_suitpos_big[i].x + (_card.pos.x-1) , card_suitpos_big[i].y + (_card.pos.y-1))
			
			cardWrite(_card.valueString, _pos.x, _pos.y)
		end
	end
	for i=1, #suit_layout[_card.valueID] do
		local _pos = vector.new(2 + (_card.pos.x-1), 1+i + (_card.pos.y-1))
		for c=1, #suit_layout[_card.valueID][i] do
			cardWrite(string.gsub(suit_layout[_card.valueID][i][c], "s", _card.suitString), _pos.x+(c-1), _pos.y)
		end
	end
end

func.draw = function(_small, _card)
	term.clear()
	if _small == true then
		func.drawSmall(_card)
	else
		func.drawBig(_card)
	end
end

return func

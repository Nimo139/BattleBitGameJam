-- title:  Katzu
-- author: kleeder, Nimo, BotA, alili1996
-- desc:   BotB Game Jam 3
-- script: lua

-- t: updates every frame (60fps)
-- modes: used to change current state of game

t = 0
mode_menu = 1
mode_prelevel = 2
mode_level = 3
mode_music = 4
mode_clear = 5
mode_done = 6
mode_playMusic = 7
mode_controls = 8
mode_debug = false
mode=mode_menu

woolStringLength = {2400,2000,2000,2000,1000}  -- for each level
size = 0  --unnötig nötige variable für die destroy animation

playerStartPos = {
	{10, 88, 10, 88, 10, 72, 10, 120, 0, 0, 0, 0, 0, 0},  --level 1: Room 1 x,y, Room 2 x,y, x3,y3, ...
	{10, 120, 10, 120, 10, 112, 10, 104, 10, 0, 10, 0, 10, 0},	 --level 2: ...
	{10, 88, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0},
	{10, 88, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0},
	{10, 88, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0}}
woolStartPos = {
	{24, 88, 24, 88, 24, 72, 24, 120, 0, 0, 0, 0, 0, 0},  --level 1:
	{24, 120, 24, 120, 24, 112, 24, 104, 24, 0, 24, 0, 24, 0},	 --level 2: ...
	{24, 88, 24, 0, 24, 0, 24, 0, 24, 0, 24, 0, 24, 0},
	{24, 88, 24, 0, 24, 0, 24, 0, 24, 0, 24, 0, 24, 0},
	{24, 88, 24, 0, 24, 0, 24, 0, 24, 0, 24, 0, 24, 0}}


function init()
    --solids={[2]=true,[3]=true}
	levelCounter = pmem(1) -- increments after every finished level
	music (1,0,7,false) --menu theme
	p={
	x=0,
	y=0,
	vx=0, --Velocity X
	vy=0, --Velocity Y
	o =0, --orientation
	f =0, --falling
	p =0, --punch
	}
	
	initHold = false
	
	--cam={x=120,y=68}
	
	--Jumping physics
	btn0released = true
	
	inRoomNr = 64
	rooms = {}
	for y = 0,136-17,17 do
		for x = 0,240-30,30 do
			table.insert(rooms, {x,y})
		end
	end
end

function rget(i)
 return rooms[i][1],rooms[i][2],30,17
end

-- mget recalculation for rooms 
function mget2(x,y, room)
	return mget(x+30*((room-1)%8), y + 17*((room-1)//8))
end

function setRoomNr(roomNr)
	inRoomNr = roomNr
end

-- is block id solid?  for player
function isSolid(id)
	return id >= 32 and id <= 79 or id >= 241 and id <= 246 or id == 247--#032-#079: Solid // also id 253: destroy-block
end

-- is block id solid? for wool
function isSolidWool(id)
	return id >= 32 and id <= 79 or id == 248--#032-#079: Solid // also id 253: destroy-block
end


-- is a block at x,y solid? (actual map view)

function solid(x,y)
    return isSolid(mget2((x)//8,(y)//8, inRoomNr))
end

--function solid(x,y)
--    return isSolid(mget2((x)//8,(y)//8, inRoomNr))
--end

function solidInRoom(x,y, room)
    return isSolidWool(mget2((x)//8,(y)//8, room))
end


function getGroundHeight(x, y)
	while (not solidInRoom(x ,y , w.room)) and (not solidInRoom(x-1 ,y , w.room)) and y < 132 do      -- 240 under level  
		y = y + 1
	end
	return y
end

function spawnPlayer()
	p={
		x=20,
		y=0,
		vx=0, --Velocity X
		vy=0, --Velocity Y
		o =0, --orientation
		f =0, --falling
		p =0, --punch
	}
	inRoomNr = 2 + levelCounter * 8 
	
	p.x = playerStartPos[(levelCounter+1)][1]
	p.y = playerStartPos[(levelCounter+1)][2]
end

function spawnWool(currentRoom)
	w={
		x = 28,
		y = 0,
		vx= 0,
		vy= 0,
		r = 0,
		room = currentRoom+1,
		goal = false,
		size = 0,
		track = {},
		length = {},
		respawn = false,
		stringLength = 0
	}
	
	w.x = woolStartPos[(levelCounter+1)][1]
	w.y = woolStartPos[(levelCounter+1)][2]
	
	--w.stringLength = 
end

function isPointInBlockID(x,y,room, id)
	return mget2((x)//8,(y)//8, room) == id
end

--check if a Sprite 8x8 touches a Block with the ID
function isWoolInBlockId(id)
	return isPointInBlockID(w.x+w.vx+4,w.y+w.vy, w.room, id) or isPointInBlockID(w.x+4,w.y+w.vy, w.room, id) 
		or isPointInBlockID(w.x+4+w.vx,w.y+4+w.vy, w.room, id) or isPointInBlockID(w.x+w.vx+4,w.y+4+w.vy, w.room, id) 

end

-- draws a parabel between 2 points
function cLine(x1,y1,x2,y2, color)
	
	dx = x2 - x1 
	dy = y2 - y1
	
	trackX = {}
	trackY = {}
	counter = 0
	
	if y1 >= y2 then 
		for x = x1, x2, 1 do
			y = y1 + dy/(dx*dx) * (x - x1) * (x - x1)
			--pix(x,y,color)
			trackX[counter] = x 
			trackY[counter] = y
			counter = counter + 1 
			--line(ox, oy, x, y, color)
		end
	else
		for x = x1, x2, 1 do
			y = y2 - dy/(dx*dx) * (x - x1) * (x - x1)
			--pix(x2-(x-x1),y,color)
			
			trackX[counter] = x2-(x-x1) 
			trackY[counter] = y
			counter = counter + 1
			--line(ox, oy, x, y, color)
		end
	end 
	
	for p=1, counter-1, 1 do 
		line(trackX[p-1], trackY[p-1], trackX[p], trackY[p], color) --connects pixels of parabel
	end
	
	
end 




-- is a wool at x,y? (actual map view)
function woolRight(x,y)
	return (math.abs(p.x+7-w.x)<0.5 and math.abs(p.y-w.y)<0.5)
end
function woolLeft(x,y)
	return (math.abs(p.x-7-w.x)<0.5 and math.abs(p.y-w.y)<0.5)
end

function woolInGoal(x,y)
	if mget2((x)//8,(y)//8, w.room) == 254 or mget2((x)//8,(y)//8, w.room) == 253 or mget2((x)//8,(y)//8, w.room) == 252 then 
		--set wool state to small/ fix pos -> end
		print("Level cleared!",81,26,0)
		print("Level cleared!",80,25,15)
		spr(255, (x//8)*8, (y//8)*8, 2, 1, 0, 0, 1, 1)
		w.size = 3
		w.goal = true
		line((x//8)*8 ,(y//8)*8+7 ,(x//8)*8+3,(y//8)*8+2,68)
	end
end


function respawn()
	p.o= 0
	--p.x = playerStartPos[(levelCounter) * 2 +1]
	--p.y = playerStartPos[(levelCounter) * 2 +2]		
	offset = inRoomNr - (2 + levelCounter * 8) 
	
	p.vy = 0
	p.x = playerStartPos[(levelCounter+1)][1+offset*2]
	p.y = playerStartPos[(levelCounter+1)][2+offset*2]
	
end

function respawnLevel()
	p.o= 0
	inRoomNr = 2 + levelCounter * 8 
	p.vy = 0
	p.x = playerStartPos[(levelCounter+1)][1]
	p.y = playerStartPos[(levelCounter+1)][2]
end



function resetLevel(levelCounter)
	setRoomNr( 2 + levelCounter * 8 )   -- 2 10 18 26 24  
end



--WOOL
	
-- wool physics
function woolUpdate()

	
	-- switch to next room 
	if w.x < 0 and w.room == 2 or w.x < 0 and w.room == 10 or w.x < 0 and w.room == 18 or w.x < 0 and w.room == 26 or w.x < 0 and w.room == 34 then
		w.x = 0
		w.room = w.room
	elseif w.x > 240 then 
		w.x = w.x - 240
		w.room = w.room + 1
		w.vx = w.vx + 1 
	elseif w.x < 0 and w.room > 1 then
		w.x = 232
		w.room = w.room - 1
		w.vx = w.vx - 1 
	end 
	
	if w.y > 128 then 
		respawnWool()
	end
	
	
	
	--specialBlocks 
	--destroy
	if isWoolInBlockId(241) or isWoolInBlockId(242) or isWoolInBlockId(243) or isWoolInBlockId(244) or isWoolInBlockId(245) or isWoolInBlockId(246) then
		destroyWool()
	end
	
	-- gravity 
    if solidInRoom(w.x,w.y+8+w.vy, w.room) or solidInRoom(w.x+7,w.y+8+w.vy, w.room) then
        w.vy=0
    else
        w.vy=w.vy+0.2
    end
	
	--wall left right 
	if solidInRoom(w.x+w.vx,w.y+w.vy, w.room) or solidInRoom(w.x+7+w.vx,w.y+w.vy, w.room) 
	or solidInRoom(w.x+w.vx,w.y+7+w.vy, w.room) or solidInRoom(w.x+7+w.vx,w.y+7+w.vy, w.room) then
        w.vx=0
    end
	
	if math.abs(w.vx) < 0.1 then
		w.vx = 0
	end
	
	if w.size <= 1 and w.respawn == false then 
		print("Wool empty!",81,36,0)
		print("Wool empty!",80,35,15)
		w.vx=0
		--w.vy=0
	end		
	
	if w.goal == false then 
		w.x=w.x+w.vx
		w.y=w.y+w.vy
	end

	
	if math.abs(w.vx) > 0.01 or math.abs(w.vy) > 0.01 then 
		w.track[w.room][w.length[w.room]*2]	= w.x//8*8											--save coordinates in table, alternate x1,y1,x2,y2,...
		w.track[w.room][w.length[w.room]*2 + 1] = getGroundHeight(w.x//8*8, w.y)
		w.length[w.room] = w.length[w.room] + 1
		w.stringLength = w.stringLength + math.abs(w.vx)
	end
	
	
	
	
	--calc woolSize with the diff of the level max length (woolStringLength) -  5 sizes  
	if w.respawn == false then 
		w.size = math.max(0,math.ceil(((woolStringLength[levelCounter+1] - w.stringLength) / woolStringLength[levelCounter+1]) * 4))
	end
	--print(math.ceil(((woolStringLength[levelCounter+1] - w.stringLength) / woolStringLength[levelCounter+1]) * 4) ,100,110,14)
	--print(w.length[inRoomNr] ,140,110,14)
	--print(w.y ,80,110,14)


	
	--needel
	woolInGoal(w.x,w.y)
	--print(w.length[inRoomNr],100,110,14)
	
end	
	

function sign(int)
	if int < 0 then 
		return -1
	else 
		return 1
	end
end
	
	
-- vector from cat to wool
function throwWool()
	if inRoomNr == w.room then
		if sign((w.x-p.x)) == 1 and p.o == 0 or sign((w.x-p.x)) == -1 and p.o == 1 then
			w.vx = sign((w.x-p.x)) * 3    -- width: 3 
			w.vy = -3 --(w.y-p.y) 		  -- height: 3
		end
		p.p = 14
	end
end

function pullWool()
	if inRoomNr == w.room then
		if sign((w.x-p.x)) == 1 and p.o == 0 or sign((w.x-p.x)) == -1 and p.o == 1 then
			w.vx = sign((w.x-p.x)) * -2    -- width: 3 
			w.vy = 0					   -- height: 0
		end
		p.p = 14
	end
end


function destroyWool()
	w.respawn = true
end


function resetLevel()
	w.room = 2 + levelCounter * 8 
	for i = 0, 6, 1 do 
		w.track[w.room + i] = {}
		w.length[w.room + i] = 0
	end
	
	w.stringLength = 0
	
	w.vx = 0
	w.vy = 0
	
	w.x = woolStartPos[(levelCounter+1)][1]
	w.y = woolStartPos[(levelCounter+1)][2]
end 


function respawnWool()
	w.vx = 0
	w.vy = 0
	
	offset = inRoomNr - (2 + levelCounter * 8) --w.room??
		
	w.x = woolStartPos[(levelCounter+1)][1+offset*2]
	w.y = woolStartPos[(levelCounter+1)][2+offset*2]
	
	w.track[inRoomNr][(w.length[w.room]-1)*2] = w.x
	w.track[inRoomNr][(w.length[w.room]-1)*2+1] = w.y
	
end


function drawWoolString(x, y)
	if w.length[inRoomNr] > 1 then
		for x = 1, w.length[inRoomNr]-1, 1 do
			cLine(w.track[inRoomNr][(x-1)*2], w.track[inRoomNr][(x-1)*2+1], 
			     w.track[inRoomNr][x*2],     w.track[inRoomNr][x*2+1],       276)  --pix(w.track[x*2], w.track[x*2+1], 276)
			
		end
		if w.room == inRoomNr then 
			line(w.track[inRoomNr][(w.length[w.room]-1)*2], w.track[inRoomNr][(w.length[w.room]-1)*2+1], w.x+4, w.y+6 , 276)
		end
	end	
end

-- WOOL END


function resetHandler()
	-- reset progress
	if btn(6) or key(18) then
		--reset room
		respawnWool()
		respawn()
		--reset full level?
		if sc_reset > 0 then
			print("reset level?", 5,8,0)
			print("reset level?", 4,7,15)
			print(""..sc_reset.."/100", 16, 18, 0) 
			print(""..sc_reset.."/100", 15, 17, 15)
		end
		if sc_reset == 100 then
			print("Reset!", 18, 28, 0)
			print("Reset!", 17, 27, 15)
			resetLevel(levelCounter)
			resetLevel()    --overloading of func name :/
			respawnLevel()
			sc_reset=100
		else
			sc_reset=sc_reset+1
		end
	else
		sc_reset=-25
	end
	

	--if  btnp(6) or keyp(18) then
	--	resetLevel(levelCounter)
	--	respawnWool()
	--	respawn()
	-- end


end


--Map stuff

-- check if a value is in a table, thx Oka, stackoverflow 
function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function animateBlocks()
	-- animation with 2 sprites, second spirte should have the id + 1   
	-- use the first sprite in the map editor
	 
	animatiedBlocks = {160, 162}  -- only the first id, that is on the map   (lava, water) 
	
	for y = 0,17,1 do
		for x = 0,30,1 do
			tile = mget2(x,y, inRoomNr)
			if  has_value(animatiedBlocks, tile) then 
				spr(tile + (t/13)%2 ,x*8,y*8)			-- t/13 magic number, -> slow animation 
			end
		end
	end

end

-- Map end 


-- MUSIC

function playMusic()

	f1=peek(0xFF9C)|((peek(0xFF9D)&0x0F)<<8)
	v1=peek(0xFF9D)>>4
	f2=peek(0xFFAE)|((peek(0xFFAF)&0x0F)<<8)
	v2=peek(0xFFAF)>>4
	f3=peek(0xFFC0)|((peek(0xFFC1)&0x0F)<<8)
	v3=peek(0xFFC1)>>4
	f4=peek(0xFFD2)|((peek(0xFFD3)&0x0F)<<8)
	v4=peek(0xFFD3)>>4
	fx1=(math.log(f1)-min)/(max-min)
	fx2=(math.log(f2)-min)/(max-min)
	fx3=(math.log(f3)-min)/(max-min)
	fx4=(math.log(f4)-min)/(max-min)
	cls(1) --background tile color
	--map(0,0,8,8,175,1)
	rect(1,1,82,134,11) --border box left
	rect(2,2,80,132,8) --color left box
	line(11,4,11,130,3) --border 1st line
	line(31,4,31,130,3) --border 2nd line
	line(51,4,51,130,3) --border 3rd line
	line(71,4,71,130,3) --border 4th line
	line(12,4,12,130,7)
	line(32,4,32,130,7)
	line(52,4,52,130,7)
	line(72,4,72,130,7)
	rect(13-(v1/2),129-(fx1*124),v1,2,0) --shadows
	rect(33-(v2/2),129-(fx2*124),v2,2,0)
	rect(53-(v3/2),129-(fx3*124),v3,2,0)
	rect(73-(v4/2),129-(fx4*124),v4,2,0)
	rect(12-(v1/2),128-(fx1*124),v1,2,2) --1
	rect(32-(v2/2),128-(fx2*124),v2,2,5) --2
	rect(52-(v3/2),128-(fx3*124),v3,2,14) --3
	rect(72-(v4/2),128-(fx4*124),v4,2,15) --4
	rect(84,1,67,19,0) --backgrounds waveforms
	rect(84,21,67,19,0)
	rect(84,41,67,19,0)
	rect(84,61,67,19,0)
	w=0
	w1=0
	w2=0
	w3=0
	w4=0
	i1=0
	i2=0
	i3=0
	i4=0
	w1=peek(0xFF9E+(i1%16))
	w2=peek(0xFFB0+(i2%16))
	w3=peek(0xFFC2+(i3%16))
	w4=peek(0xFFD4+(i4%16))
	while w<64 do
		ww1=w1
		ww2=w2
		ww3=w3
		ww4=w4
		w1=peek(0xFF9E+(i1%16))
		w2=peek(0xFFB0+(i2%16))
		w3=peek(0xFFC2+(i3%16))
		w4=peek(0xFFD4+(i4%16))
		line(85+(w*1),(ww1/-16*(v1/15))+18,86+(w*1),(w1/-16*(v1/15))+18,2)
		line(85+(w*1),(ww2/-16*(v2/15))+38,86+(w*1),(w2/-16*(v2/15))+38,5)
		line(85+(w*1),(ww3/-16*(v3/15))+58,86+(w*1),(w3/-16*(v3/15))+58,14)
		line(85+(w*1),(ww4/-16*(v4/15))+78,86+(w*1),(w4/-16*(v4/15))+78,15)
		i1=i1+(f1/300)
		i2=i2+(f2/300)
		i3=i3+(f3/300)
		i4=i4+(f4/300)
		w=w+1
	end
	rect(84,126,155,9,0) --Song Progress Bar Border
	
	-- song progress bar for every track
	
	if track==1 then
		rect(85,127,153*((c/20)+(t/(2.4*64)/19)),7,15)
	elseif track==2 then
		rect(85,127,153*((c/20)+(t/(2.5*64)/19)),7,15)
	elseif track==3 then
		rect(85,127,153*((c/20)+(t/(1.6*64)/19)),7,15)
	elseif track==4 then
		rect(85,127,153*((c/20)+(t/(0.2*64)/19)),7,15)
	elseif track==5 then
		rect(85,127,153*((c/20)+(t/(5.8*64)/19)),7,15)
	elseif track==6 then
		rect(85,127,153*((c/20)+(t/(2.4*64)/19)),7,15) -- TODO
	end
	
	rect(85,127,153*((c/20)+(t/(7*64)/19)),7,15) --Song Progress Bar
	i=0
	while i<10 do
		if str[1+i] ~= nil then
			print(str[1+i],153,8*i+2,10)
			print(str[1+i],152,8*i+1,15)
		end
		i=i+1
	end
	i=0
	ii=ii+0.075
	
	-- back to musicbox-menu
	
	if track==1 then
		if t==2928 then
			music (1,0,7,false)
			mode = mode_music
			setRoomNr(42)
			t=0
		end
	end
	
	if track==2 then
		if t==3072 then
			c=0
			t=0
		end
	end
	
	if track==3 then
		if t==1920 then
			c=0
			t=0
		end
	end
	
	if track==4 then
		if t==240 then
			music (1,0,7,false)
			mode = mode_music
			setRoomNr(42)
			t=0
		end
	end
	
	if track==5 then
		if t==7168 then
			c=0
			t=0
		end
	end
	
	if track==6 then -- TODO
		if t==1920 then
			c=0
			t=0
		end
	end
	
	if btnp(6) or keyp(1) then
		music (1,0,7,false)
		mode = mode_music
		setRoomNr(42)
		t=0
	end
end

function music_player()
	print("Press Key 1-6 to Start Music!",44,103,0)
	print("Press Key 1-6 to Start Music!",43,102,15)
	print("Press A to go Back to Menu!",49,113,0)
	print("Press A to go Back to Menu!",48,112,15)
	track=0
		
	if keyp(28) then
		mode = mode_playMusic
		str={
		"- Main Menu -",
		"",
		"by kleeder",
		"",
		"",
		}
		min=math.log(16)
		max=math.log(3951)
		music (1,0,7,false)
		t=0
		c=0
		i=0
		ii=0
		track=1
	end
	
	if keyp(29) then
		mode = mode_playMusic
		str={
		"- Overworld -",
		"",
		"by kleeder",
		"",
		"",
		}
		min=math.log(16)
		max=math.log(3951)
		music (0,0,47,true)
		t=0
		c=0
		i=0
		ii=0
		track=2
	end
	
	if keyp(30) then
		mode = mode_playMusic
		str={
		"- Underground -",
		"",
		"by kleeder",
		"",
		"",
		}
		min=math.log(16)
		max=math.log(3951)
		music (2,4,63,true)
		t=0
		c=0
		i=0
		ii=0
		track=3
	end
	
	if keyp(31) then
		mode = mode_playMusic
		str={
		"- Course Clear -",
		"",
		"by kleeder",
		"",
		"",
		}
		min=math.log(16)
		max=math.log(3951)
		music (4,0,63,false)
		t=0
		c=0
		i=0
		ii=0
		track=4
	end
	
	if keyp(32) then
		mode = mode_playMusic
		str={
		"- Finale -",
		"",
		"by kleeder",
		"",
		"",
		}
		min=math.log(16)
		max=math.log(3951)
		music (3,15,63,true)
		t=0
		c=0
		i=0
		ii=0
		track=5
	end
	
	if keyp(33) then
		mode = mode_playMusic
		str={
		"- Ending -",
		"",
		"by kleeder",
		"",
		"",
		}
		min=math.log(16)
		max=math.log(3951)
		music (5,0,63,false)
		t=0
		c=0
		i=0
		ii=0
		track=6
	end

	if btnp(6) or keyp(1) then
	mode=mode_menu
	setRoomNr(64)
	end
end

-- MUSIC END

function controls()
	print("Controls:", 96,23,0)
	print("Controls:", 95,22,15)
	print("Arrows L/R:", 36,36,0)
	print("Arrows L/R:", 35,35,15)
	print("Move", 151,36,0)
	print("Move", 150,35,15)
	print("Arrow up:", 36,46,0)
	print("Arrow up:", 35,45,15)
	print("Jump", 151,46,0)
	print("Jump", 150,45,15)
	print("Arrow down:", 36,56,0)
	print("Arrow down:", 35,55,15)
	print("Sneak", 151,56,0)
	print("Sneak", 150,55,15)
	print("D:", 36,66,0)
	print("D:", 35,65,15)
	print("Throw Wool", 151,66,0)
	print("Throw Wool", 150,65,15)
	print("D + Sneak (near Wool):", 36,76,0)
	print("D + Sneak (near Wool):", 35,75,15)
	print("Pull Wool", 151,76,0)
	print("Pull Wool", 150,75,15)
	print("R:", 36,86,0)
	print("R:", 35,85,15)
	print("Reset Room", 151,86,0)
	print("Reset Room", 150,85,15)
	print("R (hold):", 36,96,0)
	print("R (hold):", 35,95,15)
	print("Reset Level", 151,96,0)
	print("Reset Level", 150,95,15)
	print("Press Q to go Back to Menu!", 48,111,0)
	print("Press Q to go Back to Menu!", 47,110,15)
	
	if keyp(17) then
		setRoomNr(64)
		mode = mode_menu
	end
end

function mainMenu()

	if t>224 then
		if t%64 < 32 then
			spr(360,128,0,0,1,0,0,8,5) --3
		else
			spr(352,128,0,0,1,0,0,8,5) --Logo
		end
	end
	if t%64 < 32 then
		print("Press X to Start!",11,46,0)
		print("Press X to Start!",10,45,15)
		print("Press A for Musicbox!",116,46,0)
		print("Press A for Musicbox!",115,45,15)
	end
	print("Ver 0.6",0,130,15,true,1,true)
	print("by kleeder, Nimo, BotA and alili1996",53,130,15)
	--spr(432,5,2,0,1,0,0,8,5) --1

	if btnp(5) or keyp(24) then
		init()
		mode=mode_prelevel
		music()
		return
	end
	
	if btnp(6) or keyp(1) then
		mode=mode_music
		setRoomNr(42)
		return
	end
	
	if keyp(17) then
		setRoomNr(63)
		mode=mode_controls
	end
	
	-- delete progress
	if levelCounter>0 then	
		if key(18) then
			if sc_reset == 100 then
				print("Deleted!", 49, 28, 0)
				print("Deleted!", 48, 27, 15)
				levelCounter = 0
				pmem(1, levelCounter)
				sc_reset=100
			else
				sc_reset=sc_reset+1
			end
			print("delete progress?", 25,8,0)
			print("delete progress?", 24,7,15)
			print(""..sc_reset.."/100", 51, 18, 0) 
			print(""..sc_reset.."/100", 50, 17, 15)			
		else
			sc_reset=0
			print("Press Key R", 34,8,0)
			print("Press Key R", 33,7,15)
			print("to delete", 41,18,0)
			print("to delete", 40,17,15)
			print("your Progress!", 26,28,0)
			print("your Progress!", 25,27,15)
		end
	elseif key(18) and sc_reset == 100 then
		print("Deleted!", 49, 28, 0)
		print("Deleted!", 48, 27, 15)
		print("delete progress?", 25,8,0)
		print("delete progress?", 24,7,15)
		print(""..sc_reset.."/100", 51, 18, 0) 
		print(""..sc_reset.."/100", 50, 17, 15)	
	else
		sc_reset=0
		print("Press Key Q", 34,13,0)
		print("Press Key Q", 33,12,15)
		print("to view Controls", 23,23,0)
		print("to view Controls", 22,22,15)
	end
end

function clear_cutscene()

	if initHold == false then
	holdTheLine = 0
	initHold = true
	end
	woolInGoal(w.x,w.y)
	if holdTheLine == 200 then
	initHold = false
	mode=mode_prelevel
	music ()
	else
		holdTheLine = holdTheLine + 1
	end
end
	
function game_done() --TODO

	print("Congratz, you won the game ;D",10,10,15)
	print("press X to continue!",100,110,15)
	if btnp(5) or keyp(24) then
		mode=mode_menu
		setRoomNr(64)
		music (1,0,7,false)
		t = 0
		return
	end
end

function prelevel()

	if levelCounter == 0 then
		setRoomNr(1)
	end
	
	if levelCounter == 1 then
		setRoomNr(9)
	end
	
	if levelCounter == 2 then
		setRoomNr(17)
	end
	
	if levelCounter == 3 then
		setRoomNr(25)
	end
	
	if levelCounter == 4 then
		setRoomNr(33)
	end

	if levelCounter == 5 then
		levelCounter = 0
		pmem(1, levelCounter)
		setRoomNr(41)
		mode=mode_done
		music (5,0,63,false)
		return
	end
	
	currentRoom = inRoomNr
	
	if initHold == false then
	holdTheLine = 0
	initHold = true
	end
	
	if holdTheLine == 100 or btnp(5) or keyp(24) then
		if mode_debug == true then
			spawnPlayer()
			spawnWool(48)
		else
			spawnPlayer()
			spawnWool(currentRoom)
		end
		
		for r = 0, 64, 1 do  --init wool track for every room
			w.track[r] = {}
			w.length[r] = 0 
		end
		
		if mode_debug == true then
			setRoomNr(49)
		else
			setRoomNr(currentRoom+1)
		end
		
		mode=mode_level
		if levelCounter == 4 then
		music (3,15,63,true)
		elseif levelCounter == 3 then
		music (2,4,63,true)
		else
		music (0,0,47,true)
		--table.insert(w.track, 0)
		end
	else
		holdTheLine = holdTheLine + 1
	end
	
	
	
end

function level()

	-- button left/right
    if btn(2) then 
		p.vx=-1
		p.o = 1
    elseif btn(3) then 
		p.vx=1
		p.o = 0
    else p.vx=0
    end
	
	--sneak
	if btn(1) then 
		p.vx = p.vx/4
	end
	
    
	-- wall left/right?
    if solid(p.x+p.vx,p.y+p.vy) or solid(p.x+7+p.vx,p.y+p.vy) or solid(p.x+p.vx,p.y+7+p.vy) or solid(p.x+7+p.vx,p.y+7+p.vy) then
        p.vx=0
    end
     
	
	-- gravity 
    if solid(p.x,p.y+8+p.vy) or solid(p.x+7,p.y+8+p.vy) then
        p.vy=0
		p.f = 0
    else
        p.vy=p.vy+0.2
		p.f = 1
    end
    
	--Jumping 
    if p.vy == 0 and btnp(5) and btn0released or p.vy == 0 and keyp(58) and btn0released then 
		p.vy=-2.5 
		btn0released = false  -- no permanent jumping
	end
	btn0released = not btn(5)
		
	
	-- ceiling check 
    if p.vy<0 and (solid(p.x+p.vx,p.y+p.vy) or solid(p.x+7+p.vx,p.y+p.vy)) then
        p.vy=0
    end   

    p.x=p.x+p.vx
    p.y=p.y+p.vy
    
	
	-- respawn if p under map 
	if p.y > 128 then
		respawn()
	end
	
	-- switch to next room 
	if p.x < 0 and inRoomNr == 2 or p.x < 0 and inRoomNr == 10 or p.x < 0 and inRoomNr == 18 or p.x < 0 and inRoomNr == 26 or p.x < 0 and inRoomNr == 34 then
		p.x = 0
		inRoomNr = inRoomNr
	elseif p.x > 240 and inRoomNr < 64 then 
		p.x = 0
		inRoomNr = inRoomNr + 1
	elseif p.x < 0 and inRoomNr > 1 then
		p.x = 232
		inRoomNr = inRoomNr - 1
	end
	
	-- wool left/right?
    if woolRight(p.x,p.y) and inRoomNr == w.room then
        w.vx=1
    elseif woolLeft(p.x,p.y) and inRoomNr == w.room  then
        w.vx=-1
    else  
		w.vx= w.vx - w.vx/10
	end
	
	dis = math.sqrt((w.x-p.x)^2 + (w.y-p.y)^2 ) 
	if btn(1) and btnp(4) and dis < 9 or btn(1) and keyp(4) and dis < 9 then 
		pullWool()
	elseif not btn(1) and btnp(4) and dis < 16 or not btn(1) and keyp(4) and dis < 16 then	
		throwWool()	
	elseif btnp(4) and p.p ==  0 or keyp(4) and p.p ==  0 then 
		p.p = 14
	end
	--print(dis,84,84)
	woolUpdate()
	
	--Reset Level if Stuck
	resetHandler()
	
	
	--cam.x=math.min(120,lerp(cam.x,120-p.x,0.05))
	--cam.y=math.min(64,lerp(cam.y,64-p.y,0.05))
	--map(0,0,240,136,-cam.x,-cam.y)
	
	
	-- cat animations 
	if p.p > 0 then
		p.p = p.p -1 
		spr(264+p.p//7,p.x,p.y,0,1,p.o,0,0)		-- punch sp 264 + 265
	elseif p.vy > 0 then
		spr(261,p.x,p.y,0,1,p.o,0,0)			 -- landing sp 261
	elseif p.vy<0 then
		spr(260,p.x,p.y,0,1,p.o,0,0)           -- jumping sp 260
	elseif btn(1) and btn(2) or btn(1) and btn(3) then
		spr(268+t%80//40,p.x,p.y,0,1,p.o,0,0) --ducking & running sp 268-269
	elseif btn(1) then
		spr(266+t%80//40,p.x,p.y,0,1,p.o,0,0) --ducking sp 266-267
	elseif p.vx==0 then
		spr(262+t%80//40,p.x,p.y,0,1,p.o,0,0)  -- standing sp 262-263
	else
		spr(256+t%40//10,p.x,p.y,0,1,p.o,0,0)  --running sp 256-259
	end
	
	-- wool animations
	if w.respawn then  
		if size < 4 then 
			spr(272 +  size ,w.x,w.y,0,1,0,w.x//9%4,0)
			size = size + 0.2 
		else 
			size = 0
			w.respawn = false
			respawnWool()
		end
	elseif w.room == inRoomNr then 
		spr(276 -  w.size ,w.x,w.y+4-w.size,0,1,0,w.x//3%4,0)
	end	
	
	drawWoolString(0, 120)
	
	if w.goal == true then
		initHold = false
		levelCounter = levelCounter+1
		pmem(1, levelCounter)
		mode=mode_clear
		music (4,0,63,false)
	end
	
	
end
	

function TIC()

    cls()
    --map(0,0,30,17)
	map(rget(inRoomNr))
    --rect(p.x,p.y,8,8,15)

	if mode==mode_menu then
		mainMenu()
	elseif mode==mode_prelevel then
		prelevel()
	elseif mode==mode_level then
		level()
	elseif mode==mode_clear then
		clear_cutscene()
	elseif mode==mode_done then
		game_done()
	elseif mode==mode_music then
		music_player()
	elseif mode==mode_playMusic then
		playMusic()
	elseif mode==mode_controls then
		controls()
	end
	
	t = t+1
	animateBlocks()
-- DEBUG PRINTS

--print(inRoomNr,84,84)
print(t,84,84)
--print(t%64,84,84)
--print(((inRoomNr-1)%8),84,84)
--print(((inRoomNr-1)//8),120,84)
--print(mode,84,84)
--print(p.x,84,84,0)
print(p.y,94,94,0)
	
end

init()
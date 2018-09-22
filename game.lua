-- t: updates every frame (60fps)
-- modes: used to change current state of game

t = 0
mode_menu = 1
mode_prelevel = 2
mode_level = 3
mode_music = 4
mode_clear = 5
mode_done = 6
mode_trackOne = 7
mode_trackTwo = 8
mode_trackThree = 9
mode_trackFour = 10
mode_trackFive = 11
mode_trackSix = 12
mode=mode_menu

function init()
    --solids={[2]=true,[3]=true}
	levelCounter = 0 -- increments after every finished level
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

-- is block id solid?
function isSolid(id)
	return id >= 32 and id <= 79 or id >= 241 and id <= 246 --#032-#079: Solid // also id 253: destroy-block
end

-- is a block at x,y solid? (actual map view)

function solid(x,y)
    return isSolid(mget2((x)//8,(y)//8, inRoomNr))
end

--function solid(x,y)
--    return isSolid(mget2((x)//8,(y)//8, inRoomNr))
--end

function solidInRoom(x,y, room)
    return isSolid(mget2((x)//8,(y)//8, room))
end


function getGroundHeight(x, y)
	while (not solidInRoom(x ,y , w.room)) and (not solidInRoom(x-1 ,y , w.room)) and y < 240 do      -- 240 under level  
		y = y + 1
	end
	return y
end


function isPointInBlockID(x,y,room, id)
	return mget2((x)//8,(y)//8, room) == id
end

--check if a Sprite 8x8 touches a Block with the ID
function isWoolInBlockId(id)
	return isPointInBlockID(w.x+w.vx,w.y+w.vy, w.room, id) or isPointInBlockID(w.x+8,w.y+w.vy, w.room, id) 
		or isPointInBlockID(w.x+8+w.vx,w.y+8+w.vy, w.room, id) or isPointInBlockID(w.x+w.vx,w.y+8+w.vy, w.room, id) 

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
		print("Level cleared",100,60)
		spr(255, (x//8)*8, (y//8)*8, 2, 1, 0, 0, 1, 1)
		w.size = 3
		w.goal = true
		line((x//8)*8 ,(y//8)*8+7 ,(x//8)*8+3,(y//8)*8+2,68)
	end
end


function respawn()
	p.x=20
	--p.y=100
	p.o= 0
	y = 128             
	while solid(0,y) do   -- respawn on the first solid block
		y = y - 8
	end
	p.y = y
	
	
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
	elseif w.x < 0 and w.room > 1 then
		w.x = 232
		w.room = w.room - 1
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
	
	
		
	if w.goal == false then 
		w.x=w.x+w.vx
		w.y=w.y+w.vy
		
	end
	
	if w.vx > 0.01 or w.vy > 0.01 then 
		w.track[w.room][w.length[w.room]*2]	= w.x//8*8											--save coordinates in table, alternate x1,y1,x2,y2,...
		w.track[w.room][w.length[w.room]*2 + 1] = getGroundHeight(w.x//8*8, w.y)
		w.length[w.room] = w.length[w.room] + 1
	end
	
	--needel
	woolInGoal(w.x,w.y)
	--print(w.length[inRoomNr],100,110,14)
	
end	
	
-- vector from cat to wool 
function throwWool()
	if inRoomNr == w.room then
		w.vx = (w.x-p.x)/2
		w.vy = -3 --(w.y-p.y)
		p.p = 14
	end
end


function destroyWool()
	w.respawn = true
end

function respawnWool()
	w.room = inRoomNr
	w.track[w.room] = {}
	w.length[w.room] = 0
	
	--w.respawn = true
	
	w.x=28
	w.vx = 0
	w.vy = 0
	y = 128             
	while solid(0,y) do   -- respawn on the first solid block
		y = y - 8
	end
	w.y = y
end

function drawWoolString(x, y)
	if w.length[inRoomNr] > 1 then
		for x = 1, w.length[inRoomNr]-1, 1 do
			cLine(w.track[inRoomNr][(x-1)*2], w.track[inRoomNr][(x-1)*2+1], 
			     w.track[inRoomNr][x*2],     w.track[inRoomNr][x*2+1],       276)  --pix(w.track[x*2], w.track[x*2+1], 276)
			
		end
		if w.room == inRoomNr then 
			line(w.track[inRoomNr][(w.length[w.room]-1)*2], w.track[inRoomNr][(w.length[w.room]-1)*2+1], w.x, w.y+8 , 276)
		end
	end	
end

-- WOOL END

-- MUSIC

function playMusicOne()
		
		if btnp(3) then
		 t=0
			c=c+1
			if c==20 then c=3 end
			if c==16 then c=c+1 end
			music(0,c)
		end
		
		if btnp(2) then
		 t=0
			c=c-1
			if c==-1 then c=19 end
			if c==16 then c=c-1 end
			music(0,c)
		end
		
		if t==7*64 then
			c=c+1
			t=0
			if c==20 then c=3 end
			if c==16 then c=c+1 end
			music(0,c)
			
		end
		
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
	 cls(2)
		--map(0,0,8,8,175,1)
	 rect(1,1,82,134,0)
	 rect(2,2,80,132,3)
	 line(11,4,11,130,0)
	 line(31,4,31,130,0)
	 line(51,4,51,130,0)
	 line(71,4,71,130,0)
		line(12,4,12,130,7)
	 line(32,4,32,130,7)
	 line(52,4,52,130,7)
	 line(72,4,72,130,7)
	 rect(13-(v1/2),129-(fx1*124),v1,2,0)
	 rect(33-(v2/2),129-(fx2*124),v2,2,0)
	 rect(53-(v3/2),129-(fx3*124),v3,2,0)
	 rect(73-(v4/2),129-(fx4*124),v4,2,0)
	 rect(12-(v1/2),128-(fx1*124),v1,2,13) --136-136
	 rect(32-(v2/2),128-(fx2*124),v2,2,6)
	 rect(52-(v3/2),128-(fx3*124),v3,2,15)
	 rect(72-(v4/2),128-(fx4*124),v4,2,11)
	 rect(84,1,67,19,0)
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
		line(85+(w*1),(ww2/-16*(v2/15))+38,86+(w*1),(w2/-16*(v2/15))+38,1)
		line(85+(w*1),(ww3/-16*(v3/15))+58,86+(w*1),(w3/-16*(v3/15))+58,3)
		line(85+(w*1),(ww4/-16*(v4/15))+78,86+(w*1),(w4/-16*(v4/15))+78,5)
		i1=i1+(f1/300)
			i2=i2+(f2/300)
			i3=i3+(f3/300)
			i4=i4+(f4/300)
			w=w+1
	 end
		rect(84,126,155,9,0)
		rect(85,127,153*((c/20)+(t/(7*64)/19)),7,8)
		i=0
		while i<10 do
			if str[1+i] ~= nil then
				print(str[1+i],153,8*i+2,0)
				print(str[1+i],152,8*i+1,10)
			end
		 i=i+1
		end
		i=0
		
		ii=ii+0.075

	
	if btnp(6) or keyp(1) then
		music()
		mode = mode_music
		setRoomNr(42)
	end
end

-- MUSIC END

function music_player()
	print("Press X to Start Music!",75,110,14)
	print("Press A to go Back to Menu!",65,120,14)
		
	if btnp(5) or keyp(24) then
		mode = mode_trackOne
		str={
		"- Overworld -",
		"",
		"by",
		"   kleeder",
		"",
		"",
		}
		min=math.log(16)
		max=math.log(3951)
		music (0,0,47,true)
		c=0
		i=0
		ii=0
		
	end

	if btnp(6) or keyp(1) then
	mode=mode_menu
	setRoomNr(64)
	music (1,0,7,false)
	t = 0
	end
end

function mainMenu()

	print("Press X to Start!",75,110,14)
	print("Press A for Musicbox!",65,120,14)
	print("Ver 0.3",0,130,1,true,1,true)
	print("by kleeder, Nimo, BotA and alili1996",25,95,12)

	if btnp(5) or keyp(24) then
		init()
		mode=mode_prelevel
		music()
		return
	end
	
	if btnp(6) or keyp(1) then
		mode=mode_music
		setRoomNr(42)
		music()
		return
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
	
function game_done()

	print("Congratz, you won the game ;D",10,10,14)
	print("press X to continue!",100,110,14)
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
		p={
			x=20,
			y=100,
			vx=0, --Velocity X
			vy=0, --Velocity Y
			o =0, --orientation
			f =0, --falling
			p =0, --punch
		}
		
		w={
			x = 28,
			y = 100,
			vx= 0,
			vy= 0,
			r = 0,
			room = currentRoom+1,
			goal = false,
			size = 0,
			track = {},
			length = {},
			respawn = false
			
		}
		
		for r = 0, 64, 1 do  --init wool track for every room
			w.track[r] = {}
			w.length[r] = 0 
		end
		
		
		setRoomNr(currentRoom+1)
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
	if p.y > 200 then
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
	if btnp(4) and dis < 16 or keyp(4) and dis < 16 then 
		throwWool()
	elseif btnp(4) and p.p ==  0 or keyp(4) and p.p ==  0 then 
		p.p = 14
	end
	woolUpdate()
	
	--Reset Level if Stuck
	if btnp(6) or keyp(18) then
		resetLevel(levelCounter)
		respawnWool()
		respawn()
	end
	
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
	elseif p.vx==0 then
		spr(262+t%80//40,p.x,p.y,0,1,p.o,0,0)  -- standing sp 262-263
	else
		spr(256+t%40//10,p.x,p.y,0,1,p.o,0,0)  --running sp 256-259
	--else
		--spr( --ducking sp 266-267
	end
	
	
	-- wool animations
	if w.respawn then  
		if w.size < 4 then 
			spr(272 +  w.size ,w.x,w.y,0,1,w.x//9%4,0,0)
			w.size = w.size + 0.4 
		else 
			w.size = 0
			w.respawn = false
			respawnWool()
		end
	elseif w.room == inRoomNr then 
		spr(272 +  w.size ,w.x,w.y,0,1,w.x//9%4,0,0)
	end	
	
	drawWoolString(0, 120)
	
	if w.goal == true then
		initHold = false
		levelCounter = levelCounter+1
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
	elseif mode==mode_trackOne then
		playMusicOne()
	end
	
	t = t+1
	
-- DEBUG PRINTS

--print(inRoomNr,84,84)
--print(t,84,84)
--print(((inRoomNr-1)%8),84,84)
--print(((inRoomNr-1)//8),120,84)
	
end

init()
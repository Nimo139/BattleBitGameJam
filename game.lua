-- t: updates every frame (60fps)
-- modes: used to change current state of game

t = 0
mode_menu = 1
mode_prelevel = 2
mode_level = 3
mode_pause = 4
mode_clear = 5
mode_done = 6
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
	return id >= 32 and id <= 79  --#032-#079: Solid
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
	while (not solidInRoom(x ,y , w.room)) and (not solidInRoom(x-1 ,y , w.room)) do 
		y = y + 1
	end
	return y
end



function cLine(x1,y1,x2,y2, color)
	
end 




-- is a wool at x,y? (actual map view)
function woolRight(x,y)
	return (math.abs(p.x+7-w.x)<0.5 and math.abs(p.y-w.y)<0.5)
end
function woolLeft(x,y)
	return (math.abs(p.x-7-w.x)<0.5 and math.abs(p.y-w.y)<0.5)
end

function woolInGoal(x,y)
	if mget2((x)//8,(y)//8, w.room) == 254 then 
		--set wool state to small/ fix pos -> end
		print("Level cleared",100,60)
		spr(255, (x//8)*8, (y//8)*8, -1, 1, 0, 0, 1, 1)
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



--function lerp(a,b,t) return (1-t)*a + t*b end
	
	
function resetLevel(levelCounter)
	if levelCounter == 0 then
		setRoomNr(2)
	end
	
	if levelCounter == 1 then
		setRoomNr(10)
	end
	
	if levelCounter == 2 then
		setRoomNr(18)
	end
	
	if levelCounter == 3 then
		setRoomNr(26)
	end
	
	if levelCounter == 4 then
		setRoomNr(34)
	end
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
		w.track[w.length*2]	= w.x//8*8											--save coordinates in table, alternate x1,y1,x2,y2,...
		w.track[w.length*2 + 1] = getGroundHeight(w.x//8*8, w.y)
		w.length = w.length + 1
	end
	
	--needel
	woolInGoal(w.x,w.y)
	print(w.length,100,110,14)
	
	
end	
	
-- vector from cat to wool 
function throwWool()
	if inRoomNr == w.room then
		w.vx = (w.x-p.x)/2
		w.vy = -3 --(w.y-p.y)
		p.p = 14
	end
end


function respawnWool()
	w.room = inRoomNr
	w.x=28
	w.vy = 0
	y = 128             
	while solid(0,y) do   -- respawn on the first solid block
		y = y - 8
	end
	w.y = y
end

function drawWoolString(x, y)
	if w.length > 1 then
		for x = 1, w.length-1, 1 do
			line(w.track[(x-1)*2], w.track[(x-1)*2+1], w.track[x*2], w.track[x*2+1], 20)  --pix(w.track[x*2], w.track[x*2+1], 20)
			
		end
		line(w.track[(w.length-1)*2], w.track[(w.length-1)*2+1], w.x, w.y+8 , 20)
	end
	
	
	-- not in use->
	if w.room == inRoomNr then
		tox = w.x
	elseif w.room > inRoomNr then
		tox = 240
	else 
		tox = -1 
	end
	-- niu
	
	
end

-- WOOL END

function mainMenu()

	print("Press X!",95,110,14)
	print("Ver 0.3",0,130,1,true,1,true)
	print("by kleeder, Nimo, BotA and alili1996",25,95,12)

	if btnp(5) or keyp(24) then
		init()
		mode=mode_prelevel
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
	
	if holdTheLine == 10 or btnp(5) or keyp(24) then   -- == 100 slow 
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
			length = 0,
			
		}
		
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
		spr(9+p.p//7,p.x,p.y,0,1,p.o,0,0)
	elseif p.vy > 0 then
		spr(6,p.x,p.y,0,1,p.o,0,0)			 -- landing
	elseif p.vy<0 then
		spr(5,p.x,p.y,0,1,p.o,0,0)           -- jumping 
	elseif p.vx==0 then
		spr(7+t%80//40,p.x,p.y,0,1,p.o,0,0)  -- standing sp 7-8
	else
		spr(1+t%40//10,p.x,p.y,0,1,p.o,0,0)  --running sp 1-4
	end
	
	
	-- wool animations
	if w.room == inRoomNr then 
		spr(16 +  w.size ,w.x,w.y,0,1,w.x//9%4,0,0)
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
	end
	if mode ~= mode_pause then
		t=t+1		
	end

	if btnp(7) and mode == mode_level or keyp(16) and mode == mode_level  then
		mode=mode_pause
		prev_room = inRoomNr
		setRoomNr(42)
	elseif mode==mode_pause then
		if btnp(7) or keyp(16) then
		setRoomNr(prev_room)
		mode=mode_level
		end
	end
	
-- DEBUG PRINTS

--print(inRoomNr,84,84)
--print(t,84,84)
--print(((inRoomNr-1)%8),84,84)
--print(((inRoomNr-1)//8),120,84)
	
end

init()
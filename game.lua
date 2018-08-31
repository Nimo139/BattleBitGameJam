function init()
    --solids={[2]=true,[3]=true}
	
	t = 0
	
	-- cat fields
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
		room = 1,
	}
		
	--cam={x=120,y=68}
	
	--Jumping physics
	btn0released = true
	
	
	inRoomNr = 1 
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
	return mget(x+30*(room-1),y)
end


-- is block id solid?
function isSolid(id)
	return id >= 32 and id <= 79  --#032-#079: Solid
end

-- is a block at x,y solid? (actual map view)
function solid(x,y)
    return isSolid(mget2((x)//8,(y)//8, inRoomNr))
end

function solidInRoom(x,y, room)
    return isSolid(mget2((x)//8,(y)//8, room))
end


-- is a wool at x,y? (actual map view)
function woolRight(x,y)
	return (math.abs(p.x+7-w.x)<0.5 and math.abs(p.y-w.y)<0.5)
end
function woolLeft(x,y)
	return (math.abs(p.x-7-w.x)<0.5 and math.abs(p.y-w.y)<0.5)
end



function respawn()
	p.x=0
	--p.y=100
	p.o= 0
	y = 128             
	while solid(0,y) do   -- respawn on the first solid block
		y = y - 8
	end
	p.y = y
	
	
end



--function lerp(a,b,t) return (1-t)*a + t*b end
	

--WOOL
	
	
-- wool physics
function woolUpdate()

	
	-- switch to next room 
	if w.x > 240 then 
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
	
	w.x=w.x+w.vx
    w.y=w.y+w.vy
	

	
	
end	
	
-- vector from cat to wool 
function throwWool()
	
	w.vx = (w.x-p.x)/2
	w.vy = -3 --(w.y-p.y)
	p.p = 14

end

-- WOOL END

-- MUSIC

music (0,0,47,true)

-- MUSIC END
	
init()
function TIC()

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
    if p.vy == 0 and btn(0) and btn0released then 
		p.vy=-2.5 
		btn0released = false  -- no permanent jumping
		
	end
	btn0released = not btn(0)
		
	
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
	if p.x > 240 then 
		p.x = 0
		inRoomNr = inRoomNr + 1
	elseif p.x < 0 and inRoomNr > 1 then
		p.x = 232
		inRoomNr = inRoomNr - 1
	end 
	
	
	-- wool left/right?
    if woolRight(p.x,p.y) then
        w.vx=1
    elseif woolLeft(p.x,p.y) then
        w.vx=-1
    else  
		w.vx= w.vx - w.vx/10
	end
	
	dis = math.sqrt((w.x-p.x)^2 + (w.y-p.y)^2 ) 
	if keyp(4) and dis < 16 then 
		throwWool()
	elseif keyp(4) and p.p ==  0 then 
		p.p = 14
	end
	woolUpdate()
	
	
    cls()
    --map(0,0,30,17)
	map(rget(inRoomNr))
    --rect(p.x,p.y,8,8,15)
	print(math.abs(p.x-7-w.x),84,84)
	print(p.x,120,84)
	t=t+1
	

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
		spr(64,w.x,w.y,0,1,w.x//9%4,0,0)
	end	
	
	-- music stuff
--	if inRoomNr == 1 then
--		music (0,0,47,true)
--	end

	if inRoomNr == 2 then
		music ()
	end

end
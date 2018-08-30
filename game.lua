function init()
    solids={[2]=true,[3]=true}
	t = 0
	p={
		x=20,
		y=100,
		vx=0, --Velocity X
		vy=0, --Velocity Y
	}
	cam={x=120,y=68}
	
	inRoom = 1 
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

function mget2(x,y, room)
	print(x+30*(room-1),84,95)
	return mget(x+30*(room-1),y)
end

function solid(x,y)
    return solids[mget2((x)//8,(y)//8, inRoom)]
end

--function lerp(a,b,t) return (1-t)*a + t*b end
	
init()
function TIC()

    if btn(2) then p.vx=-1
    elseif btn(3) then p.vx=1
    else p.vx=0
    end
    
    if solid(p.x+p.vx,p.y+p.vy) or solid(p.x+7+p.vx,p.y+p.vy) or solid(p.x+p.vx,p.y+7+p.vy) or solid(p.x+7+p.vx,p.y+7+p.vy) then
        p.vx=0
    end
    
    if solid(p.x,p.y+8+p.vy) or solid(p.x+7,p.y+8+p.vy) then
        p.vy=0
    else
        p.vy=p.vy+0.2
    end
    
    if btn(0) then 
		p.vy=-2.5 
	end

    if p.vy<0 and (solid(p.x+p.vx,p.y+p.vy) or solid(p.x+7+p.vx,p.y+p.vy)) then
        p.vy=0
    end   

    p.x=p.x+p.vx
    p.y=p.y+p.vy
    
	if p.y > 200 then
		p.x=20
		p.y=100
	end
	
	if p.x >240 then 
		p.x = 0
		inRoom = inRoom + 1
	end
	
    cls()
    --map(0,0,30,17)
	map(rget(inRoom))
    --rect(p.x,p.y,8,8,15)
	print(p.x,84,84)
	t=t+1
	

	--cam.x=math.min(120,lerp(cam.x,120-p.x,0.05))
	--cam.y=math.min(64,lerp(cam.y,64-p.y,0.05))
	--map(0,0,240,136,-cam.x,-cam.y)
	
	spr(1+t%60//30*2,p.x,p.y,-1,1,0,0)
end
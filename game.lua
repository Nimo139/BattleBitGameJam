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
end

function solid(x,y)
    return solids[mget((x)//8,(y)//8)]
end

function lerp(a,b,t) return (1-t)*a + t*b end
	
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
	
    cls()
    map()
    --rect(p.x,p.y,8,8,15)
	
	t=t+1
	

	--cam.x=math.min(120,lerp(cam.x,120-p.x,0.05))
	--cam.y=math.min(64,lerp(cam.y,64-p.y,0.05))
	--map(0,0,240,136,-cam.x,-cam.y)
	
	spr(1+t%60//30*2,p.x,p.y,-1,1,0,0)
end
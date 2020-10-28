
botN = botN or {}
botN.currentlyOnline = {}
botN.botData = {}
botN.botData.vars = {}
botN.botAllies = {
	"STEAM_0:0:73272856",
	"STEAM_0:0:183022593",
	"STEAM_0:1:555925769"

}

surface.CreateFont( "COH2_Normal", {
	font = "Trebuchet24", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 20,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = true,
	outline = false,
})

surface.CreateFont( "COH2_Small", {
	font = "Trebuchet24", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 14,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont( "COH2_BSmall", {
	font = "Trebuchet24", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 14,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = true,
})

surface.CreateFont( "COH2_SSmall", {
	font = "Trebuchet24", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 14,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

function botN.setBotData(steamid, varname, data)

	local newdata = "1 "..varname.." "..util.TableToJSON(data)
	http.Post("http://2.221.42.177:5000/setdata", { name = steamid, data = newdata })
end


function botN.getBotData(steamid)
	http.Post("http://2.221.42.177:5000/getdata", { name = steamid }, function(result)
		if result then
			botN.processData(result)
		end
	end)
end

function botN.processData(data)
	local datatab = util.JSONToTable(data)
	if (datatab) then
		for k, v in pairs( datatab ) do

			local splitstring = string.Split(v, " ")
			if (splitstring[1] == "1") then

				local reversestring = "1 "..splitstring[2].." "
				local datarr = string.sub(v, #reversestring)
				botN.botData.vars[splitstring[2]] = datarr

				hook.Run(splitstring[2], datarr)
			end
		end
	end
end

function botN.isParent()
	if (LocalPlayer():SteamID() == "STEAM_0:0:73272856") then
		return true
	end
	return false

end

function botN.isSteamIDParent(steamid)
	if (LocalPlayer():SteamID() == steamid) then
		return true
	end
	return false
end

function botN.isAlly(steamid)
	if (table.HasValue(botN.botAllies, steamid)) then
		return true
	end
	return false
end


timer.Remove("DataTimerCheck")
timer.Create( "DataTimerCheck", 0.01, 0, function() 
	botN.getBotData(LocalPlayer():SteamID())
end )

 
botN.Enabled = false
botN.ViewOrigin = Vector( 0, 0, 0 )
botN.ViewAngle = Angle( 0, 0, 0 )
botN.Velocity = Vector( 0, 0, 0 )
 
function botN.CalcView( ply, origin, angles, fov )
        if ( !botN.Enabled ) then return end
        if ( botN.SetView ) then
                botN.ViewOrigin = origin
                botN.ViewAngle = angles
               
                botN.SetView = false
        end
        return { origin = botN.ViewOrigin, angles = botN.ViewAngle }
end
hook.Add( "CalcView", "SpiritWalk", botN.CalcView )
 
function botN.CreateMove( cmd )
        if ( !botN.Enabled ) then return end
       

        local time = FrameTime()
        botN.ViewOrigin = botN.ViewOrigin + ( botN.Velocity * time )
        botN.Velocity = botN.Velocity * 0.95
       

        local sensitivity = 0.022
        botN.ViewAngle.p = math.Clamp( botN.ViewAngle.p + ( cmd:GetMouseY() * sensitivity ), -89, 89 )
        botN.ViewAngle.y = botN.ViewAngle.y + ( cmd:GetMouseX() * -1 * sensitivity )
       
        local add = Vector( 0, 0, 0 )
        local ang = botN.ViewAngle
        if ( cmd:KeyDown( IN_FORWARD ) ) then add = add + ang:Forward() end
        if ( cmd:KeyDown( IN_BACK ) ) then add = add - ang:Forward() end
        if ( cmd:KeyDown( IN_MOVERIGHT ) ) then add = add + ang:Right() end
        if ( cmd:KeyDown( IN_MOVELEFT ) ) then add = add - ang:Right() end
        if ( cmd:KeyDown( IN_JUMP ) ) then add = add + ang:Up() end
        if ( cmd:KeyDown( IN_DUCK ) ) then add = add - ang:Up() end
       

        add = add:GetNormal() * time * 1000
        if ( cmd:KeyDown( IN_SPEED ) ) then add = add * 6 end
       
        botN.Velocity = botN.Velocity + add
       

        if ( botN.LockView == true ) then
                botN.LockView = cmd:GetViewAngles()
        end
        if ( botN.LockView ) then
                cmd:SetViewAngles( botN.LockView )
        end
       
        cmd:SetForwardMove( 0 )
        cmd:SetSideMove( 0 )
        cmd:SetUpMove( 0 )
end
hook.Add( "CreateMove", "SpiritWalk", botN.CreateMove )
 
function botN.CameraToggle()
	if (botN.isParent()) then
    		botN.Enabled = !botN.Enabled
    		botN.LockView = botN.Enabled
    		botN.SetView = true
    end
end



botN.isRTSMode = false

botN.RTSFrame = botN.RTSFrame or nil 

botN.RTSTextures = {
	[1] = Material( "botmats/coh2ui_1.png" ),
	[2] = Material( "botmats/coh2ui_1_outer.png" ),
	[3] = Material( "botmats/coh2ui_1_outer2.png" ),

	[4] = Material( "botmats/coh2ui_2.png" ),
	[5] = Material( "botmats/coh2ui_2_inner.png" ),
	[6] = Material( "botmats/coh2ui_3.png" ),

	[7] = Material( "botmats/coh2ui_4.png" ),

	[8] = Material( "botmats/uniticon.png" ),
	[9] = Material( "botmats/unithealthbar.png" ),
	[10] = Material( "botmats/conscript1.png" ),
	[11] = Material( "botmats/conscript_picture.png" ),

	[100] = Material( "botmats/testimage.jpg" )
}


function botN.ToggleRTSMode()
	if (!botN.isParent()) then return end
	if (botN.isRTSMode) then
		botN.RTSFrame:Remove()

	else
		if IsValid(botN.RTSFrame) then botN.RTSFrame:Remove() end
		botN.RTSFrame = vgui.Create( "DFrame" )
		botN.RTSFrame:SetTitle( "" )
		botN.RTSFrame:SetSize( ScrW(),ScrH() )
		botN.RTSFrame:Center()	
		botN.RTSFrame:SetDraggable(false)		
		botN.RTSFrame:SetPopupStayAtBack(true)
		botN.RTSFrame.Paint = function( self, w, h ) 
 
		end

	



		local radarwidth = ScrW() * 0.197
		local radarheight = ScrH() * 0.328

		local radarframe = vgui.Create( "DFrame" , botN.RTSFrame) 
		radarframe:SetPos(0, ScrH()-radarheight+1)
		radarframe:SetSize(radarwidth, radarheight)
		radarframe:SetDraggable(false)
		radarframe:ShowCloseButton( false )
		radarframe:SetTitle("")
		radarframe.Paint = function( self, w, h ) 
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( botN.RTSTextures[7] ) 
			surface.DrawTexturedRect( 0, 0, w, h ) 


		end

		local picturewidth = ScrW() * 0.0934
		local pictureheight = ScrH() * 0.2082

		local pictureframe = vgui.Create( "DFrame" , botN.RTSFrame) 
		pictureframe:SetPos(radarwidth, ScrH()-pictureheight+1)
		pictureframe:SetSize(picturewidth, pictureheight)
		pictureframe:SetDraggable(false)
		pictureframe:ShowCloseButton( false )
		pictureframe:SetTitle("")
		pictureframe.Paint = function( self, w, h ) 
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( botN.RTSTextures[6] ) 
			surface.DrawTexturedRect( 0, 0, w, h ) 

			if (table.Count( botN.selectedUnits) > 0) then
				surface.SetDrawColor( 200, 200, 200, 255 )
				surface.SetMaterial( botN.RTSTextures[11] ) 
				surface.DrawTexturedRect( (w * 0.07), (h * 0.11), w - (w * 0.15), h - (h * 0.2) ) 				

			end


		end

		local mainwidth = ScrW() * 0.529
		local mainheight = ScrH() * 0.2082

		local mainframe = vgui.Create( "DFrame" , botN.RTSFrame) 
		mainframe:SetPos(radarwidth + picturewidth, ScrH()-mainheight+1)
		mainframe:SetSize(mainwidth, mainheight)
		mainframe:SetDraggable(false)
		mainframe:ShowCloseButton( false )
		mainframe:SetTitle("")
		mainframe.Paint = function( self, w, h ) 
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( botN.RTSTextures[2] ) 
			surface.DrawTexturedRect( 0, 0, 36, h ) 

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( botN.RTSTextures[1] ) 
			surface.DrawTexturedRect( 36, 0, w-72, h ) 

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( botN.RTSTextures[3] ) 
			surface.DrawTexturedRect( w-36, 0, 36, h ) 

			local cont = table.Count( botN.selectedUnits)

			if (cont == 1) then
				botN.drawUnitIcon(botN.selectedUnits[1], w * 0.024, h * 0.15 , w * 0.04, h * 0.38)


				draw.DrawText(botN.selectedUnits[1]:Name(), "COH2_Normal", (w * 0.08), (h * 0.13), Color(0, 187, 255,255), TEXT_ALIGN_LEFT)

				draw.DrawText("Conscript Infantry Squad", "COH2_Normal", (w * 0.08), (h * 0.24), Color(255, 255, 255,255), TEXT_ALIGN_LEFT)
				draw.DrawText([[Basic troops with little combat training or experience. The backbone and bulk of the Soviet 
Army. Often lost in large numbers, they can be truly effective with good support.]], "COH2_Small", (w * 0.08), (h * 0.35), Color(200, 200, 200,255), TEXT_ALIGN_LEFT)

				draw.DrawText([[Cheap troops. Effective when fighting in cover.]], "COH2_SSmall", (w * 0.08), (h * 0.5), Color(212, 219, 0,255), TEXT_ALIGN_LEFT)	

			elseif (cont > 1) then
				for i, v in ipairs( botN.selectedUnits ) do
					botN.drawUnitIcon(botN.selectedUnits[i], w * 0.024 + ((i-1) * (w *0.05)), h * 0.15 , w * 0.04, h * 0.38)

				end
				




			end
		end

		local iconwidth = ScrW() * 0.181
		local iconheight = ScrH() * 0.253

		local iconframe = vgui.Create( "DFrame" , botN.RTSFrame) 
		iconframe:SetPos(radarwidth + picturewidth + mainwidth, ScrH()-iconheight+1)
		iconframe:SetSize(iconwidth, iconheight)
		iconframe:SetEnabled( true )
		iconframe:SetDraggable(false)
		iconframe:ShowCloseButton( false )
		iconframe:SetTitle("")
		iconframe.Paint = function( self, w, h ) 
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( botN.RTSTextures[4] ) 
			surface.DrawTexturedRect( 0, 0, w, h ) 

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( botN.RTSTextures[5] ) 
			surface.DrawTexturedRect( 22, 22, w-44, h-44 ) 
		end


		for i, v in ipairs( botN.currentlyOnline ) do

			local unitwidth = ScrW() * 0.022
			local unitheight = ScrH() * 0.067

			local unitheightlimit = ScrH() * 0.0464
			local unitspace = ScrW() * 0.0292

			local unitframe = vgui.Create( "DButton" , botN.RTSFrame) 
			unitframe:SetText( "" )
			unitframe:SetPos(ScrW() - (unitspace * i), 0 + unitheightlimit)
			unitframe:SetSize(unitwidth, unitheight + (unitheight * 0.15))
			unitframe.dediplayer = v
			unitframe.DoClick = function()	
				botN.RTSSelectUnit(unitframe.dediplayer)	
			end
			unitframe.Paint = function( self, w, h ) 
				botN.drawUnitIcon(unitframe.dediplayer, 0, 0, w, h)
			end
		end

	end


	botN.isRTSMode = !botN.isRTSMode

    botN.Enabled = botN.isRTSMode
    botN.LockView = botN.isRTSMode
    botN.SetView = true
end

function botN.drawUnitIcon(ply, posw, posh, w, h)
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( botN.RTSTextures[8] ) 
	surface.DrawTexturedRect( posw, posh + (h * 0.1) , w, h - (h * 0.15) ) 

	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.SetMaterial( botN.RTSTextures[9] ) 
	surface.DrawTexturedRect( posw + (w * 0.03), posh, w - (w * 0.03), h * 0.10)

	surface.SetDrawColor( 180, 180, 180, 255 )
	surface.SetMaterial( botN.RTSTextures[9] ) 
	surface.DrawTexturedRect( posw + (w * 0.03), posh, (w - (w * 0.03)) * (ply:Health()/100), h * 0.10)

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( botN.RTSTextures[10] ) 
	surface.DrawTexturedRect( posw + (w * 0.08), posh + (h * 0.22), h * 0.42, h * 0.42)

	draw.DrawText("1", "COH2_BSmall", posw + (w * 0.2), posh + (h * 0.13), Color(255,255,255,255), TEXT_ALIGN_CENTER)
end

botN.mouseRightDownLength = 0

hook.Add( "CreateMove", "BotN_RTSMODE", function( ply, cmd )
	if (!botN.isParent()) then return end

	if (botN.isRTSMode) then
		local mouseinput = !input.IsMouseDown(MOUSE_RIGHT)

		if (!mouseinput) then
			botN.mouseRightDownLength = botN.mouseRightDownLength + CurTime()

			if (botN.mouseRightDownLength > 300000) then
				gui.EnableScreenClicker(false)
			end
		else

			if (botN.mouseRightDownLength > 0 and botN.mouseRightDownLength < 300000) then
				botN.DidRightClick()
			end

			botN.mouseRightDownLength = 0
			gui.EnableScreenClicker(true)
		end
		botN.RTSSelectCheck()
	else
		gui.EnableScreenClicker(false)
	end

end )

function botN.DidRightClick()
	local tr = botN.raycastFromMouseCheck()
	if (tr) then

		for i, v in ipairs( botN.selectedUnits ) do
			botN.setBotData(v:SteamID(), "MoveToPoint", {tostring(tr.HitPos)})
		end
	end
end

function botN.RTSSelectCheck()
	if (!botN.isParent()) then return end
	if (input.WasMousePressed(MOUSE_LEFT)) then

		local tr = botN.raycastFromMouseCheck()

		local entselect = tr.Entity
		if (!tr.Entity:IsPlayer()) then
			local entsnear = ents.FindInSphere(tr.HitPos, 300)
			local ply
			if (entsnear) then
				ply = botN.closestEnt(entsnear, tr.HitPos, "player")
		    end

		end
		botN.RTSSelectUnit(entselect)
			
		
	end
end

function botN.raycastFromMouseCheck()
	local tr = util.TraceLine( {
		start = botN.ViewOrigin,
		endpos = botN.ViewOrigin + gui.ScreenToVector(gui.MousePos()) * 10000,
	} )

	return tr
end

function botN.closestEnt(tab, pos, filter)
	local ent
	local distance = 999999999999
	for k, v in pairs( tab ) do
		local contin = false
		if (filter) then
			if (v:GetClass() != filter) then contin = true end
		end

		if (not contin) then
			local dist = pos:DistToSqr(v:GetPos())
			if (dist < distance) then
				distance = dist
				ent = v
			end
		end
	end	
	return ent
end


botN.selectedUnits = {}

function botN.RTSSelectUnit(ent)
	if (ent:IsPlayer()) then

		if (botN.isAlly(ent:SteamID())) then
			if (input.IsKeyDown(KEY_LSHIFT)) then
				if (botN.RTSisSelected(ent)) then
					table.remove(botN.selectedUnits, tablefind(botN.selectedUnits,ent))
					return
				end
				table.insert(botN.selectedUnits, ent)
				return
			end
			botN.selectedUnits = {ent}
			
		end
	else
		botN.selectedUnits = {}
	end
end

function botN.RTSisSelected(ent)
	if (table.HasValue(botN.selectedUnits, ent)) then
		return true
	end
	return false
end

function tablefind(tab,el)
	for index, value in pairs(tab) do
	    if value == el then
	        return index
	    end
	end
end

function botN.checkCurrentlyOnline()
	for i, v in ipairs( player.GetAll() ) do
		if (!botN.isSteamIDParent(v:SteamID())) then
    		if (table.HasValue(botN.botAllies, v:SteamID())) then
    			table.insert(botN.currentlyOnline,v)
    		end
    	end
	end
end

function botN.Init()
	botN.checkCurrentlyOnline()
	botN.ToggleRTSMode()
end

gui.EnableScreenClicker(false)
concommand.Add("rtsmode", function( ply, cmd, args )
    botN.Init()
end)

concommand.Add("generateNodeMap", function( ply, cmd, args )
    local minco = Vector(tonumber(args[1]), tonumber(args[2]), tonumber(args[3]))
    local maxco = Vector(tonumber(args[4]), tonumber(args[5]), tonumber(args[6]))

    if (minco) and (maxco) then
    	debugoverlay.Box( Vector(0,0,0), minco, maxco, 10, Color( 255, 255, 255, 0) )

    	local distancex = minco:Distance(Vector(minco.x,maxco.y,maxco.z))
    	local distancey = minco:Distance(Vector(maxco.x,minco.y,maxco.z))
    	local distancez = minco:Distance(Vector(maxco.x,maxco.y,minco.z))

    	for x=0,distancex, 20 do 
    		for y=0,distancey, 20 do 
    			for z=0,distancez, 20 do 
    				botN.GenerateNodeAtPos(minco + Vector(x, y, z))
    			end
    		end
    	end
    end
end)

-- World Sphere took from https://www.youtube.com/watch?v=w4tt5pvbr6A
local color_mask2 = Color(0,0,0,0)

local function drawStencilSphere( pos, ref, compare_func, radius, color, detail )
	render.SetStencilReferenceValue( ref )
	render.SetStencilCompareFunction( compare_func )
	render.DrawSphere(pos, radius, detail, detail, color)
end

-- Call this before calling render.AddWorldRing()
function render.StartWorldRings()
	render.WORLD_RINGS = {}
	cam.IgnoreZ(false)
	render.SetStencilEnable(true)
	render.SetStencilTestMask(255)
	render.SetStencilWriteMask(255)
	render.ClearStencil()
	render.SetColorMaterial()
end

-- Args: pos = where, radius = how big, [thicc = how thick, detail = how laggy]
-- Detail must be an odd number or it will look like shit.
function render.AddWorldRing(pos, radius, thicc, detail)
	detail = detail or 25
	thicc = thicc or 10
	local z = {detail=detail, thicc=thicc, pos=pos, outer_r=radius, inner_r=math.max(radius-thicc,0)}
	table.insert(render.WORLD_RINGS, z)
end

-- Call this to actually draw the rings added with render.AddWorldRing()
function render.FinishWorldRings(color)
	local ply = LocalPlayer()
	local zones = render.WORLD_RINGS
	
	render.SetStencilZFailOperation( STENCILOPERATION_REPLACE )
	
	for i, zone in ipairs(zones) do
		local outer_r = zone.radius
		drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, -zone.outer_r, color_mask2, zone.detail ) -- big, inside-out
	end
	render.SetStencilZFailOperation( STENCILOPERATION_DECR )
	for i, zone in ipairs(zones) do
		local outer_r = zone.radius
		drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, zone.outer_r, color_mask2, zone.detail ) -- big
	end
	render.SetStencilZFailOperation( STENCILOPERATION_INCR )
	for i, zone in ipairs(zones) do
		drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, -zone.inner_r, color_mask2, zone.detail ) -- small, inside-out
	end
	render.SetStencilZFailOperation( STENCILOPERATION_DECR )
	for i, zone in ipairs(zones) do
		drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, zone.inner_r, color_mask2, zone.detail ) -- small
	end
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	
	local cam_pos = ply:EyePos()
	local cam_angle = ply:EyeAngles()
	local cam_normal = cam_angle:Forward()
	cam.IgnoreZ(true)
	render.SetStencilReferenceValue( 1 )
	render.DrawQuadEasy(cam_pos + cam_normal * 10, -cam_normal,10000,10000,color,cam_angle.roll)
	cam.IgnoreZ(false)
	render.SetStencilEnable(false)
end

hook.Add("PostDrawOpaqueRenderables","combat_sphere",function( depth, skybox )
	if (!botN.isParent()) then return end
	local pulsatingRed = Color(0, 187, 255,180)
	render.StartWorldRings()
		for k,v in ipairs(player.GetAll())do
			if (botN.RTSisSelected(v)) then
				render.AddWorldRing(v:GetPos(), 70, 5, 15)
			end
		end
	render.FinishWorldRings(pulsatingRed)
end)

hook.Add("PreDrawViewModel","disableviewmodel",function( depth, skybox )
	return botN.isRTSMode

end )


botN.gotoPos = {}

hook.Add( "StartCommand", "BOTCODE", function( ply, cmd )
	if ( botN.isParent() ) then return end

	cmd:ClearMovement() 
	cmd:ClearButtons()


	if (#botN.gotoPos > 0) then
		cmd:SetForwardMove( ply:GetWalkSpeed() )

		local nextpos = botN.gotoPos[1]

		local movedir = ((nextpos - LocalPlayer():GetShootPos() ):GetNormalized():Angle())	
		cmd:SetViewAngles(  movedir )
		
		if (LocalPlayer():GetPos():DistToSqr(nextpos) < (20*20)) then
			table.remove(botN.gotoPos, 1)
		end
	end
end )

hook.Add("MoveToPoint","GoToPoint",function( data )
	local arr = util.JSONToTable(data)
	local splitarr = string.Split(arr[1], " ")

	--print(Vector(splitarr[1], splitarr[2], splitarr[3]))

	--botN.gotoPos = {Vector(splitarr[1], splitarr[2], splitarr[3])}

	botN.ComputePath(Vector(splitarr[1], splitarr[2], splitarr[3]))



end )

local trr = { collisiongroup = COLLISION_GROUP_WORLD }
function util.IsInWorld( pos )
	trr.start = pos
	trr.endpos = pos
	return util.TraceLine( trr ).HitWorld
end

local nodes = {}
local debugnode = 100
local yourmum = {}


function botN.generateNodeCube(pos)
	for x=-1,1 do 	
		for y=-1,1 do
			for z=-1,1 do
				local xpos = (x*20)+pos.x
				local ypos = (y*20)+pos.y
				local zpos = (z*20)+pos.z

				botN.GenerateNodeAtPos(Vector(xpos, ypos, zpos))
			end	
		end
	end
end

function botN.ComputePath(endpos)
	print("BOT: Calculating path...")
	local vec = LocalPlayer():GetPos()
	botN.generateNodeCube(vec)				
	local path = botN.CalculateAStarPath(botN.nearestNode(vec), endpos)

	if (path) then
		print("BOT: Found Path! Moving through path...")
		botN.gotoPos = path
	end
end

local INF = 1/0

function heuristic_cost_estimate ( nodeA, nodeB )
	return nodeA:DistToSqr(nodeB)
end

function lowest_f_score ( set, f_score )

	local lowest, bestNode = INF, nil
	for _, node in pairs ( set ) do
		local score = f_score [ node ]
		if score < lowest then
			lowest, bestNode = score, node
		end
	end
	return bestNode
end

function remove_node(set, node)
	for k, v in pairs( set ) do
		if (v == node) then
			table.remove(set, k)
		end
	end
end

function unwind_path ( flat_path, map, current_node )

	if map [ current_node ] then
		table.insert ( flat_path, 1, map [ current_node ] ) 
		return unwind_path ( flat_path, map, map [ current_node ] )
	else
		return flat_path
	end
end

function botN.CalculateAStarPath(startnode, endnode)


	local open_list = {startnode}
	local closed_list = {}
	local came_from = {}

	local g_score, f_score = {}, {}
	g_score [ startnode ] = 0
	f_score [ startnode ] = g_score [ startnode ] + heuristic_cost_estimate ( startnode, endnode )



	for i=1,500 do


		local current = lowest_f_score ( open_list, f_score )

		local dist = current:DistToSqr(endnode)

		if dist < 5000 then 	 			
			local path = unwind_path ( {}, came_from, current )

			for k, v in pairs ( path ) do
				debugoverlay.Box( v, Vector(10,10,10), Vector(-10,-10,-10), 10, Color( 0, 255, 0, 50 ) )

			end


			return path
		end

		remove_node(open_list, current)
		table.insert(closed_list, current)

		--botN.generateNodeCube(current)	
		local aroundnodes = botN.getNodesAroundNode(current)


		for _, neighbor  in pairs( aroundnodes ) do

			

			came_from 	[ neighbor ] = current

			if (!table.HasValue(closed_list, neighbor)) then
				local tentative_g_score = g_score [ current ] + current:DistToSqr(neighbor)
				if (!table.HasValue(open_list, neighbor)) then 	
					g_score 	[ neighbor ] = tentative_g_score
					f_score 	[ neighbor ] = g_score [ neighbor ] + heuristic_cost_estimate ( neighbor, endnode )
					print(tentative_g_score)

					debugoverlay.Box( neighbor, Vector(10,10,10), Vector(-10,-10,-10), 10, Color( tentative_g_score/100, tentative_g_score/100, tentative_g_score/100, 0 ) )

					table.insert ( open_list, neighbor )							
				end
			end
		end
	end
end

function botN.calculateCost(currentnode, endnode)
	return currentnode:DistToSqr(endnode) 
end

function botN.nearestNode(vec)
	local nodeindex
	local distance = 9999999999
	for k, v in pairs( nodes ) do
		for k2, v2 in pairs( v ) do
			for k3, v3 in pairs( v2 ) do


				local vecnode = Vector(k, k2, v3)
				local dist = vecnode:DistToSqr(vec)
				if (dist < distance) then
					nodeindex = vecnode
					distance = dist
				end
			end
		end
	end


	return nodeindex
end

function botN.getNodesAroundNode(plc)
	local nearnodes = {}

	for x=-2,2 do 	
		for y=-2,2 do		
			local xpos = (x*20)+plc.x
			local ypos = (y*20)+plc.y

			botN.GenerateNodeAtPos(Vector(xpos, ypos, plc.z))

			if (nodes[xpos] and nodes[xpos][ypos]) then
				for k, v in pairs ( nodes[xpos][ypos] ) do


					local vec = Vector(xpos,ypos,v)

					if (vec:DistToSqr(plc) < 25 ^ 2) then

						if (vec != plc) then
							table.insert(nearnodes, vec)
						end
					end	
				end
			end
		end
	end

	-- for k, v in pairs( nodes ) do
	-- 	for k2, v2 in pairs( v ) do
	-- 		local vecnode = Vector(k, k2, v2)
	-- 		local dist = plc:DistToSqr(vecnode)
	-- 		if (dist < (10 ^ 2)) then
	-- 			table.insert(nearnodes, vecnode)
	-- 		end
	-- 	end
	-- end

	return nearnodes
end

function botN.GenerateNodeAtPos(vec)

	if (!util.IsInWorld( vec )) then
		local tr = util.TraceLine( {
			start = vec,
			endpos = vec - Vector(0,0,20),
			filter = function( ent ) 

				if ( ent == LocalPlayer()) then 
					return false 
				end 


			end

		} )

	

		local newpos = tr.HitPos
		if tr.HitWorld then
			local tr = {
				start = newpos + Vector(0,0,5),
				endpos = newpos + Vector(0,0,5),
				mins = Vector( -16, -16, 0 ),
				maxs = Vector( 16, 16, 71  ),
				filter = function( ent ) if ( ent == LocalPlayer()) then return false end end
			}
			
			local hullTrace = util.TraceHull( tr )

			if ( !hullTrace.Hit ) then
				nodes[newpos.x] = nodes[newpos.x] or {}
				nodes[newpos.x][newpos.y] = nodes[newpos.x][newpos.y] or {}
				table.insert(nodes[newpos.x][newpos.y], newpos.z)
			end
		end
	end			
end


hook.Add("PostDrawOpaqueRenderables", "example", function()
	if (nodes) then
		

		
	end
end )

if botN.isParent() then
	botN.ComputePath(Vector(-2356, -1262, -79))

end
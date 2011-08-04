--[[
Name: "sh_plugin.lua".
Product: "Citrus (Server Management)".
--]]

local PLUGIN = citrus.Plugins.Get("Translate")

-- Translate Entity.
function PLUGIN.TranslateEntity(Entity, Duplicate, Key)
	local OBBMaxs = Entity:OBBMaxs()
	local OBBMins = Entity:OBBMins()
	
	-- Temp Up.
	local TempUp = Entity:GetUp()
	local TempRight = Entity:GetRight()
	local TempForward = Entity:GetForward()
	
	-- Position.
	local Position = Entity:GetPos()
	
	-- Up.
	local Up = Position + TempUp * (OBBMaxs.z - OBBMins.z)
	local Down = Position + TempUp * -(OBBMaxs.z - OBBMins.z)
	local Right = Position + TempRight * (OBBMaxs.y - OBBMins.y)
	local Left = Position + TempRight * -(OBBMaxs.y - OBBMins.y)
	local Forward = Position + TempForward * (OBBMaxs.x - OBBMins.x)
	local Backward = Position + TempForward * -(OBBMaxs.x - OBBMins.x)
	
	-- Check Key.
	if (Key == IN_FORWARD) then
		Duplicate:SetPos(Backward)
	elseif (Key == IN_BACK) then
		Duplicate:SetPos(Forward)
	elseif (Key == IN_MOVERIGHT) then
		Duplicate:SetPos(Left)
	elseif (Key == IN_MOVELEFT) then
		Duplicate:SetPos(Right)
	elseif (Key == IN_JUMP) then
		Duplicate:SetPos(Up)
	elseif (Key == IN_DUCK) then
		Duplicate:SetPos(Down)
	end
end
--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Death Watch")

-- Calc View.
function PLUGIN.CalcView(Player, Origin, Angles, FOV)
	local Ragdoll = Player:GetRagdollEntity()

	-- Check Ragdoll.
	if (Ragdoll) then
		local IsValid = Ragdoll:IsValid()
		
		-- Check Is Valid.
		if (IsValid) then
			local Eyes = Ragdoll:GetAttachment(Ragdoll:LookupAttachment("Eyes"))
			
			-- Check Eyes.
			if (Eyes) then		
				local View = {origin = Eyes.Pos, angles = Eyes.Ang, fov = 90}
				
				-- Return View.
				return View
			end
		end
	end
end

-- Hook Add.
PLUGIN:HookAdd("CalcView", PLUGIN.CalcView)
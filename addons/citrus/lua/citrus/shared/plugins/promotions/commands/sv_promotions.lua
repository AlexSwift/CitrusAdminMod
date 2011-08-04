--[[
Name: "sv_promotions.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("promotions", "S")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Promotions")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Promotions")
	Menu:SetIcon("gui/silkicons/star")
	Menu:SetUpdate(COMMAND.Callback)
	Menu:SetReference(COMMAND.Callback)
	
	-- Check Count.
	if (table.Count(PLUGIN.Configuration) < table.Count(citrus.Groups.Stored)) then
		Menu:ButtonAdd("Add", COMMAND.Add)
	end
	
	-- Check Count.
	if (table.Count(PLUGIN.Configuration) > 0) then
		Menu:ButtonAdd("Remove", COMMAND.Remove)
		Menu:ButtonAdd("Edit", COMMAND.Edit)
	end
	
	-- Send.
	Menu:Send()
end

-- Add.
function COMMAND.Add(Player)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Add Promotion")
	Menu:SetIcon("gui/silkicons/add")
	Menu:SetUpdate(COMMAND.Add)
	Menu:SetReference(COMMAND.Add)
	
	-- Success.
	local Success = false
	
	-- For Loop.
	for K, V in pairs(citrus.Groups.Stored) do
		if (!PLUGIN.Configuration[K]) then
			Menu:ButtonAdd(V.Name, function() COMMAND.SetPromotionHours(Player, V, "Add") end)
			
			-- Success.
			Success = true
		end
	end
	
	-- Check Success.
	if (!Success) then Menu:TextAdd("Unable to locate groups!") end
	
	-- Send.
	Menu:Send()
end

-- Edit.
function COMMAND.Edit(Player)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Edit Promotion")
	Menu:SetIcon("gui/silkicons/wrench")
	Menu:SetUpdate(COMMAND.Edit)
	Menu:SetReference(COMMAND.Edit)
	
	-- Success.
	local Success = false
	
	-- For Loop.
	for K, V in pairs(PLUGIN.Configuration) do
		if (citrus.Groups.Get(K)) then
			Menu:ButtonAdd(K, function() COMMAND.SetPromotionHours(Player, citrus.Groups.Get(K), "Edit") end)
			
			-- Success.
			Success = true
		end
	end
	
	-- Check Success.
	if (!Success) then Menu:TextAdd("Unable to locate promotions!") end
	
	-- Send.
	Menu:Send()
end

-- Remove.
function COMMAND.Remove(Player)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Remove Promotion")
	Menu:SetIcon("gui/silkicons/exclamation")
	Menu:SetUpdate(COMMAND.Remove)
	Menu:SetReference(COMMAND.Remove)
	
	-- Success.
	local Success = false
	
	-- For Loop.
	for K, V in pairs(PLUGIN.Configuration) do
		Menu:ButtonAdd(K, function()
			PLUGIN.Configuration[K] = nil
			
			-- Check Get.
			if (citrus.Groups.Get(K)) then
				citrus.Groups.Get(K):SetSetting("Promotion", nil)
			end
			
			-- Update.
			citrus.Menus.Update(nil, COMMAND.Callback)
			citrus.Menus.Update(nil, COMMAND.Add)
			citrus.Menus.Update(nil, COMMAND.Remove)
			
			-- Notify All.
			citrus.Player.NotifyAll("Promotion for "..K.." removed.")
		end)
		
		-- Success.
		Success = true
	end
	
	-- Check Success.
	if (!Success) then Menu:TextAdd("Unable to locate promotions!") end
	
	-- Send.
	Menu:Send()
end

-- Set Promotion Hours.
function COMMAND.SetPromotionHours(Player, Group, Type)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Set Promotion Hours ("..Group.Name..")")
	Menu:SetIcon("gui/silkicons/wrench")
	Menu:SetReference(COMMAND.SetPromotionHours, Group, Type)
	
	-- Slider Add.
	Menu:SliderAdd("Hour(s)", function(Player, Value)
		PLUGIN.Configuration[Group.Name] = Value
		
		-- Set Setting.
		Group:SetSetting("Promotion", Value.." Hour(s)")
		
		-- Update.
		citrus.Menus.Update(nil, COMMAND.Callback)
		citrus.Menus.Update(nil, COMMAND.Edit)
		citrus.Menus.Update(nil, COMMAND.Add)
		
		-- Check Type.
		if (Type == "Add") then
			citrus.Player.NotifyAll("Promotion for "..Group.Name.." added.")
		else
			citrus.Player.NotifyAll("Promotion for "..Group.Name.." edited.")
		end
	end, 1, 250, {Value = PLUGIN.Configuration[Group.Name] or 0, Discontinue = true})
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Plugin Configuration", "Promotions")

-- Create.
COMMAND:Create()
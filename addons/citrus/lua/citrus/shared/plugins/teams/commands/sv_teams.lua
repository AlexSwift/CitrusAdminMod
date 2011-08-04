--[[
Name: "sv_teams.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("teams", "S")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Teams")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Teams")
	Menu:SetIcon("gui/silkicons/group")
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

-- Remove.
function COMMAND.Remove(Player)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Remove Team")
	Menu:SetIcon("gui/silkicons/exclamation")
	Menu:SetUpdate(COMMAND.Remove)
	Menu:SetReference(COMMAND.Remove)
	
	-- Success.
	local Success = false
	
	-- For Loop.
	for K, V in pairs(PLUGIN.Configuration) do
		Menu:ButtonAdd(K, function()
			PLUGIN.Configuration[K] = nil
			
			-- Get.
			local Group = citrus.Groups.Get(K)
			
			-- Check Group.
			if (Group) then
				Group:SetSetting("Team", nil)
				
				-- Players.
				local Players = player.GetAll()
				
				-- For Loop.
				for K, V in pairs(Players) do
					if (citrus.Player.GetGroup(Player) == Group) then
						V:SetTeam(TEAM_UNASSIGNED)
						V:Spawn()
					end
				end
			end
			
			-- Update.
			citrus.Menus.Update(nil, COMMAND.Callback)
			citrus.Menus.Update(nil, COMMAND.Add)
			citrus.Menus.Update(nil, COMMAND.Remove)
			citrus.Menus.Update(nil, COMMAND.Edit)
			citrus.Menus.Remove(nil, COMMAND.SetTeamColor, K, "Edit")
			
			-- Notify.
			citrus.Player.NotifyAll("Team for "..K.." removed.")
		end)
		
		-- Success.
		Success = true
	end
	
	-- Check Success.
	if (!Success) then Menu:TextAdd("Unable to locate teams!") end
	
	-- Send.
	Menu:Send()
end

-- Add.
function COMMAND.Add(Player)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Add Team")
	Menu:SetIcon("gui/silkicons/add")
	Menu:SetUpdate(COMMAND.Add)
	Menu:SetReference(COMMAND.Add)
	
	-- Success.
	local Success = false
	
	-- For Loop.
	for K, V in pairs(citrus.Groups.Stored) do
		if (!PLUGIN.Configuration[V.Name]) then
			Menu:ButtonAdd(V.Name, function()
				COMMAND.SetTeamColor(Player, V, "Add")
			end)
			
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
	Menu:SetTitle("Edit Team")
	Menu:SetIcon("gui/silkicons/wrench")
	Menu:SetUpdate(COMMAND.Edit)
	Menu:SetReference(COMMAND.Edit)
	
	-- Success.
	local Success = false
	
	-- For Loop.
	for K, V in pairs(PLUGIN.Configuration) do
		local Group = citrus.Groups.Get(K)
		
		-- Check Group.
		if (Group) then
			Menu:ButtonAdd(Group.Name, function()
				COMMAND.SetTeamColor(Player, Group, "Edit")
			end)
			
			-- Success.
			Success = true
		end
	end
	
	-- Check Success.
	if (!Success) then Menu:TextAdd("Unable to locate teams!") end
	
	-- Send.
	Menu:Send()
end

-- Set Team Color.
function COMMAND.SetTeamColor(Player, Group, Type)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Set Team Color ("..Group.Name..")")
	Menu:SetIcon("gui/silkicons/group")
	Menu:SetReference(COMMAND.SetTeamColor, Group.Name, Type)
	
	-- Red.
	local Red = 255
	local Green = 255
	local Blue = 255
	local Alpha = 255
	
	-- Check Type.
	if (Type == "Edit") then
		Red = Group:GetSetting("Team").Color.r
		Green = Group:GetSetting("Team").Color.g
		Blue = Group:GetSetting("Team").Color.b
		Alpha = Group:GetSetting("Team").Color.a
	end
	
	-- Slider Add.
	Menu:SliderAdd("Red", function(Player, Value) Red = Value end, 0, 255, {Index = "Red", Value = Red})
	Menu:SliderAdd("Green", function(Player, Value) Green = Value end, 0, 255, {Index = "Green", Value = Green})
	Menu:SliderAdd("Blue", function(Player, Value) Blue = Value end, 0, 255, {Index = "Blue", Value = Blue})
	Menu:SliderAdd("Alpha", function(Player, Value) Alpha = Value end, 0, 255, {Index = "Alpha", Value = Alpha})
	Menu:ControlAdd("Team Color", {Red = "Red", Green = "Green", Blue = "Blue", Alpha = "Alpha"})
	Menu:ButtonAdd(Type, function()
		if (Type == "Add") then
			PLUGIN.SetUp(Group, Color(Red, Green, Blue, Alpha), true)
			
			-- Notify All.
			citrus.Player.NotifyAll("Team for "..Group.Name.." added.")
		else
			PLUGIN.SetUp(Group, Color(Red, Green, Blue, Alpha))
			
			-- Notify All.
			citrus.Player.NotifyAll("Team for "..Group.Name.." edited.")
		end
		
		-- Update.
		citrus.Menus.Update(nil, COMMAND.Callback)
		citrus.Menus.Update(nil, COMMAND.Add)
		citrus.Menus.Update(nil, COMMAND.Remove)
		citrus.Menus.Update(nil, COMMAND.Edit)
	end, {Discontinue = (Type == "Add")})
	
	-- Send.
	Menu:Send()
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Plugin Configuration", "Teams")

-- Create.
COMMAND:Create()
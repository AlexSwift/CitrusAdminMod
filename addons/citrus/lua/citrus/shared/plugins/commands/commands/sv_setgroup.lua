--[[
Name: "sv_setgroup.lua".
Product: "Citrus (Server Management)"
--]]

local COMMAND = citrus.Command:New("setgroup", "A", {{"Player", "player"}, {"Group", "string"}})

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Commands")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- RCon Callback.
function COMMAND.RConCallback(Arguments)
	local Group, Error = citrus.Groups.Get(Arguments[2])
	
	-- Check Group.
	if (Group) then
		citrus.Groups.Set(Arguments[1], Group)
		
		-- Notify By Access.
		citrus.Player.NotifyByAccess("M", Arguments[1]:Name().."'s group is set to "..Group.Name.." (Console).")
		citrus.Player.NotifyByAccess("!M", Arguments[1]:Name().."'s group is set to "..Group.Name..".")
		
		-- Print.
		print(Arguments[1]:Name().."'s group is set to "..Group.Name.." (Console).")
	else
		print(Error)
	end
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	local Group, Error = citrus.Groups.Get(Arguments[2])
	
	-- Check Group.
	if (Group) then
		if (Player == Arguments[1]) then
			citrus.Player.Notify(Player, "Unable to set own group!", 1)
		elseif (citrus.Player.GetGroup(Player):GetSetting("Rank") > Group:GetSetting("Rank")) then
			citrus.Player.Notify(Player, "Unable to set player to higher ranked group!", 1)
		elseif (citrus.Player.GetGroup(Player):GetSetting("Rank") > citrus.Player.GetGroup(Arguments[1]):GetSetting("Rank")) then
			citrus.Player.Notify(Player, "Unable to set group of higher ranked player!", 1)
		else
			citrus.Groups.Set(Arguments[1], Group)
			
			-- Notify By Access.
			citrus.Player.NotifyByAccess("M", Arguments[1]:Name().."'s group is set to "..Group.Name.." ("..Player:Name()..").")
			citrus.Player.NotifyByAccess("!M", Arguments[1]:Name().."'s group is set to "..Group.Name..".")
		end
	else
		citrus.Player.Notify(Player, Error, 1)
	end
end

-- Get Group.
function COMMAND.GetGroup(Player, Menu, Argument)
	for K, V in pairs(citrus.Groups.Stored) do
		Menu:ButtonAdd(V.Name, function()
			citrus.QuickMenu.SetArgument(Player, Argument, V.Name)
		end)
	end
end

-- Quick Menu Add.
COMMAND:QuickMenuAdd("Player Administration", "Set Group", {{"Player", citrus.QuickMenu.GetPlayer}, {"Group", COMMAND.GetGroup}}, "gui/silkicons/group")

-- Create.
COMMAND:Create()
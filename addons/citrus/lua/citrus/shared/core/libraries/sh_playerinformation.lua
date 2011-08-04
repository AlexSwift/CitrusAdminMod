--[[
Name: "sh_playerinformation.lua".
Product: "Citrus (Server Management)".
--]]

citrus.PlayerInformation = {}

-- Set.
function citrus.PlayerInformation.Set(Player, Type, Key, Value)
	Key = util.CRC("citrus.PlayerInformation['"..Type.."']['"..Key.."']")
	
	-- Set Networked Var.
	Player:SetNetworkedVar(Key, Value)
end

-- Get.
function citrus.PlayerInformation.Get(Player, Type, Key)
	Key = util.CRC("citrus.PlayerInformation['"..Type.."']['"..Key.."']")
	
	-- Return Get Networked Var.
	return Player:GetNetworkedVar(Key)
end

-- Show.
function citrus.PlayerInformation.Show(Player, Target)
	umsg.Start("citrus.PlayerInformation.Show", Player)
		umsg.Entity(Target)
	umsg.End()
end

-- Check CLIENT.
if (CLIENT) then
	citrus.PlayerInformation.Stored = {}

	-- Type Add.
	function citrus.PlayerInformation.TypeAdd(Type)
		citrus.PlayerInformation.Stored[Type] = citrus.PlayerInformation.Stored[Type] or {}
	end

	-- Type Remove.
	function citrus.PlayerInformation.TypeRemove(Type)
		citrus.PlayerInformation.Stored[Type] = nil
	end

	-- Key Add.
	function citrus.PlayerInformation.KeyAdd(Type, Key)
		citrus.PlayerInformation.Stored[Type] = citrus.PlayerInformation.Stored[Type] or {}
		
		-- Type.
		citrus.PlayerInformation.Stored[Type][#citrus.PlayerInformation.Stored[Type] + 1] = Key
	end

	-- Key Remove.
	function citrus.PlayerInformation.KeyRemove(Type, Key)
		if (citrus.PlayerInformation.Stored[Type]) then
			for K, V in pairs(citrus.PlayerInformation.Stored[Type]) do
				if (V == Key) then citrus.PlayerInformation.Stored[Type][K] = nil end
			end
		end
	end

	-- Get All.
	function citrus.PlayerInformation.GetAll(Player, Type)
		if (citrus.PlayerInformation.Stored[Type]) then
			local Table = {}
			
			-- Check List.
			if (table.Count(citrus.PlayerInformation.Stored[Type]) == 0) then return false end
			
			-- For Loop.
			for K, V in pairs(citrus.PlayerInformation.Stored[Type]) do
				local Text = citrus.PlayerInformation.Get(Player, Type, V)
				
				-- Check Text.
				if (Text != "") then Table[V] = Text end
			end
			
			-- Return Table.
			return Table
		end
		
		-- Return False.
		return false
	end
	
	-- Show.
	function citrus.PlayerInformation.Show(Player)
		local Menu = citrus.Menu:New()
		
		-- Set Title.
		Menu:SetTitle("Player Information ("..Player:Name()..")")
		Menu:SetIcon("gui/silkicons/user")
		Menu:SetReference(citrus.PlayerInformation.Show, Player)
		
		-- Success.
		local Success = false
		local Public = citrus.PlayerInformation.GetAll(Player, "Public")
		
		-- Check Public.
		if (Public) then
			for K, V in pairs(Public) do
				Menu:ControlAdd("Text", {Text = K..": "..tostring(V).."."})
				
				-- Success.
				Success = true
			end
		end
		
		-- Check Success.
		if (!Success) then Menu:ControlAdd("Text", {Text = "Unable to find information!"}) end
		
		-- Create.
		Menu:Create()
	end
	
	-- Hook.
	usermessage.Hook("citrus.PlayerInformation.Show", function(Message)
		local Player = Message:ReadEntity()
		
		-- Check Valid Entity.
		if (ValidEntity(Player)) then citrus.PlayerInformation.Show(Player) end
	end)
end
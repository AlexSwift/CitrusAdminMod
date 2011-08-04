--[[
Name: "sv_quickmenu.lua".
Product: "Citrus (Server Management)".
--]]

citrus.QuickMenu = {}
citrus.QuickMenu.Stored = {}

-- Add.
function citrus.QuickMenu.Add(Category, Name, Command, Arguments, Access, Icon)
	citrus.QuickMenu.Stored[#citrus.QuickMenu.Stored + 1] = {Category = Category, Name = Name, Command = Command, Access = Access or "B", Arguments = Arguments or {}, Icon = Icon}
	
	-- Return Stored.
	return #citrus.QuickMenu.Stored
end

-- Remove.
function citrus.QuickMenu.Remove(Index)
	citrus.QuickMenu.Stored[Index] = nil
end

-- Hide.
function citrus.QuickMenu.Hide(Index, Boolean)
	if (citrus.QuickMenu.Stored[Index]) then
		citrus.QuickMenu.Stored[Index].Hidden = Boolean
	end
end

-- Get Player.
function citrus.QuickMenu.GetPlayer(Player, Menu, Argument, Title)
	local Players = player.GetAll()
	
	-- For Loop.
	for K, V in pairs(Players) do
		Menu:ButtonAdd(V:Name(), function()
			citrus.QuickMenu.SetArgument(Player, Argument, citrus.Player.GetUniqueID(V))
		end)
	end
end

-- Get Boolean.
function citrus.QuickMenu.GetBoolean(Player, Menu, Argument, Title)
	Menu:CheckBoxAdd(Title, function(Player, Value)
		citrus.QuickMenu.SetArgument(Player, Argument, Value)
	end, true, {Confirmation = true})
end

-- Get Text.
function citrus.QuickMenu.GetText(Player, Menu, Argument, Title)
	citrus.Menus.TextEntry(Player, Title, function(Player, Text)
		citrus.QuickMenu.SetArgument(Player, Argument, Text)
	end, true)
	
	-- Return True.
	return true
end

-- Start.
function citrus.QuickMenu.Start(Player, Index)
	if (citrus.QuickMenu.Stored[Index]) then
		if (citrus.Access.Has(Player, citrus.QuickMenu.Stored[Index].Access)) then
			if (table.Count(citrus.QuickMenu.Stored[Index].Arguments) > 0) then
				citrus.PlayerCookies.Set(Player, "QuickMenu", {Index = Index, Arguments = {}})
				
				-- Next.
				citrus.QuickMenu.Next(Player, 1)
			else
				citrus.Player.ConsoleCommand(Player, citrus.QuickMenu.Stored[Index].Command)
			end
		end
	end
end

-- Set Argument.
function citrus.QuickMenu.SetArgument(Player, Argument, Value)
	local QuickMenu = citrus.PlayerCookies.Get(Player, "QuickMenu")
	
	-- Check Quick Menu.
	if (QuickMenu) then
		QuickMenu.Arguments[Argument] = Value
		
		-- Next.
		citrus.QuickMenu.Next(Player, Argument + 1)
	end
end

-- Next.
function citrus.QuickMenu.Next(Player, Argument)
	local QuickMenu = citrus.PlayerCookies.Get(Player, "QuickMenu")
	
	-- Check Quick Menu.
	if (QuickMenu) then
		local Index = QuickMenu.Index
		
		-- Check List.
		if (citrus.QuickMenu.Stored[Index]) then
			local Current = citrus.QuickMenu.Stored[Index].Arguments[Argument]
			local Name = citrus.QuickMenu.Stored[Index].Name
			
			-- Check Current.
			if (Current) then
				local Menu = citrus.Menu:New()
				
				-- Set Player.
				Menu:SetPlayer(Player)
				Menu:SetTitle(Name.." ("..Current[1]..")")
				Menu:SetReference(citrus.QuickMenu.Next, Index, Argument)
				
				-- Check Icon.
				if (citrus.QuickMenu.Stored[Index].Icon) then
					Menu:SetIcon(citrus.QuickMenu.Stored[Index].Icon)
				end
				
				-- Check 2.
				if (Current[2](Player, Menu, Argument, Current[1])) then
					Menu = nil
				else			
					Menu:Send()
				end
			else
				local Arguments = {}
				
				-- For Loop.
				for K, V in pairs(QuickMenu.Arguments) do Arguments[#Arguments + 1] = "\""..tostring(V).."\"" end
				
				-- Callback.
				local Command = citrus.QuickMenu.Stored[Index].Command.." "..table.concat(Arguments, " ")
				
				-- Console Command.
				citrus.Player.ConsoleCommand(Player, Command)
			end
		end
	end
end

-- Display.
function citrus.QuickMenu.Display(Player)
	local Menu = citrus.Menu:New()
	
	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Quick Menu")
	Menu:SetIcon("gui/silkicons/application")
	Menu:SetReference(citrus.QuickMenu.Display)
	
	-- Success.
	local Success = false
	local Categories = {}
	
	-- For Loop.
	for K, V in pairs(citrus.QuickMenu.Stored) do
		if (!V.Hidden) then
			if (!Categories[V.Category]) then
				if (citrus.Access.Has(Player, V.Access)) then Categories[V.Category] = V.Category end
			end
		end
	end
	
	-- For Loop.
	for K, V in pairs(Categories) do
		Menu:ButtonAdd(V, function() citrus.QuickMenu.Category(Player, V) end)
		
		-- Success.
		Success = true
	end
	
	-- Check Success.
	if (!Success) then Menu:TextAdd("Unable to locate categories!") end
	
	-- Send.
	Menu:Send()
end

-- Category.
function citrus.QuickMenu.Category(Player, Category)
	local Menu = citrus.Menu:New()
	
	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Quick Menu ("..Category..")")
	Menu:SetIcon("gui/silkicons/application")
	Menu:SetReference(citrus.QuickMenu.Category, Category)
	
	-- Success.
	local Success = false
	
	-- For Loop.
	for K, V in pairs(citrus.QuickMenu.Stored) do
		if (!V.Hidden) then
			if (V.Category == Category) then
				if (citrus.Access.Has(Player, V.Access)) then
					Menu:ButtonAdd(V.Name, function() citrus.QuickMenu.Start(Player, K) end)
					
					-- Success.
					Success = true
				end
			end
		end
	end
	
	-- Check Success.
	if (!Success) then Menu:TextAdd("Unable to locate commands!") end
	
	-- Send.
	Menu:Send()
end
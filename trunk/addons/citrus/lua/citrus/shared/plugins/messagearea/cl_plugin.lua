--[[
Name: "cl_plugin.lua".
Product: "Citrus (Server Management)"
--]]

local PLUGIN = citrus.Plugin:New("Message Area")

-- Create Client ConVar.
-- CreateClientConVar("cl_messagearea_avatars", "0", true, true)
CreateClientConVar("cl_messagearea_joinleave", "1", true, true)
CreateClientConVar("cl_messagearea_chat", "1", true, true)
CreateClientConVar("cl_messagearea_none", "1", true, true)
CreateClientConVar("cl_messagearea_team", "1", true, true)

-- Emoticons.
PLUGIN.Emoticons = {}
PLUGIN.Messages = {}
PLUGIN.Derma = {}
PLUGIN.Tags = {}

-- History.
PLUGIN.History = {}
PLUGIN.History.Messages = {}
PLUGIN.History.Position = 0

-- Include Directory.
citrus.Utilities.IncludeDirectory(PLUGIN.FilePath.."/tags/", "cl_", ".lua")

-- On Load.
function PLUGIN:OnLoad()
	citrus.PlayerInformation.TypeAdd("Message Area")
	citrus.PlayerInformation.KeyAdd("Message Area", "Title")
	citrus.PlayerInformation.KeyAdd("Message Area", "Color")
	
	-- Check Initialized.
	if (!self.Initialized) then
		self.Initialized = true
		
		-- Create Derma Panel.
		PLUGIN.CreateDermaPanel()
		PLUGIN.CreateDermaTextEntry()
		PLUGIN.CreateDermaButtons()
		PLUGIN.CreateDermaCheckBoxes()
		PLUGIN.CreateDermaFilters()
		
		-- Hide.
		PLUGIN.Derma.Panel.Hide()
		
		-- -- Avatars.
		-- PLUGIN.Derma.Avatars = {}
		
		-- -- For Loop.
		-- for I = 1, 5 do
			-- PLUGIN.Derma.Avatars[I] = vgui.Create("AvatarImage")
			-- PLUGIN.Derma.Avatars[I]:SetSize(20, 20)
			-- PLUGIN.Derma.Avatars[I]:SetVisible(false)
		-- end
	end
end

-- On Unload.
function PLUGIN:OnUnload()
	citrus.PlayerInformation.TypeRemove("Message Area")
	citrus.PlayerInformation.KeyRemove("Message Area", "Title")
	citrus.PlayerInformation.KeyRemove("Message Area", "Color")
	
	-- Message Text.
	PLUGIN.MessageText = false
end

-- Usermessage Hook.
PLUGIN:UsermessageHook("Team Message", function(Message)
	local Player = Message:ReadEntity()
	local Text = Message:ReadString()
	
	-- Chat Text.
	PLUGIN.ChatText(Player:EntIndex(), Player:Name(), Text, "team")
end)

-- Usermessage Hook.
PLUGIN:UsermessageHook("Emoticon", function(Message)
	local Emoticon = Message:ReadString()
	local Texture = Message:ReadString()
	
	-- Material.
	local Material = Material(Texture)
	
	-- Emoticon.
	PLUGIN.Emoticons[Emoticon] = {}
	PLUGIN.Emoticons[Emoticon].TextureID = surface.GetTextureID(Texture)
	PLUGIN.Emoticons[Emoticon].Width = Material:GetMaterialInt("$width")
	PLUGIN.Emoticons[Emoticon].Height = Material:GetMaterialInt("$height")
	
	-- Check Width.
	if (!PLUGIN.Emoticons[Emoticon].Width or !PLUGIN.Emoticons[Emoticon].Height) then
		PLUGIN.Emoticons[Emoticon] = nil
		
		-- Return.
		return
	end
	
	-- Set Font.
	surface.SetFont("citrus_MainText")
	
	-- Width.
	local Width, Height = surface.GetTextSize("W")
	
	-- Characters.
	PLUGIN.Emoticons[Emoticon].Characters = math.ceil(PLUGIN.Emoticons[Emoticon].Width / Width)
end)

-- Get Position.
function PLUGIN.GetPosition() return 24, ScrH() - (ScrH() / 4) end

-- Get X.
function PLUGIN.GetX()
	local X, Y = PLUGIN.GetPosition()
	
	-- Return X.
	return X
end

-- Get Y.
function PLUGIN.GetY()
	local X, Y = PLUGIN.GetPosition()
	
	-- Return Y.
	return Y
end

-- Get Spacing.
function PLUGIN.GetSpacing(Message)
	if (Message) then
		return 20 + Message.Spacing
	else
		return 20
	end
end

-- Create Derma Buttons.
function PLUGIN.CreateDermaButtons()
	if (!PLUGIN.Derma.Buttons) then
		PLUGIN.Derma.Buttons = {}
		
		-- Create Derma Button.
		PLUGIN.CreateDermaButton("Up", "+", 434, 16, "Scroll up the message area.", function()
			PLUGIN.History.Position = PLUGIN.History.Position - 1
		end, function(self)
			if (PLUGIN.History.Messages[PLUGIN.History.Position - 5]) then
				self:SetDisabled(false)
			else
				self:SetDisabled(true)
			end
		end)
		PLUGIN.CreateDermaButton("Down", "-", 454, 16, "Scroll down the message area.", function()
			PLUGIN.History.Position = PLUGIN.History.Position + 1
		end, function(self)
			if (PLUGIN.History.Messages[PLUGIN.History.Position + 1]) then
				self:SetDisabled(false)
			else
				self:SetDisabled(true)
			end
		end)
		PLUGIN.CreateDermaButton("Bottom", "*", 474, 16, "Goto the bottom of the message area.", function()
			PLUGIN.History.Position = #PLUGIN.History.Messages
		end, function(self)
			if (PLUGIN.History.Position < #PLUGIN.History.Messages) then
				self:SetDisabled(false)
			else
				self:SetDisabled(true)
			end
		end)
		PLUGIN.CreateDermaButton("Filters", "Filters", 494, 80, "Enable or disable message filters.", function()
			local IsVisible = PLUGIN.Derma.Filters:IsVisible()
			
			-- Check Is Visible.
			if (IsVisible) then
				PLUGIN.Derma.Filters:SetVisible(false)
			else
				PLUGIN.Derma.Filters:SetVisible(true)
			end
		end, function(self) end)
	end
end
	
-- Create Derma Button.
function PLUGIN.CreateDermaButton(Name, Text, X, Width, ToolTip, DoClick, Think)
	if (!PLUGIN.Derma.Buttons[Name]) then
		PLUGIN.Derma.Buttons[Name] = vgui.Create("DButton", PLUGIN.Derma.Panel)
		PLUGIN.Derma.Buttons[Name]:SetText(Text)
		PLUGIN.Derma.Buttons[Name]:SetSize(Width, 16)
		PLUGIN.Derma.Buttons[Name]:SetPos(X, 4)
		PLUGIN.Derma.Buttons[Name]:SetToolTip(ToolTip)
		PLUGIN.Derma.Buttons[Name].DoClick = DoClick
		PLUGIN.Derma.Buttons[Name].Think = Think
	end
end

-- Create Derma Check Boxes.
function PLUGIN.CreateDermaCheckBoxes()
	if (!PLUGIN.Derma.CheckBoxes) then PLUGIN.Derma.CheckBoxes = {} end
end

-- Create Derma Check Box.
function PLUGIN.CreateDermaCheckBox(Name, ConVar, X, Y, ToolTip, Label, Parent)
	Name = Name or ConVar
	
	-- Check Name.
	if (!PLUGIN.Derma.CheckBoxes[Name]) then
		Parent = Parent or PLUGIN.Derma.Panel
		
		-- Check Label.
		if (Label) then
			PLUGIN.Derma.CheckBoxes[Name] = vgui.Create("DCheckBoxLabel", Parent)
			PLUGIN.Derma.CheckBoxes[Name]:SetText(Label)
		else
			PLUGIN.Derma.CheckBoxes[Name] = vgui.Create("DCheckBox", Parent)
		end
		
		-- Set Pos.
		PLUGIN.Derma.CheckBoxes[Name]:SetPos(X, Y)
		PLUGIN.Derma.CheckBoxes[Name]:SetToolTip(ToolTip)
		PLUGIN.Derma.CheckBoxes[Name]:SetConVar(ConVar)
		
		-- Check Label.
		if (Label) then
			PLUGIN.Derma.CheckBoxes[Name]:SizeToContents()
		else
			PLUGIN.Derma.CheckBoxes[Name]:SetSize(16, 16)
		end
	end
end

-- Create Derma Text Entry.
function PLUGIN.CreateDermaTextEntry()
	if (!PLUGIN.Derma.TextEntry) then
		PLUGIN.Derma.TextEntry = vgui.Create("DTextEntry", PLUGIN.Derma.Panel)
		PLUGIN.Derma.TextEntry:SetPos(34, 4)
		PLUGIN.Derma.TextEntry:SetSize(396, 16)
		PLUGIN.Derma.TextEntry.OnEnter = function()
			local Message = PLUGIN.Derma.TextEntry:GetValue()
			
			-- Check Message.
			if (Message and Message != "") then
				PLUGIN.History.Position = #PLUGIN.History.Messages
				
				-- Message.
				Message = string.Replace(Message, '"', '\"')
				
				-- Check Say Team.
				if (PLUGIN.SayTeam) then
					LocalPlayer():ConCommand("say_team \""..Message.."\"\n")
				else
					LocalPlayer():ConCommand("say \""..Message.."\"\n")
				end
				
				-- Set Text.
				PLUGIN.Derma.TextEntry:SetText("")
			end
			
			-- Hide.
			PLUGIN.Derma.Panel.Hide()
		end
		
		-- Think.
		function PLUGIN.Derma.TextEntry:Think()
			local Message = self:GetValue()
			
			-- Check Len.
			if (string.len(Message) > 126) then
				self:SetValue(string.sub(Message, 1, 126))
				self:SetCaretPos(126)
				
				-- Play Sound.
				surface.PlaySound("common/talk.wav")
			end
		end
	end
end

-- Create Derma Panel.
function PLUGIN.CreateDermaPanel()
	if (!PLUGIN.Derma.Panel) then
		PLUGIN.Derma.Panel = vgui.Create("EditablePanel")
		PLUGIN.Derma.Panel:SetSize(578, 24)
		PLUGIN.Derma.Panel.Show = function()
			PLUGIN.Derma.Panel:SetKeyboardInputEnabled(true)
			PLUGIN.Derma.Panel:SetMouseInputEnabled(true)
			
			-- Set Visible.
			PLUGIN.Derma.Scroll:SetVisible(true)
			PLUGIN.Derma.Panel:SetVisible(true)
			PLUGIN.Derma.Panel:MakePopup()
			
			-- Position.
			PLUGIN.History.Position = #PLUGIN.History.Messages
			
			-- Request Focus.
			PLUGIN.Derma.TextEntry:RequestFocus()
		end
		PLUGIN.Derma.Panel.Hide = function()
			PLUGIN.Derma.Panel:SetKeyboardInputEnabled(false)
			PLUGIN.Derma.Panel:SetMouseInputEnabled(false)
			
			-- Set Visible.
			PLUGIN.Derma.Panel:SetVisible(false)
			PLUGIN.Derma.Filters:SetVisible(false)
			PLUGIN.Derma.Scroll:SetVisible(false)
		end
		
		-- Paint.
		function PLUGIN.Derma.Panel:Paint()
			local BackgroundColor = citrus.Themes.GetColor("Background")
			local CornerSize = citrus.Themes.GetSize("Corner")
			local TitleColor = citrus.Themes.GetColor("Title")
			local TextColor = citrus.Themes.GetColor("Text")
			
			-- Rounded Box.
			draw.RoundedBox(CornerSize, 0, 0, self:GetWide(), self:GetTall(), BackgroundColor)
			
			-- Set Font.
			surface.SetFont("citrus_MainText")
			
			-- Width.
			local Width = surface.GetTextSize("Say")
			
			-- Check Say Team.
			if (PLUGIN.SayTeam) then
				Width = surface.GetTextSize("Say Team")
				
				-- Simple Text.
				draw.SimpleText("Say Team", "citrus_MainText", 5, 13, Color(0, 0, 0, 255), 0, 1)
				draw.SimpleText("Say Team", "citrus_MainText", 4, 12, TitleColor, 0, 1)
				
				-- Text Entry.
				PLUGIN.Derma.TextEntry:SetPos(74, 4)
				PLUGIN.Derma.TextEntry:SetSize(356, 16)
			else
				draw.SimpleText("Say", "citrus_MainText", 5, 13, Color(0, 0, 0, 255), 0, 1)
				draw.SimpleText("Say", "citrus_MainText", 4, 12, TitleColor, 0, 1)
				
				-- Text Entry.
				PLUGIN.Derma.TextEntry:SetPos(34, 4)
				PLUGIN.Derma.TextEntry:SetSize(396, 16)
			end
			
			-- Simple Text.
			draw.SimpleText(":", "citrus_MainText", 5 + Width, 13, Color(0, 0, 0, 255), 0, 1)
			draw.SimpleText(":", "citrus_MainText", 4 + Width, 12, TextColor, 0, 1)
		end
		
		-- Think.
		function PLUGIN.Derma.Panel:Think()
			local X, Y = PLUGIN.GetPosition()
			
			-- Set Pos.
			PLUGIN.Derma.Panel:SetPos(X, Y + 6)
			
			-- Check Is Visible.
			if (self:IsVisible() and input.IsKeyDown(KEY_ESCAPE)) then PLUGIN.Derma.Panel.Hide() end 
		end
		
		-- Scroll.
		PLUGIN.Derma.Scroll = vgui.Create("Panel")
		PLUGIN.Derma.Scroll:SetPos(0, 0)
		PLUGIN.Derma.Scroll:SetSize(0, 0)
		
		-- On Mouse Wheeled.
		function PLUGIN.Derma.Scroll:OnMouseWheeled(Delta)
			local IsVisible = PLUGIN.Derma.Panel:IsVisible()
			
			-- Check Is Visible.
			if (IsVisible) then
				if (Delta > 0) then
					if (PLUGIN.History.Messages[PLUGIN.History.Position - 5]) then
						PLUGIN.History.Position = PLUGIN.History.Position - 1
					end
				else
					if (PLUGIN.History.Messages[PLUGIN.History.Position + 1]) then
						PLUGIN.History.Position = PLUGIN.History.Position + 1
					end
				end
			end
		end
	end
end

-- Create Derma Filters.
function PLUGIN.CreateDermaFilters()
	if (!PLUGIN.Derma.Filters) then
		PLUGIN.Derma.Filters = vgui.Create("EditablePanel")
		PLUGIN.Derma.Filters:SetSize(120, 88)
		
		-- Paint.
		function PLUGIN.Derma.Filters:Paint()
			local BackgroundColor = citrus.Themes.GetColor("Background")
			local CornerSize = citrus.Themes.GetSize("Corner")
			local TitleColor = citrus.Themes.GetColor("Title")
			local TextColor = citrus.Themes.GetColor("Text")
			
			-- Rounded Box.
			draw.RoundedBox(CornerSize, 0, 0, self:GetWide(), self:GetTall(), BackgroundColor)
		end
		
		-- Think.
		function PLUGIN.Derma.Filters:Think()
			local X = PLUGIN.Derma.Panel.x + PLUGIN.Derma.Panel:GetWide() + 4
			local Y = PLUGIN.Derma.Panel.y + PLUGIN.Derma.Panel:GetTall() - self:GetTall()
			
			-- Set Pos.
			self:SetPos(X, Y)
		end
		
		-- Create Derma Check Box.
		PLUGIN.CreateDermaCheckBox(nil, "cl_messagearea_joinleave", 8, 8, "Filter join/leave messages.", "Filter Join/Leave", PLUGIN.Derma.Filters)
		PLUGIN.CreateDermaCheckBox(nil, "cl_messagearea_chat", 8, 28, "Filter chat messages.", "Filter Chat", PLUGIN.Derma.Filters)
		PLUGIN.CreateDermaCheckBox(nil, "cl_messagearea_none", 8, 48, "Filter server messages.", "Filter Server", PLUGIN.Derma.Filters)
		PLUGIN.CreateDermaCheckBox(nil, "cl_messagearea_team", 8, 68, "Filter team messages.", "Filter Team", PLUGIN.Derma.Filters)
	end
end

-- Player Bind Press.
function PLUGIN.PlayerBindPress(Player, Bind, Press)
	if (Bind == "toggleconsole") then
		PLUGIN.Derma.Panel.Hide()
	elseif (Bind == "messagemode" and Press) then
		PLUGIN.Derma.Panel.Show()
		PLUGIN.SayTeam = false
		
		-- Return True.
		return true
	elseif (Bind == "messagemode2" and Press) then
		PLUGIN.Derma.Panel.Show()
		PLUGIN.SayTeam = true
		
		-- Return True.
		return true
	end
end

-- Hook Add.
PLUGIN:HookAdd("PlayerBindPress", PLUGIN.PlayerBindPress)

-- Message Add.
function PLUGIN.MessageAdd(Player, Title, Name, Text, Parse)
	local Message = {}
	
	-- Check Title.
	if (Title) then
		Title = citrus.Utilities.GetTable(Title)
		
		-- Title.
		Message.Title = {}
		Message.Title.Text = Title[1]
		Message.Title.Color = Title[2] or citrus.Themes.GetColor("Text")
	end
	
	-- Check Name.
	if (Name) then
		Name = citrus.Utilities.GetTable(Name)
		
		-- Name.
		Message.Name = {}
		Message.Name.Text = Name[1]
		Message.Name.Color = Name[2] or citrus.Themes.GetColor("Text")
	end
	
	-- Text.
	Text = citrus.Utilities.GetTable(Text)
	
	-- Time Start.
	Message.TimeStart = CurTime()
	Message.TimeFade = Message.TimeStart + 10
	Message.TimeFinish = Message.TimeFade + 1
	Message.Spacing = 0
	Message.Player = Player
	Message.Blocks = {}
	Message.Color = Text[2] or citrus.Themes.GetColor("Text")
	Message.Alpha = 255
	Message.Lines = 1
	Message.Text = PLUGIN.ExplodeTags(Text[1], " ", "[", "]")
	
	-- Extract Types.
	PLUGIN.ExtractTypes(Message, Parse)
	PLUGIN.PrintConsole(Message)
	
	-- Check Position.
	if (PLUGIN.History.Position == #PLUGIN.History.Messages) then
		PLUGIN.History.Position = #PLUGIN.History.Messages + 1
	end
	
	-- Check Messages.
	if (#PLUGIN.Messages == 5) then table.remove(PLUGIN.Messages, 5) end
	
	-- Copy.
	local Copy = table.Copy(Message)
	
	-- Insert.
	table.insert(PLUGIN.Messages, 1, Message)
	table.insert(PLUGIN.History.Messages, Copy)
	
	-- Play Sound.
	surface.PlaySound("common/talk.wav")
end

-- Print Console.
function PLUGIN.PrintConsole(Message)
	local String = ""
	
	-- Check Title.
	if (Message.Title) then String = String..Message.Title.Text.." " end
	if (Message.Name) then String = String..Message.Name.Text..": " end
	
	-- For Loop.
	for K, V in pairs(Message.Blocks) do
		local Space = " "
		
		-- Check K.
		if (K == #Message.Blocks) then Space = "" end
		
		-- Check Break.
		if (V.Break) then Space = "" end
		
		-- Check Type.
		if (V.Type == "Text") then
			String = String..V.Text..Space
		elseif (V.Type == "Emoticon") then
			String = String..V.Name..Space
		end
		
		-- Check Break.
		if (V.Break) then
			print(String)
			
			-- String.
			String = ""
		end
	end
	
	-- Check String.
	if (String != "") then print(String) end
end

-- Extract Types.
function PLUGIN.ExtractTypes(Message, Parse)
	local Length = 0
	
	-- Check Title.
	if (Message.Title) then Length = Length + string.len(Message.Title.Text) end
	if (Message.Name) then Length = Length + string.len(Message.Name.Text..":") end
	
	-- Set Font.
	surface.SetFont("citrus_MainText")
	
	-- For Loop.
	for K, V in pairs(Message.Text) do
		local Extracted = false
		
		-- Check Parse.
		if (Parse) then
			if (!Extracted) then
				if (string.sub(V, 1, 1) == "[" and string.sub(V, -1) == "]") then
					local Name = string.Explode("=", string.sub(V, 2, -2))[1]
					
					-- Check Sub.
					if (string.sub(Name, 1, 1) == "/") then Name = string.sub(Name, 2) end
					
					-- Check Name.
					if (PLUGIN.Tags[Name]) then
						local Tag = PLUGIN.Tags[Name]
						
						-- Check Arguments.
						if (Tag.Arguments) then
							string.gsub(V, "%["..Tag.Name.."=(.+)%]", function(Arguments)
								Arguments = string.Explode(Tag.Seperator, Arguments)
								
								-- For Loop.
								for K2, V2 in pairs(Arguments) do
									Arguments[K2] = citrus.Utilities.GetStringValue(string.Trim(V2))
									
									-- Check K2.
									if (Tag.Arguments[K2] == "string") then
										Arguments[K2] = tostring(Arguments[K2])
									end
									
									-- Check type.
									if (type(Arguments[K2]) != Tag.Arguments[K2]) then Arguments[K2] = nil end
								end
								
								-- Check Arguments.
								if (#Arguments == #Tag.Arguments) then
									table.insert(Message.Blocks, {Type = "Tag", Name = Tag.Name, Arguments = Arguments, Start = true})
									
									-- Extracted.
									Extracted = true
								end
							end)
						else
							string.gsub(V, "%["..Tag.Name.."%]", function()
								table.insert(Message.Blocks, {Type = "Tag", Name = Tag.Name, Arguments = {}, Start = true})
								
								-- Extracted.
								Extracted = true
							end)
						end
						
						-- Check Extracted.
						if (!Extracted) then
							string.gsub(V, "%[/"..Tag.Name.."%]", function()
								table.insert(Message.Blocks, {Type = "Tag", Name = Tag.Name, Finish = true})
								
								-- Extracted.
								Extracted = true
							end)
						end
					end
				end
			end
		end
		
		-- Check Extracted.
		if (!Extracted) then
			if (PLUGIN.Emoticons[V] and Parse) then
				local Characters = PLUGIN.Emoticons[V].Characters + 1
				
				-- Width.
				local Width, Height = surface.GetTextSize("W")
				
				-- Check Height.
				if (PLUGIN.Emoticons[V].Height > Height) then
					Height = (PLUGIN.Emoticons[V].Height - Height)
					
					-- Check Height.
					if (Height > Message.Spacing) then Message.Spacing = (Height / 2) end
				end
				
				-- Check Length.
				if (Length + Characters >= 75) then
					Message.Lines = Message.Lines + 1
					
					-- Length.
					Length = 0
					
					-- Insert.
					table.insert(Message.Blocks, {Type = "Emoticon", Name = V, Break = true})
				else
					Length = Length + Characters
					
					-- Insert.
					table.insert(Message.Blocks, {Type = "Emoticon", Name = V})
				end
			else
				local Characters = string.len(V) + 1
				
				-- Check Length.
				if (Length + Characters >= 75) then
					local Break = math.Clamp(Characters - ((Length + Characters) - 75), 0, Characters)
					
					-- Dash.
					local Dash = "-"
					local One = string.sub(V, 1, Break)
					local Two = string.sub(V, Break + 1)
					
					-- Check Find.
					if (string.find(string.sub(One, -1), "%p")) then Dash = "" end
					if (string.find(string.sub(Two, 1, 1), "%p")) then
						Dash, One, Two = "", One..string.sub(Two, 1, 1), string.sub(Two, 2)
					end
					
					-- Check One.
					if (One == "" or Two == "") then Dash = "" end
					
					-- Check Insert.
					table.insert(Message.Blocks, {Type = "Text", Text = One..Dash, Break = true})
					
					-- Check Two.
					if (Two != "") then table.insert(Message.Blocks, {Type = "Text", Text = Two}) end
					
					-- Lines.
					Message.Lines = Message.Lines + 1
					
					-- Length.
					Length = string.len(Two)
					Extracted = true
				end
				
				-- Check Extracted.
				if (!Extracted) then
					Length = Length + Characters
					
					-- Insert.
					table.insert(Message.Blocks, {Type = "Text", Text = V})
				end
			end
		end
	end
	
	-- For Loop.
	for K, V in pairs(Message.Blocks) do
		if (V.Break) then
			if (!Message.Blocks[K + 1] or (Message.Blocks[K + 1] and Message.Blocks[K + 1].Type == "Tag")) then
				Message.Blocks[K].Break = false
				
				-- Lines.
				Message.Lines = Message.Lines - 1
			end
		end
	end
end

-- Exploded Tags.
function PLUGIN.ExplodeTags(String, Seperator, Open, Close)
	local Results = {}
	local Block = ""
	local Tag = false
	
	-- For Loop.
	for I = 1, string.len(String) do
		local Character = string.sub(String, I, I)
		
		-- Check Tag.
		if (!Tag) then
			if (Character == Open) then
				Block = Block..Character
				
				-- Tag.
				Tag = true
			elseif (Character == Seperator) then
				Results[#Results + 1] = Block
				
				-- Block.
				Block = ""
			else
				Block = Block..Character
			end
		else
			Block = Block..Character
			
			-- Check Character.
			if (Character == Close) then Tag = false end
		end
	end
	
	-- Check Block.
	if (Block != "") then Results[#Results + 1] = Block end
	
	-- Return Results.
	return Results
end

-- On Think.
function PLUGIN.OnThink()
	local Time = CurTime()
	
	-- For Loop.
	for K, V in pairs(PLUGIN.Messages) do
		if (Time >= V.TimeFade) then
			local FadeTime = V.TimeFinish - V.TimeFade
			local TimeLeft = V.TimeFinish - Time
			local Alpha = math.Clamp((255 / FadeTime) * TimeLeft, 0, 255)
			
			-- Check Alpha.
			if (Alpha == 0) then
				table.remove(PLUGIN.Messages, K)
			else
				V.Alpha = Alpha
			end
		end
	end
end

-- On Draw.
function PLUGIN.OnDraw()
	local X, Y = PLUGIN.GetPosition()
	
	-- Set Font.
	surface.SetFont("citrus_MainText")
	
	-- Space.
	local Space = surface.GetTextSize(" ")
	local Box = {Width = 0, Height = 0}
	
	-- Table.
	local Table = PLUGIN.Messages
	local IsVisible = PLUGIN.Derma.Panel:IsVisible()
	
	-- Check Is Visible.
	if (IsVisible) then
		Table = {}
		
		-- For Loop.
		for I = 0, 4 do
			table.insert(Table, PLUGIN.History.Messages[PLUGIN.History.Position - I])
		end
	else
		if (#PLUGIN.History.Messages > 100) then
			local Amount = #PLUGIN.History.Messages - 100
			
			-- For Loop.
			for I = 1, Amount do table.remove(PLUGIN.History.Messages, 1) end
		end
	end
	
	-- -- For Loop.
	-- for K, V in pairs(PLUGIN.Derma.Avatars) do
		-- if (GetConVarNumber("cl_messagearea_avatars") == 0) then
			-- V:SetVisible(false)
		-- else
			-- if (Table[K] and Table[K].Player) then
				-- V:SetPlayer(Table[K].Player)
				-- V:SetVisible(true)
			-- else
				-- V:SetVisible(false)
			-- end
		-- end
	-- end
	
	-- For Loop.
	for K, V in pairs(Table) do
		if (Table[K - 1]) then Y = Y - Table[K - 1].Spacing end
		
		-- Y.
		Y = Y - ((PLUGIN.GetSpacing() + V.Spacing) * V.Lines)
		
		-- Message X.
		local MessageX = math.floor(X)
		local MessageY = math.floor(Y)
		
		-- -- Check K.
		-- if (PLUGIN.Derma.Avatars[K]) then
			-- local IsVisible = PLUGIN.Derma.Avatars[K]:IsVisible()
			
			-- -- Check Is Visible.
			-- if (IsVisible) then
				-- if (K > 1) then MessageY = MessageY - 4 end
				
				-- -- Set Pos.
				-- PLUGIN.Derma.Avatars[K]:SetPos(MessageX, MessageY - 2)
				-- PLUGIN.Derma.Avatars[K]:SetAlpha(V.Alpha)
				
				-- -- Message X.
				-- MessageX = MessageX + 24
				
				-- -- Check K.
				-- if (K > 1) then Y = Y - 8 else Y = Y - 4 end
			-- end
		-- end
		
		-- Check Title.
		if (V.Title) then
			local Width = surface.GetTextSize(V.Title.Text)
			
			-- Title Color.
			local TitleColor = Color(V.Title.Color.r, V.Title.Color.g, V.Title.Color.b, V.Alpha)
			
			-- Draw.
			draw.SimpleText(V.Title.Text, "citrus_MainText", MessageX + 1, MessageY + 1, Color(0, 0, 0, V.Alpha), 0, 0)
			draw.SimpleText(V.Title.Text, "citrus_MainText", MessageX, MessageY, TitleColor, 0, 0)
			
			-- Message X.
			MessageX = MessageX + Width + Space
		end
		
		-- Check Name.
		if (V.Name) then
			local Width = surface.GetTextSize(V.Name.Text)
			
			-- Name Color.
			local NameColor = Color(V.Name.Color.r, V.Name.Color.g, V.Name.Color.b, V.Alpha)
			
			-- Draw.
			draw.SimpleText(V.Name.Text, "citrus_MainText", MessageX + 1, MessageY + 1, Color(0, 0, 0, V.Alpha), 0, 0)
			draw.SimpleText(V.Name.Text, "citrus_MainText", MessageX, MessageY, NameColor, 0, 0)
			
			-- Message X.
			MessageX = MessageX + Width
			
			-- Width.
			local Width = surface.GetTextSize(":")
			
			-- Text.
			draw.SimpleText(":", "citrus_MainText", MessageX + 1, MessageY + 1, Color(0, 0, 0, V.Alpha), 0, 0)
			draw.SimpleText(":", "citrus_MainText", MessageX, MessageY, Color(255, 255, 255, V.Alpha), 0, 0)
			
			-- Message X.
			MessageX = MessageX + Width + Space
		end
		
		-- Text Color.
		local TextColor = Color(V.Color.r, V.Color.g, V.Color.b, V.Alpha)
		local Tag = nil
		
		-- For Loop.
		for K2, V2 in pairs(V.Blocks) do
			if (V2.Type == "Tag") then
				if (V2.Finish and Tag and Tag.Name == V2.Name) then
					Tag = nil
				elseif (V2.Start and !Tag) then
					Tag = {Name = V2.Name, Arguments = V2.Arguments}
				end
			elseif (V2.Type == "Emoticon") then
				local Emoticon = PLUGIN.Emoticons[V2.Name]
				local EmoticonColor = Color(255, 255, 255, V.Alpha)
				
				-- Get Texture Size.
				local Width, Height = surface.GetTextureSize(Emoticon.TextureID)
				local _, TextHeight = surface.GetTextSize("W")
				
				-- Texture.
				citrus.Draw.Texture(Emoticon.TextureID, MessageX, (MessageY - (Emoticon.Height / 2) + (TextHeight / 2)), Width, Height, EmoticonColor)
				
				-- Message X.
				MessageX = MessageX + Emoticon.Width + Space
			elseif (V2.Type == "Text") then
				if (Tag) then
					local Width = PLUGIN.Tags[Tag.Name].Callback(V2.Text, MessageX, MessageY, TextColor, V.Alpha, Tag.Arguments)
					
					-- Message X.
					MessageX = MessageX + Width + Space
				else
					local Width = surface.GetTextSize(V2.Text)
					
					-- Draw.
					draw.SimpleText(V2.Text, "citrus_MainText", MessageX + 1, MessageY + 1, Color(0, 0, 0, V.Alpha), 0, 0)
					draw.SimpleText(V2.Text, "citrus_MainText", MessageX, MessageY, TextColor, 0, 0)
					
					-- Message X.
					MessageX = MessageX + Width + Space
				end
			end
			
			-- Check Message X.
			if (MessageX - 8 > Box.Width) then Box.Width = MessageX - 8 end
			if (PLUGIN.GetY() - Y > Box.Height) then Box.Height = PLUGIN.GetY() - Y end
			
			-- Check Break.
			if (V2.Break) then
				MessageY = math.floor(MessageY + PLUGIN.GetSpacing() + V.Spacing)
				MessageX = math.floor(X)
			end
		end
	end
	
	-- Set Pos.
	PLUGIN.Derma.Scroll:SetPos(X, Y)
	PLUGIN.Derma.Scroll:SetSize(Box.Width, Box.Height)
end

-- Start Chat.
function PLUGIN.StartChat(Team) return true end

-- Hook Add.
PLUGIN:HookAdd("StartChat", PLUGIN.StartChat)

-- Chat Text.
function PLUGIN.ChatText(Index, Name, Text, Filter)
	if (ConVarExists("cl_messagearea_"..Filter) and GetConVarNumber("cl_messagearea_"..Filter) == 0) then
		return true
	end
	
	-- Player.
	local Player = player.GetByID(Index)
	
	-- Check Player.
	if (ValidEntity(Player)) then
		local Team = Player:Team()
		local TeamColor = team.GetColor(Team)
		
		-- Check Filter.
		if (Filter == "chat") then
			local TitleText = citrus.PlayerInformation.Get(Player, "Message Area", "Title")
			local TitleColor = citrus.PlayerInformation.Get(Player, "Message Area", "Color")
			
			-- Check Title Text.
			if (TitleText and TitleColor) then
				TitleColor = citrus.Utilities.GetColor(TitleColor)
				
				-- Message Add.
				PLUGIN.MessageAdd(Player, {TitleText, TitleColor}, {Name, TeamColor}, Text, true)
			else
				PLUGIN.MessageAdd(Player, nil, {Name, TeamColor}, Text, true)
			end
		elseif (Filter == "team") then
			PLUGIN.MessageAdd(Player, "(Team)", {Name, TeamColor}, Text, true)
		end
	else
		if (Name == "Console" and Filter == "chat") then
			PLUGIN.MessageAdd(nil, nil, {"Console", Color(150, 150, 150, 255)}, Text, true)
		elseif (Filter == "joinleave") then
			Text = Text.."."
			
			-- Check Find.
			if (string.find(Text, "%(") and string.find(Text, "%)")) then
				Text = string.gsub(Text, "Kicked by Console :", "Kicked by Console:", 1)
				Text = string.gsub(Text, "%.%)", ")")
				
				-- Message Add.
				PLUGIN.MessageAdd(nil, nil, nil, {Text, Color(255, 75, 75, 255)})
			else
				PLUGIN.MessageAdd(nil, nil, nil, {Text, Color(175, 255, 125, 255)})
			end
		else
			PLUGIN.MessageAdd(nil, nil, nil, {Text, Color(255, 255, 150, 255)})
		end
	end
	
	-- Return True.
	return true
end

-- Hook Add.
PLUGIN:HookAdd("ChatText", PLUGIN.ChatText)
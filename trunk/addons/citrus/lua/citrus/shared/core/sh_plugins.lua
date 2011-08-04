--[[
Name: "sh_plugins.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Plugin = {}
citrus.Plugins = {}
citrus.Plugins.Stored = {}
citrus.Plugins.Loaded = {}

-- PLUGIN_FILEPATH.
local PLUGIN_FILEPATH = ""

-- New.
function citrus.Plugin:New(Name)
	local Table = {}
	
	-- Set Meta Table.
	setmetatable(Table, self)
	
	-- Index.
	self.__index = self
	
	-- Name.
	Table.Name = Name
	Table.Hooks = {}
	Table.Timers = {}
	Table.Commands = {}
	Table.FilePath = PLUGIN_FILEPATH
	
	-- Settings.
	Table.Settings = {}
	Table.Settings.GameSupport = true
	Table.Settings.Description = "N/A"
	Table.Settings.Unloadable = true
	Table.Settings.Required = false
	Table.Settings.Gamemode = false
	Table.Settings.Author = "N/A"
	Table.Settings.Game = false
	Table.Settings.Base = false
	
	-- Name.
	citrus.Plugins.Stored[Name] = Table
	
	-- Return Table.
	return citrus.Plugins.Stored[Name]
end

-- Command Add.
function citrus.Plugin:CommandAdd(Command)
	self.Commands[Command.Name] = Command
	
	-- Is Loaded.
	local IsLoaded = self:IsLoaded()
	
	-- Check Is Loaded.
	if (!IsLoaded) then Command:SetUsable(false) end
end

-- Command Remove.
function citrus.Plugin:CommandRemove(Command)
	self.Commands[Command.Name] = nil
	
	-- Set Usable.
	Command:SetUsable(true)
end

-- Add.
function citrus.Plugin:HookAdd(Hook, Callback)
	local Table = {
		Name = util.CRC("['"..Hook.."']['"..tostring(Callback).."']"),
		Hook = Hook,
		Callback = Callback
	}
	
	-- Name.
	self.Hooks[Table.Name] = Table
	
	-- Is Loaded.
	local IsLoaded = self:IsLoaded()
	
	-- Check Is Loaded.
	if (IsLoaded) then hook.Add(Table.Hook, Table.Name, Table.Callback) end
	
	-- Return Name.
	return Table.Name
end

-- Hook Remove.
function citrus.Plugin:HookRemove(Name)
	for K, V in pairs(self.Hooks) do
		if (V.Name == Name or V.Name == util.CRC("['"..Name.."']['"..tostring(V.Callback).."']")) then
			hook.Remove(V.Hook, V.Name)
			
			-- K.
			self.Hooks[K] = nil
		end
	end
end

-- Timer Create.
function citrus.Plugin:TimerCreate(Name, Delay, Repeats, Callback, ...)
	local Table = {
		Delay = Delay,
		Repeats = Repeats,
		Callback = Callback,
		Arguments = arg
	}
	
	-- Check Name.
	if (Name) then
		Table.Name = util.CRC("['"..Name.."']['"..tostring(Callback).."']")
	else
		Table.Name = util.CRC("['"..tostring(Table).."']['"..tostring(Callback).."']")
	end
	
	-- Name.
	self.Timers[Table.Name] = Table
	
	-- Create.
	timer.Create(Table.Name, Table.Delay, Table.Repeats, Table.Callback, unpack(Table.Arguments))
	
	-- Is Loaded.
	local IsLoaded = self:IsLoaded()
	
	-- Check Is Loaded.
	if (!IsLoaded) then timer.Pause(Table.Name) end
	
	-- Return Name.
	return Table.Name
end

-- Timer Remove.
function citrus.Plugin:TimerRemove(Name)
	for K, V in pairs(self.Timers) do
		if (V.Name == Name or V.Name == util.CRC("['"..Name.."']['"..tostring(V.Callback).."']")) then
			timer.Remove(V.Name)
			
			-- K.
			self.Timers[K] = nil
		end
	end
end

-- Is Loaded.
function citrus.Plugin:IsLoaded()
	return (citrus.Plugins.Loaded[self.Name] != nil)
end

-- Load.
function citrus.Plugin:Load()
	local IsLoaded = self:IsLoaded()
	
	-- Check Is Loaded.
	if (IsLoaded) then return false, self.Name.." is already loaded!" end
	
	-- Check SERVER.
	if (SERVER) then
		if (self.Settings.Base) then
			local Plugin = citrus.Plugins.Get(self.Settings.Base)
			
			-- Check Plugin.
			if (Plugin) then
				local IsLoaded = Plugin:IsLoaded()
				
				-- Check Is Loaded.
				if (!IsLoaded) then
					local Success, Error = Plugin:Load()
					
					-- Check Success.
					if (!Success) then
						return false, "Unable to load base plugin '"..V.."'!"
					end
				end
			else
				return false, "Unable to locate base plugin '"..V.."'!"
			end
			
			-- Table.
			local Table = table.Copy(Plugin)
			
			-- Merge.
			table.Merge(Table, self)
			table.Merge(self, Table)
			
			-- Base.
			self.Base = Plugin
		end
		
		-- Check Required.
		if (self.Settings.Required) then
			for K, V in pairs(self.Settings.Required) do
				local Plugin = citrus.Plugins.Get(V)
				
				-- Check Plugin.
				if (Plugin) then
					local IsLoaded = Plugin:IsLoaded()
					
					-- Check Is Loaded.
					if (!IsLoaded) then
						local Success, Error = Plugin:Load()
						
						-- Check Success.
						if (!Success) then
							return false, "Unable to load required plugin '"..V.."'!"
						end
					end
				else
					return false, "Unable to locate required plugin '"..V.."'!"
				end
			end
		end
		
		-- Check Gamemode.
		if (self.Settings.Gamemode) then
			if (self.Settings.Gamemode[2]) then
				if (!citrus.Utilities.GamemodeDerivesFrom(self.Settings.Gamemode[1])) then
					return false, self.Name.." requires '"..self.Settings.Gamemode[1].."' derived gamemode!"
				end
			else
				if (string.lower(GAMEMODE.Name) != string.lower(self.Settings.Gamemode[1])) then
					return false, self.Name.." requires gamemode '"..self.Settings.Gamemode[1].."'!"
				end
			end
		end
		
		-- Check Game.
		if (self.Settings.Game) then	
			if (citrus.Plugins.Game) then
				local Plugin = citrus.Plugins.Game.Plugin
				local Unloaded = citrus.Plugins.Game.Unloaded
				
				-- Game.
				citrus.Plugins.Game = false
				
				-- Unload.
				Plugin:Unload()
				
				-- Game.
				citrus.Plugins.Game = {Plugin = self, Unloaded = Unloaded}
			else
				citrus.Plugins.Game = {Plugin = self, Unloaded = {}}
			end
			
			-- For Loop.
			for K, V in pairs(citrus.Plugins.Loaded) do
				if (!V.Settings.GameSupport) then
					citrus.Plugins.Game.Unloaded[#citrus.Plugins.Game.Unloaded + 1] = V
					
					-- Unload.
					V:Unload(true)
				end
			end
		end
	end
	
	-- For Loop.
	for K, V in pairs(self.Hooks) do hook.Add(V.Hook, V.Name, V.Callback) end
	for K, V in pairs(self.Timers) do timer.UnPause(V.Name) end
	
	-- Loaded.
	citrus.Plugins.Loaded[self.Name] = self
	
	-- On Load.
	self:OnLoad()
	
	-- Check SERVER.
	if (SERVER) then
		local Players = player.GetAll()
		
		-- For Loop.
		for K, V in pairs(Players) do
			local PluginsInitialized = citrus.PlayerCookies.Get(V, "Plugins Initialized")
			
			-- Check Name.
			if (!PluginsInitialized[self.Name]) then
				if (self.OnPlayerSetVariables) then self.OnPlayerSetVariables(V) end
				if (self.OnPlayerInitialSpawn) then self.OnPlayerInitialSpawn(V) end
				
				-- Name.
				PluginsInitialized[self.Name] = true
			end
			
			-- On Player Load.
			self:OnPlayerLoad(V)
		end
		
		-- For Loop.
		for K, V in pairs(self.Commands) do
			V:SetUsable(true)
			
			-- Check Quick Menu.
			if (V.Settings.QuickMenu) then
				citrus.QuickMenu.Hide(V.Settings.QuickMenu, false)
			end
		end
	end
	
	-- Check SERVER.
	if (SERVER) then
		citrus.ServerVariables.Get("Unloaded Plugins")[self.Name] = nil
		
		-- Client Side Load.
		self:ClientSideLoad()
	end
	
	-- Call.
	citrus.Hooks.Call("OnPluginLoaded", self)
	
	-- Return True.
	return true
end

-- Unload.
function citrus.Plugin:Unload(Temporary)
	local IsLoaded = self:IsLoaded()
	
	-- Check Is Loaded.
	if (!IsLoaded) then return false, self.Name.." is not loaded!" end
	
	-- Check SERVER.
	if (SERVER) then
		if (!self.Settings.Unloadable) then return false, self.Name.." is not unloadable!" end
		
		-- For Loop.
		for K, V in pairs(citrus.Plugins.Loaded) do
			if (V.Settings.Base) then
				if (V.Settings.Base == self.Name) then
					local Success, Error = V:Unload()
					
					-- Check Success.
					if (!Success) then
						return false, self.Name.." is the base of unloadable plugin '"..V.Name.."'!"
					end
				end
			end
			
			-- Check Required.
			if (V.Settings.Required) then
				if (table.HasValue(V.Settings.Required, self.Name)) then
					local Success, Error = V:Unload()
					
					-- Check Success.
					if (!Success) then
						return false, self.Name.." is required by unloadble plugin '"..V.Name.."'!"
					end
				end
			end
		end
	end
	
	-- For Loop.
	for K, V in pairs(self.Hooks) do hook.Remove(V.Hook, V.Name) end
	for K, V in pairs(self.Timers) do timer.Pause(V.Name) end
	
	-- Loaded.
	citrus.Plugins.Loaded[self.Name] = nil
	
	-- Check SERVER.
	if (SERVER) then
		local Players = player.GetAll()
		
		-- For Loop.
		for K, V in pairs(Players) do self:OnPlayerUnload(V) end
		for K, V in pairs(self.Commands) do
			V:SetUsable(false)
			
			-- Check Quick Menu.
			if (V.Settings.QuickMenu) then
				citrus.QuickMenu.Hide(V.Settings.QuickMenu, true)
			end
		end
	end
	
	-- On Unload.
	self:OnUnload()
	
	-- Check Server.
	if (SERVER) then
		if (citrus.Plugins.Game and citrus.Plugins.Game.Plugin == self) then
			for K, V in pairs(citrus.Plugins.Game.Unloaded) do V:Load() end
			
			-- Gamemode.
			citrus.Plugins.Game = false
		end
		
		-- Check Temporary.
		if (!Temporary) then citrus.ServerVariables.Get("Unloaded Plugins")[self.Name] = true end
		
		-- Client Side Unload.
		self:ClientSideUnload()
	end
	
	-- Call.
	citrus.Hooks.Call("OnPluginUnloaded", self)
	
	-- Return True.
	return true
end

-- On Load.
function citrus.Plugin:OnLoad() end

-- On Unload.
function citrus.Plugin:OnUnload() end

-- On Player Load.
function citrus.Plugin:OnPlayerLoad(Player) end

-- On Player Unload.
function citrus.Plugin:OnPlayerUnload(Player) end

-- Get.
function citrus.Plugins.Get(Plugin)
	for K, V in pairs(citrus.Plugins.Stored) do
		if (string.lower(V.Name) == string.lower(Plugin)) then return V end
	end
	
	-- Return False.
	return false, "Unable to locate '"..Plugin.."'!"
end

-- Exists.
function citrus.Plugins.Exists(Index)
	if (citrus.Plugins.Stored[Index]) then return true end
	
	-- Return False.
	return false
end

-- Include All.
function citrus.Plugins.IncludeAll()
	local Directories = file.FindInLua("citrus/shared/plugins/*")

	-- For Loop.
	for K, V in pairs(Directories) do
		if (V != "." and V != "..") then
			PLUGIN_FILEPATH = "citrus/shared/plugins/"..V
			
			-- Check CLIENT.
			if (CLIENT) then
				if (citrus.Utilities.IsFileDownloaded("citrus/shared/plugins/"..V.."/cl_plugin.lua")) then
					include("citrus/shared/plugins/"..V.."/cl_plugin.lua")
				end
			else
				if (file.Exists("../lua/citrus/shared/plugins/"..V.."/sv_plugin.lua")) then
					include("citrus/shared/plugins/"..V.."/sv_plugin.lua")
				end
			end
		end
	end
end

-- On Hook Called.
function citrus.Plugins.OnHookCalled(Hook, ...)
	for K, V in pairs(citrus.Plugins.Loaded) do
		if (V[Hook]) then
			local Success, Error = pcall(V[Hook], unpack(arg))
			
			-- Check Success.
			if (!Success) then print(Error) end
		end
		
		-- Check On Hook Called.
		if (V["OnHookCalled"]) then
			local Success, Error = pcall(V["OnHookCalled"], Hook, unpack(arg))
			
			-- Check Success.
			if (!Success) then print(Error) end
		end
	end
end

-- Add.
citrus.Hooks.Add("OnHookCalled", citrus.Plugins.OnHookCalled)

-- Check CLIENT.
if (CLIENT) then
	usermessage.Hook("citrus.Plugins.Load", function(Message)
		local Plugin = Message:ReadString()
		local Boolean = Message:ReadBool()
		
		-- Plugin.
		Plugin = citrus.Plugins.Get(Plugin)
		
		-- Check Plugin.
		if (Plugin) then
			if (Boolean) then
				Plugin:Load()
			else
				Plugin:Unload()
			end
		end
	end)

	-- Hook.
	usermessage.Hook("citrus.Plugins.IncludeAll", function()
		citrus.Plugins.IncludeAll()
	end)
	
	-- Usermessage Hook.
	function citrus.Plugin:UsermessageHook(Name, Function)
		usermessage.Hook(util.CRC("citrus.Plugins['"..self.Name.."']['"..Name.."']"), Function)
	end
end

-- Check SERVER.
if (SERVER) then
	function citrus.Plugin:ClientSideUnload(Player)
		umsg.Start("citrus.Plugins.Load", Player)
			umsg.String(self.Name)
			umsg.Bool(false)
		umsg.End()
	end

	-- Client Load.
	function citrus.Plugin:ClientSideLoad(Player)
		umsg.Start("citrus.Plugins.Load", Player)
			umsg.String(self.Name)
			umsg.Bool(true)
		umsg.End()
	end
	
	-- Usermessage Call.
	function citrus.Plugin:UsermessageCall(Name, Player, Callback)
		umsg.Start(util.CRC("citrus.Plugins['"..self.Name.."']['"..Name.."']"), Player)
		
		-- Check Callback.
		if (Callback) then Callback() end
		
		-- End.
		umsg.End()
	end
	
	-- Load All.
	function citrus.Plugins.LoadAll()
		for K, V in pairs(citrus.Plugins.Stored) do
			if (!citrus.ServerVariables.Get("Unloaded Plugins")[K] and !V.Settings.Game) then
				V:Load()
			else
				for K2, V2 in pairs(V.Commands) do
					if (V2.Settings.QuickMenu) then
						citrus.QuickMenu.Hide(V2.Settings.QuickMenu, true)
					end
				end
			end
		end
		
		-- Call.
		citrus.Hooks.Call("OnPluginsLoaded")
	end
	
	-- On Player Set Variables.
	function citrus.Plugins.OnPlayerSetVariables(Player)
		citrus.PlayerCookies.New(Player, "Plugins Initialized", {})
		
		-- Plugins Initialized.
		local PluginsInitialized = citrus.PlayerCookies.Get(Player, "Plugins Initialized")
		
		-- For Loop.
		for K, V in pairs(citrus.Plugins.Loaded) do PluginsInitialized[V.Name] = true end
	end
	
	-- Add.
	citrus.Hooks.Add("OnPlayerSetVariables", citrus.Plugins.OnPlayerSetVariables)
	
	-- On Load Variables.
	function citrus.Plugins.OnLoadVariables()
		citrus.ServerVariables.New("Unloaded Plugins", {})
		
		-- Include All.
		citrus.Plugins.IncludeAll()
		citrus.Plugins.LoadAll()
	end
	
	-- Add.
	citrus.Hooks.Add("OnLoadVariables", citrus.Plugins.OnLoadVariables)
end
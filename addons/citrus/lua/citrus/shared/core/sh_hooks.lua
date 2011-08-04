--[[
Name: "sh_hooks.lua".
Product: "Citrus (Server Management)".
--]]

citrus.Hooks = {}
citrus.Hooks.Stored = {}
citrus.Hooks.Temporary = {}

-- Add.
function citrus.Hooks.Add(Hook, Function)
	local Index = #citrus.Hooks.Stored + 1
	
	-- Index.
	citrus.Hooks.Stored[Index] = {Hook, Function}
	
	-- Return Index.
	return Index
end

-- Remove.
function citrus.Hooks.Remove(Index) citrus.Hooks.Stored[Index] = nil end

-- Call.
function citrus.Hooks.Call(Hook, ...)
	for K, V in pairs(citrus.Hooks.Stored) do
		if (V[1] == Hook) then
			if (V[2]) then
				local Success, Error = pcall(V[2], unpack(arg))
				
				-- Check Success.
				if (!Success) then print("("..Hook..") "..Error) end
			else
				citrus.Hooks.Stored[K] = nil
			end
		end
	end
	
	-- Check Hook.
	if (Hook != "OnHookCalled") then citrus.Hooks.Call("OnHookCalled", Hook, unpack(arg)) end
end
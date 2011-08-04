--[[
Name: "sv_shop.lua".
Product: "Citrus (Server Management)".
--]]

local COMMAND = citrus.Command:New("spendpoints")

-- PLUGIN.
local PLUGIN = citrus.Plugins.Get("Points")

-- Set Chat Command.
COMMAND:SetChatCommand(true)

-- Command Add.
PLUGIN:CommandAdd(COMMAND)

-- Purchase.
function COMMAND.Purchase(Player, Purchase)
	local Menu = citrus.Menu:New()

	-- Set Player.
	Menu:SetPlayer(Player)
	Menu:SetTitle("Purchase ("..Purchase.Name..")")
	Menu:SetIcon("gui/silkicons/star")
	Menu:SetReference(COMMAND.Purchase, Purchase)
	
	-- Text Add.
	Menu:TextAdd("Cost: "..Purchase.Cost.." Point(s).")
	Menu:TextAdd("Description: "..Purchase.Description..".")
	
	-- Button Add.
	Menu:ButtonAdd("Purchase", function()
		local Points = citrus.PlayerVariables.Get(Player, "Points")
		
		-- Check Name.
		if (Points.Purchases[Purchase.Name]) then
			citrus.Player.Notify(Player, "Unable to purchase again!", 1)
		else
			if (!Purchase.PurchaseCondition or Purchase.PurchaseCondition(Player)) then
				if (PLUGIN.Has(Player, Purchase.Cost)) then
					PLUGIN.Take(Player, Purchase.Cost)
					
					-- Name.
					Points.Purchases[Purchase.Name] = true
					
					-- On Purchase.
					if (Purchase.OnPurchase) then Purchase.OnPurchase(Player) end
					
					-- Update.
					citrus.Menus.Update(nil, COMMAND.Callback)
					
					-- Notify.
					citrus.Player.Notify(Player, "You have purchased '"..Purchase.Name.."'.")
				else
					citrus.Player.Notify(Player, "Unable to afford purchase!", 1)
				end
			else
				citrus.Player.Notify(Player, "Unable to meet purchase condition!", 1)
			end
		end
	end, {Discontinue = true})
	
	-- Send.
	Menu:Send()
end

-- Callback.
function COMMAND.Callback(Player, Arguments)
	if (!PLUGIN.Configuration["Purchases"]) then
		citrus.Player.Notify(Player, "Purchases are disabled!", 1)
	else
		local Menu = citrus.Menu:New()
		
		-- Set Player.
		Menu:SetPlayer(Player)
		Menu:SetTitle("Spend Points")
		Menu:SetIcon("gui/silkicons/star")
		Menu:SetUpdate(COMMAND.Callback)
		Menu:SetReference(COMMAND.Callback)
		
		-- Success.
		local Success = false
		
		-- For Loop.
		for K, V in pairs(PLUGIN.Purchases) do
			if (!citrus.PlayerVariables.Get(Player, "Points").Purchases[V.Name]) then
				if (!V.PurchaseCondition or V.PurchaseCondition(Player)) then
					Menu:ButtonAdd(V.Name, function() COMMAND.Purchase(Player, V) end)
					
					-- Success.
					Success = true
				end
			end
		end
		
		-- Check Success.
		if (!Success) then
			Menu:TextAdd("Unable to locate purchases!")
		end
		
		-- Send.
		Menu:Send()
	end
end

-- Create.
COMMAND:Create()
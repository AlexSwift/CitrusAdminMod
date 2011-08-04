--[[
Name: "sv_core.lua".
Product: "Citrus (Server Management)"
--]]

function citrus.Think() citrus.Hooks.Call("OnThink") end

-- Add.
hook.Add("Think", "citrus.Think", citrus.Think)

-- Second.
function citrus.Second() citrus.Hooks.Call("OnSecond") end

-- Create.
timer.Create("citrus.Second", 1, 0, citrus.Second)

-- Minute.
function citrus.Minute() citrus.Hooks.Call("OnMinute") end

-- Create.
timer.Create("citrus.Minute", 60, 0, citrus.Minute)
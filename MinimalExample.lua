--[[
    SpectrumX UI Library - Minimal Example
    Quick start with basic features
--]]

local SpectrumX = loadstring(game:HttpGet("https://raw.githubusercontent.com/seuusuario/SpectrumXUI/main/Main.lua"))()

-- Create window
local Window = SpectrumX:CreateWindow({
    Title = "My Script",
    Icon = "S"
})

-- Create tab
local Main = Window:CreateTab({Name = "Main", Icon = "M"})

-- Add toggle
Window:CreateToggle(Main.Left, {
    Text = "Auto Farm",
    Callback = function(state)
        print("Auto Farm:", state)
    end
})

-- Add button
Window:CreateButton(Main.Right, {
    Text = "Teleport",
    Callback = function()
        print("Teleported!")
    end
})

-- Add slider
Window:CreateSlider(Main.Left, {
    Text = "Speed",
    Min = 1,
    Max = 100,
    Default = 50,
    Callback = function(v)
        print("Speed:", v)
    end
})

-- Add dropdown
Window:CreateDropdown(Main.Right, {
    Label = "Location",
    Options = {"Spawn", "Shop", "Boss"},
    Callback = function(selected)
        print("Selected:", selected)
    end
})

print("UI Loaded!")

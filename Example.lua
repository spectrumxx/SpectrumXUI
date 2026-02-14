--[[
    SpectrumX UI Library - Example Usage
    Demonstrates all components and features
--]]

-- Load the library
local SpectrumX = loadstring(game:HttpGet("https://raw.githubusercontent.com/seuusuario/SpectrumXUI/main/Main.lua"))()

-- Create Window
local Window = SpectrumX:CreateWindow({
    Title = "Spectrum X",
    Icon = "S", -- Letter instead of image
    Position = UDim2.new(0.5, -300, 0.5, -180),
    Size = UDim2.new(0, 600, 0, 360)
})

-- Create Tabs
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "M"
})

local SettingsTab = Window:CreateTab({
    Name = "Settings", 
    Icon = "⚙"
})

local TeleportTab = Window:CreateTab({
    Name = "Teleport",
    Icon = "T"
})

local MiscTab = Window:CreateTab({
    Name = "Misc",
    Icon = "✦"
})

-- ==================== MAIN TAB ====================

-- Section Title
Window:CreateSection(MainTab.Left, "🎮 Auto Features", SpectrumX.Theme.Accent)

-- Toggle
local AutoFarmToggle = Window:CreateToggle(MainTab.Left, {
    Text = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
        if state then
            SpectrumX:Notify({
                Text = "Auto Farm Enabled!",
                Type = "success",
                Duration = 2
            })
        end
    end
})

-- Another Toggle
local AutoCollectToggle = Window:CreateToggle(MainTab.Left, {
    Text = "Auto Collect",
    Default = true,
    Callback = function(state)
        print("Auto Collect:", state)
    end
})

-- Number Input
local SpeedInput = Window:CreateNumberInput(MainTab.Left, {
    Label = "Farm Speed",
    Default = 1.5,
    Min = 0.1,
    Max = 10,
    Callback = function(value)
        print("Speed set to:", value)
    end
})

-- Slider
local RangeSlider = Window:CreateSlider(MainTab.Left, {
    Text = "Collection Range",
    Min = 10,
    Max = 500,
    Default = 100,
    Callback = function(value)
        print("Range:", value)
    end
})

-- Right Side - Dropdowns
Window:CreateSection(MainTab.Right, "📍 Location Settings", SpectrumX.Theme.Warning)

-- Single Select Dropdown
local LocationDropdown = Window:CreateDropdown(MainTab.Right, {
    Label = "Select Location",
    Options = {"Forest", "Desert", "Ocean", "Mountains", "City"},
    Default = "Forest",
    Callback = function(selected)
        print("Selected location:", selected)
    end
})

-- Multi Select Dropdown
local ItemsDropdown = Window:CreateMultiDropdown(MainTab.Right, {
    Label = "Select Items",
    Options = {"Sword", "Shield", "Potion", "Armor", "Ring", "Amulet"},
    Default = {"Sword", "Potion"},
    Callback = function(selected)
        print("Selected items:", table.concat(selected, ", "))
    end
})

-- ==================== SETTINGS TAB ====================

Window:CreateSection(SettingsTab.Left, "⚙️ General Settings", SpectrumX.Theme.Info)

-- Checkbox
local ShowNamesCheckbox = Window:CreateCheckbox(SettingsTab.Left, {
    Text = "Show Player Names",
    Default = true,
    Callback = function(state)
        print("Show names:", state)
    end
})

-- Input
local UsernameInput = Window:CreateInput(SettingsTab.Left, {
    Label = "Target Username",
    Default = "",
    Placeholder = "Enter username...",
    Callback = function(text)
        print("Target:", text)
    end
})

-- More Checkboxes
Window:CreateCheckbox(SettingsTab.Left, {
    Text = "Anti-AFK",
    Default = false,
    Callback = function(state)
        print("Anti-AFK:", state)
    end
})

Window:CreateCheckbox(SettingsTab.Left, {
    Text = "Auto Rejoin",
    Default = false,
    Callback = function(state)
        print("Auto Rejoin:", state)
    end
})

-- Right Side
Window:CreateSection(SettingsTab.Right, "📊 Performance", SpectrumX.Theme.Success)

-- Sliders
Window:CreateSlider(SettingsTab.Right, {
    Text = "Render Distance",
    Min = 100,
    Max = 2000,
    Default = 500,
    Callback = function(value)
        print("Render distance:", value)
    end
})

Window:CreateSlider(SettingsTab.Right, {
    Text = "FPS Limit",
    Min = 30,
    Max = 240,
    Default = 60,
    Callback = function(value)
        print("FPS limit:", value)
    end
})

-- ==================== TELEPORT TAB ====================

Window:CreateSection(TeleportTab.Left, "🎯 Quick Teleport", SpectrumX.Theme.Warning)

-- Teleport Buttons
Window:CreateButton(TeleportTab.Left, {
    Text = "Teleport to Spawn",
    Style = "accent",
    Callback = function()
        print("Teleporting to spawn...")
        SpectrumX:Notify({
            Text = "Teleported to Spawn!",
            Type = "success"
        })
    end
})

Window:CreateButton(TeleportTab.Left, {
    Text = "Teleport to Shop",
    Style = "info",
    Callback = function()
        print("Teleporting to shop...")
    end
})

Window:CreateButton(TeleportTab.Left, {
    Text = "Random Location",
    Style = "warning",
    Callback = function()
        print("Random teleport...")
    end
})

-- Right Side - Coordinates
Window:CreateSection(TeleportTab.Right, "📍 Custom Coordinates", SpectrumX.Theme.Info)

local XInput = Window:CreateNumberInput(TeleportTab.Right, {
    Label = "X Position",
    Default = 0,
    Min = -10000,
    Max = 10000,
    Callback = function(value) end
})

local YInput = Window:CreateNumberInput(TeleportTab.Right, {
    Label = "Y Position",
    Default = 0,
    Min = -10000,
    Max = 10000,
    Callback = function(value) end
})

local ZInput = Window:CreateNumberInput(TeleportTab.Right, {
    Label = "Z Position",
    Default = 0,
    Min = -10000,
    Max = 10000,
    Callback = function(value) end
})

Window:CreateButton(TeleportTab.Right, {
    Text = "Teleport to Coordinates",
    Style = "accent",
    Callback = function()
        local x = XInput:GetValue()
        local y = YInput:GetValue()
        local z = ZInput:GetValue()
        print("Teleporting to:", x, y, z)
        SpectrumX:Notify({
            Text = "Teleported to " .. x .. ", " .. y .. ", " .. z,
            Type = "success"
        })
    end
})

-- ==================== MISC TAB ====================

Window:CreateSection(MiscTab.Left, "🔧 Utilities", SpectrumX.Theme.TextSecondary)

-- Labels
Window:CreateLabel(MiscTab.Left, {
    Text = "Player Information",
    Color = SpectrumX.Theme.Accent,
    Size = UDim2.new(1, 0, 0, 30)
})

Window:CreateLabel(MiscTab.Left, {
    Text = "Health: 100/100",
    Color = SpectrumX.Theme.Success
})

Window:CreateLabel(MiscTab.Left, {
    Text = "Level: 50",
    Color = SpectrumX.Theme.Info
})

Window:CreateLabel(MiscTab.Left, {
    Text = "Coins: 999,999",
    Color = SpectrumX.Theme.Warning
})

Window:CreateSeparator(MiscTab.Left)

-- More Buttons
Window:CreateButton(MiscTab.Left, {
    Text = "Reset Character",
    Style = "default",
    Callback = function()
        print("Resetting character...")
    end
})

-- Status Card (Draggable)
local StatusCard = Window:CreateStatusCard(MiscTab.Right, {
    Title = "⚡ SYSTEM STATUS"
})

-- Update status example
spawn(function()
    while wait(2) do
        StatusCard:SetStatus("Active", SpectrumX.Theme.Success)
        StatusCard:SetInfo("Farming in progress...")
        StatusCard.AnimateLoading(true, 2)
        wait(2)
        StatusCard:SetStatus("Idle", SpectrumX.Theme.TextMuted)
        StatusCard:SetInfo("Waiting for next action")
        StatusCard.AnimateLoading(false)
    end
end)

-- ==================== NOTIFICATIONS DEMO ====================

-- Show welcome notification
SpectrumX:Notify({
    Text = "Welcome to SpectrumX UI Library!",
    Type = "info",
    Duration = 4
})

-- Example: Programmatic control
-- AutoFarmToggle:SetState(true)
-- SpeedInput:SetValue(5)
-- LocationDropdown:SetValue("City")
-- StatusCard:SetStatus("Running", SpectrumX.Theme.Success)

print("SpectrumX UI Loaded Successfully!")

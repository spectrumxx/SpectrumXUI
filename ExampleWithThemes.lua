--[[
    SpectrumX UI Library - Example with Themes
    Shows how to use different color themes
--]]

-- Load the library and themes
local SpectrumX = loadstring(game:HttpGet("https://raw.githubusercontent.com/seuusuario/SpectrumXUI/main/Main.lua"))()
local Themes = loadstring(game:HttpGet("https://raw.githubusercontent.com/seuusuario/SpectrumXUI/main/Themes.lua"))()

-- Apply a theme BEFORE creating the window
-- Available themes: "Red", "Blue", "Purple", "Green", "Orange", "Pink", "Dark", "Midnight"
Themes.Apply(SpectrumX, "Purple")  -- Change this to try different themes!

-- Create Window
local Window = SpectrumX:CreateWindow({
    Title = "Themed UI",
    Icon = "T"
})

-- Create Tab
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "M"
})

-- Add some components to show the theme
Window:CreateSection(MainTab.Left, "Theme Demo", SpectrumX.Theme.Accent)

Window:CreateToggle(MainTab.Left, {
    Text = "Sample Toggle",
    Default = true,
    Callback = function(state) end
})

Window:CreateSlider(MainTab.Left, {
    Text = "Sample Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value) end
})

Window:CreateButton(MainTab.Left, {
    Text = "Sample Button",
    Style = "accent",
    Callback = function()
        SpectrumX:Notify({
            Text = "Current theme applied!",
            Type = "success"
        })
    end
})

Window:CreateDropdown(MainTab.Left, {
    Label = "Theme Selector",
    Options = Themes.GetNames(),
    Default = "Purple",
    Callback = function(selected)
        print("Selected theme:", selected)
    end
})

-- Right side
Window:CreateSection(MainTab.Right, "More Examples", SpectrumX.Theme.Warning)

Window:CreateCheckbox(MainTab.Right, {
    Text = "Checkbox Example",
    Default = false,
    Callback = function(state) end
})

Window:CreateInput(MainTab.Right, {
    Label = "Text Input",
    Placeholder = "Type something...",
    Callback = function(text) end
})

Window:CreateNumberInput(MainTab.Right, {
    Label = "Number Input",
    Default = 42,
    Min = 0,
    Max = 100,
    Callback = function(value) end
})

-- Status card with theme colors
local status = Window:CreateStatusCard(MainTab.Right, {
    Title = "Status"
})

status:SetStatus("Active", SpectrumX.Theme.Success)
status:SetInfo("Theme: Purple")
status:AnimateLoading(true, 2)

-- Show available themes
print("Available themes:")
for _, name in ipairs(Themes.GetNames()) do
    print(" - " .. name)
end

# 🎨 SpectrumX UI Library

A modern, sleek, and mobile-optimized UI library for Roblox. Built with a dark theme and red accent colors, perfect for creating professional-looking interfaces.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Roblox](https://img.shields.io/badge/platform-Roblox-red.svg)

## ✨ Features

- 📱 **Mobile Optimized** - Touch-friendly interface with proper sizing
- 🎨 **Modern Design** - Dark theme with beautiful red accents
- 🖱️ **Draggable Elements** - Move windows and status cards freely
- 📦 **Complete Components** - All UI elements you need
- ⚡ **Smooth Animations** - Tween-based transitions
- 🔔 **Notifications** - Built-in notification system
- 🎯 **Easy to Use** - Simple and intuitive API

## 📦 Components

| Component | Description |
|-----------|-------------|
| `Toggle` | On/Off switch with smooth animation |
| `Button` | Clickable button with multiple styles |
| `Input` | Text input field |
| `NumberInput` | Numeric input with min/max constraints |
| `Slider` | Draggable value slider |
| `Dropdown` | Single select dropdown menu |
| `MultiDropdown` | Multi-select dropdown with priorities |
| `Checkbox` | Check/uncheck box |
| `Label` | Display text |
| `Section` | Section title separator |
| `StatusCard` | Draggable status display with loading bar |
| `Separator` | Visual divider |

## 🚀 Quick Start

```lua
-- Load the library
local SpectrumX = loadstring(game:HttpGet("https://raw.githubusercontent.com/seuusuario/SpectrumXUI/main/Main.lua"))()

-- Create Window
local Window = SpectrumX:CreateWindow({
    Title = "My Script",
    Icon = "S"
})

-- Create Tab
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "M"
})

-- Add Components
Window:CreateToggle(MainTab.Left, {
    Text = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
    end
})

Window:CreateButton(MainTab.Right, {
    Text = "Click Me",
    Callback = function()
        print("Button clicked!")
    end
})
```

## 📖 Documentation

### Creating a Window

```lua
local Window = SpectrumX:CreateWindow({
    Title = "Window Title",      -- Window title
    Icon = "S",                  -- Single letter icon
    Position = UDim2.new(0.5, -300, 0.5, -180), -- Window position
    Size = UDim2.new(0, 600, 0, 360)            -- Window size
})
```

### Creating Tabs

```lua
local MainTab = Window:CreateTab({
    Name = "Main",    -- Tab identifier
    Icon = "M"        -- Single letter or emoji
})

-- Access left and right columns
MainTab.Left   -- Left scrolling frame
MainTab.Right  -- Right scrolling frame
```

### Toggle

```lua
Window:CreateToggle(parent, {
    Text = "Feature Name",
    Default = false,
    Callback = function(state)
        -- state is true/false
    end
})

-- Methods:
toggle:GetState()      -- Get current state
toggle:SetState(true)  -- Set state programmatically
```

### Button

```lua
Window:CreateButton(parent, {
    Text = "Button Text",
    Style = "default",  -- default, accent, warning, info
    Callback = function()
        -- Button clicked
    end
})

-- Methods:
button:SetText("New Text")
```

### Input

```lua
Window:CreateInput(parent, {
    Label = "Username",
    Default = "",
    Placeholder = "Enter text...",
    Callback = function(text)
        -- Text entered
    end
})

-- Methods:
input:GetText()
input:SetText("new text")
```

### Number Input

```lua
Window:CreateNumberInput(parent, {
    Label = "Speed",
    Default = 1,
    Min = 0,
    Max = 100,
    Callback = function(value)
        -- Number value
    end
})

-- Methods:
input:GetValue()
input:SetValue(50)
```

### Slider

```lua
Window:CreateSlider(parent, {
    Text = "Volume",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        -- Slider value
    end
})

-- Methods:
slider:GetValue()
slider:SetValue(75)
```

### Dropdown (Single Select)

```lua
Window:CreateDropdown(parent, {
    Label = "Select Option",
    Options = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",
    Callback = function(selected)
        -- Selected option
    end
})

-- Methods:
dropdown:GetValue()
dropdown:SetValue("Option 2")
dropdown:SetOptions({"New", "Options"})
```

### Multi Dropdown

```lua
Window:CreateMultiDropdown(parent, {
    Label = "Select Multiple",
    Options = {"A", "B", "C", "D"},
    Default = {"A", "C"},
    Callback = function(selected)
        -- Table of selected values
    end
})

-- Methods:
dropdown:GetValues()           -- Returns table
dropdown:SetValues({"A", "B"})
dropdown:SetOptions({"New", "List"})
```

### Checkbox

```lua
Window:CreateCheckbox(parent, {
    Text = "Enable Feature",
    Default = false,
    Callback = function(state)
        -- true/false
    end
})

-- Methods:
checkbox:GetState()
checkbox:SetState(true)
```

### Label

```lua
Window:CreateLabel(parent, {
    Text = "Display Text",
    Color = SpectrumX.Theme.Text,
    Size = UDim2.new(1, 0, 0, 30)
})

-- Methods:
label:SetText("New Text")
```

### Section Title

```lua
Window:CreateSection(parent, "Section Name", SpectrumX.Theme.Accent)
```

### Status Card

```lua
local status = Window:CreateStatusCard(parent, {
    Title = "System Status"
})

-- Methods:
status:SetStatus("Active", SpectrumX.Theme.Success)
status:SetInfo("Additional info here")
status:AnimateLoading(true, 1.5)  -- Start animation
status:AnimateLoading(false)       -- Stop animation
```

### Separator

```lua
Window:CreateSeparator(parent)
```

## 🔔 Notifications

```lua
SpectrumX:Notify({
    Text = "Operation completed!",
    Type = "success",  -- info, success, warning, error
    Duration = 3       -- Seconds
})
```

## 🎨 Customization

### Theme Colors

```lua
SpectrumX.Theme = {
    Background = Color3.fromRGB(0, 0, 0),
    Header = Color3.fromRGB(0, 0, 0),
    Sidebar = Color3.fromRGB(0, 0, 0),
    Content = Color3.fromRGB(15, 15, 15),
    Card = Color3.fromRGB(25, 25, 25),
    Input = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(255, 40, 40),
    AccentSecondary = Color3.fromRGB(255, 100, 100),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    TextMuted = Color3.fromRGB(150, 150, 150),
    Success = Color3.fromRGB(50, 255, 50),
    Warning = Color3.fromRGB(255, 200, 100),
    Info = Color3.fromRGB(100, 180, 255),
    Border = Color3.fromRGB(40, 40, 40),
    ToggleOff = Color3.fromRGB(50, 50, 50),
    ToggleOn = Color3.fromRGB(255, 40, 40)
}
```

## 📱 Mobile Features

- Large touch targets (minimum 40px)
- Draggable floating toggle button
- Proper spacing for touch interfaces
- Smooth scrolling
- Touch-friendly dropdowns

## 📁 File Structure

```
SpectrumXUI/
├── Main.lua          -- Main library file
├── Example.lua       -- Usage examples
└── README.md         -- Documentation
```

## 🔧 Utility Functions

```lua
-- Tween animation
SpectrumX:Tween(object, {Property = value}, duration)

-- Create corner
SpectrumX:CreateCorner(parent, radius)

-- Create stroke
SpectrumX:CreateStroke(parent, color, thickness, transparency)

-- Create shadow
SpectrumX:CreateShadow(parent)

-- Make draggable
SpectrumX:MakeDraggable(frame, handle)

-- Destroy UI
SpectrumX:Destroy()
```

## 💡 Tips

1. **Organize your UI** - Use tabs to group related features
2. **Use sections** - Add section titles to organize content
3. **Left/Right columns** - Balance content between sides
4. **Status cards** - Use for displaying real-time information
5. **Notifications** - Keep users informed of actions

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## 🌟 Credits

Created by [Your Name]

Inspired by modern UI design principles.

---

<p align="center">Made with ❤️ for the Roblox community</p>

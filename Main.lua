--[[
    SpectrumX UI Library (Remastered PRO)
    A modern, high-quality, mobile-optimized UI library for Roblox.
    
    FEATURES:
    - Advanced Responsiveness (Auto-Centering & UIScale)
    - Full Asset ID Support (Header & Tabs)
    - Intelligent Dropdowns (Collision detection & Click-outside-to-close)
    - Premium Visuals (Subtle gradients, better strokes, and spacing)
    - Compact but readable (Wind UI inspired with PC comfort)
--]]

local SpectrumX = {}
SpectrumX.__index = SpectrumX

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Theme Configuration
SpectrumX.Theme = {
    Background = Color3.fromRGB(12, 12, 12),
    Header = Color3.fromRGB(18, 18, 18),
    Sidebar = Color3.fromRGB(18, 18, 18),
    Content = Color3.fromRGB(22, 22, 22),
    Card = Color3.fromRGB(28, 28, 28),
    Input = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(255, 60, 60),
    AccentSecondary = Color3.fromRGB(255, 110, 110),
    Text = Color3.fromRGB(250, 250, 250),
    TextSecondary = Color3.fromRGB(190, 190, 190),
    TextMuted = Color3.fromRGB(140, 140, 140),
    Success = Color3.fromRGB(80, 255, 80),
    Warning = Color3.fromRGB(255, 210, 100),
    Info = Color3.fromRGB(100, 190, 255),
    Border = Color3.fromRGB(45, 45, 45),
    ToggleOff = Color3.fromRGB(50, 50, 50),
    ToggleOn = Color3.fromRGB(255, 60, 60)
}

-- Utility Functions
function SpectrumX:Tween(obj, props, time, easingStyle, easingDirection)
    local info = TweenInfo.new(
        time or 0.25,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

function SpectrumX:CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 8)
    corner.Parent = parent
    return corner
end

function SpectrumX:CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or self.Theme.Accent
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

function SpectrumX:CreateShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 45, 1, 45)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.Parent = parent
    return shadow
end

function SpectrumX:GetIconType(val)
    if not val then return nil end
    local sVal = tostring(val)
    if sVal:match("rbxassetid://") or sVal:match("http://") or tonumber(val) then
        return "Image"
    end
    return "Text"
end

function SpectrumX:ApplyIcon(obj, val, color)
    local iconType = self:GetIconType(val)
    if iconType == "Image" then
        local id = tonumber(val) and "rbxassetid://"..val or val
        obj.Image = id
        obj.ImageColor3 = color or self.Theme.Text
    else
        obj.Text = tostring(val)
        obj.TextColor3 = color or self.Theme.Text
    end
end

function SpectrumX:MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Global Scale Logic
function SpectrumX:SetupScaling(guiObject)
    local uiScale = Instance.new("UIScale")
    uiScale.Parent = guiObject
    
    local function update()
        local vp = workspace.CurrentCamera.ViewportSize
        local baseRes = Vector2.new(1280, 720)
        local scale = math.min(vp.X / baseRes.X, vp.Y / baseRes.Y)
        -- Clamp scale to prevent it from getting too small or too huge
        uiScale.Scale = math.clamp(scale, 0.7, 1.2)
    end
    
    update()
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
    return uiScale
end

function SpectrumX:CreateWindow(config)
    config = config or {}
    local window = setmetatable({}, self)
    
    if PlayerGui:FindFirstChild("SpectrumX") then PlayerGui.SpectrumX:Destroy() end
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SpectrumX"
    self.ScreenGui.Parent = PlayerGui
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.IgnoreGuiInset = true
    
    -- Centering logic: Use AnchorPoint and 0.5 Scale
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Position = config.Position or UDim2.new(0.5, 0, 0.5, 0)
    self.MainFrame.Size = config.Size or UDim2.new(0, 620, 0, 400)
    self.MainFrame.Active = true
    self.MainFrame.Parent = self.ScreenGui
    
    self:CreateCorner(self.MainFrame, UDim.new(0, 12))
    self:CreateShadow(self.MainFrame)
    self:CreateStroke(self.MainFrame, self.Theme.Border, 1.5, 0)
    self:SetupScaling(self.MainFrame)
    
    -- Dropdown Overlay (to close when clicking outside)
    self.DropdownOverlay = Instance.new("TextButton")
    self.DropdownOverlay.Name = "DropdownOverlay"
    self.DropdownOverlay.BackgroundTransparency = 1
    self.DropdownOverlay.Size = UDim2.new(1, 0, 1, 0)
    self.DropdownOverlay.Text = ""
    self.DropdownOverlay.Visible = false
    self.DropdownOverlay.ZIndex = 1500
    self.DropdownOverlay.Parent = self.ScreenGui
    
    -- Header
    self.Header = Instance.new("Frame")
    self.Header.Name = "Header"
    self.Header.BackgroundColor3 = self.Theme.Header
    self.Header.Size = UDim2.new(1, 0, 0, 50)
    self.Header.Parent = self.MainFrame
    self:CreateCorner(self.Header, UDim.new(0, 12))
    
    local headerCover = Instance.new("Frame")
    headerCover.BorderSizePixel = 0
    headerCover.BackgroundColor3 = self.Theme.Header
    headerCover.Size = UDim2.new(1, 0, 0, 15)
    headerCover.Position = UDim2.new(0, 0, 1, -15)
    headerCover.Parent = self.Header
    
    local sep = Instance.new("Frame")
    sep.BackgroundColor3 = self.Theme.Border
    sep.BorderSizePixel = 0
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.Position = UDim2.new(0, 0, 1, 0)
    sep.Parent = self.Header
    
    -- Icon logic (Asset ID supported)
    local iconVal = config.Icon or "S"
    local iconType = self:GetIconType(iconVal)
    local titleIcon
    
    if iconType == "Image" then
        titleIcon = Instance.new("ImageLabel")
        titleIcon.Size = UDim2.new(0, 30, 0, 30)
        titleIcon.Position = UDim2.new(0, 15, 0, 10)
    else
        titleIcon = Instance.new("TextLabel")
        titleIcon.Size = UDim2.new(0, 30, 1, 0)
        titleIcon.Position = UDim2.new(0, 15, 0, 0)
        titleIcon.Font = Enum.Font.GothamBlack
        titleIcon.TextSize = 24
    end
    titleIcon.Name = "TitleIcon"
    titleIcon.BackgroundTransparency = 1
    self:ApplyIcon(titleIcon, iconVal, self.Theme.Accent)
    titleIcon.Parent = self.Header
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 55, 0, 0)
    title.Size = UDim2.new(0, 300, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title or "Spectrum X"
    title.TextColor3 = self.Theme.Text
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self.Header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position = UDim2.new(1, -45, 0, 10)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = self.Theme.TextMuted
    closeBtn.TextSize = 18
    closeBtn.Parent = self.Header
    
    closeBtn.MouseEnter:Connect(function() self:Tween(closeBtn, {TextColor3 = self.Theme.Text}, 0.2) end)
    closeBtn.MouseLeave:Connect(function() self:Tween(closeBtn, {TextColor3 = self.Theme.TextMuted}, 0.2) end)
    closeBtn.MouseButton1Click:Connect(function() self.MainFrame.Visible = false end)
    
    -- Sidebar
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.BackgroundColor3 = self.Theme.Sidebar
    self.Sidebar.Position = UDim2.new(0, 0, 0, 50)
    self.Sidebar.Size = UDim2.new(0, 60, 1, -50)
    self.Sidebar.Parent = self.MainFrame
    self:CreateCorner(self.Sidebar, UDim.new(0, 12))
    
    local sidebarCover = Instance.new("Frame")
    sidebarCover.BackgroundColor3 = self.Theme.Sidebar
    sidebarCover.BorderSizePixel = 0
    sidebarCover.Size = UDim2.new(1, 0, 0, 15)
    sidebarCover.Parent = self.Sidebar
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 10)
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.Parent = self.Sidebar
    
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 15)
    sidebarPadding.Parent = self.Sidebar
    
    -- Content Area
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Position = UDim2.new(0, 70, 0, 60)
    self.ContentArea.Size = UDim2.new(1, -80, 1, -75)
    self.ContentArea.Parent = self.MainFrame
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    self:MakeDraggable(self.MainFrame, self.Header)
    self:CreateFloatingButton()
    
    return window
end

function SpectrumX:CreateFloatingButton()
    self.FloatBtn = Instance.new("ImageButton")
    self.FloatBtn.Name = "FloatBtn"
    self.FloatBtn.BackgroundColor3 = self.Theme.Accent
    self.FloatBtn.Position = UDim2.new(0, 20, 0.5, 0)
    self.FloatBtn.Size = UDim2.new(0, 50, 0, 50)
    self.FloatBtn.Image = ""
    self.FloatBtn.Parent = self.ScreenGui
    self:CreateCorner(self.FloatBtn, UDim.new(0, 14))
    self:SetupScaling(self.FloatBtn)
    
    local floatText = Instance.new("TextLabel")
    floatText.BackgroundTransparency = 1
    floatText.Size = UDim2.new(1, 0, 1, 0)
    floatText.Font = Enum.Font.GothamBlack
    floatText.Text = "S"
    floatText.TextColor3 = self.Theme.Text
    floatText.TextSize = 24
    floatText.Parent = self.FloatBtn
    
    local floatStroke = Instance.new("UIStroke")
    floatStroke.Color = Color3.fromRGB(0, 0, 0)
    floatStroke.Thickness = 2.5
    floatStroke.Parent = self.FloatBtn
    
    local fDragging, fDragInput, fDragStart, fStartPos
    self.FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fDragging = true
            fDragStart = input.Position
            fStartPos = self.FloatBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then fDragging = false end
            end)
        end
    end)
    
    self.FloatBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then fDragInput = input end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == fDragInput and fDragging then
            local delta = input.Position - fDragStart
            self.FloatBtn.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
        end
    end)
    
    self.FloatBtn.MouseButton1Click:Connect(function()
        if not fDragging then self.MainFrame.Visible = not self.MainFrame.Visible end
    end)
end

function SpectrumX:CreateTab(config)
    config = config or {}
    local tabId = config.Name or "Tab"
    local tabIcon = config.Icon or string.sub(tabId, 1, 1)
    
    local tabBtn
    if self:GetIconType(tabIcon) == "Image" then
        tabBtn = Instance.new("ImageButton")
        tabBtn.Size = UDim2.new(0, 40, 0, 40)
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 8); padding.PaddingBottom = UDim.new(0, 8)
        padding.PaddingLeft = UDim.new(0, 8); padding.PaddingRight = UDim.new(0, 8)
        padding.Parent = tabBtn
    else
        tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0, 40, 0, 40)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 18
    end
    
    tabBtn.Name = tabId .. "Tab"
    tabBtn.BackgroundColor3 = self.Theme.Card
    tabBtn.Parent = self.Sidebar
    self:CreateCorner(tabBtn, UDim.new(0, 10))
    self:ApplyIcon(tabBtn, tabIcon, self.Theme.TextMuted)
    
    local pageContainer = Instance.new("Frame")
    pageContainer.Name = tabId .. "PageContainer"
    pageContainer.BackgroundTransparency = 1
    pageContainer.Size = UDim2.new(1, 0, 1, 0)
    pageContainer.Visible = false
    pageContainer.Parent = self.ContentArea
    
    local function createSide(name, pos)
        local side = Instance.new("ScrollingFrame")
        side.Name = name
        side.BackgroundTransparency = 1
        side.BorderSizePixel = 0
        side.Position = pos
        side.Size = UDim2.new(0.485, 0, 1, 0)
        side.ScrollBarThickness = 2
        side.ScrollBarImageColor3 = self.Theme.Border
        side.Parent = pageContainer
        
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 12)
        layout.Parent = side
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            side.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
        end)
        return side
    end
    
    local leftSide = createSide("LeftSide", UDim2.new(0, 0, 0, 0))
    local rightSide = createSide("RightSide", UDim2.new(0.515, 0, 0, 0))
    
    local tabData = { Button = tabBtn, Container = pageContainer, Left = leftSide, Right = rightSide, IconValue = tabIcon }
    self.Tabs[tabId] = tabData
    
    tabBtn.MouseButton1Click:Connect(function() self:SelectTab(tabId) end)
    if not self.CurrentTab then self:SelectTab(tabId) end
    
    return tabData
end

function SpectrumX:SelectTab(tabId)
    for id, data in pairs(self.Tabs) do
        local isSelected = (id == tabId)
        data.Container.Visible = isSelected
        local color = isSelected and self.Theme.Text or self.Theme.TextMuted
        local bg = isSelected and self.Theme.Accent or self.Theme.Card
        
        self:Tween(data.Button, {BackgroundColor3 = bg}, 0.2)
        self:ApplyIcon(data.Button, data.IconValue, color)
    end
    self.CurrentTab = tabId
end

-- Component Creation (Smaller but luxurious)
function SpectrumX:CreateSection(parent, text, color)
    local section = Instance.new("TextLabel")
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, 0, 0, 24)
    section.Font = Enum.Font.GothamBold
    section.Text = text
    section.TextColor3 = color or self.Theme.Accent
    section.TextSize = 14
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = parent
    return section
end

function SpectrumX:CreateToggle(parent, config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local switchBg = Instance.new("TextButton")
    switchBg.Text = ""
    switchBg.BackgroundColor3 = default and self.Theme.ToggleOn or self.Theme.ToggleOff
    switchBg.Position = UDim2.new(1, -50, 0.5, -11)
    switchBg.Size = UDim2.new(0, 38, 0, 22)
    switchBg.Parent = frame
    self:CreateCorner(switchBg, UDim.new(1, 0))
    
    local circle = Instance.new("Frame")
    circle.BackgroundColor3 = self.Theme.Text
    circle.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Parent = switchBg
    self:CreateCorner(circle, UDim.new(1, 0))
    
    local state = default
    local function update(newState)
        state = newState
        callback(state)
        self:Tween(switchBg, {BackgroundColor3 = state and self.Theme.ToggleOn or self.Theme.ToggleOff}, 0.2)
        self:Tween(circle, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2)
    end
    
    switchBg.MouseButton1Click:Connect(function() update(not state) end)
    return { Frame = frame, GetState = function() return state end, SetState = update }
end

function SpectrumX:CreateButton(parent, config)
    config = config or {}
    local text = config.Text or "Button"
    local style = config.Style or "default"
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.Parent = parent
    self:CreateCorner(frame)
    self:CreateStroke(frame, self.Theme.Border, 1, 0)
    
    local btn = Instance.new("TextButton")
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextSize = 13
    btn.Parent = frame
    
    local color = self.Theme.Text
    if style == "warning" then color = self.Theme.Warning
    elseif style == "info" then color = self.Theme.Info
    elseif style == "accent" then color = self.Theme.Accent end
    btn.TextColor3 = color
    
    btn.MouseEnter:Connect(function() self:Tween(frame, {BackgroundColor3 = self.Theme.Input}, 0.15) end)
    btn.MouseLeave:Connect(function() self:Tween(frame, {BackgroundColor3 = self.Theme.Card}, 0.15) end)
    btn.MouseButton1Down:Connect(function() self:Tween(btn, {TextSize = 11}, 0.1) end)
    btn.MouseButton1Up:Connect(function() self:Tween(btn, {TextSize = 13}, 0.1) end)
    btn.MouseButton1Click:Connect(callback)
    
    return { Frame = frame, Button = btn, SetText = function(t) btn.Text = t end }
end

function SpectrumX:CreateInput(parent, config)
    config = config or {}
    local labelText = config.Label or "Input"
    local default = config.Default or ""
    local placeholder = config.Placeholder or "Type here..."
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 5)
    label.Size = UDim2.new(1, -20, 0, 18)
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local box = Instance.new("TextBox")
    box.BackgroundColor3 = self.Theme.Input
    box.Position = UDim2.new(0, 10, 0, 25)
    box.Size = UDim2.new(1, -20, 0, 22)
    box.Font = Enum.Font.Gotham
    box.Text = tostring(default)
    box.PlaceholderText = placeholder
    box.TextColor3 = self.Theme.Text
    box.TextSize = 12
    box.Parent = frame
    self:CreateCorner(box, UDim.new(0, 6))
    
    local boxStroke = self:CreateStroke(box, self.Theme.Accent, 1, 1)
    box.Focused:Connect(function() self:Tween(boxStroke, {Transparency = 0.4}, 0.2) end)
    box.FocusLost:Connect(function()
        self:Tween(boxStroke, {Transparency = 1}, 0.2)
        callback(box.Text)
    end)
    
    return { Frame = frame, TextBox = box, GetText = function() return box.Text end, SetText = function(t) box.Text = t end }
end

function SpectrumX:CreateSlider(parent, config)
    config = config or {}
    local text = config.Text or "Slider"
    local min, max = config.Min or 0, config.Max or 100
    local default = config.Default or min
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 6)
    label.Size = UDim2.new(0.5, 0, 0, 18)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text; label.TextColor3 = self.Theme.Text; label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valLabel = Instance.new("TextLabel")
    valLabel.BackgroundTransparency = 1; valLabel.Position = UDim2.new(0.5, -12, 0, 6); valLabel.Size = UDim2.new(0.5, 0, 0, 18)
    valLabel.Font = Enum.Font.GothamBold; valLabel.Text = tostring(default); valLabel.TextColor3 = self.Theme.Accent; valLabel.TextSize = 12; valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.BackgroundColor3 = self.Theme.Input; sliderBg.Position = UDim2.new(0, 12, 0, 32); sliderBg.Size = UDim2.new(1, -24, 0, 8)
    sliderBg.Parent = frame; self:CreateCorner(sliderBg, UDim.new(1, 0))
    
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = self.Theme.Accent; fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.Parent = sliderBg; self:CreateCorner(fill, UDim.new(1, 0))
    
    local knob = Instance.new("Frame")
    knob.BackgroundColor3 = self.Theme.Text; knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8); knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Parent = sliderBg; self:CreateCorner(knob, UDim.new(1, 0))
    
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor((min + (max - min) * pos) * 100) / 100
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -8, 0.5, -8)
        valLabel.Text = tostring(value)
        callback(value)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; update(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    
    return { Frame = frame }
end

-- Intelligent Dropdown Logic
function SpectrumX:CreateDropdown(parent, config, isMulti)
    local labelText = config.Label or "Dropdown"
    local options = config.Options or {}
    local default = config.Default
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, 52)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1; label.Position = UDim2.new(0, 12, 0, 5); label.Size = UDim2.new(1, -24, 0, 18)
    label.Font = Enum.Font.GothamBold; label.Text = labelText; label.TextColor3 = self.Theme.Text; label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = self.Theme.Input; btn.Position = UDim2.new(0, 12, 0, 25); btn.Size = UDim2.new(1, -24, 0, 22)
    btn.Font = Enum.Font.GothamSemibold; btn.Text = "  Select..."; btn.TextColor3 = self.Theme.TextSecondary; btn.TextSize = 12; btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = frame; self:CreateCorner(btn, UDim.new(0, 6))
    
    local arrow = Instance.new("TextLabel")
    arrow.BackgroundTransparency = 1; arrow.Position = UDim2.new(1, -25, 0, 0); arrow.Size = UDim2.new(0, 25, 1, 0)
    arrow.Font = Enum.Font.GothamBold; arrow.Text = "▼"; arrow.TextColor3 = self.Theme.Accent; arrow.TextSize = 10
    arrow.Parent = btn
    
    local list = Instance.new("ScrollingFrame")
    list.BackgroundColor3 = self.Theme.Card; list.Size = UDim2.new(0, 200, 0, 0); list.ScrollBarThickness = 2; list.Visible = false; list.ZIndex = 2000; list.BorderSizePixel = 0
    list.Parent = self.ScreenGui; self:CreateCorner(list, UDim.new(0, 8)); self:CreateStroke(list, self.Theme.Border, 1.5, 0)
    
    local listScale = self:SetupScaling(list)
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 4); listLayout.Parent = list
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 6); listPadding.PaddingBottom = UDim.new(0, 6); listPadding.PaddingLeft = UDim.new(0, 6); listPadding.PaddingRight = UDim.new(0, 6)
    listPadding.Parent = list
    
    local isOpen = false
    local renderConn
    local selection = isMulti and {} or default
    if isMulti and default then for _, v in ipairs(default) do table.insert(selection, v) end end
    
    local function updateText()
        if isMulti then
            if #selection == 0 then btn.Text = "  Select..."
            elseif #selection == 1 then btn.Text = "  " .. selection[1]
            else btn.Text = "  " .. #selection .. " selected" end
        else btn.Text = "  " .. (selection or "Select...") end
    end
    updateText()
    
    local function close()
        if not isOpen then return end
        isOpen = false
        if renderConn then renderConn:Disconnect() end
        self.DropdownOverlay.Visible = false
        self:Tween(list, {Size = UDim2.new(0, btn.AbsoluteSize.X / listScale.Scale, 0, 0)}, 0.2)
        self:Tween(arrow, {Rotation = 0}, 0.2)
        task.wait(0.2)
        list.Visible = false
    end
    
    local function populate()
        for _, c in ipairs(list:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        for _, opt in ipairs(options) do
            local isSel = false
            if isMulti then for _, v in ipairs(selection) do if v == opt then isSel = true break end end else isSel = (opt == selection) end
            
            local optFrame = Instance.new("Frame")
            optFrame.BackgroundColor3 = isSel and Color3.fromRGB(45, 55, 45) or self.Theme.Input; optFrame.Size = UDim2.new(1, 0, 0, 28); optFrame.ZIndex = 2001
            optFrame.Parent = list; self:CreateCorner(optFrame, UDim.new(0, 6))
            
            local oBtn = Instance.new("TextButton")
            oBtn.BackgroundTransparency = 1; oBtn.Size = UDim2.new(1, 0, 1, 0); oBtn.Font = Enum.Font.GothamSemibold; oBtn.Text = "  " .. (isSel and "✓ " or "") .. opt
            oBtn.TextColor3 = isSel and self.Theme.Success or self.Theme.TextSecondary; oBtn.TextSize = 12; oBtn.TextXAlignment = Enum.TextXAlignment.Left; oBtn.ZIndex = 2002; oBtn.Parent = optFrame
            
            oBtn.MouseButton1Click:Connect(function()
                if isMulti then
                    local found = false; for i, v in ipairs(selection) do if v == opt then table.remove(selection, i); found = true break end end
                    if not found then table.insert(selection, opt) end
                    updateText(); callback(selection); populate()
                else
                    selection = opt; updateText(); callback(opt); close()
                end
            end)
        end
        local h = math.min(listLayout.AbsoluteContentSize.Y + 12, 180)
        self:Tween(list, {Size = UDim2.new(0, btn.AbsoluteSize.X / listScale.Scale, 0, h)}, 0.2)
        list.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
    end
    
    local function updatePos()
        if not btn.Parent then return end
        local vp = workspace.CurrentCamera.ViewportSize
        local ap = btn.AbsolutePosition
        local as = btn.AbsoluteSize
        local th = list.Size.Y.Offset * listScale.Scale
        -- Fixed: Proper offset logic to prevent overlapping the button
        if ap.Y + as.Y + th + 10 > vp.Y then
            list.Position = UDim2.fromOffset(ap.X, ap.Y - th - 5)
        else
            list.Position = UDim2.fromOffset(ap.X, ap.Y + as.Y + 5)
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        if isOpen then close() return end
        isOpen = true
        self.DropdownOverlay.Visible = true
        list.Size = UDim2.new(0, btn.AbsoluteSize.X / listScale.Scale, 0, 0)
        list.Visible = true
        updatePos()
        renderConn = RunService.RenderStepped:Connect(updatePos)
        populate()
        self:Tween(arrow, {Rotation = 180}, 0.2)
    end)
    
    self.DropdownOverlay.MouseButton1Click:Connect(close)
    
    return { Frame = frame }
end

function SpectrumX:CreateMultiDropdown(p, c) return self:CreateDropdown(p, c, true) end

function SpectrumX:Notify(config)
    local notification = Instance.new("Frame")
    notification.BackgroundColor3 = self.Theme.Card; notification.Position = UDim2.new(1, 300, 0.9, 0); notification.Size = UDim2.new(0, 280, 0, 60); notification.Parent = self.ScreenGui
    self:CreateCorner(notification); self:SetupScaling(notification)
    
    local type = config.Type or "info"
    local color = type == "success" and self.Theme.Success or type == "warning" and self.Theme.Warning or type == "error" and Color3.fromRGB(255, 50, 50) or self.Theme.Info
    self:CreateStroke(notification, color, 1.5, 0.2)
    
    local icon = Instance.new("TextLabel")
    icon.BackgroundTransparency = 1; icon.Position = UDim2.new(0, 12, 0, 0); icon.Size = UDim2.new(0, 30, 1, 0); icon.Font = Enum.Font.GothamBlack
    icon.Text = type == "success" and "✓" or type == "warning" and "!" or type == "error" and "✕" or "i"
    icon.TextColor3 = color; icon.TextSize = 22; icon.Parent = notification
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1; label.Position = UDim2.new(0, 50, 0, 0); label.Size = UDim2.new(1, -60, 1, 0); label.Font = Enum.Font.GothamSemibold
    label.Text = config.Text or "Notification"; label.TextColor3 = self.Theme.Text; label.TextSize = 13; label.TextWrapped = true; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = notification
    
    self:Tween(notification, {Position = UDim2.new(1, -300, 0.9, 0)}, 0.4)
    task.delay(config.Duration or 3, function()
        if notification.Parent then
            self:Tween(notification, {Position = UDim2.new(1, 300, 0.9, 0)}, 0.4)
            task.wait(0.4); notification:Destroy()
        end
    end)
end

function SpectrumX:Destroy()
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

return SpectrumX

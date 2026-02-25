--[[
    SpectrumX UI Library (Remastered)
    A modern, compact, mobile-optimized UI library for Roblox
    Remastered for better responsiveness, smaller footprint, and asset ID support.
    Fixed dropdown overlapping and multi-select.
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
    Background = Color3.fromRGB(10, 10, 10),
    Header = Color3.fromRGB(15, 15, 15),
    Sidebar = Color3.fromRGB(15, 15, 15),
    Content = Color3.fromRGB(20, 20, 20),
    Card = Color3.fromRGB(25, 25, 25),
    Input = Color3.fromRGB(32, 32, 32),
    Accent = Color3.fromRGB(255, 60, 60),
    AccentSecondary = Color3.fromRGB(255, 100, 100),
    Text = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    TextMuted = Color3.fromRGB(130, 130, 130),
    Success = Color3.fromRGB(60, 255, 60),
    Warning = Color3.fromRGB(255, 200, 80),
    Info = Color3.fromRGB(80, 180, 255),
    Border = Color3.fromRGB(40, 40, 40),
    ToggleOff = Color3.fromRGB(45, 45, 45),
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
    corner.CornerRadius = radius or UDim.new(0, 6)
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
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.Parent = parent
    return shadow
end

function SpectrumX:MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    return dragging
end

-- Global Scale Logic for DPI / Device responsiveness
function SpectrumX:GetViewportScale()
    local viewport = workspace.CurrentCamera.ViewportSize
    if viewport.Y < 600 then
        return viewport.Y / 600
    end
    return 1
end

function SpectrumX:SetupScaling(guiObject)
    local uiScale = Instance.new("UIScale")
    uiScale.Parent = guiObject
    
    local function update()
        uiScale.Scale = self:GetViewportScale()
    end
    
    update()
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
    return uiScale
end

function SpectrumX:CreateWindow(config)
    config = config or {}
    local window = setmetatable({}, self)
    
    if PlayerGui:FindFirstChild("SpectrumX") then
        PlayerGui.SpectrumX:Destroy()
    end
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SpectrumX"
    self.ScreenGui.Parent = PlayerGui
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.DisplayOrder = 999
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Position = config.Position or UDim2.new(0.5, -250, 0.5, -160)
    self.MainFrame.Size = config.Size or UDim2.new(0, 500, 0, 320)
    self.MainFrame.Active = true
    self.MainFrame.Visible = true
    self.MainFrame.Parent = self.ScreenGui
    
    self:CreateCorner(self.MainFrame, UDim.new(0, 8))
    self:CreateShadow(self.MainFrame)
    self:CreateStroke(self.MainFrame, self.Theme.Border, 1, 0)
    
    -- Make it responsive
    self:SetupScaling(self.MainFrame)
    
    self.Header = Instance.new("Frame")
    self.Header.Name = "Header"
    self.Header.BackgroundColor3 = self.Theme.Header
    self.Header.BorderSizePixel = 0
    self.Header.Size = UDim2.new(1, 0, 0, 40)
    self.Header.Parent = self.MainFrame
    self:CreateCorner(self.Header, UDim.new(0, 8))
    
    local headerCover = Instance.new("Frame")
    headerCover.BorderSizePixel = 0
    headerCover.BackgroundColor3 = self.Theme.Header
    headerCover.Size = UDim2.new(1, 0, 0, 8)
    headerCover.Position = UDim2.new(0, 0, 1, -8)
    headerCover.Parent = self.Header
    self:CreateSeparator(self.Header).Position = UDim2.new(0, 0, 1, -1)
    
    local iconVal = config.Icon or "S"
    local isAssetId = tostring(iconVal):match("rbxassetid://") or tonumber(iconVal)
    
    if isAssetId then
        local titleIcon = Instance.new("ImageLabel")
        titleIcon.Name = "TitleIcon"
        titleIcon.BackgroundTransparency = 1
        titleIcon.Position = UDim2.new(0, 12, 0, 8)
        titleIcon.Size = UDim2.new(0, 24, 0, 24)
        titleIcon.Image = tonumber(iconVal) and "rbxassetid://"..iconVal or iconVal
        titleIcon.ImageColor3 = self.Theme.Accent
        titleIcon.Parent = self.Header
    else
        local titleIcon = Instance.new("TextLabel")
        titleIcon.Name = "TitleIcon"
        titleIcon.BackgroundTransparency = 1
        titleIcon.Position = UDim2.new(0, 12, 0, 0)
        titleIcon.Size = UDim2.new(0, 24, 1, 0)
        titleIcon.Font = Enum.Font.GothamBlack
        titleIcon.Text = iconVal
        titleIcon.TextColor3 = self.Theme.Accent
        titleIcon.TextSize = 18
        titleIcon.Parent = self.Header
    end
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 42, 0, 0)
    title.Size = UDim2.new(0, 300, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title or "Spectrum X"
    title.TextColor3 = self.Theme.Text
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self.Header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = self.Theme.TextMuted
    closeBtn.TextSize = 14
    closeBtn.Parent = self.Header
    
    closeBtn.MouseEnter:Connect(function() self:Tween(closeBtn, {TextColor3 = self.Theme.Text}, 0.2) end)
    closeBtn.MouseLeave:Connect(function() self:Tween(closeBtn, {TextColor3 = self.Theme.TextMuted}, 0.2) end)
    closeBtn.MouseButton1Click:Connect(function() self.MainFrame.Visible = false end)
    
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.BackgroundColor3 = self.Theme.Sidebar
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Position = UDim2.new(0, 0, 0, 40)
    self.Sidebar.Size = UDim2.new(0, 45, 1, -40)
    self.Sidebar.Parent = self.MainFrame
    self:CreateCorner(self.Sidebar, UDim.new(0, 8))
    
    local sidebarCover = Instance.new("Frame")
    sidebarCover.BackgroundColor3 = self.Theme.Sidebar
    sidebarCover.BorderSizePixel = 0
    sidebarCover.Size = UDim2.new(1, 0, 0, 8)
    sidebarCover.Parent = self.Sidebar
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 6)
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.Parent = self.Sidebar
    
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 8)
    sidebarPadding.Parent = self.Sidebar
    
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Position = UDim2.new(0, 52, 0, 48)
    self.ContentArea.Size = UDim2.new(1, -60, 1, -56)
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
    self.FloatBtn.Position = UDim2.new(0, 10, 0.5, 0)
    self.FloatBtn.Size = UDim2.new(0, 40, 0, 40)
    self.FloatBtn.Image = ""
    self.FloatBtn.Parent = self.ScreenGui
    self:CreateCorner(self.FloatBtn, UDim.new(0, 10))
    self:SetupScaling(self.FloatBtn)
    
    local floatText = Instance.new("TextLabel")
    floatText.BackgroundTransparency = 1
    floatText.Size = UDim2.new(1, 0, 1, 0)
    floatText.Font = Enum.Font.GothamBlack
    floatText.Text = "S"
    floatText.TextColor3 = self.Theme.Text
    floatText.TextSize = 20
    floatText.Parent = self.FloatBtn
    
    local floatStroke = Instance.new("UIStroke")
    floatStroke.Color = Color3.fromRGB(0, 0, 0)
    floatStroke.Thickness = 2
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            fDragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == fDragInput and fDragging then
            local delta = input.Position - fDragStart
            self.FloatBtn.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
        end
    end)
    
    self.FloatBtn.MouseButton1Click:Connect(function()
        if not fDragging then
            self.MainFrame.Visible = not self.MainFrame.Visible
        end
    end)
end

function SpectrumX:CreateTab(config)
    config = config or {}
    local tabId = config.Name or "Tab"
    local tabIcon = config.Icon or string.sub(tabId, 1, 1)
    local isAssetId = tostring(tabIcon):match("rbxassetid://") or tonumber(tabIcon)
    
    local tabBtn
    if isAssetId then
        tabBtn = Instance.new("ImageButton")
        tabBtn.Name = tabId .. "Tab"
        tabBtn.BackgroundColor3 = self.Theme.Card
        tabBtn.Size = UDim2.new(0, 32, 0, 32)
        tabBtn.Image = tonumber(tabIcon) and "rbxassetid://"..tabIcon or tabIcon
        tabBtn.ImageColor3 = self.Theme.TextMuted
        tabBtn.Parent = self.Sidebar
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 6)
        padding.PaddingBottom = UDim.new(0, 6)
        padding.PaddingLeft = UDim.new(0, 6)
        padding.PaddingRight = UDim.new(0, 6)
        padding.Parent = tabBtn
    else
        tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabId .. "Tab"
        tabBtn.BackgroundColor3 = self.Theme.Card
        tabBtn.Size = UDim2.new(0, 32, 0, 32)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.Text = tabIcon
        tabBtn.TextColor3 = self.Theme.TextMuted
        tabBtn.TextSize = 14
        tabBtn.Parent = self.Sidebar
    end
    self:CreateCorner(tabBtn, UDim.new(0, 6))
    
    local pageContainer = Instance.new("Frame")
    pageContainer.Name = tabId .. "PageContainer"
    pageContainer.BackgroundTransparency = 1
    pageContainer.Size = UDim2.new(1, 0, 1, 0)
    pageContainer.Visible = false
    pageContainer.Parent = self.ContentArea
    
    local leftSide = Instance.new("ScrollingFrame")
    leftSide.Name = "LeftSide"
    leftSide.BackgroundTransparency = 1
    leftSide.BorderSizePixel = 0
    leftSide.Size = UDim2.new(0.49, 0, 1, 0)
    leftSide.ScrollBarThickness = 2
    leftSide.ScrollBarImageColor3 = self.Theme.Border
    leftSide.Parent = pageContainer
    
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Padding = UDim.new(0, 8)
    leftLayout.Parent = leftSide
    
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        leftSide.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 10)
    end)
    
    local rightSide = Instance.new("ScrollingFrame")
    rightSide.Name = "RightSide"
    rightSide.BackgroundTransparency = 1
    rightSide.BorderSizePixel = 0
    rightSide.Position = UDim2.new(0.51, 0, 0, 0)
    rightSide.Size = UDim2.new(0.49, 0, 1, 0)
    rightSide.ScrollBarThickness = 2
    rightSide.ScrollBarImageColor3 = self.Theme.Border
    rightSide.Parent = pageContainer
    
    local rightLayout = Instance.new("UIListLayout")
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Padding = UDim.new(0, 8)
    rightLayout.Parent = rightSide
    
    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        rightSide.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 10)
    end)
    
    local tabData = { Button = tabBtn, Container = pageContainer, Left = leftSide, Right = rightSide }
    self.Tabs[tabId] = tabData
    
    tabBtn.MouseButton1Click:Connect(function() self:SelectTab(tabId) end)
    if not self.CurrentTab then self:SelectTab(tabId) end
    
    return tabData
end

function SpectrumX:SelectTab(tabId)
    for id, data in pairs(self.Tabs) do
        if id == tabId then
            data.Container.Visible = true
            if data.Button:IsA("ImageButton") then
                self:Tween(data.Button, {BackgroundColor3 = self.Theme.Accent, ImageColor3 = self.Theme.Text}, 0.2)
            else
                self:Tween(data.Button, {BackgroundColor3 = self.Theme.Accent, TextColor3 = self.Theme.Text}, 0.2)
            end
        else
            data.Container.Visible = false
            if data.Button:IsA("ImageButton") then
                self:Tween(data.Button, {BackgroundColor3 = self.Theme.Card, ImageColor3 = self.Theme.TextMuted}, 0.2)
            else
                self:Tween(data.Button, {BackgroundColor3 = self.Theme.Card, TextColor3 = self.Theme.TextMuted}, 0.2)
            end
        end
    end
    self.CurrentTab = tabId
end

function SpectrumX:CreateSection(parent, text, color)
    local section = Instance.new("TextLabel")
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, 0, 0, 20)
    section.Font = Enum.Font.GothamBold
    section.Text = text
    section.TextColor3 = color or self.Theme.Accent
    section.TextSize = 12
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
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local switchBg = Instance.new("TextButton")
    switchBg.Text = ""
    switchBg.BackgroundColor3 = default and self.Theme.ToggleOn or self.Theme.ToggleOff
    switchBg.Position = UDim2.new(1, -42, 0.5, -9)
    switchBg.Size = UDim2.new(0, 32, 0, 18)
    switchBg.Parent = frame
    self:CreateCorner(switchBg, UDim.new(1, 0))
    
    local circle = Instance.new("Frame")
    circle.BackgroundColor3 = self.Theme.Text
    circle.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Parent = switchBg
    self:CreateCorner(circle, UDim.new(1, 0))
    
    local state = default
    local function update(newState)
        state = newState
        callback(state)
        if state then
            self:Tween(switchBg, {BackgroundColor3 = self.Theme.ToggleOn}, 0.2)
            self:Tween(circle, {Position = UDim2.new(1, -16, 0.5, -7)}, 0.2)
        else
            self:Tween(switchBg, {BackgroundColor3 = self.Theme.ToggleOff}, 0.2)
            self:Tween(circle, {Position = UDim2.new(0, 2, 0.5, -7)}, 0.2)
        end
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
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local btn = Instance.new("TextButton")
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextSize = 12
    btn.Parent = frame
    
    local color = self.Theme.Text
    if style == "warning" then color = self.Theme.Warning
    elseif style == "info" then color = self.Theme.Info
    elseif style == "accent" then color = self.Theme.Accent end
    btn.TextColor3 = color
    
    local btnStroke = self:CreateStroke(frame, self.Theme.Border, 1, 0)
    
    btn.MouseEnter:Connect(function() self:Tween(frame, {BackgroundColor3 = self.Theme.Input}, 0.15) end)
    btn.MouseLeave:Connect(function() self:Tween(frame, {BackgroundColor3 = self.Theme.Card}, 0.15) end)
    btn.MouseButton1Click:Connect(callback)
    
    return { Frame = frame, Button = btn, SetText = function(t) btn.Text = t end }
end

function SpectrumX:CreateInput(parent, config)
    config = config or {}
    local labelText = config.Label or "Input"
    local default = config.Default or ""
    local placeholder = config.Placeholder or ""
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, 46)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 8, 0, 2)
    label.Size = UDim2.new(1, -16, 0, 16)
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local box = Instance.new("TextBox")
    box.BackgroundColor3 = self.Theme.Input
    box.Position = UDim2.new(0, 8, 0, 18)
    box.Size = UDim2.new(1, -16, 0, 22)
    box.Font = Enum.Font.Gotham
    box.Text = tostring(default)
    box.PlaceholderText = placeholder
    box.TextColor3 = self.Theme.Text
    box.TextSize = 11
    box.Parent = frame
    self:CreateCorner(box, UDim.new(0, 4))
    
    local boxStroke = self:CreateStroke(box, self.Theme.Accent, 1, 1)
    box.Focused:Connect(function() self:Tween(boxStroke, {Transparency = 0.5}, 0.2) end)
    box.FocusLost:Connect(function()
        self:Tween(boxStroke, {Transparency = 1}, 0.2)
        callback(box.Text)
    end)
    
    return { Frame = frame, TextBox = box, GetText = function() return box.Text end, SetText = function(t) box.Text = t end }
end

function SpectrumX:CreateNumberInput(parent, config)
    local input = self:CreateInput(parent, config)
    local min = config.Min or -math.huge
    local max = config.Max or math.huge
    
    input.TextBox.FocusLost:Connect(function()
        local val = tonumber(input.TextBox.Text)
        if val then
            val = math.clamp(val, min, max)
            input.TextBox.Text = tostring(val)
            if config.Callback then config.Callback(val) end
        else
            input.TextBox.Text = tostring(config.Default or 0)
        end
    end)
    return input
end

function SpectrumX:CreateSlider(parent, config)
    config = config or {}
    local text = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, 46)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 8, 0, 4)
    label.Size = UDim2.new(0.5, 0, 0, 16)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(0.5, -8, 0, 4)
    valueLabel.Size = UDim2.new(0.5, 0, 0, 16)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = self.Theme.Accent
    valueLabel.TextSize = 11
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.BackgroundColor3 = self.Theme.Input
    sliderBg.Position = UDim2.new(0, 8, 0, 26)
    sliderBg.Size = UDim2.new(1, -16, 0, 6)
    sliderBg.Parent = frame
    self:CreateCorner(sliderBg, UDim.new(1, 0))
    
    local sliderFill = Instance.new("Frame")
    sliderFill.BackgroundColor3 = self.Theme.Accent
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.Parent = sliderBg
    self:CreateCorner(sliderFill, UDim.new(1, 0))
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.BackgroundColor3 = self.Theme.Text
    sliderKnob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    sliderKnob.Size = UDim2.new(0, 12, 0, 12)
    sliderKnob.Parent = sliderBg
    self:CreateCorner(sliderKnob, UDim.new(1, 0))
    
    local dragging = false
    local currentValue = default
    
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * pos
        value = math.floor(value * 100) / 100
        currentValue = value
        
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderKnob.Position = UDim2.new(pos, -6, 0.5, -6)
        valueLabel.Text = tostring(value)
        callback(value)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return { Frame = frame, GetValue = function() return currentValue end }
end

function SpectrumX:CreateDropdownCore(parent, config, isMulti)
    local labelText = config.Label or "Dropdown"
    local options = config.Options or {}
    local default = config.Default
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 8, 0, 4)
    label.Size = UDim2.new(1, -16, 0, 16)
    label.Font = Enum.Font.GothamBold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.BackgroundColor3 = self.Theme.Input
    dropdownBtn.Position = UDim2.new(0, 8, 0, 20)
    dropdownBtn.Size = UDim2.new(1, -16, 0, 22)
    dropdownBtn.Font = Enum.Font.GothamSemibold
    dropdownBtn.Text = "  Select..."
    dropdownBtn.TextColor3 = self.Theme.TextSecondary
    dropdownBtn.TextSize = 11
    dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropdownBtn.Parent = frame
    self:CreateCorner(dropdownBtn, UDim.new(0, 4))
    
    local dropdownStroke = self:CreateStroke(dropdownBtn, self.Theme.Border, 1, 0)
    
    local arrow = Instance.new("TextLabel")
    arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Font = Enum.Font.GothamBold
    arrow.Text = "▼"
    arrow.TextColor3 = self.Theme.Accent
    arrow.TextSize = 9
    arrow.Parent = dropdownBtn
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.BackgroundColor3 = self.Theme.Card
    dropdownList.Size = UDim2.new(0, 200, 0, 0)
    dropdownList.ScrollBarThickness = 2
    dropdownList.Visible = false
    dropdownList.ZIndex = 2000
    dropdownList.BorderSizePixel = 0
    dropdownList.Parent = self.ScreenGui
    self:CreateCorner(dropdownList, UDim.new(0, 6))
    self:CreateStroke(dropdownList, self.Theme.Border, 1, 0)
    
    local listScale = self:SetupScaling(dropdownList)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = dropdownList
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 4)
    listPadding.PaddingBottom = UDim.new(0, 4)
    listPadding.PaddingLeft = UDim.new(0, 4)
    listPadding.PaddingRight = UDim.new(0, 4)
    listPadding.Parent = dropdownList
    
    local isOpen = false
    local renderConn
    local selectedValue = isMulti and {} or default
    
    if isMulti and default then
        for _, v in ipairs(default) do table.insert(selectedValue, v) end
    end
    
    local function updateText()
        if isMulti then
            if #selectedValue == 0 then dropdownBtn.Text = "  Select..."
            elseif #selectedValue == 1 then dropdownBtn.Text = "  " .. selectedValue[1]
            else dropdownBtn.Text = "  " .. #selectedValue .. " selected" end
        else
            dropdownBtn.Text = "  " .. (selectedValue or "Select...")
        end
    end
    updateText()
    
    local function close()
        isOpen = false
        if renderConn then renderConn:Disconnect() end
        self:Tween(dropdownList, {Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X / listScale.Scale, 0, 0)}, 0.2)
        self:Tween(arrow, {Rotation = 0}, 0.2)
        task.wait(0.2)
        dropdownList.Visible = false
    end
    
    local function populate()
        for _, c in ipairs(dropdownList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        
        for _, opt in ipairs(options) do
            local isSel = false
            if isMulti then
                for _, v in ipairs(selectedValue) do if v == opt then isSel = true break end end
            else
                isSel = (opt == selectedValue)
            end
            
            local optFrame = Instance.new("Frame")
            optFrame.BackgroundColor3 = isSel and Color3.fromRGB(40, 50, 40) or self.Theme.Input
            optFrame.Size = UDim2.new(1, 0, 0, 24)
            optFrame.ZIndex = 2001
            optFrame.Parent = dropdownList
            self:CreateCorner(optFrame, UDim.new(0, 4))
            
            local btn = Instance.new("TextButton")
            btn.BackgroundTransparency = 1
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.Font = Enum.Font.GothamSemibold
            btn.Text = "  " .. (isSel and "• " or "") .. opt
            btn.TextColor3 = isSel and self.Theme.Success or self.Theme.TextSecondary
            btn.TextSize = 11
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.ZIndex = 2002
            btn.Parent = optFrame
            
            btn.MouseButton1Click:Connect(function()
                if isMulti then
                    if isSel then
                        for i, v in ipairs(selectedValue) do if v == opt then table.remove(selectedValue, i) break end end
                    else
                        table.insert(selectedValue, opt)
                    end
                    updateText()
                    callback(selectedValue)
                    populate()
                else
                    selectedValue = opt
                    updateText()
                    callback(opt)
                    close()
                end
            end)
        end
        
        local h = math.min(listLayout.AbsoluteContentSize.Y + 8, 160)
        self:Tween(dropdownList, {Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X / listScale.Scale, 0, h)}, 0.2)
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
    end
    
    local function updatePos()
        if not dropdownBtn.Parent then return end
        local vp = workspace.CurrentCamera.ViewportSize
        local ap = dropdownBtn.AbsolutePosition
        local as = dropdownBtn.AbsoluteSize
        local th = dropdownList.Size.Y.Offset * listScale.Scale
        if ap.Y + as.Y + th + 10 > vp.Y then
            dropdownList.Position = UDim2.fromOffset(ap.X, ap.Y - th - 2)
        else
            dropdownList.Position = UDim2.fromOffset(ap.X, ap.Y + as.Y + 2)
        end
    end
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if isOpen then close() return end
        for _, c in ipairs(self.ScreenGui:GetChildren()) do
            if c:IsA("ScrollingFrame") and c ~= dropdownList then c.Visible = false end
        end
        
        dropdownList.Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X / listScale.Scale, 0, 0)
        dropdownList.Visible = true
        isOpen = true
        updatePos()
        renderConn = RunService.RenderStepped:Connect(updatePos)
        populate()
        self:Tween(arrow, {Rotation = 180}, 0.2)
    end)
    
    return { Frame = frame }
end

function SpectrumX:CreateDropdown(parent, config) return self:CreateDropdownCore(parent, config, false) end
function SpectrumX:CreateMultiDropdown(parent, config) return self:CreateDropdownCore(parent, config, true) end

function SpectrumX:CreateCheckbox(parent, config)
    config = config or {}
    local text = config.Text or "Checkbox"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local check = Instance.new("TextButton")
    check.BackgroundColor3 = default and self.Theme.Accent or self.Theme.Input
    check.Position = UDim2.new(0, 8, 0.5, -8)
    check.Size = UDim2.new(0, 16, 0, 16)
    check.Font = Enum.Font.GothamBold
    check.Text = default and "✓" or ""
    check.TextColor3 = self.Theme.Text
    check.TextSize = 12
    check.Parent = frame
    self:CreateCorner(check, UDim.new(0, 4))
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 32, 0, 0)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local state = default
    check.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        self:Tween(check, {BackgroundColor3 = state and self.Theme.Accent or self.Theme.Input}, 0.15)
        check.Text = state and "✓" or ""
    end)
    return { Frame = frame }
end

function SpectrumX:CreateLabel(parent, config)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = config.Size or UDim2.new(1, 0, 0, 26)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = config.Text or "Label"
    label.TextColor3 = config.Color or self.Theme.Text
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    return { Frame = frame, Label = label, SetText = function(t) label.Text = t end }
end

function SpectrumX:CreateSeparator(parent)
    local sep = Instance.new("Frame")
    sep.BackgroundColor3 = self.Theme.Border
    sep.BorderSizePixel = 0
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.Parent = parent
    return sep
end

function SpectrumX:CreateStatusCard(parent, config)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, 90)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local header = Instance.new("Frame")
    header.BackgroundColor3 = self.Theme.Header
    header.Size = UDim2.new(1, 0, 0, 28)
    header.Parent = frame
    self:CreateCorner(header)
    
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 8, 0, 0)
    title.Size = UDim2.new(1, -16, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title or "Status"
    title.TextColor3 = self.Theme.Text
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Position = UDim2.new(0, 8, 0, 34)
    status.Size = UDim2.new(1, -16, 0, 16)
    status.Font = Enum.Font.GothamSemibold
    status.Text = "● Idle"
    status.TextColor3 = self.Theme.TextMuted
    status.TextSize = 11
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame
    
    local info = Instance.new("TextLabel")
    info.BackgroundTransparency = 1
    info.Position = UDim2.new(0, 8, 0, 52)
    info.Size = UDim2.new(1, -16, 0, 16)
    info.Font = Enum.Font.Gotham
    info.Text = "Ready"
    info.TextColor3 = self.Theme.TextSecondary
    info.TextSize = 10
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = frame
    
    local loadingBg = Instance.new("Frame")
    loadingBg.BackgroundColor3 = self.Theme.Input
    loadingBg.Position = UDim2.new(0, 8, 1, -12)
    loadingBg.Size = UDim2.new(1, -16, 0, 4)
    loadingBg.Parent = frame
    self:CreateCorner(loadingBg)
    
    local loadingFill = Instance.new("Frame")
    loadingFill.BackgroundColor3 = self.Theme.Accent
    loadingFill.Size = UDim2.new(0, 0, 1, 0)
    loadingFill.Parent = loadingBg
    self:CreateCorner(loadingFill)
    
    return {
        Frame = frame,
        SetStatus = function(txt, color) status.Text = "● " .. txt; status.TextColor3 = color or self.Theme.TextMuted end,
        SetInfo = function(txt) info.Text = txt end,
        AnimateLoading = function(active)
            if active then
                spawn(function()
                    while active and frame.Parent do
                        self:Tween(loadingFill, {Size = UDim2.new(1, 0, 1, 0)}, 1.5).Completed:Wait()
                        loadingFill.Size = UDim2.new(0, 0, 1, 0)
                    end
                end)
            else loadingFill.Size = UDim2.new(0, 0, 1, 0) end
        end
    }
end

function SpectrumX:Notify(config)
    local notification = Instance.new("Frame")
    notification.BackgroundColor3 = self.Theme.Card
    notification.Position = UDim2.new(1, 300, 0.9, 0)
    notification.Size = UDim2.new(0, 250, 0, 50)
    notification.Parent = self.ScreenGui
    self:CreateCorner(notification)
    
    local type = config.Type or "info"
    local color = type == "success" and self.Theme.Success or type == "warning" and self.Theme.Warning or type == "error" and Color3.fromRGB(255, 50, 50) or self.Theme.Info
    self:CreateStroke(notification, color, 1, 0.2)
    
    local icon = Instance.new("TextLabel")
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(0, 8, 0, 0)
    icon.Size = UDim2.new(0, 24, 1, 0)
    icon.Font = Enum.Font.GothamBlack
    icon.Text = type == "success" and "✓" or type == "warning" and "!" or type == "error" and "✕" or "i"
    icon.TextColor3 = color
    icon.TextSize = 18
    icon.Parent = notification
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 36, 0, 0)
    label.Size = UDim2.new(1, -44, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = config.Text or "Notification"
    label.TextColor3 = self.Theme.Text
    label.TextSize = 12
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = notification
    
    self:SetupScaling(notification)
    
    self:Tween(notification, {Position = UDim2.new(1, -260, 0.9, 0)}, 0.4)
    task.delay(config.Duration or 3, function()
        if notification.Parent then
            self:Tween(notification, {Position = UDim2.new(1, 300, 0.9, 0)}, 0.4)
            task.wait(0.4)
            notification:Destroy()
        end
    end)
end

function SpectrumX:Destroy()
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

return SpectrumX

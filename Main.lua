--[[
    SpectrumX UI Library - Remastered v3.0 (Mobile-First)
    Foco em mobile, simétrica e visualmente refinada
--]]

local SpectrumX = {}
SpectrumX.__index = SpectrumX

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Theme - Visual refinado
SpectrumX.Theme = {
    Background = Color3.fromRGB(22, 22, 28),
    Header = Color3.fromRGB(28, 28, 36),
    Sidebar = Color3.fromRGB(28, 28, 36),
    Content = Color3.fromRGB(22, 22, 28),
    Card = Color3.fromRGB(35, 35, 45),
    Input = Color3.fromRGB(45, 45, 58),
    Accent = Color3.fromRGB(255, 65, 65),
    AccentSecondary = Color3.fromRGB(255, 130, 130),
    Text = Color3.fromRGB(250, 250, 250),
    TextSecondary = Color3.fromRGB(180, 180, 190),
    TextMuted = Color3.fromRGB(130, 130, 140),
    Success = Color3.fromRGB(85, 230, 130),
    Warning = Color3.fromRGB(255, 200, 90),
    Info = Color3.fromRGB(100, 180, 255),
    Border = Color3.fromRGB(50, 50, 65),
    ToggleOff = Color3.fromRGB(60, 60, 75),
    ToggleOn = Color3.fromRGB(255, 65, 65)
}

-- Responsive Settings - Mobile First
local ScaleData = {
    IsMobile = false,
    ScaleFactor = 1,
    BaseWidth = 1920,
    BaseHeight = 1080
}

function SpectrumX:UpdateScale()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local width, height = viewportSize.X, viewportSize.Y
    
    -- Detect mobile (touch + smaller screen)
    ScaleData.IsMobile = UserInputService.TouchEnabled and (width < 1200 or height < 700)
    
    -- Scale calculation - mais conservador
    local scaleX = width / ScaleData.BaseWidth
    local scaleY = height / ScaleData.BaseHeight
    local baseScale = math.min(scaleX, scaleY)
    
    -- Mobile: 0.9-1.1 | PC: 0.85-1.0
    if ScaleData.IsMobile then
        ScaleData.ScaleFactor = math.clamp(baseScale, 0.9, 1.15)
    else
        ScaleData.ScaleFactor = math.clamp(baseScale, 0.85, 1.0)
    end
end

function SpectrumX:Scale(value)
    if typeof(value) == "number" then
        return math.floor(value * ScaleData.ScaleFactor)
    elseif typeof(value) == "UDim2" then
        return UDim2.new(
            value.X.Scale, 
            math.floor(value.X.Offset * ScaleData.ScaleFactor),
            value.Y.Scale, 
            math.floor(value.Y.Offset * ScaleData.ScaleFactor)
        )
    end
    return value
end

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
    stroke.Color = color or self.Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.85
    stroke.Parent = parent
    return stroke
end

function SpectrumX:CreateShadow(parent, size)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = self:Scale(UDim2.new(1, size or 50, 1, size or 50))
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.55
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
end

-- Main Window - MAIS GRANDE E SIMÉTRICA
function SpectrumX:CreateWindow(config)
    config = config or {}
    local window = setmetatable({}, self)
    
    self:UpdateScale()
    
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
    
    -- Tamanhos maiores e simétricos
    local defaultSize, defaultPos
    if ScaleData.IsMobile then
        -- Mobile: UI grande e confortável
        defaultSize = UDim2.new(0, 420, 0, 580)  -- Mais alta que larga (portrait-friendly)
        defaultPos = UDim2.new(0.5, -210, 0.5, -290)
    else
        -- PC: Proporção widescreen
        defaultSize = UDim2.new(0, 640, 0, 420)
        defaultPos = UDim2.new(0.5, -320, 0.5, -210)
    end
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Position = config.Position or self:Scale(defaultPos)
    self.MainFrame.Size = config.Size or self:Scale(defaultSize)
    self.MainFrame.Active = true
    self.MainFrame.Visible = true
    self.MainFrame.Parent = self.ScreenGui
    
    self:CreateCorner(self.MainFrame, UDim.new(0, 14))
    self:CreateShadow(self.MainFrame, 60)
    self:CreateStroke(self.MainFrame, self.Theme.Accent, 2, 0.6)
    
    -- Header - Maior e mais espaçoso
    self.Header = Instance.new("Frame")
    self.Header.Name = "Header"
    self.Header.BackgroundColor3 = self.Theme.Header
    self.Header.BorderSizePixel = 0
    self.Header.Size = UDim2.new(1, 0, 0, self:Scale(60))
    self.Header.Parent = self.MainFrame
    
    self:CreateCorner(self.Header, UDim.new(0, 14))
    
    local headerCover = Instance.new("Frame")
    headerCover.BorderSizePixel = 0
    headerCover.BackgroundColor3 = self.Theme.Header
    headerCover.Size = UDim2.new(1, 0, 0, 14)
    headerCover.Position = UDim2.new(0, 0, 1, -14)
    headerCover.Parent = self.Header
    
    -- Title Icon - Suporte a AssetId
    if config.IconAssetId and config.IconAssetId ~= "" then
        local titleIcon = Instance.new("ImageLabel")
        titleIcon.Name = "TitleIcon"
        titleIcon.BackgroundTransparency = 1
        titleIcon.Position = self:Scale(UDim2.new(0, 16, 0, 12))
        titleIcon.Size = self:Scale(UDim2.new(0, 36, 0, 36))
        titleIcon.Image = config.IconAssetId
        titleIcon.Parent = self.Header
        
        local aspect = Instance.new("UIAspectRatioConstraint")
        aspect.Parent = titleIcon
    else
        local titleIcon = Instance.new("TextLabel")
        titleIcon.Name = "TitleIcon"
        titleIcon.BackgroundTransparency = 1
        titleIcon.Position = self:Scale(UDim2.new(0, 16, 0, 10))
        titleIcon.Size = self:Scale(UDim2.new(0, 40, 0, 40))
        titleIcon.Font = Enum.Font.GothamBlack
        titleIcon.Text = config.Icon or "S"
        titleIcon.TextColor3 = self.Theme.Accent
        titleIcon.TextSize = self:Scale(26)
        titleIcon.Parent = self.Header
    end
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = self:Scale(UDim2.new(0, 64, 0, 0))
    title.Size = self:Scale(UDim2.new(0, 350, 1, 0))
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title or "Spectrum X"
    title.TextColor3 = self.Theme.Text
    title.TextSize = self:Scale(20)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self.Header
    
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, self.Theme.Text),
        ColorSequenceKeypoint.new(1, self.Theme.AccentSecondary)
    }
    titleGradient.Parent = title
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position = UDim2.new(1, -48, 0.5, -14)
    closeBtn.Size = UDim2.new(0, 32, 0, 28)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "—"
    closeBtn.TextColor3 = self.Theme.TextMuted
    closeBtn.TextSize = self:Scale(18)
    closeBtn.Parent = self.Header
    
    closeBtn.MouseEnter:Connect(function() 
        self:Tween(closeBtn, {TextColor3 = self.Theme.Text}, 0.2) 
    end)
    closeBtn.MouseLeave:Connect(function() 
        self:Tween(closeBtn, {TextColor3 = self.Theme.TextMuted}, 0.2) 
    end)
    closeBtn.MouseButton1Click:Connect(function() 
        self.MainFrame.Visible = false 
    end)
    
    -- Sidebar - Mais larga
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.BackgroundColor3 = self.Theme.Sidebar
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Position = UDim2.new(0, 0, 0, self:Scale(60))
    self.Sidebar.Size = UDim2.new(0, self:Scale(65), 1, -self:Scale(60))
    self.Sidebar.Parent = self.MainFrame
    
    self:CreateCorner(self.Sidebar, UDim.new(0, 14))
    
    local sidebarCover = Instance.new("Frame")
    sidebarCover.BackgroundColor3 = self.Theme.Sidebar
    sidebarCover.BorderSizePixel = 0
    sidebarCover.Size = UDim2.new(1, 0, 0, 14)
    sidebarCover.Parent = self.Sidebar
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 12)
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.Parent = self.Sidebar
    
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 16)
    sidebarPadding.Parent = self.Sidebar
    
    -- Content Area - Simétrico
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Position = self:Scale(UDim2.new(0, 75, 0, 72))
    self.ContentArea.Size = UDim2.new(1, -self:Scale(85), 1, -self:Scale(82))
    self.ContentArea.Parent = self.MainFrame
    
    self.Tabs = {}
    self.CurrentTab = nil
    self.Dropdowns = {}
    
    self:MakeDraggable(self.MainFrame, self.Header)
    self:CreateFloatingButton()
    
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        self:UpdateScale()
    end)
    
    return window
end

-- Floating Button - Maior
function SpectrumX:CreateFloatingButton()
    local btnSize = self:Scale(55)
    
    self.FloatBtn = Instance.new("ImageButton")
    self.FloatBtn.Name = "FloatBtn"
    self.FloatBtn.BackgroundColor3 = self.Theme.Accent
    self.FloatBtn.Position = UDim2.new(0, 20, 0.5, 0)
    self.FloatBtn.Size = UDim2.new(0, btnSize, 0, btnSize)
    self.FloatBtn.Image = ""
    self.FloatBtn.Parent = self.ScreenGui
    self:CreateCorner(self.FloatBtn, UDim.new(0, 16))
    
    -- Suporte a AssetId no botão flutuante
    if self.FloatIconAssetId then
        local icon = Instance.new("ImageLabel")
        icon.BackgroundTransparency = 1
        icon.Size = UDim2.new(0.6, 0, 0.6, 0)
        icon.Position = UDim2.new(0.2, 0, 0.2, 0)
        icon.Image = self.FloatIconAssetId
        icon.Parent = self.FloatBtn
    else
        local floatText = Instance.new("TextLabel")
        floatText.BackgroundTransparency = 1
        floatText.Size = UDim2.new(1, 0, 1, 0)
        floatText.Font = Enum.Font.GothamBlack
        floatText.Text = "S"
        floatText.TextColor3 = self.Theme.Text
        floatText.TextSize = self:Scale(22)
        floatText.Parent = self.FloatBtn
    end
    
    local floatStroke = Instance.new("UIStroke")
    floatStroke.Color = Color3.fromRGB(0, 0, 0)
    floatStroke.Thickness = 2
    floatStroke.Transparency = 0.4
    floatStroke.Parent = self.FloatBtn
    
    local fDragging, fDragInput, fDragStart, fStartPos
    
    local function updateFloat(input)
        local delta = input.Position - fDragStart
        self.FloatBtn.Position = UDim2.new(
            fStartPos.X.Scale, 
            fStartPos.X.Offset + delta.X, 
            fStartPos.Y.Scale, 
            fStartPos.Y.Offset + delta.Y
        )
    end
    
    self.FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            fDragging = true
            fDragStart = input.Position
            fStartPos = self.FloatBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    fDragging = false
                end
            end)
        end
    end)
    
    self.FloatBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            fDragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == fDragInput and fDragging then
            updateFloat(input)
        end
    end)
    
    self.FloatBtn.MouseButton1Click:Connect(function()
        if not fDragging then
            self.MainFrame.Visible = not self.MainFrame.Visible
        end
    end)
end

-- Create Tab - Suporte a AssetId
function SpectrumX:CreateTab(config)
    config = config or {}
    local tabId = config.Name or "Tab"
    local tabIcon = config.Icon or string.sub(tabId, 1, 1)
    
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabId .. "Tab"
    tabBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 55)
    tabBtn.Size = UDim2.new(0, self:Scale(48), 0, self:Scale(48))
    tabBtn.Text = ""
    tabBtn.Parent = self.Sidebar
    self:CreateCorner(tabBtn, UDim.new(0, 12))
    
    -- Suporte a AssetId nas tabs
    if config.IconAssetId and config.IconAssetId ~= "" then
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.new(0.5, -12, 0.5, -12)
        icon.Size = UDim2.new(0, 24, 0, 24)
        icon.Image = config.IconAssetId
        icon.Parent = tabBtn
        
        local aspect = Instance.new("UIAspectRatioConstraint")
        aspect.Parent = icon
    else
        local icon = Instance.new("TextLabel")
        icon.Name = "Icon"
        icon.BackgroundTransparency = 1
        icon.Size = UDim2.new(1, 0, 1, 0)
        icon.Font = Enum.Font.GothamBold
        icon.Text = tabIcon
        icon.TextColor3 = self.Theme.TextMuted
        icon.TextSize = self:Scale(18)
        icon.Parent = tabBtn
    end
    
    local pageContainer = Instance.new("Frame")
    pageContainer.Name = tabId .. "PageContainer"
    pageContainer.BackgroundTransparency = 1
    pageContainer.Size = UDim2.new(1, 0, 1, 0)
    pageContainer.Visible = false
    pageContainer.Parent = self.ContentArea
    
    -- Divisor central simétrico
    local divider = Instance.new("Frame")
    divider.BackgroundColor3 = self.Theme.Border
    divider.BorderSizePixel = 0
    divider.Position = UDim2.new(0.5, -1, 0, 0)
    divider.Size = UDim2.new(0, 2, 1, 0)
    divider.Parent = pageContainer
    
    -- Left Side
    local leftSide = Instance.new("ScrollingFrame")
    leftSide.Name = "LeftSide"
    leftSide.BackgroundTransparency = 1
    leftSide.BorderSizePixel = 0
    leftSide.Size = UDim2.new(0.48, 0, 1, 0)
    leftSide.ScrollBarThickness = 3
    leftSide.ScrollBarImageColor3 = self.Theme.Accent
    leftSide.Parent = pageContainer
    
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Padding = UDim.new(0, 12)
    leftLayout.Parent = leftSide
    
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        leftSide.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 15)
    end)
    
    -- Right Side
    local rightSide = Instance.new("ScrollingFrame")
    rightSide.Name = "RightSide"
    rightSide.BackgroundTransparency = 1
    rightSide.BorderSizePixel = 0
    rightSide.Position = UDim2.new(0.52, 0, 0, 0)
    rightSide.Size = UDim2.new(0.48, 0, 1, 0)
    rightSide.ScrollBarThickness = 3
    rightSide.ScrollBarImageColor3 = self.Theme.Accent
    rightSide.Parent = pageContainer
    
    local rightLayout = Instance.new("UIListLayout")
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Padding = UDim.new(0, 12)
    rightLayout.Parent = rightSide
    
    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        rightSide.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 15)
    end)
    
    local tabData = {
        Button = tabBtn,
        Container = pageContainer,
        Left = leftSide,
        Right = rightSide
    }
    self.Tabs[tabId] = tabData
    
    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(tabId)
    end)
    
    if not self.CurrentTab then
        self:SelectTab(tabId)
    end
    
    return tabData
end

-- Select Tab
function SpectrumX:SelectTab(tabId)
    for id, data in pairs(self.Tabs) do
        local icon = data.Button:FindFirstChild("Icon")
        if id == tabId then
            data.Container.Visible = true
            self:Tween(data.Button, {BackgroundColor3 = self.Theme.Accent}, 0.2)
            if icon and icon:IsA("TextLabel") then
                self:Tween(icon, {TextColor3 = self.Theme.Text}, 0.2)
            end
        else
            data.Container.Visible = false
            self:Tween(data.Button, {BackgroundColor3 = Color3.fromRGB(42, 42, 55)}, 0.2)
            if icon and icon:IsA("TextLabel") then
                self:Tween(icon, {TextColor3 = self.Theme.TextMuted}, 0.2)
            end
        end
    end
    self.CurrentTab = tabId
end

-- Create Section Title
function SpectrumX:CreateSection(parent, text, color)
    local section = Instance.new("TextLabel")
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, 0, 0, self:Scale(28))
    section.Font = Enum.Font.GothamBold
    section.Text = text
    section.TextColor3 = color or self.Theme.Accent
    section.TextSize = self:Scale(14)
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = parent
    return section
end

-- Create Toggle - Proporcional
function SpectrumX:CreateToggle(parent, config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, self:Scale(50))
    frame.Parent = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 16, 0, 0)
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    -- Toggle track
    local switchBg = Instance.new("TextButton")
    switchBg.Text = ""
    switchBg.BackgroundColor3 = default and self.Theme.ToggleOn or self.Theme.ToggleOff
    switchBg.Position = UDim2.new(1, -58, 0.5, -12)
    switchBg.Size = UDim2.new(0, 46, 0, self:Scale(24))
    switchBg.Parent = frame
    self:CreateCorner(switchBg, UDim.new(1, 0))
    
    -- Knob proporcional
    local circle = Instance.new("Frame")
    circle.BackgroundColor3 = self.Theme.Text
    circle.Position = default and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Parent = switchBg
    self:CreateCorner(circle, UDim.new(1, 0))
    
    local state = default
    
    switchBg.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        
        if state then
            self:Tween(switchBg, {BackgroundColor3 = self.Theme.ToggleOn}, 0.2)
            self:Tween(circle, {Position = UDim2.new(1, -22, 0.5, -9)}, 0.2)
        else
            self:Tween(switchBg, {BackgroundColor3 = self.Theme.ToggleOff}, 0.2)
            self:Tween(circle, {Position = UDim2.new(0, 3, 0.5, -9)}, 0.2)
        end
    end)
    
    return {
        Frame = frame,
        GetState = function() return state end,
        SetState = function(newState)
            state = newState
            callback(state)
            if state then
                self:Tween(switchBg, {BackgroundColor3 = self.Theme.ToggleOn}, 0.2)
                self:Tween(circle, {Position = UDim2.new(1, -22, 0.5, -9)}, 0.2)
            else
                self:Tween(switchBg, {BackgroundColor3 = self.Theme.ToggleOff}, 0.2)
                self:Tween(circle, {Position = UDim2.new(0, 3, 0.5, -9)}, 0.2)
            end
        end
    }
end

-- Create Button
function SpectrumX:CreateButton(parent, config)
    config = config or {}
    local text = config.Text or "Button"
    local style = config.Style or "default"
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Background
    frame.Size = UDim2.new(1, 0, 0, self:Scale(52))
    frame.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Name = "Button"
    btn.BackgroundColor3 = self.Theme.Card
    btn.Position = UDim2.new(0.02, 0, 0.08, 0)
    btn.Size = UDim2.new(0.96, 0, 0.84, 0)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextSize = self:Scale(14)
    btn.Parent = frame
    self:CreateCorner(btn, UDim.new(0, 10))
    
    local color = self.Theme.Accent
    if style == "warning" then
        color = self.Theme.Warning
        btn.TextColor3 = self.Theme.Warning
    elseif style == "info" then
        color = self.Theme.Info
        btn.TextColor3 = self.Theme.Info
    elseif style == "accent" then
        btn.TextColor3 = self.Theme.Accent
    else
        btn.TextColor3 = self.Theme.Text
    end
    
    local btnStroke = self:CreateStroke(btn, color, 1, 0.85)
    
    btn.MouseEnter:Connect(function()
        self:Tween(btn, {BackgroundColor3 = Color3.fromRGB(42, 42, 55)}, 0.2)
        self:Tween(btnStroke, {Transparency = 0.5}, 0.2)
    end)
    
    btn.MouseLeave:Connect(function()
        self:Tween(btn, {BackgroundColor3 = self.Theme.Card}, 0.2)
        self:Tween(btnStroke, {Transparency = 0.85}, 0.2)
    end)
    
    btn.MouseButton1Click:Connect(function()
        callback()
    end)
    
    return {
        Frame = frame,
        Button = btn,
        SetText = function(newText) btn.Text = newText end
    }
end

-- Create Input
function SpectrumX:CreateInput(parent, config)
    config = config or {}
    local labelText = config.Label or "Input"
    local default = config.Default or ""
    local placeholder = config.Placeholder or ""
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, self:Scale(62))
    frame.Parent = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 16, 0, 0)
    label.Size = UDim2.new(0.6, 0, 0.45, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local box = Instance.new("TextBox")
    box.BackgroundColor3 = self.Theme.Input
    box.Position = UDim2.new(0.03, 0, 0.48, 0)
    box.Size = UDim2.new(0.94, 0, 0, self:Scale(30))
    box.Font = Enum.Font.Gotham
    box.Text = tostring(default)
    box.PlaceholderText = placeholder
    box.TextColor3 = self.Theme.Text
    box.TextSize = self:Scale(13)
    box.Parent = frame
    self:CreateCorner(box, UDim.new(0, 8))
    
    local boxStroke = self:CreateStroke(box, self.Theme.Accent, 1, 0.85)
    
    box.Focused:Connect(function()
        self:Tween(boxStroke, {Transparency = 0.4}, 0.2)
    end)
    
    box.FocusLost:Connect(function()
        self:Tween(boxStroke, {Transparency = 0.85}, 0.2)
        callback(box.Text)
    end)
    
    return {
        Frame = frame,
        TextBox = box,
        GetText = function() return box.Text end,
        SetText = function(text) box.Text = text end
    }
end

-- Create Number Input
function SpectrumX:CreateNumberInput(parent, config)
    config = config or {}
    local labelText = config.Label or "Number"
    local default = config.Default or 0
    local min = config.Min or -math.huge
    local max = config.Max or math.huge
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, self:Scale(62))
    frame.Parent = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 16, 0, 0)
    label.Size = UDim2.new(0.6, 0, 0.45, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local box = Instance.new("TextBox")
    box.BackgroundColor3 = self.Theme.Input
    box.Position = UDim2.new(0.03, 0, 0.48, 0)
    box.Size = UDim2.new(0.94, 0, 0, self:Scale(30))
    box.Font = Enum.Font.Gotham
    box.Text = tostring(default)
    box.TextColor3 = self.Theme.Text
    box.TextSize = self:Scale(13)
    box.Parent = frame
    self:CreateCorner(box, UDim.new(0, 8))
    
    local boxStroke = self:CreateStroke(box, self.Theme.Accent, 1, 0.85)
    
    box.Focused:Connect(function()
        self:Tween(boxStroke, {Transparency = 0.4}, 0.2)
    end)
    
    box.FocusLost:Connect(function()
        self:Tween(boxStroke, {Transparency = 0.85}, 0.2)
        local val = tonumber(box.Text)
        if val then
            val = math.clamp(val, min, max)
            box.Text = tostring(val)
            callback(val)
        else
            box.Text = tostring(default)
        end
    end)
    
    return {
        Frame = frame,
        TextBox = box,
        GetValue = function() return tonumber(box.Text) end,
        SetValue = function(val) 
            val = math.clamp(val, min, max)
            box.Text = tostring(val) 
        end
    }
end

-- Create Slider - Proporcional
function SpectrumX:CreateSlider(parent, config)
    config = config or {}
    local text = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, self:Scale(68))
    frame.Parent = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 16, 0, 10)
    label.Size = UDim2.new(0.5, 0, 0, 22)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(0.6, 0, 0, 10)
    valueLabel.Size = UDim2.new(0.35, 0, 0, 22)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = self.Theme.Accent
    valueLabel.TextSize = self:Scale(14)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    -- Track
    local sliderBg = Instance.new("Frame")
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    sliderBg.Position = UDim2.new(0.03, 0, 0, 44)
    sliderBg.Size = UDim2.new(0.94, 0, 0, self:Scale(8))
    sliderBg.Parent = frame
    self:CreateCorner(sliderBg, UDim.new(1, 0))
    
    -- Fill
    local sliderFill = Instance.new("Frame")
    sliderFill.BackgroundColor3 = self.Theme.Accent
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.Parent = sliderBg
    self:CreateCorner(sliderFill, UDim.new(1, 0))
    
    -- Knob proporcional
    local sliderKnob = Instance.new("Frame")
    sliderKnob.BackgroundColor3 = self.Theme.Text
    sliderKnob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sliderKnob.Parent = sliderBg
    self:CreateCorner(sliderKnob, UDim.new(1, 0))
    
    -- Sombra no knob
    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = Color3.fromRGB(0, 0, 0)
    knobStroke.Thickness = 1
    knobStroke.Transparency = 0.4
    knobStroke.Parent = sliderKnob
    
    local dragging = false
    local currentValue = default
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * pos
        value = math.floor(value * 100) / 100
        currentValue = value
        
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        sliderKnob.Position = UDim2.new(pos, -8, 0.5, -8)
        valueLabel.Text = tostring(value)
        callback(value)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    
    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                        input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return {
        Frame = frame,
        GetValue = function() return currentValue end,
        SetValue = function(val)
            val = math.clamp(val, min, max)
            currentValue = val
            local pos = (val - min) / (max - min)
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            sliderKnob.Position = UDim2.new(pos, -8, 0.5, -8)
            valueLabel.Text = tostring(val)
        end
    }
end

-- Create Dropdown
function SpectrumX:CreateDropdown(parent, config)
    config = config or {}
    local labelText = config.Label or "Dropdown"
    local options = config.Options or {}
    local default = config.Default
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, self:Scale(68))
    frame.ClipsDescendants = false
    frame.Parent = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 16, 0, 10)
    label.Size = UDim2.new(1, -32, 0, 20)
    label.Font = Enum.Font.GothamBold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(13)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.BackgroundColor3 = self.Theme.Input
    dropdownBtn.Position = UDim2.new(0, 16, 0, 32)
    dropdownBtn.Size = UDim2.new(1, -32, 0, self:Scale(30))
    dropdownBtn.Font = Enum.Font.GothamSemibold
    dropdownBtn.Text = "  " .. (default or "Select...")
    dropdownBtn.TextColor3 = self.Theme.TextSecondary
    dropdownBtn.TextSize = self:Scale(13)
    dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropdownBtn.ZIndex = 2
    dropdownBtn.Parent = frame
    self:CreateCorner(dropdownBtn, UDim.new(0, 8))
    
    local dropdownStroke = self:CreateStroke(dropdownBtn, self.Theme.Accent, 1, 0.8)
    
    local arrowLabel = Instance.new("TextLabel")
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Position = UDim2.new(1, -26, 0, 0)
    arrowLabel.Size = UDim2.new(0, 26, 1, 0)
    arrowLabel.Font = Enum.Font.GothamBold
    arrowLabel.Text = "▼"
    arrowLabel.TextColor3 = self.Theme.Accent
    arrowLabel.TextSize = self:Scale(11)
    arrowLabel.Parent = dropdownBtn
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Name = "DropdownList_" .. labelText .. "_" .. tostring(tick())
    dropdownList.BackgroundColor3 = self.Theme.Card
    dropdownList.Size = UDim2.new(0, 0, 0, 0)
    dropdownList.ScrollBarThickness = 3
    dropdownList.ScrollBarImageColor3 = self.Theme.Accent
    dropdownList.Visible = false
    dropdownList.ZIndex = 2000
    dropdownList.BorderSizePixel = 0
    dropdownList.Parent = self.ScreenGui
    self:CreateCorner(dropdownList, UDim.new(0, 8))
    self:CreateStroke(dropdownList, self.Theme.Accent, 2, 0.4)
    
    table.insert(self.Dropdowns, dropdownList)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = dropdownList
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 6)
    listPadding.PaddingBottom = UDim.new(0, 6)
    listPadding.PaddingLeft = UDim.new(0, 6)
    listPadding.PaddingRight = UDim.new(0, 6)
    listPadding.Parent = dropdownList
    
    local selectedValue = default
    local isOpen = false
    
    local function positionDropdown()
        local absPos = dropdownBtn.AbsolutePosition
        local absSize = dropdownBtn.AbsoluteSize
        
        local contentHeight = listLayout.AbsoluteContentSize.Y + 12
        local maxHeight = self:Scale(180)
        local targetHeight = math.min(contentHeight, maxHeight)
        
        local targetY = absPos.Y + absSize.Y + 5
        
        local screenHeight = workspace.CurrentCamera.ViewportSize.Y
        if targetY + targetHeight > screenHeight then
            targetY = absPos.Y - targetHeight - 5
        end
        
        dropdownList.Position = UDim2.fromOffset(absPos.X, targetY)
        dropdownList.Size = UDim2.new(0, absSize.X, 0, 0)
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        
        return targetHeight
    end
    
    local function populateList()
        for _, child in ipairs(dropdownList:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        for _, option in ipairs(options) do
            local isSelected = option == selectedValue
            
            local optionFrame = Instance.new("Frame")
            optionFrame.BackgroundColor3 = isSelected and Color3.fromRGB(55, 80, 55) or self.Theme.Input
            optionFrame.Size = UDim2.new(1, 0, 0, self:Scale(32))
            optionFrame.ZIndex = 2001
            optionFrame.Parent = dropdownList
            self:CreateCorner(optionFrame, UDim.new(0, 6))
            
            if isSelected then
                self:CreateStroke(optionFrame, Color3.fromRGB(100, 240, 100), 1.5, 0.3)
            end
            
            local optionBtn = Instance.new("TextButton")
            optionBtn.Name = option
            optionBtn.BackgroundTransparency = 1
            optionBtn.Size = UDim2.new(1, 0, 1, 0)
            optionBtn.Font = Enum.Font.GothamSemibold
            optionBtn.Text = (isSelected and "● " or "   ") .. option
            optionBtn.TextColor3 = isSelected and Color3.fromRGB(150, 255, 150) or self.Theme.TextSecondary
            optionBtn.TextSize = self:Scale(13)
            optionBtn.TextXAlignment = Enum.TextXAlignment.Left
            optionBtn.ZIndex = 2002
            optionBtn.Parent = optionFrame
            
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 10)
            padding.Parent = optionBtn
            
            optionBtn.MouseButton1Click:Connect(function()
                selectedValue = option
                dropdownBtn.Text = "  " .. option
                callback(option)
                
                isOpen = false
                self:Tween(dropdownList, {Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X, 0, 0)}, 0.3)
                self:Tween(arrowLabel, {Rotation = 0}, 0.2)
                task.wait(0.3)
                dropdownList.Visible = false
            end)
            
            optionBtn.MouseEnter:Connect(function()
                if not isSelected then
                    self:Tween(optionFrame, {BackgroundColor3 = Color3.fromRGB(60, 60, 75)}, 0.15)
                end
            end)
            
            optionBtn.MouseLeave:Connect(function()
                if not isSelected then
                    self:Tween(optionFrame, {BackgroundColor3 = self.Theme.Input}, 0.15)
                end
            end)
        end
    end
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if isOpen then
            isOpen = false
            self:Tween(dropdownList, {Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X, 0, 0)}, 0.3)
            self:Tween(arrowLabel, {Rotation = 0}, 0.2)
            task.wait(0.3)
            dropdownList.Visible = false
        else
            for _, dd in ipairs(self.Dropdowns) do
                if dd ~= dropdownList then
                    dd.Visible = false
                end
            end
            
            populateList()
            local targetHeight = positionDropdown()
            dropdownList.Visible = true
            
            self:Tween(dropdownList, {Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X, 0, targetHeight)}, 0.3)
            self:Tween(arrowLabel, {Rotation = 180}, 0.2)
            isOpen = true
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            if isOpen then
                local pos = input.Position
                local listPos = dropdownList.AbsolutePosition
                local listSize = dropdownList.AbsoluteSize
                local btnPos = dropdownBtn.AbsolutePosition
                local btnSize = dropdownBtn.AbsoluteSize
                
                local inList = pos.X >= listPos.X and pos.X <= listPos.X + listSize.X and
                              pos.Y >= listPos.Y and pos.Y <= listPos.Y + listSize.Y
                local inBtn = pos.X >= btnPos.X and pos.X <= btnPos.X + btnSize.X and
                             pos.Y >= btnPos.Y and pos.Y <= btnPos.Y + btnSize.Y
                
                if not inList and not inBtn then
                    isOpen = false
                    self:Tween(dropdownList, {Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X, 0, 0)}, 0.3)
                    self:Tween(arrowLabel, {Rotation = 0}, 0.2)
                    task.wait(0.3)
                    dropdownList.Visible = false
                end
            end
        end
    end)
    
    return {
        Frame = frame,
        GetValue = function() return selectedValue end,
        SetValue = function(val)
            selectedValue = val
            dropdownBtn.Text = "  " .. (val or "Select...")
        end,
        SetOptions = function(newOptions)
            options = newOptions
            if isOpen then
                populateList()
            end
        end
    }
end

-- Create Multi Dropdown
function SpectrumX:CreateMultiDropdown(parent, config)
    config = config or {}
    local labelText = config.Label or "Multi Select"
    local options = config.Options or {}
    local default = config.Default or {}
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, self:Scale(68))
    frame.ClipsDescendants = false
    frame.Parent = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 16, 0, 10)
    label.Size = UDim2.new(1, -32, 0, 20)
    label.Font = Enum.Font.GothamBold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(13)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.BackgroundColor3 = self.Theme.Input
    dropdownBtn.Position = UDim2.new(0, 16, 0, 32)
    dropdownBtn.Size = UDim2.new(1, -32, 0, self:Scale(30))
    dropdownBtn.Font = Enum.Font.GothamSemibold
    dropdownBtn.Text = "  Select Options..."
    dropdownBtn.TextColor3 = self.Theme.TextSecondary
    dropdownBtn.TextSize = self:Scale(13)
    dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropdownBtn.ZIndex = 2
    dropdownBtn.Parent = frame
    self:CreateCorner(dropdownBtn, UDim.new(0, 8))
    
    local dropdownStroke = self:CreateStroke(dropdownBtn, self.Theme.Accent, 1, 0.8)
    
    local arrowLabel = Instance.new("TextLabel")
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Position = UDim2.new(1, -26, 0, 0)
    arrowLabel.Size = UDim2.new(0, 26, 1, 0)
    arrowLabel.Font = Enum.Font.GothamBold
    arrowLabel.Text = "▼"
    arrowLabel.TextColor3 = self.Theme.Accent
    arrowLabel.TextSize = self:Scale(11)
    arrowLabel.Parent = dropdownBtn
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Name = "MultiDropdownList_" .. labelText .. "_" .. tostring(tick())
    dropdownList.BackgroundColor3 = self.Theme.Card
    dropdownList.Size = UDim2.new(0, 0, 0, 0)
    dropdownList.ScrollBarThickness = 3
    dropdownList.ScrollBarImageColor3 = self.Theme.Accent
    dropdownList.Visible = false
    dropdownList.ZIndex = 2000
    dropdownList.BorderSizePixel = 0
    dropdownList.Parent = self.ScreenGui
    self:CreateCorner(dropdownList, UDim.new(0, 8))
    self:CreateStroke(dropdownList, self.Theme.Accent, 2, 0.4)
    
    table.insert(self.Dropdowns, dropdownList)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = dropdownList
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 6)
    listPadding.PaddingBottom = UDim.new(0, 6)
    listPadding.PaddingLeft = UDim.new(0, 6)
    listPadding.PaddingRight = UDim.new(0, 6)
    listPadding.Parent = dropdownList
    
    local selectedValues = {}
    for _, v in ipairs(default) do
        table.insert(selectedValues, v)
    end
    local isOpen = false
    
    local function updateButtonText()
        if #selectedValues == 0 then
            dropdownBtn.Text = "  Select Options..."
        elseif #selectedValues == 1 then
            dropdownBtn.Text = "  " .. selectedValues[1]
        else
            dropdownBtn.Text = "  " .. #selectedValues .. " selected"
        end
    end
    
    local function positionDropdown()
        local absPos = dropdownBtn.AbsolutePosition
        local absSize = dropdownBtn.AbsoluteSize
        
        local contentHeight = listLayout.AbsoluteContentSize.Y + 12
        local maxHeight = self:Scale(180)
        local targetHeight = math.min(contentHeight, maxHeight)
        
        local targetY = absPos.Y + absSize.Y + 5
        
        local screenHeight = workspace.CurrentCamera.ViewportSize.Y
        if targetY + targetHeight > screenHeight then
            targetY = absPos.Y - targetHeight - 5
        end
        
        dropdownList.Position = UDim2.fromOffset(absPos.X, targetY)
        dropdownList.Size = UDim2.new(0, absSize.X, 0, 0)
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        
        return targetHeight
    end
    
    local function getPriority(zoneName)
        for i, zone in ipairs(selectedValues) do
            if zone == zoneName then
                return i
            end
        end
        return nil
    end
    
    local function toggleSelection(zoneName)
        for i, zone in ipairs(selectedValues) do
            if zone == zoneName then
                table.remove(selectedValues, i)
                return false
            end
        end
        table.insert(selectedValues, zoneName)
        return true
    end
    
    local function populateList()
        for _, child in ipairs(dropdownList:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        for _, option in ipairs(options) do
            local priority = getPriority(option)
            local isSelected = priority ~= nil
            
            local optionFrame = Instance.new("Frame")
            optionFrame.BackgroundColor3 = isSelected and Color3.fromRGB(55, 80, 55) or self.Theme.Input
            optionFrame.Size = UDim2.new(1, 0, 0, self:Scale(32))
            optionFrame.ZIndex = 2001
            optionFrame.Parent = dropdownList
            self:CreateCorner(optionFrame, UDim.new(0, 6))
            
            if isSelected then
                self:CreateStroke(optionFrame, Color3.fromRGB(100, 240, 100), 1.5, 0.3)
            end
            
            local optionBtn = Instance.new("TextButton")
            optionBtn.Name = option
            optionBtn.BackgroundTransparency = 1
            optionBtn.Size = UDim2.new(1, 0, 1, 0)
            optionBtn.Font = Enum.Font.GothamSemibold
            optionBtn.Text = (isSelected and (priority .. ". ") or "   ") .. option
            optionBtn.TextColor3 = isSelected and Color3.fromRGB(150, 255, 150) or self.Theme.TextSecondary
            optionBtn.TextSize = self:Scale(13)
            optionBtn.TextXAlignment = Enum.TextXAlignment.Left
            optionBtn.ZIndex = 2002
            optionBtn.Parent = optionFrame
            
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 10)
            padding.Parent = optionBtn
            
            optionBtn.MouseButton1Click:Connect(function()
                toggleSelection(option)
                callback(selectedValues)
                updateButtonText()
                populateList()
            end)
            
            optionBtn.MouseEnter:Connect(function()
                if not isSelected then
                    self:Tween(optionFrame, {BackgroundColor3 = Color3.fromRGB(60, 60, 75)}, 0.15)
                end
            end)
            
            optionBtn.MouseLeave:Connect(function()
                if not isSelected then
                    self:Tween(optionFrame, {BackgroundColor3 = self.Theme.Input}, 0.15)
                end
            end)
        end
    end
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if isOpen then
            isOpen = false
            self:Tween(dropdownList, {Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X, 0, 0)}, 0.3)
            self:Tween(arrowLabel, {Rotation = 0}, 0.2)
            task.wait(0.3)
            dropdownList.Visible = false
        else
            for _, dd in ipairs(self.Dropdowns) do
                if dd ~= dropdownList then
                    dd.Visible = false
                end
            end
            
            populateList()
            local targetHeight = positionDropdown()
            dropdownList.Visible = true
            
            self:Tween(dropdownList, {Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X, 0, targetHeight)}, 0.3)
            self:Tween(arrowLabel, {Rotation = 180}, 0.2)
            isOpen = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if isOpen then
                local pos = input.Position
                local listPos = dropdownList.AbsolutePosition
                local listSize = dropdownList.AbsoluteSize
                local btnPos = dropdownBtn.AbsolutePosition
                local btnSize = dropdownBtn.AbsoluteSize
                
                local inList = pos.X >= listPos.X and pos.X <= listPos.X + listSize.X and
                              pos.Y >= listPos.Y and pos.Y <= listPos.Y + listSize.Y
                local inBtn = pos.X >= btnPos.X and pos.X <= btnPos.X + btnSize.X and
                             pos.Y >= btnPos.Y and pos.Y <= btnPos.Y + btnSize.Y
                
                if not inList and not inBtn then
                    isOpen = false
                    self:Tween(dropdownList, {Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X, 0, 0)}, 0.3)
                    self:Tween(arrowLabel, {Rotation = 0}, 0.2)
                    task.wait(0.3)
                    dropdownList.Visible = false
                end
            end
        end
    end)
    
    updateButtonText()
    
    return {
        Frame = frame,
        GetValues = function() return selectedValues end,
        SetValues = function(values)
            selectedValues = values
            updateButtonText()
        end,
        SetOptions = function(newOptions)
            options = newOptions
            if isOpen then
                populateList()
            end
        end
    }
end

-- Create Checkbox
function SpectrumX:CreateCheckbox(parent, config)
    config = config or {}
    local text = config.Text or "Checkbox"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, self:Scale(44))
    frame.Parent = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)
    
    local checkbox = Instance.new("TextButton")
    checkbox.Name = "Checkbox"
    checkbox.BackgroundColor3 = default and self.Theme.Accent or self.Theme.Input
    checkbox.Position = UDim2.new(0, 16, 0.5, -10)
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Font = Enum.Font.GothamBold
    checkbox.Text = default and "✓" or ""
    checkbox.TextColor3 = self.Theme.Text
    checkbox.TextSize = self:Scale(13)
    checkbox.Parent = frame
    self:CreateCorner(checkbox, UDim.new(0, 5))
    
    local checkboxStroke = self:CreateStroke(checkbox, self.Theme.Accent, 1.5, 0.5)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 44, 0, 0)
    label.Size = UDim2.new(1, -58, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local state = default
    
    checkbox.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        
        if state then
            self:Tween(checkbox, {BackgroundColor3 = self.Theme.Accent}, 0.2)
            checkbox.Text = "✓"
        else
            self:Tween(checkbox, {BackgroundColor3 = self.Theme.Input}, 0.2)
            checkbox.Text = ""
        end
    end)
    
    return {
        Frame = frame,
        GetState = function() return state end,
        SetState = function(newState)
            state = newState
            callback(state)
            if state then
                self:Tween(checkbox, {BackgroundColor3 = self.Theme.Accent}, 0.2)
                checkbox.Text = "✓"
            else
                self:Tween(checkbox, {BackgroundColor3 = self.Theme.Input}, 0.2)
                checkbox.Text = ""
            end
        end
    }
end

-- Create Label
function SpectrumX:CreateLabel(parent, config)
    config = config or {}
    local text = config.Text or "Label"
    local color = config.Color or self.Theme.Text
    local size = config.Size or UDim2.new(1, 0, 0, self:Scale(38))
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = self:Scale(size)
    frame.Parent = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 16, 0, 0)
    label.Size = UDim2.new(1, -32, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = color
    label.TextSize = self:Scale(14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    return {
        Frame = frame,
        Label = label,
        SetText = function(newText) label.Text = newText end
    }
end

-- Create Separator
function SpectrumX:CreateSeparator(parent)
    local separator = Instance.new("Frame")
    separator.BackgroundColor3 = self.Theme.Border
    separator.BorderSizePixel = 0
    separator.Size = UDim2.new(1, 0, 0, 1)
    separator.Parent = parent
    return separator
end

-- Create Status Card
function SpectrumX:CreateStatusCard(parent, config)
    config = config or {}
    local title = config.Title or "Status"
    
    local frame = Instance.new("Frame")
    frame.Name = "StatusCard"
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, self:Scale(110))
    frame.Active = true
    frame.Parent = parent
    self:CreateCorner(frame, UDim.new(0, 12))
    self:CreateStroke(frame, self.Theme.Accent, 2, 0.35)
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, self:Scale(34))
    header.Parent = frame
    self:CreateCorner(header, UDim.new(0, 12))
    
    local headerCover = Instance.new("Frame")
    headerCover.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    headerCover.BorderSizePixel = 0
    headerCover.Size = UDim2.new(1, 0, 0, 12)
    headerCover.Position = UDim2.new(0, 0, 1, -12)
    headerCover.Parent = header
    
    local statusTitle = Instance.new("TextLabel")
    statusTitle.BackgroundTransparency = 1
    statusTitle.Size = UDim2.new(1, -14, 1, 0)
    statusTitle.Position = UDim2.new(0, 14, 0, 0)
    statusTitle.Font = Enum.Font.GothamBold
    statusTitle.Text = title
    statusTitle.TextColor3 = self.Theme.Text
    statusTitle.TextSize = self:Scale(13)
    statusTitle.TextXAlignment = Enum.TextXAlignment.Left
    statusTitle.Parent = header
    
    local content = Instance.new("Frame")
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 14, 0, self:Scale(40))
    content.Size = UDim2.new(1, -28, 1, -self:Scale(48))
    content.Parent = frame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(1, 0, 0, self:Scale(22))
    statusLabel.Font = Enum.Font.GothamSemibold
    statusLabel.Text = "● Idle"
    statusLabel.TextColor3 = self.Theme.TextMuted
    statusLabel.TextSize = self:Scale(13)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = content
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.BackgroundTransparency = 1
    infoLabel.Position = UDim2.new(0, 0, 0, self:Scale(24))
    infoLabel.Size = UDim2.new(1, 0, 0, self:Scale(18))
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Text = "Ready"
    infoLabel.TextColor3 = self.Theme.TextSecondary
    infoLabel.TextSize = self:Scale(11)
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = content
    
    local loadingBarBg = Instance.new("Frame")
    loadingBarBg.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    loadingBarBg.Position = UDim2.new(0, 0, 1, -8)
    loadingBarBg.Size = UDim2.new(1, 0, 0, self:Scale(4))
    loadingBarBg.ClipsDescendants = true
    loadingBarBg.Parent = content
    self:CreateCorner(loadingBarBg, UDim.new(1, 0))
    
    local loadingBar = Instance.new("Frame")
    loadingBar.BackgroundColor3 = self.Theme.Accent
    loadingBar.Size = UDim2.new(0, 0, 1, 0)
    loadingBar.BorderSizePixel = 0
    loadingBar.Parent = loadingBarBg
    self:CreateCorner(loadingBar, UDim.new(1, 0))
    
    self:MakeDraggable(frame, header)
    
    return {
        Frame = frame,
        SetStatus = function(status, color)
            statusLabel.Text = "● " .. status
            statusLabel.TextColor3 = color or self.Theme.TextMuted
        end,
        SetInfo = function(info)
            infoLabel.Text = info
        end,
        AnimateLoading = function(active, duration)
            if active then
                spawn(function()
                    while active and frame.Parent do
                        local tween = self:Tween(loadingBar, {Size = UDim2.new(1, 0, 1, 0)}, duration or 1.5)
                        tween.Completed:Wait()
                        task.wait(0.1)
                        loadingBar.Size = UDim2.new(0, 0, 1, 0)
                        task.wait(0.1)
                    end
                end)
            else
                loadingBar.Size = UDim2.new(0, 0, 1, 0)
            end
        end
    }
end

-- Notification System
function SpectrumX:Notify(config)
    config = config or {}
    local text = config.Text or "Notification"
    local type = config.Type or "info"
    local duration = config.Duration or 3
    
    self:UpdateScale()
    
    local notifWidth = ScaleData.IsMobile and 300 or 340
    local notifHeight = ScaleData.IsMobile and 62 or 68
    
    local notification = Instance.new("Frame")
    notification.BackgroundColor3 = self.Theme.Card
    notification.Position = UDim2.new(1, self:Scale(24), 0.88, 0)
    notification.Size = UDim2.new(0, self:Scale(notifWidth), 0, self:Scale(notifHeight))
    notification.Parent = self.ScreenGui
    self:CreateCorner(notification, UDim.new(0, 12))
    self:CreateStroke(notification, self.Theme.Border, 1, 0.85)
    
    local color = self.Theme.Info
    if type == "success" then
        color = self.Theme.Success
    elseif type == "warning" then
        color = self.Theme.Warning
    elseif type == "error" then
        color = Color3.fromRGB(255, 75, 75)
    end
    
    local icon = Instance.new("TextLabel")
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(0, self:Scale(16), 0, 0)
    icon.Size = UDim2.new(0, self:Scale(28), 1, 0)
    icon.Font = Enum.Font.GothamBlack
    icon.Text = type == "success" and "✓" or type == "warning" and "!" or type == "error" and "✕" or "i"
    icon.TextColor3 = color
    icon.TextSize = self:Scale(22)
    icon.Parent = notification
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self:Scale(50), 0, 0)
    label.Size = UDim2.new(1, -self:Scale(62), 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(13)
    label.TextWrapped = true
    label.Parent = notification
    
    local entryX = ScaleData.IsMobile and -notifWidth - 15 or -notifWidth - 25
    
    self:Tween(notification, {Position = UDim2.new(1, self:Scale(entryX), 0.88, 0)}, 0.4)
    
    task.wait(duration)
    
    self:Tween(notification, {Position = UDim2.new(1, self:Scale(24), 0.88, 0)}, 0.4)
    task.wait(0.4)
    notification:Destroy()
end

-- Destroy UI
function SpectrumX:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return SpectrumX

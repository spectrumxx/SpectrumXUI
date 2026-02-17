-- https://github.com/spectrumxx/SpectrumXUI

local SpectrumX = {}
SpectrumX.__index = SpectrumX

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Theme Configuration
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

-- Utility Functions
function SpectrumX:Tween(obj, props, time, easingStyle, easingDirection)
    local info = TweenInfo.new(
        time or 0.3,
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
    stroke.Parent = parent
    return stroke
end

function SpectrumX:CreateShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
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

-- ========== SISTEMA DE DROPDOWN GLOBAL (FIX) ==========
function SpectrumX:SetupDropdownSystem()
    self.ActiveDropdowns = {}
    
    -- Fecha todos os dropdowns
    self.CloseAllDropdowns = function()
        for _, dropdown in ipairs(self.ActiveDropdowns) do
            if dropdown and dropdown.Visible then
                local arrowLabel = dropdown:GetAttribute("ArrowLabel")
                local dropdownStroke = dropdown:GetAttribute("DropdownStroke")
                
                -- Animação de fechamento
                self:Tween(dropdown, {Size = UDim2.new(0, dropdown.Size.X.Offset, 0, 0)}, 0.3)
                if arrowLabel then
                    self:Tween(arrowLabel, {Rotation = 0}, 0.2)
                end
                if dropdownStroke then
                    self:Tween(dropdownStroke, {Transparency = 0.6}, 0.2)
                end
                
                task.delay(0.3, function()
                    if dropdown then
                        dropdown.Visible = false
                    end
                end)
            end
        end
        self.ActiveDropdowns = {}
    end
    
    -- Detecta clique fora
    self.DropdownConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and 
           input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        
        if gameProcessed then return end
        
        local mousePos = UserInputService:GetMouseLocation()
        local mainFramePos = self.MainFrame.AbsolutePosition
        local mainFrameSize = self.MainFrame.AbsoluteSize
        
        -- Verifica se clicou dentro do MainFrame
        local clickedInsideMain = (
            mousePos.X >= mainFramePos.X and 
            mousePos.X <= mainFramePos.X + mainFrameSize.X and
            mousePos.Y >= mainFramePos.Y and 
            mousePos.Y <= mainFramePos.Y + mainFrameSize.Y
        )
        
        -- Verifica se clicou dentro de algum dropdown
        local clickedInsideDropdown = false
        for _, dropdown in ipairs(self.ActiveDropdowns) do
            if dropdown and dropdown.Visible then
                local dropPos = dropdown.AbsolutePosition
                local dropSize = dropdown.AbsoluteSize
                
                if mousePos.X >= dropPos.X and mousePos.X <= dropPos.X + dropSize.X and
                   mousePos.Y >= dropPos.Y and mousePos.Y <= dropPos.Y + dropSize.Y then
                    clickedInsideDropdown = true
                    break
                end
            end
        end
        
        -- Fecha se clicou fora de tudo
        if not clickedInsideMain and not clickedInsideDropdown then
            self.CloseAllDropdowns()
        end
    end)
end

-- Main Window Creation
function SpectrumX:CreateWindow(config)
    config = config or {}
    local window = setmetatable({}, self)
    
    -- Destroy existing UI
    if PlayerGui:FindFirstChild("SpectrumX") then
        PlayerGui.SpectrumX:Destroy()
    end
    
    -- ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SpectrumX"
    self.ScreenGui.Parent = PlayerGui
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.DisplayOrder = 999
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Position = config.Position or UDim2.new(0.5, -300, 0.5, -180)
    self.MainFrame.Size = config.Size or UDim2.new(0, 600, 0, 360)
    self.MainFrame.Active = true
    self.MainFrame.Visible = true
    self.MainFrame.Parent = self.ScreenGui
    
    self:CreateCorner(self.MainFrame, UDim.new(0, 12))
    self:CreateShadow(self.MainFrame)
    self:CreateStroke(self.MainFrame, self.Theme.Accent, 2, 0)
    
    -- Header
    self.Header = Instance.new("Frame")
    self.Header.Name = "Header"
    self.Header.BackgroundColor3 = self.Theme.Header
    self.Header.BorderSizePixel = 0
    self.Header.Size = UDim2.new(1, 0, 0, 55)
    self.Header.Parent = self.MainFrame
    
    self:CreateCorner(self.Header, UDim.new(0, 12))
    
    local headerCover = Instance.new("Frame")
    headerCover.BorderSizePixel = 0
    headerCover.BackgroundColor3 = self.Theme.Header
    headerCover.Size = UDim2.new(1, 0, 0, 12)
    headerCover.Position = UDim2.new(0, 0, 1, -12)
    headerCover.Parent = self.Header
    
    -- Title Icon (Letter)
    local titleIcon = Instance.new("TextLabel")
    titleIcon.Name = "TitleIcon"
    titleIcon.BackgroundTransparency = 1
    titleIcon.Position = UDim2.new(0, 15, 0, 7.5)
    titleIcon.Size = UDim2.new(0, 40, 0, 40)
    titleIcon.Font = Enum.Font.GothamBlack
    titleIcon.Text = config.Icon or "S"
    titleIcon.TextColor3 = self.Theme.Accent
    titleIcon.TextSize = 28
    titleIcon.Parent = self.Header
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 65, 0, 0)
    title.Size = UDim2.new(0, 300, 1, 0)
    title.Font = Enum.Font.GothamBlack
    title.Text = config.Title or "Spectrum X"
    title.TextColor3 = self.Theme.Text
    title.TextSize = 22
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
    closeBtn.Position = UDim2.new(1, -50, 0, 12.5)
    closeBtn.Size = UDim2.new(0, 35, 0, 30)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "—"
    closeBtn.TextColor3 = self.Theme.TextMuted
    closeBtn.TextSize = 20
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
    
    -- Sidebar
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.BackgroundColor3 = self.Theme.Sidebar
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Position = UDim2.new(0, 0, 0, 55)
    self.Sidebar.Size = UDim2.new(0, 55, 1, -55)
    self.Sidebar.Parent = self.MainFrame
    
    self:CreateCorner(self.Sidebar, UDim.new(0, 12))
    
    local sidebarCover = Instance.new("Frame")
    sidebarCover.BackgroundColor3 = self.Theme.Sidebar
    sidebarCover.BorderSizePixel = 0
    sidebarCover.Size = UDim2.new(1, 0, 0, 12)
    sidebarCover.Parent = self.Sidebar
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, 10)
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.Parent = self.Sidebar
    
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, 12)
    sidebarPadding.Parent = self.Sidebar
    
    -- Content Area
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Position = UDim2.new(0, 65, 0, 65)
    self.ContentArea.Size = UDim2.new(1, -75, 1, -75)
    self.ContentArea.Parent = self.MainFrame
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Setup Dropdown System (FIX)
    self:SetupDropdownSystem()
    
    -- Make draggable
    self:MakeDraggable(self.MainFrame, self.Header)
    
    -- Create Floating Toggle Button
    self:CreateFloatingButton()
    
    return window
end

-- Floating Toggle Button
function SpectrumX:CreateFloatingButton()
    self.FloatBtn = Instance.new("ImageButton")
    self.FloatBtn.Name = "FloatBtn"
    self.FloatBtn.BackgroundColor3 = self.Theme.Accent
    self.FloatBtn.Position = UDim2.new(0, 10, 0.5, 0)
    self.FloatBtn.Size = UDim2.new(0, 55, 0, 55)
    self.FloatBtn.Image = ""
    self.FloatBtn.Parent = self.ScreenGui
    self:CreateCorner(self.FloatBtn, UDim.new(0, 14))
    
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
    floatStroke.Thickness = 3
    floatStroke.Parent = self.FloatBtn
    
    -- Make draggable
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

-- Create Tab
function SpectrumX:CreateTab(config)
    config = config or {}
    local tabId = config.Name or "Tab"
    local tabIcon = config.Icon or string.sub(tabId, 1, 1)
    
    -- Tab Button
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabId .. "Tab"
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabBtn.Size = UDim2.new(0, 40, 0, 40)
    tabBtn.Font = Enum.Font.GothamBlack
    tabBtn.Text = tabIcon
    tabBtn.TextColor3 = self.Theme.TextMuted
    tabBtn.TextSize = 18
    tabBtn.Parent = self.Sidebar
    self:CreateCorner(tabBtn, UDim.new(0, 10))
    
    -- Page Container
    local pageContainer = Instance.new("Frame")
    pageContainer.Name = tabId .. "PageContainer"
    pageContainer.BackgroundTransparency = 1
    pageContainer.Size = UDim2.new(1, 0, 1, 0)
    pageContainer.Visible = false
    pageContainer.Parent = self.ContentArea
    
    -- Divider
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
    leftLayout.Padding = UDim.new(0, 10)
    leftLayout.Parent = leftSide
    
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        leftSide.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 10)
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
    rightLayout.Padding = UDim.new(0, 10)
    rightLayout.Parent = rightSide
    
    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        rightSide.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Store tab data
    local tabData = {
        Button = tabBtn,
        Container = pageContainer,
        Left = leftSide,
        Right = rightSide
    }
    self.Tabs[tabId] = tabData
    
    -- Tab click handler (FIX: Fecha dropdowns ao trocar de aba)
    tabBtn.MouseButton1Click:Connect(function()
        self:CloseAllDropdowns()
        self:SelectTab(tabId)
    end)
    
    -- Select first tab automatically
    if not self.CurrentTab then
        self:SelectTab(tabId)
    end
    
    return tabData
end

-- Select Tab
function SpectrumX:SelectTab(tabId)
    for id, data in pairs(self.Tabs) do
        if id == tabId then
            data.Container.Visible = true
            self:Tween(data.Button, {
                BackgroundColor3 = self.Theme.Accent, 
                TextColor3 = self.Theme.Text
            }, 0.2)
        else
            data.Container.Visible = false
            self:Tween(data.Button, {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30), 
                TextColor3 = self.Theme.TextMuted
            }, 0.2)
        end
    end
    self.CurrentTab = tabId
end

-- Create Section Title
function SpectrumX:CreateSection(parent, text, color)
    local section = Instance.new("TextLabel")
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, 0, 0, 28)
    section.Font = Enum.Font.GothamBlack
    section.Text = text
    section.TextColor3 = color or self.Theme.Accent
    section.TextSize = 14
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = parent
    return section
end

-- Create Toggle
function SpectrumX:CreateToggle(parent, config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, 45)
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
    switchBg.Position = UDim2.new(1, -55, 0.5, -12)
    switchBg.Size = UDim2.new(0, 45, 0, 24)
    switchBg.Parent = frame
    self:CreateCorner(switchBg, UDim.new(1, 0))
    
    local circle = Instance.new("Frame")
    circle.BackgroundColor3 = self.Theme.Text
    circle.Position = default and UDim2.new(1, -20, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Parent = switchBg
    self:CreateCorner(circle, UDim.new(1, 0))
    
    local state = default
    
    switchBg.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        
        if state then
            self:Tween(switchBg, {BackgroundColor3 = self.Theme.ToggleOn}, 0.2)
            self:Tween(circle, {Position = UDim2.new(1, -20, 0.5, -10)}, 0.2)
        else
            self:Tween(switchBg, {BackgroundColor3 = self.Theme.ToggleOff}, 0.2)
            self:Tween(circle, {Position = UDim2.new(0, 2, 0.5, -10)}, 0.2)
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
                self:Tween(circle, {Position = UDim2.new(1, -20, 0.5, -10)}, 0.2)
            else
                self:Tween(switchBg, {BackgroundColor3 = self.Theme.ToggleOff}, 0.2)
                self:Tween(circle, {Position = UDim2.new(0, 2, 0.5, -10)}, 0.2)
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
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local btn = Instance.new("TextButton")
    btn.Name = "Button"
    btn.BackgroundColor3 = self.Theme.Card
    btn.Position = UDim2.new(0.05, 0, 0.1, 0)
    btn.Size = UDim2.new(0.9, 0, 0.8, 0)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextSize = 13
    btn.Parent = frame
    self:CreateCorner(btn)
    
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
    
    local btnStroke = self:CreateStroke(btn, color, 1, 0.7)
    
    btn.MouseEnter:Connect(function()
        self:Tween(btn, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}, 0.2)
        self:Tween(btnStroke, {Transparency = 0.3}, 0.2)
    end)
    
    btn.MouseLeave:Connect(function()
        self:Tween(btn, {BackgroundColor3 = self.Theme.Card}, 0.2)
        self:Tween(btnStroke, {Transparency = 0.7}, 0.2)
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
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(0.6, 0, 0.6, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local box = Instance.new("TextBox")
    box.BackgroundColor3 = self.Theme.Input
    box.Position = UDim2.new(0.05, 0, 0.5, -2)
    box.Size = UDim2.new(0.9, 0, 0, 28)
    box.Font = Enum.Font.Gotham
    box.Text = tostring(default)
    box.PlaceholderText = placeholder
    box.TextColor3 = self.Theme.Text
    box.TextSize = 13
    box.Parent = frame
    self:CreateCorner(box, UDim.new(0, 6))
    
    local boxStroke = self:CreateStroke(box, self.Theme.Accent, 1, 0.7)
    
    box.Focused:Connect(function()
        self:Tween(boxStroke, {Transparency = 0}, 0.2)
    end)
    
    box.FocusLost:Connect(function()
        self:Tween(boxStroke, {Transparency = 0.7}, 0.2)
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
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(0.6, 0, 0.6, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local box = Instance.new("TextBox")
    box.BackgroundColor3 = self.Theme.Input
    box.Position = UDim2.new(0.05, 0, 0.5, -2)
    box.Size = UDim2.new(0.9, 0, 0, 28)
    box.Font = Enum.Font.Gotham
    box.Text = tostring(default)
    box.TextColor3 = self.Theme.Text
    box.TextSize = 13
    box.Parent = frame
    self:CreateCorner(box, UDim.new(0, 6))
    
    local boxStroke = self:CreateStroke(box, self.Theme.Accent, 1, 0.7)
    
    box.Focused:Connect(function()
        self:Tween(boxStroke, {Transparency = 0}, 0.2)
    end)
    
    box.FocusLost:Connect(function()
        self:Tween(boxStroke, {Transparency = 0.7}, 0.2)
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

-- Create Slider
function SpectrumX:CreateSlider(parent, config)
    config = config or {}
    local text = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, 65)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 8)
    label.Size = UDim2.new(0.5, 0, 0, 20)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(0.6, 0, 0, 8)
    valueLabel.Size = UDim2.new(0.35, 0, 0, 20)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = self.Theme.Accent
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    sliderBg.Position = UDim2.new(0.05, 0, 0, 38)
    sliderBg.Size = UDim2.new(0.9, 0, 0, 8)
    sliderBg.Parent = frame
    self:CreateCorner(sliderBg, UDim.new(1, 0))
    
    local sliderFill = Instance.new("Frame")
    sliderFill.BackgroundColor3 = self.Theme.Accent
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.Parent = sliderBg
    self:CreateCorner(sliderFill, UDim.new(1, 0))
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.BackgroundColor3 = self.Theme.Text
    sliderKnob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sliderKnob.Parent = sliderBg
    self:CreateCorner(sliderKnob, UDim.new(1, 0))
    
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

-- ========== CREATE DROPDOWN (FIXED) ==========
function SpectrumX:CreateDropdown(parent, config)
    config = config or {}
    local labelText = config.Label or "Dropdown"
    local options = config.Options or {}
    local default = config.Default
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.ClipsDescendants = false
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 8)
    label.Size = UDim2.new(1, -24, 0, 18)
    label.Font = Enum.Font.GothamBold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.BackgroundColor3 = self.Theme.Input
    dropdownBtn.Position = UDim2.new(0, 12, 0, 30)
    dropdownBtn.Size = UDim2.new(1, -24, 0, 24)
    dropdownBtn.Font = Enum.Font.GothamSemibold
    dropdownBtn.Text = "  " .. (default or "Select...")
    dropdownBtn.TextColor3 = self.Theme.TextSecondary
    dropdownBtn.TextSize = 11
    dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropdownBtn.ZIndex = 2
    dropdownBtn.Parent = frame
    self:CreateCorner(dropdownBtn, UDim.new(0, 6))
    
    local dropdownStroke = self:CreateStroke(dropdownBtn, self.Theme.Accent, 1.2, 0.6)
    
    local arrowLabel = Instance.new("TextLabel")
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Position = UDim2.new(1, -20, 0, 0)
    arrowLabel.Size = UDim2.new(0, 20, 1, 0)
    arrowLabel.Font = Enum.Font.GothamBold
    arrowLabel.Text = "▼"
    arrowLabel.TextColor3 = self.Theme.Accent
    arrowLabel.TextSize = 10
    arrowLabel.Parent = dropdownBtn
    
    -- Dropdown List (ScreenGui level for proper layering)
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Name = "DropdownList_" .. labelText .. "_" .. HttpService:GenerateGUID(false)
    dropdownList.BackgroundColor3 = self.Theme.Card
    dropdownList.Size = UDim2.new(0, 200, 0, 0)
    dropdownList.ScrollBarThickness = 2
    dropdownList.ScrollBarImageColor3 = self.Theme.Accent
    dropdownList.Visible = false
    dropdownList.ZIndex = 2000
    dropdownList.BorderSizePixel = 0
    dropdownList.Parent = self.ScreenGui
    self:CreateCorner(dropdownList, UDim.new(0, 6))
    
    -- Store references for closing system
    dropdownList:SetAttribute("ArrowLabel", arrowLabel)
    dropdownList:SetAttribute("DropdownStroke", dropdownStroke)
    dropdownList:SetAttribute("IsOpen", false)
    
    local listStroke = self:CreateStroke(dropdownList, self.Theme.Accent, 1.5, 0)
    
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
    
    local function updateDropdownHeight()
        local contentHeight = listLayout.AbsoluteContentSize.Y + 12
        local maxHeight = 180
        local targetHeight = math.min(contentHeight, maxHeight)
        self:Tween(dropdownList, {Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X, 0, targetHeight)}, 0.3)
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
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
            optionFrame.BackgroundColor3 = isSelected and Color3.fromRGB(40, 60, 40) or self.Theme.Input
            optionFrame.Size = UDim2.new(1, 0, 0, 32)
            optionFrame.ZIndex = 2001
            optionFrame.Parent = dropdownList
            self:CreateCorner(optionFrame, UDim.new(0, 6))
            
            if isSelected then
                local selectedGlow = self:CreateStroke(optionFrame, Color3.fromRGB(80, 255, 80), 1.5, 0.3)
            end
            
            local optionBtn = Instance.new("TextButton")
            optionBtn.Name = option
            optionBtn.BackgroundTransparency = 1
            optionBtn.Size = UDim2.new(1, 0, 1, 0)
            optionBtn.Font = Enum.Font.GothamSemibold
            optionBtn.Text = (isSelected and "⭐ " or "    ") .. option
            optionBtn.TextColor3 = isSelected and Color3.fromRGB(150, 255, 150) or self.Theme.TextSecondary
            optionBtn.TextSize = 11
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
                
                -- Close dropdown
                isOpen = false
                dropdownList:SetAttribute("IsOpen", false)
                
                -- Remove from active list
                for i, dd in ipairs(self.ActiveDropdowns) do
                    if dd == dropdownList then
                        table.remove(self.ActiveDropdowns, i)
                        break
                    end
                end
                
                self:Tween(dropdownList, {Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X, 0, 0)}, 0.3)
                self:Tween(arrowLabel, {Rotation = 0}, 0.2)
                task.wait(0.3)
                dropdownList.Visible = false
            end)
            
            optionBtn.MouseEnter:Connect(function()
                if not isSelected then
                    self:Tween(optionFrame, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.15)
                else
                    self:Tween(optionFrame, {BackgroundColor3 = Color3.fromRGB(50, 75, 50)}, 0.15)
                end
            end)
            
            optionBtn.MouseLeave:Connect(function()
                if not isSelected then
                    self:Tween(optionFrame, {BackgroundColor3 = self.Theme.Input}, 0.15)
                else
                    self:Tween(optionFrame, {BackgroundColor3 = Color3.fromRGB(40, 60, 40)}, 0.15)
                end
            end)
        end
        
        updateDropdownHeight()
    end
    
    -- ========== FIXED POSITIONING FUNCTION ==========
    local function positionDropdown()
        local absPos = dropdownBtn.AbsolutePosition
        local absSize = dropdownBtn.AbsoluteSize
        local screenHeight = workspace.CurrentCamera.ViewportSize.Y
        local dropdownHeight = math.min(listLayout.AbsoluteContentSize.Y + 12, 180)
        
        -- Calculate available space
        local spaceBelow = screenHeight - (absPos.Y + absSize.Y)
        local spaceAbove = absPos.Y
        
        -- Decide position: prefer below, but go above if not enough space
        local openAbove = false
        if spaceBelow < dropdownHeight and spaceAbove > dropdownHeight then
            openAbove = true
        end
        
        if openAbove then
            -- Open ABOVE the button
            dropdownList.Position = UDim2.fromOffset(absPos.X, absPos.Y - dropdownHeight - 4)
        else
            -- Open BELOW the button (default)
            dropdownList.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 4)
        end
    end
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if isOpen then
            -- Close
            isOpen = false
            dropdownList:SetAttribute("IsOpen", false)
            
            -- Remove from active list
            for i, dd in ipairs(self.ActiveDropdowns) do
                if dd == dropdownList then
                    table.remove(self.ActiveDropdowns, i)
                    break
                end
            end
            
            self:Tween(dropdownList, {Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X, 0, 0)}, 0.3)
            self:Tween(dropdownStroke, {Transparency = 0.6}, 0.2)
            self:Tween(arrowLabel, {Rotation = 0}, 0.2)
            task.wait(0.3)
            dropdownList.Visible = false
        else
            -- Close other dropdowns first
            self:CloseAllDropdowns()
            
            -- Position and open
            dropdownList.Visible = true
            populateList()
            positionDropdown() -- FIXED: Smart positioning
            
            self:Tween(dropdownStroke, {Transparency = 0.2}, 0.2)
            self:Tween(arrowLabel, {Rotation = 180}, 0.2)
            
            isOpen = true
            dropdownList:SetAttribute("IsOpen", true)
            table.insert(self.ActiveDropdowns, dropdownList)
        end
    end)
    
    dropdownBtn.MouseEnter:Connect(function()
        self:Tween(dropdownBtn, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}, 0.15)
        self:Tween(dropdownStroke, {Transparency = 0.3}, 0.15)
    end)
    
    dropdownBtn.MouseLeave:Connect(function()
        self:Tween(dropdownBtn, {BackgroundColor3 = self.Theme.Input}, 0.15)
        if not isOpen then
            self:Tween(dropdownStroke, {Transparency = 0.6}, 0.15)
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

-- ========== CREATE MULTI DROPDOWN (FIXED) ==========
function SpectrumX:CreateMultiDropdown(parent, config)
    config = config or {}
    local labelText = config.Label or "Multi Select"
    local options = config.Options or {}
    local default = config.Default or {}
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.ClipsDescendants = false
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 8)
    label.Size = UDim2.new(1, -24, 0, 18)
    label.Font = Enum.Font.GothamBold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.BackgroundColor3 = self.Theme.Input
    dropdownBtn.Position = UDim2.new(0, 12, 0, 30)
    dropdownBtn.Size = UDim2.new(1, -24, 0, 24)
    dropdownBtn.Font = Enum.Font.GothamSemibold
    dropdownBtn.Text = "  Select Options..."
    dropdownBtn.TextColor3 = self.Theme.TextSecondary
    dropdownBtn.TextSize = 11
    dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropdownBtn.ZIndex = 2
    dropdownBtn.Parent = frame
    self:CreateCorner(dropdownBtn, UDim.new(0, 6))
    
    local dropdownStroke = self:CreateStroke(dropdownBtn, self.Theme.Accent, 1.2, 0.6)
    
    local arrowLabel = Instance.new("TextLabel")
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Position = UDim2.new(1, -20, 0, 0)
    arrowLabel.Size = UDim2.new(0, 20, 1, 0)
    arrowLabel.Font = Enum.Font.GothamBold
    arrowLabel.Text = "▼"
    arrowLabel.TextColor3 = self.Theme.Accent
    arrowLabel.TextSize = 10
    arrowLabel.Parent = dropdownBtn
    
    -- Dropdown List
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Name = "MultiDropdownList_" .. labelText .. "_" .. HttpService:GenerateGUID(false)
    dropdownList.BackgroundColor3 = self.Theme.Card
    dropdownList.Size = UDim2.new(0, 200, 0, 0)
    dropdownList.ScrollBarThickness = 2
    dropdownList.ScrollBarImageColor3 = self.Theme.Accent
    dropdownList.Visible = false
    dropdownList.ZIndex = 2000
    dropdownList.BorderSizePixel = 0
    dropdownList.Parent = self.ScreenGui
    self:CreateCorner(dropdownList, UDim.new(0, 6))
    
    -- Store references for closing system
    dropdownList:SetAttribute("ArrowLabel", arrowLabel)
    dropdownList:SetAttribute("DropdownStroke", dropdownStroke)
    dropdownList:SetAttribute("IsOpen", false)
    
    local listStroke = self:CreateStroke(dropdownList, self.Theme.Accent, 1.5, 0)
    
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
    
    local function updateDropdownHeight()
        local contentHeight = listLayout.AbsoluteContentSize.Y + 12
        local maxHeight = 180
        local targetHeight = math.min(contentHeight, maxHeight)
        self:Tween(dropdownList, {Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X, 0, targetHeight)}, 0.3)
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
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
            optionFrame.BackgroundColor3 = isSelected and Color3.fromRGB(40, 60, 40) or self.Theme.Input
            optionFrame.Size = UDim2.new(1, 0, 0, 32)
            optionFrame.ZIndex = 2001
            optionFrame.Parent = dropdownList
            self:CreateCorner(optionFrame, UDim.new(0, 6))
            
            if isSelected then
                local selectedGlow = self:CreateStroke(optionFrame, Color3.fromRGB(80, 255, 80), 1.5, 0.3)
            end
            
            local optionBtn = Instance.new("TextButton")
            optionBtn.Name = option
            optionBtn.BackgroundTransparency = 1
            optionBtn.Size = UDim2.new(1, 0, 1, 0)
            optionBtn.Font = Enum.Font.GothamSemibold
            optionBtn.Text = (isSelected and ("⭐ " .. priority .. ". ") or "    ") .. option
            optionBtn.TextColor3 = isSelected and Color3.fromRGB(150, 255, 150) or self.Theme.TextSecondary
            optionBtn.TextSize = 11
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
                    self:Tween(optionFrame, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.15)
                else
                    self:Tween(optionFrame, {BackgroundColor3 = Color3.fromRGB(50, 75, 50)}, 0.15)
                end
            end)
            
            optionBtn.MouseLeave:Connect(function()
                if not isSelected then
                    self:Tween(optionFrame, {BackgroundColor3 = self.Theme.Input}, 0.15)
                else
                    self:Tween(optionFrame, {BackgroundColor3 = Color3.fromRGB(40, 60, 40)}, 0.15)
                end
            end)
        end
        
        updateDropdownHeight()
    end
    
    -- ========== FIXED POSITIONING FUNCTION ==========
    local function positionDropdown()
        local absPos = dropdownBtn.AbsolutePosition
        local absSize = dropdownBtn.AbsoluteSize
        local screenHeight = workspace.CurrentCamera.ViewportSize.Y
        local dropdownHeight = math.min(listLayout.AbsoluteContentSize.Y + 12, 180)
        
        -- Calculate available space
        local spaceBelow = screenHeight - (absPos.Y + absSize.Y)
        local spaceAbove = absPos.Y
        
        -- Decide position: prefer below, but go above if not enough space
        local openAbove = false
        if spaceBelow < dropdownHeight and spaceAbove > dropdownHeight then
            openAbove = true
        end
        
        if openAbove then
            -- Open ABOVE the button
            dropdownList.Position = UDim2.fromOffset(absPos.X, absPos.Y - dropdownHeight - 4)
        else
            -- Open BELOW the button (default)
            dropdownList.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 4)
        end
    end
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if isOpen then
            -- Close
            isOpen = false
            dropdownList:SetAttribute("IsOpen", false)
            
            -- Remove from active list
            for i, dd in ipairs(self.ActiveDropdowns) do
                if dd == dropdownList then
                    table.remove(self.ActiveDropdowns, i)
                    break
                end
            end
            
            self:Tween(dropdownList, {Size = UDim2.new(0, dropdownBtn.AbsoluteSize.X, 0, 0)}, 0.3)
            self:Tween(dropdownStroke, {Transparency = 0.6}, 0.2)
            self:Tween(arrowLabel, {Rotation = 0}, 0.2)
            task.wait(0.3)
            dropdownList.Visible = false
        else
            -- Close other dropdowns first
            self:CloseAllDropdowns()
            
            -- Position and open
            dropdownList.Visible = true
            populateList()
            positionDropdown() -- FIXED: Smart positioning
            
            self:Tween(dropdownStroke, {Transparency = 0.2}, 0.2)
            self:Tween(arrowLabel, {Rotation = 180}, 0.2)
            
            isOpen = true
            dropdownList:SetAttribute("IsOpen", true)
            table.insert(self.ActiveDropdowns, dropdownList)
        end
    end)
    
    dropdownBtn.MouseEnter:Connect(function()
        self:Tween(dropdownBtn, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}, 0.15)
        self:Tween(dropdownStroke, {Transparency = 0.3}, 0.15)
    end)
    
    dropdownBtn.MouseLeave:Connect(function()
        self:Tween(dropdownBtn, {BackgroundColor3 = self.Theme.Input}, 0.15)
        if not isOpen then
            self:Tween(dropdownStroke, {Transparency = 0.6}, 0.15)
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
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local checkbox = Instance.new("TextButton")
    checkbox.Name = "Checkbox"
    checkbox.BackgroundColor3 = default and self.Theme.Accent or self.Theme.Input
    checkbox.Position = UDim2.new(0, 12, 0.5, -10)
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Font = Enum.Font.GothamBold
    checkbox.Text = default and "✓" or ""
    checkbox.TextColor3 = self.Theme.Text
    checkbox.TextSize = 14
    checkbox.Parent = frame
    self:CreateCorner(checkbox, UDim.new(0, 4))
    
    local checkboxStroke = self:CreateStroke(checkbox, self.Theme.Accent, 1.5, 0.5)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 42, 0, 0)
    label.Size = UDim2.new(1, -54, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = 13
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
    local size = config.Size or UDim2.new(1, 0, 0, 30)
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = size
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(1, -24, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = color
    label.TextSize = 13
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
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, 110)
    frame.Active = true
    frame.Parent = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    
    local statusStroke = self:CreateStroke(frame, self.Theme.Accent, 2, 0.2)
    
    -- Pulsing animation
    spawn(function()
        while frame.Parent do
            self:Tween(statusStroke, {Transparency = 0}, 0.8)
            task.wait(0.8)
            self:Tween(statusStroke, {Transparency = 0.4}, 0.8)
            task.wait(0.8)
        end
    end)
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 32)
    header.Parent = frame
    self:CreateCorner(header, UDim.new(0, 10))
    
    local headerCover = Instance.new("Frame")
    headerCover.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    headerCover.BorderSizePixel = 0
    headerCover.Size = UDim2.new(1, 0, 0, 10)
    headerCover.Position = UDim2.new(0, 0, 1, -10)
    headerCover.Parent = header
    
    local statusTitle = Instance.new("TextLabel")
    statusTitle.BackgroundTransparency = 1
    statusTitle.Size = UDim2.new(1, -10, 1, 0)
    statusTitle.Position = UDim2.new(0, 10, 0, 0)
    statusTitle.Font = Enum.Font.GothamBold
    statusTitle.Text = title
    statusTitle.TextColor3 = self.Theme.Text
    statusTitle.TextSize = 11
    statusTitle.TextXAlignment = Enum.TextXAlignment.Left
    statusTitle.Parent = header
    
    local content = Instance.new("Frame")
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 10, 0, 38)
    content.Size = UDim2.new(1, -20, 1, -44)
    content.Parent = frame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Font = Enum.Font.GothamSemibold
    statusLabel.Text = "● Idle"
    statusLabel.TextColor3 = self.Theme.TextMuted
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = content
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.BackgroundTransparency = 1
    infoLabel.Position = UDim2.new(0, 0, 0, 24)
    infoLabel.Size = UDim2.new(1, 0, 0, 18)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Text = "Ready"
    infoLabel.TextColor3 = self.Theme.TextSecondary
    infoLabel.TextSize = 10
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = content
    
    local loadingBarBg = Instance.new("Frame")
    loadingBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    loadingBarBg.Position = UDim2.new(0, 0, 1, -8)
    loadingBarBg.Size = UDim2.new(1, 0, 0, 4)
    loadingBarBg.ClipsDescendants = true
    loadingBarBg.Parent = content
    self:CreateCorner(loadingBarBg, UDim.new(1, 0))
    
    local loadingBar = Instance.new("Frame")
    loadingBar.BackgroundColor3 = self.Theme.Accent
    loadingBar.Size = UDim2.new(0, 0, 1, 0)
    loadingBar.BorderSizePixel = 0
    loadingBar.Parent = loadingBarBg
    self:CreateCorner(loadingBar, UDim.new(1, 0))
    
    -- Make draggable
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
    
    local notification = Instance.new("Frame")
    notification.BackgroundColor3 = self.Theme.Card
    notification.Position = UDim2.new(1, 320, 0.9, 0)
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Parent = self.ScreenGui
    self:CreateCorner(notification)
    
    local color = self.Theme.Info
    if type == "success" then
        color = self.Theme.Success
    elseif type == "warning" then
        color = self.Theme.Warning
    elseif type == "error" then
        color = Color3.fromRGB(255, 50, 50)
    end
    
    local stroke = self:CreateStroke(notification, color, 2, 0.3)
    
    local icon = Instance.new("TextLabel")
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(0, 12, 0, 0)
    icon.Size = UDim2.new(0, 30, 1, 0)
    icon.Font = Enum.Font.GothamBlack
    icon.Text = type == "success" and "✓" or type == "warning" and "!" or type == "error" and "✕" or "i"
    icon.TextColor3 = color
    icon.TextSize = 24
    icon.Parent = notification
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 50, 0, 0)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = 13
    label.TextWrapped = true
    label.Parent = notification
    
    -- Animate in
    self:Tween(notification, {Position = UDim2.new(1, -320, 0.9, 0)}, 0.5)
    
    task.wait(duration)
    
    -- Animate out
    self:Tween(notification, {Position = UDim2.new(1, 320, 0.9, 0)}, 0.5)
    task.wait(0.5)
    notification:Destroy()
end

-- Destroy UI
function SpectrumX:Destroy()
    if self.DropdownConnection then
        self.DropdownConnection:Disconnect()
    end
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return SpectrumX

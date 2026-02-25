--[[
    SpectrumX UI Library - REMASTERED v2.1 (FIXED)
    Correções: Toggle funcional, Dropdown posicionado abaixo, UI maior, Click outside funcional
--]]

local SpectrumX = {}
SpectrumX.__index = SpectrumX

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- DPI & Scaling System (AUMENTADO)
SpectrumX.DPI = {
    Scale = 1,
    BaseResolution = Vector2.new(1920, 1080),
    IsMobile = false,
    
    -- Tamanhos aumentados (era 520x320, agora 650x420)
    Sizes = {
        Window = Vector2.new(650, 420),        -- AUMENTADO de 520x320
        Header = 50,                           -- AUMENTADO de 42
        Sidebar = 55,                          -- AUMENTADO de 44
        TabButton = 40,                        -- AUMENTADO de 32
        ElementHeight = 45,                    -- AUMENTADO de 36
        Toggle = 24,                           -- AUMENTADO de 20
        Input = 28,                            -- AUMENTADO de 24
        Slider = 8,                            -- AUMENTADO de 6
        Padding = 10,                          -- AUMENTADO de 8
        TextSmall = 12,                        -- AUMENTADO de 11
        TextNormal = 14,                       -- AUMENTADO de 12
        CornerRadius = 8,                      -- AUMENTADO de 6
        FloatingBtn = 55                       -- AUMENTADO de 44
    }
}

-- Calculate optimal scale (AUMENTADO para mobile também)
function SpectrumX:CalculateScale()
    local viewport = workspace.CurrentCamera.ViewportSize
    local deviceType = GuiService:GetPlatform()
    
    self.DPI.IsMobile = (deviceType == Enum.Platform.Android or 
                        deviceType == Enum.Platform.IOS or
                        viewport.X < 800)
    
    local widthScale = viewport.X / self.DPI.BaseResolution.X
    local heightScale = viewport.Y / self.DPI.BaseResolution.Y
    local rawScale = math.min(widthScale, heightScale)
    
    if self.DPI.IsMobile then
        -- Mobile: escala maior
        self.DPI.Scale = math.clamp(rawScale * 1.3, 0.9, 1.3)  -- AUMENTADO
    else
        -- PC: escala maior (era max 1.0, agora 1.2)
        self.DPI.Scale = math.clamp(rawScale, 0.8, 1.2)  -- AUMENTADO max para 1.2
    end
    
    return self.DPI.Scale
end

-- Utility: Scale a number based on DPI
function SpectrumX:Scale(value)
    return math.floor(value * self.DPI.Scale)
end

-- Utility: Scale UDim2
function SpectrumX:ScaleUDim2(scaleX, offsetX, scaleY, offsetY)
    return UDim2.new(scaleX, self:Scale(offsetX), scaleY, self:Scale(offsetY))
end

-- Utility: Scale Vector2
function SpectrumX:ScaleVector2(x, y)
    return Vector2.new(self:Scale(x), self:Scale(y))
end

-- Theme Configuration
SpectrumX.Theme = {
    Background = Color3.fromRGB(8, 8, 8),
    Header = Color3.fromRGB(12, 12, 12),
    Sidebar = Color3.fromRGB(10, 10, 10),
    Content = Color3.fromRGB(12, 12, 12),
    Card = Color3.fromRGB(20, 20, 20),
    Input = Color3.fromRGB(28, 28, 28),
    Accent = Color3.fromRGB(255, 45, 45),
    AccentSecondary = Color3.fromRGB(255, 85, 85),
    Text = Color3.fromRGB(245, 245, 245),
    TextSecondary = Color3.fromRGB(170, 170, 170),
    TextMuted = Color3.fromRGB(120, 120, 120),
    Success = Color3.fromRGB(45, 220, 90),
    Warning = Color3.fromRGB(255, 180, 60),
    Info = Color3.fromRGB(80, 160, 255),
    Border = Color3.fromRGB(35, 35, 35),
    ToggleOff = Color3.fromRGB(45, 45, 45),
    ToggleOn = Color3.fromRGB(255, 45, 45),
    Shadow = Color3.fromRGB(0, 0, 0)
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
    corner.CornerRadius = UDim.new(0, self:Scale(radius or self.DPI.Sizes.CornerRadius))
    corner.Parent = parent
    return corner
end

function SpectrumX:CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or self.Theme.Accent
    stroke.Thickness = self:Scale(thickness or 1)
    stroke.Transparency = transparency or 0
    stroke.Parent = parent
    return stroke
end

function SpectrumX:CreateShadow(parent, intensity)
    intensity = intensity or 0.6
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, self:Scale(30), 1, self:Scale(30))
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = self.Theme.Shadow
    shadow.ImageTransparency = intensity
    shadow.Parent = parent
    return shadow
end

-- Icon/Image Helper
function SpectrumX:CreateIcon(parent, config)
    config = config or {}
    local iconType = config.Type or "Text"
    local content = config.Content or "S"
    local size = config.Size or 24
    local position = config.Position or UDim2.new(0, 0, 0, 0)
    local color = config.Color or self.Theme.Accent
    
    local container = Instance.new("Frame")
    container.Name = "IconContainer"
    container.BackgroundTransparency = 1
    container.Position = position
    container.Size = UDim2.new(0, self:Scale(size), 0, self:Scale(size))
    container.Parent = parent
    
    if iconType == "Image" and content then
        local assetId = content
        if type(content) == "string" and content:match("^rbxassetid://") then
            assetId = content
        elseif type(content) == "number" or (type(content) == "string" and content:match("^%d+$")) then
            assetId = "rbxassetid://" .. tostring(content):gsub("rbxassetid://", "")
        end
        
        local image = Instance.new("ImageLabel")
        image.Name = "IconImage"
        image.BackgroundTransparency = 1
        image.Size = UDim2.new(1, 0, 1, 0)
        image.Image = assetId
        image.ImageColor3 = color
        image.Parent = container
        
        image.ImageLoaded:Connect(function()
            image.ImageColor3 = Color3.new(1, 1, 1)
        end)
    else
        local label = Instance.new("TextLabel")
        label.Name = "IconText"
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Font = Enum.Font.GothamBlack
        label.Text = content:sub(1, 1):upper()
        label.TextColor3 = color
        label.TextSize = self:Scale(size * 0.6)
        label.Parent = container
    end
    
    return container
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

-- Main Window Creation
function SpectrumX:CreateWindow(config)
    config = config or {}
    local window = setmetatable({}, self)
    
    self:CalculateScale()
    
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
    
    local viewport = workspace.CurrentCamera.ViewportSize
    local windowSize = self:ScaleVector2(self.DPI.Sizes.Window.X, self.DPI.Sizes.Window.Y)
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Position = config.Position or UDim2.new(0.5, -windowSize.X/2, 0.5, -windowSize.Y/2)
    self.MainFrame.Size = config.Size or UDim2.new(0, windowSize.X, 0, windowSize.Y)
    self.MainFrame.Active = true
    self.MainFrame.Visible = true
    self.MainFrame.Parent = self.ScreenGui
    
    self:CreateCorner(self.MainFrame, self.DPI.Sizes.CornerRadius)
    self:CreateShadow(self.MainFrame, 0.7)
    self:CreateStroke(self.MainFrame, self.Theme.Border, 1, 0.5)
    
    local headerHeight = self:Scale(self.DPI.Sizes.Header)
    self.Header = Instance.new("Frame")
    self.Header.Name = "Header"
    self.Header.BackgroundColor3 = self.Theme.Header
    self.Header.BorderSizePixel = 0
    self.Header.Size = UDim2.new(1, 0, 0, headerHeight)
    self.Header.Parent = self.MainFrame
    
    self:CreateCorner(self.Header, self.DPI.Sizes.CornerRadius)
    
    local headerCover = Instance.new("Frame")
    headerCover.BorderSizePixel = 0
    headerCover.BackgroundColor3 = self.Theme.Header
    headerCover.Size = UDim2.new(1, 0, 0, self:Scale(self.DPI.Sizes.CornerRadius))
    headerCover.Position = UDim2.new(0, 0, 1, -self:Scale(self.DPI.Sizes.CornerRadius))
    headerCover.Parent = self.Header
    
    local iconSize = self:Scale(32)
    local iconConfig = {
        Type = config.IconType or "Text",
        Content = config.Icon or config.Title and config.Title:sub(1,1) or "S",
        Size = 32,
        Position = UDim2.new(0, self:Scale(15), 0.5, -iconSize/2),
        Color = self.Theme.Accent
    }
    self:CreateIcon(self.Header, iconConfig)
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = self:ScaleUDim2(0, 55, 0, 0)
    title.Size = self:ScaleUDim2(0, 300, 1, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = config.Title or "Spectrum X"
    title.TextColor3 = self.Theme.Text
    title.TextSize = self:Scale(18)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self.Header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position = self:ScaleUDim2(1, -42, 0.5, -14)
    closeBtn.Size = self:ScaleUDim2(0, 28, 0, 28)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "×"
    closeBtn.TextColor3 = self.Theme.TextMuted
    closeBtn.TextSize = self:Scale(22)
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
    
    local sidebarWidth = self:Scale(self.DPI.Sizes.Sidebar)
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.BackgroundColor3 = self.Theme.Sidebar
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Position = UDim2.new(0, 0, 0, headerHeight)
    self.Sidebar.Size = UDim2.new(0, sidebarWidth, 1, -headerHeight)
    self.Sidebar.Parent = self.MainFrame
    
    self:CreateCorner(self.Sidebar, self.DPI.Sizes.CornerRadius)
    
    local sidebarCover = Instance.new("Frame")
    sidebarCover.BackgroundColor3 = self.Theme.Sidebar
    sidebarCover.BorderSizePixel = 0
    sidebarCover.Size = UDim2.new(1, 0, 0, self:Scale(self.DPI.Sizes.CornerRadius))
    sidebarCover.Parent = self.Sidebar
    
    local sidebarLayout = Instance.new("UIListLayout")
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarLayout.Padding = UDim.new(0, self:Scale(8))
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarLayout.Parent = self.Sidebar
    
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.PaddingTop = UDim.new(0, self:Scale(10))
    sidebarPadding.Parent = self.Sidebar
    
    local contentPadding = self:Scale(10)
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Position = UDim2.new(0, sidebarWidth + contentPadding, 0, headerHeight + contentPadding)
    self.ContentArea.Size = UDim2.new(1, -(sidebarWidth + contentPadding * 2), 1, -(headerHeight + contentPadding * 2))
    self.ContentArea.Parent = self.MainFrame
    
    self.Tabs = {}
    self.CurrentTab = nil
    self.ActiveDropdowns = {} -- Track active dropdowns for click-outside
    
    self:MakeDraggable(self.MainFrame, self.Header)
    self:CreateFloatingButton(config)
    
    -- FIXED: Global click-outside handler
    self:SetupGlobalClickHandler()
    
    return window
end

-- FIXED: Global click handler for dropdowns
function SpectrumX:SetupGlobalClickHandler()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and 
           input.UserInputType ~= Enum.UserInputType.Touch then return end
        
        local clickPos = input.Position
        
        -- Check all active dropdowns
        for dropdownData, _ in pairs(self.ActiveDropdowns or {}) do
            if dropdownData and dropdownData.IsOpen then
                local list = dropdownData.List
                local btn = dropdownData.Button
                
                if list and btn then
                    local listPos = list.AbsolutePosition
                    local listSize = list.AbsoluteSize
                    local btnPos = btn.AbsolutePosition
                    local btnSize = btn.AbsoluteSize
                    
                    local inList = clickPos.X >= listPos.X and clickPos.X <= listPos.X + listSize.X and
                                   clickPos.Y >= listPos.Y and clickPos.Y <= listPos.Y + listSize.Y
                    local inBtn = clickPos.X >= btnPos.X and clickPos.X <= btnPos.X + btnSize.X and
                                  clickPos.Y >= btnPos.Y and clickPos.Y <= btnPos.Y + btnSize.Y
                    
                    if not inList and not inBtn then
                        -- Close this dropdown
                        dropdownData.CloseCallback()
                    end
                end
            end
        end
    end)
end

-- Floating Toggle Button
function SpectrumX:CreateFloatingButton(config)
    local btnSize = self:Scale(self.DPI.Sizes.FloatingBtn)
    
    self.FloatBtn = Instance.new("ImageButton")
    self.FloatBtn.Name = "FloatBtn"
    self.FloatBtn.BackgroundColor3 = self.Theme.Accent
    self.FloatBtn.Position = self:ScaleUDim2(0, 15, 0.5, -btnSize/2)
    self.FloatBtn.Size = UDim2.new(0, btnSize, 0, btnSize)
    self.FloatBtn.Image = ""
    self.FloatBtn.Parent = self.ScreenGui
    self:CreateCorner(self.FloatBtn, self.DPI.Sizes.CornerRadius + 2)
    
    local floatIconConfig = {
        Type = config.FloatingIconType or "Text",
        Content = config.FloatingIcon or config.Icon or "S",
        Size = 28,
        Position = UDim2.new(0.5, -self:Scale(14), 0.5, -self:Scale(14)),
        Color = self.Theme.Text
    }
    self:CreateIcon(self.FloatBtn, floatIconConfig)
    
    local floatShadow = Instance.new("ImageLabel")
    floatShadow.BackgroundTransparency = 1
    floatShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    floatShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    floatShadow.Size = UDim2.new(1, self:Scale(12), 1, self:Scale(12))
    floatShadow.ZIndex = -1
    floatShadow.Image = "rbxassetid://6015897843"
    floatShadow.ImageColor3 = Color3.new(0, 0, 0)
    floatShadow.ImageTransparency = 0.6
    floatShadow.Parent = self.FloatBtn
    
    local fDragging, fDragStart, fStartPos, dragThreshold = false, nil, nil, 5
    
    self.FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            fDragging = false
            fDragStart = input.Position
            fStartPos = self.FloatBtn.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                    if not fDragging then
                        self.MainFrame.Visible = not self.MainFrame.Visible
                    end
                    fDragging = false
                end
            end)
        end
    end)
    
    self.FloatBtn.InputChanged:Connect(function(input)
        if fDragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch) then
            local delta = (input.Position - fDragStart).Magnitude
            if delta > dragThreshold then
                fDragging = true
                local deltaPos = input.Position - fDragStart
                self.FloatBtn.Position = UDim2.new(
                    fStartPos.X.Scale, fStartPos.X.Offset + deltaPos.X,
                    fStartPos.Y.Scale, fStartPos.Y.Offset + deltaPos.Y
                )
            end
        end
    end)
end

-- Create Tab
function SpectrumX:CreateTab(config)
    config = config or {}
    local tabId = config.Name or "Tab"
    local tabIcon = config.Icon or string.sub(tabId, 1, 1)
    local iconType = config.IconId and "Image" or "Text"
    local iconContent = config.IconId or tabIcon
    
    local tabSize = self:Scale(self.DPI.Sizes.TabButton)
    
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabId .. "Tab"
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabBtn.Size = UDim2.new(0, tabSize, 0, tabSize)
    tabBtn.Text = ""
    tabBtn.Parent = self.Sidebar
    self:CreateCorner(tabBtn, self.DPI.Sizes.CornerRadius - 2)
    
    local iconConfig = {
        Type = iconType,
        Content = iconContent,
        Size = 20,
        Position = UDim2.new(0.5, -self:Scale(10), 0.5, -self:Scale(10)),
        Color = self.Theme.TextMuted
    }
    local iconContainer = self:CreateIcon(tabBtn, iconConfig)
    
    local pageContainer = Instance.new("Frame")
    pageContainer.Name = tabId .. "PageContainer"
    pageContainer.BackgroundTransparency = 1
    pageContainer.Size = UDim2.new(1, 0, 1, 0)
    pageContainer.Visible = false
    pageContainer.Parent = self.ContentArea
    
    local useTwoColumns = config.TwoColumns ~= false
    
    if useTwoColumns then
        local divider = Instance.new("Frame")
        divider.BackgroundColor3 = self.Theme.Border
        divider.BorderSizePixel = 0
        divider.Position = UDim2.new(0.5, -self:Scale(0.5), 0, 0)
        divider.Size = UDim2.new(0, 1, 1, 0)
        divider.Parent = pageContainer
        
        local leftSide = Instance.new("ScrollingFrame")
        leftSide.Name = "LeftSide"
        leftSide.BackgroundTransparency = 1
        leftSide.BorderSizePixel = 0
        leftSide.Size = UDim2.new(0.48, 0, 1, 0)
        leftSide.ScrollBarThickness = self:Scale(2)
        leftSide.ScrollBarImageColor3 = self.Theme.Accent
        leftSide.Parent = pageContainer
        
        local leftLayout = Instance.new("UIListLayout")
        leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        leftLayout.Padding = UDim.new(0, self:Scale(self.DPI.Sizes.Padding))
        leftLayout.Parent = leftSide
        
        leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            leftSide.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + self:Scale(10))
        end)
        
        local rightSide = Instance.new("ScrollingFrame")
        rightSide.Name = "RightSide"
        rightSide.BackgroundTransparency = 1
        rightSide.BorderSizePixel = 0
        rightSide.Position = UDim2.new(0.52, 0, 0, 0)
        rightSide.Size = UDim2.new(0.48, 0, 1, 0)
        rightSide.ScrollBarThickness = self:Scale(2)
        rightSide.ScrollBarImageColor3 = self.Theme.Accent
        rightSide.Parent = pageContainer
        
        local rightLayout = Instance.new("UIListLayout")
        rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rightLayout.Padding = UDim.new(0, self:Scale(self.DPI.Sizes.Padding))
        rightLayout.Parent = rightSide
        
        rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            rightSide.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + self:Scale(10))
        end)
        
        local tabData = {
            Button = tabBtn,
            Container = pageContainer,
            Left = leftSide,
            Right = rightSide,
            IconContainer = iconContainer
        }
        self.Tabs[tabId] = tabData
    else
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Name = "Content"
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.ScrollBarThickness = self:Scale(2)
        scrollFrame.ScrollBarImageColor3 = self.Theme.Accent
        scrollFrame.Parent = pageContainer
        
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, self:Scale(self.DPI.Sizes.Padding))
        layout.Parent = scrollFrame
        
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + self:Scale(10))
        end)
        
        local tabData = {
            Button = tabBtn,
            Container = pageContainer,
            Content = scrollFrame,
            IconContainer = iconContainer
        }
        self.Tabs[tabId] = tabData
    end
    
    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(tabId)
    end)
    
    if not self.CurrentTab then
        self:SelectTab(tabId)
    end
    
    return self.Tabs[tabId]
end

-- Select Tab
function SpectrumX:SelectTab(tabId)
    for id, data in pairs(self.Tabs) do
        if id == tabId then
            data.Container.Visible = true
            self:Tween(data.Button, {BackgroundColor3 = self.Theme.Accent}, 0.2)
            
            if data.IconContainer then
                local icon = data.IconContainer:FindFirstChild("IconText") or data.IconContainer:FindFirstChild("IconImage")
                if icon then
                    self:Tween(icon, {TextColor3 = self.Theme.Text}, 0.2)
                    if icon:IsA("ImageLabel") then
                        self:Tween(icon, {ImageColor3 = self.Theme.Text}, 0.2)
                    end
                end
            end
        else
            data.Container.Visible = false
            self:Tween(data.Button, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}, 0.2)
            
            if data.IconContainer then
                local icon = data.IconContainer:FindFirstChild("IconText") or data.IconContainer:FindFirstChild("IconImage")
                if icon then
                    self:Tween(icon, {TextColor3 = self.Theme.TextMuted}, 0.2)
                    if icon:IsA("ImageLabel") then
                        self:Tween(icon, {ImageColor3 = self.Theme.TextMuted}, 0.2)
                    end
                end
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
    section.Text = text:upper()
    section.TextColor3 = color or self.Theme.Accent
    section.TextSize = self:Scale(self.DPI.Sizes.TextSmall)
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = parent
    return section
end

-- FIXED Create Toggle (CORRIGIDO)
function SpectrumX:CreateToggle(parent, config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, self:Scale(self.DPI.Sizes.ElementHeight))
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = self:ScaleUDim2(0, 12, 0, 0)
    label.Size = self:ScaleUDim2(0.7, 0, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(self.DPI.Sizes.TextNormal)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local switchWidth = self:Scale(44)
    local switchHeight = self:Scale(self.DPI.Sizes.Toggle)
    
    local switchBg = Instance.new("TextButton")
    switchBg.Text = ""
    switchBg.BackgroundColor3 = default and self.Theme.ToggleOn or self.Theme.ToggleOff
    switchBg.Position = UDim2.new(1, -switchWidth - self:Scale(12), 0.5, -switchHeight/2)
    switchBg.Size = UDim2.new(0, switchWidth, 0, switchHeight)
    switchBg.Parent = frame
    self:CreateCorner(switchBg, UDim.new(1, 0))
    
    local circleSize = self:Scale(18)
    local circle = Instance.new("Frame")
    circle.BackgroundColor3 = self.Theme.Text
    circle.Position = default and UDim2.new(1, -circleSize - 2, 0.5, -circleSize/2) or UDim2.new(0, 2, 0.5, -circleSize/2)
    circle.Size = UDim2.new(0, circleSize, 0, circleSize)
    circle.Parent = switchBg
    self:CreateCorner(circle, UDim.new(1, 0))
    
    local state = default
    
    switchBg.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        
        if state then
            self:Tween(switchBg, {BackgroundColor3 = self.Theme.ToggleOn}, 0.2)
            self:Tween(circle, {Position = UDim2.new(1, -circleSize - 2, 0.5, -circleSize/2)}, 0.2)
        else
            self:Tween(switchBg, {BackgroundColor3 = self.Theme.ToggleOff}, 0.2)
            self:Tween(circle, {Position = UDim2.new(0, 2, 0.5, -circleSize/2)}, 0.2)
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
                self:Tween(circle, {Position = UDim2.new(1, -circleSize - 2, 0.5, -circleSize/2)}, 0.2)
            else
                self:Tween(switchBg, {BackgroundColor3 = self.Theme.ToggleOff}, 0.2)
                self:Tween(circle, {Position = UDim2.new(0, 2, 0.5, -circleSize/2)}, 0.2)
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
    frame.Size = UDim2.new(1, 0, 0, self:Scale(48))
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local btn = Instance.new("TextButton")
    btn.Name = "Button"
    btn.BackgroundColor3 = self.Theme.Card
    btn.Position = self:ScaleUDim2(0.03, 0, 0.08, 0)
    btn.Size = self:ScaleUDim2(0.94, 0, 0.84, 0)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextSize = self:Scale(self.DPI.Sizes.TextNormal)
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
    
    local btnStroke = self:CreateStroke(btn, color, 1, 0.6)
    
    btn.MouseEnter:Connect(function()
        self:Tween(btn, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}, 0.2)
        self:Tween(btnStroke, {Transparency = 0.2}, 0.2)
    end)
    
    btn.MouseLeave:Connect(function()
        self:Tween(btn, {BackgroundColor3 = self.Theme.Card}, 0.2)
        self:Tween(btnStroke, {Transparency = 0.6}, 0.2)
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
    frame.Size = UDim2.new(1, 0, 0, self:Scale(58))
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = self:ScaleUDim2(0, 12, 0, 0)
    label.Size = self:ScaleUDim2(0.6, 0, 0.55, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(self.DPI.Sizes.TextNormal)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local box = Instance.new("TextBox")
    box.BackgroundColor3 = self.Theme.Input
    box.Position = self:ScaleUDim2(0.03, 0, 0.5, -2)
    box.Size = self:ScaleUDim2(0.94, 0, 0, self.DPI.Sizes.Input)
    box.Font = Enum.Font.Gotham
    box.Text = tostring(default)
    box.PlaceholderText = placeholder
    box.TextColor3 = self.Theme.Text
    box.TextSize = self:Scale(self.DPI.Sizes.TextSmall)
    box.Parent = frame
    self:CreateCorner(box, self.DPI.Sizes.CornerRadius - 2)
    
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
    frame.Size = UDim2.new(1, 0, 0, self:Scale(58))
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = self:ScaleUDim2(0, 12, 0, 0)
    label.Size = self:ScaleUDim2(0.6, 0, 0.55, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(self.DPI.Sizes.TextNormal)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local box = Instance.new("TextBox")
    box.BackgroundColor3 = self.Theme.Input
    box.Position = self:ScaleUDim2(0.03, 0, 0.5, -2)
    box.Size = self:ScaleUDim2(0.94, 0, 0, self.DPI.Sizes.Input)
    box.Font = Enum.Font.Gotham
    box.Text = tostring(default)
    box.TextColor3 = self.Theme.Text
    box.TextSize = self:Scale(self.DPI.Sizes.TextSmall)
    box.Parent = frame
    self:CreateCorner(box, self.DPI.Sizes.CornerRadius - 2)
    
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
    frame.Size = UDim2.new(1, 0, 0, self:Scale(62))
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = self:ScaleUDim2(0, 12, 0, 8)
    label.Size = self:ScaleUDim2(0.5, 0, 0, 20)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(self.DPI.Sizes.TextNormal)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = self:ScaleUDim2(0.6, 0, 0, 8)
    valueLabel.Size = self:ScaleUDim2(0.35, 0, 0, 20)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = self.Theme.Accent
    valueLabel.TextSize = self:Scale(self.DPI.Sizes.TextNormal)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    sliderBg.Position = self:ScaleUDim2(0.03, 0, 0, 38)
    sliderBg.Size = self:ScaleUDim2(0.94, 0, 0, self.DPI.Sizes.Slider)
    sliderBg.Parent = sliderBg
    self:CreateCorner(sliderBg, UDim.new(1, 0))
    
    local sliderFill = Instance.new("Frame")
    sliderFill.BackgroundColor3 = self.Theme.Accent
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.Parent = sliderBg
    self:CreateCorner(sliderFill, UDim.new(1, 0))
    
    local knobSize = self:Scale(14)
    local sliderKnob = Instance.new("Frame")
    sliderKnob.BackgroundColor3 = self.Theme.Text
    sliderKnob.Position = UDim2.new((default - min) / (max - min), -knobSize/2, 0.5, -knobSize/2)
    sliderKnob.Size = UDim2.new(0, knobSize, 0, knobSize)
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
        sliderKnob.Position = UDim2.new(pos, -knobSize/2, 0.5, -knobSize/2)
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
            sliderKnob.Position = UDim2.new(pos, -knobSize/2, 0.5, -knobSize/2)
            valueLabel.Text = tostring(val)
        end
    }
end

-- FIXED Dropdown - Posicionamento abaixo e click outside funcional
function SpectrumX:CreateDropdown(parent, config)
    config = config or {}
    local labelText = config.Label or "Dropdown"
    local options = config.Options or {}
    local default = config.Default
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, self:Scale(58))
    frame.ClipsDescendants = false
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = self:ScaleUDim2(0, 12, 0, 6)
    label.Size = self:ScaleUDim2(1, -24, 0, 18)
    label.Font = Enum.Font.GothamBold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(self.DPI.Sizes.TextSmall)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.BackgroundColor3 = self.Theme.Input
    dropdownBtn.Position = self:ScaleUDim2(0, 12, 0, 28)
    dropdownBtn.Size = self:ScaleUDim2(1, -24, 0, 26)
    dropdownBtn.Font = Enum.Font.GothamSemibold
    dropdownBtn.Text = "  " .. (default or "Select...")
    dropdownBtn.TextColor3 = self.Theme.TextSecondary
    dropdownBtn.TextSize = self:Scale(11)
    dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropdownBtn.ZIndex = 2
    dropdownBtn.Parent = frame
    self:CreateCorner(dropdownBtn, self.DPI.Sizes.CornerRadius - 2)
    
    local dropdownStroke = self:CreateStroke(dropdownBtn, self.Theme.Accent, 1, 0.6)
    
    local arrowLabel = Instance.new("TextLabel")
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Position = UDim2.new(1, -22, 0, 0)
    arrowLabel.Size = UDim2.new(0, 22, 1, 0)
    arrowLabel.Font = Enum.Font.GothamBold
    arrowLabel.Text = "▼"
    arrowLabel.TextColor3 = self.Theme.Accent
    arrowLabel.TextSize = self:Scale(10)
    arrowLabel.Parent = dropdownBtn
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Name = "DropdownList_" .. labelText .. "_" .. HttpService:GenerateGUID(false)
    dropdownList.BackgroundColor3 = self.Theme.Card
    dropdownList.Size = UDim2.new(0, 0, 0, 0)
    dropdownList.ScrollBarThickness = self:Scale(2)
    dropdownList.ScrollBarImageColor3 = self.Theme.Accent
    dropdownList.Visible = false
    dropdownList.ZIndex = 100
    dropdownList.BorderSizePixel = 0
    dropdownList.Parent = self.ScreenGui
    self:CreateCorner(dropdownList, self.DPI.Sizes.CornerRadius - 2)
    
    local listStroke = self:CreateStroke(dropdownList, self.Theme.Accent, 1.5, 0)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, self:Scale(4))
    listLayout.Parent = dropdownList
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, self:Scale(6))
    listPadding.PaddingBottom = UDim.new(0, self:Scale(6))
    listPadding.PaddingLeft = UDim.new(0, self:Scale(6))
    listPadding.PaddingRight = UDim.new(0, self:Scale(6))
    listPadding.Parent = dropdownList
    
    local selectedValue = default
    local isOpen = false
    
    -- FIXED: Sempre abrir ABAIXO do botão
    local function positionDropdown()
        local absPos = dropdownBtn.AbsolutePosition
        local absSize = dropdownBtn.AbsoluteSize
        
        -- SEMPRE abaixo do botão (como solicitado)
        local targetY = absPos.Y + absSize.Y + self:Scale(4)
        local targetX = absPos.X
        local targetWidth = absSize.X
        
        -- Calcular altura baseada no conteúdo
        local contentHeight = listLayout.AbsoluteContentSize.Y + self:Scale(12)
        local maxHeight = self:Scale(180)
        local targetHeight = math.min(contentHeight, maxHeight)
        
        -- Verificar se passa da borda inferior da tela
        local viewportY = workspace.CurrentCamera.ViewportSize.Y
        if targetY + targetHeight > viewportY - self:Scale(20) then
            -- Se não couber abaixo, abrir acima (fallback)
            targetY = absPos.Y - targetHeight - self:Scale(4)
        end
        
        dropdownList.Position = UDim2.fromOffset(targetX, targetY)
        dropdownList.Size = UDim2.fromOffset(targetWidth, targetHeight)
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
            optionFrame.BackgroundColor3 = isSelected and Color3.fromRGB(40, 65, 40) or self.Theme.Input
            optionFrame.Size = UDim2.new(1, 0, 0, self:Scale(32))
            optionFrame.ZIndex = 101
            optionFrame.Parent = dropdownList
            self:CreateCorner(optionFrame, self.DPI.Sizes.CornerRadius - 3)
            
            if isSelected then
                self:CreateStroke(optionFrame, Color3.fromRGB(80, 230, 80), 1, 0.3)
            end
            
            local optionBtn = Instance.new("TextButton")
            optionBtn.Name = option
            optionBtn.BackgroundTransparency = 1
            optionBtn.Size = UDim2.new(1, 0, 1, 0)
            optionBtn.Font = Enum.Font.GothamSemibold
            optionBtn.Text = (isSelected and "● " or "    ") .. option
            optionBtn.TextColor3 = isSelected and Color3.fromRGB(140, 255, 140) or self.Theme.TextSecondary
            optionBtn.TextSize = self:Scale(11)
            optionBtn.TextXAlignment = Enum.TextXAlignment.Left
            optionBtn.ZIndex = 102
            optionBtn.Parent = optionFrame
            
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, self:Scale(10))
            padding.Parent = optionBtn
            
            optionBtn.MouseButton1Click:Connect(function()
                selectedValue = option
                dropdownBtn.Text = "  " .. option
                callback(option)
                
                -- Fechar dropdown
                isOpen = false
                self.ActiveDropdowns[dropdownData] = nil
                self:Tween(dropdownList, {Size = UDim2.fromOffset(dropdownList.AbsoluteSize.X, 0)}, 0.25)
                self:Tween(arrowLabel, {Rotation = 0}, 0.2)
                task.wait(0.25)
                dropdownList.Visible = false
            end)
            
            optionBtn.MouseEnter:Connect(function()
                if not isSelected then
                    self:Tween(optionFrame, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.15)
                end
            end)
            
            optionBtn.MouseLeave:Connect(function()
                if not isSelected then
                    self:Tween(optionFrame, {BackgroundColor3 = self.Theme.Input}, 0.15)
                end
            end)
        end
        
        positionDropdown()
    end
    
    -- Dados para o click-outside handler
    local dropdownData = {
        List = dropdownList,
        Button = dropdownBtn,
        IsOpen = false,
        CloseCallback = function()
            isOpen = false
            dropdownData.IsOpen = false
            self.ActiveDropdowns[dropdownData] = nil
            self:Tween(dropdownList, {Size = UDim2.fromOffset(dropdownList.AbsoluteSize.X, 0)}, 0.25)
            self:Tween(dropdownStroke, {Transparency = 0.6}, 0.2)
            self:Tween(arrowLabel, {Rotation = 0}, 0.2)
            task.wait(0.25)
            dropdownList.Visible = false
        end
    }
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if isOpen then
            dropdownData.CloseCallback()
        else
            -- Fechar outros dropdowns
            for otherData, _ in pairs(self.ActiveDropdowns or {}) do
                if otherData ~= dropdownData and otherData.CloseCallback then
                    otherData.CloseCallback()
                end
            end
            
            dropdownList.Visible = true
            populateList()
            isOpen = true
            dropdownData.IsOpen = true
            self.ActiveDropdowns[dropdownData] = true
            self:Tween(dropdownStroke, {Transparency = 0.2}, 0.2)
            self:Tween(arrowLabel, {Rotation = 180}, 0.2)
        end
    end)
    
    dropdownBtn.MouseEnter:Connect(function()
        self:Tween(dropdownBtn, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
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

-- FIXED Multi Dropdown - Mesmas correções
function SpectrumX:CreateMultiDropdown(parent, config)
    config = config or {}
    local labelText = config.Label or "Multi Select"
    local options = config.Options or {}
    local default = config.Default or {}
    local callback = config.Callback or function() end
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = UDim2.new(1, 0, 0, self:Scale(58))
    frame.ClipsDescendants = false
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = self:ScaleUDim2(0, 12, 0, 6)
    label.Size = self:ScaleUDim2(1, -24, 0, 18)
    label.Font = Enum.Font.GothamBold
    label.Text = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(self.DPI.Sizes.TextSmall)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.BackgroundColor3 = self.Theme.Input
    dropdownBtn.Position = self:ScaleUDim2(0, 12, 0, 28)
    dropdownBtn.Size = self:ScaleUDim2(1, -24, 0, 26)
    dropdownBtn.Font = Enum.Font.GothamSemibold
    dropdownBtn.Text = "  Select Options..."
    dropdownBtn.TextColor3 = self.Theme.TextSecondary
    dropdownBtn.TextSize = self:Scale(11)
    dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropdownBtn.ZIndex = 2
    dropdownBtn.Parent = frame
    self:CreateCorner(dropdownBtn, self.DPI.Sizes.CornerRadius - 2)
    
    local dropdownStroke = self:CreateStroke(dropdownBtn, self.Theme.Accent, 1, 0.6)
    
    local arrowLabel = Instance.new("TextLabel")
    arrowLabel.BackgroundTransparency = 1
    arrowLabel.Position = UDim2.new(1, -22, 0, 0)
    arrowLabel.Size = UDim2.new(0, 22, 1, 0)
    arrowLabel.Font = Enum.Font.GothamBold
    arrowLabel.Text = "▼"
    arrowLabel.TextColor3 = self.Theme.Accent
    arrowLabel.TextSize = self:Scale(10)
    arrowLabel.Parent = dropdownBtn
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Name = "MultiDropdownList_" .. labelText .. "_" .. HttpService:GenerateGUID(false)
    dropdownList.BackgroundColor3 = self.Theme.Card
    dropdownList.Size = UDim2.new(0, 0, 0, 0)
    dropdownList.ScrollBarThickness = self:Scale(2)
    dropdownList.ScrollBarImageColor3 = self.Theme.Accent
    dropdownList.Visible = false
    dropdownList.ZIndex = 100
    dropdownList.BorderSizePixel = 0
    dropdownList.Parent = self.ScreenGui
    self:CreateCorner(dropdownList, self.DPI.Sizes.CornerRadius - 2)
    
    local listStroke = self:CreateStroke(dropdownList, self.Theme.Accent, 1.5, 0)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, self:Scale(4))
    listLayout.Parent = dropdownList
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, self:Scale(6))
    listPadding.PaddingBottom = UDim.new(0, self:Scale(6))
    listPadding.PaddingLeft = UDim.new(0, self:Scale(6))
    listPadding.PaddingRight = UDim.new(0, self:Scale(6))
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
        
        -- SEMPRE abaixo
        local targetY = absPos.Y + absSize.Y + self:Scale(4)
        local targetX = absPos.X
        local targetWidth = absSize.X
        
        local contentHeight = listLayout.AbsoluteContentSize.Y + self:Scale(12)
        local maxHeight = self:Scale(180)
        local targetHeight = math.min(contentHeight, maxHeight)
        
        local viewportY = workspace.CurrentCamera.ViewportSize.Y
        if targetY + targetHeight > viewportY - self:Scale(20) then
            targetY = absPos.Y - targetHeight - self:Scale(4)
        end
        
        dropdownList.Position = UDim2.fromOffset(targetX, targetY)
        dropdownList.Size = UDim2.fromOffset(targetWidth, targetHeight)
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
            optionFrame.BackgroundColor3 = isSelected and Color3.fromRGB(40, 65, 40) or self.Theme.Input
            optionFrame.Size = UDim2.new(1, 0, 0, self:Scale(32))
            optionFrame.ZIndex = 101
            optionFrame.Parent = dropdownList
            self:CreateCorner(optionFrame, self.DPI.Sizes.CornerRadius - 3)
            
            if isSelected then
                self:CreateStroke(optionFrame, Color3.fromRGB(80, 230, 80), 1, 0.3)
            end
            
            local optionBtn = Instance.new("TextButton")
            optionBtn.Name = option
            optionBtn.BackgroundTransparency = 1
            optionBtn.Size = UDim2.new(1, 0, 1, 0)
            optionBtn.Font = Enum.Font.GothamSemibold
            optionBtn.Text = (isSelected and ("● " .. priority .. ". ") or "    ") .. option
            optionBtn.TextColor3 = isSelected and Color3.fromRGB(140, 255, 140) or self.Theme.TextSecondary
            optionBtn.TextSize = self:Scale(11)
            optionBtn.TextXAlignment = Enum.TextXAlignment.Left
            optionBtn.ZIndex = 102
            optionBtn.Parent = optionFrame
            
            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, self:Scale(10))
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
                end
            end)
            
            optionBtn.MouseLeave:Connect(function()
                if not isSelected then
                    self:Tween(optionFrame, {BackgroundColor3 = self.Theme.Input}, 0.15)
                end
            end)
        end
        
        positionDropdown()
    end
    
    local dropdownData = {
        List = dropdownList,
        Button = dropdownBtn,
        IsOpen = false,
        CloseCallback = function()
            isOpen = false
            dropdownData.IsOpen = false
            self.ActiveDropdowns[dropdownData] = nil
            self:Tween(dropdownList, {Size = UDim2.fromOffset(dropdownList.AbsoluteSize.X, 0)}, 0.25)
            self:Tween(dropdownStroke, {Transparency = 0.6}, 0.2)
            self:Tween(arrowLabel, {Rotation = 0}, 0.2)
            task.wait(0.25)
            dropdownList.Visible = false
        end
    }
    
    dropdownBtn.MouseButton1Click:Connect(function()
        if isOpen then
            dropdownData.CloseCallback()
        else
            for otherData, _ in pairs(self.ActiveDropdowns or {}) do
                if otherData ~= dropdownData and otherData.CloseCallback then
                    otherData.CloseCallback()
                end
            end
            
            dropdownList.Visible = true
            populateList()
            isOpen = true
            dropdownData.IsOpen = true
            self.ActiveDropdowns[dropdownData] = true
            self:Tween(dropdownStroke, {Transparency = 0.2}, 0.2)
            self:Tween(arrowLabel, {Rotation = 180}, 0.2)
        end
    end)
    
    dropdownBtn.MouseEnter:Connect(function()
        self:Tween(dropdownBtn, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
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
    frame.Size = UDim2.new(1, 0, 0, self:Scale(38))
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local checkSize = self:Scale(18)
    local checkbox = Instance.new("TextButton")
    checkbox.Name = "Checkbox"
    checkbox.BackgroundColor3 = default and self.Theme.Accent or self.Theme.Input
    checkbox.Position = UDim2.new(0, self:Scale(12), 0.5, -checkSize/2)
    checkbox.Size = UDim2.new(0, checkSize, 0, checkSize)
    checkbox.Font = Enum.Font.GothamBold
    checkbox.Text = default and "✓" or ""
    checkbox.TextColor3 = self.Theme.Text
    checkbox.TextSize = self:Scale(12)
    checkbox.Parent = frame
    self:CreateCorner(checkbox, UDim.new(0, self:Scale(4)))
    
    local checkboxStroke = self:CreateStroke(checkbox, self.Theme.Accent, 1, 0.5)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, self:Scale(36), 0, 0)
    label.Size = self:ScaleUDim2(1, -48, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(self.DPI.Sizes.TextNormal)
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
    local size = config.Size or UDim2.new(1, 0, 0, self:Scale(30))
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size = size
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = self:ScaleUDim2(0, 12, 0, 0)
    label.Size = self:ScaleUDim2(1, -24, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = color
    label.TextSize = self:Scale(self.DPI.Sizes.TextNormal)
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
    frame.BackgroundColor3 = self.Theme.Card
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, self:Scale(100))
    frame.Active = true
    frame.Parent = parent
    self:CreateCorner(frame)
    
    local statusStroke = self:CreateStroke(frame, self.Theme.Accent, 1.5, 0.3)
    
    spawn(function()
        while frame.Parent do
            self:Tween(statusStroke, {Transparency = 0.1}, 1)
            task.wait(1)
            self:Tween(statusStroke, {Transparency = 0.4}, 1)
            task.wait(1)
        end
    end)
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, self:Scale(28))
    header.Parent = frame
    self:CreateCorner(header)
    
    local headerCover = Instance.new("Frame")
    headerCover.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    headerCover.BorderSizePixel = 0
    headerCover.Size = UDim2.new(1, 0, 0, self:Scale(6))
    headerCover.Position = UDim2.new(0, 0, 1, -self:Scale(6))
    headerCover.Parent = header
    
    local statusTitle = Instance.new("TextLabel")
    statusTitle.BackgroundTransparency = 1
    statusTitle.Size = self:ScaleUDim2(1, -10, 1, 0)
    statusTitle.Position = self:ScaleUDim2(0, 10, 0, 0)
    statusTitle.Font = Enum.Font.GothamBold
    statusTitle.Text = title
    statusTitle.TextColor3 = self.Theme.Text
    statusTitle.TextSize = self:Scale(11)
    statusTitle.TextXAlignment = Enum.TextXAlignment.Left
    statusTitle.Parent = header
    
    local content = Instance.new("Frame")
    content.BackgroundTransparency = 1
    content.Position = self:ScaleUDim2(0, 10, 0, 32)
    content.Size = self:ScaleUDim2(1, -20, 1, -38)
    content.Parent = frame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(1, 0, 0, self:Scale(20))
    statusLabel.Font = Enum.Font.GothamSemibold
    statusLabel.Text = "● Idle"
    statusLabel.TextColor3 = self.Theme.TextMuted
    statusLabel.TextSize = self:Scale(12)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = content
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.BackgroundTransparency = 1
    infoLabel.Position = UDim2.new(0, 0, 0, self:Scale(22))
    infoLabel.Size = UDim2.new(1, 0, 0, self:Scale(18))
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Text = "Ready"
    infoLabel.TextColor3 = self.Theme.TextSecondary
    infoLabel.TextSize = self:Scale(10)
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = content
    
    local loadingBarBg = Instance.new("Frame")
    loadingBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    loadingBarBg.Position = UDim2.new(0, 0, 1, -self:Scale(6))
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
    
    local notifWidth = math.min(self:Scale(300), workspace.CurrentCamera.ViewportSize.X - self:Scale(40))
    local notifHeight = self:Scale(55)
    
    local notification = Instance.new("Frame")
    notification.BackgroundColor3 = self.Theme.Card
    notification.Position = UDim2.new(1, notifWidth + self:Scale(20), 1, -notifHeight - self:Scale(20))
    notification.Size = UDim2.new(0, notifWidth, 0, notifHeight)
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
    
    local stroke = self:CreateStroke(notification, color, 1.5, 0.2)
    
    local icon = Instance.new("TextLabel")
    icon.BackgroundTransparency = 1
    icon.Position = self:ScaleUDim2(0, 12, 0, 0)
    icon.Size = self:ScaleUDim2(0, 26, 1, 0)
    icon.Font = Enum.Font.GothamBlack
    icon.Text = type == "success" and "✓" or type == "warning" and "!" or type == "error" and "✕" or "i"
    icon.TextColor3 = color
    icon.TextSize = self:Scale(20)
    icon.Parent = notification
    
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = self:ScaleUDim2(0, 44, 0, 0)
    label.Size = self:ScaleUDim2(1, -54, 1, 0)
    label.Font = Enum.Font.GothamSemibold
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.TextSize = self:Scale(12)
    label.TextWrapped = true
    label.Parent = notification
    
    self:Tween(notification, {Position = UDim2.new(1, -notifWidth - self:Scale(20), 1, -notifHeight - self:Scale(20))}, 0.4)
    
    task.wait(duration)
    
    self:Tween(notification, {Position = UDim2.new(1, notifWidth + self:Scale(20), 1, -notifHeight - self:Scale(20))}, 0.4)
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

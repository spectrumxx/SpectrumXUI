--[[
    SpectrumX UI Library - Remastered Final
    Visual moderno, responsivo (PC/Mobile), dropdowns corrigidos,
    notificações empilhadas, suporte a AssetId.
    API 100% compatível. Funciona via loadstring.
    
    Uso:
        local SpectrumX = loadstring(game:HttpGet("URL"))()
]]

local SpectrumX = {}
SpectrumX.__index = SpectrumX

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ─── Theme ────────────────────────────────────────────────────────────────────
SpectrumX.Theme = {
    Background      = Color3.fromRGB(22, 22, 28),
    Header          = Color3.fromRGB(28, 28, 36),
    Sidebar         = Color3.fromRGB(28, 28, 36),
    Content         = Color3.fromRGB(22, 22, 28),
    Card            = Color3.fromRGB(35, 35, 45),
    Input           = Color3.fromRGB(45, 45, 58),
    Accent          = Color3.fromRGB(255, 65, 65),
    AccentSecondary = Color3.fromRGB(255, 130, 130),
    Text            = Color3.fromRGB(250, 250, 250),
    TextSecondary   = Color3.fromRGB(180, 180, 190),
    TextMuted       = Color3.fromRGB(130, 130, 140),
    Success         = Color3.fromRGB(85, 230, 130),
    Warning         = Color3.fromRGB(255, 200, 90),
    Info            = Color3.fromRGB(100, 180, 255),
    Border          = Color3.fromRGB(50, 50, 65),
    ToggleOff       = Color3.fromRGB(60, 60, 75),
    ToggleOn        = Color3.fromRGB(255, 65, 65),
}

-- ─── Escala responsiva ────────────────────────────────────────────────────────
local ScaleData = {
    IsMobile    = false,
    ScaleFactor = 1,
    BaseWidth   = 1920,
    BaseHeight  = 1080,
}

function SpectrumX:UpdateScale()
    local ok, cam = pcall(function() return workspace.CurrentCamera end)
    if not ok or not cam then return end
    local vp = cam.ViewportSize
    if vp.X == 0 then return end
    local w, h = vp.X, vp.Y
    ScaleData.IsMobile = UserInputService.TouchEnabled and (w < 1200 or h < 700)
    local base = math.min(w / ScaleData.BaseWidth, h / ScaleData.BaseHeight)
    ScaleData.ScaleFactor = math.clamp(base, ScaleData.IsMobile and 0.9 or 0.85, ScaleData.IsMobile and 1.15 or 1.05)
end

function SpectrumX:S(value)
    if type(value) == "number" then
        return math.floor(value * ScaleData.ScaleFactor)
    elseif typeof(value) == "UDim2" then
        return UDim2.new(
            value.X.Scale, math.floor(value.X.Offset * ScaleData.ScaleFactor),
            value.Y.Scale, math.floor(value.Y.Offset * ScaleData.ScaleFactor)
        )
    end
    return value
end

-- ─── Utilitários ─────────────────────────────────────────────────────────────
function SpectrumX:Tween(obj, props, time, style, dir)
    local t = TweenService:Create(obj,
        TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

function SpectrumX:CreateCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, 8)
    c.Parent = parent
    return c
end

function SpectrumX:CreateStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color        = color or self.Theme.Border
    s.Thickness    = thickness or 1
    s.Transparency = transparency or 0.85
    s.Parent       = parent
    return s
end

function SpectrumX:CreateShadow(parent, size)
    local sh = Instance.new("ImageLabel")
    sh.Name               = "Shadow"
    sh.AnchorPoint        = Vector2.new(0.5, 0.5)
    sh.BackgroundTransparency = 1
    sh.Position           = UDim2.new(0.5, 0, 0.5, 0)
    sh.Size               = self:S(UDim2.new(1, size or 50, 1, size or 50))
    sh.ZIndex             = -1
    sh.Image              = "rbxassetid://6015897843"
    sh.ImageColor3        = Color3.fromRGB(0, 0, 0)
    sh.ImageTransparency  = 0.55
    sh.Parent             = parent
    return sh
end

function SpectrumX:MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ─── FECHAR DROPDOWNS AO CLICAR FORA ─────────────────────────────────────────
function SpectrumX:_RegisterDropdown(dropList, btnRef, closeFn)
    if not self._dropCloseFuncs then self._dropCloseFuncs = {} end
    table.insert(self._dropCloseFuncs, {list = dropList, btn = btnRef, close = closeFn})
    table.insert(self.Dropdowns, dropList)
end

function SpectrumX:_CloseDropdownsOnClickOutside(pos)
    if not self._dropCloseFuncs then return end
    for _, entry in ipairs(self._dropCloseFuncs) do
        local dl = entry.list
        local db = entry.btn
        if not dl or not dl.Visible then continue end
        local lp, ls = dl.AbsolutePosition, dl.AbsoluteSize
        local bp, bs = db.AbsolutePosition, db.AbsoluteSize
        local inList = pos.X >= lp.X and pos.X <= lp.X + ls.X and pos.Y >= lp.Y and pos.Y <= lp.Y + ls.Y
        local inBtn  = pos.X >= bp.X and pos.X <= bp.X + bs.X and pos.Y >= bp.Y and pos.Y <= bp.Y + bs.Y
        if not inList and not inBtn then
            task.spawn(entry.close)
        end
    end
end

-- ─── WINDOW ───────────────────────────────────────────────────────────────────
function SpectrumX:CreateWindow(config)
    config = config or {}
    local window = setmetatable({}, self)

    self:UpdateScale()

    if PlayerGui:FindFirstChild("SpectrumX") then
        PlayerGui.SpectrumX:Destroy()
    end

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name           = "SpectrumX"
    self.ScreenGui.Parent         = PlayerGui
    self.ScreenGui.ResetOnSpawn   = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.DisplayOrder   = 999

    self._notifications  = {}
    self.Dropdowns       = {}
    self._dropCloseFuncs = {}

    local defaultSize, defaultPos
    if ScaleData.IsMobile then
        defaultSize = UDim2.new(0, 420, 0, 560)
        defaultPos  = UDim2.new(0.5, -210, 0.5, -280)
    else
        defaultSize = UDim2.new(0, 650, 0, 420)
        defaultPos  = UDim2.new(0.5, -325, 0.5, -210)
    end

    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name             = "MainFrame"
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BorderSizePixel  = 0
    self.MainFrame.Position         = config.Position or self:S(defaultPos)
    self.MainFrame.Size             = config.Size     or self:S(defaultSize)
    self.MainFrame.Active           = true
    self.MainFrame.Visible          = true
    self.MainFrame.Parent           = self.ScreenGui
    self:CreateCorner(self.MainFrame, UDim.new(0, 14))
    self:CreateShadow(self.MainFrame, 60)
    self:CreateStroke(self.MainFrame, self.Theme.Accent, 2, 0.6)

    local HEADER_H = self:S(60)

    self.Header = Instance.new("Frame")
    self.Header.Name             = "Header"
    self.Header.BackgroundColor3 = self.Theme.Header
    self.Header.BorderSizePixel  = 0
    self.Header.Size             = UDim2.new(1, 0, 0, HEADER_H)
    self.Header.Parent           = self.MainFrame
    self:CreateCorner(self.Header, UDim.new(0, 14))

    local hCover = Instance.new("Frame")
    hCover.BackgroundColor3 = self.Theme.Header
    hCover.BorderSizePixel  = 0
    hCover.Size             = UDim2.new(1, 0, 0, 14)
    hCover.Position         = UDim2.new(0, 0, 1, -14)
    hCover.Parent           = self.Header

    -- Ícone do header
    if config.IconAssetId and config.IconAssetId ~= "" then
        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.Position = self:S(UDim2.new(0, 16, 0, 12))
        img.Size     = self:S(UDim2.new(0, 36, 0, 36))
        img.Image    = config.IconAssetId
        img.ScaleType= Enum.ScaleType.Fit
        img.Parent   = self.Header
        Instance.new("UIAspectRatioConstraint").Parent = img
    else
        local ico = Instance.new("TextLabel")
        ico.BackgroundTransparency = 1
        ico.Position = self:S(UDim2.new(0, 16, 0, 10))
        ico.Size     = self:S(UDim2.new(0, 40, 0, 40))
        ico.Font     = Enum.Font.GothamBlack
        ico.Text     = config.Icon or "S"
        ico.TextColor3 = self.Theme.Accent
        ico.TextSize = self:S(26)
        ico.Parent   = self.Header
    end

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position   = self:S(UDim2.new(0, 64, 0, 0))
    title.Size       = self:S(UDim2.new(0, 380, 1, 0))
    title.Font       = Enum.Font.GothamBold
    title.Text       = config.Title or "Spectrum X"
    title.TextColor3 = self.Theme.Text
    title.TextSize   = self:S(20)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent     = self.Header
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, self.Theme.Text),
        ColorSequenceKeypoint.new(1, self.Theme.AccentSecondary),
    }
    grad.Parent = title

    if config.Subtitle then
        local sub = Instance.new("TextLabel")
        sub.BackgroundTransparency = 1
        sub.Position   = self:S(UDim2.new(0, 64, 0, 34))
        sub.Size       = self:S(UDim2.new(0, 380, 0, 18))
        sub.Font       = Enum.Font.Gotham
        sub.Text       = config.Subtitle
        sub.TextColor3 = self.Theme.TextMuted
        sub.TextSize   = self:S(11)
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.Parent     = self.Header
    end

    local closeBtn = Instance.new("TextButton")
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position  = UDim2.new(1, -48, 0.5, -14)
    closeBtn.Size      = UDim2.new(0, 32, 0, 28)
    closeBtn.Font      = Enum.Font.GothamBold
    closeBtn.Text      = "—"
    closeBtn.TextColor3= self.Theme.TextMuted
    closeBtn.TextSize  = self:S(18)
    closeBtn.Parent    = self.Header
    closeBtn.MouseEnter:Connect(function()  self:Tween(closeBtn, {TextColor3 = self.Theme.Text}, 0.2) end)
    closeBtn.MouseLeave:Connect(function()  self:Tween(closeBtn, {TextColor3 = self.Theme.TextMuted}, 0.2) end)
    closeBtn.MouseButton1Click:Connect(function() self.MainFrame.Visible = false end)

    local SIDEBAR_W = self:S(65)
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name             = "Sidebar"
    self.Sidebar.BackgroundColor3 = self.Theme.Sidebar
    self.Sidebar.BorderSizePixel  = 0
    self.Sidebar.Position         = UDim2.new(0, 0, 0, HEADER_H)
    self.Sidebar.Size             = UDim2.new(0, SIDEBAR_W, 1, -HEADER_H)
    self.Sidebar.Parent           = self.MainFrame
    self:CreateCorner(self.Sidebar, UDim.new(0, 14))

    local sbCover = Instance.new("Frame")
    sbCover.BackgroundColor3 = self.Theme.Sidebar
    sbCover.BorderSizePixel  = 0
    sbCover.Size             = UDim2.new(1, 0, 0, 14)
    sbCover.Parent           = self.Sidebar

    local sbLayout = Instance.new("UIListLayout")
    sbLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    sbLayout.Padding             = UDim.new(0, self:S(12))
    sbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sbLayout.Parent              = self.Sidebar

    local sbPad = Instance.new("UIPadding")
    sbPad.PaddingTop = UDim.new(0, self:S(16))
    sbPad.Parent     = self.Sidebar

    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name              = "ContentArea"
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Position          = self:S(UDim2.new(0, 75, 0, 72))
    self.ContentArea.Size              = UDim2.new(1, -self:S(85), 1, -self:S(82))
    self.ContentArea.Parent            = self.MainFrame

    self.Tabs       = {}
    self.CurrentTab = nil

    self:MakeDraggable(self.MainFrame, self.Header)
    self:_CreateFloatingButton(config)

    -- Fechar dropdowns ao clicar fora
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            self:_CloseDropdownsOnClickOutside(input.Position)
        end
    end)

    local ok, cam = pcall(function() return workspace.CurrentCamera end)
    if ok and cam then
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() self:UpdateScale() end)
    end

    return window
end

-- ─── FLOATING BUTTON ─────────────────────────────────────────────────────────
function SpectrumX:_CreateFloatingButton(config)
    config = config or {}
    local btnSize = self:S(52)
    self.FloatBtn = Instance.new("ImageButton")
    self.FloatBtn.Name             = "FloatBtn"
    self.FloatBtn.BackgroundColor3 = self.Theme.Accent
    self.FloatBtn.Position         = UDim2.new(0, 20, 0.5, 0)
    self.FloatBtn.Size             = UDim2.new(0, btnSize, 0, btnSize)
    self.FloatBtn.Image            = ""
    self.FloatBtn.Parent           = self.ScreenGui
    self:CreateCorner(self.FloatBtn, UDim.new(0, 16))
    self:CreateStroke(self.FloatBtn, Color3.fromRGB(0,0,0), 2, 0.4)

    if config.IconAssetId and config.IconAssetId ~= "" then
        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.Size     = UDim2.new(0.6, 0, 0.6, 0)
        img.Position = UDim2.new(0.2, 0, 0.2, 0)
        img.Image    = config.IconAssetId
        img.Parent   = self.FloatBtn
    else
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size      = UDim2.new(1, 0, 1, 0)
        lbl.Font      = Enum.Font.GothamBlack
        lbl.Text      = config.Icon or "S"
        lbl.TextColor3= self.Theme.Text
        lbl.TextSize  = self:S(22)
        lbl.Parent    = self.FloatBtn
    end

    local fDragging, fDragInput, fDragStart, fStartPos
    self.FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            fDragging = true; fDragStart = input.Position; fStartPos = self.FloatBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then fDragging = false end
            end)
        end
    end)
    self.FloatBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then fDragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == fDragInput and fDragging then
            local d = input.Position - fDragStart
            self.FloatBtn.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + d.X,
                                               fStartPos.Y.Scale, fStartPos.Y.Offset + d.Y)
        end
    end)
    self.FloatBtn.MouseButton1Click:Connect(function()
        if not fDragging then self.MainFrame.Visible = not self.MainFrame.Visible end
    end)
end

-- ─── TAB ─────────────────────────────────────────────────────────────────────
function SpectrumX:CreateTab(config)
    config = config or {}
    local tabId   = config.Name or "Tab"
    local tabIcon = config.Icon or string.sub(tabId, 1, 1)
    local btnSize = self:S(48)

    local tabBtn = Instance.new("TextButton")
    tabBtn.Name             = tabId .. "Tab"
    tabBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 55)
    tabBtn.Size             = UDim2.new(0, btnSize, 0, btnSize)
    tabBtn.Text             = ""
    tabBtn.Parent           = self.Sidebar
    self:CreateCorner(tabBtn, UDim.new(0, 12))

    if config.IconAssetId and config.IconAssetId ~= "" then
        local img = Instance.new("ImageLabel")
        img.Name                 = "Icon"
        img.BackgroundTransparency = 1
        img.Position             = UDim2.new(0.5, -12, 0.5, -12)
        img.Size                 = UDim2.new(0, 24, 0, 24)
        img.Image                = config.IconAssetId
        img.Parent               = tabBtn
        Instance.new("UIAspectRatioConstraint").Parent = img
    else
        local ico = Instance.new("TextLabel")
        ico.Name                 = "Icon"
        ico.BackgroundTransparency = 1
        ico.Size                 = UDim2.new(1, 0, 1, 0)
        ico.Font                 = Enum.Font.GothamBold
        ico.Text                 = tabIcon
        ico.TextColor3           = self.Theme.TextMuted
        ico.TextSize             = self:S(18)
        ico.Parent               = tabBtn
    end

    local pageContainer = Instance.new("Frame")
    pageContainer.Name                  = tabId .. "PageContainer"
    pageContainer.BackgroundTransparency= 1
    pageContainer.Size                  = UDim2.new(1, 0, 1, 0)
    pageContainer.Visible               = false
    pageContainer.Parent                = self.ContentArea

    local divider = Instance.new("Frame")
    divider.BackgroundColor3 = self.Theme.Border
    divider.BorderSizePixel  = 0
    divider.Position         = UDim2.new(0.5, -1, 0, 0)
    divider.Size             = UDim2.new(0, 2, 1, 0)
    divider.Parent           = pageContainer

    local function makeSide(pos, size, name)
        local sf = Instance.new("ScrollingFrame")
        sf.Name                   = name
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel        = 0
        sf.Position               = pos
        sf.Size                   = size
        sf.ScrollBarThickness     = 3
        sf.ScrollBarImageColor3   = self.Theme.Accent
        sf.CanvasSize             = UDim2.new(0,0,0,0)
        sf.Parent                 = pageContainer
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding   = UDim.new(0, self:S(12))
        layout.Parent    = sf
        local pad = Instance.new("UIPadding")
        pad.PaddingRight = UDim.new(0, 4)
        pad.Parent       = sf
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
        end)
        return sf
    end

    local leftSide  = makeSide(UDim2.new(0, 0, 0, 0),    UDim2.new(0.48, 0, 1, 0), "LeftSide")
    local rightSide = makeSide(UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0), "RightSide")

    local tabData = {Button = tabBtn, Container = pageContainer, Left = leftSide, Right = rightSide}
    self.Tabs[tabId] = tabData

    tabBtn.MouseButton1Click:Connect(function() self:SelectTab(tabId) end)
    if not self.CurrentTab then self:SelectTab(tabId) end

    return tabData
end

function SpectrumX:SelectTab(tabId)
    for id, data in pairs(self.Tabs) do
        local icon = data.Button:FindFirstChild("Icon")
        if id == tabId then
            data.Container.Visible = true
            self:Tween(data.Button, {BackgroundColor3 = self.Theme.Accent}, 0.2)
            if icon then
                if icon:IsA("TextLabel") then self:Tween(icon, {TextColor3 = self.Theme.Text}, 0.2) end
                if icon:IsA("ImageLabel") then self:Tween(icon, {ImageColor3 = self.Theme.Text}, 0.2) end
            end
        else
            data.Container.Visible = false
            self:Tween(data.Button, {BackgroundColor3 = Color3.fromRGB(42, 42, 55)}, 0.2)
            if icon then
                if icon:IsA("TextLabel") then self:Tween(icon, {TextColor3 = self.Theme.TextMuted}, 0.2) end
                if icon:IsA("ImageLabel") then self:Tween(icon, {ImageColor3 = self.Theme.TextMuted}, 0.2) end
            end
        end
    end
    self.CurrentTab = tabId
end

-- ─── SECTION ──────────────────────────────────────────────────────────────────
function SpectrumX:CreateSection(parent, text, color)
    local s = Instance.new("TextLabel")
    s.BackgroundTransparency = 1
    s.Size        = UDim2.new(1, 0, 0, self:S(28))
    s.Font        = Enum.Font.GothamBold
    s.Text        = text
    s.TextColor3  = color or self.Theme.Accent
    s.TextSize    = self:S(14)
    s.TextXAlignment = Enum.TextXAlignment.Left
    s.Parent      = parent
    return s
end

-- ─── TOGGLE ───────────────────────────────────────────────────────────────────
function SpectrumX:CreateToggle(parent, config)
    config = config or {}
    local text     = config.Text     or "Toggle"
    local default  = config.Default  or false
    local callback = config.Callback or function() end

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = UDim2.new(1, 0, 0, self:S(50))
    frame.Parent           = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position   = UDim2.new(0, 16, 0, 0)
    label.Size       = UDim2.new(0.65, 0, 1, 0)
    label.Font       = Enum.Font.GothamSemibold
    label.Text       = text
    label.TextColor3 = self.Theme.Text
    label.TextSize   = self:S(14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent     = frame

    local swBg = Instance.new("TextButton")
    swBg.Text             = ""
    swBg.AutoButtonColor  = false
    swBg.BackgroundColor3 = default and self.Theme.ToggleOn or self.Theme.ToggleOff
    swBg.Position         = UDim2.new(1, -58, 0.5, -12)
    swBg.Size             = UDim2.new(0, 46, 0, self:S(24))
    swBg.ZIndex           = 2
    swBg.Parent           = frame
    self:CreateCorner(swBg, UDim.new(1, 0))

    local knob = Instance.new("Frame")
    knob.BackgroundColor3 = self.Theme.Text
    knob.Position         = default and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.Size             = UDim2.new(0, 18, 0, 18)
    knob.ZIndex           = 3
    knob.Parent           = swBg
    self:CreateCorner(knob, UDim.new(1, 0))

    local state = default
    local function update(s)
        if s then
            self:Tween(swBg,  {BackgroundColor3 = self.Theme.ToggleOn}, 0.2)
            self:Tween(knob,  {Position = UDim2.new(1, -22, 0.5, -9)}, 0.2)
        else
            self:Tween(swBg,  {BackgroundColor3 = self.Theme.ToggleOff}, 0.2)
            self:Tween(knob,  {Position = UDim2.new(0, 3, 0.5, -9)}, 0.2)
        end
    end

    swBg.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        update(state)
    end)

    return {
        Frame    = frame,
        GetState = function() return state end,
        SetState = function(newState) state = newState; callback(state); update(state) end,
    }
end

-- ─── BUTTON ───────────────────────────────────────────────────────────────────
function SpectrumX:CreateButton(parent, config)
    config = config or {}
    local text     = config.Text     or "Button"
    local style    = config.Style    or "default"
    local callback = config.Callback or function() end

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Background
    frame.Size             = UDim2.new(1, 0, 0, self:S(52))
    frame.Parent           = parent

    local btn = Instance.new("TextButton")
    btn.Name             = "Button"
    btn.BackgroundColor3 = self.Theme.Card
    btn.Position         = UDim2.new(0.02, 0, 0.08, 0)
    btn.Size             = UDim2.new(0.96, 0, 0.84, 0)
    btn.Font             = Enum.Font.GothamSemibold
    btn.Text             = text
    btn.TextSize         = self:S(14)
    btn.Parent           = frame
    self:CreateCorner(btn, UDim.new(0, 10))

    local color = self.Theme.Accent
    if style == "warning" then
        color = self.Theme.Warning; btn.TextColor3 = self.Theme.Warning
    elseif style == "info" then
        color = self.Theme.Info; btn.TextColor3 = self.Theme.Info
    elseif style == "accent" then
        btn.TextColor3 = self.Theme.Accent
    else
        btn.TextColor3 = self.Theme.Text
    end

    local stroke = self:CreateStroke(btn, color, 1, 0.85)
    btn.MouseEnter:Connect(function()
        self:Tween(btn, {BackgroundColor3 = Color3.fromRGB(42,42,55)}, 0.2)
        self:Tween(stroke, {Transparency = 0.5}, 0.2)
    end)
    btn.MouseLeave:Connect(function()
        self:Tween(btn, {BackgroundColor3 = self.Theme.Card}, 0.2)
        self:Tween(stroke, {Transparency = 0.85}, 0.2)
    end)
    btn.MouseButton1Click:Connect(function() callback() end)

    return {Frame = frame, Button = btn, SetText = function(t) btn.Text = t end}
end

-- ─── INPUT ────────────────────────────────────────────────────────────────────
function SpectrumX:CreateInput(parent, config)
    config = config or {}
    local labelText   = config.Label       or "Input"
    local default     = config.Default     or ""
    local placeholder = config.Placeholder or ""
    local callback    = config.Callback    or function() end

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = UDim2.new(1, 0, 0, self:S(62))
    frame.Parent           = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position   = UDim2.new(0, 16, 0, 0)
    label.Size       = UDim2.new(0.6, 0, 0.45, 0)
    label.Font       = Enum.Font.GothamSemibold
    label.Text       = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize   = self:S(14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent     = frame

    local box = Instance.new("TextBox")
    box.BackgroundColor3  = self.Theme.Input
    box.Position          = UDim2.new(0.03, 0, 0.48, 0)
    box.Size              = UDim2.new(0.94, 0, 0, self:S(30))
    box.Font              = Enum.Font.Gotham
    box.Text              = tostring(default)
    box.PlaceholderText   = placeholder
    box.PlaceholderColor3 = self.Theme.TextMuted
    box.TextColor3        = self.Theme.Text
    box.TextSize          = self:S(13)
    box.ClearTextOnFocus  = false
    box.Parent            = frame
    self:CreateCorner(box, UDim.new(0, 8))

    local stroke = self:CreateStroke(box, self.Theme.Accent, 1, 0.85)
    box.Focused:Connect(function()  self:Tween(stroke, {Transparency = 0.4}, 0.2) end)
    box.FocusLost:Connect(function()
        self:Tween(stroke, {Transparency = 0.85}, 0.2)
        callback(box.Text)
    end)

    return {
        Frame   = frame, TextBox = box,
        GetText = function() return box.Text end,
        SetText = function(t) box.Text = t end,
    }
end

-- ─── NUMBER INPUT ─────────────────────────────────────────────────────────────
function SpectrumX:CreateNumberInput(parent, config)
    config = config or {}
    local labelText = config.Label    or "Number"
    local default   = config.Default  or 0
    local min       = config.Min      or -math.huge
    local max       = config.Max      or math.huge
    local callback  = config.Callback or function() end

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = UDim2.new(1, 0, 0, self:S(62))
    frame.Parent           = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position   = UDim2.new(0, 16, 0, 0)
    label.Size       = UDim2.new(0.6, 0, 0.45, 0)
    label.Font       = Enum.Font.GothamSemibold
    label.Text       = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize   = self:S(14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent     = frame

    local box = Instance.new("TextBox")
    box.BackgroundColor3 = self.Theme.Input
    box.Position         = UDim2.new(0.03, 0, 0.48, 0)
    box.Size             = UDim2.new(0.94, 0, 0, self:S(30))
    box.Font             = Enum.Font.Gotham
    box.Text             = tostring(default)
    box.TextColor3       = self.Theme.Text
    box.TextSize         = self:S(13)
    box.ClearTextOnFocus = false
    box.Parent           = frame
    self:CreateCorner(box, UDim.new(0, 8))

    local stroke = self:CreateStroke(box, self.Theme.Accent, 1, 0.85)
    box.Focused:Connect(function()  self:Tween(stroke, {Transparency = 0.4}, 0.2) end)
    box.FocusLost:Connect(function()
        self:Tween(stroke, {Transparency = 0.85}, 0.2)
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
        Frame    = frame, TextBox = box,
        GetValue = function() return tonumber(box.Text) end,
        SetValue = function(v) box.Text = tostring(math.clamp(v, min, max)) end,
    }
end

-- ─── SLIDER ───────────────────────────────────────────────────────────────────
function SpectrumX:CreateSlider(parent, config)
    config = config or {}
    local text     = config.Text     or "Slider"
    local min      = config.Min      or 0
    local max      = config.Max      or 100
    local default  = config.Default  or min
    local callback = config.Callback or function() end

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = UDim2.new(1, 0, 0, self:S(68))
    frame.Parent           = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position   = UDim2.new(0, 16, 0, 10)
    label.Size       = UDim2.new(0.5, 0, 0, 22)
    label.Font       = Enum.Font.GothamSemibold
    label.Text       = text
    label.TextColor3 = self.Theme.Text
    label.TextSize   = self:S(14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent     = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.BackgroundTransparency = 1
    valLabel.Position   = UDim2.new(0.6, 0, 0, 10)
    valLabel.Size       = UDim2.new(0.35, 0, 0, 22)
    valLabel.Font       = Enum.Font.GothamBold
    valLabel.Text       = tostring(default)
    valLabel.TextColor3 = self.Theme.Accent
    valLabel.TextSize   = self:S(14)
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent     = frame

    local track = Instance.new("Frame")
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    track.Position         = UDim2.new(0.03, 0, 0, 44)
    track.Size             = UDim2.new(0.94, 0, 0, self:S(8))
    track.Parent           = frame
    self:CreateCorner(track, UDim.new(1, 0))

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = self.Theme.Accent
    fill.Size             = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.Parent           = track
    self:CreateCorner(fill, UDim.new(1, 0))

    local knob = Instance.new("Frame")
    knob.BackgroundColor3 = self.Theme.Text
    knob.Position         = UDim2.new((default-min)/(max-min), -8, 0.5, -8)
    knob.Size             = UDim2.new(0, 16, 0, 16)
    knob.Parent           = track
    self:CreateCorner(knob, UDim.new(1, 0))
    self:CreateStroke(knob, Color3.fromRGB(0,0,0), 1, 0.4)

    local dragging = false
    local currentValue = default

    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + (max-min)*pos)*100)/100
        currentValue = val
        fill.Size     = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -8, 0.5, -8)
        valLabel.Text = tostring(val)
        callback(val)
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; updateSlider(i)
        end
    end)
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(i)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {
        Frame    = frame,
        GetValue = function() return currentValue end,
        SetValue = function(v)
            v = math.clamp(v, min, max); currentValue = v
            local p = (v-min)/(max-min)
            fill.Size = UDim2.new(p,0,1,0); knob.Position = UDim2.new(p,-8,0.5,-8); valLabel.Text = tostring(v)
        end,
    }
end

-- ─── HELPER: posição do dropdown ─────────────────────────────────────────────
local function calcDropPos(dropBtn, listLayout, maxH)
    local absPos  = dropBtn.AbsolutePosition
    local absSize = dropBtn.AbsoluteSize
    local contentH = listLayout.AbsoluteContentSize.Y + 12
    local targetH  = math.min(contentH, maxH)
    local ok, cam  = pcall(function() return workspace.CurrentCamera end)
    local screenH  = (ok and cam) and cam.ViewportSize.Y or 768
    local targetY  = absPos.Y + absSize.Y + 5
    if targetY + targetH > screenH then targetY = absPos.Y - targetH - 5 end
    return UDim2.fromOffset(absPos.X, targetY), targetH, contentH
end

-- ─── DROPDOWN (Single) ───────────────────────────────────────────────────────
function SpectrumX:CreateDropdown(parent, config)
    config = config or {}
    local labelText = config.Label    or "Dropdown"
    local options   = config.Options  or {}
    local default   = config.Default
    local callback  = config.Callback or function() end

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = UDim2.new(1, 0, 0, self:S(68))
    frame.ClipsDescendants = false
    frame.Parent           = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position   = UDim2.new(0, 16, 0, 10)
    label.Size       = UDim2.new(1, -32, 0, 20)
    label.Font       = Enum.Font.GothamBold
    label.Text       = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize   = self:S(13)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent     = frame

    local dropBtn = Instance.new("TextButton")
    dropBtn.BackgroundColor3 = self.Theme.Input
    dropBtn.Position         = UDim2.new(0, 16, 0, 32)
    dropBtn.Size             = UDim2.new(1, -32, 0, self:S(30))
    dropBtn.Font             = Enum.Font.GothamSemibold
    dropBtn.Text             = "  " .. (default or "Select...")
    dropBtn.TextColor3       = self.Theme.TextSecondary
    dropBtn.TextSize         = self:S(13)
    dropBtn.TextXAlignment   = Enum.TextXAlignment.Left
    dropBtn.ZIndex           = 2
    dropBtn.Parent           = frame
    self:CreateCorner(dropBtn, UDim.new(0, 8))
    self:CreateStroke(dropBtn, self.Theme.Accent, 1, 0.8)

    local arrow = Instance.new("TextLabel")
    arrow.BackgroundTransparency = 1
    arrow.Position   = UDim2.new(1, -26, 0, 0)
    arrow.Size       = UDim2.new(0, 26, 1, 0)
    arrow.Font       = Enum.Font.GothamBold
    arrow.Text       = "▼"
    arrow.TextColor3 = self.Theme.Accent
    arrow.TextSize   = self:S(11)
    arrow.Parent     = dropBtn

    local dropList = Instance.new("ScrollingFrame")
    dropList.Name                 = "DropdownList_" .. labelText .. "_" .. tostring(tick())
    dropList.BackgroundColor3     = self.Theme.Card
    dropList.Size                 = UDim2.new(0, 0, 0, 0)
    dropList.ScrollBarThickness   = 3
    dropList.ScrollBarImageColor3 = self.Theme.Accent
    dropList.Visible              = false
    dropList.ZIndex               = 2000
    dropList.BorderSizePixel      = 0
    dropList.Parent               = self.ScreenGui
    self:CreateCorner(dropList, UDim.new(0, 8))
    self:CreateStroke(dropList, self.Theme.Accent, 2, 0.4)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding   = UDim.new(0, 4)
    listLayout.Parent    = dropList

    local lPad = Instance.new("UIPadding")
    lPad.PaddingTop = UDim.new(0,6); lPad.PaddingBottom = UDim.new(0,6)
    lPad.PaddingLeft = UDim.new(0,6); lPad.PaddingRight = UDim.new(0,6)
    lPad.Parent = dropList

    local selectedValue = default
    local isOpen        = false
    local maxH          = self:S(180)

    local function closeDropdown()
        if not isOpen then return end
        isOpen = false
        self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)}, 0.3)
        self:Tween(arrow,    {Rotation = 0}, 0.2)
        task.wait(0.3)
        dropList.Visible = false
    end

    self:_RegisterDropdown(dropList, dropBtn, closeDropdown)

    local function populate()
        for _, ch in ipairs(dropList:GetChildren()) do
            if ch:IsA("Frame") then ch:Destroy() end
        end
        for _, option in ipairs(options) do
            local isSel = option == selectedValue
            local oF = Instance.new("Frame")
            oF.BackgroundColor3 = isSel and Color3.fromRGB(55,80,55) or self.Theme.Input
            oF.Size             = UDim2.new(1, 0, 0, self:S(32))
            oF.ZIndex           = 2001
            oF.Parent           = dropList
            self:CreateCorner(oF, UDim.new(0, 6))
            if isSel then self:CreateStroke(oF, Color3.fromRGB(100,240,100), 1.5, 0.3) end

            local oBtn = Instance.new("TextButton")
            oBtn.BackgroundTransparency = 1
            oBtn.Size      = UDim2.new(1, 0, 1, 0)
            oBtn.Font      = Enum.Font.GothamSemibold
            oBtn.Text      = (isSel and "● " or "   ") .. option
            oBtn.TextColor3= isSel and Color3.fromRGB(150,255,150) or self.Theme.TextSecondary
            oBtn.TextSize  = self:S(13)
            oBtn.TextXAlignment = Enum.TextXAlignment.Left
            oBtn.ZIndex    = 2002
            oBtn.Parent    = oF
            local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0,10); p.Parent = oBtn

            oBtn.MouseButton1Click:Connect(function()
                selectedValue = option
                dropBtn.Text  = "  " .. option
                dropBtn.TextColor3 = self.Theme.Text
                callback(option)
                closeDropdown()
            end)
            oBtn.MouseEnter:Connect(function() if not isSel then self:Tween(oF, {BackgroundColor3 = Color3.fromRGB(60,60,75)}, 0.15) end end)
            oBtn.MouseLeave:Connect(function() if not isSel then self:Tween(oF, {BackgroundColor3 = self.Theme.Input}, 0.15) end end)
        end
    end

    dropBtn.MouseButton1Click:Connect(function()
        if isOpen then
            closeDropdown()
        else
            for _, dd in ipairs(self.Dropdowns) do if dd ~= dropList then dd.Visible = false end end
            populate()
            local pos, targetH, contentH = calcDropPos(dropBtn, listLayout, maxH)
            dropList.Position   = pos
            dropList.Size       = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)
            dropList.CanvasSize = UDim2.new(0, 0, 0, contentH)
            dropList.Visible    = true
            self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, targetH)}, 0.3)
            self:Tween(arrow,    {Rotation = 180}, 0.2)
            isOpen = true
        end
    end)

    dropBtn.MouseEnter:Connect(function() self:Tween(dropBtn, {BackgroundColor3 = Color3.fromRGB(55,55,70)}, 0.15) end)
    dropBtn.MouseLeave:Connect(function() self:Tween(dropBtn, {BackgroundColor3 = self.Theme.Input}, 0.15) end)

    return {
        Frame      = frame,
        GetValue   = function() return selectedValue end,
        SetValue   = function(v)
            selectedValue = v
            dropBtn.Text  = "  " .. (v or "Select...")
            dropBtn.TextColor3 = v and self.Theme.Text or self.Theme.TextSecondary
        end,
        SetOptions = function(opts) options = opts; if isOpen then populate() end end,
    }
end

-- ─── MULTI DROPDOWN ──────────────────────────────────────────────────────────
function SpectrumX:CreateMultiDropdown(parent, config)
    config = config or {}
    local labelText = config.Label    or "Multi Select"
    local options   = config.Options  or {}
    local default   = config.Default  or {}
    local callback  = config.Callback or function() end

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = UDim2.new(1, 0, 0, self:S(68))
    frame.ClipsDescendants = false
    frame.Parent           = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position   = UDim2.new(0, 16, 0, 10)
    label.Size       = UDim2.new(1, -32, 0, 20)
    label.Font       = Enum.Font.GothamBold
    label.Text       = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize   = self:S(13)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent     = frame

    local dropBtn = Instance.new("TextButton")
    dropBtn.BackgroundColor3 = self.Theme.Input
    dropBtn.Position         = UDim2.new(0, 16, 0, 32)
    dropBtn.Size             = UDim2.new(1, -32, 0, self:S(30))
    dropBtn.Font             = Enum.Font.GothamSemibold
    dropBtn.Text             = "  Select Options..."
    dropBtn.TextColor3       = self.Theme.TextSecondary
    dropBtn.TextSize         = self:S(13)
    dropBtn.TextXAlignment   = Enum.TextXAlignment.Left
    dropBtn.ZIndex           = 2
    dropBtn.Parent           = frame
    self:CreateCorner(dropBtn, UDim.new(0, 8))
    self:CreateStroke(dropBtn, self.Theme.Accent, 1, 0.8)

    local arrow = Instance.new("TextLabel")
    arrow.BackgroundTransparency = 1
    arrow.Position   = UDim2.new(1, -26, 0, 0)
    arrow.Size       = UDim2.new(0, 26, 1, 0)
    arrow.Font       = Enum.Font.GothamBold
    arrow.Text       = "▼"
    arrow.TextColor3 = self.Theme.Accent
    arrow.TextSize   = self:S(11)
    arrow.Parent     = dropBtn

    local dropList = Instance.new("ScrollingFrame")
    dropList.Name                 = "MultiDropdownList_" .. labelText .. "_" .. tostring(tick())
    dropList.BackgroundColor3     = self.Theme.Card
    dropList.Size                 = UDim2.new(0, 0, 0, 0)
    dropList.ScrollBarThickness   = 3
    dropList.ScrollBarImageColor3 = self.Theme.Accent
    dropList.Visible              = false
    dropList.ZIndex               = 2000
    dropList.BorderSizePixel      = 0
    dropList.Parent               = self.ScreenGui
    self:CreateCorner(dropList, UDim.new(0, 8))
    self:CreateStroke(dropList, self.Theme.Accent, 2, 0.4)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding   = UDim.new(0, 4)
    listLayout.Parent    = dropList

    local lPad = Instance.new("UIPadding")
    lPad.PaddingTop = UDim.new(0,6); lPad.PaddingBottom = UDim.new(0,6)
    lPad.PaddingLeft = UDim.new(0,6); lPad.PaddingRight = UDim.new(0,6)
    lPad.Parent = dropList

    local selectedValues = {}
    for _, v in ipairs(default) do table.insert(selectedValues, v) end
    local isOpen = false
    local maxH   = self:S(180)

    local function updateBtnText()
        if #selectedValues == 0 then
            dropBtn.Text = "  Select Options..."; dropBtn.TextColor3 = self.Theme.TextSecondary
        elseif #selectedValues == 1 then
            dropBtn.Text = "  " .. selectedValues[1]; dropBtn.TextColor3 = self.Theme.Text
        else
            dropBtn.Text = "  " .. #selectedValues .. " selected"; dropBtn.TextColor3 = self.Theme.Text
        end
    end

    local function closeMulti()
        if not isOpen then return end
        isOpen = false
        self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)}, 0.3)
        self:Tween(arrow,    {Rotation = 0}, 0.2)
        task.wait(0.3)
        dropList.Visible = false
    end

    self:_RegisterDropdown(dropList, dropBtn, closeMulti)

    local function getPriority(name)
        for i, v in ipairs(selectedValues) do if v == name then return i end end
    end
    local function toggleSel(name)
        for i, v in ipairs(selectedValues) do
            if v == name then table.remove(selectedValues, i); return end
        end
        table.insert(selectedValues, name)
    end

    local function populate()
        for _, ch in ipairs(dropList:GetChildren()) do
            if ch:IsA("Frame") then ch:Destroy() end
        end
        for _, option in ipairs(options) do
            local prio  = getPriority(option)
            local isSel = prio ~= nil
            local oF = Instance.new("Frame")
            oF.BackgroundColor3 = isSel and Color3.fromRGB(55,80,55) or self.Theme.Input
            oF.Size             = UDim2.new(1, 0, 0, self:S(32))
            oF.ZIndex           = 2001
            oF.Parent           = dropList
            self:CreateCorner(oF, UDim.new(0, 6))
            if isSel then self:CreateStroke(oF, Color3.fromRGB(100,240,100), 1.5, 0.3) end

            local oBtn = Instance.new("TextButton")
            oBtn.BackgroundTransparency = 1
            oBtn.Size      = UDim2.new(1, 0, 1, 0)
            oBtn.Font      = Enum.Font.GothamSemibold
            oBtn.Text      = (isSel and (prio .. ". ") or "   ") .. option
            oBtn.TextColor3= isSel and Color3.fromRGB(150,255,150) or self.Theme.TextSecondary
            oBtn.TextSize  = self:S(13)
            oBtn.TextXAlignment = Enum.TextXAlignment.Left
            oBtn.ZIndex    = 2002
            oBtn.Parent    = oF
            local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0,10); p.Parent = oBtn

            oBtn.MouseButton1Click:Connect(function()
                toggleSel(option); callback(selectedValues); updateBtnText(); populate()
            end)
            oBtn.MouseEnter:Connect(function() if not isSel then self:Tween(oF, {BackgroundColor3 = Color3.fromRGB(60,60,75)}, 0.15) end end)
            oBtn.MouseLeave:Connect(function() if not isSel then self:Tween(oF, {BackgroundColor3 = self.Theme.Input}, 0.15) end end)
        end
    end

    dropBtn.MouseButton1Click:Connect(function()
        if isOpen then
            closeMulti()
        else
            for _, dd in ipairs(self.Dropdowns) do if dd ~= dropList then dd.Visible = false end end
            populate()
            local pos, targetH, contentH = calcDropPos(dropBtn, listLayout, maxH)
            dropList.Position   = pos
            dropList.Size       = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)
            dropList.CanvasSize = UDim2.new(0, 0, 0, contentH)
            dropList.Visible    = true
            self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, targetH)}, 0.3)
            self:Tween(arrow,    {Rotation = 180}, 0.2)
            isOpen = true
        end
    end)

    dropBtn.MouseEnter:Connect(function() self:Tween(dropBtn, {BackgroundColor3 = Color3.fromRGB(55,55,70)}, 0.15) end)
    dropBtn.MouseLeave:Connect(function() self:Tween(dropBtn, {BackgroundColor3 = self.Theme.Input}, 0.15) end)

    updateBtnText()

    return {
        Frame      = frame,
        GetValues  = function() return selectedValues end,
        SetValues  = function(v) selectedValues = v; updateBtnText() end,
        SetOptions = function(opts) options = opts; if isOpen then populate() end end,
    }
end

-- ─── CHECKBOX ─────────────────────────────────────────────────────────────────
function SpectrumX:CreateCheckbox(parent, config)
    config = config or {}
    local text     = config.Text     or "Checkbox"
    local default  = config.Default  or false
    local callback = config.Callback or function() end

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = UDim2.new(1, 0, 0, self:S(44))
    frame.Parent           = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)

    local box = Instance.new("TextButton")
    box.BackgroundColor3 = default and self.Theme.Accent or self.Theme.Input
    box.Position         = UDim2.new(0, 16, 0.5, -10)
    box.Size             = UDim2.new(0, 20, 0, 20)
    box.Font             = Enum.Font.GothamBold
    box.Text             = default and "✓" or ""
    box.TextColor3       = self.Theme.Text
    box.TextSize         = self:S(13)
    box.Parent           = frame
    self:CreateCorner(box, UDim.new(0, 5))
    self:CreateStroke(box, self.Theme.Accent, 1.5, 0.5)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position   = UDim2.new(0, 44, 0, 0)
    label.Size       = UDim2.new(1, -58, 1, 0)
    label.Font       = Enum.Font.GothamSemibold
    label.Text       = text
    label.TextColor3 = self.Theme.Text
    label.TextSize   = self:S(14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent     = frame

    local state = default
    box.MouseButton1Click:Connect(function()
        state = not state; callback(state)
        self:Tween(box, {BackgroundColor3 = state and self.Theme.Accent or self.Theme.Input}, 0.2)
        box.Text = state and "✓" or ""
    end)

    return {
        Frame    = frame,
        GetState = function() return state end,
        SetState = function(s)
            state = s; callback(state)
            self:Tween(box, {BackgroundColor3 = state and self.Theme.Accent or self.Theme.Input}, 0.2)
            box.Text = state and "✓" or ""
        end,
    }
end

-- ─── LABEL ────────────────────────────────────────────────────────────────────
function SpectrumX:CreateLabel(parent, config)
    config = config or {}
    local text  = config.Text  or "Label"
    local color = config.Color or self.Theme.Text
    local size  = config.Size  or UDim2.new(1, 0, 0, self:S(38))

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = size
    frame.Parent           = parent
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.9)

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Position   = UDim2.new(0, 16, 0, 0)
    lbl.Size       = UDim2.new(1, -32, 1, 0)
    lbl.Font       = Enum.Font.GothamSemibold
    lbl.Text       = text
    lbl.TextColor3 = color
    lbl.TextSize   = self:S(14)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent     = frame

    return {Frame = frame, Label = lbl, SetText = function(t) lbl.Text = t end}
end

-- ─── SEPARATOR ────────────────────────────────────────────────────────────────
function SpectrumX:CreateSeparator(parent)
    local sep = Instance.new("Frame")
    sep.BackgroundColor3 = self.Theme.Border
    sep.BorderSizePixel  = 0
    sep.Size             = UDim2.new(1, 0, 0, 1)
    sep.Parent           = parent
    return sep
end

-- ─── STATUS CARD ─────────────────────────────────────────────────────────────
function SpectrumX:CreateStatusCard(parent, config)
    config = config or {}
    local title = config.Title or "Status"

    local frame = Instance.new("Frame")
    frame.Name             = "StatusCard"
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    frame.BorderSizePixel  = 0
    frame.Size             = UDim2.new(1, 0, 0, self:S(110))
    frame.Active           = true
    frame.Parent           = parent
    self:CreateCorner(frame, UDim.new(0, 12))

    local statusStroke = self:CreateStroke(frame, self.Theme.Accent, 2, 0.35)
    spawn(function()
        while frame.Parent do
            self:Tween(statusStroke, {Transparency = 0}, 0.8)
            task.wait(0.85)
            self:Tween(statusStroke, {Transparency = 0.5}, 0.8)
            task.wait(0.85)
        end
    end)

    local header = Instance.new("Frame")
    header.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    header.BorderSizePixel  = 0
    header.Size             = UDim2.new(1, 0, 0, self:S(34))
    header.Parent           = frame
    self:CreateCorner(header, UDim.new(0, 12))
    local hCover = Instance.new("Frame")
    hCover.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    hCover.BorderSizePixel  = 0
    hCover.Size             = UDim2.new(1, 0, 0, 12)
    hCover.Position         = UDim2.new(0, 0, 1, -12)
    hCover.Parent           = header

    local ht = Instance.new("TextLabel")
    ht.BackgroundTransparency = 1
    ht.Size      = UDim2.new(1, -14, 1, 0)
    ht.Position  = UDim2.new(0, 14, 0, 0)
    ht.Font      = Enum.Font.GothamBold
    ht.Text      = title
    ht.TextColor3= self.Theme.Text
    ht.TextSize  = self:S(13)
    ht.TextXAlignment = Enum.TextXAlignment.Left
    ht.Parent    = header

    local content = Instance.new("Frame")
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 14, 0, self:S(40))
    content.Size     = UDim2.new(1, -28, 1, -self:S(48))
    content.Parent   = frame

    local statusLbl = Instance.new("TextLabel")
    statusLbl.BackgroundTransparency = 1
    statusLbl.Size       = UDim2.new(1, 0, 0, self:S(22))
    statusLbl.Font       = Enum.Font.GothamSemibold
    statusLbl.Text       = "● Idle"
    statusLbl.TextColor3 = self.Theme.TextMuted
    statusLbl.TextSize   = self:S(13)
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.Parent     = content

    local infoLbl = Instance.new("TextLabel")
    infoLbl.BackgroundTransparency = 1
    infoLbl.Position = UDim2.new(0, 0, 0, self:S(24))
    infoLbl.Size     = UDim2.new(1, 0, 0, self:S(18))
    infoLbl.Font     = Enum.Font.Gotham
    infoLbl.Text     = "Ready"
    infoLbl.TextColor3 = self.Theme.TextSecondary
    infoLbl.TextSize = self:S(11)
    infoLbl.TextXAlignment = Enum.TextXAlignment.Left
    infoLbl.Parent   = content

    local barBg = Instance.new("Frame")
    barBg.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    barBg.Position         = UDim2.new(0, 0, 1, -8)
    barBg.Size             = UDim2.new(1, 0, 0, self:S(4))
    barBg.ClipsDescendants = true
    barBg.Parent           = content
    self:CreateCorner(barBg, UDim.new(1, 0))

    local bar = Instance.new("Frame")
    bar.BackgroundColor3 = self.Theme.Accent
    bar.Size             = UDim2.new(0, 0, 1, 0)
    bar.BorderSizePixel  = 0
    bar.Parent           = barBg
    self:CreateCorner(bar, UDim.new(1, 0))

    self:MakeDraggable(frame, header)

    return {
        Frame     = frame,
        SetStatus = function(status, color)
            statusLbl.Text = "● " .. status
            statusLbl.TextColor3 = color or self.Theme.TextMuted
        end,
        SetInfo   = function(info) infoLbl.Text = info end,
        AnimateLoading = function(active, duration)
            if active then
                spawn(function()
                    while active and frame.Parent do
                        local t = self:Tween(bar, {Size = UDim2.new(1,0,1,0)}, duration or 1.5)
                        t.Completed:Wait(); task.wait(0.1)
                        bar.Size = UDim2.new(0,0,1,0); task.wait(0.1)
                    end
                end)
            else
                bar.Size = UDim2.new(0,0,1,0)
            end
        end,
    }
end

-- ─── NOTIFICAÇÕES ─────────────────────────────────────────────────────────────
function SpectrumX:Notify(config)
    config = config or {}
    local text     = config.Text     or "Notification"
    local ntype    = config.Type     or "info"
    local duration = config.Duration or 3

    self:UpdateScale()
    local nW = self:S(ScaleData.IsMobile and 300 or 340)
    local nH = self:S(ScaleData.IsMobile and 62 or 68)

    local color = self.Theme.Info
    if ntype == "success" then     color = self.Theme.Success
    elseif ntype == "warning" then color = self.Theme.Warning
    elseif ntype == "error" then   color = Color3.fromRGB(255, 75, 75)
    end

    local notif = Instance.new("Frame")
    notif.BackgroundColor3 = self.Theme.Card
    notif.Position         = UDim2.new(1, nW + 10, 0.88, 0)
    notif.Size             = UDim2.new(0, nW, 0, nH)
    notif.Parent           = self.ScreenGui
    self:CreateCorner(notif, UDim.new(0, 12))
    self:CreateStroke(notif, self.Theme.Border, 1, 0.85)

    local sideBar = Instance.new("Frame")
    sideBar.BackgroundColor3 = color
    sideBar.BorderSizePixel  = 0
    sideBar.Size             = UDim2.new(0, 3, 1, -16)
    sideBar.Position         = UDim2.new(0, 0, 0, 8)
    sideBar.Parent           = notif
    self:CreateCorner(sideBar, UDim.new(1, 0))

    local icon = Instance.new("TextLabel")
    icon.BackgroundTransparency = 1
    icon.Position   = UDim2.new(0, self:S(16), 0, 0)
    icon.Size       = UDim2.new(0, self:S(28), 1, 0)
    icon.Font       = Enum.Font.GothamBlack
    icon.Text       = ntype=="success" and "✓" or ntype=="warning" and "!" or ntype=="error" and "✕" or "i"
    icon.TextColor3 = color
    icon.TextSize   = self:S(22)
    icon.Parent     = notif

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Position     = UDim2.new(0, self:S(50), 0, 0)
    lbl.Size         = UDim2.new(1, -self:S(62), 1, 0)
    lbl.Font         = Enum.Font.GothamSemibold
    lbl.Text         = text
    lbl.TextColor3   = self.Theme.Text
    lbl.TextSize     = self:S(13)
    lbl.TextWrapped  = true
    lbl.Parent       = notif

    local progBg = Instance.new("Frame")
    progBg.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    progBg.BorderSizePixel  = 0
    progBg.Position         = UDim2.new(0, 0, 1, -3)
    progBg.Size             = UDim2.new(1, 0, 0, 3)
    progBg.ClipsDescendants = true
    progBg.Parent           = notif
    self:CreateCorner(progBg, UDim.new(1, 0))
    local prog = Instance.new("Frame")
    prog.BackgroundColor3 = color
    prog.Size             = UDim2.new(1, 0, 1, 0)
    prog.BorderSizePixel  = 0
    prog.Parent           = progBg

    table.insert(self._notifications, notif)

    local function getVP()
        local ok, cam = pcall(function() return workspace.CurrentCamera end)
        return (ok and cam) and cam.ViewportSize or Vector2.new(1366, 768)
    end

    local function restack()
        local vp  = getVP()
        local off = 10
        for i = #self._notifications, 1, -1 do
            local n = self._notifications[i]
            if n and n.Parent then
                self:Tween(n, {Position = UDim2.fromOffset(vp.X - nW - 12, vp.Y - nH - off)}, 0.3)
                off = off + nH + 8
            end
        end
    end

    local function dismiss()
        for i, n in ipairs(self._notifications) do
            if n == notif then table.remove(self._notifications, i); break end
        end
        local vp = getVP()
        self:Tween(notif, {Position = UDim2.fromOffset(vp.X + nW, notif.AbsolutePosition.Y)}, 0.35)
        restack()
        task.wait(0.4)
        if notif and notif.Parent then notif:Destroy() end
    end

    local vp = getVP()
    self:Tween(notif, {Position = UDim2.fromOffset(vp.X - nW - 12, vp.Y - nH - 10)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    restack()
    self:Tween(prog, {Size = UDim2.new(0, 0, 1, 0)}, duration)

    task.delay(duration, function()
        if notif and notif.Parent then dismiss() end
    end)
end

-- ─── DESTROY ──────────────────────────────────────────────────────────────────
function SpectrumX:Destroy()
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

return SpectrumX

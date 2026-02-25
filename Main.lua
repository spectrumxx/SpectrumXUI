--[[
    SpectrumX UI Library - Remastered
    Visual moderno, responsivo (PC/Mobile/DPI), dropdowns corrigidos,
    notificações empilhadas, suporte a AssetId em ícones e abas.
    API 100% compatível com a versão original.
]]

local SpectrumX = {}
SpectrumX.__index = SpectrumX

-- Services
local Players         = game:GetService("Players")
local UserInputService= game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ─── Escala responsiva ────────────────────────────────────────────────────────
-- Usa a viewport real para calcular um factor de escala.
-- Baseline: 1366×768 (desktop médio). Em resoluções menores (mobile) tudo encolhe.
local function getScale()
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1366, 768)
    local baseW, baseH = 1366, 768
    local s = math.clamp(math.min(vp.X / baseW, vp.Y / baseH), 0.45, 1.15)
    return s
end

local function px(n) return math.round(n * getScale()) end

-- ─── Theme ────────────────────────────────────────────────────────────────────
SpectrumX.Theme = {
    Background      = Color3.fromRGB(10, 10, 12),
    Header          = Color3.fromRGB(14, 14, 18),
    Sidebar         = Color3.fromRGB(14, 14, 18),
    Content         = Color3.fromRGB(18, 18, 22),
    Card            = Color3.fromRGB(22, 22, 28),
    Input           = Color3.fromRGB(30, 30, 38),
    Accent          = Color3.fromRGB(220, 40, 40),
    AccentSecondary = Color3.fromRGB(255, 110, 110),
    Text            = Color3.fromRGB(240, 240, 245),
    TextSecondary   = Color3.fromRGB(170, 170, 180),
    TextMuted       = Color3.fromRGB(110, 110, 125),
    Success         = Color3.fromRGB(50, 220, 100),
    Warning         = Color3.fromRGB(255, 185, 70),
    Info            = Color3.fromRGB(80, 160, 255),
    Border          = Color3.fromRGB(38, 38, 48),
    ToggleOff       = Color3.fromRGB(42, 42, 52),
    ToggleOn        = Color3.fromRGB(220, 40, 40),
}

-- ─── Utility ──────────────────────────────────────────────────────────────────
function SpectrumX:Tween(obj, props, time, style, dir)
    local info = TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function SpectrumX:CreateCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or UDim.new(0, px(8))
    c.Parent = parent
    return c
end

function SpectrumX:CreateStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color        = color or self.Theme.Accent
    s.Thickness    = thickness or 1
    s.Transparency = transparency or 0
    s.Parent       = parent
    return s
end

function SpectrumX:CreateShadow(parent)
    local sh = Instance.new("ImageLabel")
    sh.Name               = "Shadow"
    sh.AnchorPoint        = Vector2.new(0.5, 0.5)
    sh.BackgroundTransparency = 1
    sh.Position           = UDim2.new(0.5, 0, 0.5, 0)
    sh.Size               = UDim2.new(1, px(40), 1, px(40))
    sh.ZIndex             = -1
    sh.Image              = "rbxassetid://6015897843"
    sh.ImageColor3        = Color3.fromRGB(0, 0, 0)
    sh.ImageTransparency  = 0.55
    sh.Parent             = parent
    return sh
end

-- Cria um ImageLabel OU TextLabel dependendo de ser assetid ou texto
local function createIconElement(parent, iconValue, defaultLetter, size, pos, textSize, textColor, zIndex)
    zIndex = zIndex or 2
    -- Detecta se é um número (asset id) ou string numérica
    local assetId = tonumber(tostring(iconValue):match("^%d+$") or "")
    if assetId or (type(iconValue) == "string" and iconValue:match("^rbxassetid://")) then
        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.Position  = pos
        img.Size      = size
        img.Image     = type(iconValue) == "number" and ("rbxassetid://" .. iconValue) or iconValue
        img.ImageColor3 = textColor or Color3.fromRGB(255,255,255)
        img.ScaleType = Enum.ScaleType.Fit
        img.ZIndex    = zIndex
        img.Parent    = parent
        return img
    else
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Position  = pos
        lbl.Size      = size
        lbl.Font      = Enum.Font.GothamBlack
        lbl.Text      = iconValue or defaultLetter or "?"
        lbl.TextColor3= textColor or Color3.fromRGB(255,255,255)
        lbl.TextSize  = textSize or px(18)
        lbl.ZIndex    = zIndex
        lbl.Parent    = parent
        return lbl
    end
end

function SpectrumX:MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
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

-- ─── WINDOW ───────────────────────────────────────────────────────────────────
function SpectrumX:CreateWindow(config)
    config = config or {}
    local window = setmetatable({}, self)

    if PlayerGui:FindFirstChild("SpectrumX") then
        PlayerGui.SpectrumX:Destroy()
    end

    -- Dimensões responsivas
    local W = px(580)
    local H = px(345)
    local HEADER_H = px(44)
    local SIDEBAR_W = px(46)

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name           = "SpectrumX"
    self.ScreenGui.Parent         = PlayerGui
    self.ScreenGui.ResetOnSpawn   = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.DisplayOrder   = 999

    -- Notificações: fila para empilhar
    self._notifications = {}

    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name             = "MainFrame"
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BorderSizePixel  = 0
    self.MainFrame.Position         = config.Position or UDim2.new(0.5, -W/2, 0.5, -H/2)
    self.MainFrame.Size             = config.Size or UDim2.new(0, W, 0, H)
    self.MainFrame.Active           = true
    self.MainFrame.Parent           = self.ScreenGui
    self:CreateCorner(self.MainFrame, UDim.new(0, px(10)))
    self:CreateShadow(self.MainFrame)
    self:CreateStroke(self.MainFrame, self.Theme.Accent, 1.5, 0.1)

    -- ── Header ────────────────────────────────────────────────
    self.Header = Instance.new("Frame")
    self.Header.Name             = "Header"
    self.Header.BackgroundColor3 = self.Theme.Header
    self.Header.BorderSizePixel  = 0
    self.Header.Size             = UDim2.new(1, 0, 0, HEADER_H)
    self.Header.Parent           = self.MainFrame
    self:CreateCorner(self.Header, UDim.new(0, px(10)))

    -- Cover round bottom of header
    local hCover = Instance.new("Frame")
    hCover.BackgroundColor3 = self.Theme.Header
    hCover.BorderSizePixel  = 0
    hCover.Size             = UDim2.new(1, 0, 0, px(10))
    hCover.Position         = UDim2.new(0, 0, 1, -px(10))
    hCover.Parent           = self.Header

    -- Icon (letra ou asset)
    local iconSize = UDim2.new(0, px(28), 0, px(28))
    local iconPos  = UDim2.new(0, px(12), 0.5, -px(14))
    createIconElement(self.Header, config.Icon or "S", "S",
        iconSize, iconPos, px(20), self.Theme.Accent)

    -- Title
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position   = UDim2.new(0, px(48), 0, 0)
    title.Size       = UDim2.new(0, px(260), 1, 0)
    title.Font       = Enum.Font.GothamBlack
    title.Text       = config.Title or "Spectrum X"
    title.TextColor3 = self.Theme.Text
    title.TextSize   = px(17)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent     = self.Header

    local titleGrad = Instance.new("UIGradient")
    titleGrad.Color  = ColorSequence.new{
        ColorSequenceKeypoint.new(0, self.Theme.Text),
        ColorSequenceKeypoint.new(1, self.Theme.AccentSecondary)
    }
    titleGrad.Parent = title

    -- Subtítulo opcional
    if config.Subtitle then
        local sub = Instance.new("TextLabel")
        sub.BackgroundTransparency = 1
        sub.Position   = UDim2.new(0, px(48), 0.55, 0)
        sub.Size       = UDim2.new(0, px(260), 0.45, 0)
        sub.Font       = Enum.Font.Gotham
        sub.Text       = config.Subtitle
        sub.TextColor3 = self.Theme.TextMuted
        sub.TextSize   = px(11)
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.Parent     = self.Header
    end

    -- Close / Minimise
    local closeBtn = Instance.new("TextButton")
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position  = UDim2.new(1, -px(36), 0.5, -px(12))
    closeBtn.Size      = UDim2.new(0, px(26), 0, px(24))
    closeBtn.Font      = Enum.Font.GothamBold
    closeBtn.Text      = "—"
    closeBtn.TextColor3= self.Theme.TextMuted
    closeBtn.TextSize  = px(16)
    closeBtn.Parent    = self.Header

    closeBtn.MouseEnter:Connect(function()  self:Tween(closeBtn, {TextColor3 = self.Theme.Text}, 0.15) end)
    closeBtn.MouseLeave:Connect(function()  self:Tween(closeBtn, {TextColor3 = self.Theme.TextMuted}, 0.15) end)
    closeBtn.MouseButton1Click:Connect(function() self.MainFrame.Visible = false end)

    -- ── Sidebar ───────────────────────────────────────────────
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Name             = "Sidebar"
    self.Sidebar.BackgroundColor3 = self.Theme.Sidebar
    self.Sidebar.BorderSizePixel  = 0
    self.Sidebar.Position         = UDim2.new(0, 0, 0, HEADER_H)
    self.Sidebar.Size             = UDim2.new(0, SIDEBAR_W, 1, -HEADER_H)
    self.Sidebar.Parent           = self.MainFrame
    self:CreateCorner(self.Sidebar, UDim.new(0, px(10)))

    local sbCover = Instance.new("Frame")
    sbCover.BackgroundColor3 = self.Theme.Sidebar
    sbCover.BorderSizePixel  = 0
    sbCover.Size             = UDim2.new(1, 0, 0, px(10))
    sbCover.Parent           = self.Sidebar

    local sbLayout  = Instance.new("UIListLayout")
    sbLayout.SortOrder            = Enum.SortOrder.LayoutOrder
    sbLayout.Padding              = UDim.new(0, px(8))
    sbLayout.HorizontalAlignment  = Enum.HorizontalAlignment.Center
    sbLayout.Parent               = self.Sidebar

    local sbPad = Instance.new("UIPadding")
    sbPad.PaddingTop = UDim.new(0, px(10))
    sbPad.Parent     = self.Sidebar

    -- ── Content ───────────────────────────────────────────────
    local GAP = px(8)
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name              = "ContentArea"
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Position          = UDim2.new(0, SIDEBAR_W + GAP, 0, HEADER_H + GAP)
    self.ContentArea.Size              = UDim2.new(1, -(SIDEBAR_W + GAP * 2), 1, -(HEADER_H + GAP * 2))
    self.ContentArea.Parent            = self.MainFrame

    self.Tabs       = {}
    self.CurrentTab = nil

    self:MakeDraggable(self.MainFrame, self.Header)
    self:CreateFloatingButton(config)

    return window
end

-- ─── FLOATING BUTTON ─────────────────────────────────────────────────────────
function SpectrumX:CreateFloatingButton(config)
    config = config or {}
    local btnSize = px(44)

    self.FloatBtn = Instance.new("ImageButton")
    self.FloatBtn.Name            = "FloatBtn"
    self.FloatBtn.BackgroundColor3= self.Theme.Accent
    self.FloatBtn.Position        = UDim2.new(0, px(10), 0.5, 0)
    self.FloatBtn.Size            = UDim2.new(0, btnSize, 0, btnSize)
    self.FloatBtn.Image           = ""
    self.FloatBtn.Parent          = self.ScreenGui
    self:CreateCorner(self.FloatBtn, UDim.new(0, px(12)))
    self:CreateStroke(self.FloatBtn, Color3.fromRGB(0,0,0), 2, 0.5)

    createIconElement(self.FloatBtn, config.Icon or "S", "S",
        UDim2.new(1, 0, 1, 0), UDim2.new(0,0,0,0), px(20), self.Theme.Text, 2)

    -- Drag
    local fDragging, fDragInput, fDragStart, fStartPos
    local clickStart

    self.FloatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            fDragging = true
            fDragStart = input.Position
            fStartPos  = self.FloatBtn.Position
            clickStart = tick()
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
            local delta = input.Position - fDragStart
            self.FloatBtn.Position = UDim2.new(
                fStartPos.X.Scale, fStartPos.X.Offset + delta.X,
                fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y
            )
        end
    end)

    self.FloatBtn.MouseButton1Click:Connect(function()
        -- só toggle se não foi um drag longo
        local moved = fDragStart and (UserInputService:GetMouseLocation() - Vector2.new(fDragStart.X, fDragStart.Y)).Magnitude or 0
        if moved < 5 then
            self.MainFrame.Visible = not self.MainFrame.Visible
        end
    end)
end

-- ─── TAB ─────────────────────────────────────────────────────────────────────
function SpectrumX:CreateTab(config)
    config = config or {}
    local tabId   = config.Name or "Tab"
    local tabIcon = config.Icon or string.sub(tabId, 1, 1)

    local btnSize = px(34)

    local tabBtn = Instance.new("TextButton")
    tabBtn.Name             = tabId .. "Tab"
    tabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    tabBtn.Size             = UDim2.new(0, btnSize, 0, btnSize)
    tabBtn.Font             = Enum.Font.GothamBlack
    tabBtn.Text             = ""
    tabBtn.TextColor3       = self.Theme.TextMuted
    tabBtn.TextSize         = px(14)
    tabBtn.Parent           = self.Sidebar
    self:CreateCorner(tabBtn, UDim.new(0, px(8)))

    -- Tooltip
    tabBtn.Name = tabId .. "Tab"

    -- Ícone na aba (letra ou assetid)
    createIconElement(tabBtn, tabIcon, string.sub(tabId,1,1),
        UDim2.new(0, px(20), 0, px(20)),
        UDim2.new(0.5, -px(10), 0.5, -px(10)),
        px(14), self.Theme.TextMuted, 2)

    -- Page
    local pageContainer = Instance.new("Frame")
    pageContainer.Name                  = tabId .. "PageContainer"
    pageContainer.BackgroundTransparency= 1
    pageContainer.Size                  = UDim2.new(1, 0, 1, 0)
    pageContainer.Visible               = false
    pageContainer.Parent                = self.ContentArea

    -- Divider
    local divider = Instance.new("Frame")
    divider.BackgroundColor3 = self.Theme.Border
    divider.BorderSizePixel  = 0
    divider.Position         = UDim2.new(0.5, -1, 0, 0)
    divider.Size             = UDim2.new(0, 1, 1, 0)
    divider.Parent           = pageContainer

    local function makeSide(pos, size)
        local sf = Instance.new("ScrollingFrame")
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel        = 0
        sf.Position               = pos
        sf.Size                   = size
        sf.ScrollBarThickness     = px(3)
        sf.ScrollBarImageColor3   = self.Theme.Accent
        sf.ScrollBarImageTransparency = 0.5
        sf.CanvasSize             = UDim2.new(0, 0, 0, 0)
        sf.Parent                 = pageContainer

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding   = UDim.new(0, px(6))
        layout.Parent    = sf

        local pad = Instance.new("UIPadding")
        pad.PaddingRight = UDim.new(0, px(4))
        pad.Parent       = sf

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + px(10))
        end)

        return sf
    end

    local leftSide  = makeSide(UDim2.new(0, 0, 0, 0),       UDim2.new(0.49, 0, 1, 0))
    local rightSide = makeSide(UDim2.new(0.51, 0, 0, 0),    UDim2.new(0.49, 0, 1, 0))
    leftSide.Name   = "LeftSide"
    rightSide.Name  = "RightSide"

    local tabData = {
        Button    = tabBtn,
        Container = pageContainer,
        Left      = leftSide,
        Right     = rightSide,
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

function SpectrumX:SelectTab(tabId)
    for id, data in pairs(self.Tabs) do
        if id == tabId then
            data.Container.Visible = true
            self:Tween(data.Button, {BackgroundColor3 = self.Theme.Accent}, 0.2)
            -- atualiza cor do ícone
            for _, ch in ipairs(data.Button:GetChildren()) do
                if ch:IsA("TextLabel") or ch:IsA("ImageLabel") then
                    if ch:IsA("TextLabel") then
                        self:Tween(ch, {TextColor3 = self.Theme.Text}, 0.2)
                    else
                        self:Tween(ch, {ImageColor3 = self.Theme.Text}, 0.2)
                    end
                end
            end
        else
            data.Container.Visible = false
            self:Tween(data.Button, {BackgroundColor3 = Color3.fromRGB(28, 28, 36)}, 0.2)
            for _, ch in ipairs(data.Button:GetChildren()) do
                if ch:IsA("TextLabel") or ch:IsA("ImageLabel") then
                    if ch:IsA("TextLabel") then
                        self:Tween(ch, {TextColor3 = self.Theme.TextMuted}, 0.2)
                    else
                        self:Tween(ch, {ImageColor3 = self.Theme.TextMuted}, 0.2)
                    end
                end
            end
        end
    end
    self.CurrentTab = tabId
end

-- ─── SECTION ──────────────────────────────────────────────────────────────────
function SpectrumX:CreateSection(parent, text, color)
    local section = Instance.new("TextLabel")
    section.BackgroundTransparency = 1
    section.Size        = UDim2.new(1, 0, 0, px(22))
    section.Font        = Enum.Font.GothamBlack
    section.Text        = text
    section.TextColor3  = color or self.Theme.Accent
    section.TextSize    = px(11)
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent      = parent
    return section
end

-- ─── TOGGLE ───────────────────────────────────────────────────────────────────
function SpectrumX:CreateToggle(parent, config)
    config = config or {}
    local text     = config.Text     or "Toggle"
    local default  = config.Default  or false
    local callback = config.Callback or function() end

    local H = px(38)

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = UDim2.new(1, 0, 0, H)
    frame.Parent           = parent
    self:CreateCorner(frame)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position   = UDim2.new(0, px(10), 0, 0)
    label.Size       = UDim2.new(0.7, 0, 1, 0)
    label.Font       = Enum.Font.GothamSemibold
    label.Text       = text
    label.TextColor3 = self.Theme.Text
    label.TextSize   = px(12)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent     = frame

    local swBg = Instance.new("TextButton")
    swBg.Text            = ""
    swBg.BackgroundColor3= default and self.Theme.ToggleOn or self.Theme.ToggleOff
    swBg.Position        = UDim2.new(1, -px(46), 0.5, -px(10))
    swBg.Size            = UDim2.new(0, px(36), 0, px(20))
    swBg.Parent          = frame
    self:CreateCorner(swBg, UDim.new(1, 0))

    local knob = Instance.new("Frame")
    knob.BackgroundColor3 = self.Theme.Text
    knob.Position         = default and UDim2.new(1, -px(17), 0.5, -px(8)) or UDim2.new(0, px(2), 0.5, -px(8))
    knob.Size             = UDim2.new(0, px(16), 0, px(16))
    knob.Parent           = swBg
    self:CreateCorner(knob, UDim.new(1, 0))

    local state = default

    local function update(s)
        if s then
            self:Tween(swBg,  {BackgroundColor3 = self.Theme.ToggleOn}, 0.2)
            self:Tween(knob,  {Position = UDim2.new(1, -px(17), 0.5, -px(8))}, 0.2)
        else
            self:Tween(swBg,  {BackgroundColor3 = self.Theme.ToggleOff}, 0.2)
            self:Tween(knob,  {Position = UDim2.new(0, px(2), 0.5, -px(8))}, 0.2)
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
        SetState = function(newState)
            state = newState
            callback(state)
            update(state)
        end
    }
end

-- ─── BUTTON ───────────────────────────────────────────────────────────────────
function SpectrumX:CreateButton(parent, config)
    config = config or {}
    local text     = config.Text     or "Button"
    local style    = config.Style    or "default"
    local callback = config.Callback or function() end

    local H = px(36)

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Background
    frame.Size             = UDim2.new(1, 0, 0, H)
    frame.Parent           = parent
    self:CreateCorner(frame)

    local btn = Instance.new("TextButton")
    btn.Name             = "Button"
    btn.BackgroundColor3 = self.Theme.Card
    btn.Position         = UDim2.new(0, px(4), 0, px(4))
    btn.Size             = UDim2.new(1, -px(8), 1, -px(8))
    btn.Font             = Enum.Font.GothamBold
    btn.Text             = text
    btn.TextSize         = px(12)
    btn.Parent           = frame
    self:CreateCorner(btn)

    local color = self.Theme.Accent
    if style == "warning" then
        color = self.Theme.Warning; btn.TextColor3 = self.Theme.Warning
    elseif style == "info" then
        color = self.Theme.Info;    btn.TextColor3 = self.Theme.Info
    elseif style == "accent" then
        btn.TextColor3 = self.Theme.Accent
    else
        btn.TextColor3 = self.Theme.Text
    end

    local stroke = self:CreateStroke(btn, color, 1, 0.65)

    btn.MouseEnter:Connect(function()
        self:Tween(btn,    {BackgroundColor3 = Color3.fromRGB(32, 32, 40)}, 0.15)
        self:Tween(stroke, {Transparency = 0.2}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        self:Tween(btn,    {BackgroundColor3 = self.Theme.Card}, 0.15)
        self:Tween(stroke, {Transparency = 0.65}, 0.15)
    end)
    btn.MouseButton1Click:Connect(function()
        self:Tween(btn, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, 0.07)
        task.wait(0.07)
        self:Tween(btn, {BackgroundColor3 = Color3.fromRGB(32, 32, 40)}, 0.12)
        callback()
    end)

    return {
        Frame   = frame,
        Button  = btn,
        SetText = function(t) btn.Text = t end,
    }
end

-- ─── INPUT ────────────────────────────────────────────────────────────────────
function SpectrumX:CreateInput(parent, config)
    config = config or {}
    local labelText = config.Label       or "Input"
    local default   = config.Default     or ""
    local placeholder = config.Placeholder or ""
    local callback  = config.Callback    or function() end

    local H = px(50)

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = UDim2.new(1, 0, 0, H)
    frame.Parent           = parent
    self:CreateCorner(frame)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position   = UDim2.new(0, px(10), 0, 0)
    label.Size       = UDim2.new(1, -px(20), 0, H * 0.48)
    label.Font       = Enum.Font.GothamSemibold
    label.Text       = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize   = px(11)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent     = frame

    local box = Instance.new("TextBox")
    box.BackgroundColor3 = self.Theme.Input
    box.Position         = UDim2.new(0, px(8), 0, H * 0.5 - px(1))
    box.Size             = UDim2.new(1, -px(16), 0, px(22))
    box.Font             = Enum.Font.Gotham
    box.Text             = tostring(default)
    box.PlaceholderText  = placeholder
    box.TextColor3       = self.Theme.Text
    box.PlaceholderColor3= self.Theme.TextMuted
    box.TextSize         = px(11)
    box.ClearTextOnFocus = false
    box.Parent           = frame
    self:CreateCorner(box, UDim.new(0, px(5)))

    local boxStroke = self:CreateStroke(box, self.Theme.Accent, 1, 0.7)

    box.Focused:Connect(function()  self:Tween(boxStroke, {Transparency = 0}, 0.2) end)
    box.FocusLost:Connect(function()
        self:Tween(boxStroke, {Transparency = 0.7}, 0.2)
        callback(box.Text)
    end)

    return {
        Frame   = frame,
        TextBox = box,
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

    local H = px(50)

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = UDim2.new(1, 0, 0, H)
    frame.Parent           = parent
    self:CreateCorner(frame)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position   = UDim2.new(0, px(10), 0, 0)
    label.Size       = UDim2.new(1, -px(20), 0, H * 0.48)
    label.Font       = Enum.Font.GothamSemibold
    label.Text       = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize   = px(11)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent     = frame

    local box = Instance.new("TextBox")
    box.BackgroundColor3 = self.Theme.Input
    box.Position         = UDim2.new(0, px(8), 0, H * 0.5 - px(1))
    box.Size             = UDim2.new(1, -px(16), 0, px(22))
    box.Font             = Enum.Font.Gotham
    box.Text             = tostring(default)
    box.TextColor3       = self.Theme.Text
    box.TextSize         = px(11)
    box.ClearTextOnFocus = false
    box.Parent           = frame
    self:CreateCorner(box, UDim.new(0, px(5)))

    local boxStroke = self:CreateStroke(box, self.Theme.Accent, 1, 0.7)

    box.Focused:Connect(function()  self:Tween(boxStroke, {Transparency = 0}, 0.2) end)
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
        Frame    = frame,
        TextBox  = box,
        GetValue = function() return tonumber(box.Text) end,
        SetValue = function(val)
            val = math.clamp(val, min, max)
            box.Text = tostring(val)
        end,
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

    local H = px(55)

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = UDim2.new(1, 0, 0, H)
    frame.Parent           = parent
    self:CreateCorner(frame)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position   = UDim2.new(0, px(10), 0, px(7))
    label.Size       = UDim2.new(0.6, 0, 0, px(18))
    label.Font       = Enum.Font.GothamSemibold
    label.Text       = text
    label.TextColor3 = self.Theme.Text
    label.TextSize   = px(12)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent     = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.BackgroundTransparency = 1
    valLabel.Position   = UDim2.new(0.6, 0, 0, px(7))
    valLabel.Size       = UDim2.new(0.35, -px(10), 0, px(18))
    valLabel.Font       = Enum.Font.GothamBold
    valLabel.Text       = tostring(default)
    valLabel.TextColor3 = self.Theme.Accent
    valLabel.TextSize   = px(12)
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent     = frame

    local track = Instance.new("Frame")
    track.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
    track.Position         = UDim2.new(0, px(10), 0, H - px(18))
    track.Size             = UDim2.new(1, -px(20), 0, px(6))
    track.Parent           = frame
    self:CreateCorner(track, UDim.new(1, 0))

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = self.Theme.Accent
    fill.Size             = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.Parent           = track
    self:CreateCorner(fill, UDim.new(1, 0))

    local knob = Instance.new("Frame")
    knob.BackgroundColor3 = self.Theme.Text
    knob.Position         = UDim2.new((default - min) / (max - min), -px(7), 0.5, -px(7))
    knob.Size             = UDim2.new(0, px(14), 0, px(14))
    knob.Parent           = track
    self:CreateCorner(knob, UDim.new(1, 0))
    self:CreateStroke(knob, self.Theme.Accent, 1.5, 0)

    local dragging  = false
    local currentValue = default

    local function updateSlider(input)
        local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val  = math.floor((min + (max - min) * relX) * 100) / 100
        currentValue = val
        fill.Size      = UDim2.new(relX, 0, 1, 0)
        knob.Position  = UDim2.new(relX, -px(7), 0.5, -px(7))
        valLabel.Text  = tostring(val)
        callback(val)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; updateSlider(input)
        end
    end)
    knob.InputBegan:Connect(function(input)
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
        Frame    = frame,
        GetValue = function() return currentValue end,
        SetValue = function(val)
            val = math.clamp(val, min, max)
            currentValue = val
            local p = (val - min) / (max - min)
            fill.Size     = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -px(7), 0.5, -px(7))
            valLabel.Text = tostring(val)
        end,
    }
end

-- ─── HELPER: Dropdown List (shared entre Single e Multi) ─────────────────────
-- Posiciona a lista ABAIXO do botão, verificando se cabe na tela (senão vai pra cima)
local function positionDropdown(dropdownList, dropdownBtn)
    local absPos  = dropdownBtn.AbsolutePosition
    local absSize = dropdownBtn.AbsoluteSize
    local listH   = dropdownList.AbsoluteSize.Y
    local vp      = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1366, 768)

    local yBelow = absPos.Y + absSize.Y + 4
    local yAbove = absPos.Y - listH - 4

    if yBelow + listH > vp.Y and yAbove > 0 then
        dropdownList.Position = UDim2.fromOffset(absPos.X, yAbove)
    else
        dropdownList.Position = UDim2.fromOffset(absPos.X, yBelow)
    end
end

-- ─── DROPDOWN (Single) ───────────────────────────────────────────────────────
function SpectrumX:CreateDropdown(parent, config)
    config = config or {}
    local labelText = config.Label    or "Dropdown"
    local options   = config.Options  or {}
    local default   = config.Default
    local callback  = config.Callback or function() end

    local H = px(52)

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = UDim2.new(1, 0, 0, H)
    frame.ClipsDescendants = false
    frame.Parent           = parent
    self:CreateCorner(frame)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position   = UDim2.new(0, px(10), 0, px(7))
    label.Size       = UDim2.new(1, -px(20), 0, px(16))
    label.Font       = Enum.Font.GothamBold
    label.Text       = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize   = px(11)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent     = frame

    local dropBtn = Instance.new("TextButton")
    dropBtn.BackgroundColor3 = self.Theme.Input
    dropBtn.Position         = UDim2.new(0, px(8), 0, px(26))
    dropBtn.Size             = UDim2.new(1, -px(16), 0, px(22))
    dropBtn.Font             = Enum.Font.GothamSemibold
    dropBtn.Text             = "  " .. (default or "Select...")
    dropBtn.TextColor3       = self.Theme.TextSecondary
    dropBtn.TextSize         = px(11)
    dropBtn.TextXAlignment   = Enum.TextXAlignment.Left
    dropBtn.ZIndex           = 2
    dropBtn.Parent           = frame
    self:CreateCorner(dropBtn, UDim.new(0, px(5)))

    local dropStroke = self:CreateStroke(dropBtn, self.Theme.Accent, 1, 0.6)

    local arrow = Instance.new("TextLabel")
    arrow.BackgroundTransparency = 1
    arrow.Position   = UDim2.new(1, -px(20), 0, 0)
    arrow.Size       = UDim2.new(0, px(18), 1, 0)
    arrow.Font       = Enum.Font.GothamBold
    arrow.Text       = "▼"
    arrow.TextColor3 = self.Theme.Accent
    arrow.TextSize   = px(9)
    arrow.Parent     = dropBtn

    -- List (parented to ScreenGui para ZIndex correto)
    local dropList = Instance.new("ScrollingFrame")
    dropList.Name                 = "DropdownList_" .. labelText
    dropList.BackgroundColor3     = self.Theme.Card
    dropList.Size                 = UDim2.new(0, px(200), 0, 0)
    dropList.ScrollBarThickness   = px(2)
    dropList.ScrollBarImageColor3 = self.Theme.Accent
    dropList.Visible              = false
    dropList.ZIndex               = 2000
    dropList.BorderSizePixel      = 0
    dropList.Parent               = self.ScreenGui
    self:CreateCorner(dropList, UDim.new(0, px(6)))
    self:CreateStroke(dropList, self.Theme.Accent, 1.5, 0)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding   = UDim.new(0, px(3))
    listLayout.Parent    = dropList

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop    = UDim.new(0, px(5))
    listPad.PaddingBottom = UDim.new(0, px(5))
    listPad.PaddingLeft   = UDim.new(0, px(5))
    listPad.PaddingRight  = UDim.new(0, px(5))
    listPad.Parent        = dropList

    local selectedValue = default
    local isOpen        = false

    local function closeAll()
        for _, ch in ipairs(self.ScreenGui:GetChildren()) do
            if (ch.Name:find("DropdownList_") or ch.Name:find("MultiDropdownList_")) and ch ~= dropList then
                ch.Visible = false
                ch.Size    = UDim2.new(0, ch.AbsoluteSize.X, 0, 0)
            end
        end
    end

    local function updateHeight()
        local h = math.min(listLayout.AbsoluteContentSize.Y + px(12), px(180))
        dropList.Size      = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, h)
        dropList.CanvasSize= UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + px(12))
        positionDropdown(dropList, dropBtn)
    end

    local function populate()
        for _, ch in ipairs(dropList:GetChildren()) do
            if ch:IsA("Frame") then ch:Destroy() end
        end
        for _, option in ipairs(options) do
            local isSel = option == selectedValue
            local oFrame = Instance.new("Frame")
            oFrame.BackgroundColor3 = isSel and Color3.fromRGB(60, 20, 20) or self.Theme.Input
            oFrame.Size             = UDim2.new(1, 0, 0, px(28))
            oFrame.ZIndex           = 2001
            oFrame.Parent           = dropList
            self:CreateCorner(oFrame, UDim.new(0, px(5)))
            if isSel then self:CreateStroke(oFrame, self.Theme.Accent, 1, 0.3) end

            local oBtn = Instance.new("TextButton")
            oBtn.BackgroundTransparency = 1
            oBtn.Size      = UDim2.new(1, 0, 1, 0)
            oBtn.Font      = Enum.Font.GothamSemibold
            oBtn.Text      = (isSel and "✔ " or "  ") .. option
            oBtn.TextColor3= isSel and self.Theme.Accent or self.Theme.TextSecondary
            oBtn.TextSize  = px(11)
            oBtn.TextXAlignment = Enum.TextXAlignment.Left
            oBtn.ZIndex    = 2002
            oBtn.Parent    = oFrame
            local p = Instance.new("UIPadding")
            p.PaddingLeft = UDim.new(0, px(8))
            p.Parent      = oBtn

            oBtn.MouseButton1Click:Connect(function()
                selectedValue    = option
                dropBtn.Text     = "  " .. option
                dropBtn.TextColor3 = self.Theme.Text
                callback(option)
                isOpen = false
                self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)}, 0.25)
                self:Tween(arrow,    {Rotation = 0}, 0.2)
                task.wait(0.25)
                dropList.Visible = false
            end)
            oBtn.MouseEnter:Connect(function() self:Tween(oFrame, {BackgroundColor3 = Color3.fromRGB(45, 45, 58)}, 0.12) end)
            oBtn.MouseLeave:Connect(function() self:Tween(oFrame, {BackgroundColor3 = isSel and Color3.fromRGB(60,20,20) or self.Theme.Input}, 0.12) end)
        end
        task.defer(updateHeight)
    end

    dropBtn.MouseButton1Click:Connect(function()
        if isOpen then
            isOpen = false
            self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)}, 0.25)
            self:Tween(arrow,    {Rotation = 0}, 0.2)
            task.wait(0.25)
            dropList.Visible = false
        else
            closeAll()
            dropList.Visible = true
            populate()
            self:Tween(arrow, {Rotation = 180}, 0.2)
            isOpen = true
        end
    end)

    dropBtn.MouseEnter:Connect(function() self:Tween(dropBtn, {BackgroundColor3 = Color3.fromRGB(38, 38, 50)}, 0.12) end)
    dropBtn.MouseLeave:Connect(function() self:Tween(dropBtn, {BackgroundColor3 = self.Theme.Input}, 0.12) end)

    return {
        Frame      = frame,
        GetValue   = function() return selectedValue end,
        SetValue   = function(val)
            selectedValue = val
            dropBtn.Text  = "  " .. (val or "Select...")
            dropBtn.TextColor3 = val and self.Theme.Text or self.Theme.TextSecondary
        end,
        SetOptions = function(newOpts)
            options = newOpts
            if isOpen then populate() end
        end,
    }
end

-- ─── MULTI DROPDOWN ──────────────────────────────────────────────────────────
function SpectrumX:CreateMultiDropdown(parent, config)
    config = config or {}
    local labelText = config.Label    or "Multi Select"
    local options   = config.Options  or {}
    local default   = config.Default  or {}
    local callback  = config.Callback or function() end

    local H = px(52)

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = UDim2.new(1, 0, 0, H)
    frame.ClipsDescendants = false
    frame.Parent           = parent
    self:CreateCorner(frame)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position   = UDim2.new(0, px(10), 0, px(7))
    label.Size       = UDim2.new(1, -px(20), 0, px(16))
    label.Font       = Enum.Font.GothamBold
    label.Text       = labelText
    label.TextColor3 = self.Theme.Text
    label.TextSize   = px(11)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent     = frame

    local dropBtn = Instance.new("TextButton")
    dropBtn.BackgroundColor3 = self.Theme.Input
    dropBtn.Position         = UDim2.new(0, px(8), 0, px(26))
    dropBtn.Size             = UDim2.new(1, -px(16), 0, px(22))
    dropBtn.Font             = Enum.Font.GothamSemibold
    dropBtn.Text             = "  Select Options..."
    dropBtn.TextColor3       = self.Theme.TextSecondary
    dropBtn.TextSize         = px(11)
    dropBtn.TextXAlignment   = Enum.TextXAlignment.Left
    dropBtn.ZIndex           = 2
    dropBtn.Parent           = frame
    self:CreateCorner(dropBtn, UDim.new(0, px(5)))

    self:CreateStroke(dropBtn, self.Theme.Accent, 1, 0.6)

    local arrow = Instance.new("TextLabel")
    arrow.BackgroundTransparency = 1
    arrow.Position   = UDim2.new(1, -px(20), 0, 0)
    arrow.Size       = UDim2.new(0, px(18), 1, 0)
    arrow.Font       = Enum.Font.GothamBold
    arrow.Text       = "▼"
    arrow.TextColor3 = self.Theme.Accent
    arrow.TextSize   = px(9)
    arrow.Parent     = dropBtn

    local dropList = Instance.new("ScrollingFrame")
    dropList.Name                 = "MultiDropdownList_" .. labelText
    dropList.BackgroundColor3     = self.Theme.Card
    dropList.Size                 = UDim2.new(0, px(200), 0, 0)
    dropList.ScrollBarThickness   = px(2)
    dropList.ScrollBarImageColor3 = self.Theme.Accent
    dropList.Visible              = false
    dropList.ZIndex               = 2000
    dropList.BorderSizePixel      = 0
    dropList.Parent               = self.ScreenGui
    self:CreateCorner(dropList, UDim.new(0, px(6)))
    self:CreateStroke(dropList, self.Theme.Accent, 1.5, 0)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding   = UDim.new(0, px(3))
    listLayout.Parent    = dropList

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop    = UDim.new(0, px(5))
    listPad.PaddingBottom = UDim.new(0, px(5))
    listPad.PaddingLeft   = UDim.new(0, px(5))
    listPad.PaddingRight  = UDim.new(0, px(5))
    listPad.Parent        = dropList

    local selectedValues = {}
    for _, v in ipairs(default) do table.insert(selectedValues, v) end
    local isOpen = false

    local function updateBtnText()
        if #selectedValues == 0 then
            dropBtn.Text = "  Select Options..."
            dropBtn.TextColor3 = self.Theme.TextSecondary
        elseif #selectedValues == 1 then
            dropBtn.Text = "  " .. selectedValues[1]
            dropBtn.TextColor3 = self.Theme.Text
        else
            dropBtn.Text = "  " .. #selectedValues .. " selected"
            dropBtn.TextColor3 = self.Theme.Text
        end
    end

    local function updateHeight()
        local h = math.min(listLayout.AbsoluteContentSize.Y + px(12), px(200))
        dropList.Size       = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, h)
        dropList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + px(12))
        positionDropdown(dropList, dropBtn)
    end

    local function getPriority(name)
        for i, v in ipairs(selectedValues) do
            if v == name then return i end
        end
    end

    local function populate()
        for _, ch in ipairs(dropList:GetChildren()) do
            if ch:IsA("Frame") then ch:Destroy() end
        end
        for _, option in ipairs(options) do
            local prio  = getPriority(option)
            local isSel = prio ~= nil

            local oFrame = Instance.new("Frame")
            oFrame.BackgroundColor3 = isSel and Color3.fromRGB(60, 20, 20) or self.Theme.Input
            oFrame.Size             = UDim2.new(1, 0, 0, px(28))
            oFrame.ZIndex           = 2001
            oFrame.Parent           = dropList
            self:CreateCorner(oFrame, UDim.new(0, px(5)))
            if isSel then self:CreateStroke(oFrame, self.Theme.Accent, 1, 0.3) end

            local oBtn = Instance.new("TextButton")
            oBtn.BackgroundTransparency = 1
            oBtn.Size      = UDim2.new(1, 0, 1, 0)
            oBtn.Font      = Enum.Font.GothamSemibold
            oBtn.Text      = (isSel and ("✔ " .. prio .. ". ") or "  ") .. option
            oBtn.TextColor3= isSel and self.Theme.Accent or self.Theme.TextSecondary
            oBtn.TextSize  = px(11)
            oBtn.TextXAlignment = Enum.TextXAlignment.Left
            oBtn.ZIndex    = 2002
            oBtn.Parent    = oFrame
            local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, px(8)); p.Parent = oBtn

            oBtn.MouseButton1Click:Connect(function()
                local found = false
                for i, v in ipairs(selectedValues) do
                    if v == option then
                        table.remove(selectedValues, i)
                        found = true; break
                    end
                end
                if not found then table.insert(selectedValues, option) end
                callback(selectedValues)
                updateBtnText()
                populate()
            end)
            oBtn.MouseEnter:Connect(function() self:Tween(oFrame, {BackgroundColor3 = Color3.fromRGB(45, 45, 58)}, 0.12) end)
            oBtn.MouseLeave:Connect(function() self:Tween(oFrame, {BackgroundColor3 = isSel and Color3.fromRGB(60,20,20) or self.Theme.Input}, 0.12) end)
        end
        task.defer(updateHeight)
    end

    local function closeAll()
        for _, ch in ipairs(self.ScreenGui:GetChildren()) do
            if (ch.Name:find("DropdownList_") or ch.Name:find("MultiDropdownList_")) and ch ~= dropList then
                ch.Visible = false
            end
        end
    end

    dropBtn.MouseButton1Click:Connect(function()
        if isOpen then
            isOpen = false
            self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)}, 0.25)
            self:Tween(arrow,    {Rotation = 0}, 0.2)
            task.wait(0.25)
            dropList.Visible = false
        else
            closeAll()
            dropList.Visible = true
            populate()
            self:Tween(arrow, {Rotation = 180}, 0.2)
            isOpen = true
        end
    end)

    dropBtn.MouseEnter:Connect(function() self:Tween(dropBtn, {BackgroundColor3 = Color3.fromRGB(38, 38, 50)}, 0.12) end)
    dropBtn.MouseLeave:Connect(function() self:Tween(dropBtn, {BackgroundColor3 = self.Theme.Input}, 0.12) end)

    updateBtnText()

    return {
        Frame      = frame,
        GetValues  = function() return selectedValues end,
        SetValues  = function(vals) selectedValues = vals; updateBtnText() end,
        SetOptions = function(newOpts)
            options = newOpts
            if isOpen then populate() end
        end,
    }
end

-- ─── CHECKBOX ─────────────────────────────────────────────────────────────────
function SpectrumX:CreateCheckbox(parent, config)
    config = config or {}
    local text     = config.Text     or "Checkbox"
    local default  = config.Default  or false
    local callback = config.Callback or function() end

    local H = px(34)

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = UDim2.new(1, 0, 0, H)
    frame.Parent           = parent
    self:CreateCorner(frame)

    local box = Instance.new("TextButton")
    box.BackgroundColor3 = default and self.Theme.Accent or self.Theme.Input
    box.Position         = UDim2.new(0, px(10), 0.5, -px(9))
    box.Size             = UDim2.new(0, px(18), 0, px(18))
    box.Font             = Enum.Font.GothamBold
    box.Text             = default and "✓" or ""
    box.TextColor3       = self.Theme.Text
    box.TextSize         = px(12)
    box.Parent           = frame
    self:CreateCorner(box, UDim.new(0, px(4)))
    self:CreateStroke(box, self.Theme.Accent, 1.5, 0.4)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position   = UDim2.new(0, px(36), 0, 0)
    label.Size       = UDim2.new(1, -px(46), 1, 0)
    label.Font       = Enum.Font.GothamSemibold
    label.Text       = text
    label.TextColor3 = self.Theme.Text
    label.TextSize   = px(12)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent     = frame

    local state = default

    box.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        self:Tween(box, {BackgroundColor3 = state and self.Theme.Accent or self.Theme.Input}, 0.15)
        box.Text = state and "✓" or ""
    end)

    return {
        Frame    = frame,
        GetState = function() return state end,
        SetState = function(newState)
            state = newState
            callback(state)
            self:Tween(box, {BackgroundColor3 = state and self.Theme.Accent or self.Theme.Input}, 0.15)
            box.Text = state and "✓" or ""
        end,
    }
end

-- ─── LABEL ────────────────────────────────────────────────────────────────────
function SpectrumX:CreateLabel(parent, config)
    config = config or {}
    local text  = config.Text  or "Label"
    local color = config.Color or self.Theme.Text
    local size  = config.Size  or UDim2.new(1, 0, 0, px(26))

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.Size             = size
    frame.Parent           = parent
    self:CreateCorner(frame)

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Position   = UDim2.new(0, px(10), 0, 0)
    lbl.Size       = UDim2.new(1, -px(20), 1, 0)
    lbl.Font       = Enum.Font.GothamSemibold
    lbl.Text       = text
    lbl.TextColor3 = color
    lbl.TextSize   = px(12)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent     = frame

    return {
        Frame   = frame,
        Label   = lbl,
        SetText = function(t) lbl.Text = t end,
    }
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

    local H = px(95)

    local frame = Instance.new("Frame")
    frame.Name             = "StatusCard"
    frame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    frame.BorderSizePixel  = 0
    frame.Size             = UDim2.new(1, 0, 0, H)
    frame.Parent           = parent
    self:CreateCorner(frame, UDim.new(0, px(8)))

    local statusStroke = self:CreateStroke(frame, self.Theme.Accent, 1.5, 0.2)

    spawn(function()
        while frame.Parent do
            self:Tween(statusStroke, {Transparency = 0},   0.8)
            task.wait(0.85)
            self:Tween(statusStroke, {Transparency = 0.45}, 0.8)
            task.wait(0.85)
        end
    end)

    local header = Instance.new("Frame")
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    header.BorderSizePixel  = 0
    header.Size             = UDim2.new(1, 0, 0, px(26))
    header.Parent           = frame
    self:CreateCorner(header, UDim.new(0, px(8)))
    local hCover = Instance.new("Frame")
    hCover.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    hCover.BorderSizePixel  = 0
    hCover.Size             = UDim2.new(1, 0, 0, px(8))
    hCover.Position         = UDim2.new(0, 0, 1, -px(8))
    hCover.Parent           = header

    local ht = Instance.new("TextLabel")
    ht.BackgroundTransparency = 1
    ht.Size      = UDim2.new(1, -px(10), 1, 0)
    ht.Position  = UDim2.new(0, px(10), 0, 0)
    ht.Font      = Enum.Font.GothamBold
    ht.Text      = title
    ht.TextColor3= self.Theme.Text
    ht.TextSize  = px(10)
    ht.TextXAlignment = Enum.TextXAlignment.Left
    ht.Parent    = header

    local content = Instance.new("Frame")
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, px(10), 0, px(30))
    content.Size     = UDim2.new(1, -px(20), 1, -px(36))
    content.Parent   = frame

    local statusLbl = Instance.new("TextLabel")
    statusLbl.BackgroundTransparency = 1
    statusLbl.Size       = UDim2.new(1, 0, 0, px(17))
    statusLbl.Font       = Enum.Font.GothamSemibold
    statusLbl.Text       = "● Idle"
    statusLbl.TextColor3 = self.Theme.TextMuted
    statusLbl.TextSize   = px(11)
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.Parent     = content

    local infoLbl = Instance.new("TextLabel")
    infoLbl.BackgroundTransparency = 1
    infoLbl.Position = UDim2.new(0, 0, 0, px(20))
    infoLbl.Size     = UDim2.new(1, 0, 0, px(14))
    infoLbl.Font     = Enum.Font.Gotham
    infoLbl.Text     = "Ready"
    infoLbl.TextColor3 = self.Theme.TextSecondary
    infoLbl.TextSize = px(10)
    infoLbl.TextXAlignment = Enum.TextXAlignment.Left
    infoLbl.Parent   = content

    local barBg = Instance.new("Frame")
    barBg.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    barBg.Position         = UDim2.new(0, 0, 1, -px(6))
    barBg.Size             = UDim2.new(1, 0, 0, px(4))
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
        Frame   = frame,
        SetStatus = function(status, color)
            statusLbl.Text      = "● " .. status
            statusLbl.TextColor3= color or self.Theme.TextMuted
        end,
        SetInfo = function(info)
            infoLbl.Text = info
        end,
        AnimateLoading = function(active, duration)
            if active then
                spawn(function()
                    while active and frame.Parent do
                        local t = self:Tween(bar, {Size = UDim2.new(1, 0, 1, 0)}, duration or 1.5)
                        t.Completed:Wait()
                        task.wait(0.1)
                        bar.Size = UDim2.new(0, 0, 1, 0)
                        task.wait(0.1)
                    end
                end)
            else
                bar.Size = UDim2.new(0, 0, 1, 0)
            end
        end,
    }
end

-- ─── NOTIFICAÇÕES ─────────────────────────────────────────────────────────────
-- Sistema de fila: notificações empilhadas no canto inferior direito,
-- tamanho responsivo, fecham ao clicar.
function SpectrumX:Notify(config)
    config = config or {}
    local text     = config.Text     or "Notification"
    local ntype    = config.Type     or "info"
    local duration = config.Duration or 3

    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1366, 768)
    local nW = math.min(px(280), vp.X - px(20))
    local nH = px(56)

    local color = self.Theme.Info
    if ntype == "success" then     color = self.Theme.Success
    elseif ntype == "warning" then color = self.Theme.Warning
    elseif ntype == "error" then   color = Color3.fromRGB(255, 55, 55)
    end

    local icon = ntype == "success" and "✓" or ntype == "warning" and "!" or ntype == "error" and "✕" or "i"

    local notif = Instance.new("Frame")
    notif.BackgroundColor3 = self.Theme.Card
    notif.Size             = UDim2.new(0, nW, 0, nH)
    notif.Position         = UDim2.fromOffset(vp.X + nW, vp.Y - nH - px(12))
    notif.Parent           = self.ScreenGui
    notif.ClipsDescendants = false
    self:CreateCorner(notif, UDim.new(0, px(8)))
    self:CreateStroke(notif, color, 1.5, 0.25)
    self:CreateShadow(notif)

    -- Barra colorida esquerda
    local bar = Instance.new("Frame")
    bar.BackgroundColor3 = color
    bar.BorderSizePixel  = 0
    bar.Size             = UDim2.new(0, px(3), 1, -px(16))
    bar.Position         = UDim2.new(0, 0, 0, px(8))
    bar.Parent           = notif
    self:CreateCorner(bar, UDim.new(1, 0))

    local iconLbl = Instance.new("TextLabel")
    iconLbl.BackgroundTransparency = 1
    iconLbl.Position   = UDim2.new(0, px(10), 0, 0)
    iconLbl.Size       = UDim2.new(0, px(26), 1, 0)
    iconLbl.Font       = Enum.Font.GothamBlack
    iconLbl.Text       = icon
    iconLbl.TextColor3 = color
    iconLbl.TextSize   = px(18)
    iconLbl.Parent     = notif

    local txtLbl = Instance.new("TextLabel")
    txtLbl.BackgroundTransparency = 1
    txtLbl.Position      = UDim2.new(0, px(42), 0, 0)
    txtLbl.Size          = UDim2.new(1, -px(50), 1, 0)
    txtLbl.Font          = Enum.Font.GothamSemibold
    txtLbl.Text          = text
    txtLbl.TextColor3    = self.Theme.Text
    txtLbl.TextSize      = px(11)
    txtLbl.TextWrapped   = true
    txtLbl.TextXAlignment= Enum.TextXAlignment.Left
    txtLbl.Parent        = notif

    -- Barra de progresso de duração
    local progBg = Instance.new("Frame")
    progBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    progBg.BorderSizePixel  = 0
    progBg.Position         = UDim2.new(0, 0, 1, -px(3))
    progBg.Size             = UDim2.new(1, 0, 0, px(3))
    progBg.ClipsDescendants = true
    progBg.Parent           = notif
    self:CreateCorner(progBg, UDim.new(1, 0))

    local prog = Instance.new("Frame")
    prog.BackgroundColor3 = color
    prog.BorderSizePixel  = 0
    prog.Size             = UDim2.new(1, 0, 1, 0)
    prog.Parent           = progBg

    -- Clicar fecha
    local closeButton = Instance.new("TextButton")
    closeButton.BackgroundTransparency = 1
    closeButton.Size   = UDim2.new(1, 0, 1, 0)
    closeButton.Text   = ""
    closeButton.ZIndex = 3
    closeButton.Parent = notif

    -- Registra na fila
    table.insert(self._notifications, notif)

    local function getStackOffset(n)
        local off = px(12)
        for i = 1, #self._notifications do
            if self._notifications[i] == n then break end
            local h = self._notifications[i].AbsoluteSize.Y + px(8)
            off = off + h
        end
        return off
    end

    local function repositionAll()
        for i, n in ipairs(self._notifications) do
            local off = px(12)
            for j = i+1, #self._notifications do
                off = off + self._notifications[j].AbsoluteSize.Y + px(8)
            end
            self:Tween(n, {Position = UDim2.fromOffset(vp.X - nW - px(12), vp.Y - n.AbsoluteSize.Y - off)}, 0.3)
        end
    end

    local function dismiss()
        -- Remove da fila
        for i, n in ipairs(self._notifications) do
            if n == notif then table.remove(self._notifications, i); break end
        end
        self:Tween(notif, {Position = UDim2.fromOffset(vp.X + nW, notif.AbsolutePosition.Y)}, 0.35)
        repositionAll()
        task.wait(0.4)
        notif:Destroy()
    end

    closeButton.MouseButton1Click:Connect(dismiss)

    -- Slide in
    local targetY = vp.Y - nH - px(12)
    self:Tween(notif, {Position = UDim2.fromOffset(vp.X - nW - px(12), targetY)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    repositionAll()

    -- Progress bar
    self:Tween(prog, {Size = UDim2.new(0, 0, 1, 0)}, duration)

    task.delay(duration, function()
        if notif.Parent then
            dismiss()
        end
    end)
end

-- ─── DESTROY ──────────────────────────────────────────────────────────────────
function SpectrumX:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return SpectrumX

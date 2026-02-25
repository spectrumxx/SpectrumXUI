--[[
    SpectrumX UI Library - Remastered Premium
    Visual premium, preto puro, detalhes vermelhos, responsivo.
    API 100% compatível. Funciona via loadstring.

    Uso:
        local SpectrumX = loadstring(game:HttpGet("URL"))()
        local Window = SpectrumX:CreateWindow({ Title = "Meu Script", Icon = "S" })
        local Tab = Window:CreateTab({ Name = "Main", Icon = "M" })
        SpectrumX:CreateToggle(Tab.Left, { Text = "Auto Farm", Callback = function(v) end })
]]

local SpectrumX = {}
SpectrumX.__index = SpectrumX

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ─── THEME ── preto puro, detalhes vermelhos ──────────────────────────────────
SpectrumX.Theme = {
    Background      = Color3.fromRGB(8, 8, 8),
    Header          = Color3.fromRGB(12, 12, 12),
    Sidebar         = Color3.fromRGB(10, 10, 10),
    Card            = Color3.fromRGB(16, 16, 16),
    CardHover       = Color3.fromRGB(22, 22, 22),
    Input           = Color3.fromRGB(20, 20, 20),
    InputHover      = Color3.fromRGB(28, 28, 28),
    Accent          = Color3.fromRGB(220, 35, 35),
    AccentHover     = Color3.fromRGB(255, 55, 55),
    AccentSecondary = Color3.fromRGB(255, 100, 100),
    AccentDark      = Color3.fromRGB(140, 20, 20),
    Text            = Color3.fromRGB(255, 255, 255),
    TextSecondary   = Color3.fromRGB(185, 185, 185),
    TextMuted       = Color3.fromRGB(110, 110, 110),
    Success         = Color3.fromRGB(60, 220, 100),
    Warning         = Color3.fromRGB(255, 190, 60),
    Info            = Color3.fromRGB(80, 160, 255),
    Error           = Color3.fromRGB(255, 55, 55),
    Border          = Color3.fromRGB(30, 30, 30),
    BorderBright    = Color3.fromRGB(50, 50, 50),
    ToggleOff       = Color3.fromRGB(30, 30, 30),
    ToggleOn        = Color3.fromRGB(220, 35, 35),
}

-- ─── ESCALA RESPONSIVA ────────────────────────────────────────────────────────
local ScaleData = { IsMobile = false, ScaleFactor = 1 }

function SpectrumX:UpdateScale()
    local ok, cam = pcall(function() return workspace.CurrentCamera end)
    if not ok or not cam then return end
    local vp = cam.ViewportSize
    if vp.X == 0 then return end
    ScaleData.IsMobile = UserInputService.TouchEnabled and (vp.X < 1200 or vp.Y < 700)
    local base = math.min(vp.X / 1920, vp.Y / 1080)
    if ScaleData.IsMobile then
        ScaleData.ScaleFactor = math.clamp(base, 0.85, 1.2)
    else
        ScaleData.ScaleFactor = math.clamp(base, 0.7, 1.1)
    end
end

function SpectrumX:S(v)
    if type(v) == "number" then return math.floor(v * ScaleData.ScaleFactor) end
    if typeof(v) == "UDim2" then
        return UDim2.new(v.X.Scale, math.floor(v.X.Offset * ScaleData.ScaleFactor),
                         v.Y.Scale, math.floor(v.Y.Offset * ScaleData.ScaleFactor))
    end
    return v
end

-- ─── UTILITÁRIOS ─────────────────────────────────────────────────────────────
function SpectrumX:Tween(obj, props, t, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(t or 0.2,
        style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play(); return tw
end

function SpectrumX:CreateCorner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = r or UDim.new(0, 7); c.Parent = p; return c
end

function SpectrumX:CreateStroke(p, color, thick, transp)
    local s = Instance.new("UIStroke")
    s.Color = color or self.Theme.Border; s.Thickness = thick or 1
    s.Transparency = transp or 0.5; s.Parent = p; return s
end

function SpectrumX:CreateShadow(p, sz)
    local sh = Instance.new("ImageLabel")
    sh.Name = "Shadow"; sh.AnchorPoint = Vector2.new(0.5, 0.5)
    sh.BackgroundTransparency = 1; sh.Position = UDim2.new(0.5,0,0.5,0)
    sh.Size = UDim2.new(1, sz or 40, 1, sz or 40); sh.ZIndex = -1
    sh.Image = "rbxassetid://6015897843"
    sh.ImageColor3 = Color3.new(0,0,0); sh.ImageTransparency = 0.4; sh.Parent = p; return sh
end

-- Gradient horizontal (decorativo)
local function makeGradient(p, c0, c1, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c0, c1); g.Rotation = rot or 0; g.Parent = p; return g
end

function SpectrumX:MakeDraggable(frame, handle)
    handle = handle or frame
    local drag, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            drag = true; dragStart = i.Position; startPos = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or
           i.UserInputType == Enum.UserInputType.Touch then dragInput = i end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i == dragInput and drag then
            local d = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                       startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ─── FECHAR DROPDOWNS AO CLICAR FORA ─────────────────────────────────────────
function SpectrumX:_RegisterDropdown(list, btn, closeFn)
    if not self._drops then self._drops = {} end
    table.insert(self._drops, {list=list, btn=btn, close=closeFn})
    table.insert(self.Dropdowns, list)
end

function SpectrumX:_CloseOnOutside(pos)
    if not self._drops then return end
    for _, e in ipairs(self._drops) do
        if not e.list or not e.list.Visible then continue end
        local lp,ls = e.list.AbsolutePosition, e.list.AbsoluteSize
        local bp,bs = e.btn.AbsolutePosition,  e.btn.AbsoluteSize
        local inL = pos.X>=lp.X and pos.X<=lp.X+ls.X and pos.Y>=lp.Y and pos.Y<=lp.Y+ls.Y
        local inB = pos.X>=bp.X and pos.X<=bp.X+bs.X and pos.Y>=bp.Y and pos.Y<=bp.Y+bs.Y
        if not inL and not inB then task.spawn(e.close) end
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
    self.ScreenGui.Name = "SpectrumX"; self.ScreenGui.Parent = PlayerGui
    self.ScreenGui.ResetOnSpawn = false; self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.IgnoreGuiInset = true; self.ScreenGui.DisplayOrder = 999

    self._notifications = {}; self.Dropdowns = {}; self._drops = {}

    -- Tamanho da janela
    local W = ScaleData.IsMobile and self:S(430) or self:S(660)
    local H = ScaleData.IsMobile and self:S(570) or self:S(430)
    local px = ScaleData.IsMobile and -(W/2) or -(W/2)
    local py = ScaleData.IsMobile and -(H/2) or -(H/2)

    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Position = config.Position or UDim2.new(0.5, px, 0.5, py)
    self.MainFrame.Size = config.Size or UDim2.new(0, W, 0, H)
    self.MainFrame.Active = true; self.MainFrame.Visible = true
    self.MainFrame.Parent = self.ScreenGui
    self:CreateCorner(self.MainFrame, UDim.new(0, 12))
    self:CreateShadow(self.MainFrame, 70)

    -- Borda vermelha principal
    local mainStroke = self:CreateStroke(self.MainFrame, self.Theme.Accent, 1.5, 0)
    -- Linha vermelha topo (accent bar)
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"; accentBar.BackgroundColor3 = self.Theme.Accent
    accentBar.BorderSizePixel = 0; accentBar.Size = UDim2.new(1, 0, 0, 2)
    accentBar.ZIndex = 5; accentBar.Parent = self.MainFrame

    -- ── HEADER ────────────────────────────────────────────────────────────────
    local HH = self:S(54)
    self.Header = Instance.new("Frame")
    self.Header.Name = "Header"; self.Header.BackgroundColor3 = self.Theme.Header
    self.Header.BorderSizePixel = 0; self.Header.Size = UDim2.new(1, 0, 0, HH)
    self.Header.Position = UDim2.new(0,0,0,2); self.Header.ZIndex = 2
    self.Header.Parent = self.MainFrame
    self:CreateCorner(self.Header, UDim.new(0, 12))

    -- Cover para arredondar só em cima
    local hCov = Instance.new("Frame")
    hCov.BackgroundColor3 = self.Theme.Header; hCov.BorderSizePixel = 0
    hCov.Size = UDim2.new(1,0,0,12); hCov.Position = UDim2.new(0,0,1,-12)
    hCov.ZIndex = 2; hCov.Parent = self.Header

    -- Separador vermelho embaixo do header
    local hLine = Instance.new("Frame")
    hLine.BackgroundColor3 = self.Theme.Accent; hLine.BorderSizePixel = 0
    hLine.Size = UDim2.new(1,0,0,1); hLine.Position = UDim2.new(0,0,1,0)
    hLine.ZIndex = 3; hLine.Parent = self.Header
    makeGradient(hLine,
        Color3.fromRGB(0,0,0),
        self.Theme.Accent, 0)

    -- Ícone header
    local iconX = self:S(16)
    if config.IconAssetId and config.IconAssetId ~= "" then
        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.Position = UDim2.new(0, iconX, 0.5, -self:S(16))
        img.Size = UDim2.new(0, self:S(32), 0, self:S(32))
        img.Image = config.IconAssetId; img.ScaleType = Enum.ScaleType.Fit
        img.ZIndex = 3; img.Parent = self.Header
        Instance.new("UIAspectRatioConstraint").Parent = img
    else
        -- Letra com fundo quadrado vermelho
        local iconBg = Instance.new("Frame")
        iconBg.BackgroundColor3 = self.Theme.Accent
        iconBg.Position = UDim2.new(0, iconX, 0.5, -self:S(15))
        iconBg.Size = UDim2.new(0, self:S(30), 0, self:S(30))
        iconBg.ZIndex = 3; iconBg.Parent = self.Header
        self:CreateCorner(iconBg, UDim.new(0, 6))
        local ico = Instance.new("TextLabel")
        ico.BackgroundTransparency = 1; ico.Size = UDim2.new(1,0,1,0)
        ico.Font = Enum.Font.GothamBlack; ico.Text = config.Icon or "S"
        ico.TextColor3 = Color3.new(1,1,1); ico.TextSize = self:S(17)
        ico.ZIndex = 4; ico.Parent = iconBg
    end

    local titleX = iconX + self:S(42)
    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, titleX, 0, 0)
    titleLbl.Size = UDim2.new(0, self:S(300), 1, 0)
    titleLbl.Font = Enum.Font.GothamBold; titleLbl.Text = config.Title or "Spectrum X"
    titleLbl.TextColor3 = self.Theme.Text; titleLbl.TextSize = self:S(18)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 3; titleLbl.Parent = self.Header
    makeGradient(titleLbl, self.Theme.Text, self.Theme.AccentSecondary, 0)

    if config.Subtitle then
        titleLbl.Size = UDim2.new(0, self:S(300), 0, self:S(24))
        titleLbl.Position = UDim2.new(0, titleX, 0, self:S(8))
        local sub = Instance.new("TextLabel")
        sub.BackgroundTransparency = 1
        sub.Position = UDim2.new(0, titleX, 0, self:S(28))
        sub.Size = UDim2.new(0, self:S(300), 0, self:S(16))
        sub.Font = Enum.Font.Gotham; sub.Text = config.Subtitle
        sub.TextColor3 = self.Theme.TextMuted; sub.TextSize = self:S(10)
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.ZIndex = 3; sub.Parent = self.Header
    end

    -- Botão minimizar (—)
    local minBtn = Instance.new("TextButton")
    minBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    minBtn.Position = UDim2.new(1, -self:S(40), 0.5, -self:S(11))
    minBtn.Size = UDim2.new(0, self:S(26), 0, self:S(22))
    minBtn.Font = Enum.Font.GothamBold; minBtn.Text = "—"
    minBtn.TextColor3 = self.Theme.TextMuted; minBtn.TextSize = self:S(13)
    minBtn.AutoButtonColor = false; minBtn.ZIndex = 3; minBtn.Parent = self.Header
    self:CreateCorner(minBtn, UDim.new(0, 5))
    minBtn.MouseEnter:Connect(function()
        self:Tween(minBtn, {BackgroundColor3 = self.Theme.Accent, TextColor3 = Color3.new(1,1,1)}, 0.15)
    end)
    minBtn.MouseLeave:Connect(function()
        self:Tween(minBtn, {BackgroundColor3 = Color3.fromRGB(30,30,30), TextColor3 = self.Theme.TextMuted}, 0.15)
    end)
    minBtn.MouseButton1Click:Connect(function() self.MainFrame.Visible = false end)

    -- ── SIDEBAR com scroll ─────────────────────────────────────────────────────
    local SW = self:S(58)
    self.Sidebar = Instance.new("ScrollingFrame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.BackgroundColor3 = self.Theme.Sidebar
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Position = UDim2.new(0, 0, 0, HH + 2)
    self.Sidebar.Size = UDim2.new(0, SW, 1, -(HH + 2))
    self.Sidebar.ScrollBarThickness = 0  -- escondido, mas funcional
    self.Sidebar.CanvasSize = UDim2.new(0,0,0,0)
    self.Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    self.Sidebar.Parent = self.MainFrame
    self:CreateCorner(self.Sidebar, UDim.new(0, 12))

    -- Cover canto superior
    local sbTopCov = Instance.new("Frame")
    sbTopCov.BackgroundColor3 = self.Theme.Sidebar; sbTopCov.BorderSizePixel = 0
    sbTopCov.Size = UDim2.new(1,0,0,12); sbTopCov.Parent = self.Sidebar

    -- Linha vermelha direita da sidebar
    local sbLine = Instance.new("Frame")
    sbLine.BackgroundColor3 = self.Theme.Border; sbLine.BorderSizePixel = 0
    sbLine.Position = UDim2.new(1,-1,0,0); sbLine.Size = UDim2.new(0,1,1,0)
    sbLine.Parent = self.Sidebar

    local sbLayout = Instance.new("UIListLayout")
    sbLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sbLayout.Padding = UDim.new(0, self:S(8))
    sbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sbLayout.Parent = self.Sidebar

    local sbPad = Instance.new("UIPadding")
    sbPad.PaddingTop = UDim.new(0, self:S(12))
    sbPad.PaddingBottom = UDim.new(0, self:S(12))
    sbPad.Parent = self.Sidebar

    -- Auto-resize canvas da sidebar conforme tabs são adicionadas
    sbLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Sidebar.CanvasSize = UDim2.new(0,0,0, sbLayout.AbsoluteContentSize.Y + self:S(24))
    end)

    -- ── CONTENT AREA ──────────────────────────────────────────────────────────
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name = "ContentArea"; self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Position = UDim2.new(0, SW + self:S(8), 0, HH + self:S(10))
    self.ContentArea.Size = UDim2.new(1, -(SW + self:S(16)), 1, -(HH + self:S(18)))
    self.ContentArea.Parent = self.MainFrame

    self.Tabs = {}; self.CurrentTab = nil

    self:MakeDraggable(self.MainFrame, self.Header)
    self:_CreateFloatingButton(config)

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            self:_CloseOnOutside(input.Position)
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
    local sz = self:S(50)
    self.FloatBtn = Instance.new("ImageButton")
    self.FloatBtn.Name = "FloatBtn"; self.FloatBtn.BackgroundColor3 = self.Theme.Accent
    self.FloatBtn.Position = UDim2.new(0, 18, 0.5, 0)
    self.FloatBtn.Size = UDim2.new(0, sz, 0, sz)
    self.FloatBtn.Image = ""; self.FloatBtn.AutoButtonColor = false
    self.FloatBtn.Parent = self.ScreenGui
    self:CreateCorner(self.FloatBtn, UDim.new(0, 14))
    self:CreateShadow(self.FloatBtn, 20)

    -- Brilho interno
    local glow = Instance.new("ImageLabel")
    glow.BackgroundTransparency = 1; glow.Size = UDim2.new(1,0,1,0)
    glow.Image = "rbxassetid://7072725342"
    glow.ImageTransparency = 0.6; glow.ZIndex = 2; glow.Parent = self.FloatBtn

    if config.IconAssetId and config.IconAssetId ~= "" then
        local img = Instance.new("ImageLabel"); img.BackgroundTransparency = 1
        img.Size = UDim2.new(0.55,0,0.55,0); img.Position = UDim2.new(0.225,0,0.225,0)
        img.Image = config.IconAssetId; img.ZIndex = 3; img.Parent = self.FloatBtn
    else
        local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1,0,1,0); lbl.Font = Enum.Font.GothamBlack
        lbl.Text = config.Icon or "S"; lbl.TextColor3 = Color3.new(1,1,1)
        lbl.TextSize = self:S(22); lbl.ZIndex = 3; lbl.Parent = self.FloatBtn
    end

    self.FloatBtn.MouseEnter:Connect(function()
        self:Tween(self.FloatBtn, {BackgroundColor3 = self.Theme.AccentHover}, 0.15)
    end)
    self.FloatBtn.MouseLeave:Connect(function()
        self:Tween(self.FloatBtn, {BackgroundColor3 = self.Theme.Accent}, 0.15)
    end)

    local fDrag, fDragInput, fDragStart, fStartPos
    self.FloatBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            fDrag = true; fDragStart = i.Position; fStartPos = self.FloatBtn.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then fDrag = false end
            end)
        end
    end)
    self.FloatBtn.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or
           i.UserInputType == Enum.UserInputType.Touch then fDragInput = i end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i == fDragInput and fDrag then
            local d = i.Position - fDragStart
            self.FloatBtn.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + d.X,
                                               fStartPos.Y.Scale, fStartPos.Y.Offset + d.Y)
        end
    end)
    self.FloatBtn.MouseButton1Click:Connect(function()
        if not fDrag then
            local visible = not self.MainFrame.Visible
            self.MainFrame.Visible = visible
            if visible then
                self.MainFrame.BackgroundTransparency = 1
                self:Tween(self.MainFrame, {BackgroundTransparency = 0}, 0.2)
            end
        end
    end)
end

-- ─── TAB ─────────────────────────────────────────────────────────────────────
function SpectrumX:CreateTab(config)
    config = config or {}
    local tabId   = config.Name or "Tab"
    local tabIcon = config.Icon or string.sub(tabId, 1, 1)
    local btnSz   = self:S(44)

    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabId .. "Tab"
    tabBtn.BackgroundColor3 = self.Theme.Card
    tabBtn.Size = UDim2.new(0, btnSz, 0, btnSz)
    tabBtn.Text = ""; tabBtn.AutoButtonColor = false
    tabBtn.Parent = self.Sidebar
    self:CreateCorner(tabBtn, UDim.new(0, 9))

    -- Indicador lateral esquerdo (vermelho quando ativo)
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.BackgroundColor3 = self.Theme.Accent
    indicator.BorderSizePixel = 0
    indicator.Position = UDim2.new(0, -4, 0.2, 0)
    indicator.Size = UDim2.new(0, 3, 0.6, 0)
    indicator.Visible = false; indicator.Parent = tabBtn
    self:CreateCorner(indicator, UDim.new(1, 0))

    if config.IconAssetId and config.IconAssetId ~= "" then
        local img = Instance.new("ImageLabel"); img.Name = "Icon"
        img.BackgroundTransparency = 1
        img.Position = UDim2.new(0.5, -10, 0.5, -10)
        img.Size = UDim2.new(0, 20, 0, 20)
        img.Image = config.IconAssetId; img.Parent = tabBtn
        Instance.new("UIAspectRatioConstraint").Parent = img
    else
        local ico = Instance.new("TextLabel"); ico.Name = "Icon"
        ico.BackgroundTransparency = 1; ico.Size = UDim2.new(1,0,1,0)
        ico.Font = Enum.Font.GothamBold; ico.Text = tabIcon
        ico.TextColor3 = self.Theme.TextMuted; ico.TextSize = self:S(16)
        ico.Parent = tabBtn
    end

    -- Tooltip (nome da aba ao hover)
    local tooltip = Instance.new("TextLabel")
    tooltip.BackgroundColor3 = Color3.fromRGB(18,18,18)
    tooltip.BorderSizePixel = 0
    tooltip.Position = UDim2.new(1, self:S(8), 0.5, -self:S(10))
    tooltip.Size = UDim2.new(0, 0, 0, self:S(20))
    tooltip.AutomaticSize = Enum.AutomaticSize.X
    tooltip.Font = Enum.Font.GothamSemibold; tooltip.Text = "  " .. tabId .. "  "
    tooltip.TextColor3 = self.Theme.Text; tooltip.TextSize = self:S(11)
    tooltip.Visible = false; tooltip.ZIndex = 9999; tooltip.Parent = tabBtn
    self:CreateCorner(tooltip, UDim.new(0, 4))
    self:CreateStroke(tooltip, self.Theme.Border, 1, 0.3)

    tabBtn.MouseEnter:Connect(function()
        if self.CurrentTab ~= tabId then
            self:Tween(tabBtn, {BackgroundColor3 = self.Theme.CardHover}, 0.15)
        end
        tooltip.Visible = true
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabId then
            self:Tween(tabBtn, {BackgroundColor3 = self.Theme.Card}, 0.15)
        end
        tooltip.Visible = false
    end)

    -- Page container
    local page = Instance.new("Frame")
    page.Name = tabId .. "Page"; page.BackgroundTransparency = 1
    page.Size = UDim2.new(1,0,1,0); page.Visible = false
    page.Parent = self.ContentArea

    -- Divisor central
    local div = Instance.new("Frame")
    div.BackgroundColor3 = self.Theme.Border; div.BorderSizePixel = 0
    div.Position = UDim2.new(0.5,-1,0,0); div.Size = UDim2.new(0,1,1,0); div.Parent = page

    local function makeSide(pos, sz, name)
        local sf = Instance.new("ScrollingFrame")
        sf.Name = name; sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0
        sf.Position = pos; sf.Size = sz
        sf.ScrollBarThickness = 3
        sf.ScrollBarImageColor3 = self.Theme.Accent
        sf.CanvasSize = UDim2.new(0,0,0,0); sf.Parent = page
        local lay = Instance.new("UIListLayout")
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        lay.Padding = UDim.new(0, self:S(6)); lay.Parent = sf
        local pad = Instance.new("UIPadding")
        pad.PaddingBottom = UDim.new(0, self:S(8)); pad.Parent = sf
        lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sf.CanvasSize = UDim2.new(0,0,0, lay.AbsoluteContentSize.Y + self:S(16))
        end)
        return sf
    end

    local left  = makeSide(UDim2.new(0,0,0,0),        UDim2.new(0.49,0,1,0), "Left")
    local right = makeSide(UDim2.new(0.51,0,0,0),     UDim2.new(0.49,0,1,0), "Right")

    local tabData = {Button = tabBtn, Container = page, Left = left, Right = right}
    self.Tabs[tabId] = tabData

    tabBtn.MouseButton1Click:Connect(function() self:SelectTab(tabId) end)
    if not self.CurrentTab then self:SelectTab(tabId) end

    return tabData
end

function SpectrumX:SelectTab(tabId)
    for id, data in pairs(self.Tabs) do
        local ico = data.Button:FindFirstChild("Icon")
        local ind = data.Button:FindFirstChild("Indicator")
        if id == tabId then
            data.Container.Visible = true
            self:Tween(data.Button, {BackgroundColor3 = self.Theme.Accent}, 0.2)
            if ico then
                if ico:IsA("TextLabel") then self:Tween(ico, {TextColor3 = Color3.new(1,1,1)}, 0.2) end
                if ico:IsA("ImageLabel") then self:Tween(ico, {ImageColor3 = Color3.new(1,1,1)}, 0.2) end
            end
            if ind then ind.Visible = true end
        else
            data.Container.Visible = false
            self:Tween(data.Button, {BackgroundColor3 = self.Theme.Card}, 0.2)
            if ico then
                if ico:IsA("TextLabel") then self:Tween(ico, {TextColor3 = self.Theme.TextMuted}, 0.2) end
                if ico:IsA("ImageLabel") then self:Tween(ico, {ImageColor3 = self.Theme.TextMuted}, 0.2) end
            end
            if ind then ind.Visible = false end
        end
    end
    self.CurrentTab = tabId
end

-- ─── SECTION ──────────────────────────────────────────────────────────────────
function SpectrumX:CreateSection(parent, text, color)
    local wrap = Instance.new("Frame")
    wrap.BackgroundTransparency = 1; wrap.Size = UDim2.new(1,0,0, self:S(24))
    wrap.Parent = parent

    -- Linha vermelha + texto
    local line = Instance.new("Frame")
    line.BackgroundColor3 = color or self.Theme.Accent; line.BorderSizePixel = 0
    line.Position = UDim2.new(0,0,0.5,0); line.Size = UDim2.new(1,0,0,1); line.Parent = wrap

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundColor3 = self.Theme.Background; lbl.BorderSizePixel = 0
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Position = UDim2.new(0, self:S(4), 0, 0); lbl.Size = UDim2.new(0,0,1,0)
    lbl.Font = Enum.Font.GothamBold; lbl.Text = "  " .. text .. "  "
    lbl.TextColor3 = color or self.Theme.Accent; lbl.TextSize = self:S(11)
    lbl.ZIndex = 2; lbl.Parent = wrap
    return wrap
end

-- ─── TOGGLE ── premium ────────────────────────────────────────────────────────
function SpectrumX:CreateToggle(parent, config)
    config = config or {}
    local text     = config.Text     or "Toggle"
    local default  = config.Default  or false
    local callback = config.Callback or function() end

    local H = self:S(44)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card; frame.Size = UDim2.new(1,0,0,H)
    frame.Parent = parent; self:CreateCorner(frame, UDim.new(0, 8))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.6)

    -- Hover effect
    local hoverFill = Instance.new("Frame")
    hoverFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
    hoverFill.BackgroundTransparency = 1; hoverFill.BorderSizePixel = 0
    hoverFill.Size = UDim2.new(1,0,1,0); hoverFill.Parent = frame
    self:CreateCorner(hoverFill, UDim.new(0, 8))

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, self:S(12), 0, 0)
    lbl.Size = UDim2.new(0.65, 0, 1, 0); lbl.Font = Enum.Font.GothamSemibold
    lbl.Text = text; lbl.TextColor3 = self.Theme.Text; lbl.TextSize = self:S(13)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frame

    -- Track
    local trackW, trackH = self:S(44), self:S(22)
    local track = Instance.new("TextButton")
    track.AutoButtonColor = false
    track.BackgroundColor3 = default and self.Theme.ToggleOn or self.Theme.ToggleOff
    track.Position = UDim2.new(1, -trackW - self:S(12), 0.5, -trackH/2)
    track.Size = UDim2.new(0, trackW, 0, trackH)
    track.Text = ""; track.ZIndex = 2; track.Parent = frame
    self:CreateCorner(track, UDim.new(1,0))
    self:CreateStroke(track, default and self.Theme.Accent or self.Theme.Border, 1,
        default and 0.2 or 0.5)

    local trackStroke = track:FindFirstChildOfClass("UIStroke")

    -- Glow no track quando ativo
    local trackGlow = Instance.new("ImageLabel")
    trackGlow.BackgroundTransparency = 1; trackGlow.Size = UDim2.new(1,20,1,20)
    trackGlow.Position = UDim2.new(0,-10,0,-10); trackGlow.Image = "rbxassetid://7072725342"
    trackGlow.ImageColor3 = self.Theme.Accent
    trackGlow.ImageTransparency = default and 0.7 or 1
    trackGlow.ZIndex = 1; trackGlow.Parent = track

    -- Knob
    local kSz = self:S(16)
    local knob = Instance.new("Frame")
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Position = default and UDim2.new(1,-kSz-self:S(3),0.5,-kSz/2)
                             or UDim2.new(0,self:S(3),0.5,-kSz/2)
    knob.Size = UDim2.new(0,kSz,0,kSz); knob.ZIndex = 3; knob.Parent = track
    self:CreateCorner(knob, UDim.new(1,0))
    self:CreateShadow(knob, 8)

    local state = default

    local function update(s, animated)
        local t = animated == false and 0 or 0.2
        if s then
            self:Tween(track, {BackgroundColor3 = self.Theme.ToggleOn}, t)
            self:Tween(trackStroke, {Color = self.Theme.Accent, Transparency = 0.2}, t)
            self:Tween(trackGlow, {ImageTransparency = 0.7}, t)
            self:Tween(knob, {Position = UDim2.new(1,-kSz-self:S(3),0.5,-kSz/2)}, t,
                Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            self:Tween(track, {BackgroundColor3 = self.Theme.ToggleOff}, t)
            self:Tween(trackStroke, {Color = self.Theme.Border, Transparency = 0.5}, t)
            self:Tween(trackGlow, {ImageTransparency = 1}, t)
            self:Tween(knob, {Position = UDim2.new(0,self:S(3),0.5,-kSz/2)}, t,
                Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end

    track.MouseButton1Click:Connect(function()
        state = not state; callback(state); update(state)
    end)

    -- Hover
    frame.MouseEnter:Connect(function()
        self:Tween(hoverFill, {BackgroundTransparency = 0.97}, 0.15)
    end)
    frame.MouseLeave:Connect(function()
        self:Tween(hoverFill, {BackgroundTransparency = 1}, 0.15)
    end)

    return {
        Frame    = frame,
        GetState = function() return state end,
        SetState = function(s) state = s; callback(state); update(state) end,
    }
end

-- ─── BUTTON ── premium ────────────────────────────────────────────────────────
function SpectrumX:CreateButton(parent, config)
    config = config or {}
    local text     = config.Text     or "Button"
    local style    = config.Style    or "default"
    local callback = config.Callback or function() end

    local H = self:S(38)
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1; frame.Size = UDim2.new(1,0,0,H)
    frame.Parent = parent

    local btn = Instance.new("TextButton")
    btn.Name = "Button"; btn.AutoButtonColor = false
    btn.Size = UDim2.new(1,0,1,0); btn.Font = Enum.Font.GothamBold
    btn.Text = text; btn.TextSize = self:S(13)
    btn.Parent = frame; self:CreateCorner(btn, UDim.new(0, 8))

    local color, textColor
    if style == "accent" then
        btn.BackgroundColor3 = self.Theme.Accent; textColor = Color3.new(1,1,1)
        color = self.Theme.Accent
    elseif style == "warning" then
        btn.BackgroundColor3 = Color3.fromRGB(30,20,0); textColor = self.Theme.Warning
        color = self.Theme.Warning
    elseif style == "info" then
        btn.BackgroundColor3 = Color3.fromRGB(10,18,30); textColor = self.Theme.Info
        color = self.Theme.Info
    else -- default/outline
        btn.BackgroundColor3 = self.Theme.Card; textColor = self.Theme.Text
        color = self.Theme.Border
    end
    btn.TextColor3 = textColor

    local stroke = self:CreateStroke(btn, color, 1.2, style == "accent" and 1 or 0.4)

    if style == "accent" then
        -- Gradiente no botão accent
        makeGradient(btn, self.Theme.Accent, self.Theme.AccentDark, 90)
    end

    -- Ripple container
    local rippleHolder = Instance.new("Frame")
    rippleHolder.BackgroundTransparency = 1; rippleHolder.BorderSizePixel = 0
    rippleHolder.Size = UDim2.new(1,0,1,0); rippleHolder.ClipsDescendants = true
    rippleHolder.ZIndex = btn.ZIndex + 1; rippleHolder.Parent = btn
    self:CreateCorner(rippleHolder, UDim.new(0, 8))

    btn.MouseEnter:Connect(function()
        if style == "accent" then
            self:Tween(btn, {BackgroundColor3 = self.Theme.AccentHover}, 0.15)
        else
            self:Tween(btn, {BackgroundColor3 = self.Theme.CardHover}, 0.15)
            self:Tween(stroke, {Transparency = 0.1}, 0.15)
        end
    end)
    btn.MouseLeave:Connect(function()
        if style == "accent" then
            self:Tween(btn, {BackgroundColor3 = self.Theme.Accent}, 0.15)
        else
            self:Tween(btn, {BackgroundColor3 = self.Theme.Card}, 0.15)
            self:Tween(stroke, {Transparency = style == "accent" and 1 or 0.4}, 0.15)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        -- Ripple effect
        local ripple = Instance.new("Frame")
        ripple.BackgroundColor3 = Color3.new(1,1,1)
        ripple.BackgroundTransparency = 0.85
        ripple.BorderSizePixel = 0
        local mpos = UserInputService:GetMouseLocation()
        local relX = mpos.X - btn.AbsolutePosition.X
        local relY = mpos.Y - btn.AbsolutePosition.Y
        ripple.Position = UDim2.new(0, relX - 2, 0, relY - 2)
        ripple.Size = UDim2.new(0, 4, 0, 4)
        ripple.ZIndex = btn.ZIndex + 2; ripple.Parent = rippleHolder
        self:CreateCorner(ripple, UDim.new(1,0))
        local maxSz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.5
        self:Tween(ripple, {
            Size = UDim2.new(0, maxSz, 0, maxSz),
            Position = UDim2.new(0, relX - maxSz/2, 0, relY - maxSz/2),
            BackgroundTransparency = 1
        }, 0.5)
        task.delay(0.5, function() ripple:Destroy() end)
        callback()
    end)

    return {Frame = frame, Button = btn, SetText = function(t) btn.Text = t end}
end

-- ─── INPUT ────────────────────────────────────────────────────────────────────
function SpectrumX:CreateInput(parent, config)
    config = config or {}
    local labelText   = config.Label       or "Input"
    local default     = config.Default     or ""
    local placeholder = config.Placeholder or "Digite aqui..."
    local callback    = config.Callback    or function() end

    local H = self:S(58)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card; frame.Size = UDim2.new(1,0,0,H)
    frame.Parent = parent; self:CreateCorner(frame, UDim.new(0, 8))
    local stroke = self:CreateStroke(frame, self.Theme.Border, 1, 0.4)

    local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, self:S(12), 0, self:S(8))
    lbl.Size = UDim2.new(1, -self:S(24), 0, self:S(16))
    lbl.Font = Enum.Font.GothamSemibold; lbl.Text = labelText
    lbl.TextColor3 = self.Theme.TextMuted; lbl.TextSize = self:S(10)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frame

    local box = Instance.new("TextBox")
    box.BackgroundColor3 = self.Theme.Input
    box.Position = UDim2.new(0, self:S(10), 0, self:S(26))
    box.Size = UDim2.new(1, -self:S(20), 0, self:S(24))
    box.Font = Enum.Font.Gotham; box.Text = tostring(default)
    box.PlaceholderText = placeholder; box.PlaceholderColor3 = self.Theme.TextMuted
    box.TextColor3 = self.Theme.Text; box.TextSize = self:S(13)
    box.ClearTextOnFocus = false; box.Parent = frame
    self:CreateCorner(box, UDim.new(0, 6))

    box.Focused:Connect(function()
        self:Tween(stroke, {Color = self.Theme.Accent, Transparency = 0.1}, 0.2)
        self:Tween(lbl, {TextColor3 = self.Theme.Accent}, 0.2)
    end)
    box.FocusLost:Connect(function()
        self:Tween(stroke, {Color = self.Theme.Border, Transparency = 0.4}, 0.2)
        self:Tween(lbl, {TextColor3 = self.Theme.TextMuted}, 0.2)
        callback(box.Text)
    end)

    return {
        Frame = frame, TextBox = box,
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

    local H = self:S(58)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card; frame.Size = UDim2.new(1,0,0,H)
    frame.Parent = parent; self:CreateCorner(frame, UDim.new(0, 8))
    local stroke = self:CreateStroke(frame, self.Theme.Border, 1, 0.4)

    local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, self:S(12), 0, self:S(8))
    lbl.Size = UDim2.new(1, -self:S(24), 0, self:S(16))
    lbl.Font = Enum.Font.GothamSemibold; lbl.Text = labelText
    lbl.TextColor3 = self.Theme.TextMuted; lbl.TextSize = self:S(10)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frame

    local box = Instance.new("TextBox")
    box.BackgroundColor3 = self.Theme.Input
    box.Position = UDim2.new(0, self:S(10), 0, self:S(26))
    box.Size = UDim2.new(1, -self:S(20), 0, self:S(24))
    box.Font = Enum.Font.GothamBold; box.Text = tostring(default)
    box.TextColor3 = self.Theme.Text; box.TextSize = self:S(13)
    box.ClearTextOnFocus = false; box.Parent = frame
    self:CreateCorner(box, UDim.new(0, 6))

    box.Focused:Connect(function()
        self:Tween(stroke, {Color = self.Theme.Accent, Transparency = 0.1}, 0.2)
        self:Tween(lbl, {TextColor3 = self.Theme.Accent}, 0.2)
    end)
    box.FocusLost:Connect(function()
        self:Tween(stroke, {Color = self.Theme.Border, Transparency = 0.4}, 0.2)
        self:Tween(lbl, {TextColor3 = self.Theme.TextMuted}, 0.2)
        local v = tonumber(box.Text)
        if v then
            v = math.clamp(v, min, max); box.Text = tostring(v); callback(v)
        else
            box.Text = tostring(default)
        end
    end)

    return {
        Frame = frame, TextBox = box,
        GetValue = function() return tonumber(box.Text) end,
        SetValue = function(v) box.Text = tostring(math.clamp(v, min, max)) end,
    }
end

-- ─── SLIDER ── premium ────────────────────────────────────────────────────────
function SpectrumX:CreateSlider(parent, config)
    config = config or {}
    local text     = config.Text     or "Slider"
    local min      = config.Min      or 0
    local max      = config.Max      or 100
    local default  = config.Default  or min
    local callback = config.Callback or function() end

    local H = self:S(58)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card; frame.Size = UDim2.new(1,0,0,H)
    frame.Parent = parent; self:CreateCorner(frame, UDim.new(0, 8))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.4)

    local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, self:S(12), 0, self:S(10))
    lbl.Size = UDim2.new(0.6,0,0,self:S(16))
    lbl.Font = Enum.Font.GothamSemibold; lbl.Text = text
    lbl.TextColor3 = self.Theme.Text; lbl.TextSize = self:S(12)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frame

    local valBg = Instance.new("Frame")
    valBg.BackgroundColor3 = self.Theme.Accent
    valBg.Position = UDim2.new(1, -self:S(38), 0, self:S(8))
    valBg.Size = UDim2.new(0, self:S(34), 0, self:S(20))
    valBg.Parent = frame; self:CreateCorner(valBg, UDim.new(0, 5))

    local valLbl = Instance.new("TextLabel"); valLbl.BackgroundTransparency = 1
    valLbl.Size = UDim2.new(1,0,1,0); valLbl.Font = Enum.Font.GothamBold
    valLbl.Text = tostring(default); valLbl.TextColor3 = Color3.new(1,1,1)
    valLbl.TextSize = self:S(11); valLbl.Parent = valBg

    -- Track
    local trackH = self:S(6)
    local trackBg = Instance.new("Frame")
    trackBg.BackgroundColor3 = self.Theme.Input
    trackBg.Position = UDim2.new(0, self:S(12), 1, -self:S(18))
    trackBg.Size = UDim2.new(1, -self:S(24), 0, trackH)
    trackBg.Parent = frame; self:CreateCorner(trackBg, UDim.new(1,0))

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = self.Theme.Accent
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.Parent = trackBg; self:CreateCorner(fill, UDim.new(1,0))
    makeGradient(fill, self.Theme.Accent, self.Theme.AccentDark, 0)

    local kSz = self:S(14)
    local knob = Instance.new("Frame")
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Position = UDim2.new((default-min)/(max-min), -kSz/2, 0.5, -kSz/2)
    knob.Size = UDim2.new(0,kSz,0,kSz); knob.ZIndex = 2; knob.Parent = trackBg
    self:CreateCorner(knob, UDim.new(1,0))
    self:CreateStroke(knob, self.Theme.Accent, 2, 0)
    self:CreateShadow(knob, 10)

    local drag = false; local cur = default

    local function upd(i)
        local p = math.clamp((i.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
        local v = math.floor((min + (max-min)*p) * 100) / 100
        cur = v; fill.Size = UDim2.new(p,0,1,0)
        knob.Position = UDim2.new(p,-kSz/2,0.5,-kSz/2)
        valLbl.Text = tostring(v); callback(v)
    end

    trackBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then drag=true; upd(i) end
    end)
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then drag=true end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or
           i.UserInputType == Enum.UserInputType.Touch) then upd(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)

    return {
        Frame = frame,
        GetValue = function() return cur end,
        SetValue = function(v)
            v = math.clamp(v, min, max); cur = v
            local p = (v-min)/(max-min)
            fill.Size = UDim2.new(p,0,1,0)
            knob.Position = UDim2.new(p,-kSz/2,0.5,-kSz/2)
            valLbl.Text = tostring(v)
        end,
    }
end

-- ─── HELPER DROPDOWN: posição ─────────────────────────────────────────────────
local function dropPos(btn, layout, maxH)
    local ap, as = btn.AbsolutePosition, btn.AbsoluteSize
    local cH = layout.AbsoluteContentSize.Y + 12
    local tH = math.min(cH, maxH)
    local ok, cam = pcall(function() return workspace.CurrentCamera end)
    local sH = (ok and cam) and cam.ViewportSize.Y or 768
    local tY = ap.Y + as.Y + 4
    if tY + tH > sH then tY = ap.Y - tH - 4 end
    return UDim2.fromOffset(ap.X, tY), tH, cH
end

-- ─── DROPDOWN ── premium ──────────────────────────────────────────────────────
function SpectrumX:CreateDropdown(parent, config)
    config = config or {}
    local labelText = config.Label    or "Dropdown"
    local options   = config.Options  or {}
    local default   = config.Default
    local callback  = config.Callback or function() end

    local H = self:S(58)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card; frame.Size = UDim2.new(1,0,0,H)
    frame.ClipsDescendants = false; frame.Parent = parent
    self:CreateCorner(frame, UDim.new(0,8)); self:CreateStroke(frame, self.Theme.Border, 1, 0.4)

    local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, self:S(12), 0, self:S(8))
    lbl.Size = UDim2.new(1,-self:S(24),0,self:S(14))
    lbl.Font = Enum.Font.GothamSemibold; lbl.Text = labelText
    lbl.TextColor3 = self.Theme.TextMuted; lbl.TextSize = self:S(10)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frame

    local dropBtn = Instance.new("TextButton")
    dropBtn.BackgroundColor3 = self.Theme.Input; dropBtn.AutoButtonColor = false
    dropBtn.Position = UDim2.new(0, self:S(10), 0, self:S(24))
    dropBtn.Size = UDim2.new(1, -self:S(20), 0, self:S(26))
    dropBtn.Font = Enum.Font.GothamSemibold
    dropBtn.Text = "  " .. (default or "Selecionar...")
    dropBtn.TextColor3 = default and self.Theme.Text or self.Theme.TextMuted
    dropBtn.TextSize = self:S(12); dropBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropBtn.ZIndex = 2; dropBtn.Parent = frame
    self:CreateCorner(dropBtn, UDim.new(0,6))
    local dropStroke = self:CreateStroke(dropBtn, self.Theme.Border, 1, 0.4)

    local arrow = Instance.new("TextLabel"); arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(1,-self:S(26),0,0); arrow.Size = UDim2.new(0,self:S(24),1,0)
    arrow.Font = Enum.Font.GothamBold; arrow.Text = "▾"
    arrow.TextColor3 = self.Theme.Accent; arrow.TextSize = self:S(14)
    arrow.ZIndex = 3; arrow.Parent = dropBtn

    local dropList = Instance.new("ScrollingFrame")
    dropList.Name = "DropList_" .. labelText .. "_" .. tostring(tick())
    dropList.BackgroundColor3 = self.Theme.Card
    dropList.Size = UDim2.new(0,0,0,0); dropList.ScrollBarThickness = 3
    dropList.ScrollBarImageColor3 = self.Theme.Accent
    dropList.Visible = false; dropList.ZIndex = 5000; dropList.BorderSizePixel = 0
    dropList.Parent = self.ScreenGui
    self:CreateCorner(dropList, UDim.new(0,8))
    self:CreateStroke(dropList, self.Theme.Accent, 1.5, 0.2)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, self:S(3)); listLayout.Parent = dropList

    local lPad = Instance.new("UIPadding")
    lPad.PaddingTop = UDim.new(0,5); lPad.PaddingBottom = UDim.new(0,5)
    lPad.PaddingLeft = UDim.new(0,5); lPad.PaddingRight = UDim.new(0,5)
    lPad.Parent = dropList

    local selected = default; local isOpen = false; local maxH = self:S(180)

    local function closeDD()
        if not isOpen then return end
        isOpen = false
        self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)}, 0.2)
        self:Tween(arrow, {Rotation = 0}, 0.2)
        self:Tween(dropStroke, {Color = self.Theme.Border, Transparency = 0.4}, 0.2)
        task.wait(0.2); dropList.Visible = false
    end

    self:_RegisterDropdown(dropList, dropBtn, closeDD)

    local function populate()
        for _, ch in ipairs(dropList:GetChildren()) do
            if ch:IsA("Frame") then ch:Destroy() end
        end
        for _, opt in ipairs(options) do
            local isSel = opt == selected
            local row = Instance.new("Frame")
            row.BackgroundColor3 = isSel and Color3.fromRGB(35,8,8) or self.Theme.Input
            row.Size = UDim2.new(1,0,0,self:S(28)); row.ZIndex = 5001; row.Parent = dropList
            self:CreateCorner(row, UDim.new(0,5))
            if isSel then self:CreateStroke(row, self.Theme.Accent, 1, 0.2) end

            -- Dot indicator
            if isSel then
                local dot = Instance.new("Frame")
                dot.BackgroundColor3 = self.Theme.Accent
                dot.Position = UDim2.new(0,self:S(6),0.5,-self:S(3))
                dot.Size = UDim2.new(0,self:S(6),0,self:S(6))
                dot.ZIndex = 5002; dot.Parent = row
                self:CreateCorner(dot, UDim.new(1,0))
            end

            local rowBtn = Instance.new("TextButton"); rowBtn.BackgroundTransparency = 1
            rowBtn.Size = UDim2.new(1,0,1,0); rowBtn.Font = Enum.Font.GothamSemibold
            rowBtn.Text = (isSel and "   " or "  ") .. opt
            rowBtn.TextColor3 = isSel and self.Theme.AccentSecondary or self.Theme.TextSecondary
            rowBtn.TextSize = self:S(12); rowBtn.TextXAlignment = Enum.TextXAlignment.Left
            rowBtn.ZIndex = 5002; rowBtn.Parent = row
            local rPad = Instance.new("UIPadding"); rPad.PaddingLeft = UDim.new(0,self:S(10)); rPad.Parent = rowBtn

            rowBtn.MouseButton1Click:Connect(function()
                selected = opt; dropBtn.Text = "  " .. opt
                dropBtn.TextColor3 = self.Theme.Text; callback(opt); closeDD()
            end)
            rowBtn.MouseEnter:Connect(function()
                if not isSel then self:Tween(row, {BackgroundColor3 = self.Theme.CardHover}, 0.1) end
            end)
            rowBtn.MouseLeave:Connect(function()
                if not isSel then self:Tween(row, {BackgroundColor3 = self.Theme.Input}, 0.1) end
            end)
        end
    end

    dropBtn.MouseEnter:Connect(function()
        self:Tween(dropBtn, {BackgroundColor3 = self.Theme.InputHover}, 0.15)
    end)
    dropBtn.MouseLeave:Connect(function()
        self:Tween(dropBtn, {BackgroundColor3 = self.Theme.Input}, 0.15)
    end)

    dropBtn.MouseButton1Click:Connect(function()
        if isOpen then closeDD(); return end
        for _, dd in ipairs(self.Dropdowns) do if dd ~= dropList then dd.Visible = false end end
        populate()
        local pos, tH, cH = dropPos(dropBtn, listLayout, maxH)
        dropList.Position = pos; dropList.Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)
        dropList.CanvasSize = UDim2.new(0,0,0,cH); dropList.Visible = true
        self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, tH)}, 0.25,
            Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        self:Tween(arrow, {Rotation = 180}, 0.2)
        self:Tween(dropStroke, {Color = self.Theme.Accent, Transparency = 0.2}, 0.2)
        isOpen = true
    end)

    return {
        Frame      = frame,
        GetValue   = function() return selected end,
        SetValue   = function(v) selected=v; dropBtn.Text="  "..(v or "Selecionar...") end,
        SetOptions = function(o) options=o; if isOpen then populate() end end,
    }
end

-- ─── MULTI DROPDOWN ──────────────────────────────────────────────────────────
function SpectrumX:CreateMultiDropdown(parent, config)
    config = config or {}
    local labelText = config.Label    or "Multi Select"
    local options   = config.Options  or {}
    local default   = config.Default  or {}
    local callback  = config.Callback or function() end

    local H = self:S(58)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card; frame.Size = UDim2.new(1,0,0,H)
    frame.ClipsDescendants = false; frame.Parent = parent
    self:CreateCorner(frame, UDim.new(0,8)); self:CreateStroke(frame, self.Theme.Border, 1, 0.4)

    local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0,self:S(12),0,self:S(8))
    lbl.Size = UDim2.new(1,-self:S(24),0,self:S(14))
    lbl.Font = Enum.Font.GothamSemibold; lbl.Text = labelText
    lbl.TextColor3 = self.Theme.TextMuted; lbl.TextSize = self:S(10)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frame

    local dropBtn = Instance.new("TextButton")
    dropBtn.BackgroundColor3 = self.Theme.Input; dropBtn.AutoButtonColor = false
    dropBtn.Position = UDim2.new(0,self:S(10),0,self:S(24))
    dropBtn.Size = UDim2.new(1,-self:S(20),0,self:S(26))
    dropBtn.Font = Enum.Font.GothamSemibold; dropBtn.Text = "  Selecionar..."
    dropBtn.TextColor3 = self.Theme.TextMuted; dropBtn.TextSize = self:S(12)
    dropBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropBtn.ZIndex = 2; dropBtn.Parent = frame
    self:CreateCorner(dropBtn, UDim.new(0,6))
    local dropStroke = self:CreateStroke(dropBtn, self.Theme.Border, 1, 0.4)

    local arrow = Instance.new("TextLabel"); arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(1,-self:S(26),0,0); arrow.Size = UDim2.new(0,self:S(24),1,0)
    arrow.Font = Enum.Font.GothamBold; arrow.Text = "▾"
    arrow.TextColor3 = self.Theme.Accent; arrow.TextSize = self:S(14)
    arrow.ZIndex = 3; arrow.Parent = dropBtn

    local dropList = Instance.new("ScrollingFrame")
    dropList.Name = "MultiDropList_" .. labelText .. "_" .. tostring(tick())
    dropList.BackgroundColor3 = self.Theme.Card
    dropList.Size = UDim2.new(0,0,0,0); dropList.ScrollBarThickness = 3
    dropList.ScrollBarImageColor3 = self.Theme.Accent
    dropList.Visible = false; dropList.ZIndex = 5000; dropList.BorderSizePixel = 0
    dropList.Parent = self.ScreenGui
    self:CreateCorner(dropList, UDim.new(0,8))
    self:CreateStroke(dropList, self.Theme.Accent, 1.5, 0.2)

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0,self:S(3)); listLayout.Parent = dropList

    local lPad = Instance.new("UIPadding")
    lPad.PaddingTop = UDim.new(0,5); lPad.PaddingBottom = UDim.new(0,5)
    lPad.PaddingLeft = UDim.new(0,5); lPad.PaddingRight = UDim.new(0,5)
    lPad.Parent = dropList

    local selected = {}
    for _, v in ipairs(default) do table.insert(selected, v) end
    local isOpen = false; local maxH = self:S(180)

    local function updText()
        if #selected == 0 then
            dropBtn.Text = "  Selecionar..."; dropBtn.TextColor3 = self.Theme.TextMuted
        elseif #selected == 1 then
            dropBtn.Text = "  " .. selected[1]; dropBtn.TextColor3 = self.Theme.Text
        else
            dropBtn.Text = "  " .. #selected .. " selecionados"; dropBtn.TextColor3 = self.Theme.Text
        end
    end

    local function closeMulti()
        if not isOpen then return end
        isOpen = false
        self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)}, 0.2)
        self:Tween(arrow, {Rotation = 0}, 0.2)
        self:Tween(dropStroke, {Color = self.Theme.Border, Transparency = 0.4}, 0.2)
        task.wait(0.2); dropList.Visible = false
    end

    self:_RegisterDropdown(dropList, dropBtn, closeMulti)

    local function getPrio(n)
        for i,v in ipairs(selected) do if v==n then return i end end
    end
    local function toggle(n)
        for i,v in ipairs(selected) do
            if v==n then table.remove(selected,i); return end
        end
        table.insert(selected, n)
    end

    local function populate()
        for _, ch in ipairs(dropList:GetChildren()) do
            if ch:IsA("Frame") then ch:Destroy() end
        end
        for _, opt in ipairs(options) do
            local p = getPrio(opt); local isSel = p ~= nil
            local row = Instance.new("Frame")
            row.BackgroundColor3 = isSel and Color3.fromRGB(35,8,8) or self.Theme.Input
            row.Size = UDim2.new(1,0,0,self:S(28)); row.ZIndex = 5001; row.Parent = dropList
            self:CreateCorner(row, UDim.new(0,5))
            if isSel then self:CreateStroke(row, self.Theme.Accent, 1, 0.2) end

            -- Número de prioridade
            if isSel then
                local prioLbl = Instance.new("TextLabel")
                prioLbl.BackgroundColor3 = self.Theme.Accent
                prioLbl.Position = UDim2.new(0,self:S(4),0.5,-self:S(8))
                prioLbl.Size = UDim2.new(0,self:S(16),0,self:S(16))
                prioLbl.Font = Enum.Font.GothamBold; prioLbl.Text = tostring(p)
                prioLbl.TextColor3 = Color3.new(1,1,1); prioLbl.TextSize = self:S(9)
                prioLbl.ZIndex = 5002; prioLbl.Parent = row
                self:CreateCorner(prioLbl, UDim.new(1,0))
            end

            local rowBtn = Instance.new("TextButton"); rowBtn.BackgroundTransparency = 1
            rowBtn.Size = UDim2.new(1,0,1,0); rowBtn.Font = Enum.Font.GothamSemibold
            rowBtn.Text = (isSel and "      " or "  ") .. opt
            rowBtn.TextColor3 = isSel and self.Theme.AccentSecondary or self.Theme.TextSecondary
            rowBtn.TextSize = self:S(12); rowBtn.TextXAlignment = Enum.TextXAlignment.Left
            rowBtn.ZIndex = 5002; rowBtn.Parent = row
            local rPad = Instance.new("UIPadding"); rPad.PaddingLeft = UDim.new(0,self:S(10)); rPad.Parent = rowBtn

            rowBtn.MouseButton1Click:Connect(function()
                toggle(opt); callback(selected); updText(); populate()
            end)
            rowBtn.MouseEnter:Connect(function()
                if not isSel then self:Tween(row, {BackgroundColor3 = self.Theme.CardHover}, 0.1) end
            end)
            rowBtn.MouseLeave:Connect(function()
                if not isSel then self:Tween(row, {BackgroundColor3 = self.Theme.Input}, 0.1) end
            end)
        end
    end

    dropBtn.MouseEnter:Connect(function()
        self:Tween(dropBtn, {BackgroundColor3 = self.Theme.InputHover}, 0.15)
    end)
    dropBtn.MouseLeave:Connect(function()
        self:Tween(dropBtn, {BackgroundColor3 = self.Theme.Input}, 0.15)
    end)

    dropBtn.MouseButton1Click:Connect(function()
        if isOpen then closeMulti(); return end
        for _, dd in ipairs(self.Dropdowns) do if dd ~= dropList then dd.Visible = false end end
        populate()
        local pos, tH, cH = dropPos(dropBtn, listLayout, maxH)
        dropList.Position = pos; dropList.Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)
        dropList.CanvasSize = UDim2.new(0,0,0,cH); dropList.Visible = true
        self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, tH)}, 0.25,
            Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        self:Tween(arrow, {Rotation = 180}, 0.2)
        self:Tween(dropStroke, {Color = self.Theme.Accent, Transparency = 0.2}, 0.2)
        isOpen = true
    end)

    updText()

    return {
        Frame      = frame,
        GetValues  = function() return selected end,
        SetValues  = function(v) selected=v; updText() end,
        SetOptions = function(o) options=o; if isOpen then populate() end end,
    }
end

-- ─── CHECKBOX ─────────────────────────────────────────────────────────────────
function SpectrumX:CreateCheckbox(parent, config)
    config = config or {}
    local text     = config.Text     or "Checkbox"
    local default  = config.Default  or false
    local callback = config.Callback or function() end

    local H = self:S(40)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card; frame.Size = UDim2.new(1,0,0,H)
    frame.Parent = parent; self:CreateCorner(frame, UDim.new(0,8))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.4)

    local cbSz = self:S(18)
    local cb = Instance.new("TextButton")
    cb.BackgroundColor3 = default and self.Theme.Accent or self.Theme.Input
    cb.AutoButtonColor = false
    cb.Position = UDim2.new(0, self:S(12), 0.5, -cbSz/2)
    cb.Size = UDim2.new(0, cbSz, 0, cbSz)
    cb.Font = Enum.Font.GothamBold
    cb.Text = default and "✓" or ""; cb.TextColor3 = Color3.new(1,1,1)
    cb.TextSize = self:S(12); cb.ZIndex = 2; cb.Parent = frame
    self:CreateCorner(cb, UDim.new(0,5))
    self:CreateStroke(cb, default and self.Theme.Accent or self.Theme.Border, 1.5, default and 0.2 or 0.4)

    local cbStroke = cb:FindFirstChildOfClass("UIStroke")

    local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, self:S(38), 0, 0); lbl.Size = UDim2.new(1,-self:S(50),1,0)
    lbl.Font = Enum.Font.GothamSemibold; lbl.Text = text
    lbl.TextColor3 = self.Theme.Text; lbl.TextSize = self:S(13)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frame

    local state = default
    cb.MouseButton1Click:Connect(function()
        state = not state; callback(state)
        if state then
            self:Tween(cb, {BackgroundColor3 = self.Theme.Accent}, 0.2)
            self:Tween(cbStroke, {Color = self.Theme.Accent, Transparency = 0.2}, 0.2)
            cb.Text = "✓"
        else
            self:Tween(cb, {BackgroundColor3 = self.Theme.Input}, 0.2)
            self:Tween(cbStroke, {Color = self.Theme.Border, Transparency = 0.4}, 0.2)
            cb.Text = ""
        end
    end)

    return {
        Frame    = frame,
        GetState = function() return state end,
        SetState = function(s)
            state = s; callback(state)
            self:Tween(cb, {BackgroundColor3 = state and self.Theme.Accent or self.Theme.Input}, 0.2)
            cb.Text = state and "✓" or ""
        end,
    }
end

-- ─── LABEL ────────────────────────────────────────────────────────────────────
function SpectrumX:CreateLabel(parent, config)
    config = config or {}
    local text  = config.Text  or "Label"
    local color = config.Color or self.Theme.TextSecondary
    local size  = config.Size  or UDim2.new(1,0,0,self:S(32))

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card; frame.Size = size
    frame.Parent = parent; self:CreateCorner(frame, UDim.new(0,8))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.5)

    local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0,self:S(12),0,0); lbl.Size = UDim2.new(1,-self:S(24),1,0)
    lbl.Font = Enum.Font.GothamSemibold; lbl.Text = text
    lbl.TextColor3 = color; lbl.TextSize = self:S(12)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frame

    return {Frame = frame, Label = lbl, SetText = function(t) lbl.Text = t end}
end

-- ─── SEPARATOR ────────────────────────────────────────────────────────────────
function SpectrumX:CreateSeparator(parent)
    local wrap = Instance.new("Frame")
    wrap.BackgroundTransparency = 1; wrap.Size = UDim2.new(1,0,0,self:S(10))
    wrap.Parent = parent
    local line = Instance.new("Frame")
    line.BackgroundColor3 = self.Theme.Border; line.BorderSizePixel = 0
    line.Position = UDim2.new(0,0,0.5,0); line.Size = UDim2.new(1,0,0,1)
    line.Parent = wrap
    makeGradient(line, Color3.new(0,0,0), self.Theme.BorderBright, 0)
    return wrap
end

-- ─── STATUS CARD ─────────────────────────────────────────────────────────────
function SpectrumX:CreateStatusCard(parent, config)
    config = config or {}
    local title = config.Title or "Status"

    local H = self:S(100)
    local frame = Instance.new("Frame")
    frame.Name = "StatusCard"; frame.BackgroundColor3 = self.Theme.Card
    frame.BorderSizePixel = 0; frame.Size = UDim2.new(1,0,0,H)
    frame.Active = true; frame.Parent = parent
    self:CreateCorner(frame, UDim.new(0,10))

    local fStroke = self:CreateStroke(frame, self.Theme.Accent, 1.5, 0)
    spawn(function()
        while frame.Parent do
            self:Tween(fStroke, {Transparency = 0.1}, 0.9)
            task.wait(0.95)
            self:Tween(fStroke, {Transparency = 0.7}, 0.9)
            task.wait(0.95)
        end
    end)

    -- Linha accent esquerda
    local leftBar = Instance.new("Frame")
    leftBar.BackgroundColor3 = self.Theme.Accent; leftBar.BorderSizePixel = 0
    leftBar.Position = UDim2.new(0,0,0,0); leftBar.Size = UDim2.new(0,3,1,0)
    leftBar.Parent = frame; self:CreateCorner(leftBar, UDim.new(0,10))

    local hd = Instance.new("Frame")
    hd.BackgroundColor3 = self.Theme.Header; hd.BorderSizePixel = 0
    hd.Size = UDim2.new(1,0,0,self:S(30)); hd.Parent = frame
    self:CreateCorner(hd, UDim.new(0,10))
    local hdCov = Instance.new("Frame")
    hdCov.BackgroundColor3 = self.Theme.Header; hdCov.BorderSizePixel = 0
    hdCov.Size = UDim2.new(1,0,0,10); hdCov.Position = UDim2.new(0,0,1,-10); hdCov.Parent = hd

    local hdTitle = Instance.new("TextLabel"); hdTitle.BackgroundTransparency = 1
    hdTitle.Position = UDim2.new(0,self:S(14),0,0); hdTitle.Size = UDim2.new(1,-self:S(14),1,0)
    hdTitle.Font = Enum.Font.GothamBold; hdTitle.Text = title
    hdTitle.TextColor3 = self.Theme.Text; hdTitle.TextSize = self:S(12)
    hdTitle.TextXAlignment = Enum.TextXAlignment.Left; hdTitle.Parent = hd

    local content = Instance.new("Frame"); content.BackgroundTransparency = 1
    content.Position = UDim2.new(0,self:S(12),0,self:S(34))
    content.Size = UDim2.new(1,-self:S(24),1,-self:S(42)); content.Parent = frame

    local statusLbl = Instance.new("TextLabel"); statusLbl.BackgroundTransparency = 1
    statusLbl.Size = UDim2.new(1,0,0,self:S(18))
    statusLbl.Font = Enum.Font.GothamSemibold; statusLbl.Text = "● Idle"
    statusLbl.TextColor3 = self.Theme.TextMuted; statusLbl.TextSize = self:S(12)
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left; statusLbl.Parent = content

    local infoLbl = Instance.new("TextLabel"); infoLbl.BackgroundTransparency = 1
    infoLbl.Position = UDim2.new(0,0,0,self:S(20))
    infoLbl.Size = UDim2.new(1,0,0,self:S(16))
    infoLbl.Font = Enum.Font.Gotham; infoLbl.Text = "Aguardando..."
    infoLbl.TextColor3 = self.Theme.TextMuted; infoLbl.TextSize = self:S(10)
    infoLbl.TextXAlignment = Enum.TextXAlignment.Left; infoLbl.Parent = content

    local barBg = Instance.new("Frame")
    barBg.BackgroundColor3 = self.Theme.Input; barBg.Position = UDim2.new(0,0,1,-self:S(5))
    barBg.Size = UDim2.new(1,0,0,self:S(4)); barBg.ClipsDescendants = true
    barBg.Parent = content; self:CreateCorner(barBg, UDim.new(1,0))

    local bar = Instance.new("Frame")
    bar.BackgroundColor3 = self.Theme.Accent; bar.Size = UDim2.new(0,0,1,0)
    bar.BorderSizePixel = 0; bar.Parent = barBg; self:CreateCorner(bar, UDim.new(1,0))
    makeGradient(bar, self.Theme.Accent, self.Theme.AccentDark, 0)

    self:MakeDraggable(frame, hd)

    return {
        Frame = frame,
        SetStatus = function(s, c)
            statusLbl.Text = "● " .. s; statusLbl.TextColor3 = c or self.Theme.TextMuted
        end,
        SetInfo = function(i) infoLbl.Text = i end,
        AnimateLoading = function(active, dur)
            if active then
                spawn(function()
                    while active and frame.Parent do
                        local tw = self:Tween(bar, {Size = UDim2.new(1,0,1,0)}, dur or 1.5)
                        tw.Completed:Wait(); task.wait(0.1)
                        bar.Size = UDim2.new(0,0,1,0); task.wait(0.1)
                    end
                end)
            else
                bar.Size = UDim2.new(0,0,1,0)
            end
        end,
    }
end

-- ─── NOTIFICAÇÕES ── premium, empilhadas ──────────────────────────────────────
function SpectrumX:Notify(config)
    config = config or {}
    local text     = config.Text     or "Notificação"
    local ntype    = config.Type     or "info"
    local duration = config.Duration or 3

    self:UpdateScale()
    local nW = self:S(ScaleData.IsMobile and 280 or 320)
    local nH = self:S(ScaleData.IsMobile and 58 or 64)

    local color = self.Theme.Info
    if ntype == "success" then     color = self.Theme.Success
    elseif ntype == "warning" then color = self.Theme.Warning
    elseif ntype == "error" then   color = self.Theme.Error
    end

    local notif = Instance.new("Frame")
    notif.BackgroundColor3 = self.Theme.Card
    notif.BorderSizePixel = 0
    notif.Size = UDim2.new(0, nW, 0, nH)
    notif.Parent = self.ScreenGui
    self:CreateCorner(notif, UDim.new(0,10))
    self:CreateStroke(notif, self.Theme.Border, 1, 0.3)
    self:CreateShadow(notif, 30)

    -- Barra colorida esquerda
    local colorBar = Instance.new("Frame")
    colorBar.BackgroundColor3 = color; colorBar.BorderSizePixel = 0
    colorBar.Size = UDim2.new(0, 3, 1, -self:S(16))
    colorBar.Position = UDim2.new(0, 0, 0, self:S(8))
    colorBar.Parent = notif; self:CreateCorner(colorBar, UDim.new(1,0))

    -- Barra topo colorida (fina)
    local topBar = Instance.new("Frame")
    topBar.BackgroundColor3 = color; topBar.BorderSizePixel = 0
    topBar.Size = UDim2.new(0.4, 0, 0, 2); topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.Parent = notif; self:CreateCorner(topBar, UDim.new(1,0))

    local icon = Instance.new("TextLabel"); icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(0, self:S(14), 0, 0); icon.Size = UDim2.new(0, self:S(26), 1, 0)
    icon.Font = Enum.Font.GothamBlack
    icon.Text = ntype=="success" and "✓" or ntype=="warning" and "⚠" or ntype=="error" and "✕" or "ℹ"
    icon.TextColor3 = color; icon.TextSize = self:S(18); icon.Parent = notif

    local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, self:S(46), 0, 0)
    lbl.Size = UDim2.new(1, -self:S(58), 1, 0)
    lbl.Font = Enum.Font.GothamSemibold; lbl.Text = text
    lbl.TextColor3 = self.Theme.Text; lbl.TextSize = self:S(12)
    lbl.TextWrapped = true; lbl.Parent = notif

    -- Barra de progresso
    local progBg = Instance.new("Frame")
    progBg.BackgroundColor3 = Color3.fromRGB(20,20,20); progBg.BorderSizePixel = 0
    progBg.Position = UDim2.new(0,0,1,-2); progBg.Size = UDim2.new(1,0,0,2)
    progBg.ClipsDescendants = true; progBg.Parent = notif
    self:CreateCorner(progBg, UDim.new(1,0))
    local prog = Instance.new("Frame")
    prog.BackgroundColor3 = color; prog.Size = UDim2.new(1,0,1,0)
    prog.BorderSizePixel = 0; prog.Parent = progBg

    -- Click para fechar
    local closeArea = Instance.new("TextButton")
    closeArea.BackgroundTransparency = 1; closeArea.Size = UDim2.new(1,0,1,0)
    closeArea.Text = ""; closeArea.ZIndex = 10; closeArea.Parent = notif

    table.insert(self._notifications, notif)

    local function getVP()
        local ok, cam = pcall(function() return workspace.CurrentCamera end)
        return (ok and cam) and cam.ViewportSize or Vector2.new(1366, 768)
    end

    local function restack()
        local vp = getVP(); local off = self:S(10)
        for i = #self._notifications, 1, -1 do
            local n = self._notifications[i]
            if n and n.Parent then
                self:Tween(n, {Position = UDim2.fromOffset(vp.X - nW - self:S(12), vp.Y - nH - off)}, 0.3)
                off = off + nH + self:S(6)
            end
        end
    end

    local dismissed = false
    local function dismiss()
        if dismissed then return end; dismissed = true
        for i, n in ipairs(self._notifications) do
            if n == notif then table.remove(self._notifications, i); break end
        end
        local vp = getVP()
        self:Tween(notif, {Position = UDim2.fromOffset(vp.X + nW + 20, notif.AbsolutePosition.Y),
                           BackgroundTransparency = 1}, 0.3)
        restack(); task.wait(0.35)
        if notif and notif.Parent then notif:Destroy() end
    end

    closeArea.MouseButton1Click:Connect(dismiss)

    -- Slide in
    local vp = getVP()
    notif.Position = UDim2.fromOffset(vp.X + nW + 20, vp.Y - nH - self:S(10))
    self:Tween(notif, {Position = UDim2.fromOffset(vp.X - nW - self:S(12), vp.Y - nH - self:S(10))},
        0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    restack()
    self:Tween(prog, {Size = UDim2.new(0,0,1,0)}, duration)

    task.delay(duration, function()
        if not dismissed then dismiss() end
    end)
end

-- ─── DESTROY ──────────────────────────────────────────────────────────────────
function SpectrumX:Destroy()
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

return SpectrumX

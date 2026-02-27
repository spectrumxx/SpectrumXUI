local SpectrumX = {}
SpectrumX.__index = SpectrumX

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════════════════════
-- THEME MODERNO - Inspirado na WindUI (Glassmorphism + Neumorphism)
-- ═══════════════════════════════════════════════════════════════════════════════
SpectrumX.Theme = {
    -- Cores base
    Background      = Color3.fromRGB(12, 12, 14),      -- Fundo escuro profundo
    BackgroundLight = Color3.fromRGB(18, 18, 22),      -- Cards elevados
    Header          = Color3.fromRGB(16, 16, 20),      -- Header sutil
    Sidebar         = Color3.fromRGB(14, 14, 18),      -- Sidebar integrada
    
    -- Cores de interação
    Card            = Color3.fromRGB(22, 22, 26),      -- Cards principais
    CardHover       = Color3.fromRGB(28, 28, 34),      -- Hover suave
    CardActive      = Color3.fromRGB(32, 32, 40),      -- Estado ativo
    Input           = Color3.fromRGB(26, 26, 30),      -- Inputs
    InputHover      = Color3.fromRGB(32, 32, 38),      -- Inputs hover
    InputFocus      = Color3.fromRGB(35, 35, 42),      -- Inputs focados
    
    -- Cores de destaque (Vermelho moderno)
    Accent          = Color3.fromRGB(220, 40, 40),     -- Vermelho vibrante
    AccentHover     = Color3.fromRGB(255, 60, 60),     -- Hover mais claro
    AccentSecondary = Color3.fromRGB(255, 100, 100),   -- Tom secundário
    AccentDark      = Color3.fromRGB(160, 25, 25),     -- Sombra do accent
    AccentGlow      = Color3.fromRGB(220, 40, 40),     -- Glow effect
    
    -- Texto
    Text            = Color3.fromRGB(245, 245, 250),   -- Texto principal
    TextSecondary   = Color3.fromRGB(160, 160, 170),   -- Texto secundário
    TextMuted       = Color3.fromRGB(100, 100, 110),   -- Texto desativado
    
    -- Estados
    Success         = Color3.fromRGB(50, 220, 100),
    Warning         = Color3.fromRGB(255, 190, 60),
    Info            = Color3.fromRGB(80, 170, 255),
    Error           = Color3.fromRGB(255, 60, 60),
    
    -- Bordas e separadores
    Border          = Color3.fromRGB(35, 35, 42),      -- Borda sutil
    BorderLight     = Color3.fromRGB(45, 45, 55),      -- Borda clara
    BorderAccent    = Color3.fromRGB(220, 40, 40),     -- Borda ativa
    
    -- Toggle
    ToggleOff       = Color3.fromRGB(40, 40, 48),
    ToggleOn        = Color3.fromRGB(220, 40, 40),
    
    -- Glassmorphism
    GlassBg         = Color3.fromRGB(20, 20, 25),      -- Fundo glass
    GlassBorder     = Color3.fromRGB(255, 255, 255),   -- Borda glass
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- ESCALA RESPONSIVA APRIMORADA
-- ═══════════════════════════════════════════════════════════════════════════════
local ScaleData = { IsMobile = false, ScaleFactor = 1, ScreenSize = Vector2.new(1920, 1080) }

function SpectrumX:UpdateScale()
    local ok, cam = pcall(function() return workspace.CurrentCamera end)
    if not ok or not cam then return end
    local vp = cam.ViewportSize
    if vp.X == 0 then return end
    
    ScaleData.ScreenSize = vp
    ScaleData.IsMobile = UserInputService.TouchEnabled and (vp.X < 1000 or vp.Y < 600)
    
    -- Cálculo mais preciso baseado na diagonal
    local diag = math.sqrt(vp.X^2 + vp.Y^2)
    local baseDiag = math.sqrt(1920^2 + 1080^2)
    local scale = diag / baseDiag
    
    if ScaleData.IsMobile then
        ScaleData.ScaleFactor = math.clamp(scale * 1.15, 0.9, 1.3)
    else
        ScaleData.ScaleFactor = math.clamp(scale, 0.75, 1.15)
    end
end

function SpectrumX:S(v)
    if type(v) == "number" then return math.floor(v * ScaleData.ScaleFactor) end
    if typeof(v) == "UDim2" then
        return UDim2.new(v.X.Scale, math.floor(v.X.Offset * ScaleData.ScaleFactor),
                         v.Y.Scale, math.floor(v.Y.Offset * ScaleData.ScaleFactor))
    end
    if typeof(v) == "UDim" then
        return UDim.new(v.Scale, math.floor(v.Offset * ScaleData.ScaleFactor))
    end
    return v
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- UTILITÁRIOS VISUAIS MODERNOS
-- ═══════════════════════════════════════════════════════════════════════════════
function SpectrumX:Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(
        t or 0.25,
        style or Enum.EasingStyle.Quart,
        dir or Enum.EasingDirection.Out
    )
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

function SpectrumX:CreateCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or UDim.new(0, 8)
    c.Parent = p
    return c
end

function SpectrumX:CreateStroke(p, color, thick, transp)
    local s = Instance.new("UIStroke")
    s.Color = color or self.Theme.Border
    s.Thickness = thick or 1
    s.Transparency = transp or 0.6
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

-- Sombra moderna multi-camada (simula elevação)
function SpectrumX:CreateShadow(p, intensity)
    intensity = intensity or 1
    local sz = math.floor(20 * intensity)
    
    -- Sombra externa suave
    local sh1 = Instance.new("Frame")
    sh1.Name = "Shadow1"
    sh1.AnchorPoint = Vector2.new(0.5, 0.5)
    sh1.BackgroundColor3 = Color3.new(0, 0, 0)
    sh1.BackgroundTransparency = 0.85
    sh1.BorderSizePixel = 0
    sh1.Position = UDim2.new(0.5, 0, 0.5, 2)
    sh1.Size = UDim2.new(1, sz, 1, sz)
    sh1.ZIndex = -2
    sh1.Parent = p
    self:CreateCorner(sh1, UDim.new(0, 12))
    
    -- Sombra interna mais forte
    local sh2 = Instance.new("Frame")
    sh2.Name = "Shadow2"
    sh2.AnchorPoint = Vector2.new(0.5, 0.5)
    sh2.BackgroundColor3 = Color3.new(0, 0, 0)
    sh2.BackgroundTransparency = 0.7
    sh2.BorderSizePixel = 0
    sh2.Position = UDim2.new(0.5, 0, 0.5, 1)
    sh2.Size = UDim2.new(1, math.floor(sz*0.6), 1, math.floor(sz*0.6))
    sh2.ZIndex = -1
    sh2.Parent = p
    self:CreateCorner(sh2, UDim.new(0, 10))
    
    return {sh1, sh2}
end

-- Gradiente moderno
function SpectrumX:CreateGradient(p, c0, c1, rot, trans)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c0 or self.Theme.Accent),
        ColorSequenceKeypoint.new(1, c1 or self.Theme.AccentDark)
    })
    g.Rotation = rot or 90
    g.Transparency = NumberSequence.new(trans or 0)
    g.Parent = p
    return g
end

-- Glow effect para elementos ativos
function SpectrumX:CreateGlow(p, color)
    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundColor3 = color or self.Theme.Accent
    glow.BackgroundTransparency = 0.9
    glow.BorderSizePixel = 0
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.Size = UDim2.new(1, 10, 1, 10)
    glow.ZIndex = -1
    glow.Parent = p
    self:CreateCorner(glow, UDim.new(0, 10))
    
    -- Animação de pulso sutil
    spawn(function()
        while glow.Parent do
            self:Tween(glow, {BackgroundTransparency = 0.95}, 1)
            task.wait(1)
            self:Tween(glow, {BackgroundTransparency = 0.85}, 1)
            task.wait(1)
        end
    end)
    
    return glow
end

-- Ícone moderno (suporta AssetId ou Lucide-style)
function SpectrumX:CreateIcon(parent, config)
    config = config or {}
    local size = config.Size or self:S(20)
    local color = config.Color or self.Theme.Text
    local assetId = config.AssetId
    local text = config.Text or "⚡"
    
    if assetId and assetId ~= "" then
        -- Ícone de imagem (AssetId)
        local img = Instance.new("ImageLabel")
        img.Name = "Icon"
        img.BackgroundTransparency = 1
        img.Size = UDim2.new(0, size, 0, size)
        img.Position = config.Position or UDim2.new(0.5, -size/2, 0.5, -size/2)
        img.Image = assetId
        img.ImageColor3 = color
        img.ScaleType = Enum.ScaleType.Fit
        img.ZIndex = config.ZIndex or 2
        img.Parent = parent
        
        if config.AspectRatio then
            local asp = Instance.new("UIAspectRatioConstraint")
            asp.AspectRatio = config.AspectRatio
            asp.Parent = img
        end
        
        return img
    else
        -- Ícone de texto (fallback)
        local lbl = Instance.new("TextLabel")
        lbl.Name = "Icon"
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(0, size, 0, size)
        lbl.Position = config.Position or UDim2.new(0.5, -size/2, 0.5, -size/2)
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = text
        lbl.TextColor3 = color
        lbl.TextSize = size * 0.8
        lbl.ZIndex = config.ZIndex or 2
        lbl.Parent = parent
        
        return lbl
    end
end

function SpectrumX:MakeDraggable(frame, handle)
    handle = handle or frame
    local drag, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dragStart = i.Position
            startPos = frame.Position
            
            -- Efeito visual ao pegar
            self:Tween(frame, {Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset,
                startPos.Y.Scale, startPos.Y.Offset - 2
            )}, 0.1)
            
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then 
                    drag = false
                    -- Volta ao normal
                    self:Tween(frame, {Position = startPos}, 0.1)
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or
           i.UserInputType == Enum.UserInputType.Touch then 
            dragInput = i 
        end
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if i == dragInput and drag then
            local delta = i.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SISTEMA DE DROPDOWNS
-- ═══════════════════════════════════════════════════════════════════════════════
function SpectrumX:_RegisterDropdown(list, btn, closeFn)
    if not self._drops then self._drops = {} end
    table.insert(self._drops, {list=list, btn=btn, close=closeFn})
    table.insert(self.Dropdowns, list)
end

function SpectrumX:_CloseOnOutside(pos)
    if not self._drops then return end
    for _, e in ipairs(self._drops) do
        if not e.list or not e.list.Visible then continue end
        local lp, ls = e.list.AbsolutePosition, e.list.AbsoluteSize
        local bp, bs = e.btn.AbsolutePosition, e.btn.AbsoluteSize
        local inL = pos.X >= lp.X and pos.X <= lp.X + ls.X and pos.Y >= lp.Y and pos.Y <= lp.Y + ls.Y
        local inB = pos.X >= bp.X and pos.X <= bp.X + bs.X and pos.Y >= bp.Y and pos.Y <= bp.Y + bs.Y
        if not inL and not inB then 
            task.spawn(function()
                e.close()
            end)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- WINDOW PRINCIPAL - Visual Moderno
-- ═══════════════════════════════════════════════════════════════════════════════
function SpectrumX:CreateWindow(config)
    config = config or {}
    local window = setmetatable({}, self)
    self:UpdateScale()
    
    -- Limpa GUI anterior
    if PlayerGui:FindFirstChild("SpectrumX") then
        PlayerGui.SpectrumX:Destroy()
    end
    
    -- ScreenGui principal
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SpectrumX"
    self.ScreenGui.Parent = PlayerGui
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.DisplayOrder = 999999
    
    self._notifications = {}
    self.Dropdowns = {}
    self._drops = {}
    
    -- Tamanho responsivo
    local isMobile = ScaleData.IsMobile
    local W = isMobile and self:S(400) or self:S(720)
    local H = isMobile and self:S(540) or self:S(460)
    
    -- Frame principal com glassmorphism
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.BackgroundColor3 = self.Theme.Background
    self.MainFrame.BackgroundTransparency = 0.02
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Position = config.Position or UDim2.new(0.5, -W/2, 0.5, -H/2)
    self.MainFrame.Size = config.Size or UDim2.new(0, W, 0, H)
    self.MainFrame.Active = true
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.ZIndex = 1
    self.MainFrame.Parent = self.ScreenGui
    
    -- Cantos arredondados modernos
    self:CreateCorner(self.MainFrame, UDim.new(0, 14))
    
    -- Sombra elevada
    self:CreateShadow(self.MainFrame, 1.2)
    
    -- Borda sutil com gradiente
    local borderFrame = Instance.new("Frame")
    borderFrame.Name = "Border"
    borderFrame.BackgroundTransparency = 1
    borderFrame.Size = UDim2.new(1, 0, 1, 0)
    borderFrame.ZIndex = 0
    borderFrame.Parent = self.MainFrame
    
    local stroke = self:CreateStroke(borderFrame, self.Theme.Border, 1.5, 0.3)
    
    -- Barra de accent no topo (estilo WindUI)
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.BackgroundColor3 = self.Theme.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Size = UDim2.new(1, 0, 0, 2)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.ZIndex = 5
    accentBar.Parent = self.MainFrame
    
    -- Gradiente na barra de accent
    self:CreateGradient(accentBar, self.Theme.Accent, self.Theme.AccentDark, 0)
    
    -- ═══ HEADER MODERNO ═══
    local HH = self:S(56)
    self.Header = Instance.new("Frame")
    self.Header.Name = "Header"
    self.Header.BackgroundColor3 = self.Theme.Header
    self.Header.BackgroundTransparency = 0.5
    self.Header.BorderSizePixel = 0
    self.Header.Size = UDim2.new(1, 0, 0, HH)
    self.Header.Position = UDim2.new(0, 0, 0, 2)
    self.Header.ZIndex = 2
    self.Header.Parent = self.MainFrame
    
    self:CreateCorner(self.Header, UDim.new(0, 12))
    
    -- Cover para arredondamento perfeito
    local hCov = Instance.new("Frame")
    hCov.BackgroundColor3 = self.Theme.Header
    hCov.BackgroundTransparency = 0.5
    hCov.BorderSizePixel = 0
    hCov.Size = UDim2.new(1, 0, 0, 12)
    hCov.Position = UDim2.new(0, 0, 1, -12)
    hCov.ZIndex = 2
    hCov.Parent = self.Header
    
    -- Linha separadora sutil
    local hLine = Instance.new("Frame")
    hLine.BackgroundColor3 = self.Theme.Border
    hLine.BorderSizePixel = 0
    hLine.Size = UDim2.new(1, -20, 0, 1)
    hLine.Position = UDim2.new(0.5, 0, 1, 0)
    hLine.AnchorPoint = Vector2.new(0.5, 0)
    hLine.ZIndex = 3
    hLine.Parent = self.Header
    
    -- Ícone/Logo do header com suporte a AssetId
    local iconX = self:S(16)
    local iconSize = self:S(32)
    
    if config.IconAssetId and config.IconAssetId ~= "" then
        -- Container para o ícone com fundo sutil
        local iconContainer = Instance.new("Frame")
        iconContainer.BackgroundColor3 = self.Theme.Accent
        iconContainer.BackgroundTransparency = 0.9
        iconContainer.Position = UDim2.new(0, iconX, 0.5, -iconSize/2)
        iconContainer.Size = UDim2.new(0, iconSize, 0, iconSize)
        iconContainer.ZIndex = 3
        iconContainer.Parent = self.Header
        self:CreateCorner(iconContainer, UDim.new(0, 8))
        
        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.Position = UDim2.new(0.5, -iconSize*0.35, 0.5, -iconSize*0.35)
        img.Size = UDim2.new(0, iconSize*0.7, 0, iconSize*0.7)
        img.Image = config.IconAssetId
        img.ImageColor3 = self.Theme.Accent
        img.ScaleType = Enum.ScaleType.Fit
        img.ZIndex = 4
        img.Parent = iconContainer
    else
        -- Logo padrão (letra S estilizada)
        local iconBg = Instance.new("Frame")
        iconBg.BackgroundColor3 = self.Theme.Accent
        iconBg.Position = UDim2.new(0, iconX, 0.5, -iconSize/2)
        iconBg.Size = UDim2.new(0, iconSize, 0, iconSize)
        iconBg.ZIndex = 3
        iconBg.Parent = self.Header
        self:CreateCorner(iconBg, UDim.new(0, 8))
        
        -- Gradiente no ícone
        self:CreateGradient(iconBg, self.Theme.Accent, self.Theme.AccentDark, 135)
        
        local ico = Instance.new("TextLabel")
        ico.BackgroundTransparency = 1
        ico.Size = UDim2.new(1, 0, 1, 0)
        ico.Font = Enum.Font.GothamBlack
        ico.Text = config.Icon or "S"
        ico.TextColor3 = Color3.new(1, 1, 1)
        ico.TextSize = self:S(18)
        ico.ZIndex = 4
        ico.Parent = iconBg
    end
    
    -- Título com gradiente sutil
    local titleX = iconX + self:S(42)
    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, titleX, 0, 0)
    titleLbl.Size = UDim2.new(0, self:S(300), 1, 0)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Text = config.Title or "Spectrum X"
    titleLbl.TextColor3 = self.Theme.Text
    titleLbl.TextSize = self:S(17)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 3
    titleLbl.Parent = self.Header
    
    -- Subtítulo (opcional)
    if config.Subtitle then
        titleLbl.Size = UDim2.new(0, self:S(300), 0, self:S(26))
        titleLbl.Position = UDim2.new(0, titleX, 0, self:S(6))
        
        local sub = Instance.new("TextLabel")
        sub.BackgroundTransparency = 1
        sub.Position = UDim2.new(0, titleX, 0, self:S(28))
        sub.Size = UDim2.new(0, self:S(300), 0, self:S(16))
        sub.Font = Enum.Font.Gotham
        sub.Text = config.Subtitle
        sub.TextColor3 = self.Theme.TextMuted
        sub.TextSize = self:S(10)
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.ZIndex = 3
        sub.Parent = self.Header
    end
    
    -- Botão minimizar moderno
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "Minimize"
    minBtn.BackgroundColor3 = self.Theme.Card
    minBtn.Position = UDim2.new(1, -self:S(44), 0.5, -self:S(12))
    minBtn.Size = UDim2.new(0, self:S(28), 0, self:S(24))
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Text = "—"
    minBtn.TextColor3 = self.Theme.TextMuted
    minBtn.TextSize = self:S(12)
    minBtn.AutoButtonColor = false
    minBtn.ZIndex = 3
    minBtn.Parent = self.Header
    self:CreateCorner(minBtn, UDim.new(0, 6))
    
    -- Hover effect
    minBtn.MouseEnter:Connect(function()
        self:Tween(minBtn, {BackgroundColor3 = self.Theme.Accent, TextColor3 = Color3.new(1,1,1)}, 0.2)
    end)
    minBtn.MouseLeave:Connect(function()
        self:Tween(minBtn, {BackgroundColor3 = self.Theme.Card, TextColor3 = self.Theme.TextMuted}, 0.2)
    end)
    minBtn.MouseButton1Click:Connect(function()
        self.MainFrame.Visible = false
    end)
    
    -- ═══ SIDEBAR MODERNA ═══
    local SW = self:S(68)
    
    -- Container da sidebar com visual integrado
    local sidebarWrap = Instance.new("Frame")
    sidebarWrap.Name = "SidebarWrap"
    sidebarWrap.BackgroundColor3 = self.Theme.Sidebar
    sidebarWrap.BackgroundTransparency = 0.3
    sidebarWrap.BorderSizePixel = 0
    sidebarWrap.Position = UDim2.new(0, 0, 0, HH + 2)
    sidebarWrap.Size = UDim2.new(0, SW, 1, -(HH + 2))
    sidebarWrap.ClipsDescendants = true
    sidebarWrap.ZIndex = 1
    sidebarWrap.Parent = self.MainFrame
    
    self:CreateCorner(sidebarWrap, UDim.new(0, 12))
    
    -- Linha separadora vertical sutil
    local sbLine = Instance.new("Frame")
    sbLine.BackgroundColor3 = self.Theme.Border
    sbLine.BorderSizePixel = 0
    sbLine.Position = UDim2.new(1, -1, 0, 10)
    sbLine.Size = UDim2.new(0, 1, 1, -20)
    sbLine.ZIndex = 2
    sbLine.Parent = sidebarWrap
    
    -- ScrollingFrame da sidebar
    self.Sidebar = Instance.new("ScrollingFrame")
    self.Sidebar.Name = "Sidebar"
    self.Sidebar.BackgroundTransparency = 1
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Position = UDim2.new(0, 0, 0, 0)
    self.Sidebar.Size = UDim2.new(1, 0, 1, 0)
    self.Sidebar.ScrollBarThickness = 0 -- Scrollbar invisível (estilo moderno)
    self.Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    self.Sidebar.ZIndex = 1
    self.Sidebar.Parent = sidebarWrap
    
    local sbLayout = Instance.new("UIListLayout")
    sbLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sbLayout.Padding = UDim.new(0, self:S(6))
    sbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sbLayout.Parent = self.Sidebar
    
    local sbPad = Instance.new("UIPadding")
    sbPad.PaddingTop = UDim.new(0, self:S(12))
    sbPad.PaddingBottom = UDim.new(0, self:S(12))
    sbPad.Parent = self.Sidebar
    
    -- Auto-resize
    sbLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Sidebar.CanvasSize = UDim2.new(0, 0, 0, sbLayout.AbsoluteContentSize.Y + self:S(24))
    end)
    
    -- ═══ CONTENT AREA ═══
    local CA_X = SW + self:S(10)
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Position = UDim2.new(0, CA_X, 0, HH + self:S(10))
    self.ContentArea.Size = UDim2.new(1, -(CA_X + self:S(10)), 1, -(HH + self:S(16)))
    self.ContentArea.ZIndex = 1
    self.ContentArea.Parent = self.MainFrame
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Setup inicial
    self:MakeDraggable(self.MainFrame, self.Header)
    self:_CreateFloatingButton(config)
    
    -- Fechar dropdowns ao clicar fora
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            self:_CloseOnOutside(input.Position)
        end
    end)
    
    -- Atualizar escala quando mudar resolução
    local ok, cam = pcall(function() return workspace.CurrentCamera end)
    if ok and cam then
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            self:UpdateScale()
        end)
    end
    
    return window
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- FLOATING BUTTON MODERNO
-- ═══════════════════════════════════════════════════════════════════════════════
function SpectrumX:_CreateFloatingButton(config)
    config = config or {}
    local sz = self:S(52)
    
    self.FloatBtn = Instance.new("ImageButton")
    self.FloatBtn.Name = "FloatBtn"
    self.FloatBtn.BackgroundColor3 = self.Theme.Accent
    self.FloatBtn.Position = UDim2.new(0, 20, 0.5, 0)
    self.FloatBtn.Size = UDim2.new(0, sz, 0, sz)
    self.FloatBtn.Image = ""
    self.FloatBtn.AutoButtonColor = false
    self.FloatBtn.ZIndex = 10
    self.FloatBtn.Parent = self.ScreenGui
    
    self:CreateCorner(self.FloatBtn, UDim.new(0, 14))
    
    -- Sombra do botão flutuante
    self:CreateShadow(self.FloatBtn, 1.5)
    self:CreateGlow(self.FloatBtn, self.Theme.Accent)
    
    -- Ícone do botão (suporta AssetId)
    if config.IconAssetId and config.IconAssetId ~= "" then
        self:CreateIcon(self.FloatBtn, {
            AssetId = config.IconAssetId,
            Size = self:S(26),
            Color = Color3.new(1, 1, 1),
            ZIndex = 3
        })
    else
        self:CreateIcon(self.FloatBtn, {
            Text = config.Icon or "S",
            Size = self:S(26),
            Color = Color3.new(1, 1, 1),
            ZIndex = 3
        })
    end
    
    -- Animações de hover
    self.FloatBtn.MouseEnter:Connect(function()
        self:Tween(self.FloatBtn, {BackgroundColor3 = self.Theme.AccentHover, Size = UDim2.new(0, sz*1.05, 0, sz*1.05)}, 0.2)
    end)
    self.FloatBtn.MouseLeave:Connect(function()
        self:Tween(self.FloatBtn, {BackgroundColor3 = self.Theme.Accent, Size = UDim2.new(0, sz, 0, sz)}, 0.2)
    end)
    
    -- Drag do botão flutuante
    local fDrag, fDragInput, fDragStart, fStartPos
    self.FloatBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            fDrag = true
            fDragStart = i.Position
            fStartPos = self.FloatBtn.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then fDrag = false end
            end)
        end
    end)
    
    self.FloatBtn.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or
           i.UserInputType == Enum.UserInputType.Touch then 
            fDragInput = i 
        end
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if i == fDragInput and fDrag then
            local d = i.Position - fDragStart
            self.FloatBtn.Position = UDim2.new(
                fStartPos.X.Scale, fStartPos.X.Offset + d.X,
                fStartPos.Y.Scale, fStartPos.Y.Offset + d.Y
            )
        end
    end)
    
    -- Toggle visibilidade
    self.FloatBtn.MouseButton1Click:Connect(function()
        if not fDrag then
            local visible = not self.MainFrame.Visible
            self.MainFrame.Visible = visible
            
            if visible then
                self.MainFrame.BackgroundTransparency = 1
                self:Tween(self.MainFrame, {BackgroundTransparency = 0.02}, 0.25)
                
                -- Animação de entrada suave
                local originalPos = self.MainFrame.Position
                self.MainFrame.Position = UDim2.new(
                    originalPos.X.Scale, originalPos.X.Offset,
                    originalPos.Y.Scale, originalPos.Y.Offset + 20
                )
                self:Tween(self.MainFrame, {Position = originalPos}, 0.3, Enum.EasingStyle.Back)
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB SYSTEM COM SUPORTE A ASSETID
-- ═══════════════════════════════════════════════════════════════════════════════
function SpectrumX:CreateTab(config)
    config = config or {}
    local tabId = config.Name or "Tab"
    local tabIcon = config.Icon
    local iconAssetId = config.IconAssetId
    local btnSz = self:S(48)
    
    -- Botão da tab
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = tabId .. "Tab"
    tabBtn.BackgroundColor3 = self.Theme.Card
    tabBtn.BackgroundTransparency = 0.5
    tabBtn.Size = UDim2.new(0, btnSz, 0, btnSz)
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    tabBtn.ZIndex = 2
    tabBtn.Parent = self.Sidebar
    
    self:CreateCorner(tabBtn, UDim.new(0, 10))
    
    -- Indicador lateral (estilo WindUI)
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.BackgroundColor3 = self.Theme.Accent
    indicator.BorderSizePixel = 0
    indicator.Position = UDim2.new(0, 0, 0.5, -self:S(12))
    indicator.Size = UDim2.new(0, 3, 0, self:S(24))
    indicator.Visible = false
    indicator.ZIndex = 3
    indicator.Parent = tabBtn
    self:CreateCorner(indicator, UDim.new(1, 0))
    
    -- Glow do indicador
    local indGlow = Instance.new("Frame")
    indGlow.BackgroundColor3 = self.Theme.Accent
    indGlow.BackgroundTransparency = 0.8
    indGlow.BorderSizePixel = 0
    indGlow.Position = UDim2.new(0, -2, 0.5, -self:S(16))
    indGlow.Size = UDim2.new(0, 7, 0, self:S(32))
    indGlow.Visible = false
    indGlow.ZIndex = 2
    indGlow.Parent = tabBtn
    self:CreateCorner(indGlow, UDim.new(1, 0))
    
    -- Ícone da tab (suporta AssetId)
    local iconContainer = Instance.new("Frame")
    iconContainer.Name = "IconContainer"
    iconContainer.BackgroundTransparency = 1
    iconContainer.Position = UDim2.new(0.5, -self:S(12), 0.5, -self:S(12))
    iconContainer.Size = UDim2.new(0, self:S(24), 0, self:S(24))
    iconContainer.ZIndex = 3
    iconContainer.Parent = tabBtn
    
    if iconAssetId and iconAssetId ~= "" then
        -- Ícone de imagem
        self:CreateIcon(iconContainer, {
            AssetId = iconAssetId,
            Size = self:S(22),
            Color = self.Theme.TextMuted,
            ZIndex = 3
        })
    else
        -- Ícone de texto
        self:CreateIcon(iconContainer, {
            Text = tabIcon or string.sub(tabId, 1, 1),
            Size = self:S(20),
            Color = self.Theme.TextMuted,
            ZIndex = 3
        })
    end
    
    -- Tooltip moderno
    local tooltip = Instance.new("Frame")
    tooltip.Name = "Tooltip"
    tooltip.BackgroundColor3 = self.Theme.Card
    tooltip.BackgroundTransparency = 0.1
    tooltip.BorderSizePixel = 0
    tooltip.Position = UDim2.new(1, self:S(10), 0.5, -self:S(12))
    tooltip.Size = UDim2.new(0, 0, 0, self:S(24))
    tooltip.Visible = false
    tooltip.ZIndex = 100
    tooltip.Parent = tabBtn
    self:CreateCorner(tooltip, UDim.new(0, 6))
    self:CreateStroke(tooltip, self.Theme.Border, 1, 0.5)
    
    local tooltipLbl = Instance.new("TextLabel")
    tooltipLbl.BackgroundTransparency = 1
    tooltipLbl.Position = UDim2.new(0, self:S(10), 0, 0)
    tooltipLbl.Size = UDim2.new(0, self:S(100), 1, 0)
    tooltipLbl.Font = Enum.Font.GothamSemibold
    tooltipLbl.Text = tabId
    tooltipLbl.TextColor3 = self.Theme.Text
    tooltipLbl.TextSize = self:S(11)
    tooltipLbl.TextXAlignment = Enum.TextXAlignment.Left
    tooltipLbl.ZIndex = 101
    tooltipLbl.Parent = tooltip
    
    -- Animações de hover
    tabBtn.MouseEnter:Connect(function()
        if self.CurrentTab ~= tabId then
            self:Tween(tabBtn, {BackgroundColor3 = self.Theme.CardHover, BackgroundTransparency = 0.3}, 0.2)
        end
        tooltip.Visible = true
        self:Tween(tooltip, {Size = UDim2.new(0, self:S(80), 0, self:S(24))}, 0.2)
    end)
    
    tabBtn.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabId then
            self:Tween(tabBtn, {BackgroundColor3 = self.Theme.Card, BackgroundTransparency = 0.5}, 0.2)
        end
        tooltip.Visible = false
        tooltip.Size = UDim2.new(0, 0, 0, self:S(24))
    end)
    
    -- Container da página
    local page = Instance.new("Frame")
    page.Name = tabId .. "Page"
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Visible = false
    page.ZIndex = 1
    page.Parent = self.ContentArea
    
    -- Layout de duas colunas
    local div = Instance.new("Frame")
    div.BackgroundColor3 = self.Theme.Border
    div.BorderSizePixel = 0
    div.Position = UDim2.new(0.5, -1, 0, 0)
    div.Size = UDim2.new(0, 1, 1, 0)
    div.ZIndex = 1
    div.Parent = page
    
    local function makeSide(pos, sz, name)
        local sf = Instance.new("ScrollingFrame")
        sf.Name = name
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel = 0
        sf.Position = pos
        sf.Size = sz
        sf.ScrollBarThickness = 2
        sf.ScrollBarImageColor3 = self.Theme.Accent
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.ZIndex = 1
        sf.Parent = page
        
        local lay = Instance.new("UIListLayout")
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        lay.Padding = UDim.new(0, self:S(8))
        lay.Parent = sf
        
        local pad = Instance.new("UIPadding")
        pad.PaddingBottom = UDim.new(0, self:S(12))
        pad.Parent = sf
        
        lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sf.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + self:S(20))
        end)
        
        return sf
    end
    
    local left = makeSide(UDim2.new(0, 0, 0, 0), UDim2.new(0.48, 0, 1, 0), "Left")
    local right = makeSide(UDim2.new(0.52, 0, 0, 0), UDim2.new(0.48, 0, 1, 0), "Right")
    
    -- Armazenar dados da tab
    local tabData = {
        Button = tabBtn,
        Container = page,
        Left = left,
        Right = right,
        IconContainer = iconContainer,
        Indicator = indicator,
        IndGlow = indGlow
    }
    self.Tabs[tabId] = tabData
    
    -- Evento de clique
    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(tabId)
    end)
    
    -- Selecionar primeira tab automaticamente
    if not self.CurrentTab then
        self:SelectTab(tabId)
    end
    
    return tabData
end

function SpectrumX:SelectTab(tabId)
    for id, data in pairs(self.Tabs) do
        local icon = data.IconContainer:FindFirstChild("Icon")
        local isActive = (id == tabId)
        
        if isActive then
            -- Estado ativo
            data.Container.Visible = true
            self:Tween(data.Button, {BackgroundColor3 = self.Theme.CardActive, BackgroundTransparency = 0.2}, 0.25)
            data.Indicator.Visible = true
            data.IndGlow.Visible = true
            
            -- Animação do indicador
            self:Tween(data.Indicator, {Size = UDim2.new(0, 3, 0, self:S(28))}, 0.2, Enum.EasingStyle.Back)
            
            -- Ícone branco
            if icon then
                if icon:IsA("TextLabel") then
                    self:Tween(icon, {TextColor3 = self.Theme.Text}, 0.2)
                elseif icon:IsA("ImageLabel") then
                    self:Tween(icon, {ImageColor3 = self.Theme.Text}, 0.2)
                end
            end
            
            -- Glow sutil
            self:CreateGlow(data.Button, self.Theme.Accent)
        else
            -- Estado inativo
            data.Container.Visible = false
            self:Tween(data.Button, {BackgroundColor3 = self.Theme.Card, BackgroundTransparency = 0.5}, 0.25)
            data.Indicator.Visible = false
            data.IndGlow.Visible = false
            
            -- Ícone muted
            if icon then
                if icon:IsA("TextLabel") then
                    self:Tween(icon, {TextColor3 = self.Theme.TextMuted}, 0.2)
                elseif icon:IsA("ImageLabel") then
                    self:Tween(icon, {ImageColor3 = self.Theme.TextMuted}, 0.2)
                end
            end
            
            -- Remover glow
            local glow = data.Button:FindFirstChild("Glow")
            if glow then glow:Destroy() end
        end
    end
    
    self.CurrentTab = tabId
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- COMPONENTES UI MODERNIZADOS (API 100% compatível)
-- ═══════════════════════════════════════════════════════════════════════════════

function SpectrumX:CreateSection(parent, text, color)
    local wrap = Instance.new("Frame")
    wrap.BackgroundTransparency = 1
    wrap.Size = UDim2.new(1, 0, 0, self:S(28))
    wrap.ZIndex = 1
    wrap.Parent = parent
    
    -- Linha com gradiente
    local line = Instance.new("Frame")
    line.BackgroundColor3 = color or self.Theme.Accent
    line.BorderSizePixel = 0
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.ZIndex = 1
    line.Parent = wrap
    
    self:CreateGradient(line, Color3.new(0,0,0), color or self.Theme.Accent, 0)
    
    -- Texto com fundo
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundColor3 = self.Theme.Background
    lbl.BorderSizePixel = 0
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Position = UDim2.new(0, self:S(6), 0, 0)
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = "  " .. text .. "  "
    lbl.TextColor3 = color or self.Theme.Accent
    lbl.TextSize = self:S(12)
    lbl.ZIndex = 2
    lbl.Parent = wrap
    
    return wrap
end

function SpectrumX:CreateToggle(parent, config)
    config = config or {}
    local text = config.Text or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local H = self:S(48)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.BackgroundTransparency = 0.4
    frame.Size = UDim2.new(1, 0, 0, H)
    frame.ZIndex = 1
    frame.Parent = parent
    
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.5)
    
    -- Hover effect
    local hoverBg = Instance.new("Frame")
    hoverBg.Name = "HoverBg"
    hoverBg.BackgroundColor3 = self.Theme.CardHover
    hoverBg.BackgroundTransparency = 1
    hoverBg.Size = UDim2.new(1, 0, 1, 0)
    hoverBg.ZIndex = 0
    hoverBg.Parent = frame
    self:CreateCorner(hoverBg, UDim.new(0, 10))
    
    -- Label
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, self:S(14), 0, 0)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Text = text
    lbl.TextColor3 = self.Theme.Text
    lbl.TextSize = self:S(13)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 1
    lbl.Parent = frame
    
    -- Track do toggle
    local trackW, trackH = self:S(48), self:S(24)
    local track = Instance.new("TextButton")
    track.Name = "Track"
    track.AutoButtonColor = false
    track.BackgroundColor3 = default and self.Theme.ToggleOn or self.Theme.ToggleOff
    track.Position = UDim2.new(1, -trackW - self:S(14), 0.5, -trackH/2)
    track.Size = UDim2.new(0, trackW, 0, trackH)
    track.Text = ""
    track.ZIndex = 2
    track.Parent = frame
    
    self:CreateCorner(track, UDim.new(1, 0))
    self:CreateStroke(track, default and self.Theme.Accent or self.Theme.Border, 1.5, default and 0.3 or 0.6)
    
    local trackStroke = track:FindFirstChildOfClass("UIStroke")
    
    -- Knob com sombra
    local kSz = self:S(18)
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Position = default and UDim2.new(1, -kSz - self:S(3), 0.5, -kSz/2)
                          or UDim2.new(0, self:S(3), 0.5, -kSz/2)
    knob.Size = UDim2.new(0, kSz, 0, kSz)
    knob.ZIndex = 3
    knob.Parent = track
    
    self:CreateCorner(knob, UDim.new(1, 0))
    
    -- Sombra do knob
    local knobShadow = Instance.new("Frame")
    knobShadow.BackgroundColor3 = Color3.new(0, 0, 0)
    knobShadow.BackgroundTransparency = 0.7
    knobShadow.BorderSizePixel = 0
    knobShadow.Position = UDim2.new(0, 0, 0, 2)
    knobShadow.Size = UDim2.new(1, 0, 1, 0)
    knobShadow.ZIndex = 2
    knobShadow.Parent = knob
    self:CreateCorner(knobShadow, UDim.new(1, 0))
    
    local state = default
    
    local function update(s, animated)
        local t = animated == false and 0 or 0.25
        if s then
            self:Tween(track, {BackgroundColor3 = self.Theme.ToggleOn}, t)
            self:Tween(trackStroke, {Color = self.Theme.Accent, Transparency = 0.3}, t)
            self:Tween(knob, {Position = UDim2.new(1, -kSz - self:S(3), 0.5, -kSz/2)}, t,
                Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            
            -- Glow no frame quando ativo
            local glow = frame:FindFirstChild("Glow")
            if not glow then
                self:CreateGlow(frame, self.Theme.Accent)
            end
        else
            self:Tween(track, {BackgroundColor3 = self.Theme.ToggleOff}, t)
            self:Tween(trackStroke, {Color = self.Theme.Border, Transparency = 0.6}, t)
            self:Tween(knob, {Position = UDim2.new(0, self:S(3), 0.5, -kSz/2)}, t,
                Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            
            -- Remover glow
            local glow = frame:FindFirstChild("Glow")
            if glow then glow:Destroy() end
        end
    end
    
    track.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        update(state)
    end)
    
    -- Hover effects
    frame.MouseEnter:Connect(function()
        self:Tween(hoverBg, {BackgroundTransparency = 0.6}, 0.2)
    end)
    frame.MouseLeave:Connect(function()
        self:Tween(hoverBg, {BackgroundTransparency = 1}, 0.2)
    end)
    
    -- Estado inicial
    if default then
        self:CreateGlow(frame, self.Theme.Accent)
    end
    
    return {
        Frame = frame,
        GetState = function() return state end,
        SetState = function(s) state = s; callback(state); update(state) end,
    }
end

function SpectrumX:CreateButton(parent, config)
    config = config or {}
    local text = config.Text or "Button"
    local style = config.Style or "default"
    local callback = config.Callback or function() end
    
    local H = self:S(40)
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 0, H)
    frame.ZIndex = 1
    frame.Parent = parent
    
    local btn = Instance.new("TextButton")
    btn.Name = "Button"
    btn.AutoButtonColor = false
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextSize = self:S(13)
    btn.ZIndex = 2
    btn.Parent = frame
    
    self:CreateCorner(btn, UDim.new(0, 8))
    
    -- Cores baseadas no estilo
    local color, textColor, hoverColor
    if style == "accent" then
        btn.BackgroundColor3 = self.Theme.Accent
        textColor = Color3.new(1, 1, 1)
        hoverColor = self.Theme.AccentHover
        self:CreateGradient(btn, self.Theme.Accent, self.Theme.AccentDark, 90)
    elseif style == "warning" then
        btn.BackgroundColor3 = Color3.fromRGB(40, 30, 10)
        textColor = self.Theme.Warning
        hoverColor = Color3.fromRGB(60, 45, 15)
    elseif style == "info" then
        btn.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
        textColor = self.Theme.Info
        hoverColor = Color3.fromRGB(25, 40, 70)
    else
        btn.BackgroundColor3 = self.Theme.Card
        textColor = self.Theme.Text
        hoverColor = self.Theme.CardHover
    end
    
    btn.TextColor3 = textColor
    
    local stroke = self:CreateStroke(btn, style == "accent" and self.Theme.Accent or self.Theme.Border, 
        1.2, style == "accent" and 0.8 or 0.4)
    
    -- Container para ripple
    local rippleHolder = Instance.new("Frame")
    rippleHolder.BackgroundTransparency = 1
    rippleHolder.BorderSizePixel = 0
    rippleHolder.Size = UDim2.new(1, 0, 1, 0)
    rippleHolder.ClipsDescendants = true
    rippleHolder.ZIndex = btn.ZIndex + 1
    rippleHolder.Parent = btn
    self:CreateCorner(rippleHolder, UDim.new(0, 8))
    
    -- Animações
    btn.MouseEnter:Connect(function()
        if style == "accent" then
            self:Tween(btn, {BackgroundColor3 = hoverColor}, 0.2)
        else
            self:Tween(btn, {BackgroundColor3 = hoverColor}, 0.2)
            self:Tween(stroke, {Transparency = 0.2}, 0.2)
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if style == "accent" then
            btn.BackgroundColor3 = self.Theme.Accent
        else
            self:Tween(btn, {BackgroundColor3 = self.Theme.Card}, 0.2)
            self:Tween(stroke, {Transparency = 0.4}, 0.2)
        end
    end)
    
    -- Ripple effect melhorado
    btn.MouseButton1Click:Connect(function()
        -- Criar ripple
        local ripple = Instance.new("Frame")
        ripple.BackgroundColor3 = Color3.new(1, 1, 1)
        ripple.BackgroundTransparency = 0.8
        ripple.BorderSizePixel = 0
        
        local mousePos = UserInputService:GetMouseLocation()
        local relX = mousePos.X - btn.AbsolutePosition.X
        local relY = mousePos.Y - btn.AbsolutePosition.Y
        
        ripple.Position = UDim2.new(0, relX - 2, 0, relY - 2)
        ripple.Size = UDim2.new(0, 4, 0, 4)
        ripple.ZIndex = 10
        ripple.Parent = rippleHolder
        self:CreateCorner(ripple, UDim.new(1, 0))
        
        local maxSz = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.5
        
        self:Tween(ripple, {
            Size = UDim2.new(0, maxSz, 0, maxSz),
            Position = UDim2.new(0, relX - maxSz/2, 0, relY - maxSz/2),
            BackgroundTransparency = 1
        }, 0.5)
        
        task.delay(0.5, function()
            if ripple then ripple:Destroy() end
        end)
        
        callback()
    end)
    
    return {
        Frame = frame,
        Button = btn,
        SetText = function(t) btn.Text = t end
    }
end

function SpectrumX:CreateInput(parent, config)
    config = config or {}
    local labelText = config.Label or "Input"
    local default = config.Default or ""
    local placeholder = config.Placeholder or "Digite aqui..."
    local callback = config.Callback or function() end
    
    local H = self:S(64)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.BackgroundTransparency = 0.4
    frame.Size = UDim2.new(1, 0, 0, H)
    frame.ZIndex = 1
    frame.Parent = parent
    
    self:CreateCorner(frame, UDim.new(0, 10))
    local stroke = self:CreateStroke(frame, self.Theme.Border, 1, 0.4)
    
    -- Label
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, self:S(12), 0, self:S(10))
    lbl.Size = UDim2.new(1, -self:S(24), 0, self:S(16))
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Text = labelText
    lbl.TextColor3 = self.Theme.TextMuted
    lbl.TextSize = self:S(10)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 1
    lbl.Parent = frame
    
    -- TextBox
    local box = Instance.new("TextBox")
    box.BackgroundColor3 = self.Theme.Input
    box.Position = UDim2.new(0, self:S(10), 0, self:S(28))
    box.Size = UDim2.new(1, -self:S(20), 0, self:S(26))
    box.Font = Enum.Font.Gotham
    box.Text = tostring(default)
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = self.Theme.TextMuted
    box.TextColor3 = self.Theme.Text
    box.TextSize = self:S(13)
    box.ClearTextOnFocus = false
    box.ZIndex = 2
    box.Parent = frame
    
    self:CreateCorner(box, UDim.new(0, 6))
    
    -- Focus effects
    box.Focused:Connect(function()
        self:Tween(stroke, {Color = self.Theme.Accent, Transparency = 0.2}, 0.2)
        self:Tween(lbl, {TextColor3 = self.Theme.Accent}, 0.2)
        self:Tween(box, {BackgroundColor3 = self.Theme.InputFocus}, 0.2)
    end)
    
    box.FocusLost:Connect(function()
        self:Tween(stroke, {Color = self.Theme.Border, Transparency = 0.4}, 0.2)
        self:Tween(lbl, {TextColor3 = self.Theme.TextMuted}, 0.2)
        self:Tween(box, {BackgroundColor3 = self.Theme.Input}, 0.2)
        callback(box.Text)
    end)
    
    return {
        Frame = frame,
        TextBox = box,
        GetText = function() return box.Text end,
        SetText = function(t) box.Text = t end,
    }
end

function SpectrumX:CreateSlider(parent, config)
    config = config or {}
    local text = config.Text or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local callback = config.Callback or function() end
    
    local H = self:S(64)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.BackgroundTransparency = 0.4
    frame.Size = UDim2.new(1, 0, 0, H)
    frame.ZIndex = 1
    frame.Parent = parent
    
    self:CreateCorner(frame, UDim.new(0, 10))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.4)
    
    -- Label
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, self:S(12), 0, self:S(10))
    lbl.Size = UDim2.new(0.5, 0, 0, self:S(16))
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Text = text
    lbl.TextColor3 = self.Theme.Text
    lbl.TextSize = self:S(12)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 1
    lbl.Parent = frame
    
    -- Valor display
    local valBg = Instance.new("Frame")
    valBg.BackgroundColor3 = self.Theme.Accent
    valBg.Position = UDim2.new(1, -self:S(50), 0, self:S(8))
    valBg.Size = UDim2.new(0, self:S(44), 0, self:S(22))
    valBg.ZIndex = 2
    valBg.Parent = frame
    self:CreateCorner(valBg, UDim.new(0, 6))
    
    local valLbl = Instance.new("TextLabel")
    valLbl.BackgroundTransparency = 1
    valLbl.Size = UDim2.new(1, 0, 1, 0)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = Color3.new(1, 1, 1)
    valLbl.TextSize = self:S(11)
    valLbl.ZIndex = 3
    valLbl.Parent = valBg
    
    -- Track
    local trackH = self:S(6)
    local trackBg = Instance.new("Frame")
    trackBg.BackgroundColor3 = self.Theme.Input
    trackBg.Position = UDim2.new(0, self:S(12), 1, -self:S(20))
    trackBg.Size = UDim2.new(1, -self:S(24), 0, trackH)
    trackBg.ZIndex = 1
    trackBg.Parent = frame
    self:CreateCorner(trackBg, UDim.new(1, 0))
    
    -- Fill com gradiente
    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = self.Theme.Accent
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.ZIndex = 2
    fill.Parent = trackBg
    self:CreateCorner(fill, UDim.new(1, 0))
    self:CreateGradient(fill, self.Theme.Accent, self.Theme.AccentDark, 0)
    
    -- Knob moderno
    local kSz = self:S(16)
    local knob = Instance.new("Frame")
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Position = UDim2.new((default-min)/(max-min), -kSz/2, 0.5, -kSz/2)
    knob.Size = UDim2.new(0, kSz, 0, kSz)
    knob.ZIndex = 3
    knob.Parent = trackBg
    self:CreateCorner(knob, UDim.new(1, 0))
    
    -- Sombra do knob
    local knobShadow = Instance.new("Frame")
    knobShadow.BackgroundColor3 = Color3.new(0, 0, 0)
    knobShadow.BackgroundTransparency = 0.6
    knobShadow.BorderSizePixel = 0
    knobShadow.Position = UDim2.new(0, 0, 0, 2)
    knobShadow.Size = UDim2.new(1, 0, 1, 0)
    knobShadow.ZIndex = 2
    knobShadow.Parent = knob
    self:CreateCorner(knobShadow, UDim.new(1, 0))
    
    local drag = false
    local cur = default
    
    local function upd(input)
        local p = math.clamp((input.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
        local v = math.floor((min + (max-min)*p) * 100) / 100
        cur = v
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, -kSz/2, 0.5, -kSz/2)
        valLbl.Text = tostring(v)
        callback(v)
    end
    
    trackBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            upd(i)
        end
    end)
    
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            -- Scale up no knob
            self:Tween(knob, {Size = UDim2.new(0, kSz*1.2, 0, kSz*1.2)}, 0.1)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or
           i.UserInputType == Enum.UserInputType.Touch) then
            upd(i)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            if drag then
                drag = false
                -- Scale down no knob
                self:Tween(knob, {Size = UDim2.new(0, kSz, 0, kSz)}, 0.1)
            end
        end
    end)
    
    return {
        Frame = frame,
        GetValue = function() return cur end,
        SetValue = function(v)
            v = math.clamp(v, min, max)
            cur = v
            local p = (v-min)/(max-min)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -kSz/2, 0.5, -kSz/2)
            valLbl.Text = tostring(v)
        end,
    }
end

-- Dropdown helper
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

function SpectrumX:CreateDropdown(parent, config)
    config = config or {}
    local labelText = config.Label or "Dropdown"
    local options = config.Options or {}
    local default = config.Default
    local callback = config.Callback or function() end
    
    local H = self:S(64)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.BackgroundTransparency = 0.4
    frame.Size = UDim2.new(1, 0, 0, H)
    frame.ClipsDescendants = false
    frame.ZIndex = 1
    frame.Parent = parent
    
    self:CreateCorner(frame, UDim.new(0, 10))
    local stroke = self:CreateStroke(frame, self.Theme.Border, 1, 0.4)
    
    -- Label
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, self:S(12), 0, self:S(10))
    lbl.Size = UDim2.new(1, -self:S(24), 0, self:S(14))
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Text = labelText
    lbl.TextColor3 = self.Theme.TextMuted
    lbl.TextSize = self:S(10)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 1
    lbl.Parent = frame
    
    -- Botão do dropdown
    local dropBtn = Instance.new("TextButton")
    dropBtn.BackgroundColor3 = self.Theme.Input
    dropBtn.AutoButtonColor = false
    dropBtn.Position = UDim2.new(0, self:S(10), 0, self:S(26))
    dropBtn.Size = UDim2.new(1, -self:S(20), 0, self:S(28))
    dropBtn.Font = Enum.Font.GothamSemibold
    dropBtn.Text = "  " .. (default or "Selecionar...")
    dropBtn.TextColor3 = default and self.Theme.Text or self.Theme.TextMuted
    dropBtn.TextSize = self:S(12)
    dropBtn.TextXAlignment = Enum.TextXAlignment.Left
    dropBtn.ZIndex = 2
    dropBtn.Parent = frame
    
    self:CreateCorner(dropBtn, UDim.new(0, 8))
    local dropStroke = self:CreateStroke(dropBtn, self.Theme.Border, 1, 0.4)
    
    -- Ícone de seta
    local arrow = Instance.new("TextLabel")
    arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(1, -self:S(28), 0, 0)
    arrow.Size = UDim2.new(0, self:S(24), 1, 0)
    arrow.Font = Enum.Font.GothamBold
    arrow.Text = "▼"
    arrow.TextColor3 = self.Theme.Accent
    arrow.TextSize = self:S(10)
    arrow.ZIndex = 3
    arrow.Parent = dropBtn
    
    -- Lista do dropdown
    local dropList = Instance.new("ScrollingFrame")
    dropList.Name = "DropList"
    dropList.BackgroundColor3 = self.Theme.Card
    dropList.BackgroundTransparency = 0.05
    dropList.Size = UDim2.new(0, 0, 0, 0)
    dropList.ScrollBarThickness = 2
    dropList.ScrollBarImageColor3 = self.Theme.Accent
    dropList.Visible = false
    dropList.ZIndex = 100
    dropList.BorderSizePixel = 0
    dropList.Parent = self.ScreenGui
    
    self:CreateCorner(dropList, UDim.new(0, 10))
    self:CreateStroke(dropList, self.Theme.Accent, 1.5, 0.3)
    self:CreateShadow(dropList, 1)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, self:S(4))
    listLayout.Parent = dropList
    
    local lPad = Instance.new("UIPadding")
    lPad.PaddingTop = UDim.new(0, 6)
    lPad.PaddingBottom = UDim.new(0, 6)
    lPad.PaddingLeft = UDim.new(0, 6)
    lPad.PaddingRight = UDim.new(0, 6)
    lPad.Parent = dropList
    
    local selected = default
    local isOpen = false
    local maxH = self:S(200)
    
    local function closeDD()
        if not isOpen then return end
        isOpen = false
        self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)}, 0.2)
        self:Tween(arrow, {Rotation = 0}, 0.2)
        self:Tween(dropStroke, {Color = self.Theme.Border, Transparency = 0.4}, 0.2)
        task.wait(0.2)
        dropList.Visible = false
    end
    
    self:_RegisterDropdown(dropList, dropBtn, closeDD)
    
    local function populate()
        for _, ch in ipairs(dropList:GetChildren()) do
            if ch:IsA("Frame") then ch:Destroy() end
        end
        
        for _, opt in ipairs(options) do
            local isSel = opt == selected
            local row = Instance.new("TextButton")
            row.BackgroundColor3 = isSel and Color3.fromRGB(40, 20, 20) or self.Theme.Input
            row.Size = UDim2.new(1, 0, 0, self:S(30))
            row.Font = Enum.Font.GothamSemibold
            row.Text = "  " .. opt
            row.TextColor3 = isSel and self.Theme.Accent or self.Theme.TextSecondary
            row.TextSize = self:S(12)
            row.TextXAlignment = Enum.TextXAlignment.Left
            row.AutoButtonColor = false
            row.ZIndex = 101
            row.Parent = dropList
            
            self:CreateCorner(row, UDim.new(0, 6))
            
            if isSel then
                self:CreateStroke(row, self.Theme.Accent, 1, 0.3)
            end
            
            -- Hover
            row.MouseEnter:Connect(function()
                if not isSel then
                    self:Tween(row, {BackgroundColor3 = self.Theme.CardHover}, 0.15)
                end
            end)
            row.MouseLeave:Connect(function()
                if not isSel then
                    self:Tween(row, {BackgroundColor3 = self.Theme.Input}, 0.15)
                end
            end)
            
            row.MouseButton1Click:Connect(function()
                selected = opt
                dropBtn.Text = "  " .. opt
                dropBtn.TextColor3 = self.Theme.Text
                callback(opt)
                closeDD()
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
        
        for _, dd in ipairs(self.Dropdowns) do
            if dd ~= dropList then dd.Visible = false end
        end
        
        populate()
        local pos, tH, cH = dropPos(dropBtn, listLayout, maxH)
        dropList.Position = pos
        dropList.Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, 0)
        dropList.CanvasSize = UDim2.new(0, 0, 0, cH)
        dropList.Visible = true
        
        self:Tween(dropList, {Size = UDim2.new(0, dropBtn.AbsoluteSize.X, 0, tH)}, 0.25,
            Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        self:Tween(arrow, {Rotation = 180}, 0.2)
        self:Tween(dropStroke, {Color = self.Theme.Accent, Transparency = 0.2}, 0.2)
        
        isOpen = true
    end)
    
    return {
        Frame = frame,
        GetValue = function() return selected end,
        SetValue = function(v)
            selected = v
            dropBtn.Text = "  " .. (v or "Selecionar...")
        end,
        SetOptions = function(o)
            options = o
            if isOpen then populate() end
        end,
    }
end

function SpectrumX:CreateLabel(parent, config)
    config = config or {}
    local text = config.Text or "Label"
    local color = config.Color or self.Theme.TextSecondary
    local size = config.Size or UDim2.new(1, 0, 0, self:S(36))
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = self.Theme.Card
    frame.BackgroundTransparency = 0.6
    frame.Size = size
    frame.ZIndex = 1
    frame.Parent = parent
    
    self:CreateCorner(frame, UDim.new(0, 8))
    self:CreateStroke(frame, self.Theme.Border, 1, 0.3)
    
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, self:S(12), 0, 0)
    lbl.Size = UDim2.new(1, -self:S(24), 1, 0)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextSize = self:S(12)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 1
    lbl.Parent = frame
    
    return {
        Frame = frame,
        Label = lbl,
        SetText = function(t) lbl.Text = t end
    }
end

function SpectrumX:CreateSeparator(parent)
    local wrap = Instance.new("Frame")
    wrap.BackgroundTransparency = 1
    wrap.Size = UDim2.new(1, 0, 0, self:S(12))
    wrap.ZIndex = 1
    wrap.Parent = parent
    
    local line = Instance.new("Frame")
    line.BackgroundColor3 = self.Theme.Border
    line.BorderSizePixel = 0
    line.Position = UDim2.new(0, self:S(20), 0.5, 0)
    line.Size = UDim2.new(1, -self:S(40), 0, 1)
    line.ZIndex = 1
    line.Parent = wrap
    
    -- Gradiente sutil
    self:CreateGradient(line, Color3.new(0,0,0), self.Theme.Border, 0)
    
    return wrap
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- NOTIFICAÇÕES MODERNAS
-- ═══════════════════════════════════════════════════════════════════════════════
function SpectrumX:Notify(config)
    config = config or {}
    local text = config.Text or "Notificação"
    local ntype = config.Type or "info"
    local duration = config.Duration or 4
    
    self:UpdateScale()
    local nW = self:S(ScaleData.IsMobile and 300 or 340)
    local nH = self:S(ScaleData.IsMobile and 70 or 76)
    
    local color = self.Theme.Info
    if ntype == "success" then color = self.Theme.Success
    elseif ntype == "warning" then color = self.Theme.Warning
    elseif ntype == "error" then color = self.Theme.Error end
    
    local notif = Instance.new("Frame")
    notif.BackgroundColor3 = self.Theme.Card
    notif.BackgroundTransparency = 0.05
    notif.BorderSizePixel = 0
    notif.Size = UDim2.new(0, nW, 0, nH)
    notif.ZIndex = 1000
    notif.Parent = self.ScreenGui
    
    self:CreateCorner(notif, UDim.new(0, 12))
    self:CreateShadow(notif, 1.2)
    
    -- Barra lateral colorida
    local sideBar = Instance.new("Frame")
    sideBar.BackgroundColor3 = color
    sideBar.BorderSizePixel = 0
    sideBar.Size = UDim2.new(0, 4, 1, -self:S(16))
    sideBar.Position = UDim2.new(0, 0, 0, self:S(8))
    sideBar.ZIndex = 2
    sideBar.Parent = notif
    self:CreateCorner(sideBar, UDim.new(1, 0))
    
    -- Ícone
    local icon = Instance.new("TextLabel")
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(0, self:S(16), 0, 0)
    icon.Size = UDim2.new(0, self:S(28), 1, 0)
    icon.Font = Enum.Font.GothamBlack
    icon.Text = ntype=="success" and "✓" or ntype=="warning" and "!" or ntype=="error" and "✕" or "i"
    icon.TextColor3 = color
    icon.TextSize = self:S(20)
    icon.ZIndex = 2
    icon.Parent = notif
    
    -- Texto
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, self:S(52), 0, 0)
    lbl.Size = UDim2.new(1, -self:S(64), 1, 0)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Text = text
    lbl.TextColor3 = self.Theme.Text
    lbl.TextSize = self:S(12)
    lbl.TextWrapped = true
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex = 2
    lbl.Parent = notif
    
    -- Barra de progresso
    local progBg = Instance.new("Frame")
    progBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    progBg.BorderSizePixel = 0
    progBg.Position = UDim2.new(0, 0, 1, -3)
    progBg.Size = UDim2.new(1, 0, 0, 3)
    progBg.ClipsDescendants = true
    progBg.ZIndex = 2
    progBg.Parent = notif
    self:CreateCorner(progBg, UDim.new(1, 0))
    
    local prog = Instance.new("Frame")
    prog.BackgroundColor3 = color
    prog.Size = UDim2.new(1, 0, 1, 0)
    prog.BorderSizePixel = 0
    prog.ZIndex = 3
    prog.Parent = progBg
    
    -- Botão de fechar invisível
    local closeBtn = Instance.new("TextButton")
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size = UDim2.new(1, 0, 1, 0)
    closeBtn.Text = ""
    closeBtn.ZIndex = 10
    closeBtn.Parent = notif
    
    table.insert(self._notifications, notif)
    
    local function getVP()
        local ok, cam = pcall(function() return workspace.CurrentCamera end)
        return (ok and cam) and cam.ViewportSize or Vector2.new(1366, 768)
    end
    
    local function restack()
        local vp = getVP()
        local off = self:S(20)
        for i = #self._notifications, 1, -1 do
            local n = self._notifications[i]
            if n and n.Parent then
                self:Tween(n, {
                    Position = UDim2.fromOffset(vp.X - nW - self:S(16), vp.Y - nH - off)
                }, 0.3, Enum.EasingStyle.Quart)
                off = off + nH + self:S(10)
            end
        end
    end
    
    local dismissed = false
    local function dismiss()
        if dismissed then return end
        dismissed = true
        
        for i, n in ipairs(self._notifications) do
            if n == notif then table.remove(self._notifications, i); break end
        end
        
        local vp = getVP()
        self:Tween(notif, {
            Position = UDim2.fromOffset(vp.X + nW + 50, notif.AbsolutePosition.Y),
            BackgroundTransparency = 1
        }, 0.3)
        
        restack()
        task.wait(0.35)
        if notif and notif.Parent then notif:Destroy() end
    end
    
    closeBtn.MouseButton1Click:Connect(dismiss)
    
    -- Animação de entrada
    local vp = getVP()
    notif.Position = UDim2.fromOffset(vp.X + nW + 50, vp.Y - nH - self:S(20))
    
    self:Tween(notif, {
        Position = UDim2.fromOffset(vp.X - nW - self:S(16), vp.Y - nH - self:S(20))
    }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    restack()
    
    -- Progresso
    self:Tween(prog, {Size = UDim2.new(0, 0, 1, 0)}, duration)
    
    task.delay(duration, function()
        if not dismissed then dismiss() end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- DESTROY
-- ═══════════════════════════════════════════════════════════════════════════════
function SpectrumX:Destroy()
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

return SpectrumX

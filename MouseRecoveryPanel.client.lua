-- Mouse Recovery Panel
-- Coloque este LocalScript em StarterPlayer > StarterPlayerScripts.
-- Feito para uso dentro da sua própria experiência no Roblox Studio.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
if not player then
    warn("[Mouse Recovery] Coloque este código em um LocalScript dentro de StarterPlayer > StarterPlayerScripts.")
    return
end

local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
    warn("[Mouse Recovery] PlayerGui não ficou disponível. Inicie o jogo com Play no Roblox Studio.")
    return
end

local FIX_KEY = Enum.KeyCode.F6
local PANEL_KEY = Enum.KeyCode.RightShift
local VIDEO_ASSET_ID = "https://vt.tiktok.com/ZSgYQECos/" -- Troque por rbxassetid://ID se o Roblox não aceitar o link
local choosingKey = false
local isFixing = false

local COLORS = {
    background = Color3.fromRGB(11, 14, 23),
    panel = Color3.fromRGB(19, 23, 36),
    card = Color3.fromRGB(26, 31, 47),
    accent = Color3.fromRGB(91, 211, 255),
    accent2 = Color3.fromRGB(125, 111, 255),
    text = Color3.fromRGB(242, 246, 255),
    muted = Color3.fromRGB(145, 157, 181),
    green = Color3.fromRGB(105, 230, 176),
    red = Color3.fromRGB(255, 123, 145),
}

local function create(className, parent, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function addCorner(parent, radius)
    create("UICorner", parent, {
        CornerRadius = UDim.new(0, radius),
    })
end

local function addStroke(parent, color, transparency, thickness)
    create("UIStroke", parent, {
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
    })
end

local activeTweens = {}

local function tween(object, duration, properties)
    local previous = activeTweens[object]
    if previous then
        previous:Cancel()
    end

    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )
    activeTweens[object] = animation
    animation.Completed:Connect(function()
        if activeTweens[object] == animation then
            activeTweens[object] = nil
        end
    end)
    animation:Play()
    return animation
end

-- Tela de carregamento
local loadingGui = create("ScreenGui", playerGui, {
    Name = "MouseRecoveryLoading",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 1000,
})

local loadingBackground = create("Frame", loadingGui, {
    Name = "Background",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLORS.background,
    BorderSizePixel = 0,
})

local loadingCard = create("Frame", loadingBackground, {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(330, 205),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
})
local initialCamera = workspace.CurrentCamera
if initialCamera then
    create("UIScale", loadingCard, {
        Scale = math.min(1, initialCamera.ViewportSize.X / 360, initialCamera.ViewportSize.Y / 240),
    })
end
addCorner(loadingCard, 22)
addStroke(loadingCard, COLORS.accent2, 0.55, 1)

create("TextLabel", loadingCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 26),
    Size = UDim2.new(1, 0, 0, 34),
    Font = Enum.Font.GothamBold,
    Text = "NOVA",
    TextColor3 = COLORS.accent,
    TextSize = 26,
})

create("TextLabel", loadingCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 67),
    Size = UDim2.new(1, 0, 0, 27),
    Font = Enum.Font.GothamSemibold,
    Text = "Preparando o painel",
    TextColor3 = COLORS.text,
    TextSize = 16,
})

create("TextLabel", loadingCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 96),
    Size = UDim2.new(1, 0, 0, 22),
    Font = Enum.Font.Gotham,
    Text = "Mouse Recovery  •  inicializando",
    TextColor3 = COLORS.muted,
    TextSize = 11,
})

local loadingTrack = create("Frame", loadingCard, {
    Position = UDim2.new(0, 28, 1, -36),
    Size = UDim2.new(1, -56, 0, 5),
    BackgroundColor3 = COLORS.card,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})
addCorner(loadingTrack, 5)

local loadingFill = create("Frame", loadingTrack, {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = COLORS.accent,
    BorderSizePixel = 0,
})
addCorner(loadingFill, 5)

local loadTween = tween(loadingFill, 1.05, {
    Size = UDim2.new(1, 0, 1, 0),
})
loadTween.Completed:Wait()

for _, item in ipairs(loadingGui:GetDescendants()) do
    if item:IsA("TextLabel") or item:IsA("TextButton") then
        tween(item, 0.18, {
            TextTransparency = 1,
            BackgroundTransparency = 1,
        })
    elseif item:IsA("Frame") then
        tween(item, 0.18, {BackgroundTransparency = 1})
    elseif item:IsA("UIStroke") then
        tween(item, 0.18, {Transparency = 1})
    end
end

task.wait(0.2)
loadingGui:Destroy()

-- Interface principal
local screenGui = create("ScreenGui", playerGui, {
    Name = "MouseRecoveryPanel",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local shade = create("Frame", screenGui, {
    Name = "Shade",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(3, 5, 10),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
})

local panel = create("CanvasGroup", shade, {
    Name = "Panel",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(510, 355),
    GroupTransparency = 1,
    BackgroundColor3 = COLORS.panel,
    BackgroundTransparency = 0.16,
    BorderSizePixel = 0,
    ZIndex = 1,
})

local backgroundVideo = create("VideoFrame", panel, {
    Name = "PanelVideoBackground",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 1,
    Looped = true,
    Volume = 0,
    Visible = VIDEO_ASSET_ID ~= "",
})
addCorner(backgroundVideo, 22)

local videoTint = create("Frame", panel, {
    Name = "VideoTint",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = COLORS.background,
    BackgroundTransparency = 0.58,
    BorderSizePixel = 0,
    ZIndex = 1,
    Visible = VIDEO_ASSET_ID ~= "",
})
addCorner(videoTint, 22)

if VIDEO_ASSET_ID ~= "" then
    backgroundVideo.Loaded:Connect(function()
        backgroundVideo:Play()
    end)

    local videoSourceAccepted = pcall(function()
        backgroundVideo.Video = VIDEO_ASSET_ID
    end)

    if not videoSourceAccepted then
        backgroundVideo.Visible = false
        videoTint.Visible = false
        warn("[NOVA] O Roblox não aceitou o link externo de vídeo. Substitua VIDEO_ASSET_ID por um ID rbxassetid://.")
    end
end

addCorner(panel, 22)
addStroke(panel, COLORS.accent2, 0.48, 1)

create("UISizeConstraint", panel, {
    MinSize = Vector2.new(310, 330),
    MaxSize = Vector2.new(510, 355),
})

local panelScale = create("UIScale", panel, {
    Scale = 1,
})

local cameraViewportConnection
local function updatePanelScale()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    panelScale.Scale = math.min(1, camera.ViewportSize.X / 550, camera.ViewportSize.Y / 390)
end

local function watchCurrentCamera()
    if cameraViewportConnection then
        cameraViewportConnection:Disconnect()
        cameraViewportConnection = nil
    end
    local camera = workspace.CurrentCamera
    if camera then
        cameraViewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updatePanelScale)
        updatePanelScale()
    end
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCurrentCamera)
watchCurrentCamera()

-- Cabeçalho do painel
local header = create("Frame", panel, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(20, 14),
    Size = UDim2.new(1, -40, 0, 48),
})

local logo = create("Frame", header, {
    Size = UDim2.fromOffset(36, 36),
    BackgroundColor3 = COLORS.card,
    BorderSizePixel = 0,
})
addCorner(logo, 12)
addStroke(logo, COLORS.accent, 0.3, 1)
create("UIGradient", logo, {
    Color = ColorSequence.new(COLORS.accent, COLORS.accent2),
    Rotation = 35,
})
create("TextLabel", logo, {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.GothamBold,
    Text = "N",
    TextColor3 = COLORS.accent,
    TextSize = 19,
})

create("TextLabel", header, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(45, 0),
    Size = UDim2.fromOffset(69, 21),
    Font = Enum.Font.GothamBold,
    Text = "NOVA",
    TextColor3 = COLORS.text,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
})

create("TextLabel", header, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(46, 20),
    Size = UDim2.fromOffset(72, 15),
    Font = Enum.Font.Gotham,
    Text = "by askzedd",
    TextColor3 = COLORS.muted,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local freeBadge = create("Frame", header, {
    Position = UDim2.fromOffset(119, 6),
    Size = UDim2.fromOffset(53, 24),
    BackgroundColor3 = Color3.fromRGB(45, 52, 74),
    BorderSizePixel = 0,
})
addCorner(freeBadge, 10)
create("TextLabel", freeBadge, {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.GothamBold,
    Text = "FREE",
    TextColor3 = Color3.fromRGB(211, 218, 238),
    TextSize = 10,
})

local deviceBadge = create("Frame", header, {
    Position = UDim2.fromOffset(178, 6),
    Size = UDim2.fromOffset(76, 24),
    BackgroundColor3 = Color3.fromRGB(33, 73, 85),
    BorderSizePixel = 0,
})
addCorner(deviceBadge, 10)
local deviceBadgeText = create("TextLabel", deviceBadge, {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.GothamBold,
    TextColor3 = COLORS.accent,
    TextSize = 9,
})

local function getDeviceLabel()
    if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
        return "MOBILE"
    elseif UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
        return "GAMEPAD"
    end
    return "PC"
end

deviceBadgeText.Text = getDeviceLabel()
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
    deviceBadgeText.Text = getDeviceLabel()
end)

local closeButton = create("TextButton", header, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 1),
    Size = UDim2.fromOffset(36, 36),
    BackgroundColor3 = COLORS.card,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamSemibold,
    Text = "−",
    TextColor3 = COLORS.accent,
    TextSize = 25,
})
addCorner(closeButton, 12)

create("Frame", panel, {
    Position = UDim2.new(0, 20, 0, 73),
    Size = UDim2.new(1, -40, 0, 1),
    BackgroundColor3 = Color3.fromRGB(48, 56, 77),
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
})

-- Navegação por categorias
local sidebar = create("Frame", panel, {
    Position = UDim2.fromOffset(20, 89),
    Size = UDim2.fromOffset(116, 246),
    BackgroundTransparency = 1,
})

local content = create("CanvasGroup", panel, {
    Position = UDim2.fromOffset(146, 87),
    Size = UDim2.new(1, -166, 0, 248),
    BackgroundTransparency = 1,
    GroupTransparency = 0,
    BorderSizePixel = 0,
})

local function makeCategoryButton(text, y)
    local button = create("TextButton", sidebar, {
        Position = UDim2.fromOffset(0, y),
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = COLORS.card,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamSemibold,
        Text = "   " .. text,
        TextColor3 = COLORS.muted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    addCorner(button, 12)
    return button
end

local infoTab = makeCategoryButton("ⓘ  Info", 3)
local visualTab = makeCategoryButton("◉  Visual", 50)

local infoPage = create("Frame", content, {
    Name = "InfoPage",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = true,
})

local visualPage = create("Frame", content, {
    Name = "VisualPage",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = false,
})

create("TextLabel", infoPage, {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 20),
    Font = Enum.Font.GothamBold,
    Text = "PLAYER INFO",
    TextColor3 = COLORS.text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local function makeInfoRow(label, value, y)
    local row = create("Frame", infoPage, {
        Position = UDim2.fromOffset(0, y),
        Size = UDim2.new(1, 0, 0, 27),
        BackgroundColor3 = COLORS.card,
        BackgroundTransparency = 0.28,
        BorderSizePixel = 0,
    })
    addCorner(row, 9)
    create("TextLabel", row, {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(0, 93, 1, 0),
        Font = Enum.Font.Gotham,
        Text = label,
        TextColor3 = COLORS.muted,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local valueLabel = create("TextLabel", row, {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 103, 0, 0),
        Size = UDim2.new(1, -111, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = value,
        TextColor3 = COLORS.text,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    return valueLabel
end

makeInfoRow("Display name", player.DisplayName, 23)
makeInfoRow("Usuário", "@" .. player.Name, 53)
makeInfoRow("User ID", tostring(player.UserId), 83)
makeInfoRow("Conta", tostring(player.AccountAge) .. " dias", 113)
local pingValue = makeInfoRow("Ping", "medindo...", 143)
local deviceValue = makeInfoRow("Dispositivo", getDeviceLabel(), 173)
makeInfoRow("Região / IP", "não fornecidos pelo Roblox", 203)

local pingRefreshToken = 0
local function refreshPing()
    pingRefreshToken += 1
    local token = pingRefreshToken

    local function update()
        if token ~= pingRefreshToken or not screenGui.Parent or not infoPage.Visible then
            return
        end

        local ok, pingSeconds = pcall(function()
            return player:GetNetworkPing()
        end)
        if ok and type(pingSeconds) == "number" then
            pingValue.Text = string.format("%d ms", math.floor(pingSeconds * 1000 + 0.5))
        else
            pingValue.Text = "indisponível"
        end
        deviceValue.Text = getDeviceLabel()
        task.delay(1, update)
    end

    update()
end
refreshPing()

-- Categoria Visual: mantém a recuperação do cursor e seus atalhos.
create("TextLabel", visualPage, {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 20),
    Font = Enum.Font.GothamBold,
    Text = "VISUAL",
    TextColor3 = COLORS.text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local statusCard = create("Frame", visualPage, {
    Position = UDim2.fromOffset(0, 24),
    Size = UDim2.new(1, 0, 0, 49),
    BackgroundColor3 = COLORS.card,
    BackgroundTransparency = 0.26,
    BorderSizePixel = 0,
})
addCorner(statusCard, 12)
addStroke(statusCard, Color3.fromRGB(70, 83, 112), 0.72, 1)

local statusDot = create("Frame", statusCard, {
    Position = UDim2.fromOffset(12, 19),
    Size = UDim2.fromOffset(10, 10),
    BackgroundColor3 = COLORS.green,
    BorderSizePixel = 0,
})
addCorner(statusDot, 10)

local statusText = create("TextLabel", statusCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(30, 5),
    Size = UDim2.new(1, -40, 0, 19),
    Font = Enum.Font.GothamSemibold,
    Text = "Cursor pronto",
    TextColor3 = COLORS.text,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local statusHint = create("TextLabel", statusCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(30, 24),
    Size = UDim2.new(1, -40, 0, 17),
    Font = Enum.Font.Gotham,
    Text = "Use o botão abaixo se o mouse travar.",
    TextColor3 = COLORS.muted,
    TextSize = 8,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
})

local fixButton = create("TextButton", visualPage, {
    Position = UDim2.fromOffset(0, 81),
    Size = UDim2.new(1, 0, 0, 51),
    BackgroundColor3 = COLORS.accent2,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    Text = "LIBERAR CURSOR",
    TextColor3 = COLORS.text,
    TextSize = 12,
})
addCorner(fixButton, 13)
create("UIGradient", fixButton, {
    Color = ColorSequence.new(Color3.fromRGB(73, 194, 255), Color3.fromRGB(131, 93, 255)),
    Rotation = 0,
})
addStroke(fixButton, Color3.fromRGB(181, 223, 255), 0.68, 1)

local keyCard = create("Frame", visualPage, {
    Position = UDim2.fromOffset(0, 140),
    Size = UDim2.new(1, 0, 0, 52),
    BackgroundColor3 = COLORS.card,
    BackgroundTransparency = 0.26,
    BorderSizePixel = 0,
})
addCorner(keyCard, 12)
addStroke(keyCard, Color3.fromRGB(70, 83, 112), 0.74, 1)

create("TextLabel", keyCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(10, 5),
    Size = UDim2.new(1, -115, 0, 18),
    Font = Enum.Font.GothamSemibold,
    Text = "TECLA PARA LIBERAR",
    TextColor3 = COLORS.muted,
    TextSize = 8,
    TextXAlignment = Enum.TextXAlignment.Left,
})

local keyButton = create("TextButton", keyCard, {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -8, 0.5, 0),
    Size = UDim2.fromOffset(94, 34),
    BackgroundColor3 = Color3.fromRGB(36, 44, 64),
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    Text = FIX_KEY.Name,
    TextColor3 = COLORS.accent,
    TextSize = 10,
})
addCorner(keyButton, 10)

local keyHint = create("TextLabel", keyCard, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(10, 23),
    Size = UDim2.new(1, -115, 0, 17),
    Font = Enum.Font.Gotham,
    Text = "Toque e escolha uma tecla",
    TextColor3 = COLORS.muted,
    TextSize = 8,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
})

create("TextLabel", visualPage, {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 203),
    Size = UDim2.new(1, 0, 0, 20),
    Font = Enum.Font.Gotham,
    Text = "RIGHT SHIFT  •  mostrar / esconder",
    TextColor3 = COLORS.muted,
    TextSize = 8,
    TextXAlignment = Enum.TextXAlignment.Center,
})

local selectedTab = infoTab
local activePage = infoPage
local categoryTransition = 0

local function setCategory(category)
    local nextPage = category == "Info" and infoPage or visualPage
    local nextTab = category == "Info" and infoTab or visualTab
    if activePage == nextPage then
        return
    end

    categoryTransition += 1
    local transitionId = categoryTransition
    selectedTab = nextTab
    activePage = nextPage

    tween(infoTab, 0.15, {
        BackgroundTransparency = nextTab == infoTab and 0.16 or 0.4,
        TextColor3 = nextTab == infoTab and COLORS.text or COLORS.muted,
    })
    tween(visualTab, 0.15, {
        BackgroundTransparency = nextTab == visualTab and 0.16 or 0.4,
        TextColor3 = nextTab == visualTab and COLORS.text or COLORS.muted,
    })

    local fadeOut = tween(content, 0.1, {GroupTransparency = 1})
    fadeOut.Completed:Connect(function(playbackState)
        if playbackState ~= Enum.PlaybackState.Completed or transitionId ~= categoryTransition then
            return
        end
        infoPage.Visible = nextPage == infoPage
        visualPage.Visible = nextPage == visualPage
        if nextPage == infoPage then
            refreshPing()
        else
            pingRefreshToken += 1
        end
        tween(content, 0.13, {GroupTransparency = 0})
    end)
end

infoTab.Activated:Connect(function()
    setCategory("Info")
end)
visualTab.Activated:Connect(function()
    setCategory("Visual")
end)
infoTab.BackgroundTransparency = 0.16
infoTab.TextColor3 = COLORS.text
visualTab.BackgroundTransparency = 0.4
visualTab.TextColor3 = COLORS.muted

-- Botão flutuante que continua acessível depois de minimizar o painel.
local floatingButton = create("TextButton", screenGui, {
    Name = "FloatingOpenButton",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(1, -42, 1, -145),
    Size = UDim2.fromOffset(58, 58),
    BackgroundColor3 = COLORS.panel,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Visible = false,
    ZIndex = 10,
    Text = "",
})
addCorner(floatingButton, 19)
addStroke(floatingButton, COLORS.accent, 0.12, 1.5)
local floatingScale = create("UIScale", floatingButton, {
    Scale = 1,
})
create("UIGradient", floatingButton, {
    Color = ColorSequence.new(
        Color3.fromRGB(23, 37, 62),
        Color3.fromRGB(49, 32, 83)
    ),
    Rotation = 45,
})

create("TextLabel", floatingButton, {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.GothamBold,
    Text = "N",
    TextColor3 = COLORS.accent,
    TextSize = 22,
    ZIndex = 11,
})

local floatingDot = create("Frame", floatingButton, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -5, 0, 5),
    Size = UDim2.fromOffset(11, 11),
    BackgroundColor3 = COLORS.green,
    BorderSizePixel = 0,
    ZIndex = 12,
})
addCorner(floatingDot, 10)
addStroke(floatingDot, COLORS.panel, 0, 2)

local isOpen = true
task.defer(function()
    if screenGui.Parent then
        tween(panel, 0.3, {GroupTransparency = 0})
        tween(shade, 0.3, {BackgroundTransparency = 0.38})
    end
end)

local function setPanelOpen(open)
    if isOpen == open then
        return
    end

    isOpen = open
    if open then
        shade.Visible = true
        shade.BackgroundTransparency = 1
        panel.GroupTransparency = 1
        tween(panel, 0.24, {GroupTransparency = 0})
        tween(shade, 0.24, {BackgroundTransparency = 0.38})

        if floatingButton.Visible then
            tween(floatingScale, 0.14, {Scale = 0.72})
            task.delay(0.14, function()
                if isOpen then
                    floatingButton.Visible = false
                    floatingScale.Scale = 1
                end
            end)
        end
    else
        tween(panel, 0.2, {GroupTransparency = 1})
        tween(shade, 0.2, {BackgroundTransparency = 1})
        task.delay(0.21, function()
            if not isOpen then
                shade.Visible = false
                floatingButton.Visible = true
                floatingScale.Scale = 0.76
                tween(floatingScale, 0.2, {Scale = 1})
            end
        end)
    end
end

local function releaseCursor()
    if isFixing then
        return
    end

    isFixing = true
    statusDot.BackgroundColor3 = COLORS.accent
    statusText.Text = "Tentando liberar o cursor..."
    statusHint.Text = "Restaurando o comportamento padrão do mouse."

    local function applyDefaultMouse()
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    end

    applyDefaultMouse()

    -- Reaplica por um instante caso a câmera do jogo tente travar o mouse de novo.
    for _, delaySeconds in ipairs({0.08, 0.2, 0.4, 0.7}) do
        task.delay(delaySeconds, applyDefaultMouse)
    end

    task.delay(0.75, function()
        statusDot.BackgroundColor3 = COLORS.green
        statusText.Text = "Comando enviado"
        statusHint.Text = "Se continuar travado, a câmera do jogo pode estar forçando o bloqueio."
        task.wait(1.8)
        if screenGui.Parent then
            statusText.Text = "Cursor pronto"
            statusHint.Text = "Use a tecla escolhida se o mouse travar."
        end
        isFixing = false
    end)
end

fixButton.Activated:Connect(releaseCursor)

keyButton.Activated:Connect(function()
    choosingKey = true
    keyButton.Text = "PRESSIONE..."
    keyButton.TextColor3 = COLORS.green
    keyHint.Text = "Esc cancela  •  Right Shift é reservado"
end)

closeButton.Activated:Connect(function()
    setPanelOpen(false)
end)

local dragging = false
local dragMoved = false
local dragInput
local dragStart
local buttonStart

floatingButton.Activated:Connect(function()
    if dragMoved then
        dragMoved = false
        return
    end
    setPanelOpen(true)
end)

floatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragMoved = false
        dragInput = input
        dragStart = input.Position
        buttonStart = floatingButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                task.delay(0.2, function()
                    dragMoved = false
                end)
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    local isMouseDrag = dragInput
        and dragInput.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement
    local isTouchDrag = input == dragInput

    if dragging and (isMouseDrag or isTouchDrag) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 7 then
            dragMoved = true
        end

        local camera = workspace.CurrentCamera
        if camera then
            local viewport = camera.ViewportSize
            local startX = buttonStart.X.Scale * viewport.X + buttonStart.X.Offset
            local startY = buttonStart.Y.Scale * viewport.Y + buttonStart.Y.Offset
            local halfSize = floatingButton.AbsoluteSize / 2
            local x = math.clamp(startX + delta.X, halfSize.X, viewport.X - halfSize.X)
            local y = math.clamp(startY + delta.Y, halfSize.Y, viewport.Y - halfSize.Y)
            floatingButton.Position = UDim2.fromOffset(x, y)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if choosingKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.Escape then
                choosingKey = false
                keyButton.Text = FIX_KEY.Name
                keyButton.TextColor3 = COLORS.accent
                keyHint.Text = "Toque aqui e pressione uma tecla"
                return
            end

            if input.KeyCode == PANEL_KEY then
                keyHint.Text = "Right Shift fica reservado para o painel"
                return
            end

            FIX_KEY = input.KeyCode
            choosingKey = false
            keyButton.Text = FIX_KEY.Name
            keyButton.TextColor3 = COLORS.accent
            keyHint.Text = "Atalho atualizado"
            statusText.Text = "Atalho salvo: " .. FIX_KEY.Name
            statusHint.Text = "Use essa tecla para liberar o cursor."
        end
        return
    end

    if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end

    if input.KeyCode == PANEL_KEY then
        setPanelOpen(not isOpen)
        return
    end

    if input.KeyCode == FIX_KEY then
        releaseCursor()
    end
end)
